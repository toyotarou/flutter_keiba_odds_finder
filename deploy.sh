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

echo "=== ④ 強制アップデート用のビルドID付与 ==="
echo -n "${VERSION}" > build/web/build_id.txt
python3 - <<EOF
import pathlib

# index.html：ビルドIDの埋め込みと、flutter_bootstrap.js の読み込みにバージョン付与
p = pathlib.Path('build/web/index.html')
s = p.read_text(encoding='utf-8')
assert "'__BUILD_ID__'" in s, 'index.html に __BUILD_ID__ が見つかりません'
assert 'src="flutter_bootstrap.js"' in s, 'index.html に flutter_bootstrap.js の読み込みが見つかりません'
s = s.replace("'__BUILD_ID__'", "'${VERSION}'")
s = s.replace('src="flutter_bootstrap.js"', 'src="flutter_bootstrap.js?v=${VERSION}"')
p.write_text(s, encoding='utf-8')

# flutter_bootstrap.js：main.dart.js の読み込みにバージョン付与（古い main.dart.js が残らないように）
p = pathlib.Path('build/web/flutter_bootstrap.js')
s = p.read_text(encoding='utf-8')
assert '"mainJsPath":"main.dart.js"' in s, 'flutter_bootstrap.js に mainJsPath が見つかりません'
s = s.replace('"mainJsPath":"main.dart.js"', '"mainJsPath":"main.dart.js?v=${VERSION}"')
p.write_text(s, encoding='utf-8')

print('build_id.txt / index.html / flutter_bootstrap.js: v=${VERSION} を付与しました')
EOF

echo "=== ⑤ サーバーへ転送 ==="
rsync -avz --delete --ignore-times build/web/ centos@49.212.166.123:/var/www/horse_odds_finder/public/horse_odds_finder/

echo "=== ⑥ Cloudflareキャッシュクリア ==="
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/purge_cache" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'

echo ""
echo "=== デプロイ完了！（v=${VERSION}） ==="
echo ""
echo "【Androidのアイコン・スプラッシュを更新するには】"
echo "  PWAをアンインストール → Chromeでサイトを開いて再インストール"
