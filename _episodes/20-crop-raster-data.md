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
- "Use `grow` in `GeoDataFrame` to make a buffer polygon of a (multi)point or a polyline. This polygon can be used to crop data."
---

It is quite common that the raster data you have in hand is too large to process, or not all the pixels are relevant to your area of interest (AoI). In both situations, you should consider cropping your raster data before performing data analysis. 

In this episode, we will introduce how to crop raster data into the desired area. We will use one Sentinel-2 image over Amsterdam as the example raster data, and introduce how to crop your data to different types of AoIs.

> ## Introduce the Data
>
> Raster data: A Sentinel-2 raster image of Amsterdams: `S2_amsterdam.tif`.
> 
> Vector data: we will use three different types of vector data as AoIs:
> - Crop field polygons in north Amsterdam. ([source](https://www.pdok.nl/introductie/-/article/basisregistratie-gewaspercelen-brp-)): `data/crop_fields`.
> - Dike polylines in north Amsterdam. ([source](https://www.pdok.nl/downloads/-/article/basisregistratie-ondergrond-bro-#fa90454e447b478fb2db187bb6fc8a10)): `data/dikes`.
> -Groud water monitoring wells in north Amsterdam. ([source](https://www.pdok.nl/downloads/-/article/basisregistratie-ondergrond-bro-#3f9edb6734c11af4886cdb37b69711bc)): `data/groundwater_monitoring_well`.
{: .callout}

## Crop raster data with a bounding box

First, we can have a glimpse of the raster data by loading it with `rioxarray`:

~~~
import rioxarray

# Load image and visualize
raster = rioxarray.open_rasterio('data/S2_amsterdam.tif')
raster.plot.imshow(figsize=(8,8))
~~~
{: .language-python}

<img src="../fig/20-crop-raster-original-raster-00.png" title="Overview of the raster"  width="512" style="display: block; margin: auto;" />

The raster data is quite big. It even takes tens of seconds to visualize. But do we  need the entire raster? Suppose we are interested in the crop fields, we can simply compare its coverage with the raster coverage:

~~~
import geopandas as gpd
from shapely.geometry import box
from matplotlib import pyplot as plt

# Load the polygons of the crop fields
cf_boundary_crop = gpd.read_file("data/crop_fields/cf_boundary_crop.shp")
cf_boundary_crop = cf_boundary_crop.to_crs(raster.rio.crs) # convert to the same CRS

# Plot the bounding box over the raster
bounds = box(*cf_boundary_crop.total_bounds)
bb_cropfields = gpd.GeoDataFrame(index=[0], crs=raster.rio.crs, geometry=[bounds])
fig, ax = plt.subplots()
fig.set_size_inches((8,8))
raster.plot.imshow(ax=ax)
bb_cropfields.plot(ax=ax, alpha=0.6)
~~~
{: .language-python}

<img src="../fig/20-crop-raster-bounding-box-01.png" title="Bounding boxes of AoI over the raster"  width="512" style="display: block; margin: auto;" />

Seeing from the bounding boxes, the crop fields (red) only takes a small part of the raster (blue). Therefore before actual processing, we can first crop the raster to the actual area of interest. The `clip_box` function allows one to crop a raster by the min/max of the x and y coordinates. 

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

Now we successfully cropped the raster to a much smaller piece. We can visualize it now.

~~~
raster_clip.plot.imshow(figsize=(8,8))
~~~

{: .language-python}
<img src="../fig/20-crop-raster-crop-by-bb-02.png" title="Crop raster by a bounding box"  width="512" style="display: block; margin: auto;" />


## Crop raster data with a polygon

It is also a common case that the AoI is given by a polygon, which one can also use to crop the raster. For the example, we make a simple polygon within the raster clip we just made, and select the raster pixels within the polygon. This can be done with the `clip` function:

~~~

from matplotlib import pyplot as plt
from shapely.geometry import Polygon
xlist= [630000, 629000, 638000, 639000, 634000, 630000]
ylist = [5.804e6, 5.814e6, 5.816e6, 5.806e6, 5.803e6, 5.804e6]
polygon_geom = Polygon(zip(xlist, ylist))
polygon = gpd.GeoDataFrame(index=[0], crs=raster_clip.rio.crs, geometry=[polygon_geom])

# Plot the polygon over raster
fig, ax = plt.subplots()
fig.set_size_inches((8,8))
raster_clip.plot.imshow(ax=ax)
polygon.plot(ax=ax, edgecolor='blue', alpha=0.6)

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
> Can you select out all the crop fields from the raster data, using the `.shp` file in `data/crop_fields`? And also visualize your results.
>
> > ## Solution
> >
> > ~~~
> > # Load the crop fields polygons 
> > cf_boundary_crop = gpd.read_file("data/crop_fields/cf_boundary_crop.shp")
> > # Crop
> > raster_clip_fields = raster_clip.rio.clip(cf_boundary_crop['geometry'], cf_boundary_crop.crs)
> > # Visualize
> > raster_clip_fields.plot.imshow(figsize=(8,8))
> > ~~~
> > {: .language-python}
> > <img src="../fig/20-crop-raster-crop-fields-solution-06.png" title="Raster cropped by crop fields" width="512" style="display: block; margin: auto;" />
> {: .solution}
{: .challenge}


## Crop raster data with a geometry buffer

It is not always the case that the AoI comes in the format of a polygon. Sometimes one would like to perform analysis around a (set of) point(s), or polyline(s). Using our AoI as an example, apart from the crop fields, one may want to also analyze raster data around the groundwater monitoring wells in the area. The location of the wells comes as point vector data in `data/groundwater_monitoring_well`.

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

To select data around the geometries, one needs to first define how large the is area around the geometry to analyse. This area is called a "buffer" and it is defined in the units of the projection. A buffer is also a polygon, which can be used to crop the raster data. `geopandas` has a `buffer` function to make buffer polygons.

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
> Can you select out all the raster data within 100m around the dikes in the AoI? The dikes are stored as polylines in `.shp` file in `data/dikes`? Please visualize your results.
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