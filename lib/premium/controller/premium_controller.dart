import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../widgets/subscription_success_dialog.dart';

class PremiumController extends GetxController {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  final products = <ProductDetails>[].obs;
  final loadingProducts = true.obs;
  final purchasing = false.obs;

  @override
  void onInit() {
    super.onInit();
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
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  Future<void> _initStore() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        loadingProducts.value = false;
        return;
      }

      const Set<String> ids = {'com.herwellnessapp.monthly', 'com.herwellnessapp.annual'};
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);
      
      products.value = response.productDetails;
      loadingProducts.value = false;
    } catch (e) {
      debugPrint('Error initializing store: $e');
      loadingProducts.value = false;
    }
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        purchasing.value = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          purchasing.value = false;
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
          purchasing.value = false;

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

  void buyProduct(String productId) async {
    ProductDetails? product;
    for (var prod in products) {
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

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      Get.snackbar('Error', 'Checkout initialization failed: $e');
    }
  }

  void restorePurchases() async {
    purchasing.value = true;
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      purchasing.value = false;
      Get.snackbar('Error', 'Restore purchases failed: $e');
    }
  }

  Future<void> startMockCheckout(String type) async {
    purchasing.value = true;
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final token = type == 'monthly' ? 'mock_monthly_receipt' : 'mock_annual_receipt';
      final response = await apiClient.post(
        '/integration/iap/verify-apple',
        data: {'receiptData': token},
      );

      purchasing.value = false;

      if (response.isSuccess && response.data?['valid'] == true) {
        Get.snackbar(
          'Upgrade Success',
          'Simulated sandbox subscription active!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withAlpha(26),
        );
        final authController = Get.find<AuthController>();
        await authController.refreshCurrentUser();
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
      purchasing.value = false;
      Get.snackbar('Error', 'Mock checkout error: $e');
    }
  }
}
