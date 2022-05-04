---
title: "Crop raster data with rioxarray and geopandas"
teaching: 40
exercises: 20
questions:
- "How can I crop my raster data to the area of interest?"
objectives:
- "Crop raster data with a bounding box."
- "Crop raster data with a polygon."
- "Crop raster data within a geometry buffer."
keypoints:
- "Use `clip_box` in `DataArray.rio` to crop raster with a bounding box."
- "Use `clip` in `DataArray.rio` to crop raster with a given polygon."
- "Use `buffer` in `geopandas` to make a buffer polygon of a (multi)point or a polyline. This polygon can be used to crop data."
- "Use `reproject_match` function in `DataArray.rio` to reproject and crop a raster data using another raster data."
---

It is quite common that the raster data you have in hand is too large to process, or not all the pixels are relevant to your area of interest (AoI). In both situations, you should consider cropping your raster data before performing data analysis.

In this episode, we will introduce how to crop raster data into the desired area. We will use one Sentinel-2 image over Amsterdam as the example raster data, and introduce how to crop your data to different types of AoIs.

> ## Introduce the Data
>
> In this episode, we will use the same dataset as the one introduced in episode
> [Introduction to Raster Data in Python]({{ page.root }}{% link
> _episodes/01-intro-raster-data.md %}). Therefore, we continue from the
> `search.json` file, that is already saved in your working directory. We also
> use the PDOK vector data that is already introduced in episode [Introduction
> to Vector Data]({{ page.root }}{% link _episodes/02-intro-vector-data.md %}).
{: .callout}

## Crop raster data with a bounding box

First, we can have a glimpse of a true color image using `pystac` and `rioxarray`:

~~~
import pystac
import rioxarray

# Open image and visualize it
items = pystac.ItemCollection.from_file("search.json")
raster = rioxarray.open_rasterio(items[1].assets["visual"].href) # Select a true color image
raster.plot.imshow(figsize=(8,8))
~~~
{: .language-python}

<img src="../fig/20-crop-raster-original-raster-00.png" title="Overview of the raster"  width="512" style="display: block; margin: auto;" />

The raster data is quite big. It even takes tens of seconds to visualize. But do we need the entire raster? Suppose we are interested in the crop fields, we can simply compare its coverage with the raster data. For this, we need to first check the coordinate systems of both raster and vector data. For raster data, we use `CRS`:

~~~
from pyproj import CRS

# Check the coordinate system
CRS(raster.rio.crs)
~~~
{: .language-python}

~~~
<Derived Projected CRS: EPSG:32631>
Name: WGS 84 / UTM zone 31N
Axis Info [cartesian]:
- [east]: Easting (metre)
- [north]: Northing (metre)
Area of Use:
- undefined
Coordinate Operation:
- name: UTM zone 31N
- method: Transverse Mercator
Datum: World Geodetic System 1984
- Ellipsoid: WGS 84
- Prime Meridian: Greenwich
~~~
{: .output}


To open and check the coordinate system of vector data, we use `geopandas`:

~~~
import geopandas as gpd

# Load the polygons of the crop fields
cf_boundary_crop = gpd.read_file("data/crop_fields/cf_boundary_crop.shp")

# Check the coordinate system
cf_boundary_crop.crs
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

As seen, the coordinate systems differ. To crop the raster using the shapefile,
we first convert the coordinate system of `cf_boundary_crop` to the coordinate
system of `raster`, and then check the coverage:

~~~
from shapely.geometry import box
from matplotlib import pyplot as plt

# Convert the coordinate system
cf_boundary_crop = cf_boundary_crop.to_crs(raster.rio.crs)

# Create a bounding box
bounds = box(*cf_boundary_crop.total_bounds)
bb_cropfields = gpd.GeoDataFrame(index=[0], crs=raster.rio.crs, geometry=[bounds])

# Plot
fig, ax = plt.subplots()
fig.set_size_inches((8,8))

# Plot image
raster.plot.imshow(ax=ax)

# Plot crop fields
cf_boundary_crop.geometry.boundary.plot(
    ax=ax,
    facecolor="white",
    edgecolor="red",
    linewidth = 0.5,

)

# Plot bounding box
bb_cropfields.geometry.boundary.plot(
    ax=ax,
    color=None,
    edgecolor="black",
    linewidth = 2,
    linestyle = '--',
)
~~~
{: .language-python}

<img src="../fig/20-crop-raster-bounding-box-01.png" title="Bounding boxes of AoI over the raster"  width="512" style="display: block; margin: auto;" />

Seeing from the bounding boxes, the crop fields (red) only takes a small part of
the raster. Therefore before actual processing, we can first crop the raster to
our area of interest. The `clip_box` function allows one to crop a raster by the
min/max of the x and y coordinates.

~~~
# Crop the raster with the bounding box
raster_clip = raster.rio.clip_box(*cf_boundary_crop.total_bounds)
print(raster_clip.shape)
~~~
{: .language-python}
~~~
(3, 1565, 1565)
~~~
{: .output}

