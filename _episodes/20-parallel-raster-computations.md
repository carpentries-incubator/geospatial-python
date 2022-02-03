---
title: "Parallel raster computations using Dask"
teaching: TODO
exercises: TODO
questions:
- "TODO"
objectives:
- "Profile the timing of your raster calculations."
- "Open raster data as a chunked array."
- "Recognize good practices in selecting proper chunk sizes."
- "Setup raster calculations that take advantage of parallelization."
keypoints:
- "TODO"
---

Very often raster computations involve applying the same operation to different pieces of data. Think, for instance, to
the "pixel"-wise sum of two raster datasets, where the same sum operation is applied to all the matching grid-cells of
the two rasters. This class of data-parallel tasks can benefit from chunking the input raster(s) into smaller
pieces. In fact, operations on different data blocks can be run in parallel using multiple computing units
(e.g., multi-core CPUs), thus potentially speeding up the calculation. In addition, by processing the data
chunk-by-chunk, one could bypass the need to store the full dataset in memory, leading also to a smaller memory
footprint.

In this episode, we will introduce the use of Dask in the context of raster calculations. Dask is a Python library for
parallel and distributed computing that provides a framework to work with different data structures, including chunked
arrays (Dask Arrays). Dask is well integrated with the Xarray's `DataArray`, which can use Dask arrays as underlying
data structures.

> ## More Resources on Dask
>
> Dask and Dask Arrays, with links
>
{: .callout}

It is important to notice, however, that the details of the computation determines the extent to which using Dask's
chunked arrays instead of regular Numpy arrays can lead to faster calculations (and lower memory requirements).
Depending on the nature of the calculation and the choice of parameters such as the chunk shape and size, one could even
observe worse performances. Being able to time profile your calculations is thus essential, and we will see how to do
that in a Jupyter environment in the next section.

# Time profiling calculations in Jupyter

Let's set up a raster calculation using assets from the search carried out in the previous episode. The search result,
which consisted of a collection of STAC items (an `ItemCollection`), has been saved in GeoJSON format. We can load the
collection again using the `pystac` library:

~~~
import pystac
items = pystac.ItemCollection.from_file("mysearch.json")
~~~
{: .language-python}

