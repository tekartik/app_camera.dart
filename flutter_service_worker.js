'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "favicon.png": "5dcef449791fa27946b3d35ad8803796",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/packages/tekartik_js_qr/js/js_qr.js": "1322b5cc5c9461a60830a61d8b78aa77",
"assets/LICENSE": "e4f128cc3699846b99bb46bc56600f36",
"assets/AssetManifest.json": "412ef1de8bd14f09cfd2b88bb827b0bc",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/FontManifest.json": "01700ba55b08a6141f33e168c4a6c22f",
"main.dart.js": "f1ec2bfe266071b68cbdb01c270e2f29",
"manifest.json": "a2a93fce9f9160d2ceee4fb12c37ec3f",
"index.html": "0a385e253959f04107909d6c9c939ded",
"/": "0a385e253959f04107909d6c9c939ded"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
