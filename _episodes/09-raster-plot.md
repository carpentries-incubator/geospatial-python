---
title: "Plot Raster Data in Python FIXME"
teaching: 40
exercises: 20
questions:
- "How can I create categorized or customized maps of raster data?"
- "How can I customize the color scheme of a raster image?"
- "How can I layer raster data in a single image?"
objectives:
- "Build customized plots for a single band raster using the `earthpy` package."
- "Layer a raster dataset on top of a hillshade to create an elegant basemap."
keypoints:
- "Continuous data ranges can be grouped into categories using `mutate()` and `cut()`."
- "Use `earthpy.plot_bands()` and the `cmap` argument to change the color scheme."
- "Layer rasters on top of one another by using the `alpha` argument"
---

> ## Things You’ll Need To Complete This Episode
> See the [lesson homepage]({{ site.baseurl }}) for detailed information about the software,
> data, and other prerequisites you will need to work through the examples in this episode.
{: .prereq}

## Plot Raster Data in R
This episode covers how to plot a raster in python using the `earthpy`
package with customized coloring schemes. 
It also covers how to layer a raster on top of a hillshade to produce
an eloquent map. We will continue working with the Digital Surface Model (DSM) raster
for the NEON Harvard Forest Field Site. 

## Plotting Data Using Breaks
In the previous episode, we viewed our data using a continuous color ramp. For 
clarity and visibility of the plot, we may prefer to view the data "symbolized" or colored according to ranges of values. This is comparable to a "classified"
map. To do this, we need to tell `ggplot` how many groups to break our data into, and
where those breaks should be. To make these decisions, it is useful to first explore the distribution of the data using a bar plot. To begin with, we will use `dplyr`'s `mutate()` function combined with `cut()` to split the data into 3 bins.


~~~
DSM_HARV_df <- DSM_HARV_df %>%
                mutate(fct_elevation = cut(HARV_dsmCrop, breaks = 3))

ggplot() +
    geom_bar(data = DSM_HARV_df, aes(fct_elevation))
~~~
{: .language-r}

<img src="../fig/rmd-02-histogram-breaks-ggplot-1.png" title="plot of chunk histogram-breaks-ggplot" alt="plot of chunk histogram-breaks-ggplot" width="612" style="display: block; margin: auto;" />

If we want to know the cutoff values for the groups, we can ask for the unique values 
of `fct_elevation`:

~~~
unique(DSM_HARV_df$fct_elevation)
~~~
{: .language-r}



~~~
[1] (379,416] (342,379] (305,342]
Levels: (305,342] (342,379] (379,416]
~~~
{: .output}

And we can get the count of values in each group using `dplyr`'s 
`group_by()` and `count()` functions:


~~~
DSM_HARV_df %>%
        group_by(fct_elevation) %>%
        count()
~~~
{: .language-r}



~~~
# A tibble: 3 x 2
# Groups:   fct_elevation [3]
  fct_elevation       n
  <fct>           <int>
1 (305,342]      418891
2 (342,379]     1530073
3 (379,416]      370835
~~~
{: .output}

We might prefer to customize the cutoff values for these groups.
Lets round the cutoff values so that we have groups for the ranges of 
301–350 m, 351–400 m, and 401–450 m.
To implement this we will give `mutate()` a numeric vector of break points instead 
of the number of breaks we want.


~~~
custom_bins <- c(300, 350, 400, 450)

DSM_HARV_df <- DSM_HARV_df %>%
  mutate(fct_elevation_2 = cut(HARV_dsmCrop, breaks = custom_bins))

unique(DSM_HARV_df$fct_elevation_2)
~~~
{: .language-r}



~~~
[1] (400,450] (350,400] (300,350]
Levels: (300,350] (350,400] (400,450]
~~~
{: .output}

> ## Data Tips
> Note that when we assign break values a set of 4 values will result in 3 bins of data.
>
> The bin intervals are shown using `(` to mean exclusive and `]` to mean inclusive. For example: `(305, 342]` means "from 306 through 342".
{: .callout}

And now we can plot our bar plot again, using the new groups:


~~~
ggplot() +
  geom_bar(data = DSM_HARV_df, aes(fct_elevation_2))
~~~
{: .language-r}

<img src="../fig/rmd-02-histogram-custom-breaks-1.png" title="plot of chunk histogram-custom-breaks" alt="plot of chunk histogram-custom-breaks" width="612" style="display: block; margin: auto;" />

And we can get the count of values in each group in the same way we did before:


