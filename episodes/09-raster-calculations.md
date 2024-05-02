---
title: "Raster Calculations in Python"
teaching: 60
exercises: 15
---

:::questions
- How do I perform calculations on rasters and extract pixel values for defined locations?
:::

:::objectives
- Carry out operations with two rasters using Python's built-in math operators.
:::

## Introduction

We often want to combine values of and perform calculations on rasters to create a new output raster. This episode
covers how to perform basic math operations using raster datasets. It also illustrates how to match rasters with
different resolutions so that they can be used in the same calculation. As an example, we will calculate
[a binary classification mask](https://custom-scripts.sentinel-hub.com/sentinel-2/burned_area_ms/) to identify burned
area over a satellite scene.

The classification mask requires the following of [the Sentinel-2 bands](https://gisgeography.com/sentinel-2-bands-combinations/)
(and derived indices):

* [Normalized difference vegetation index (NDVI)](https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index),
  derived from the **near-infrared (NIR)** and **red** bands:

$$ NDVI = \frac{NIR - red}{NIR + red} $$

* [Normalized difference water index (NDWI)](https://en.wikipedia.org/wiki/Normalized_difference_water_index), derived
  from the **green** and **NIR** bands:

$$ NDWI = \frac{green - NIR}{green + NIR} $$

* A custom index derived from two of the **short-wave infrared (SWIR)** bands (with wavelenght ~1600 nm and ~2200 nm,
  respectively):

$$ INDEX = \frac{SWIR_{16} - SWIR_{22}}{SWIR_{16} + SWIR_{22}}$$

* The **blue**, **NIR**, and **SWIR** (1600 nm) bands.

In the following, we start by computing the NDVI.

### Load and crop the Data
For this episode, we will use one of the Sentinel-2 scenes that we have already employed in the previous episodes.

:::callout

## Introduce the Data

We'll continue from the results of the satellite image search that we have carried out in an exercise from
[a previous episode](05-access-data.md). We will load data starting from the `search.json` file.

If you would like to work with the data for this lesson without downloading data on-the-fly, you can download the
raster data using this [link](https://figshare.com/ndownloader/files/36028100). Save the `geospatial-python-raster-dataset.tar.gz`
file in your current working directory, and extract the archive file by double-clicking on it or by running the
following command in your terminal `tar -zxvf geospatial-python-raster-dataset.tar.gz`. Use the file `geospatial-python-raster-dataset/search.json`
(instead of `search.json`) to get started with this lesson.

:::

Let's load the results of our initial imagery search using `pystac`:

```python
import pystac
items = pystac.ItemCollection.from_file("rhodes_sentinel-2.json")
```

We then select the first item, and extract the URLs of the red and NIR bands ("red" and "nir", respectively):

```python
item = items[0]
red_href = item.assets["red"].get_absolute_href()
nir_href = item.assets["nir"].get_absolute_href()
```

Let's load the rasters with `open_rasterio` using the argument `masked=True`.

```python
import rioxarray
red = rioxarray.open_rasterio(red_href, masked=True)
nir = rioxarray.open_rasterio(nir_href, masked=True)
```

Let’s also restrict our analysis to the island of Rhodes - we can extract the bounding box from the vector file written
in an earlier episode (note that we need to match the CRS to the one of the raster files):

```python
# determine bounding box of Rhodes, in the projected CRS
import geopandas
rhodes = geopandas.read_file('rhodes.gpkg')
rhodes_reprojected = rhodes.to_crs(red.rio.crs)
bbox = rhodes_reprojected.total_bounds

# crop the rasters
red_clip = red.rio.clip_box(*bbox)
nir_clip = nir.rio.clip_box(*bbox)
```

We can now plot the two rasters. Using `robust=True` color values are stretched between the 2nd and 98th percentiles of
the data, which results in clearer distinctions between high and low reflectances:

```python
red_clip.plot(robust=True)
```

![](fig/E09/red-band.png){alt="red band image"}

```python
nir_clip.plot(robust=True)
```

![](fig/E09/NIR-band.png){alt="near infra-red band image"}

The burned area is immediately evident as a dark spot in the NIR wavelength, due to the lack of reflection from the
vegetation in the scorched area.

## Raster Math

We can perform raster calculations by subtracting (or adding,
multiplying, etc.) two rasters. In the geospatial world, we call this
"raster math", and typically it refers to operations on rasters that
have the same width and height (including `nodata` pixels).
We can check the shapes of the two rasters in the following way:

```python
print(red_clip.shape, nir_clip.shape)
```

```output
(1, 1131, 1207) (1, 1131, 1207)
```

The shapes of the two rasters match (and, not shown, the coordinates and the CRSs match too).

Let's now compute the NDVI as a new raster using the formula presented above.
We'll use `DataArray` objects so that we can easily plot our result and keep
track of the metadata.

```python
ndvi = (nir_clip - red_clip)/ (nir_clip + red_clip)
print(ndvi)
```

```output
<xarray.DataArray (band: 1, y: 1131, x: 1207)>
array([[[0., 0., 0., ..., 0., 0., 0.],
        [0., 0., 0., ..., 0., 0., 0.],
        [0., 0., 0., ..., 0., 0., 0.],
        ...,
        [0., 0., 0., ..., 0., 0., 0.],
        [0., 0., 0., ..., 0., 0., 0.],
        [0., 0., 0., ..., 0., 0., 0.]]], dtype=float32)
Coordinates:
  * band         (band) int64 1
  * x            (x) float64 5.615e+05 5.616e+05 ... 6.097e+05 6.098e+05
  * y            (y) float64 4.035e+06 4.035e+06 4.035e+06 ... 3.99e+06 3.99e+06
    spatial_ref  int64 0
```

We can now plot the output NDVI:

```python
ndvi.plot()
```

![](fig/E09/NDVI-map.png){alt="NDVI map"}

Notice that the range of values for the output NDVI is between -1 and 1.
Does this make sense for the selected region?

Maps are great, but it can also be informative to plot histograms of values to better understand the distribution. We can accomplish this using a built-in xarray method we have already been using: `plot.hist()`

```python
ndvi.plot.hist()
```

![](fig/E09/NDVI-hist.png){alt="NDVI histogram"}

:::challenge

### Exercise: NDWI and custom index to detect burned areas

Calculate the other two indices required to compute the burned area classification mask, specifically:

* The [normalized difference water index (NDWI)](https://en.wikipedia.org/wiki/Normalized_difference_water_index), derived from the **green** and **NIR** bands (with band ID "green" and "nir", respectively):

$$ NDWI = \frac{green - NIR}{green + NIR} $$

* A custom index derived from the  1600 nm and the 2200 nm **short-wave infrared (SWIR)** bands ( "swir16" and "swir22", respectively):

$$ INDEX = \frac{SWIR_{16} - SWIR_{22}}{SWIR_{16} + SWIR_{22}}$$

What challenge do you foresee in combining the data from the two indices?

::::solution

```python
def get_band_and_clip(item, band_name, bbox):
    href = item.assets[band_name].get_absolute_href()
    band = rioxarray.open_rasterio(href, masked=True)
    return band.rio.clip_box(*bbox)
```


```python
green_clip = get_band_and_clip(item, 'green', bbox)
swir16_clip = get_band_and_clip(item, 'swir16', bbox)
swir22_clip = get_band_and_clip(item, 'swir22', bbox)
```


```python
ndwi = (green_clip - nir_clip)/(green_clip + nir_clip)
index = (swir16_clip - swir22_clip)/(swir16_clip + swir22_clip)
```

```python
ndwi.plot(robust=True)
```

![](fig/E09/NDWI.png){alt="NDWI index"}

```python
index.plot(robust=True)
```

![](fig/E09/custom-index.png){alt="custom index"}

The challenge in combining the different indices is that the SWIR bands (and thus the derived custom index) have lower resolution:

```python
ndvi.rio.resolution(), ndwi.rio.resolution(), index.rio.resolution()
```

```output
((10.0, -10.0), (10.0, -10.0), (20.0, -20.0))
```

::::

:::

In order to combine data from the computed indices, we use the `reproject_match` method, which reprojects, clips and
match the resolution of a raster using another raster as a template. We use the `index` raster as a template, and match
`ndvi` and `ndwi` to its resolution and extent:


```python
ndvi_match = ndvi.rio.reproject_match(index)
ndwi_match = ndwi.rio.reproject_match(index)
```

Finally, we also fetch the blue band data and match this and the NIR band data to the template:

```python
blue_clip = get_band_and_clip(item, 'blue', bbox)
blue_match = blue_clip.rio.reproject_match(index)
nir_match = nir_clip.rio.reproject_match(index)
```

We can now go ahead and compute the binary classification mask for burned areas. Note that we need to convert the unit
of the Sentinel-2 bands [from digital numbers to reflectance](https://docs.sentinel-hub.com/api/latest/data/sentinel-2-l2a/#units)
(this is achieved by dividing by 10,000):

```python
burned = (
    (ndvi_match <= 0.3) &
    (ndwi_match <= 0.1) &
    ((index + nir_match/10_000) <= 0.1) &
    ((blue_match/10_000) <= 0.1) &
    ((swir16_clip/10_000) >= 0.1)
)
```

The classification mask has a single element along the "band" axis, we can drop this dimension in the following way:

```python
burned = burned.squeeze()
```

Let's now fetch and visualize the true color image of Rhodes, after coloring the pixels identified as burned area in red:

```python
visual_href = item.assets['visual'].get_absolute_href()
visual = rioxarray.open_rasterio(visual_href)
visual_clip = visual.rio.clip_box(*bbox)
```


```python
# set red channel to max (255), green and blue channels to min (0).
visual_clip[0] = visual_clip[0].where(~burned, 255)
visual_clip[1:3] = visual_clip[1:3].where(~burned, 0)
```

```python
visual_clip.plot.imshow()
```

![](fig/E09/visual-burned-index.png){alt="RGB image with burned area in red"}


We can save the burned classification mask to disk after converting booleans to integers:

```python
burned.rio.to_raster('burned.tif', dtype='int8')
```

:::keypoints
- Python's built-in math operators are fast and simple options for raster math.
:::
