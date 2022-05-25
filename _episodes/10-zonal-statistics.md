---
title: "Calculating Zonal Statistics on Rasters"
teaching: 40
exercises: 20
questions:
- "How to compute raster statistics on different zones delineated by a vector data?"
objectives:
- "Extract zones from the vector dataset"
- "Convert vector zones to raster using rasterize"
- "Calculate raster statistics over zones"
keypoints:
- "Zones can be extracted by attribute columns of a vector dataset"
- "Zones can be vectorized using `rasterio.features.rasterize`"
- "Calculate zonal statistics with `xrspatial.zonal_stats` over the rasterized zones."

---

# Introduction

Statistics on predefined zones of the raster data are commonly used for analysis and to better understand the data. These zones are often provided within a single vector dataset, identified by certain vector attributes. For example, in the previous episodes, we used the crop field polygon dataset. The fields with the same crop type can be identified as a "zone", resulting in multiple zones in one vector dataset. One may be interested in performing statistical analysis over these crop zones.

In this episode, we will explore how to calculate zonal statistics based on the types of crops in `cropped_field.shp` . To do this, we will first identify zones from the vector data, then rasterize these vector zones. Finally the zonal statistics for `ndvi` will be calculated over the rasterized zones.  


# Making vector and raster data compatible
Let's first read the crop fields data from our saved `cropped_field.shp` file and view the CRS information.

~~~
field = gpd.read_file('cropped_field.shp')
field.crs
~~~
{: .language-python}

~~~
<Derived Projected CRS: EPSG:28992>
Name: Amersfoort / RD New
Axis Info [cartesian]:
- X[east]: Easting (metre)
- Y[north]: Northing (metre)
Area of Use:
- name: Netherlands - onshore, including Waddenzee, Dutch Wadden Islands and 12-mile offshore coastal zone.
- bounds: (3.2, 50.75, 7.22, 53.7)
Coordinate Operation:
- name: RD New
- method: Oblique Stereographic
Datum: Amersfoort
- Ellipsoid: Bessel 1841
- Prime Meridian: Greenwich
~~~
{: .output}

In order to use the vector data as a classifier for our raster, we need to convert the vector data to the appropriate CRS and crop to our raster domain. The CRS conversion can be done from the vector CRS (EPSG:28992) to our raster `ndvi` CRS (EPSG:32631) with:
~~~
field_to_raster_crs = field.to_crs(ndvi.rio.crs)
~~~
{: .language-python}

We can further crop the vector data with the same bounds as `ndvi` and view the data:
~~~
xmin, xmax = (629000, 639000)
ymin, ymax = (5804000, 5814000)
field_cropped = field_to_raster_crs.cx[xmin:xmax, ymin:ymax]
field_cropped
~~~
{: .language-python}

