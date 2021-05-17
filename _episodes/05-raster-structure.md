---
title: "Intro to Raster Data in Python"
teaching: 40
exercises: 20
questions:
-  "What is a raster dataset?"
-  "How do I work with and plot raster data in Python?"
-  "How can I handle missing or bad data values for a raster?"

objectives:
-  "Describe the fundamental attributes of a raster dataset."
-  "Explore raster attributes and metadata using Python."
-  "Read rasters into Python using the `rioxarray` package."
keypoints:
- "The GeoTIFF file format includes metadata about the raster data."
- "`rioxarray` stores CRS information as a CRS object that can be converted to an EPSG code or PROJ4 string."
- "The GeoTIFF file may or may not store the correct no data value(s)."
- "We can find the correct value(s) in the raster's external metadata or by plotting the raster."
- "`rioxarray` and `xarray` are for working with multidimensional arrays like pandas is for working with tabular data with many columns"
---

> ## Things You'll Need To Complete This Episode
>
> See the [lesson homepage]({{ site.baseurl }}) for detailed information about the software,
> data, and other prerequisites you will need to work through the examples in this episode.
{: .prereq}

In this episode, we will introduce the fundamental principles, packages and
metadata/raster attributes that are needed to work with raster data in Python. We will
discuss some of the core metadata elements that we need to understand to work with
rasters, including Coordinate Reference Systems, no data values, and resolution. We will also explore missing and bad
data values as stored in a raster and how Python handles these elements.

