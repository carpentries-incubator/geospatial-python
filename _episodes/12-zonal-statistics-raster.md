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

So far we have chained together two geospatial operations, reprojection and raster math, to produce our Canopy Height Model (CHM) and learned how to read vector data with `geopandas`.

~~~
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
~~~
{: .language-python}

Now that we have our CHM, we can compute statistics with it to understand how canopy height varies across our study area. If we want to focus on specific areas, or zones, of interest when calculating these statistics, we can use zonal statistics. To do this, we'll import the `zonal_stats` function from the package `xrspatial`.

## Zonal Statistics with xarray-spatial
We often want to perform calculations for specific zones in a raster. These zones can be delineated by points, lines, or polygons (vectors). In the case of our Harvard Forest Dataset, we have a shapefile that contains lines representing walkways, footpaths, and roads. A single function call, `xrspatial.zonal_stats` can calculate the minimum, maximum, mean, median, and standard deviation for each line zone in our CHM.

In order to accomplish this, we first need to rasterize our `roads` geodataframe with the `rasterio.features.rasterize` function. This will produce a grid with number values representing each type of line, with numbers varying with the type of the line (walkway, footpath, road, etc.). This grid's values will then represent each of our zones for the `xrspatial.zonal_stats` function, where each pixel in the zone grid overlaps with a corresponding pixel in our CHM raster. 

Before rasterizing, we need to do a little work to make a variable, `shapes` that associates a line with a unique number to represent that line. This variable will later be used as the first argument to `rasterio.features.rasterize`.

~~~
shapes = roads[['geometry', 'RULEID']].values.tolist()
~~~
{: .language-python}

The `shapes` variable contains a list of tuples, where each tuple contains the shapely geometry from the `geometry` column of the `roads` geodataframe and the unique zone ID, from the `RULEID` column in the `roads` geodataframe.

~~~
[[<shapely.geometry.multilinestring.MultiLineString at 0x173463ac0>, 5],
 [<shapely.geometry.linestring.LineString at 0x169b957c0>, 6],
 [<shapely.geometry.linestring.LineString at 0x173475280>, 6],
 [<shapely.geometry.linestring.LineString at 0x1734751c0>, 1],
 [<shapely.geometry.linestring.LineString at 0x1734751f0>, 1],
 [<shapely.geometry.linestring.LineString at 0x173475250>, 1],
 [<shapely.geometry.linestring.LineString at 0x173475370>, 1],
 [<shapely.geometry.linestring.LineString at 0x173475220>, 1],
 [<shapely.geometry.linestring.LineString at 0x1734753d0>, 1],
 [<shapely.geometry.multilinestring.MultiLineString at 0x1734754c0>, 2],
 [<shapely.geometry.linestring.LineString at 0x1734754f0>, 5],
 [<shapely.geometry.linestring.LineString at 0x173475580>, 5],
 [<shapely.geometry.linestring.LineString at 0x1734755b0>, 5]]
~~~
{: .output}