~~~
category	gewas	gewascode	jaar	status	geometry
0	Grasland	Grasland, blijvend	265	2020	Definitief	POLYGON ((634234.009 5807461.338, 634232.049 5...
1	Grasland	Grasland, blijvend	265	2020	Definitief	POLYGON ((634514.198 5807699.177, 634504.207 5...
2	Grasland	Grasland, blijvend	265	2020	Definitief	POLYGON ((633115.463 5808493.238, 633109.078 5...
3	Grasland	Grasland, blijvend	265	2020	Definitief	POLYGON ((634803.514 5808081.449, 634809.802 5...
4	Grasland	Grasland, blijvend	265	2020	Definitief	POLYGON ((634184.289 5807370.958, 634200.036 5...
...	...	...	...	...	...	...
4864	Grasland	Grasland, natuurlijk. Hoofdfunctie landbouw.	331	2020	Definitief	POLYGON ((632846.409 5811358.808, 632854.381 5...
4865	Natuurterrein	Natuurterreinen (incl. heide)	335	2020	Definitief	POLYGON ((638144.387 5808851.932, 638089.278 5...
4866	Natuurterrein	Natuurterreinen (incl. heide)	335	2020	Definitief	POLYGON ((638761.879 5808265.992, 638758.324 5...
4867	Grasland	Grasland, blijvend	265	2020	Definitief	POLYGON ((631384.726 5809352.385, 631383.343 5...
4868	Grasland	Grasland, blijvend	265	2020	Definitief	POLYGON ((635240.367 5806904.896, 635245.819 5...
3061 rows × 6 columns
~~~
{: .output}

# Rasterizing our vector data

Before calculating zonal statistics, we first need to rasterize our `field_cropped` vector geodataframe with the `rasterio.features.rasterize` function. With this function, we aim to produce a grid with numerical values representing the types of crop as defined by the column `gewascode` from `field_cropped` - `gewascode` stands for the crop codes as defined by the Netherlands Enterprise Agency (RVO) for different types of crops or `gewas` (Grassland, permanent; Grassland, temporary; corn fields; etc.). This grid of values thus defines the zones for the `xrspatial.zonal_stats` function, where each pixel in the zone grid overlaps with a corresponding pixel in our NDVI raster. 

We can generate the `geometry, gewascode` pairs for each vector data-point to be used as the first argument to `rasterio.features.rasterize` as:

~~~
geom = field_cropped[['geometry', 'gewascode']].values.tolist()
geom
~~~
{: .language-python}

~~~
[[<shapely.geometry.polygon.Polygon at 0x7ff88666f670>, 265],
 [<shapely.geometry.polygon.Polygon at 0x7ff86bf39280>, 265],
 [<shapely.geometry.polygon.Polygon at 0x7ff86ba1db80>, 265],
 [<shapely.geometry.polygon.Polygon at 0x7ff86ba1d730>, 265],
 [<shapely.geometry.polygon.Polygon at 0x7ff86ba1d400>, 265],
 [<shapely.geometry.polygon.Polygon at 0x7ff86ba1d130>, 265],
...
 [<shapely.geometry.polygon.Polygon at 0x7ff88685c970>, 265],
 [<shapely.geometry.polygon.Polygon at 0x7ff88685c9a0>, 265],
 [<shapely.geometry.polygon.Polygon at 0x7ff88685c9d0>, 265],
 [<shapely.geometry.polygon.Polygon at 0x7ff88685ca00>, 331],
 ...]
~~~
{: .output}

This generates a list of the shapely geometries from the `geometry` column, and the unique field ID from the `gewascode` column in the `fields_cropped` geodataframe.

We can now rasterize our vector data using `rasterio.features.rasterize`:

~~~
from rasterio import features 
field_cropped_raster = rasterio.features.rasterize(geom, out_shape=ndvi_sq.shape, fill=0, transform=ndvi.rio.transform())
~~~
{: .language-python}

The argument `out_shape` specifies the shape of the output grid in pixel units, while `transform` represents the projection from pixel space to the projected coordinate space. We also need to specify the fill value for pixels that are not contained within a polygon in our shapefile, which we do with `fill = 0`. It's important to pick a fill value that is not the same as any value already defined in `gewascode` or else we won't distinguish between this zone and the background.

We convert the output of the `rasterio.features.rasterize` function, which generates a numpy array `np.ndarray`, to `xarray.DataArray` which will be used further:
~~~
import xarray as xr
field_cropped_raster_xarr = xr.DataArray(field_cropped_raster)
~~~
{: .language-python}

# Calculate zonal statistics 

In order to calculate the statistics for each crop zone, we call the function, `xrspatial.zonal_stats`. The `xrspatial.zonal_stats` function takes as input `zones`, a 2D `xarray.DataArray`, that defines different zones, and `values`, a 2D `xarray.DataArray` providing input values for calculating statistics. We use the `squeeze()` function in order to reduce our raster data `ndvi` dimension to 2D by removing the singular `band` dimension:

~~~
ndvi_sq = ndvi.squeeze()
~~~
{: .language-python}

Then we call the `zonal_stats` function with `cropfield_raster_xarr` as our classifier and the 2D raster with our values of interest `ndvi_sq` to obtain the NDVI statistics for each crop type:

~~~
from xrspatial import zonal_stats
zonal_stats(cropfield_raster_xarr, ndvi_sq)
~~~
{: .language-python}

~~~
	zone	mean	max	min	sum	std	var	count
0	0	0.266531	0.999579	-0.998648	38887.648438	0.409970	0.168075	145903.0
1	259	0.520282	0.885242	0.289196	449.003052	0.111205	0.012366	863.0
2	265	0.775609	0.925955	0.060755	66478.976562	0.091089	0.008297	85712.0
3	266	0.794128	0.918048	0.544686	1037.925781	0.074009	0.005477	1307.0
4	331	0.703056	0.905304	0.142226	10725.819336	0.102255	0.010456	15256.0
5	332	0.681699	0.849158	0.178113	321.080261	0.123633	0.015285	471.0
6	335	0.648063	0.865804	0.239661	313.662598	0.146582	0.021486	484.0
7	863	0.388575	0.510572	0.185987	1.165724	0.144245	0.020807	3.0
~~~
{: .output}

The `zonal_stats` function calculates the minimum, maximum, and sum for each zone along with statistical measures such as the mean, variance and standard deviation for each rasterized vector zone. In our raster data-set `zone = 0`, corresponding to non-crop areas, has the highest count followed by `zone = 265` which corresponds to 'Grasland, blijvend' or 'Grassland, permanent'. The highest mean NDVI is observed for `zone = 266` for 'Grasslands, temporary' with the lowest mean, aside from non-crop area, going to `zone = 863` representing 'Forest without replanting obligation'. Thus, the `zonal_stats` function can be used to analyse and understand different sections of our raster data. The definition of the zones can be derived from vector data or from classified raster data as presented in the challenge below: 

> ## Challenge: Calculate zonal statistics for zones defined by `ndvi_classified`
> 
> Let's calculate NDVI zonal statistics for the different zones as classified by `ndvi_classified` in the previous episode .
> 
> Convert both raster data-sets into 2D `xarray.DataArray`. 
> Then, calculate zonal statistics for each `class_bins`. Inspect the output of the `zonal_stats` function.
> 
> 
> > ## Answers
> > 1) Convert raster data into suitable inputs for `rasterio.features.rasterize`:
> >
> > ```python
ndvi_sq = ndvi.squeeze()
ndvi_classified_sq = ndvi_classified.squeeze()
> > ```
> >
> > 2) Create and display the zonal statistics table.
> >
> > ```python
zonal_stats(ndvi_classified_sq,ndvi_sq)
> > ```
> {: .solution}
{: .challenge}

{% include links.md %}

