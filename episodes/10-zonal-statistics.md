---
title: "Calculating Zonal Statistics on Rasters"
teaching: 40
exercises: 0
---

:::questions
- How to compute raster statistics on different zones delineated by vector data?
:::

:::objectives
- Extract zones from the vector dataset
- Convert vector data to raster
- Calculate raster statistics over zones
:::

 


## Introduction

Statistics on predefined zones of the raster data are commonly used for analysis and to better understand the data. These zones are often provided within a single vector dataset, identified by certain vector attributes. For example, in the previous episodes, we defined infrastructure regions and built-up regions on Rhodes Island as polygons. Each region can be respectively identified as a "zone", resulting in two zones. One can evualuate the effect of the wild fire on the two zones by calculating the zonal statistics.


## Data loading

We have created `assets.gpkg` in Episode "Vector data in Python",  which contains the infrastructure regions and built-up regions . We also calculated the burned index in Episode "Raster Calculations in Python" and saved it in `burned.tif`. Lets load them:

```python
# Load burned index
import rioxarray
burned = rioxarray.open_rasterio('burned.tif')

# Load assests polygons
import geopandas as gpd
assets = gpd.read_file('assets.gpkg')
```

## Align datasets

Before we continue, let's check if the two datasets are in the same CRS:

```python
print(assets.crs)
print(burned.rio.crs)
```

```output
EPSG:4326
EPSG:32635
```

The two datasets are in different CRS. Let's reproject the assets to the same CRS as the burned index raster:

```python
assets = assets.to_crs(burned.rio.crs)
```

## Rasterize the vector data

One way to define the zones, is to create a grid space with the same extent and resolution as the burned index raster, and with the numerical values in the grid representing the type of infrastructure, i.e., the zones. This can be done by rasterize the vector data `assets` to the grid space of `burned`.

Let's first take two elements from `assets`, the geometry column, and the code of the region.

```python
geom = assets[['geometry', 'code']].values.tolist()
geom
```

```output
[[<POLYGON ((602761.27 4013139.375, 602764.522 4013072.287, 602771.476 4012998...>,
  1],
 [<POLYGON ((602779.808 4013298.838, 602772.497 4013266.01, 602768.577 4013242...>,
  1],
 [<POLYGON ((602594.855 4012962.661, 602593.423 4012983.028, 602588.485 401302...>,
  1],
  ...]
```

The raster image `burned` is a 3D image with a "band" dimension.

```python
burned.shape
```

```output
(1, 4523, 4828)
```

To create the grid space, we only need the two spatial dimensions. We can used `.squeeze()` to drop the band dimension:

```python
burned_squeeze = burned.squeeze()
burned_squeeze.shape
```

```output
(4523, 4828)
```

Now we can use `features.rasterize` from `rasterio` to rasterize the vector data `assets` to the grid space of `burned`:

```python
from rasterio import features
assets_rasterized = features.rasterize(geom, out_shape=burned_squeeze.shape, transform=burned.rio.transform())
assets_rasterized
```

```output
array([[0, 0, 0, ..., 0, 0, 0],
       [0, 0, 0, ..., 0, 0, 0],
       [0, 0, 0, ..., 0, 0, 0],
       ...,
       [0, 0, 0, ..., 0, 0, 0],
       [0, 0, 0, ..., 0, 0, 0],
       [0, 0, 0, ..., 0, 0, 0]], dtype=uint8)
```

## Perform zonal statistics

The rasterized zones `assets_rasterized` is a `numpy` array. The Python package `xrspatial`, which is the one we will use for zoning statistics, accepts `xarray.DataArray`. We need to first convert  `assets_rasterized`. We can use `burned_squeeze` as a template:

```python
assets_rasterized_xarr = burned_squeeze.copy()
assets_rasterized_xarr.data = assets_rasterized
assets_rasterized_xarr.plot()
```

![](fig/E10/zones_rasterized_xarray.png){alt="Rasterized zones"}

Then we can calculate the zonal statistics using the `zonal_stats` function:

```python
from xrspatial import zonal_stats
stats = zonal_stats(assets_rasterized_xarr, burned_squeeze)
stats
```

```output
   zone      mean  max  min       sum       std       var       count
0     0  0.023504  1.0  0.0  485164.0  0.151498  0.022952  20641610.0
1     1  0.010361  1.0  0.0    9634.0  0.101259  0.010253    929853.0
2     2  0.000004  1.0  0.0       1.0  0.001940  0.000004    265581.0
```

The results provide statistics for three zones: `1` represents infrastructure regions, `2` represents built-up regions, and `0` represents the rest of the area.


:::keypoints
- Zones can be extracted by attribute columns of a vector dataset
- Zones can be rasterized using `rasterio.features.rasterize`
- Calculate zonal statistics with `xrspatial.zonal_stats` over the rasterized zones.
:::