~~~
DSM_HARV_df %>%
  group_by(fct_elevation_2) %>%
  count()
~~~
{: .language-r}



~~~
# A tibble: 3 x 2
# Groups:   fct_elevation_2 [3]
  fct_elevation_2       n
  <fct>             <int>
1 (300,350]        741815
2 (350,400]       1567316
3 (400,450]         10668
~~~
{: .output}

We can use those groups to plot our raster data, with each group being a different color:


~~~
ggplot() +
  geom_raster(data = DSM_HARV_df , aes(x = x, y = y, fill = fct_elevation_2)) + 
  coord_quickmap()
~~~
{: .language-r}

<img src="../fig/rmd-02-raster-with-breaks-1.png" title="plot of chunk raster-with-breaks" alt="plot of chunk raster-with-breaks" width="612" style="display: block; margin: auto;" />

The plot above uses the default colors inside `ggplot` for raster objects. 
We can specify our own colors to make the plot look a little nicer.
R has a built in set of colors for plotting terrain, which are built in
to the `terrain.colors()` function.
Since we have three bins, we want to create a 3-color palette:


~~~
terrain.colors(3)
~~~
{: .language-r}



~~~
[1] "#00A600FF" "#ECB176FF" "#F2F2F2FF"
~~~
{: .output}

The `terrain.colors()` function returns *hex colors* - 
 each of these character strings represents a color.
To use these in our map, we pass them across using the 
 `scale_fill_manual()` function.


~~~
ggplot() +
 geom_raster(data = DSM_HARV_df , aes(x = x, y = y,
                                      fill = fct_elevation_2)) + 
    scale_fill_manual(values = terrain.colors(3)) + 
    coord_quickmap()
~~~
{: .language-r}

<img src="../fig/rmd-02-ggplot-breaks-customcolors-1.png" title="plot of chunk ggplot-breaks-customcolors" alt="plot of chunk ggplot-breaks-customcolors" width="612" style="display: block; margin: auto;" />

### More Plot Formatting

If we need to create multiple plots using the same color palette, we can create
an R object (`my_col`) for the set of colors that we want to use. We can then
quickly change the palette across all plots by modifying the `my_col`
object, rather than each individual plot.

We can label the x- and y-axes of our plot too using `xlab` and `ylab`.
We can also give the legend a more meaningful title by passing a value 
to the `name` argument of the `scale_fill_manual()` function.


~~~
my_col <- terrain.colors(3)

ggplot() +
 geom_raster(data = DSM_HARV_df , aes(x = x, y = y,
                                      fill = fct_elevation_2)) + 
    scale_fill_manual(values = my_col, name = "Elevation") + 
    coord_quickmap()
~~~
{: .language-r}

<img src="../fig/rmd-02-add-ggplot-labels-1.png" title="plot of chunk add-ggplot-labels" alt="plot of chunk add-ggplot-labels" width="612" style="display: block; margin: auto;" />

Or we can also turn off the labels of both axes by passing `element_blank()` to
the relevant part of the `theme()` function.


~~~
ggplot() +
 geom_raster(data = DSM_HARV_df , aes(x = x, y = y,
                                      fill = fct_elevation_2)) + 
    scale_fill_manual(values = my_col, name = "Elevation") +
    theme(axis.title = element_blank()) + 
    coord_quickmap()
~~~
{: .language-r}

<img src="../fig/rmd-02-turn-off-axes-1.png" title="plot of chunk turn-off-axes" alt="plot of chunk turn-off-axes" width="612" style="display: block; margin: auto;" />

> ## Challenge: Plot Using Custom Breaks
>
> Create a plot of the Harvard Forest Digital Surface Model (DSM) that has:
>
> 1. Six classified ranges of values (break points) that are evenly divided among the range of pixel values.
> 2. Axis labels.
> 3. A plot title.
>
> > ## Answers
> > 
> > ~~~
> > DSM_HARV_df <- DSM_HARV_df  %>%
> >                mutate(fct_elevation_6 = cut(HARV_dsmCrop, breaks = 6)) 
> > 
> >  my_col <- terrain.colors(6)
> > 
> > ggplot() +
> >     geom_raster(data = DSM_HARV_df , aes(x = x, y = y,
> >                                       fill = fct_elevation_6)) + 
> >     scale_fill_manual(values = my_col, name = "Elevation") + 
> >     ggtitle("Classified Elevation Map - NEON Harvard Forest Field Site") +
> >     xlab("UTM Westing Coordinate (m)") +
> >     ylab("UTM Northing Coordinate (m)") + 
> >     coord_quickmap()
> > ~~~
> > {: .language-r}
> > 
> > <img src="../fig/rmd-02-challenge-code-plotting-1.png" title="plot of chunk challenge-code-plotting" alt="plot of chunk challenge-code-plotting" width="612" style="display: block; margin: auto;" />
> {: .solution}
{: .challenge}

