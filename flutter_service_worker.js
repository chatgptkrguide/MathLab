'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"manifest.json": "ec084a18313ae1d6dbf189db595584ae",
"index.html": "5784b4f1893044f890afc4845ba7c2e5",
"/": "5784b4f1893044f890afc4845ba7c2e5",
"manifest.json.backup": "ec084a18313ae1d6dbf189db595584ae",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "16f393fd94a5a60cd7e59ed675d8a831",
"assets/assets/icons/gomath_logo_center.png": "d4e1a65b9647d2364741b37cd940c921",
"assets/assets/icons/gomath_logo.png": "44c4e27e4d9f0c72dcb502e5c63e21b4",
"assets/assets/icons/character_design.png": "6da223570d082820f626af15bdba8006",
"assets/assets/icons/streak_fire.png": "675427dffcad7d6d20e63d2524ab1379",
"assets/assets/icons/book_pencil.png": "8fce46169f27f8b5169edb71d3755b4e",
"assets/assets/icons/gomath_logo_top.png": "f3a8dce733a63ee0409884fcd1d7f676",
"assets/assets/icons/gomath_logo_small.png": "68fa42f8f79528f6c53b5857d7017c6c",
"assets/assets/icons/streak_icon.png": "403d938aa3ca2ffe0a280c74039d8bc3",
"assets/assets/icons/xp_icon.png": "981b1b1a6af987963f922f180adb4956",
"assets/assets/icons/logo_main.png": "ad3be5af4855044340425cb3ab6b68fe",
"assets/assets/icons/robot_character.png": "fa31b12e7a0d7d670a2dde5478605c82",
"assets/assets/images/microscope.png": "dc46da5e6b8981606928e3e33069fc8c",
"assets/assets/images/bag.png": "c2f2cbbd94523dda9af9188af6f3280d",
"assets/assets/images/winner.png": "2850fc41ae1fa7b4e25f1bde6d29ca08",
"assets/assets/images/clock.png": "6efe39dddf44c529972ee1da33e4007d",
"assets/assets/images/vexel.png": "7f4ec823698e4a085ad9969cedad9411",
"assets/assets/images/book_pencil.png": "8fce46169f27f8b5169edb71d3755b4e",
"assets/assets/images/figma_03_profile_reference.png": "01dcd2a22d645c6aa5aff27a2468a3fe",
"assets/assets/images/figma_01_lessons_reference.png": "ec7c4a4e49f30c4832fe83e8c27d8d59",
"assets/assets/images/README.md": "c8d64db93e66f0691b5f4890b667d57b",
"assets/assets/images/figma_05_extra_reference.png": "2e4de49615f29c192ab66289938d4125",
"assets/assets/images/figma_home_reference.png": "31b578f70ae0ff7d558bc7d6bcc5f3e7",
"assets/assets/images/globe.png": "786aa599847e87a4dffeb332bf8a471d",
"assets/assets/images/blackboard.png": "10310e89105790e172260a694479b2c6",
"assets/assets/images/book.png": "d1a3679b5a38777bfe79de34d8dbca25",
"assets/assets/images/rulers.png": "73e0f296c230fa0bed6dfa764ab1e5fc",
"assets/assets/images/robot_character.png": "fa31b12e7a0d7d670a2dde5478605c82",
"assets/assets/images/laptop.png": "f9ecaff08acf7cd7793dfc6a53bbd2a0",
"assets/assets/images/figma_04_history_reference.png": "fe4633f58d8dfa6d643ddd3bda9ebce6",
"assets/assets/images/figma_02_errors_reference.png": "bc2fc4953531e43c1a68adfaee30af34",
"assets/assets/fonts/NEXON-Lv1-Gothic-Regular.otf": "84c0ea9d65324c758c8bd9686207afea",
"assets/assets/fonts/NEXON-Lv1-Gothic-Bold.otf": "f8a9b84216af5155ffe0e8661203f36f",
"assets/assets/fonts/nexon_lv1_gothic.zip": "f253d1b9909be432158c010d94a3729a",
"assets/assets/fonts/NotoSansKR-Variable.ttf": "138709011225153288f260a9beacc90a",
"assets/assets/fonts/Inter-Variable.ttf": "7c80433dfb0d6e565327d9beeb774bac",
"assets/assets/fonts/Roboto-Regular.ttf": "86da78cb59576328483a11c6ef74bc2b",
"assets/assets/fonts/NEXON-Lv1-Gothic-Light.otf": "de308b576c70af4871d436e89918fdf6",
"assets/assets/fonts/Roboto-Bold.ttf": "dff90a732eb2770d7ceb0af40a87485a",
"assets/assets/fonts/Roboto-Medium.ttf": "c887b7c9330f40c58124a53b03ec9ce2",
"assets/assets/data/episodes.json": "58e0494c51d30eb3494f7c9198986bb9",
"assets/assets/data/lessons.json": "96af99083913cb8bfa406796b1ee01d9",
"assets/assets/data/problems.json": "d5454220dc1c659cd6e7036710d965ab",
"assets/assets/problems/polynomials/polynomial_001.json": "147c117972b4c92b9da866d2af311f95",
"assets/assets/problems/polynomials/polynomial_002.json": "8f34fa61fba5c8ae58542dbba089ccb9",
"assets/assets/problems/images/README.md": "b521e10a2fde13a86299d773acf06500",
"assets/fonts/MaterialIcons-Regular.otf": "6d3ec644ae1b8441cfb01da2a97402ad",
"assets/NOTICES": "5cf403ef38a82b6d1d0e5e09c5c89478",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/FontManifest.json": "81961f7823a6799fe3a3550918f3c581",
"assets/AssetManifest.bin": "243b265ed61f4535dfa7ea8fe3583471",
"assets/AssetManifest.json": "377006e48cb2f7928108d25543a15951",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter_bootstrap.js": "f55cd077c871be8a78ca17bcb271db00",
"index.html.backup": "5784b4f1893044f890afc4845ba7c2e5",
"version.json": "1e4564b09609c1b0c25549827e09be4d",
"main.dart.js": "a6779061482068696b50f79d97ec16a3"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
