self.addEventListener('push', function(event) {
  console.log('[push-sw] push event received!');
  let data = {};
  if (event.data) {
    try {
      data = event.data.json();
    } catch (e) {
      data = { title: 'お知らせ', body: event.data.text() };
    }
  }

  console.log('[push-sw] data:', JSON.stringify(data));

  const title = data.title ?? 'お知らせ';
  const options = {
    body: data.body ?? '',
    icon: '/horse_odds_finder/icons/Icon-192.png',
    data: { url: data.url ?? 'https://baganriki.com/horse_odds_finder/' },
  };

  event.waitUntil(
    self.registration.showNotification(title, options).then(() => {
      console.log('[push-sw] showNotification called');
    })
  );
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  const url = event.notification.data?.url ?? 'https://baganriki.com/horse_odds_finder/';
  event.waitUntil(clients.openWindow(url));
});
