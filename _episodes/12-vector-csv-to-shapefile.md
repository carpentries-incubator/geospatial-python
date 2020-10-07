---
title: "Convert from .csv to a Shapefile in Python"
teaching: 40
exercises: 20
questions:
- "How can I import CSV files as shapefiles in Python?"
objectives:
- "Import .csv files containing x,y coordinate locations as a GeoDataFrame."
- "Export a spatial object to a .shp file."
keypoints:
- "Know the projection (if any) of your point data prior to converting to a spatial object."
- "This projection information can be used to convert a text file with spatial columns into a shapefile (or GeoJSON) with geopandas."

---
```python
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
```

```python
# Learners will have this data loaded from earlier episodes
lines_HARV = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HARV_roads.shp")
aoi_boundary_HARV = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HarClip_UTMZ18.shp")
country_boundary_US = gpd.read_file("data/NEON-DS-Site-Layout-Files/US-Boundary-Layers/US-Boundary-Dissolved-States.shp")
point_HARV = gpd.read_file("data/NEON-DS-Site-Layout-Files/HARV/HARVtower_UTM18N.shp")
```

> ## Things You’ll Need To Complete This Episode
>
> See the [lesson homepage]({{ site.baseurl }}) for detailed information about the software,
> data, and other prerequisites you will need to work through the examples in this episode.
{: .prereq}

This episode will review how to import spatial points stored in `.csv` (Comma Separated Value) format into Python as a `geopandas` `GeoDataFrame`. We will also reproject data imported from a shapefile format, export this data as a shapefile, and plot raster and vector data as layers in the same plot.

## Spatial Data in Text Format

