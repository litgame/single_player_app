'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "a1b80197e7e7c98835dc7aaab048ae16",
"assets/assets/images/2.0x/logo.png": "72acae0afde4758faf06a11a42b7df4e",
"assets/assets/images/3.0x/logo.png": "e3a968497103b62ef473d9dbb4020e35",
"assets/assets/images/bg/generic.jpg": "d52940a8e8369f96147ace1df28e6b04",
"assets/assets/images/bg/notext.jpg": "dec90140e1ade95ac2574e7e7153153a",
"assets/assets/images/bg/places.jpg": "17b8e3f684b6b3b14cab8be19679ca17",
"assets/assets/images/bg/roles.jpg": "327328889ae5f6d1f6333e8a5be6779e",
"assets/assets/images/bg_pattern.png": "6d5493796900b6510e6d78323ee71d77",
"assets/assets/images/logo.png": "b4601ef19333df4e0a9bbf89694f4c75",
"assets/assets/images/logo_ios.png": "a2bb5ec8443f2b81792fcb8a9b0b6760",
"assets/assets/images/magic/explosion_1.png": "8b3366e355e78a8a63fdd968a5e218a0",
"assets/assets/images/magic/explosion_2.png": "563a364f22b4341fdf3f076ba5c3fd35",
"assets/assets/images/magic/explosion_3.png": "8ce338076f358c11f7961aae63a01085",
"assets/assets/images/magic/explosion_4.png": "e87602c9a551cad2a4b8fc348652a715",
"assets/assets/images/magic/explosion_5.png": "8eb4d7ce2ed57391072dc35ccd9cc1a5",
"assets/assets/images/magic/explosion_6.png": "23df43f664f5f3c014a86fe54f71233a",
"assets/assets/images/magic/magic_box.png": "f2b800d5031a9683d4549d4dcd9a457a",
"assets/assets/images/magic/magic_sphere.gif": "13265f5fcfa1b81cc77ca8c5280315bc",
"assets/assets/images/magic/wand.png": "ad46bf6687cbd5f224acf95fa6c55f4d",
"assets/assets/sounds/magic_happen.mp3": "52fe819a4e44a461f4c5abf569539dca",
"assets/dotenv": "632282c2ac972532c6de8b638d160b51",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/NOTICES": "155346dba099e7abe30a60ce38707098",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "e7006a0a033d834ef9414d48db3be6fc",
"assets/shaders/ink_sparkle.frag": "ba69ce025f56e6bc28611af3e3d2c593",
"favicon.png": "6662938b652ca29b3f341a3a0c271e3a",
"icons/Icon-192.png": "6e3917cc6ec5fd335bfffae5d72d3137",
"icons/Icon-512.png": "93d480fe2c74ab81b853b1467d594227",
"icons/Icon-maskable-192.png": "6e3917cc6ec5fd335bfffae5d72d3137",
"icons/Icon-maskable-512.png": "93d480fe2c74ab81b853b1467d594227",
"index.html": "56d4cc87adea13f69f005ac30c44e3e4",
"/": "56d4cc87adea13f69f005ac30c44e3e4",
"main.dart.js": "804338bbcf9deb2565bc0a345127dad9",
"manifest.json": "072a3528e5a1d2b440480b217c3ad778",
"version.json": "bbc21a6f05a1e5ea6b87685772a7877b"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
