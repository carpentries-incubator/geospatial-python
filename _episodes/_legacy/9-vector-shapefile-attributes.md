---
title: "Explore and Plot by Shapefile Attributes"
teaching: 40
exercises: 20
questions:
- "How can I compute on the attributes of a spatial object?"
objectives:
- "Query attributes of a spatial object."
- "Subset spatial objects using specific attribute values."
- "Plot a shapefile, colored by unique attribute values."
keypoints:
- "A `GeoDataFrame` in `geopandas` is similar to standard `pandas` data frames and can be manipulated using the same functions."
- "Almost any feature of a plot can be customized using the various functions and options in the `matplotlib` package."
---

```python
# learners will have this data loaded from previous episodes
point_HARV = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HARVtower_UTM18N.shp")
lines_HARV = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HARV_roads.shp")
aoi_boundary_HARV = gpd.read_file(
  "data/NEON-DS-Site-Layout-Files/HARV/HarClip_UTMZ18.shp")
```

> ## Things You’ll Need To Complete This Episode
> See the [lesson homepage]({{ site.baseurl }}) for detailed information about the software,
> data, and other prerequisites you will need to work through the examples in this episode.
{: .prereq}

This episode continues our discussion of shapefile attributes and 
covers how to work with shapefile attributes in Python. It covers how
to identify and query shapefile
attributes, as well as how to subset shapefiles by specific attribute values.
Finally, we will learn how to plot a shapefile according to a set of attribute
values.

## Load the Data
We will continue using the `geopandas`, and `rioxarray` and `matplotlib.pyplot` packages in this episode. Make sure that you have these packages loaded. We will
continue to work with the three shapefiles that we loaded in the
[Open and Plot Shapefiles in R]({{site.baseurl}}/09-vector-open-shapefile/) episode.

## Query Shapefile Metadata

As we discussed in the
[Open and Plot Shapefiles in R]({{site.baseurl}}/09-vector-open-shapefile/) episode,
we can view metadata associated with a `GeoDataFrame` using:

* `.type` - The type of vector data stored in the object.
* `len` - The number of features in the object
* `.bounds` - The spatial extent (geographic area covered by) 
of the object.
* `.crs` - The CRS (spatial projection) of the data.

We started to explore our `point_HARV` object in the previous episode.
We can view the object with `point_HARV` or print a summary of the object itself to the console.

```python
point_HARV
```

We view the columns in `lines_HARV` with `.columns` to count the number of attributes associated with a spatial object too. Note that the geometry is just another column and counts towards the total.

```python
lines_HARV.columns
```


> ## Challenge: Attributes for Different Spatial Classes
>
> Explore the attributes associated with the `point_HARV` and `aoi_boundary_HARV` spatial objects.
>
> 1. How many attributes does each have?
> 2. Who owns the site in the `point_HARV` data object?
> 3. Which of the following is NOT an attribute of the `point_HARV` data object?
>
>     A) Latitude      B) County     C) Country
>
> > ## Answers
> > 1) To find the number of attributes, we use the `len()` and `.columns` attribute: 
> > 
> > ```python
> > print(len(point_HARV.columns))
> > print(len(aoi_boundary_HARV.columns))
> > ```
> > 2) Ownership information is in a column named `Ownership`: 
> > ```python
> > point_HARV.Ownership
> > ```
> > 3) To see a list of all of the attributes, we can use the
> > `.columns` method: 
> > ```python
> > point_HARV.columns
> > ```
> > "Country" is not an attribute of this object. 
> {: .solution}
{: .challenge}

