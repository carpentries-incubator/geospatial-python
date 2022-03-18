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

#These data refer to the [NEON Harvard Forest field site](https://www.neonscience.org/field-sites/field-sites-map/HARV), which we have been working with in previous
#episodes.
The data we will use comes from the Dutch government's open geodata set on [crop fields](https://www.pdok.nl/introductie/-/article/basisregistratie-gewaspercelen-brp-).

In later episodes, we will learn how to work with raster and vector data together and combine them into a single plot.

## Import Shapefiles

We will use the `geopandas` package to work with vector data in Python. We will also use the
`rioxarray`. 

```python
import geopandas as gpd
```

The shapefiles that we will import are:

* A polygon shapefile representing our field site boundary
* A line shapefile representing roads
* A point shapefile representing the location of the [Fisher flux tower](https://www.neonscience.org/data-collection/flux-tower-measurements)
located at the [NEON Harvard Forest field site](https://www.neonscience.org/field-sites/field-sites-map/HARV)

The first shapefile that we will open contains the boundary of our study area
(or our Area Of Interest [AOI], hence the name `aoi_boundary`). To import
shapefiles we use the `geopandas` function `read_file()`.

Let's import our AOI:

```python
aoi_boundary_HARV = gpd.read_file(
  "data/NEON-DS-Site-Layout-Files/HARV/HarClip_UTMZ18.shp")
```

## Shapefile Metadata & Attributes

When we import the `HarClip_UTMZ18` shapefile layer into Python (as our
`aoi_boundary_HARV` object) it comes in as a DataFrame, specifically a `GeoDataFrame`. `read_file()` also automatically stores
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

Each `GeoDataFrame` has a `"geometry"` column that contains geometries. In the case of our `aoi_boundary_HARV`, this geometry is represented by a `shapely.geometry.Polygon` object. `geopandas` uses the `shapely` library to represent polygons, lines, and points, so the types are inherited from `shapely`.

We can view shapefile metadata using the `.crs`, `.bounds` and `.type` attributes. First, let's view the
geometry type for our AOI shapefile. To view the geometry type, we use the `pandas` method `.type` function on the `GeoDataFrame`, `aoi_boundary_HARV`.

~~~
aoi_boundary_HARV.type
~~~
{: .language-python}
~~~
0    Polygon
dtype: object
~~~
{: .output}

To view the CRS metadata:


~~~
aoi_boundary_HARV.crs
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

Our data is in the CRS **UTM zone 18N**. The CRS is critical to 
interpreting the object's extent values as it specifies units. To find
the extent of our AOI in the projected coordinates, we can use the `.bounds()` function: 

~~~
aoi_boundary_HARV.bounds
~~~
{: .language-python}

~~~
            minx          miny           maxx          maxy
0  732128.016925  4.713209e+06  732251.102892  4.713359e+06
~~~
{: .output}

The spatial extent of a shapefile or `shapely` spatial object represents the geographic "edge" or location that is the furthest north, south, east, and west. Thus, it is represents the overall geographic coverage of the spatial object. Image Source: National Ecological Observatory Network (NEON).

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

Any `GeoDataFrame` can be plotted in CRS units to view the shape of the object with `.plot()`.

```{r}
aoi_boundary_HARV.plot()
```

We can customize our boundary plot by setting the 
`figsize`, `edgecolor`, and `color`. Making some polygons transparent will come in handy when we need to add multiple spatial datasets to a single plot.

```python
aoi_boundary_HARV.plot(figsize=(5,5), edgecolor="purple", facecolor="None")
```

Under the hood, `geopandas` is using `matplotlib` to generate this plot. In the next episode we will see how we can add `DataArrays` and other shapefiles to this plot to start building an informative map of our area of interest.

## Spatial Data Attributes
We introduced the idea of spatial data attributes in [an earlier lesson]({{site.baseurl}}/02-intro-to-vector-data). Now we will explore
how to use spatial data attributes stored in our data to plot
different features.



> ## Challenge: Import Line and Point Shapefiles
> 
> Using the steps above, import the HARV_roads and HARVtower_UTM18N layers into
> Python using `geopandas`. Name the HARV_roads shapefile as the variable `lines_HARV` and the HARVtower_UTM18N shapefile
> `point_HARV`.
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
> > lines_HARV = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HARV_roads.shp")
> > point_HARV = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HARVtower_UTM18N.shp")
> > ```
> > 
> > Then we check the types: 
> > ```python
> > lines_HARV.type
> > ```
> > ```
> > ```
> > ```python
> > point_HARV.type
> > ```
> > We also check the CRS and extent of each object: 
> > ```{r}
> > print(lines_HARV.crs)
> > print(point_HARV.bounds)
> > print(lines_HARV.crs)
> > print(point_HARV.bounds)
> > ```
> > To see the number of objects in each file, we can look at the output from when we print the results in a Jupyter notebook of call `len()` on a `GeoDataFrame`. 
> > `lines_HARV` contains 13 features (all lines) and `point_HARV` contains only one point. 
> {: .solution}
{: .challenge}

{% include links.md %}

