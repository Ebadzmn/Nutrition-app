import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../core/app_route.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../../core/network/api_client.dart';
import '../widgets/subscription_success_dialog.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _loadingProducts = true;
  bool _purchasing = false;
  String _selectedProductId = 'com.herwellnessapp.monthly';

  @override
  void initState() {
    super.initState();

    // Pre-select plan if navigated from settings with a plan argument
    final args = Get.arguments;
    if (args is Map && args['plan'] != null) {
      final plan = args['plan'] as String;
      _selectedProductId = plan == 'annual'
          ? 'com.herwellnessapp.annual'
          : 'com.herwellnessapp.monthly';
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint('IAP Stream error: $error');
    });
    _initStore();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initStore() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!mounted) return;
      if (!available) {
        setState(() {
          _loadingProducts = false;
        });
        return;
      }

      const Set<String> ids = {'com.herwellnessapp.monthly', 'com.herwellnessapp.annual'};
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);
      if (!mounted) return;
      
      setState(() {
        _products = response.productDetails;
        _loadingProducts = false;
      });
    } catch (e) {
      debugPrint('Error initializing store: $e');
      if (mounted) {
        setState(() {
          _loadingProducts = false;
        });
      }
    }
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        if (mounted) {
          setState(() {
            _purchasing = true;
          });
        }
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          if (mounted) {
            setState(() {
              _purchasing = false;
            });
          }
          Get.snackbar(
            'Purchase Error',
            purchaseDetails.error?.message ?? 'Purchase transaction failed.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          
          final success = await _verifyPurchaseOnBackend(purchaseDetails);
          if (mounted) {
            setState(() {
              _purchasing = false;
            });
          }

          if (success) {
            if (purchaseDetails.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchaseDetails);
            }
            final authController = Get.find<AuthController>();
            
            // Immediately apply active subscription locally to ensure UI updates instantly
            final isAnnual = purchaseDetails.productID.contains('annual');
            final planName = isAnnual ? 'Annual Premium Plan' : 'Monthly Premium Plan';
            final now = DateTime.now();
            final expiresAt = isAnnual ? now.add(const Duration(days: 365)) : now.add(const Duration(days: 30));

            final currentUser = authController.currentUser.value;
            if (currentUser != null) {
              final updatedUser = UserModel(
                id: currentUser.id,
                email: currentUser.email,
                username: currentUser.username,
                name: currentUser.name,
                role: currentUser.role,
                isTrialActive: false,
                hasPremiumAccess: true,
                trialExpiresAt: currentUser.trialExpiresAt,
                subscription: {
                  'id': 'local_${now.millisecondsSinceEpoch}',
                  'type': isAnnual ? 'annual' : 'monthly',
                  'plan': isAnnual ? 'annual' : 'monthly',
                  'status': 'active',
                  'isActive': true,
                  'productId': purchaseDetails.productID,
                  'startDate': now.toIso8601String(),
                  'endDate': expiresAt.toIso8601String(),
                  'expiresAt': expiresAt.toIso8601String(),
                },
              );
              authController.currentUser.value = updatedUser;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));
            }

            await authController.refreshCurrentUser();
            if (mounted) {
              Get.back();
            }
            SubscriptionSuccessDialog.show(planName: planName);
          } else {
            Get.snackbar(
              'Verification Failed',
              'Unable to verify your purchase. Please contact support.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orangeAccent,
              colorText: Colors.white,
            );
          }
        }
      }
    }
  }

  Future<bool> _verifyPurchaseOnBackend(PurchaseDetails purchase) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      
      // Determine platform and invoke relevant verify IAP backend endpoint
      final isIOS = GetPlatform.isIOS;
      
      if (isIOS) {
        final receipt = purchase.verificationData.localVerificationData;
        final response = await apiClient.post(
          '/integration/iap/verify-apple',
          data: {'receiptData': receipt},
        );
        return response.isSuccess && response.data?['valid'] == true;
      } else {
        final token = purchase.verificationData.serverVerificationData;
        final response = await apiClient.post(
          '/integration/iap/verify-google',
          data: {
            'packageName': 'com.herwellness.herwellness_flutter',
            'productId': purchase.productID,
            'token': token,
          },
        );
        return response.isSuccess && response.data?['valid'] == true;
      }
    } catch (e) {
      debugPrint('Purchase verification API error: $e');
      return false;
    }
  }

  void _buyProduct(String productId) async {
    ProductDetails? product;
    for (var prod in _products) {
      if (prod.id == productId) {
        product = prod;
        break;
      }
    }

    if (product == null) {
      Get.snackbar(
        'Product Not Loaded',
        'Store plan details are currently unavailable. Please try simulating checkouts below.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    PurchaseParam purchaseParam;

    if (!kIsWeb && Platform.isAndroid && product is GooglePlayProductDetails) {
      // Best Practice: Check if discounted subscription offer ('annual-discount-50' or tag 'annual50') exists
      final offers = product.productDetails.subscriptionOfferDetails;
      String? selectedOfferToken;

      if (offers != null && offers.isNotEmpty) {
        final matchingOffer = offers.firstWhereOrNull(
          (offer) =>
              offer.offerId == 'annual-discount-50' ||
              offer.offerTags.contains('annual50'),
        );

        // If specific discount offer is found, pass its token; otherwise fallback to primary offer token
        selectedOfferToken = matchingOffer?.offerIdToken ?? product.offerToken ?? offers.first.offerIdToken;
      }

      purchaseParam = GooglePlayPurchaseParam(
        productDetails: product,
        offerToken: selectedOfferToken,
      );
    } else {
      purchaseParam = PurchaseParam(productDetails: product);
    }

    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      Get.snackbar('Error', 'Checkout initialization failed: $e');
    }
  }

  Future<void> _startMockCheckout(String type) async {
    setState(() {
      _purchasing = true;
    });

    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final token = type == 'monthly' ? 'mock_monthly_receipt' : 'mock_annual_receipt';
      final response = await apiClient.post(
        '/integration/iap/verify-apple',
        data: {'receiptData': token},
      );

      if (mounted) {
        setState(() {
          _purchasing = false;
        });
      }

      if (response.isSuccess && response.data?['valid'] == true) {
        Get.snackbar(
          'Upgrade Success',
          'Simulated sandbox subscription active!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withAlpha(26),
        );
        final authController = Get.find<AuthController>();
        await authController.refreshCurrentUser();
        if (mounted) {
          Get.back();
        }
      } else {
        Get.snackbar(
          'Checkout Failure',
          response.message.isNotEmpty ? response.message : 'Simulation failed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _purchasing = false;
        });
      }
      Get.snackbar('Error', 'Mock checkout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Attempt to read prices from queried App Store product data, fallback to defaults
    String monthlyPrice = '£11.99/month';
    String annualPrice = '£115.99/year';
    String annualBadge = 'BEST VALUE - SAVE 19%';
    
    for (var prod in _products) {
      if (prod.id == 'com.herwellnessapp.monthly') {
        monthlyPrice = '${prod.price}/month';
      } else if (prod.id == 'com.herwellnessapp.annual') {
        annualPrice = '${prod.price}/year';
        if (!kIsWeb && Platform.isAndroid && prod is GooglePlayProductDetails) {
          final offers = prod.productDetails.subscriptionOfferDetails;
          final discountOffer = offers?.firstWhereOrNull(
            (o) => o.offerId == 'annual-discount-50' || o.offerTags.contains('annual50'),
          );
          if (discountOffer != null && discountOffer.pricingPhases.isNotEmpty) {
            final promoPrice = discountOffer.pricingPhases.first.formattedPrice;
            annualPrice = '$promoPrice/year';
            annualBadge = 'SPECIAL OFFER - 50% OFF';
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Crown icon indicator
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(76),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ]
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unlock workouts, nutritional input, recipes, and AI Coaching.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Features list
                _buildFeatureItem(Icons.auto_awesome_rounded, 'AI-Powered Wellness Coach', 'Chat with your personalized AI health coach'),
                _buildFeatureItem(Icons.fitness_center_rounded, 'Phase-Optimized Workouts', 'Structured workout logs matched to menstrual phase'),
                _buildFeatureItem(Icons.restaurant_rounded, 'Full Recipe & Nutrition Library', 'Phase-specific eating plans and food database'),
                _buildFeatureItem(Icons.analytics_rounded, 'Advanced Cycle Insights', 'Detailed analysis of symptom correlations'),
                const SizedBox(height: 28),

                // Subscription Plan Cards
                _buildPlanCard(
                  id: 'com.herwellnessapp.monthly',
                  title: 'Monthly Subscription',
                  duration: '1 Month',
                  price: monthlyPrice,
                  subtitle: '7-Day Free Trial included · Renews monthly',
                  badge: 'Cancel anytime',
                ),
                const SizedBox(height: 12),
                _buildPlanCard(
                  id: 'com.herwellnessapp.annual',
                  title: 'Annual Subscription',
                  duration: '1 Year',
                  price: annualPrice,
                  subtitle: '7-Day Free Trial included · Renews yearly',
                  badge: annualBadge,
                  highlighted: true,
                ),
                const SizedBox(height: 28),

                // Active purchase button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _buyProduct(_selectedProductId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Start 7-Day Free Trial',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Legal links for Apple App Store Guideline 3.1.2(c)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final Uri url = Uri.parse('https://sites.google.com/view/herwallness/home');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                    TextButton(
                      onPressed: () async {
                        final Uri url = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text(
                        'Terms of Use (EULA)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Divider and mock simulated purchase options for developer sandbox validation
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.primary.withAlpha(51))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('SIMULATOR DEVS ONLY', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ),
                    Expanded(child: Divider(color: AppColors.primary.withAlpha(51))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_circle_right_outlined, size: 16),
                      label: const Text('Simulate Monthly', style: TextStyle(fontSize: 12)),
                      onPressed: () => _startMockCheckout('monthly'),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.stars_outlined, size: 16),
                      label: const Text('Simulate Annual', style: TextStyle(fontSize: 12)),
                      onPressed: () => _startMockCheckout('annual'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_purchasing || _loadingProducts)
            Container(
              color: Colors.black.withAlpha(76),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 20),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String duration,
    required String price,
    required String subtitle,
    required String badge,
    bool highlighted = false,
  }) {
    final isSelected = _selectedProductId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductId = id;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white 
              : AppColors.surface.withAlpha(153),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: highlighted 
                          ? AppColors.accentGreenLight 
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.w700, 
                        color: highlighted ? AppColors.accentGreen : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
