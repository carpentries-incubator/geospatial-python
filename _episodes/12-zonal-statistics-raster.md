---
title: "Calculating Zonal Statistics on Rasters"
teaching: 40
exercises: 20
questions:
- ""
objectives:

keypoints:

---
> ## Things You’ll Need To Complete This Episode
> See the [lesson homepage]({{ site.baseurl }}) for detailed information about the software,
> data, and other prerequisites you will need to work through the examples in this episode.
{: .prereq}

So far we have chained together a couple of geospatial operations, including reprojection and raster math, to product our Canopy Height Model (CHM). Now that we have our CHM, we can compute statistics with it to get a better understanding of how canopy height varies across our study area. If we want to focus on specific areas, or zones, of interest when calculating these statistics, we can use zonal statistics.

## Zonal Statistics with xarray-spatial
We often want to perform calculations for specific zones in a raster. These zones can be delineated by points, lines, or polygons (vectors). Using a package called `xarray-spatial`, we can calculate the minimum, maximum, mean, median, and standard deviation for all zones in a raster using a single function call, `xrspatial.zonal_stats`.

In order to accomplish this, we first need to read in our vector data and rasterize it so that we have a grid with values representing each of our zones, where each pixel in the grid overlaps with a corresponding pixel in our CHM. To read this vector data, we can use geopandas, and to rasterize it, we can use the `rasterio.features.rasterize` function.

~~~
import xarray as xr
import geopandas as gpd
import rasterio

roads = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HARV_roads.shp")
shapes = roads[['geometry', 'RULEID']].values.tolist()
zones_arr_out_shape = canopy_HARV.shape[1:]
canopy_HARV_transform = canopy_HARV.rio.transform()
road_zones_arr = rasterio.features.rasterize(shapes, fill = 0, out_shape = zones_arr_out_shape, transform=canopy_HARV_transform)
~~~
{: .language-python}


~~~
road_canopy_zones_arr = np.where(road_zones_arr == 0, 7,road_zones_arr)
road_canopy_zones_xarr = xr.DataArray(road_canopy_zones_arr)
canopy_HARV_b1 = canopy_HARV.sel(band=1)
~~~
{: .language-python}


~~~
zonal_stats(road_canopy_zones_xarr, canopy_HARV_b1)
~~~
{: .language-python}

output raster. For example, suppose we are interested in mapping the heights of trees across an entire field site. In that case, we might want to calculate the difference between the Digital Surface Model (DSM, tops of trees) and the Digital Terrain Model (DTM, ground level). The resulting dataset is referred to
as a Canopy Height Model (CHM) and represents the actual height of trees,
buildings, etc. with the influence of ground elevation removed.
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