We successfully cropped the raster to a much smaller piece. We can visualize it now:

~~~
raster_clip.plot.imshow(figsize=(8,8))
~~~

{: .language-python}
<img src="../fig/20-crop-raster-crop-by-bb-02.png" title="Crop raster by a bounding box"  width="512" style="display: block; margin: auto;" />


## Crop raster data with a polygon

It is common that the AoI is given by a polygon, which can be also used to crop the raster. For the example, we make a simple polygon within the raster clip we just made, and select the raster pixels within the polygon. This can be done with the `clip` function:

~~~
from shapely.geometry import Polygon

# Create a polygon
xlist= [630000, 629000, 638000, 639000, 634000, 630000]
ylist = [5.804e6, 5.814e6, 5.816e6, 5.806e6, 5.803e6, 5.804e6]
polygon_geom = Polygon(zip(xlist, ylist))
polygon = gpd.GeoDataFrame(index=[0], crs=raster_clip.rio.crs, geometry=[polygon_geom])

# Plot the polygon over raster
fig, ax = plt.subplots()
fig.set_size_inches((8,8))
raster_clip.plot.imshow(ax=ax)
polygon.plot(
    ax=ax,
    alpha=0.6,
    color=None,
    edgecolor="blue",
    linewidth = 2,
    linestyle = '--',
)

# Crop and visualize
raster_clip_polygon = raster_clip.rio.clip(polygon['geometry'], polygon.crs)
raster_clip_polygon.plot.imshow(figsize=(8,8))
~~~
{: .language-python}

<img src="../fig/20-crop-raster-crop-by-polygon-03.png" title="Crop raster by a polygon"  width="1024" style="display: block; margin: auto;" />


> ## Exercise: Compare two ways of bounding box cropping
> So far, we have learned two ways of cropping a raster: by a bounding box (using `clip_box`) and by a polygon (using `clip`). Technically, a bounding box is also a polygon. So what if we crop the original image directly with the polygon? For example:
> ~~~
> raster_clip_polygon2 = raster.rio.clip(polygon['geometry'], polygon.crs)
> raster_clip_polygon2.plot.imshow()
> ~~~
> {: .language-python}
> And try to compare the two methods:
> - Do you have the same results?
> - Do you have the same execution time?
> - How would you choose the two methods in your daily work?
>
> > ## Solution
> >
> > The two methods give the same results, but cropping directly with a polygon is much slower.
> >
> > Therefore, if the AoI is much smaller than the original raster, it would be more efficient to first crop the raster with a bounding box, then crop with the actual AoI polygon.
> {: .solution}
{: .challenge}

> ## Exercise: Select the raster data within crop fields
> Imagine that we want to select out all the crop fields from the raster data,
> using the `.shp` file in `data/crop_fields`.
>
> 1. Convert the coordinate system of `raster_clip` to the coordinate
system of `cf_boundary_crop`. Tip: we can use `rio.reproject()` function.
> 2. Crop the `raster_clip`.
> 3. Visualize the cropped data.
> 4. Store the raster as a GeoTIFF file (`crop_fields.tif`). Tip: we learned how to do this in the first episode.
>
> > ## Solution
> >
> > ~~~
> > # Load the crop fields polygons
> > cf_boundary_crop = gpd.read_file("data/crop_fields/cf_boundary_crop.shp")
> >
> > # Convert the coordinate system
> > raster_clip = raster_clip.rio.reproject(cf_boundary_crop.crs)
> >
> > # Crop
> > raster_clip_fields = raster_clip.rio.clip(cf_boundary_crop['geometry'], cf_boundary_crop.crs)
> >
> > # Visualize
> > raster_clip_fields.plot.imshow(figsize=(8,8))
> >
> > # Save
> > raster_clip_fields.rio.to_raster("crop_fields.tif", driver="COG")
> > ~~~
> > {: .language-python}
> > <img src="../fig/20-crop-raster-crop-fields-solution-06.png" title="Raster cropped by crop fields" width="512" style="display: block; margin: auto;" />
> {: .solution}
{: .challenge}


## Crop raster data with a geometry buffer

It is not always the case that the AoI comes in the format of a polygon. Sometimes one would like to perform analysis around a (set of) point(s), or polyline(s). For example, in our AoI, there are also some groundwater monitoring wells coming as point vector data. One may also want to perform analysis around these wells. The location of the wells is stored in `data/groundwater_monitoring_well`.

~~~
# Load wells
wells = gpd.read_file("data/groundwater_monitoring_well/groundwater_monitoring_well.shp")
wells = wells.to_crs(raster_clip.rio.crs)

# Plot the wells over raster
fig, ax = plt.subplots()
fig.set_size_inches((8,8))
raster_clip.plot.imshow(ax=ax)
wells.plot(ax=ax, color='red', markersize=2)
~~~
{: .language-python}

<img src="../fig/20-crop-raster-wells-04.png" title="Ground weter level wells" width="512" style="display: block; margin: auto;" />

