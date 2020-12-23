---
title: "Work With Multi-Band Rasters in Python FIXME"
teaching: 40
exercises: 20
questions:
- "How can I visualize individual and multiple bands in a raster object?"
objectives:
- "Identify a single vs. a multi-band raster file."
- "Import multi-band rasters into Python using the `rioxarray` package."
- "Plot multi-band color image rasters using the `rioxarray` package."
keypoints:
- "A single raster file can contain multiple bands or layers."
- "Individual bands within a DataArray can be accessed, analyzed, and visualized using  
  the same plot function as single bands."
---

> ## Things You'll Need To Complete This Episode
>
> See the [lesson homepage]({{ site.baseurl }}) for detailed information about the software,
> data, and other prerequisites you will need to work through the examples in this episode.
{: .prereq}

We introduced multi-band raster data in [an earlier
lesson]({{ site.baseurl }}/01-intro-raster-data). This episode explores how to import and plot a
multi-band raster in Python.

## Getting Started with Multi-Band Data in Python

In this episode, the multi-band data that we are working with is imagery
collected using the
[NEON Airborne Observation Platform](https://www.neonscience.org/data-collection/airborne-remote-sensing)
high resolution camera over the
[NEON Harvard Forest field site](https://www.neonscience.org/field-sites/field-sites-map/HARV).
Each RGB image is a 3-band raster. The same steps would apply to
working with a multi-spectral image with 4 or more bands - like Landsat imagery.

We will use 1 package in this episode to work with raster data - `rioxarray`,
which is based on the popular `rasterio` package for working with rasters and
`xarray` for working with multi-dimensional arrays.  Make sure that you have
`rioxarray` installed and imported.

~~~
import rioxarray
~~~
{: .language-python}

The `open_rasterio` function in the `rioxarray` package can read multi-band
rasters, also referred to as "stack(s)" into Python.

~~~
rgb_stack_HARV = rioxarray.open_rasterio("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif")
~~~
{: .language-python}

As usual, we can use the `print()` function to inspect `rgb_stack_HARV`.

~~~
print(rgb_stack_HARV)
~~~
{: .language-python}

~~~
<xarray.DataArray (band: 3, y: 2317, x: 3073)>
array([[[  0.,   2., ...,   0.,   0.],
        [  0., 112., ...,   0.,   0.],
        ...,
        [  0.,   0., ...,   0.,   0.],
        [  0.,   0., ...,   0.,   0.]],

       [[  1.,   0., ...,   0.,   0.],
        [  0., 130., ...,   0.,   0.],
        ...,
        [  0.,   0., ...,   0.,   0.],
        [  0.,   0., ...,   0.,   0.]],

       [[  0.,  10., ...,   0.,   0.],
        [  1.,  99., ...,   0.,   0.],
        ...,
        [  0.,   0., ...,   0.,   0.],
        [  0.,   0., ...,   0.,   0.]]])
Coordinates:
  * band         (band) int64 1 2 3
  * y            (y) float64 4.714e+06 4.714e+06 ... 4.713e+06 4.713e+06
  * x            (x) float64 7.32e+05 7.32e+05 7.32e+05 ... 7.328e+05 7.328e+05
    spatial_ref  int64 0
Attributes:
    STATISTICS_MAXIMUM:  255
    STATISTICS_MEAN:     nan
    STATISTICS_MINIMUM:  0
    STATISTICS_STDDEV:   nan
    transform:           (0.25, 0.0, 731998.5, 0.0, -0.25, 4713535.5)
    _FillValue:          -1.7e+308
    scale_factor:        1.0
    add_offset:          0.0
    grid_mapping:        spatial_ref
~~~
{: .output}

On the first line we see that `rgb_stack_HARV` is an `xarray.DataArray` object,
just like the object created by reading a single-band raster in [an
earlier episode]({{ site.baseurl }}/05-raster-structure). The shape, `(band: 3, y: 2317, x:
3073)`, indicates that this raster has three bands.

> ## Package Delivery
> You may have expected `rgb_stack_HARV` to be a `rioxarray` object. That *is*
> the Python package we used to read in the file, after all! What's really
> happening here?
>
> As we mentioned in [an earlier episode]({{ site.baseurl }}/05-raster-structure), `rioxarray` is
> based on two other packages: `rasterio` and `xarray`.
>
> `xarray` is a great tool for manipulating and anayzing data in labeled
> multi-dimensional arrays, but it cannot read or write GeoTIFF (i.e., `.tif`)
> files such as those used in this lesson. The `rasterio` package *can* read and
> write GeoTIFF files, but provides limited functionality for data analysis
> compared to `xarray`. While it is possible to manually create an `xarray`
> object from a GeoTIFF, it is a tedious process. This is where `rioxarray`
> comes in.
>
> The `open_rasterio()` function provided by `rioxarray` uses the `rasterio`
> package to read GeoTIFF files directly into `xarray.DataArray` objects. Using
> existing packages in this way allows us to avoid "reinventing the wheel."
>
{: .callout}

As with a single-band raster, each of the object attributes can be accessed individually as well.

~~~
print(type(rgb_stack_HARV))
print(rgb_stack_HARV.shape)
print(rgb_stack_HARV.values)
~~~
{: .language-python}

~~~
<class 'xarray.core.dataarray.DataArray'>
(3, 2317, 3073)
[[[  0.   2.   6. ...   0.   0.   0.]
  [  0. 112. 104. ...   0.   0.   0.]
  [ 19.  98. 137. ...   0.   0.   0.]
  ...
  [  0.   0.   0. ...   0.   0.   0.]
  [  0.   0.   0. ...   0.   0.   0.]
  [  0.   0.   0. ...   0.   0.   0.]]

 [[  1.   0.   9. ...   0.   0.   0.]
  [  0. 130. 130. ...   0.   0.   0.]
  [ 21. 117. 142. ...   0.   0.   0.]
  ...
  [  0.   0.   0. ...   0.   0.   0.]
  [  0.   0.   0. ...   0.   0.   0.]
  [  0.   0.   0. ...   0.   0.   0.]]

 [[  0.  10.   1. ...   0.   0.   0.]
  [  1.  99. 113. ...   0.   0.   0.]
  [ 12. 104. 114. ...   0.   0.   0.]
  ...
  [  0.   0.   0. ...   0.   0.   0.]
  [  0.   0.   0. ...   0.   0.   0.]
  [  0.   0.   0. ...   0.   0.   0.]]]
~~~
{: .output}

View the raster's coordinates by accessing the `.coords` attribute.

~~~
print(rgb_stack_HARV.coords)
~~~
{: .language-python}

~~~
Coordinates:
  * band         (band) int64 1 2 3
  * y            (y) float64 4.714e+06 4.714e+06 ... 4.713e+06 4.713e+06
  * x            (x) float64 7.32e+05 7.32e+05 7.32e+05 ... 7.328e+05 7.328e+05
    spatial_ref  int64 0
~~~
{: .output}

Similarly, view the raster's attributes field by accessing the `.attrs` attribute.

~~~
print(rgb_stack_HARV.attrs)
~~~
{: .language-python}

~~~
{'STATISTICS_MAXIMUM': 255, 'STATISTICS_MEAN': nan, 'STATISTICS_MINIMUM': 0, 'STATISTICS_STDDEV': nan, 'transform': (0.25, 0.0, 731998.5, 0.0, -0.25, 4713535.5), '_FillValue': -1.7e+308, 'scale_factor': 1.0, 'add_offset': 0.0, 'grid_mapping': 'spatial_ref'}
~~~
{: .output}

We can also directly access raster metadata values just as we did with single-band rasters.

~~~
print(rgb_stack_HARV.rio.crs)
print(rgb_stack_HARV.rio.nodata)
print(rgb_stack_HARV.rio.bounds())
print(rgb_stack_HARV.rio.width)
print(rgb_stack_HARV.rio.height)
~~~
{: .language-python}

~~~
EPSG:32618
-1.7e+308
(731998.5, 4712956.25, 732766.75, 4713535.5)
3073
2317
~~~
{: .output}

## Image Raster Data Values

As we saw in the previous exercise, this raster contains values between 0
and 255. These values represent degrees of brightness associated with the image
band. In the case of a RGB image (red, green and blue), band 1 is the red
band. When we plot the red band, larger numbers (towards 255) represent pixels
with more red in them (a strong red reflection). Smaller numbers (towards 0)
represent pixels with less red in them (less red was reflected). To plot an RGB
image, we mix red + green + blue values into one single color to create a full
color image - similar to the color image a digital camera creates.

## Select A Specific Band

We can use the `sel()` function to select specific bands from our raster object
by specifying which band we want `band = <value>` (where `<value>` is the value
of the band we want to work with). To select the red band, we would pass the
argument `band=1` to the `sel()` function.

~~~
rgb_band1_HARV = rgb_stack_HARV.sel(band=1)
~~~
{: .language-python}

To select the green band, we would pass `band=2`.

~~~
rgb_band2_HARV = rgb_stack_HARV.sel(band=2)
~~~
{: .language-python}

We can confirm that these objects only contain a single band by checking the shape.

~~~
rgb_band1_HARV
~~~
{: .language-python}

~~~
(2317, 3073)
~~~
{: .output}

This shape output contains only two dimensions, confirming that `rgb_band1_HARV`
contains only a single band.

We can then plot these bands using the `plot.imshow()` function. First, plot
band 1 (red).

~~~
rgb_band1_HARV.plot.imshow(figsize=(9,7), cmap="Greys")
~~~
{: .language-python}

<img src="../fig/08-band1-grayscale-plot-01.png" title="plot of red band (band 1)" alt="plot of red band (band 1)" width="612" style="display: block; margin: auto;" />

Next, plot band 2 (green).

~~~
rgb_band2_HARV.plot.imshow(figsize=(9,7), cmap="Greys")
~~~
{: .language-python}

<img src="../fig/08-band2-grayscale-plot-01.png" title="plot of red band (band 1)" alt="plot of red band (band 1)" width="612" style="display: block; margin: auto;" />

> ## Plot Arguments
>
> You probably noticed the arguments `figsize` and `cmap` were passed to the
> plotting function. The default figure size is a bit small so we used the
> `figsize` argument to increase the size of the plot. We also elected to use a
> grayscale [color map](https://matplotlib.org/tutorials/colors/colormaps.html)
> to allow you to more easily compare values contained in the red and green
> bands.
>
{: .callout}

> ## Challenge: Making Sense of Single Band Images
>
> Compare the plots of band 1 (red) and band 2 (green). Is the forested area
> darker or lighter in band 2 (the green band) compared to band 1 (the red
> band)? Why?
>
> > ## Answers 
> > The forested area appears darker in band 2 (green) compared to band 1 (red)
> > because the leaves on healthy plants typically appear green--meaning they
> > reflect *more green light* than red light. Remember, we're dealing with RGB
> > values in this raster where larger values represent a greater contribution
> > of a color in the final mix of red, green, and blue. Revisit the *Image
> > Raster Data Values* section above for a deeper explanation.
> {: .solution}
{: .challenge}

We don't always have to create a new variable to explore or plot each band in a
raster, however. We can select a band using the `sel()` function described
earlier and then call another function on its output in the same line, a
practice called "method chaining". For example, let's use method
chaining to create a histogram of band 1.

~~~
rgb_stack_HARV.sel(band=1).plot.hist()
~~~
{: .language-python}

<img src="../fig/08-band1-hist-plot-02.png" title="histogram of band 1" alt="histogram of band 1" width="612" style="display: block; margin: auto;" />

We can use the `bins` argument to increase the number of bins for the histogram.

~~~
rgb_stack_HARV.sel(band=1).plot.hist(bins=30)
~~~
{: .language-python}

<img src="../fig/08-band1-hist-plot-03.png" title="histogram of band 1 with 30 bins" alt="histogram of band 1 with 30 bins" width="612" style="display: block; margin: auto;" />

## Create A Three Band Image

To render a final, three band, colored image in Python, we again turn to the `plot.imshow()` function.

~~~
rgb_stack_HARV.plot.imshow(figsize=(9,7))
~~~
{: .language-python}

<img src="../fig/08-rgb-nostretch-plot-04.png" title="plot of rgb stack without value stretch" alt="plot of rgb stack without value stretch" width="612" style="display: block; margin: auto;" />

From this plot we see something interesting, while our no data values were
masked along the edges, the color channel’s no data values don’t all line
up. The colored pixels at the edges between white black result from there being
no data in one or two channels at a given pixel. 0 could conceivably represent a
valid value for reflectance (the units of our pixel values) so it’s good to make
sure we are masking values at the edges and not valid data values within the
image.

While this plot tells us where we have no data values, the color scale look
strange, because our plotting function expects image values to be normalized
between a certain range (0-1 or 0-255). By using `rgb_stack_HARV.plot.imshow`
with the `robust=True` argument, we can display values between the 2nd and 98th
percentile, providing better color contrast.

~~~
rgb_stack_HARV.plot.imshow(figsize=(9,7), robust=True)
~~~
{: .language-python}

<img src="../fig/08-rgb-stretched-plot-05.png" title="plot of rgb stack with value stretch" alt="plot of rgb stack with value stretch" width="612" style="display: block; margin: auto;" />

When the range of pixel brightness values is closer to 0, a darker image is
rendered by default. We can stretch the values to extend to the full 0-255 range
of potential values to increase the visual contrast of the image.

![Image Stretch light](../fig/dc-spatial-raster/imageStretch_light.jpg)

When the range of pixel brightness values is closer to 255, a lighter image is
rendered by default. We can stretch the values to extend to the full 0-255 range
of potential values to increase the visual contrast of the image.

![Image Stretch](../fig/dc-spatial-raster/imageStretch_dark.jpg)

It is possible to perform a custom stretch when plotting multi-band rasters with `imshow()` by using the keyword arguments `vmin` and `vmax`. For example, here's how we can use `vmin` and `vmax` to recreate the output of `imshow(robust=True)`:

~~~
rgb_stack_HARV.plot.imshow(figsize=(9,7),
                     vmin=rgb_stack_HARV.quantile(0.02),
                     vmax=rgb_stack_HARV.quantile(0.98))
~~~
{: .language-python}

<img src="../fig/08-custom-stretch-plot-06.png"/>

In the code above we use the `quantile()` function to calculate the 2nd and 98th quantiles of the data values in `rgb_stack_HARV` and pass those values to `vmin` and `max`, respectively.

<!-- TODO: complete TODOs in challenge below -->
> ## Challenge: NoData Values
>
> Let's explore what happens with NoData values when working with and plotting
> rasters. We will use the `HARV_Ortho_wNA.tif` GeoTIFF file in the
> `NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/` directory.
> 1. Load the multi-band raster into Python.
> 2. View the file's attributes. Are there `NoData` values assigned for this file? (Hint: this value is sometimes called `FillValue`)
> 3. If so, what is the `NoData` value?
> 4. How many bands does this raster have?
> 5. Plot the raster as a true-color image.
> 6. What happened to the black edges in the plot?
> 7. What does this tell us about the difference in the data structure between `HARV_Ortho_wNA.tif` and `HARV_RGB_Ortho.tif`. How can you check?
>
> > ## Answers
> > 1. First, load the raster into Python using `rasterio.open_rasterio()`.
> > <!-- TODO: add code snippet -->
> > 2. Inspect the `DataArray` object's attributes.
> > <!-- TODO: add sample output -->
> > 3. The `NoData`, or `FillValue`, of this raster is -9999.
> > 4. The raster has 3 bands.
> > 5. <!-- TODO: add image of true-color plot -->
> > 6. The black edges are not plotted. <!-- TODO: FYI this differs from the R
> > implementation. Need to use `where()` to mask NoData manually in Python.-->
> > 7. Both datasets have `NoData` values, however, in `rgb_stack_HARV` the `NoData`
> {: .solution}
{: .challenge}

<!--TODO: there doesn't seem to be a great way to view all methods associated
with an object in Python. Need to explore this further...-->
> ## Challenge: What Functions Can Be Used on a Python Object of a Particular Class?
>
> 1. What methods can be used on the `rgb_stack_HARV` object?
> 2. What methods can be used on a single band within `rgb_stack_HARV`?
> 3. Is there a difference? Why?
>
> > ## Answers
> >
> > 1. We can see a list of all methods (and accessible attributes) for `rgb_stack_HARV` by typing the variable name followed by a period and then hitting the TAB key. Or by using the built-in `dir()` function.
> >
> > ~~~ 
> > dir(rgb_stack_HARV)
> > ~~~
> > {: .language-python}
> >
> > ~~~
> > ['STATISTICS_MAXIMUM', 'STATISTICS_MEAN', 'STATISTICS_MINIMUM', 'STATISTICS_STDDEV', ... , 'where', 'x', 'y']
> > ~~~
> > {: .output}
> > 2. Use the same approach to view the methods and attributes of `rgb_stack_HARV_NA`.
> > 3. Compare the output.
> >
> > ~~~
> > (dir(rgb_stack_HARV) == dir(rgb_stack_HARV_NA))
> > ~~~
> > {: .language-python}
> >
> > ~~~
> > True
> > ~~~
> > {: .output}
> >
> > The methods and attributes of each are the same because they are the same type of object, `xarray.DataArray`.
> {: .solution}
{: .challenge}


{% include links.md %}

