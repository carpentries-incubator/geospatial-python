---
title: "Raster Calculations in Python"
teaching: 30
exercises: 20
questions:
- "How do I subtract one raster from another and extract pixel values for defined locations?"
objectives:
- "Perform a subtraction between two rasters using python's builtin math operators."
- "Calculate zonal statistics for portions of a raster using the `rasterstats` package."
keypoints:
- "Rasters can be computed on using mathematical functions."
- "Rasters can be read as numpy arrays, a fast data structure for matrix computations"
- "The `rasterio.io.Dataset.write()` method can be used to write raster data to a file."
---

> ## Things You’ll Need To Complete This Episode
> See the [lesson homepage]({{ site.baseurl }}) for detailed information about the software,
> data, and other prerequisites you will need to work through the examples in this episode.
{: .prereq}

We often want to combine values of and perform calculations on rasters to create
a new output raster. This episode covers how to subtract one raster from
another using basic raster math. It also covers how to extract pixel values from a 
set of locations - for example a buffer region around locations at a field site.

## Raster Calculations in Python
We often want to perform calculations on two or more rasters to create a new
output raster. For example, if we are interested in mapping the heights of trees
across an entire field site, we might want to calculate the difference between
the Digital Surface Model (DSM, tops of trees) and the
Digital Terrain Model (DTM, ground level). The resulting dataset is referred to
as a Canopy Height Model (CHM) and represents the actual height of trees,
buildings, etc. with the influence of ground elevation removed.

![Source: National Ecological Observatory Network (NEON)](../images/dc-spatial-raster/lidarTree-height.png) 

> ## More Resources
> * Check out more on LiDAR CHM, DTM and DSM in this NEON Data Skills overview tutorial:
> [What is a CHM, DSM and DTM? About Gridded, Raster LiDAR Data](https://www.neonscience.org/chm-dsm-dtm-gridded-lidar-data).
{: .callout}

### Load the Data
For this episode, we will use the DTM and DSM from the
NEON Harvard Forest Field site and San Joaquin Experimental
Range, which we already have loaded from previous episodes. 
If you need to load them, we can use the `open_rasterio` function 
from `rioxarray` as we did before.

```
import xarray
import rioxarray

surface_model_HARV_xarr = xarray.open_rasterio("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
terrain_model_HARV_xarr_UTM18 = xarray.open_rasterio("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop_UTM18_rioxarray.tif")
```

## Two Ways to Perform Raster Calculations: Builtin Operators and Functions

We can calculate the difference between two rasters in two different ways:

* by directly subtracting the two rasters in Python using the math operator minus: `-`

or by calling the `numpy.subtract()` function. Both are equivalent in terms of what they do and 
calculation speed. It's important to note that `numpy` has many more functions available than basic 
mathematical operators.


## Raster Math & Canopy Height Models
We can perform raster calculations by subtracting (or adding,
multiplying, etc) two rasters. In the geospatial world, we call this
"raster math", and typically it refers to operations on rasters that 
have the same width and height. We saw from the last episode's challenge
that this is not the case with out DTM and DSM. Therefore, we will need 
to clip the larger raster to the extent of the smaller raster 

Let's subtract the DTM from the DSM to create a Canopy Height Model. 
We'll use `rioxarray` so that we can easily plot our result and keep 
track of the metadata for our CHM.

```python
canopy_height_xarr = surface_model_HARV_xarr - terrain_model_HARV_xarr
canopy_height_xarr.compute()
```

We can now plot the output CHM.

```python
import matplotlib.pyplot as plt # in case it has not been imported recently
canopy_height_xarr.plot()
plt.title("Canopy Height Model for Harvard Forest, Z Units: Meters)
```

Notice that the range of values for the output CHM is between 0 and 30 
meters. Does this make sense for trees in Harvard Forest?

> ## Challenge: Explore CHM Raster Values
> 
> It's often a good idea to explore the range of values in a raster dataset just like we might explore a dataset that we collected in the field.
> 
> 1. What is the min and maximum value for the Harvard Forest Canopy Height Model (`CHM_HARV`) that we just created?
> 2. What are two ways you can check this range of data for `CHM_HARV`?
> 3. What is the distribution of all the pixel values in the CHM?
> 4. Plot a histogram with 6 bins instead of the default and change the color of the histogram.
> 5. Plot the `CHM_HARV` raster using breaks that make sense for the data. Include an appropriate color palette for the data, plot title and no axes ticks / labels.
> 
> > ## Answers
> > 
> > 1) There are missing values in our data, so we need to specify 
> > `na.rm = TRUE`. 
> > ```{r}
> > min(CHM_HARV_df$layer, na.rm = TRUE)
> > max(CHM_HARV_df$layer, na.rm = TRUE)
> > ```
> > 2) Possible ways include: 
> > * Create a histogram
> > * Use the `min()` and `max()` functions.
> > * Print the object and look at the `values` attribute.
> > 3)
> > ```{r chm-harv-hist}
> > ggplot(CHM_HARV_df) +
> >     geom_histogram(aes(layer))
> > ```
> > 4)
> > ```{r chm-harv-hist-green}
> > ggplot(CHM_HARV_df) +
> >     geom_histogram(aes(layer), colour="black", 
> >                    fill="darkgreen", bins = 6)
> > ```
> > 5) 
> > ```{r chm-harv-raster}
> > custom_bins <- c(0, 10, 20, 30, 40)
> > CHM_HARV_df <- CHM_HARV_df %>%
> >                   mutate(canopy_discrete = cut(layer, breaks = custom_bins))
> > 
> > ggplot() +
> >   geom_raster(data = CHM_HARV_df , aes(x = x, y = y,
> >                                        fill = canopy_discrete)) + 
> >      scale_fill_manual(values = terrain.colors(4)) + 
> >      coord_quickmap()
> > ```
> {: .solution}
{: .challenge}

