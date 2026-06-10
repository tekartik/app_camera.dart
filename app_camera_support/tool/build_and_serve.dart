import 'package:tekartik_flutter_build/app_build.dart';
import 'package:tekartik_web_publish/surge_web_publish.dart';

var webAppBuilder = FlutterWebAppBuilder(
  deployer: SurgeWebAppDeployer(
    options: SurgeWebAppDeployOptions(domain: 'qrscan-example.surge.sh'),
  ),
  options: FlutterWebAppOptions(
    path: '../qrscan_flutter_example',
    buildOptions: FlutterWebAppBuildOptions(wasm: true),
  ),
);
Future<void> main() async {
  await webAppBuilder.buildAndServe();
}