The other argument, `out_shape` specifies the shape of the output grid in pixel units, while `transform` represents the projection from pixel space to the projected coordinate space. We also need to specify the fill value for pixels that do not intersect a line in our shapefile, which we do with `fill = 7`. It's important to pick a fill value that is not the same as any values in `shapes`/`roads['RULEID]`, or else we won't distinguish between this zone and the background. We also need to pick a fill value that is not `0`, since `xrspatial.zonal_stats` does not calculate statistics for pixels with `0` as a zone value.

~~~
zones_arr_out_shape = canopy_HARV.shape[1:]
canopy_HARV_transform = canopy_HARV.rio.transform()
road_zones_arr = rasterio.features.rasterize(shapes, fill = 7, out_shape = zones_arr_out_shape, transform=canopy_HARV_transform)
~~~
{: .language-python}

After we have this road_zones_arr, we convert it to an `xarray.DataArray` and select the one and only band in that DatArray so that the DataArray only has an x and a y dimension, since this is what the `zonal_stats` function expects as an argument.

~~~
road_canopy_zones_xarr = xr.DataArray(road_canopy_zones_arr)
canopy_HARV_b1 = canopy_HARV.sel(band=1)
~~~
{: .language-python}

Then we call the `zonal stats` function with the zones as the first argument and the raster with our values of interest as the second argument.

~~~
zonal_stats(road_canopy_zones_xarr, canopy_HARV_b1)
~~~
{: .language-python}

This produces a neat table describing statistics for each of our zones.

|    |    mean |   max |        min |     std |     var |          count |
|---:|--------:|------:|-----------:|--------:|--------:|---------------:|
|  1 | 18.0276 | 26.75 |  0         | 6.33709 | 40.1588 |  734           |
|  2 | 18.8825 | 23.98 |  0         | 5.83523 | 34.0499 |   59           |
|  5 | 14.2802 | 26.75 | -0.399994  | 7.45486 | 55.5749 | 2419           |
|  6 | 15.7706 | 26.81 | -0.0799866 | 6.59865 | 43.5422 |  719           |
|  7 | 14.9545 | 38.17 | -0.809998  | 7.10642 | 50.5012 |    2.31557e+06 |

It'd be nice to associate the zone names with each row. To do this, we can use the `roads["TYPE"]` column, which contains the unique zone names for each line. We'll make a new dataframe with two column, one for the zone ID (numeric) and one for the zone type (a string), and then join this with our stats dataframe.

~~~
zoneid_zonetype = roads[['RULEID', 'TYPE']].drop_duplicates()
zoneid_zonetype = zoneid_zonetype.append({"RULEID":7, "TYPE":"non-road"}, ignore_index=True)
zoneid_zonetype = zoneid_zonetype.set_index("RULEID")
zstats_df = zoneid_zonetype.join(zstats_df)
~~~
{: .language-python}

This results in a labeled table that is easier to interpret.

|   RULEID | TYPE       |    mean |   max |        min |     std |     var |          count |
|---------:|:-----------|--------:|------:|-----------:|--------:|--------:|---------------:|
|        5 | woods road | 14.2802 | 26.75 | -0.399994  | 7.45486 | 55.5749 | 2419           |
|        6 | footpath   | 15.7706 | 26.81 | -0.0799866 | 6.59865 | 43.5422 |  719           |
|        1 | stone wall | 18.0276 | 26.75 |  0         | 6.33709 | 40.1588 |  734           |
|        2 | boardwalk  | 18.8825 | 23.98 |  0         | 5.83523 | 34.0499 |   59           |
|        7 | non-road   | 14.9545 | 38.17 | -0.809998  | 7.10642 | 50.5012 |    2.31557e+06 |

> ## Challenge: Explore Calculate the Canopy Height Statistics for a Meteorological Tower Site
> 
> Let's calculate zonal statistics for an area where we are monitoring meteorological variables above the canopy of HARV.
> 
> Import the `NEON-DS-Site-Layout-Files/HARV/AOPClip_UTMz18N.shp` shapefile with `geopandas`.
> Then, calculate zonal statistics using our CHM. Inspect the output of your table.
> 
> 
> > ## Answers
> > 1) Read in the data.
> >
> > ```python
tower_aoi_HARV = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HarClip_UTMZ18.shp")
> > ```
> >
> > 2) Create a zone array for this polygon.
> >
> > ```python
shapes = tower_aoi_HARV[['geometry', 'id']].values.tolist()
zones_arr_out_shape = canopy_HARV.shape[1:]
canopy_HARV_transform = canopy_HARV.rio.transform()
tower_zone_arr = rasterio.features.rasterize(shapes, fill = 7, out_shape = zones_arr_out_shape, transform=canopy_HARV_transform)
> > ```
> > 
> > 3) Create and display the zonal statistics table.
> >
> > ```python
tower_zone_xarr = xr.DataArray(tower_zone_arr)
canopy_HARV_b1 = canopy_HARV.sel(band=1)
zstats_df = zonal_stats(tower_zone_xarr, canopy_HARV_b1)
zstats_df
> > ```
> > 
> > This results in the following table.
> > |    |    mean |   max |       min |     std |     var |           count |
> > |---:|--------:|------:|----------:|--------:|--------:|----------------:|
> > |  1 | 19.3435 | 38.17 | -0.170013 | 6.2115  | 38.5827 | 18450           |
> > |  7 | 14.92   | 35.59 | -0.809998 | 7.10244 | 50.4447 |     2.30105e+06 |
> {: .solution}
{: .challenge}

{% include links.md %}