The `HARV_PlotLocations.csv` file contains `x, y` (point) locations for study
plot where NEON collects data on
[vegetation and other ecological metrics](https://www.neonscience.org/data-collection/terrestrial-organismal-sampling).
We would like to:

* Create a map of these plot locations.
* Export the data in a `shapefile` format to share with our colleagues. This
shapefile can be imported into any GIS software.
* Create a map showing vegetation height with plot locations layered on top.

Spatial data are sometimes stored in a text file format (`.txt` or `.csv`). If
the text file has an associated `x` and `y` or `lat` and `lon` location column, then we can
convert the tabular text file into a `geopandas.GeoDataFrame`. This will have a column containing the point geometry. The `GeoDataFrame` allows us to store both the `x,y` values that represent the coordinate location
of each point and the associated attribute data - or columns describing each
feature in the spatial object.

We will continue using the `pandas`, `geopandas` and `rasterio` packages in this episode.

## Import .csv
To begin let's import a `.csv` file that contains plot coordinate `x, y`
locations at the NEON Harvard Forest Field Site (`HARV_PlotLocations.csv`) and look at the structure of
that new object:

```python
plot_locations_HARV = pd.read_csv("data/NEON-DS-Site-Layout-Files/HARV/HARV_PlotLocations.csv")

plot_locations_HARV.info()
```
We now have a data frame that contains 21 locations (rows) and 16 variables (attributes). Next, let's explore the `DataFrame` to determine whether it contains columns with coordinate values. If we are lucky, our `.csv` will contain columns labeled:

 * "X" and "Y" OR
 * Latitude and Longitude OR
 * easting and northing (UTM coordinates)

Let's check out the column names of our `DataFrame`.

```python
plot_locations_HARV.columns
```
## Identify X,Y Location Columns

Our column names include several fields that might contain spatial information. The `plot_locations_HARV["easting"]`
and `plot_locations_HARV["northing"]` columns contain coordinate values. We can confirm
this by looking at the first five rows of our data.


```python 
print(plot_locations_HARV["easting"].head())

print(plot_locations_HARV["northing"].head())
```
We have coordinate values in our data frame. In order to convert our
`DataFrame` to a `GeoDataFrame`, we also need to know the CRS
associated with those coordinate values.

There are several ways to figure out the CRS of spatial data in text format.

1. We can infer from the range of numbers in the coordinate column if the values represent latitude/longitude (in which case, we can use a WGS84 projection) or another coordinate system.
2. If the values are not in latitude/longitude, we can check the file metadata, which may be in a separate file or listed somewhere in the text file itself. The file header or separate data columns are possible locations for CRS related storing metadata.

Following the `easting` and `northing` columns, there is a `geodeticDa` and a
`utmZone` column. These appear to contain CRS information
(`datum` and `projection`). Let's view those next.

```python
print(plot_locations_HARV["geodeticDa"].head())
print(plot_locations_HARV["utmZone"].head())
```
The `geodeticDa` and `utmZone` columns
contain the information that helps us determine the CRS:

* `geodeticDa`: WGS84  -- this is geodetic datum WGS84
* `utmZone`: 18

In
[When Vector Data Don't Line Up - Handling Spatial Projection & CRS in Python]({{site.baseurl}}/09-vector-when-data-dont-line-up-crs/)
we learned about the components of a `proj4` string. We have everything we need
to assign a CRS to our data frame.

To create the `proj4` associated with UTM Zone 18 WGS84 we can look up the
projection on the [Spatial Reference website](http://www.spatialreference.org/ref/epsg/wgs-84-utm-zone-18n/), which contains a list of CRS formats for each projection. From here, we can extract the [proj4 string for UTM Zone 18N WGS84](http://www.spatialreference.org/ref/epsg/wgs-84-utm-zone-18n/proj4/).

However, if we have other data in the UTM Zone 18N projection, it's much
easier to use the `.crs` method to extract the CRS in `proj4` format from that GeoDataFrame and
assign it to our
new GeoDataFrame. We've seen this CRS before with our Harvard Forest study site (`point_HARV`).

```python
point_HARV.crs
```
The output above shows that the points shapefile is in
UTM zone 18N. We can thus use the CRS from that spatial object to convert our
non-spatial `DataFrame` into an `GeoDataFrame` with point geometry.

Next, let's create a `crs` object that we can use to define the CRS of our
`GeoDataFrame` when we create it.

```python 
utm18nCRS = point_HARV.crs
utm18nCRS
```
## .csv to GeoDataFrame
Next, let's convert our `DataFrame` into a `GeoDataFrame` To do
this, we need to specify:

1. The columns containing X (`easting`) and Y (`northing`) coordinate values
2. The CRS that the column coordinate represent (units are included in the CRS) - stored in our `utmCRS` object.

We will use the `points_from_xy()` function to perform the conversion.

```python
plot_locations_HARV_gdf = gpd.GeoDataFrame(plot_locations_HARV, geometry=gpd.points_from_xy(plot_locations_HARV.easting, plot_locations_HARV.northing), crs=utm18nCRS)
```
We should double check the CRS to make sure it is correct.

```python
plot_locations_HARV_gdf.crs
```
## Plot Spatial Object
We now have a `GeoDataFrame`, we can plot our newly created spatial object.
```python
fig, ax = plt.subplots()
plot_locations_HARV_gdf.plot(ax=ax)
plt.title("Map of Plot Locations")
plt.show()
```
## Plot Extent

In
[Open and Plot Shapefiles in Python]({{site.baseurl}}/06-vector-open-shapefile-in-python/)
we learned about `GeoDataFrame` extent. When we plot several spatial layers in
Python using `matplotlib`, all of the layers of the plot are considered in setting the boundaries
of the plot. To show this, let's plot our `aoi_boundary_HARV` object with our vegetation plots.

```python
fig, ax = plt.subplots()
plot_locations_HARV_gdf.plot(ax=ax)
aoi_boundary_HARV.plot(ax=ax, facecolor="None", edgecolor="orange")
plt.title("AOI Boundary Plot")
plt.show()
```

> ## Challenge - Import & Plot Additional Points
>
> We want to add two phenology plots to our existing map of vegetation plot locations.
>
> Import the .csv: `data/NEON-DS-Site-Layout-Files/HARV/HARV_2NewPhenPlots.csv` and do the following:
>
> 1. Find the X and Y coordinate locations. Which value is X and which value is Y?
> 2. These data were collected in a geographic coordinate system (WGS84). Convert
> the dataframe into an `geopandas.GeoDataFrame`.
> 3. Plot the new points with the plot location points from above. Be sure to add
> a legend. Use a different symbol for the 2 new points!
> 
> > ## Answers
> > ```python
> > newplot_locations_HARV = pd.read_csv("data/NEON-DS-Site-Layout-Files/HARV/HARV_2NewPhenPlots.csv")
> > newplot_locations_HARV.info()
> > ```
> >
> > ```python
> > geogCRS = country_boundary_US.crs
> > geogCRS
> > ```
> >
> > ```python
> > newplot_locations_HARV_gdf = gpd.GeoDataFrame(newplot_locations_HARV, geometry=gpd.points_from_xy(newplot_locations_HARV.decimalLon, newplot_locations_HARV.decimalLat), crs=geogCRS)
> > ```
> >
> > ```python
> > newplot_locations_HARV_gdf.crs
> > ```
> >
> > ```python
> > fig, ax = plt.subplots()
> > plot_locations_HARV_gdf.plot(ax=ax)
> > newplot_locations_HARV_gdf.to_crs(plot_locations_HARV_gdf.crs).plot(ax=ax, color="orange")
> > plt.title("Map of All Plot Locations")
> > plt.show()
> >```
> >
> > ```python
> > plot_locations_HARV_gdf.to_file("data/NEON-DS-Site-Layout-Files/HARV/plot_locations_HARV_gdf.shp", driver="ESRI Shapefile")
> > ```
> {: .solution}
{: .challenge}

{% include links.md %}