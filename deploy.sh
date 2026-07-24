#!/bin/bash
set -e

ZONE_ID="fd77fb9ef91474ee23580bdc5cfde584"
CF_TOKEN=$(cat ~/cloudflare_token.txt)
PROJECT_DIR="$HOME/Documents/keiba_odds_finder"
VERSION=$(date +%Y%m%d%H%M%S)

cd "$PROJECT_DIR"

echo "=== ① クリーンビルド ==="
flutter clean
flutter pub get

echo "=== ② ビルド ==="
flutter build web --release --base-href /horse_odds_finder/

echo "=== ③ アイコンURLにバージョン付与（キャッシュ回避） ==="
python3 - <<EOF
import json
with open('build/web/manifest.json') as f:
    data = json.load(f)
for icon in data.get('icons', []):
    src = icon['src']
    if '?' in src:
        src = src[:src.index('?')]
    icon['src'] = src + '?v=${VERSION}'
with open('build/web/manifest.json', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=4)
print('manifest.json: v=${VERSION} を付与しました')
EOF

echo "=== ④ サーバーへ転送 ==="
rsync -avz --delete --ignore-times build/web/ centos@49.212.166.123:/var/www/horse_odds_finder/public/horse_odds_finder/

echo "=== ⑤ Cloudflareキャッシュクリア ==="
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/purge_cache" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'

echo ""
echo "=== デプロイ完了！（v=${VERSION}） ==="
echo ""
echo "【Androidのアイコン・スプラッシュを更新するには】"
echo "  PWAをアンインストール → Chromeでサイトを開いて再インストール"
