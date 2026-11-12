# Support tools

Dev scripts of the `app_camera.dart` repository (not a package to depend on),
run from this folder:

- `dart run tool/basic_run_ci_flutter.dart`: format, analyze and test every
  other package of the workspace (`ciPackageDirs`), what the `Run CI Flutter`
  workflow runs; `test/ci_packages_test.dart` checks that the list matches the
  root `workspace:`. `tool/basic_run_ci_dart.dart`: the pure Dart ones only.
- `dart run tool/run_ci.dart`: the same, with a `tool/ci.dart` of a package
  used when present.
- `dart run tool/build_and_serve.dart` / `tool/build_and_deploy.dart`: build
  the `qrscan_flutter_example` web app (wasm) and serve it locally / deploy it
  to <https://qrscan-example.surge.sh> (surge login needed).
- `tool/build_gh_pages.dart` / `tool/push_gh_pages.dart`: the older GitHub
  pages build (peanut).