## Explore Values within One Attribute
We can explore individual values stored within a particular attribute.
Comparing attributes to a spreadsheet or a data frame, this is similar
to exploring values in a column. We did this with the `gapminder` dataframe in [an earlier lesson](https://rbavery/geosptial-python.github.io/gapminder.git). For `GeoDataFrames`, we can use the same syntax: `GeoDataFrame.attributeName` or `GeoDataFrame["attributeName"]`.

We can see the contents of the `TYPE` field of our lines shapefile:

```python
lines_HARV.TYPE
```

To see only unique values within the `TYPE` field, we can use the
`np.unique()` function for extracting the possible values of a
categorical (or numerical) variable.
```python
np.unique(lines_HARV.TYPE)
```

### Subset Shapefiles
We can use the `filter()` function from `dplyr` that we worked with in [an earlier lesson](https://datacarpentry.org/r-intro-geospatial/06-dplyr) to select a subset of features
from a spatial object in Python, just like with data frames.

For example, we might be interested only in features that are of `TYPE` "footpath". Once we subset out this data, we can use it as input to other code so that code only operates on the footpath lines.

```python
footpath_HARV = lines_HARV[lines_HARV.TYPE == "footpath"]
len(footpath_HARV)
```

Our subsetting operation reduces the `features` count to 2. This means
that only two feature lines in our spatial object have the attribute
`TYPE == footpath`. We can plot only the footpath lines:

```python
footpath_HARV.plot()
```

There are two features in our footpaths subset. Why does the plot look like
there is only one feature? Let's adjust the colors used in our plot. If we have
2 features in our vector object, we can plot each using a unique color by
assigning a color map, or `cmap` to each geometry/row in our `GeoDataFrame`. 
We can also alter the default line thickness by using the `size =` parameter, 
as the default value can be hard to see. 

```python
footpath_HARV.plot(cmap="viridis", linewidth=4)
```

Now, we see that there are in fact two features in our plot!

> ## Challenge: Subset Spatial Line Objects Part 1
> 
> Subset out all `woods road` from the lines layer and plot it.
> There are many more color maps to use, so if you'd like, do a web search to 
> find a matplotlib `cmap` that works better for this plot than `viridis`.
> 
> > ## Answers
> > 
> > First we will save an object with only the boardwalk lines:
> > ```python
> > woods_road_HARV = lines_HARV[lines_HARV.TYPE == "woods_road_HARV"]
> > ```
> > Let's check how many features there are in this subset: 
> > ```python
> > len(woods_road_HARV)
> > ```
> > Now let's plot that data: 
> > ```python
> > woods_road_HARV.plot(cmap="viridis", linewidth=3)
> > ```
> > 
> {: .solution}
{: .challenge}


### Adjust Line Width
We adjusted line color by applying an arbitrary color map earlier. If we want a unique line color for each attribute category
in our `GeoDataFrame`, we can use the following argument, `column`, as well as some style arguments to improv ethe visuals.

We already know that we have four different `TYPE` levels in the lines_HARV object, so we will set four different line colors.

```python
import matplotlib.pyplot as plt
plt.style.use("ggplot")
lines_HARV.plot(column="TYPE", linewidth=3, legend=True, figsize=(16,10))
```

Our map is starting together, in the next lesson we will add our Canopy Height Model that we calculated in an earlier episode.

> ## Challenge: Plot Polygon by Attribute
>
> 1. Create a map of the state boundaries in the United States using the data
> located in your downloaded data folder: `NEON-DS-Site-Layout-Files/US-Boundary-Layers\US-State-Boundaries-Census-2014`.
> Apply a fill color to each state using its `region` value. Add a legend.
>
> > ## Answers
> > First we read in the data and check how many levels there are
> > in the `region` column:
> > ```python
> > state_boundary_US =
> > gpd.read_file("data/NEON-DS-Site-Layout-Files/US-Boundary-Layers/US-State-Boundaries-Census-2014.shp")
> > 
> > np.unique(state_boundary_US.region)
> > ```
> >
> > Now we can create our plot: 
> > ```python
> > state_boundary_US.plot(column = "region", linewidth = 2, legend = True, figsize=(20,5))
> > ```
> {: .solution}
{: .challenge}


{% include links.md %}

