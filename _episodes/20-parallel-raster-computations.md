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
pieces: operations on different data blocks can be run in parallel using multiple computing units
(e.g., multi-core CPUs), thus potentially speeding up the calculation. In addition, processing chunked data can also
lead to smaller memory footprints, since one may bypass the need to store the full dataset in memory.

In this episode, we will introduce the use of Dask in the context of raster calculations. Dask is a Python library for
parallel and distributed computing that provides a framework to work with different data structures, including chunked
arrays (Dask Arrays). Dask is well integrated with (`rio`)`xarray` objects, which can use Dask arrays as underlying
data structures.

> ## More Resources on Dask
>
> TODO: Dask and Dask Arrays, with links
>
{: .callout}

It is important to notice, however, that many details determine the extent to which using Dask's chunked arrays instead
of regular Numpy arrays leads to faster calculations (and lower memory requirements). The actual operations to carry
out, the size of the dataset, and parameters such as the chunks' shape and size, all affects the performance of our
computations. Depending on the specifics of the calculations, serial calculations might actually turn out to be faster!
Being able to time profile your calculations is thus essential, and we will see how to do that in a Jupyter environment
in the next section.

# Time profiling calculations in Jupyter

Let's set up a raster calculation using assets from the search of satellite scenes that we have carried out in the
previous episode. The search result, which consisted of a collection of STAC items (an `ItemCollection`), has been saved
in GeoJSON format. We can load the collection using the `pystac` library:

~~~
import pystac
items = pystac.ItemCollection.from_file("mysearch.json")
~~~
{: .language-python}

We select the last scene, and extract the URLs of two assets: the true-color image ("visual") and the scene
classification layer ("SCL"). The latter is a mask where each grid cell is assigned a label that represents a specific
class e.g. "4" for vegetation, "6" for water, etc. (all classes and labels are reported in the
[Sentinel-2 documentation](https://sentinels.copernicus.eu/web/sentinel/technical-guides/sentinel-2-msi/level-2a/algorithm),
see Figure 3):

~~~
assets = items[-1].assets  # last item's assets
visual_href = assets["visual"].href  # true color image
scl_href = assets["SCL"].href  # scene classification layer
~~~
{: .language-python}


Opening the two assets with `rioxarray` shows that the true-color image is available as a raster file with 10 m
resolution, while the scene classification layer has a lower resolution (20 m):

~~~
import rioxarray
scl = rioxarray.open_rasterio(scl_href)
visual = rioxarray.open_rasterio(visual_href)
scl.rio.resolution(), visual.rio.resolution()
~~~
{: .language-python}

~~~
((20.0, -20.0), (10.0, -10.0))
~~~
{: .output}

In order to match the image and the mask pixels, one could load both rasters and resample the finer raster to the
coarser resolution (e.g. with `reproject_match`). Instead, here we take advantage of a feature of the cloud-optimized
GeoTIFF (COG) format, which is used to store these raster files. COGs typically include multiple lower-resolution
versions of the original image, called "overviews", in the same file. This allows to avoid downloading high-resolution
images when only quick previews are required.

Overviews are often computed using powers of 2 as down-sampling (or zoom) factors (e.g. 2, 4, 8, 16). For the true-color image we
thus open the first level overview (zoom factor 2) and check that the resolution is now also 20 m:

~~~
visual = rioxarray.open_rasterio(visual_href, overview_level=0)
visual.rio.resolution()
~~~
{: .language-python}

~~~
(20.0, -20.0)
~~~
{: .output}

We can now time profile the first step of our raster calculation: the (down)loading of the rasters' content. We do it by
using the Jupyter magic `%%time`, which returns the time required to run the content of a cell:

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

After having loaded the raster files into memory, we run the following steps:
* We create a mask of the grid cells that are labeled as "cloud" in the scene classification layer (values "8" and "9",
  standing for medium- and high-cloud probability, respectively).
* We use this mask to set the corresponding grid cells in the true-color image to null values.
* We save the masked image to disk as in COG format.

Again, we measure the cell execution time using `%%time`:

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

In the following section we will see how to make use of parallelization to run these steps and compare timings to the
serial runs.

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