We select the last scene, and extract the URLs of two assets: the true-color image ("visual") and the scene
classification layer ("SCL"), the latter being a pixel-based classification mask (e.g., grid cells classified as
vegetation are labelled as "4", grid cells classified as water are labelled as "6", etc. - more details on the
classes and on the algorithm employed
[here](https://sentinels.copernicus.eu/web/sentinel/technical-guides/sentinel-2-msi/level-2a/algorithm)):

~~~
assets = items[-1].assets  # last item's assets
visual_href = assets["visual"].href  # true color image
scl_href = assets["SCL"].href  # scene classification layer
~~~
{: .language-python}

Opening the two assets with `rioxarray` would show that the true-color image is available as a raster file with 10 m
resolution, while the scene classification layer has a lower resolution (20 m). In order to match the image and the mask
pixels, one could download the finer raster file and resample it to the coarser resolution. However, we can take
advantage of a feature of the cloud-optimized GeoTIFF (COG) format, used to store these raster files. COGs, in fact,
can include multiple lower-resolution versions of the original image, called "overviews", which are typically computed
using powers of 2 as down-sampling factors (e.g. 2, 4, 8, 16). This allows to avoid downloading a high-resolution image
if only a quick preview of it is required.

We can thus open the first overview (zoom factor 2, or 2 times lower resolution) of the true-color image, together with
the full resolution image of the scene classification layer, and verify that they have the same resolution:

~~~
import rioxarray
visual = rioxarray.open_rasterio(visual_href, overview_level=0)
scl = rioxarray.open_rasterio(scl_href)
scl.rio.resolution() == visual.rio.resolution()
~~~
{: .language-python}

~~~
True
~~~
{: .output}

We can now measure the time required for the first step in our calculation with raster files, which is downloading the
rasters' content. We use the Jupyter magic `%%time`, which returns the time required to run the content of a cell:

~~~
%%time
scl = scl.load()
visual = visual.load()
~~~
{: .language-python}

~~~
CPU times: user 825 ms, sys: 1.07 s, total: 1.9 s
Wall time: 1min
~~~
{: .output}

~~~
visual.plot.imshow(figsize=(10,10))
scl.squeeze().plot.imshow(levels=range(13), figsize=(12,10))
~~~
{: .language-python}

<img src="../fig/20-Dask-arrays-s2-true-color-image.png" title="Scene true color image" alt="true color image scene" width="612" style="display: block; margin: auto;" />
<img src="../fig/20-Dask-arrays-s2-scene-classification.png" title="Scene classification" alt="scene classification" width="612" style="display: block; margin: auto;" />

After having loaded the raster files into memory, we run the following calculation: we create a mask of the grid cells
that are labeled as "cloud" in the scene classification layer (labels 8 and 9, for medium- and high-cloud probability,
respectively), we use this mask to set the corresponding grid cells in the true-color image to nodata, and save
the masked image to disk as a COG. We measure the cell execution time using `%%time`:

~~~
%%time
mask = scl.squeeze().isin([8, 9])
visual_masked = visual.where(~mask, other=visual.rio.nodata)
visual_masked.rio.to_raster("band_masked.tif", driver="COG")
~~~
{: .language-python}

~~~
CPU times: user 3.9 s, sys: 733 ms, total: 4.64 s
Wall time: 4.66 s
~~~
{: .output}

We can inspect the masked image as:

~~~
visual_masked.plot.imshow(figsize=(10, 10))
~~~
{: .language-python}

<img src="../fig/20-Dask-arrays-s2-true-color-image_masked.png" title="True color image after masking out clouds" alt="masked true color image" width="612" style="display: block; margin: auto;" />

# Dask-powered rasters

## Chunked arrays

We have mentioned that one way to include parallelism is to use chunked arrays. We select another band from the assets
(the blue band, "B02"):

~~~
blue_band_href = assets["B02"].href
blue_band = rioxarray.open_rasterio(blue_band_href, lock=False, chunks=(1, 4000, 4000))
~~~
{: .language-python}

<img src="../fig/20-Dask-arrays-s2-blue-band.png" title="Xarray representation of a Dask-backed DataArray" alt="DataArray with Dask" width="612" style="display: block; margin: auto;" />

> ## Exercise: Chunk sizes matter
> We have already seen how COGs are regular GeoTIFF files with a special internal structure. Another feature of COGs is
> that data is organized in "blocks" that can be accessed via independent HTTP requests, enabling partial file readings
> (and, thus, efficient parallel access!). You can check the blocksize employed in a COG file with the following code
> snippet:
>
> ~~~
> import rasterio
> with rasterio.open(cog_uri) as r:
>     if r.is_tiled:
>         print(f"Chunk size: {r.block_shapes}")
> ~~~
> {: .language-python}
>
> In order to optimally access COGs it is best to align the blocksize of the file with the chunks employed for the file
> read. Open the blue-band asset ("B02") of a Sentinel-2 scene as a chunked `DataArray` object using suitable chunksize
> values. Which elements do you think should be considered when choosing such values?
>
> > ## Solution
> > ~~~
> > import rasterio
> > with rasterio.open(blue_band_href) as r:
> >     if r.is_tiled:
> >         print(f"Chunk size: {r.block_shapes}")
> > ~~~
> > {: .language-python}
> >
> > ~~~
> > Chunk size: [(1024, 1024)]
> > ~~~
> > {: .output}
> >
> > Ideal values are thus multiples of 1024. An element to consider is the number of resulting chunks and their size.
> > Recommended chunk sizes are of the order of 100 MB. Also the shape might be relevant, depending on the application!
> > We might select a chunks shape `(1, 6144, 6144)`:
> >
> > ~~~
> > band = rioxarray.open_rasterio(band_url, lock=False, chunks=(1, 6144, 6144))
> > ~~~
> > {: .language-python}
> >
> > which leads to chunks of 72 MB. Also, we can let `rioxarray` and Dask figure out appropriate chunk shapes by setting
> > `chunks="auto"`:
> >
> > ~~~
> > band = rioxarray.open_rasterio(band_url, lock=False, chunks="auto")
> > ~~~
> > {: .language-python}
> >
> > which leads to `(1, 8192, 8192)` chunks (128 MB).
> {: .solution}
{: .challenge}

## Lazy computations

~~~
scl = rioxarray.open_rasterio(scl_href, lock=False, chunks=(1, 2048, 2048))
visual = rioxarray.open_rasterio(visual_href, overview_level=0, lock=False, chunks=(3, 2048, 2048))
~~~
{: .language-python}

~~~
%%time
scl = scl.persist()
visual = visual.persist()
~~~
{: .language-python}

~~~
CPU times: user 1.29 s, sys: 975 ms, total: 2.27 s
Wall time: 21.4 s
~~~
{: .output}

~~~
from threading import Lock
~~~
{: .language-python}

~~~
%%time
mask = scl.squeeze().isin([8, 9])
visual_masked = visual.where(~mask, other=0)
visual_store = visual_masked.rio.to_raster("band_masked.tif", driver="COG", lock=threading.Lock(), compute=False)
~~~
{: .language-python}

~~~
CPU times: user 1.52 s, sys: 75.8 ms, total: 1.6 s
Wall time: 1.6 s
~~~
{. output}

~~~
import dask
dask.visualize(visual_store)
~~~
{: .language-python}

<img src="../fig/20-Dask-arrays-graph.png" title="Dask graph" alt="dask graph" width="612" style="display: block; margin: auto;" />

~~~
%%time
visual_store.compute()
~~~
{: .language-python}

~~~
CPU times: user 1.59 s, sys: 242 ms, total: 1.84 s
Wall time: 1.41 s
[28]:
[None, None, None, None, None, None, None, None, None]
~~~
{: .output}
