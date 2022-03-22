---
title: "Introduction to vector data"
teaching: 20
exercises: 10
questions:
- "How can I distinguish between and visualize point, line and polygon vector data?"
objectives:
- "Know the difference between point, line, and polygon vector elements."
- "Load point, line, and polygon shapefiles with `geopandas`."
- "Access the attributes of a spatial object with `geopandas`."
keypoints:
- "Shapefile metadata include geometry type, CRS, and extent."
- "Load spatial objects into Python with the `geopandas.read_file()` method."
- "Spatial objects can be plotted directly with `geopandas.GeoDataFrame.plot()`."
---

## Things You’ll Need To Complete This Episode
> See the [lesson homepage]({{ site.baseurl }}) for detailed information about the software,
> data, and other prerequisites you will need to work through the examples in this episode.
{: .prereq}

Starting with this episode, we will be moving from working with raster
data to working with vector data. In this episode, we will open and plot point, line and polygon vector data
stored in shapefile format in Python.

The data we will use comes from the Dutch government's open geodata sets obtained from the [PDOK platform](https://www.pdok.nl/).

In later episodes, we will learn how to work with raster and vector data together and combine them into a single plot.

## Import Shapefiles

```python
import geopandas as gpd
```

The shapefiles that we will import are:

* A polygon shapefile representing our crop field site boundaries.
* A line shapefile representing waterways.
* A point shapefile representing the location of groundwater monitoring wells.

First let us download and read the crop field dataset, with the following:
```python
# Load all crop field boundaries (brpgewaspercelen)
cropfield = gpd.read_file("https://service.pdok.nl/rvo/brpgewaspercelen/atom/v1_0/downloads/brpgewaspercelen_definitief_2020.gpkg")
```

This may take a couple of minutes to complete, as the dataset is somewhat large. It contains all the crop field data for the entirety of the European portion of the Netherlands.


## Shapefile Metadata & Attributes

When we import the shapefile into Python (as our `cropfield` object) it comes in as a `DataFrame`, specifically a `GeoDataFrame`. `read_file()` also automatically stores
geospatial information about the data. We are particularly interested in describing the format, CRS, extent, and other components of
the vector data, and the attributes which describe properties associated
with each individual vector object.

> ## Data Tip
> The [Explore and Plot by Shapefile Attributes]({{site.baseurl}}/10-vector-shapefile-attributes/)
> episode provides more information on both metadata and attributes
> and using attributes to subset and plot data.
{: .callout}

## Spatial Metadata
Key metadata for all shapefiles include:

1. **Object Type:** the class of the imported object.
2. **Coordinate Reference System (CRS):** the projection of the data.
3. **Extent:** the spatial extent (i.e. geographic area that the shapefile covers) of
the shapefile. Note that the spatial extent for a shapefile represents the combined
extent for all spatial objects in the shapefile.

Each `GeoDataFrame` has a `"geometry"` column that contains geometries. In the case of our `cropfield`  object, this geometry is represented by a `shapely.geometry.Polygon` object. `geopandas` uses the `shapely` library to represent polygons, lines, and points, so the types are inherited from `shapely`.

We can view shapefile metadata using the `.crs`, `.bounds` and `.type` attributes. First, let's view the
geometry type for our crop field shapefile. To view the geometry type, we use the `pandas` method `.type` function on the `GeoDataFrame` object, `cropfield`.

~~~
cropfield.type
~~~
{: .language-python}
~~~
0         Polygon
1         Polygon
2         Polygon
3         Polygon
4         Polygon
           ...   
619994    Polygon
619995    Polygon
619996    Polygon
619997    Polygon
619998    Polygon
Length: 619999, dtype: object
~~~
{: .output}

To view the CRS metadata:


~~~
cropfield.crs
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

Our data is in the CRS **RD New**. The CRS is critical to 
interpreting the object's extent values as it specifies units. To find
the extent of our dataset in the projected coordinates, we can use the `.total_bounds` function: 

~~~
cropfield.total_bounds
~~~
{: .language-python}

~~~
array([ 13653.6128, 306851.867 , 277555.288 , 612620.9868])
~~~
{: .output}

This array contains, in order, the values for minx, miny, maxx and maxy, for the overall dataset. The spatial extent of a shapefile or `shapely` spatial object represents the geographic "edge" or location that is the furthest north, south, east, and west. Thus, it is represents the overall geographic coverage of the spatial object. Image Source: National Ecological Observatory Network (NEON).

![Extent image](../fig/dc-spatial-vector/spatial_extent.png)

We can convert these coordinates to a bounding box or acquire the index of the dataframe to access the geometry. Either of these polygons can be used to clip rasters (more on that later). 

