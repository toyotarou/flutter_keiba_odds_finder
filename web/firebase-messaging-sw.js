self.addEventListener('push', function(event) {
  let data = {};
  if (event.data) {
    try {
      data = event.data.json();
    } catch (e) {
      data = { title: 'お知らせ', body: event.data.text() };
    }
  }

  const title = data.title ?? 'お知らせ';
  const options = {
    body: data.body ?? '',
    icon: '/horse_odds_finder/icons/Icon-192.png',
    badge: '/horse_odds_finder/icons/Icon-192.png',
    data: { url: data.url ?? 'https://baganriki.com/horse_odds_finder/' },
  };

  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  const url = event.notification.data?.url ?? 'https://baganriki.com/horse_odds_finder/';
  event.waitUntil(clients.openWindow(url));
});
