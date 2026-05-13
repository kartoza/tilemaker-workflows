FROM tilemaker-server-base:latest

LABEL org.opencontainers.image.title="Tilemaker Server"
LABEL org.opencontainers.image.description="OpenMapTiles-compliant vector tile server with 18 bundled styles, sprite sheets, and web viewer. Serve .mbtiles files via mbtileserver + nginx with MapLibre GL styles out of the box."
LABEL org.opencontainers.image.url="https://github.com/kartoza/tilemaker-workflows"
LABEL org.opencontainers.image.source="https://github.com/kartoza/tilemaker-workflows"
LABEL org.opencontainers.image.documentation="https://github.com/kartoza/tilemaker-workflows#readme"
LABEL org.opencontainers.image.vendor="Kartoza"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="Tim Sutton <tim@kartoza.com>, Jeremy Prior <jeremy@kartoza.com>"

COPY fonts/ /static/fonts/