## Efficient Raster Calculations: Overlay Function

Raster math, like we just did, is an appropriate approach to raster calculations
if:

1. The rasters we are using are small in size.
2. The calculations we are performing are simple.

However, raster math is a less efficient approach as computation becomes more
complex or as file sizes become large.
The `overlay()` function is more efficient when:

1. The rasters we are using are larger in size.
2. The rasters are stored as individual files.
3. The computations performed are complex.

The `overlay()` function takes two or more rasters and applies a function to
them using efficient processing methods. The syntax is

`outputRaster <- overlay(raster1, raster2, fun=functionName)`

> ## Data Tip
> If the rasters are stacked and stored
> as `RasterStack` or `RasterBrick` objects in R, then we should use `calc()`.
> `overlay()` will not work on stacked rasters.
{: .callout}

Let's perform the same subtraction calculation that we calculated above using
raster math, using the `overlay()` function.

> ## Data Tip
>
> A custom function consists of a defined
> set of commands performed on a input object. Custom functions are particularly
> useful for tasks that need to be repeated over and over in the code. A
> simplified syntax for writing a custom function in R is:
> `function_name <- function(variable1, variable2) { WhatYouWantDone, WhatToReturn}`
{: .callout}

```{r raster-overlay }
CHM_ov_HARV <- overlay(DSM_HARV,
                       DTM_HARV,
                       fun = function(r1, r2) { return( r1 - r2) })
```

Next we need to convert our new object to a data frame for plotting with 
`ggplot`. 

```{r}
CHM_ov_HARV_df <- as.data.frame(CHM_ov_HARV, xy = TRUE)
```

Now we can plot the CHM:

```{r harv-chm-overlay}
 ggplot() +
   geom_raster(data = CHM_ov_HARV_df, 
               aes(x = x, y = y, fill = layer)) + 
   scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) + 
   coord_quickmap()
```

How do the plots of the CHM created with manual raster math and the `overlay()`
function compare?

## Export a GeoTIFF
Now that we've created a new raster, let's export the data as a GeoTIFF
file using
the `writeRaster()` function.

When we write this raster object to a GeoTIFF file we'll name it
`CHM_HARV.tiff`. This name allows us to quickly remember both what the data
contains (CHM data) and for where (HARVard Forest). The `writeRaster()` function
by default writes the output file to your working directory unless you specify a
full file path.