## Reading a Shapefile from a csv

So far we have been loading file formats that were specifically built to hold spatial information. But often, point data is stored in table format, with a column for the x coordinates and a column for the y coordinates. The easiest way to get this type of data into a GeoDataFrame is with the `geopandas` function `geopandas.points_from_xy`, which takes list-like sequences of x and y coordinates. In this case, we can get these list-like sequences from columns of a pandas `DataFrame` that we get from `read_csv`.

```python
# we get the projection of the point data from our Canopy Height Model, 
# after examining the pandas DataFrame and seeing that the CRSs are the same
import rioxarray
CHM_HARV <-
  rioxarray.open("data/NEON-DS-Airborne-Remote-Sensing/HARV/CHM/HARV_chmCrop.tif")

# plotting locations in CRS coordinates using CHM_HARV's CRS
plot_locations_HARV =
  pd.read_csv("data/NEON-DS-Site-Layout-Files/HARV/HARV_PlotLocations.csv")
plot_locations_HARV = gpd.GeoDataFrame(plot_locations_HARV, 
                    geometry=gpd.points_from_xy(plot_locations_HARV.easting, plot_locations_HARV.northing), 
                    crs=CHM_HARV.rio.crs)
```

## Plotting a Shapefile
Our `cropfield` dataset is rather large, containing data for the entirety of the European portion of the Netherlands. Before plotting it we will first select a specific section of to be our area of interest.

We can create a cropped version of our dataset as follows:
```python
# Define a Boundingbox in RD
xmin, xmax = (120000, 135000)
ymin, ymax = (485000, 500000)
cropfield_crop = cropfield.cx[xmin:xmax, ymin:ymax]
```

This will cut out a smaller area, defined by a box in units of the projection, discarding the rest of the data. The resultant GeoDataframe is found in the `cropfield_crop` object. We can check the total bounds of this new data as before:

~~~
cropfield_crop.total_bounds
~~~
{: .language-python}

~~~
array([119594.384 , 485036.2543, 135169.9266, 500782.531 ])
~~~
{: .output}

We can now plot this data. Any `GeoDataFrame` can be plotted in CRS units to view the shape of the object with `.plot()`.

```{r}
cropfield_crop.plot()
```

We can customize our boundary plot by setting the 
`figsize`, `edgecolor`, and `color`. Making some polygons transparent will come in handy when we need to add multiple spatial datasets to a single plot.

```python
cropfield_crop.plot(figsize=(5,5), edgecolor="purple", facecolor="None")
```

Under the hood, `geopandas` is using `matplotlib` to generate this plot. In the next episode we will see how we can add `DataArrays` and other shapefiles to this plot to start building an informative map of our area of interest.

## Spatial Data Attributes
We introduced the idea of spatial data attributes in [an earlier lesson]({{site.baseurl}}/02-intro-to-vector-data). Now we will explore
how to use spatial data attributes stored in our data to plot
different features.



> ## Challenge: Import Line and Point Shapefiles
> 
> Using the steps above, import the waterways and groundwater well layers into
> Python using `geopandas`. Name the shapefiles as the variables `waterways_nl` and `wells_nl` respectively.
> 
> Answer the following questions:
> 
> 1. What type of Python spatial object is created when you import each layer? 
> 
> 2. What is the CRS and extent (bounds) for each object?
> 
> 3. Do the files contain points, lines, or polygons?
> 
> 4. How many spatial objects are in each file?
> 
> > ## Answers
> > 
> > First we import the data: 
> > ```python
> > waterways_nl = gpd.read_file("https://geo.rijkswaterstaat.nl/services/ogc/gdr/vaarweginformatie/ows?service=WFS&version=2.0.0&request=GetFeature&typeName=status_vaarweg&outputFormat=SHAPE-ZIP")
> > wells_nl = gpd.read_file("https://service.pdok.nl/bzk/brogmwvolledigeset/atom/v2_1/downloads/brogmwvolledigeset.zip")
> > ```
> > 
> > Then we check the types: 
> > ```python
> > waterways_nl.type
> > ```
> > ```
> > ```
> > ```python
> > wells_nl.type
> > ```
> > We also check the CRS and extent of each object: 
> > ```{r}
> > print(waterways_nl.crs)
> > print(wells_nl.total_bounds)
> > print(waterways_nl.crs)
> > print(wells_nl.total_bounds)
> > ```
> > To see the number of objects in each file, we can look at the output from when we print the results in a Jupyter notebook of call `len()` on a `GeoDataFrame`. 
> > `waterways_nl` contains 91 features (all lines) and `wells_nl` contains 51664 points.
> {: .solution}
{: .challenge}

{% include links.md %}