## Layering Rasters

We can layer a raster on top of a hillshade raster for the same area, and use a
transparency factor to create a 3-dimensional shaded effect. A
hillshade is a raster that maps the shadows and texture that you would see from
above when viewing terrain.
We will add a custom color, making the plot grey. 

First we need to read in our DSM hillshade data and view the structure:


~~~
DSM_hill_HARV <-
  raster("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif")
~~~
{: .language-r}



~~~
NOTE: rgdal::checkCRSArgs: no proj_defs.dat in PROJ.4 shared files
~~~
{: .output}



~~~
DSM_hill_HARV
~~~
{: .language-r}



~~~
class       : RasterLayer 
dimensions  : 1367, 1697, 2319799  (nrow, ncol, ncell)
resolution  : 1, 1  (x, y)
extent      : 731453, 733150, 4712471, 4713838  (xmin, xmax, ymin, ymax)
coord. ref. : +proj=utm +zone=18 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
data source : /home/rave/r-raster-vector-geospatial/_episodes_rmd/data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif 
names       : HARV_DSMhill 
values      : -0.7136298, 0.9999997  (min, max)
~~~
{: .output}

Next we convert it to a dataframe, so that we can plot it using `ggplot2`:


~~~
DSM_hill_HARV_df <- as.data.frame(DSM_hill_HARV, xy = TRUE) 

str(DSM_hill_HARV_df)
~~~
{: .language-r}



~~~
'data.frame':	2319799 obs. of  3 variables:
 $ x           : num  731454 731454 731456 731456 731458 ...
 $ y           : num  4713838 4713838 4713838 4713838 4713838 ...
 $ HARV_DSMhill: num  NA NA NA NA NA NA NA NA NA NA ...
~~~
{: .output}

Now we can plot the hillshade data:


~~~
ggplot() +
  geom_raster(data = DSM_hill_HARV_df,
              aes(x = x, y = y, alpha = HARV_DSMhill)) + 
  scale_alpha(range =  c(0.15, 0.65), guide = "none") + 
  coord_quickmap()
~~~
{: .language-r}

<img src="../fig/rmd-02-raster-hillshade-1.png" title="plot of chunk raster-hillshade" alt="plot of chunk raster-hillshade" width="612" style="display: block; margin: auto;" />

> ## Data Tips
> Turn off, or hide, the legend on a plot by adding `guide = "none"` 
> to a `scale_something()` function or by setting
> `theme(legend.position = "none")`.
> 
> The alpha value determines how transparent the colors will be (0 being
> transparent, 1 being opaque).
{: .callout}

We can layer another raster on top of our hillshade by adding another call to 
the `geom_raster()` function. Let's overlay `DSM_HARV` on top of the `hill_HARV`.


~~~
ggplot() +
  geom_raster(data = DSM_HARV_df , 
              aes(x = x, y = y, 
                  fill = HARV_dsmCrop)) + 
  geom_raster(data = DSM_hill_HARV_df, 
              aes(x = x, y = y, 
                  alpha = HARV_DSMhill)) +  
  scale_fill_viridis_c() +  
  scale_alpha(range = c(0.15, 0.65), guide = "none") +  
  ggtitle("Elevation with hillshade") +
  coord_quickmap()
~~~
{: .language-r}

<img src="../fig/rmd-02-overlay-hillshade-1.png" title="plot of chunk overlay-hillshade" alt="plot of chunk overlay-hillshade" width="612" style="display: block; margin: auto;" />

> ## Challenge: Create DTM & DSM for SJER
> 
> Use the files in the `NEON_RemoteSensing/SJER/` directory to create a Digital
Terrain Model map and Digital Surface Model map of the San Joaquin Experimental
Range field site.
> 
> Make sure to:
> 
> * include hillshade in the maps,
> * label axes on the DSM map and exclude them from the DTM map,
> * include a title for each map,
> * experiment with various alpha values and color palettes to represent the
 data.
