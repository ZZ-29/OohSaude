// Service Worker — Ooh! Saúde
var CACHE_NAME = 'ooh-saude-v1';
var CORE_FILES = [
  '/OohSaude/',
  '/OohSaude/index.html',
  '/OohSaude/manifest.json',
  '/OohSaude/icon-192.png',
  '/OohSaude/icon-512.png'
];

self.addEventListener('install', function(event){
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache){
      return cache.addAll(CORE_FILES);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', function(event){
  event.waitUntil(
    caches.keys().then(function(keys){
      return Promise.all(keys.filter(function(k){ return k!==CACHE_NAME; }).map(function(k){ return caches.delete(k); }));
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', function(event){
  if(event.request.method!=='GET') return;
  event.respondWith(
    caches.match(event.request).then(function(cached){
      if(cached) return cached;
      return fetch(event.request).then(function(resp){
        if(resp && resp.status===200 && event.request.url.indexOf(self.location.origin)===0){
          var respClone=resp.clone();
          caches.open(CACHE_NAME).then(function(cache){ cache.put(event.request, respClone); });
        }
        return resp;
      }).catch(function(){
        return caches.match('/OohSaude/index.html');
      });
    })
  );
});
