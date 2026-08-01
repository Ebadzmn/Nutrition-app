import 'package:get/get.dart';
import '../network/api_client.dart';
import '../services/notification_service.dart';
import '../../auth/controller/auth_controller.dart';
import '../../premium/controller/premium_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      // ApiClient(baseUrl: 'https://herwellness-server.vercel.app/api/v1'),
      // ApiClient(baseUrl: 'http://10.10.7.111:5000/api/v1'),
      ApiClient(baseUrl: 'https://api.herwellness.app/api/v1'),
      permanent: true,
    );
    Get.put(AuthController(), permanent: true);
    Get.put(PremiumController(), permanent: true);
    Get.putAsync<NotificationService>(
      () async => NotificationService().init(),
      permanent: true,
    );
  }
}
