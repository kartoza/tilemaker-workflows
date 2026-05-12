#!/usr/bin/env bash

SERVE_DIR="${1:-output}"

if [ ! -d "$SERVE_DIR" ] || [ -z "$(find "$SERVE_DIR" -name '*.mbtiles' -print -quit 2>/dev/null)" ]; then
  echo "No .mbtiles files found in ${SERVE_DIR}/"
  echo "Run a processing workflow first, e.g.: nix run .#processMalta"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_PORT="${NGINX_PORT:-8080}"

# Generate a temporary nginx config pointing at the local dirs
NGINX_TMPDIR=$(mktemp -d)
trap 'kill $MBTILE_PID 2>/dev/null; nginx -s stop -c "$NGINX_TMPDIR/nginx.conf" 2>/dev/null; rm -rf "$NGINX_TMPDIR"' EXIT

cat > "$NGINX_TMPDIR/nginx.conf" <<NGINXEOF
worker_processes auto;
daemon off;
pid $NGINX_TMPDIR/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include       $(nginx -V 2>&1 | grep -oP 'conf-path=\K[^"]+' | xargs dirname)/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    tcp_nopush      on;
    keepalive_timeout 65;
    gzip            on;
    gzip_types      application/json application/x-protobuf text/html text/css application/javascript;

    client_body_temp_path $NGINX_TMPDIR/client_body;
    proxy_temp_path       $NGINX_TMPDIR/proxy;
    fastcgi_temp_path     $NGINX_TMPDIR/fastcgi;
    uwsgi_temp_path       $NGINX_TMPDIR/uwsgi;
    scgi_temp_path        $NGINX_TMPDIR/scgi;

    access_log /dev/stdout;
    error_log  /dev/stderr;

    server {
        listen $NGINX_PORT;
        server_name _;

        location / {
            root $SCRIPT_DIR;
            try_files \$uri \$uri/ =404;
            add_header Access-Control-Allow-Origin *;
        }

        location /services/ {
            proxy_pass http://127.0.0.1:8000/services/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            add_header Access-Control-Allow-Origin *;
        }
    }
}
NGINXEOF

echo ""
echo "  Tilemaker Server (local)"
echo "  ========================"
echo ""
echo "  Viewer:    http://localhost:${NGINX_PORT}/viewer.html"
echo "  TileJSON:  http://localhost:${NGINX_PORT}/services/"
echo "  Styles:    http://localhost:${NGINX_PORT}/styles/"
echo "  Fonts:     http://localhost:${NGINX_PORT}/fonts/"
echo ""
echo "  Serving tiles from ${SERVE_DIR}/..."
echo ""

# Start mbtileserver in background on internal port 8000
mbtileserver \
  --port 8000 \
  --basemap-style-url "https://raw.githubusercontent.com/openmaptiles/osm-bright-gl-style/master/style.json" \
  -d "$SERVE_DIR" &
MBTILE_PID=$!

# Open the viewer in the default browser
if command -v xdg-open &>/dev/null; then
  xdg-open "http://localhost:${NGINX_PORT}/viewer.html" &
elif command -v open &>/dev/null; then
  open "http://localhost:${NGINX_PORT}/viewer.html" &
fi

# Run nginx in foreground
nginx -c "$NGINX_TMPDIR/nginx.conf"
