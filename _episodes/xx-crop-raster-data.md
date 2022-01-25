---
title: "Crop raster data"
teaching: 40
exercises: 20
questions:
- "How can I crop my raster data to the area of interest?"
objectives:
- "Crop raster data with bounding box."
- "Crop raster data with a given polygon."
- "Crop raster data within the buffer of a geometry."
keypoints:
---

```python
from xrspatial import zonal_stats
import xarray as xr
import geopandas as gpd
import rasterio
import rioxarray

surface_HARV = rioxarray.open_rasterio("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif", masked=True)
terrain_HARV_UTM18 = rioxarray.open_rasterio("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop_UTM18.tif", masked=True)
terrain_HARV_matched = terrain_HARV_UTM18.rio.reproject_match(surface_HARV)
canopy_HARV = surface_HARV - terrain_HARV_matched

roads = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HARV_roads.shp")
```

Now that we have our CHM, we can compute statistics with it to understand how canopy height varies across our study area. If we want to focus on specific areas, or zones, of interest when calculating these statistics, we can use zonal statistics. To do this, we'll import the `zonal_stats` function from the package `xrspatial`.

