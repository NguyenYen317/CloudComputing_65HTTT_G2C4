importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCBQonE7V0pjDUKZug7sSgQJyjy-VCutHc',
  authDomain: 'flutter-orderfood-1b333.firebaseapp.com',
  projectId: 'flutter-orderfood-1b333',
  storageBucket: 'flutter-orderfood-1b333.firebasestorage.app',
  messagingSenderId: '33969899605',
  appId: '1:33969899605:web:5bd52f2bffa0052f3e2cdc',
  measurementId: 'G-4QZNFETVDD',
});

var messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  var notification = payload.notification || {};
  var title = notification.title || 'Order Food';
  var options = {
    body: notification.body || 'Ban co thong bao moi.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
  };

  self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', function (event) {
  var data = event.notification.data || {};
  var fallbackUrl = self.location.origin;
  var targetUrl = data.url || fallbackUrl;

  event.notification.close();
  event.waitUntil(
    clients
      .matchAll({ type: 'window', includeUncontrolled: true })
      .then(function (clientList) {
        for (var i = 0; i < clientList.length; i += 1) {
          var client = clientList[i];
          if (client.url.startsWith(self.location.origin) && 'focus' in client) {
            return client.focus();
          }
        }

        if ('openWindow' in clients) {
          return clients.openWindow(targetUrl);
        }

        return undefined;
      })
  );
});