>
> > ## Answers
> > 
> > 
> > ~~~
> > # CREATE DSM MAPS
> > 
> > # import DSM data
> > DSM_SJER <- raster("data/NEON-DS-Airborne-Remote-Sensing/SJER/DSM/SJER_dsmCrop.tif")
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > NOTE: rgdal::checkCRSArgs: no proj_defs.dat in PROJ.4 shared files
> > ~~~
> > {: .output}
> > 
> > 
> > 
> > ~~~
> > # convert to a df for plotting
> > DSM_SJER_df <- as.data.frame(DSM_SJER, xy = TRUE)
> > 
> > # import DSM hillshade
> > DSM_hill_SJER <- raster("data/NEON-DS-Airborne-Remote-Sensing/SJER/DSM/SJER_dsmHill.tif")
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > NOTE: rgdal::checkCRSArgs: no proj_defs.dat in PROJ.4 shared files
> > ~~~
> > {: .output}
> > 
> > 
> > 
> > ~~~
> > # convert to a df for plotting
> > DSM_hill_SJER_df <- as.data.frame(DSM_hill_SJER, xy = TRUE)
> > 
> > # Build Plot
> > ggplot() +
> >     geom_raster(data = DSM_SJER_df , 
> >                 aes(x = x, y = y, 
> >                      fill = SJER_dsmCrop,
> >                      alpha = 0.8)
> >                 ) + 
> >     geom_raster(data = DSM_hill_SJER_df, 
> >                 aes(x = x, y = y, 
> >                   alpha = SJER_dsmHill)
> >                 ) +
> >     scale_fill_viridis_c() +
> >     guides(fill = guide_colorbar()) +
> >     scale_alpha(range = c(0.4, 0.7), guide = "none") +
> >     # remove grey background and grid lines
> >     theme_bw() + 
> >     theme(panel.grid.major = element_blank(), 
> >           panel.grid.minor = element_blank()) +
> >     xlab("UTM Westing Coordinate (m)") +
> >     ylab("UTM Northing Coordinate (m)") +
> >     ggtitle("DSM with Hillshade") +
> >     coord_quickmap()
> > ~~~
> > {: .language-r}
> > 
> > <img src="../fig/rmd-02-challenge-hillshade-layering-1.png" title="plot of chunk challenge-hillshade-layering" alt="plot of chunk challenge-hillshade-layering" width="612" style="display: block; margin: auto;" />
> > 
> > ~~~
> > # CREATE DTM MAP
> > # import DTM
> > DTM_SJER <- raster("data/NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmCrop.tif")
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > NOTE: rgdal::checkCRSArgs: no proj_defs.dat in PROJ.4 shared files
> > ~~~
> > {: .output}
> > 
> > 
> > 
> > ~~~
> > DTM_SJER_df <- as.data.frame(DTM_SJER, xy = TRUE)
> > 
> > # DTM Hillshade
> > DTM_hill_SJER <- raster("data/NEON-DS-Airborne-Remote-Sensing/SJER/DTM/SJER_dtmHill.tif")
> > ~~~
> > {: .language-r}
> > 
> > 
> > 
> > ~~~
> > NOTE: rgdal::checkCRSArgs: no proj_defs.dat in PROJ.4 shared files
> > ~~~
> > {: .output}
> > 
> > 
> > 
> > ~~~
> > DTM_hill_SJER_df <- as.data.frame(DTM_hill_SJER, xy = TRUE)
> > 
> > ggplot() +
> >     geom_raster(data = DTM_SJER_df ,
> >                 aes(x = x, y = y,
> >                      fill = SJER_dtmCrop,
> >                      alpha = 2.0)
> >                 ) +
> >     geom_raster(data = DTM_hill_SJER_df,
> >                 aes(x = x, y = y,
> >                   alpha = SJER_dtmHill)
> >                 ) +
> >     scale_fill_viridis_c() +
> >     guides(fill = guide_colorbar()) +
> >     scale_alpha(range = c(0.4, 0.7), guide = "none") +
> >     theme_bw() +
> >     theme(panel.grid.major = element_blank(), 
> >           panel.grid.minor = element_blank()) +
> >     theme(axis.title.x = element_blank(),
> >           axis.title.y = element_blank()) +
> >     ggtitle("DTM with Hillshade") +
> >     coord_quickmap()
> > ~~~
> > {: .language-r}
> > 
> > <img src="../fig/rmd-02-challenge-hillshade-layering-2.png" title="plot of chunk challenge-hillshade-layering" alt="plot of chunk challenge-hillshade-layering" width="612" style="display: block; margin: auto;" />
> {: .solution}
{: .challenge}

## Bad Data Values in Rasters

Bad data values are different from no data values. Bad data values are values
that fall outside of the applicable range of a dataset.

Examples of Bad Data Values:

