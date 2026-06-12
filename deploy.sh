#!/bin/bash
set -e

ZONE_ID="fd77fb9ef91474ee23580bdc5cfde584"
CF_TOKEN=$(cat ~/cloudflare_token.txt)
PROJECT_DIR="$HOME/Desktop/HIDEYUKI/flutter/keiba_odds_finder"

echo "=== ① ビルド ==="
cd "$PROJECT_DIR"
flutter build web --release --base-href /horse_odds_finder/

echo "=== ② サーバーへ転送 ==="
rsync -avz --delete --ignore-times build/web/ centos@49.212.166.123:/var/www/horse_odds_finder/public/horse_odds_finder/

echo "=== ③ Cloudflareキャッシュクリア ==="
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/purge_cache" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'

echo ""
echo "=== デプロイ完了！ ==="
