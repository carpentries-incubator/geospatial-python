---
title: "Calculating Zonal Statistics on Rasters"
teaching: 40
exercises: 20
questions:
- ""
objectives:

keypoints:

---

~~~
import xarray as xr
import geopandas as gpd
import rasterio

roads = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HARV_roads.shp")
shapes = roads[['geometry', 'RULEID']].values.tolist()
zones_arr_out_shape = canopy_HARV.shape[1:]
canopy_HARV_transform = canopy_HARV.rio.transform()
road_zones_arr = rasterio.features.rasterize(shapes, fill = 0, out_shape = zones_arr_out_shape, transform=canopy_HARV_transform)
road_canopy_zones_arr = np.where(road_zones_arr == 0, 7,road_zones_arr)
road_canopy_zones_xarr = xr.DataArray(road_canopy_zones_arr)
canopy_HARV_b1 = canopy_HARV.sel(band=1)
zonal_stats(road_canopy_zones_xarr, canopy_HARV_b1)
~~~
{: .language-python}

{% include links.md %}

