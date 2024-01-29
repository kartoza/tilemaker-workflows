# Processing Sandbox for Vector Tiles


## Pregenerating Coastlines

```
./get_data.sh
time tilemaker --output coastline.mbtiles \
  --bbox -180,-85,180,85 \
  --process process-coastline.lua \
  --config config-coastline.json
```




## Credits

Tim Sutton (tim@kartoza.com)
Jeremy Prior (jeremy@kartoza.com)