We will specify the output format ("GTiff"), the no data value (`NAflag = -9999`. We will also tell R to overwrite any data that is already in
a file of the same name. 

```{r write-raster, eval=FALSE}
writeRaster(CHM_ov_HARV, "CHM_HARV.tiff",
            format="GTiff",
            overwrite=TRUE,
            NAflag=-9999)
```

### writeRaster() Options

The function arguments that we used above include:

* **format:** specify that the format will be `GTiff` or GeoTIFF.
* **overwrite:** If TRUE, R will overwrite any existing file  with the same
name in the specified directory. USE THIS SETTING WITH CAUTION!
* **NAflag:** set the GeoTIFF tag for `NoDataValue` to -9999, the National
Ecological Observatory Network's (NEON) standard `NoDataValue`.

> ## Challenge: Explore the NEON San Joaquin Experimental Range Field Site
> 
> Data are often more interesting and powerful when we compare them across various
> locations. Let's compare some data collected over Harvard Forest to data
> collected in Southern California. The
> [NEON San Joaquin Experimental Range (SJER) field site](https://www.neonscience.org/field-sites/field-sites-map/SJER)
> located in Southern California has a very different ecosystem and climate than
> the
> [NEON Harvard Forest Field Site](https://www.neonscience.org/field-sites/field-sites-map/HARV)
in Massachusetts.
> 
> Import the SJER DSM and DTM raster files and create a Canopy Height Model.
> Then compare the two sites. Be sure to name your R objects and outputs
> carefully, as follows: objectType_SJER (e.g. `DSM_SJER`). This will help you
> keep track of data from different sites!
> 
> 0. You should have the DSM and DTM data for the SJER site already
> loaded from the 
> [Plot Raster Data in R]({{ site.baseurl }}/02-raster-plot/)
episode.) Don't forget to check the CRSs and units of the data. 
> 1. Create a CHM from the two raster layers and check to make sure the data
are what you expect.
> 2. Plot the CHM from SJER.
> 3. Export the SJER CHM as a GeoTIFF.
> 4. Compare the vegetation structure of the Harvard Forest and San Joaquin
> Experimental Range.
> 
> > ## Answers
> > 1) Use the `overlay()` function to subtract the two rasters & create
> > the CHM.
> >
> > ```{r}
> > CHM_ov_SJER <- overlay(DSM_SJER,
> >                        DTM_SJER,
> >                        fun = function(r1, r2){ return(r1 - r2) })
> > ```
> > Convert the output to a dataframe:
> >
> > ```{r}
> > CHM_ov_SJER_df <- as.data.frame(CHM_ov_SJER, xy = TRUE)
> > ```
> >
> > Create a histogram to check that the data distribution makes sense: 
> >
> > ```{r sjer-chm-overlay-hist}
> > ggplot(CHM_ov_SJER_df) +
> >     geom_histogram(aes(layer))
> > ```
> >
> > 2) Create a plot of the CHM: 
> >
> > ```{r sjer-chm-overlay-raster}
> >  ggplot() +
> >       geom_raster(data = CHM_ov_SJER_df, 
> >               aes(x = x, y = y, 
> >                    fill = layer)
> >               ) + 
> >      scale_fill_gradientn(name = "Canopy Height", 
> >         colors = terrain.colors(10)) + 
> >      coord_quickmap()
> > ```
> > 
> > 3) Export the CHM object to a file: 
> >
> > ```{r}
> > writeRaster(CHM_ov_SJER, "chm_ov_SJER.tiff",
> >             format = "GTiff",
> >             overwrite = TRUE,
> >             NAflag = -9999)
> > ```
> >
> > 4) Compare the SJER and HARV CHMs. 
> > Tree heights are much shorter in SJER. You can confirm this by 
> > looking at the histograms of the two CHMs. 
> >
> > ```{r compare-chm-harv-sjer}
> > ggplot(CHM_HARV_df) +
> >     geom_histogram(aes(layer))
> >
> > ggplot(CHM_ov_SJER_df) +
> >     geom_histogram(aes(layer))
> > ```
> {: .solution}
{: .challenge}


{% include links.md %}