We will use 1 package in this episode to work with raster data -
[`rioxarray`](https://corteva.github.io/rioxarray/stable/),
which is based on the popular [`rasterio`](https://rasterio.readthedocs.io/en/latest/) package
for working with rasters and [`xarray`](http://xarray.pydata.org/en/stable/) for working with multi-dimensional arrays.
Make sure that you have `rioxarray` installed and imported.

~~~
import rioxarray
~~~
{: .language-python}

> ## Introduce the Data
>
> A brief introduction to the datasets can be found on the 
> [Geospatial workshop setup page](https://rbavery.github.io/geospatial-python/setup.html).
> 
> For more detailed information about the datasets, check
out the [Geospatial workshop data
page](https://rbavery.github.io/geospatial-python/).
{: .callout}

## Open a Raster and View Raster File Attributes

We will be working with a series of GeoTIFF files in this lesson. The
GeoTIFF format contains a set of embedded tags with metadata about the raster
data. We can use the function `rioxarray.open_rasterio()` to read the geotiff file and 
then inspect this metadata. By calling the variable name in the jupyter notebook
we can get a quick look at the shape and attributes of the data.

~~~
surface_HARV = rioxarray.open_rasterio("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
surface_HARV
~~~
{: .language-python}

~~~
<xarray.DataArray (band: 1, y: 1367, x: 1697)>
[2319799 values with dtype=float64]
Coordinates:
  * band         (band) int64 1
  * y            (y) float64 4.714e+06 4.714e+06 ... 4.712e+06 4.712e+06
  * x            (x) float64 7.315e+05 7.315e+05 ... 7.331e+05 7.331e+05
    spatial_ref  int64 0
Attributes:
    transform:     (1.0, 0.0, 731453.0, 0.0, -1.0, 4713838.0)
    _FillValue:    -9999.0
    scales:        (1.0,)
    offsets:       (0.0,)
    grid_mapping:  spatial_ref
~~~
{: .output}

The first call to `rioxarray.open_rasterio()` opens the file and returns a `xarray.DataArray` that we store in a variable, `surface_HARV`. Reading in the data with `xarray` instead of `rioxarray` also returns a `xarray.DataArray`, but the output will not contain the geospatial metadata (such as projection information). You can use a `xarray.DataArray` in calculations just like a numpy array. Calling the variable name of the `DataArray` also prints out all of its metadata information.

The output tells us that we are looking at an `xarray.DataArray`, with `1` band, `1367` rows, and `1697` columns. We can also see the number of pixel values in the `DataArray`, and the type of those pixel values, which is floating point, or (`float64`). The `DataArray` also stores different values for the coordinates of the `DataArray`. When using `rioxarray`, the term coordinates refers to spatial coordinates like `x` and `y` but also the `band` coordinate. Each of these sequences of values has its own data type, like `float64` for the spatial coordinates
 and `int64` for the `band` coordinate. The `transform` represents the conversion between array coordinates (non-spatial) and spatial coordinates.

This `DataArray` object also has a couple attributes that are accessed like `.rio.crs`, `.rio.nodata`, and `.rio.bounds()`, which contain the metadata for the file we opened. Note that many of the metadata are accessed as attributes without `()`, but `bounds()` is a function and needs parentheses. 

~~~
print(surface_HARV.rio.crs)
print(surface_HARV.rio.nodata)
print(surface_HARV.rio.bounds())
print(surface_HARV.rio.width)
print(surface_HARV.rio.height)
~~~
{: .language-python}

~~~
EPSG:32618
-9999.0
(731453.0, 4712471.0, 733150.0, 4713838.0)
1697
1367
~~~
{: .output}

The Coordinate Reference System, or `surface_HARV.rio.crs`, is reported as the string `EPSG:32618`. The `nodata` value is encoded as -9999.0 and the bounding box corners of our raster are represented by the output of `.bounds()` as a `tuple` (like a list but you can't edit it). The height and width match what we saw when we printed the `DataArray`, but by using `.rio.width` and `.rio.height` we can access these values if we need them in calculations.

 We will be exploring this data throughout this episode. By the end of this episode, you will be able to understand and explain the metadata output.

> ## Data Tip - Object names
> To improve code
> readability, file and object names should be used that make it clear what is in
> the file. The data for this episode were collected from Harvard Forest so
> we'll use a naming convention of `datatype_HARV`.
{: .callout}

After viewing the attributes of our raster, we can examine the raw values of the array with `.values`:

~~~
surface_HARV.values
~~~
{: .language-python}

~~~
array([[[408.76998901, 408.22998047, 406.52999878, ..., 345.05999756,
         345.13998413, 344.97000122],
        [407.04998779, 406.61999512, 404.97998047, ..., 345.20999146,
         344.97000122, 345.13998413],
        [407.05999756, 406.02999878, 403.54998779, ..., 345.07000732,
         345.08999634, 345.17999268],
        ...,
        [367.91000366, 370.19000244, 370.58999634, ..., 311.38998413,
         310.44998169, 309.38998413],
        [370.75997925, 371.50997925, 363.41000366, ..., 314.70999146,
         309.25      , 312.01998901],
        [369.95999146, 372.6000061 , 372.42999268, ..., 316.38998413,
         309.86999512, 311.20999146]]])
~~~
{: .output}

This can give us a quick view of the values of our array, but only at the corners. Since our raster is loaded in python as a `DataArray` type, we can plot this in one line similar to a pandas `DataFrame` with `DataArray.plot()`.

```python
surface_HARV.plot()
```

<img src="../fig/05-surface-plot-01.png" title="Raster plot with rioxarray using the viridis color scale" alt="Raster plot with earthpy.plot using the viridis color scale" width="612" style="display: block; margin: auto;" />

Nice plot! Notice that `rioxarray` helpfully allows us to plot this raster with spatial coordinates on the x and y axis (this is not the default in many cases with other functions or libraries).

This map shows the elevation of our study site in Harvard Forest. From the
legend, we can see that the maximum elevation is ~400, but we can't tell whether
this is 400 feet or 400 meters because the legend doesn't show us the units. We
can look at the metadata of our object to see what the units are. Much of the
metadata that we're interested in is part of the CRS, and it can be accessed with `.rio.crs`. We introduced the concept of a CRS in [an earlier
episode](https://carpentries-incubator.github.io/geospatial-python/03-crs/index.html).

Now we will see how features of the CRS appear in our data file and what
meanings they have.

### View Raster Coordinate Reference System (CRS) in Python
We can view the CRS string associated with our Python object using the`crs`
attribute.


~~~
print(surface_HARV.rio.crs)
~~~
{: .language-python}



~~~
EPSG:32618
~~~
{: .output}

To just print the EPSG code number as an `int`, we use the `.to_epsg()` method:

~~~
print(surface_HARV.rio.crs.to_epsg())
~~~
{: .language-python}



~~~
32618
~~~
{: .output}

EPSG codes are great for succinctly representing a particular coordinate reference system. But what if we want to see information about the CRS? For that, we can use `pyproj`, a library for representing and working with coordinate reference systems.

~~~
from pyproj import CRS
epsg = surface_HARV.rio.crs.to_epsg()
crs = CRS(epsg)
crs
~~~
{: .language-python}

~~~
<Projected CRS: EPSG:32618>
Name: WGS 84 / UTM zone 18N
Axis Info [cartesian]:
- E[east]: Easting (metre)
- N[north]: Northing (metre)
Area of Use:
- name: World - N hemisphere - 78°W to 72°W - by country
- bounds: (-78.0, 0.0, -72.0, 84.0)
Coordinate Operation:
- name: UTM zone 18N
- method: Transverse Mercator
Datum: World Geodetic System 1984
- Ellipsoid: WGS 84
- Prime Meridian: Greenwich
~~~
{: .output}

The `CRS` class from the `pyproj` library allows us to create a `CRS` object with methods and attributes for accessing specific information about a CRS, or the detailed summary shown above.

A particularly useful attribute is `area_of_use`, which shows the geographic bounds that the CRS is intended to be used.

~~~
crs.area_of_use
~~~
{: .language-python}

~~~
AreaOfUse(name=World - N hemisphere - 78°W to 72°W - by country, west=-78.0, south=0.0, east=-72.0, north=84.0)
~~~
{: .output}


> ## Challenge
> What units are our data in? See if you can find a method to examine this information using `help(crs)` or `dir(crs)`
>
> > ## Answers
> > `crs.axis_info` tells us that our CRS for our raster has two axis and both are in meters.
> > We could also get this information from the attribute `surface_HARV.rio.crs.linear_units`.
> {: .solution}
{: .challenge}

## Understanding pyproj CRS Summary
Let's break down the pieces of the `pyproj` CRS summary. The string contains all of the individual CRS
elements that Python or another GIS might need, separated into distinct sections.
and datum (`datum=`).

### UTM pyproj summary
Our UTM projection is summarized as follows:

~~~
<Projected CRS: EPSG:32618>
Name: WGS 84 / UTM zone 18N
Axis Info [cartesian]:
- E[east]: Easting (metre)
- N[north]: Northing (metre)
Area of Use:
- name: World - N hemisphere - 78°W to 72°W - by country
- bounds: (-78.0, 0.0, -72.0, 84.0)
Coordinate Operation:
- name: UTM zone 18N
- method: Transverse Mercator
Datum: World Geodetic System 1984
- Ellipsoid: WGS 84
- Prime Meridian: Greenwich
~~~
{: .output}

* **Name** of the projection is UTM zone 18N (UTM has 60 zones, each 6-degrees of longitude in width). The underlying datum is WGS84.
* **Axis Info**: the CRS shows a Cartesian system with two axis, an easting and northing, in meter units.
* **Area of Use**: the projection is used for a particular range of longitudes `-78°W to 72°W` in the northern hemisphere (`0.0°N to 84.0°N`)
* **Coordinate Operation**: the operation to project the coordinates (if it is projected) on to a cartesian (x, y) plane. Transverse mercator is accurate for areas with longitudinal widths of a few degrees, hence the distinct UTM zones.
* **Datum** Details about the datum, or the reference point for coordinates. `WGS 84` and `NAD 1983` are common datums. `NAD 1983` is [set to be replaced in 2022](https://en.wikipedia.org/wiki/Datum_of_2022).

Note that the zone is unique to the UTM projection. Not all CRSs will have a
zone. Image source: Chrismurf at English Wikipedia, via [Wikimedia Commons](https://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system#/media/File:Utm-zones-USA.svg) (CC-BY).

![The UTM zones across the continental United States. From: https://upload.wikimedia.org/wikipedia/commons/8/8d/Utm-zones-USA.svg](../images/Utm-zones-USA.svg)

## Calculate Raster Min and Max Values

It is useful to know the minimum or maximum values of a raster dataset. In this
case, given we are working with elevation data, these values represent the
min/max elevation range at our site.

We can compute these and other descriptive statistics with `min`, `max`, `mean`, and `std`.

~~~
print(surface_HARV.min())
print(surface_HARV.max())
print(surface_HARV.mean())
print(surface_HARV.std())
~~~
{: .language-python}

~~~
<xarray.DataArray ()>
array(305.07000732)
Coordinates:
    spatial_ref  int64 0
<xarray.DataArray ()>
array(416.06997681)
Coordinates:
    spatial_ref  int64 0
<xarray.DataArray ()>
array(359.85311803)
Coordinates:
    spatial_ref  int64 0
<xarray.DataArray ()>
array(17.83168952)
Coordinates:
    spatial_ref  int64 0
~~~
{: .output}


The information above includes a report of the min, max, mean, and standard deviation values, along with the data type.

You could also get each of these values one by one using `numpy`. What if we wanted to calculate 25% and 75% quartiles?

~~~
import numpy
print(numpy.percentile(surface_HARV, 25))
print(numpy.percentile(surface_HARV, 75))
~~~
{: .language-python}

~~~
345.5899963378906
374.2799987792969
~~~
{: .output}


> ## Data Tip - Set min and max values
> You may notice that `numpy.percentile` didn't require an `axis=None` argument. This is because `axis=None` is the default for most numpy 
> functions. It's always good to check out the docs on a function to see what the default arguments are, particularly when working with 
> multi-dimensional image data. To do so, we can use`help(numpy.percentile)` or `?numpy.percentile` if you are using jupyter notebook or 
> jupyter lab.
> 
{: .callout}

We can see that the elevation at our site ranges from 305.0700073m to
416.0699768m.

## Raster Bands
The Digital Surface Model that we've been working with is a
single band raster. This means that there is only one dataset stored in the
raster: surface elevation in meters for one time period. However, a raster dataset can contain one or more bands.

![Multi-band raster image](../images/dc-spatial-raster/single_multi_raster.png)

We can view the number of bands in a raster by looking at the `.shape` attribute of the `DataArray`. The band number comes first when GeoTiffs are read with the `.open_rasterio()` function.

~~~
rgb_HARV = rioxarray.open_rasterio("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif")
rgb_HARV.shape
~~~
{: .language-python}
~~~
(3, 2317, 3073)
~~~
{: .output}

It's always a good idea to examine the shape of the raster array you are working with and make sure it's what you expect. Many functions, especially ones that plot images, expect a raster array to have a particular shape.

Jump to a later episode in
this series for information on working with multi-band rasters:
[Work with Multi-Band Rasters in Python]({{ site.baseurl }}/08-raster-multi-band/).

## Dealing with Missing Data

Raster data often has a "no data value" associated with it and for raster datasets 
read in by `rioxarray` this value is referred to as `nodata`. This is a value assigned 
to pixels where data is missing or no data were collected. However, there can be 
different cases that cause missing data, and it's common for other values in a raster 
to represent different cases. The most common example is missing data at the edges of rasters.

By default the shape of a raster is always rectangular. So if we have a dataset
that has a shape that isn't rectangular, some pixels at the edge of the raster
will have no data values. This often happens when the data were collected by a
sensor which only flew over some part of a defined region.

In the RGB image below, the pixels that are black have no data values. The sensor
did not collect data in these areas. `rioxarray` assigns a specific number as missing data to the `.rio.nodata` attribute when the dataset is read, based on the file's own metadata. The GeoTiff's `nodata` attribute is assigned to the value `-1.7e+308` and in order to run calculations on this image that ignore these edge values or plot the image without the nodata values being displayed on the color scale, `rioxarray` masks them out. 

```python
# The imshow() function in the pyplot module of the matplotlib library is used to display data as an image.
rgb_HARV.plot.imshow()
```

<img src="../fig/05-no-data-plot-03.png" title="plot of demonstrate-no-data-black" alt="plot of demonstrate-no-data-black" width="612" style="display: block; margin: auto;" />

From this plot we see something interesting, while our no data values were masked along the edges, the color channel's no data values don't all line up. The colored pixels at the edges between white and black result from there being no data in one or two bands at a given pixel. `0` could conceivably represent a valid value for reflectance (the units of our pixel values) so it's good to make sure we are masking values at the edges and not valid data values within the image.

While this plot tells us where we have no data values, the color scale looks strange, because our plotting function expects image values to be normalized between a certain range (0-1 or 0-255). By using `surface_HARV.plot.imshow` with the `robust=True` argument, we can display values between the 2nd and 98th percentile, providing better color contrast.
~~~
rgb_HARV.plot.imshow(robust=True)
~~~
{: .language-python}

<img src="../fig/05-true-color-plot-04.png" title="plot of demonstrate-no-data-masked" alt="plot of demonstrate-no-data-masked" width="612" style="display: block; margin: auto;" />

The value that is conventionally used to take note of missing data (the
no data value) varies by the raster data type. For floating-point rasters,
the figure `-3.4e+38` is a common default, and for integers, `-9999` is
common. Some disciplines have specific conventions that vary from these
common values.

In some cases, other `nodata` values may be more appropriate. A `nodata` value should
be, a) outside the range of valid values, and b) a value that fits the data type
in use. For instance, if your data ranges continuously from -20 to 100, 0 is
not an acceptable `nodata` value! Or, for categories that number 1-15, 0 might be
fine for `nodata`, but using -.000003 will force you to save the GeoTIFF on disk
as a floating point raster, resulting in a bigger file. 

{% include links.md %}
