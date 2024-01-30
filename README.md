# Processing Sandbox for Vector Tiles


## Pregenerating Coastlines

```
./get_data.sh
time tilemaker --output coastline.mbtiles \
  --bbox -180,-85,180,85 \
  --process process-coastline.lua \
  --config config-coastline.json
```

This will create ``coastline.mbtiles`` which contains all the coastlines later.


## Generating a country

This is optimised for performance:

```
process_malta.sh
```

You can then drag and drop the resulting mbtiles file into QGIS.

![](img/malta.png)

## Generating the world

This is optimised for performance:

```
process_planet.sh
```

During processing, it will consume around 250GB of temporary storage in the
work directory (this will be expunged afterwards).

You can then drag and drop the resulting mbtiles file into QGIS.

![](img/malta.png)


## Credits

Tim Sutton (tim@kartoza.com)
Jeremy Prior (jeremy@kartoza.com)