* The normalized difference vegetation index (NDVI), which is a measure of
greenness, has a valid range of -1 to 1. Any value outside of that range would
be considered a "bad" or miscalculated value.
* Reflectance data in an image will often range from 0-1 or 0-10,000 depending
upon how the data are scaled. Thus a value greater than 1 or greater than 10,000
is likely caused by an error in either data collection or processing.

### Find Bad Data Values
Sometimes a raster's metadata will tell us the range of expected values for a
raster. Values outside of this range are suspect and we need to consider that
when we analyze the data. Sometimes, we need to use some common sense and
scientific insight as we examine the data - just as we would for field data to
identify questionable values.

Plotting data with appropriate highlighting can help reveal patterns in bad
values and may suggest a solution. Below, reclassification is used to highlight
elevation values over 400m with a contrasting colour.

## Create A Histogram of Raster Values

We can explore the distribution of values contained within our raster using the
`geom_histogram()` function which produces a histogram. Histograms are often
useful in identifying outliers and bad data values in our raster data.


~~~
ggplot() +
    geom_histogram(data = DSM_HARV_df, aes(HARV_dsmCrop))
~~~
{: .language-python}



~~~
`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
~~~
{: .output}

<img src="../fig/rmd-01-view-raster-histogram-1.png" title="plot of chunk view-raster-histogram" alt="plot of chunk view-raster-histogram" width="612" style="display: block; margin: auto;" />

Notice that a warning message is thrown when Python creates the histogram.

`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

This warning is caused by a default setting in `geom_histogram` enforcing that there are
30 bins for the data. We can define the number of bins we want in the histogram
by using the `bins` value in the `geom_histogram()` function.



~~~
ggplot() +
    geom_histogram(data = DSM_HARV_df, aes(HARV_dsmCrop), bins = 40)
~~~
{: .language-python}

<img src="../fig/rmd-01-view-raster-histogram2-1.png" title="plot of chunk view-raster-histogram2" alt="plot of chunk view-raster-histogram2" width="612" style="display: block; margin: auto;" />

Note that the shape of this histogram looks similar to the previous one that
was created using the default of 30 bins. The distribution of elevation values
for our `Digital Surface Model (DSM)` looks reasonable. It is likely there are
no bad data values in this particular raster.

> ## Challenge: Explore Raster Metadata
>
> Use `GDALinfo()` to determine the following about the `NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif` file:
>
> 1. Does this file have the same CRS as `DSM_HARV`?
> 2. What is the `NoDataValue`?
> 3. What is resolution of the raster data?
> 4. How large would a 5x5 pixel area be on the Earth's surface?
> 5. Is the file a multi- or single-band raster?
>
> Notice: this file is a hillshade. We will learn about hillshades in the [Working with
> Multi-band Rasters in R]({{ site.baseurl }}/05-raster-multi-band-in-r/)  episode.
> >
> > ## Answers
> >
> > 
> > ~~~
> > GDALinfo("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif")
> > ~~~
> > {: .language-python}
> > 
> > 
> > 
> > ~~~
> > rows        1367 
> > columns     1697 
> > bands       1 
> > lower left origin.x        731453 
> > lower left origin.y        4712471 
> > res.x       1 
> > res.y       1 
> > ysign       -1 
> > oblique.x   0 
> > oblique.y   0 
> > driver      GTiff 
> > projection  +proj=utm +zone=18 +datum=WGS84 +units=m +no_defs 
> > file        data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif 
> > apparent band summary:
> >    GDType hasNoDataValue NoDataValue blockSize1 blockSize2
> > 1 Float64           TRUE       -9999          1       1697
> > apparent band statistics:
> >         Bmin      Bmax     Bmean       Bsd
> > 1 -0.7136298 0.9999997 0.3125525 0.4812939
> > Metadata:
> > AREA_OR_POINT=Area 
> > ~~~
> > {: .output}
> > 1. If this file has the same CRS as DSM_HARV?  Yes: UTM Zone 18, WGS84, meters.
> > 2. What format `NoDataValues` take?  -9999
> > 3. The resolution of the raster data? 1x1
> > 4. How large a 5x5 pixel area would be? 5mx5m How? We are given resolution of 1x1 and units in meters, therefore resolution of 5x5 means 5x5m.
> > 5. Is the file a multi- or single-band raster?  Single.
> {: .solution}
{: .challenge}

> ## More Resources
> * [Read more about the `raster` package in R.](http://cran.r-project.org/package=raster)
{: .callout}


{% include links.md %}