To select pixels around the geometries, one needs to first define a region including the geometries. This region is called a "buffer" and it is defined in the units of the projection. The size of the buffer depends on the analysis in your research. A buffer is also a polygon, which can be used to crop the raster data.  The package `geopandas` has a `buffer` function to make buffer polygons.

~~~
# Create 200m buffer around the wells
wells_buffer = wells.buffer(200)

# Crop
raster_clip_wells = raster_clip.rio.clip(wells_buffer, wells_buffer.crs)

# Visualize buffer on raster
fig, (ax1, ax2) = plt.subplots(1, 2)
fig.set_size_inches((16,8))
raster_clip.plot.imshow(ax=ax1)
wells_buffer.plot(ax=ax1, color='red')

# Visualize cropped buffer
raster_clip_wells.plot.imshow(ax=ax2)
~~~
{: .language-python}

<img src="../fig/20-crop-raster-crop-by-well-buffers-05.png" title="Raster croped by buffer around wells" width="1024" style="display: block; margin: auto;" />

> ## Exercise: Select the raster data around the dike
> The dikes are stored as polylines in `.shp` file in `data/dikes`. Let's select out all the raster data within 100m around the dikes and visualize the results.
>
> > ## Solution
> > ~~~
> > # Load dikes polyline
> > dikes = gpd.read_file("data/dikes/dikes.shp")
> > dikes = dikes.to_crs(raster.rio.crs)
> > # Dike buffer
> > dikes_buffer = dikes.buffer(100)
> > # Crop
> > raster_clip_dikes = raster_clip.rio.clip(dikes_buffer, dikes_buffer.crs)
> > # Visualize
> > raster_clip_dikes.plot.imshow(figsize=(8,8))
> > ~~~
> > {: .language-python}
> > <img src="../fig/20-crop-raster-dike-solution-07.png" title="Raster croped by buffer around dikes" width="512" style="display: block; margin: auto;" />
> {: .solution}
{: .challenge}

## Crop raster data using another raster data

Imagine that we have two raster data, let's say the `scene` and `crop_fields` in
different coordinate systems. Our goal is to crop the `scene` image using the
`crop_fields` image.

> ## Using `crop_fields` raster image
>
> For this section, we will use the `crop_fields.tif` image that was produced in
> the exercise "**Select the raster data within crop fields**".
{: .callout}

We read in both images and check their coordinate system:
~~~
# Read crop_fields
crop_fields = rioxarray.open_rasterio("crop_fields.tif")
CRS(crop_fields.rio.crs)
~~~
{: .language-python}

~~~
<Derived Projected CRS: EPSG:28992>
Name: Amersfoort / RD New
Axis Info [cartesian]:
- [east]: Easting (metre)
- [north]: Northing (metre)
Area of Use:
- undefined
Coordinate Operation:
- name: unnamed
- method: Oblique Stereographic
Datum: Amersfoort
- Ellipsoid: Bessel 1841
- Prime Meridian: Greenwich
~~~
{: .output}

~~~
# Read scene
items = pystac.ItemCollection.from_file("search.json")
scene = rioxarray.open_rasterio(items[1].assets["visual"].href)
CRS(scene.rio.crs)
~~~
{: .language-python}

~~~
<Derived Projected CRS: EPSG:32631>
Name: WGS 84 / UTM zone 31N
Axis Info [cartesian]:
- [east]: Easting (metre)
- [north]: Northing (metre)
Area of Use:
- undefined
Coordinate Operation:
- name: UTM zone 31N
- method: Transverse Mercator
Datum: World Geodetic System 1984
- Ellipsoid: WGS 84
- Prime Meridian: Greenwich
~~~
{: .output}

We can see that these images are in different coordinate systems. Now, we can
use `rioxarray.reproject_match()` function to crop `scene` image. This might
take a few minutes, because the `scene` image is large.

~~~
# Crop and reproject
cropped_scene = scene.rio.reproject_match(crop_fields)

# Visualize
cropped_scene.plot.imshow(figsize=(8,8))
~~~
{: .language-python}

> ## Exercise
>
> This time, let's crop the `crop_fields` image using the `scene` image. Discuss
> the results.
>
> > ## Solution
> >
> > ~~~
> > # Crop
> > cropped_scene = crop_fields.rio.reproject_match(scene)
> >
> > # Visualize
> > cropped_scene.plot.imshow(figsize=(8,8))
> > ~~~
> > {: .language-python}
> > <img src="../fig/20-crop-raster-raster-solution-08.png" title="Raster croped by buffer around dikes" width="512" style="display: block; margin: auto;" />
> {: .solution}
{: .challenge}

In one line `reproject_match` does a lot of helpful things:

1. It reprojects.
2. It matches the extent using `nodata` values or by clipping the data.
3. It sets `nodata` values. This means we can run calculations on those two images.

> ## Code Tip
>
> As we saw before, there also exists a method called `reproject()`, which only reprojects one raster to another projection. If you want more control over how rasters are resampled, clipped, and/or reprojected, you can use the `reproject()` method and other `rioxarray` methods individually.
{: .callout}
