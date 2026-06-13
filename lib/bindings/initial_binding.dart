import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/data_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // LazyPut ensures controllers are only initialized when needed, saving memory
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<DataController>(() => DataController(), fenix: true);
  }
}
