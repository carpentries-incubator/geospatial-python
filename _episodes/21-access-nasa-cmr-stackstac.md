---
title: "Create Monthly NDVI composites using Harmonized Landsat Sentinel (HLS) data from NASA CMR STAC api using pystac_client & stackstac"
teaching: TODO
exercises: TODO
questions:
- "How do I select an AOI?"
- "How to access Harmonized Landsat Sentinel (HLS) data from NASA CMR STAC catalog?"
- "How to parallelize the access of data using dask & stackstac?"
objectives:
- TODO
keypoints:
- TODO
---

# Create Monthly NDVI composites using Harmonized Landsat Sentinel (HLS) data from NASA CMR STAC api using `pystac_client` & `stackstac`

In this tutorial we will do the following tasks:

1. Use leafmap to select an Area of Interest (AOI) and save it as a geojson
2. Explore NASA CMR STAC API using `pystac_client` CLI & Python API
3. Understand & visualize the availability of Harmonized Landsat Sentinel (HLS) data for an AOI
4. Use `dask` and `stackstac` to pull data efficiently
5. Load the data as lazy `xarrays`, filter by cloudcover, compute NDVI & create monthly composites
6. Visualize the evolution of beautiful crop circles over time

Before starting this tutorial make sure you signed-up for https://urs.earthdata.nasa.gov/ & have a `.netrc` file configured. If not please [run this script](https://git.earthdata.nasa.gov/projects/LPDUR/repos/daac_data_download_python/browse/EarthdataLoginSetup.py) before proceeding any further.


```python
# Import all the packages we will be using in our workflow
import json
import warnings
import os
from pathlib import Path

import leafmap
import geopandas as gpd
import pandas as pd
import matplotlib.pyplot as plt
import rasterio as rio
import stackstac
import xarray as xr
from dask import distributed
from geojson_rewind import rewind
from osgeo import gdal
from pystac_client import Client
from IPython import display

warnings.filterwarnings('ignore')
```

### Set GDAL configuration to successfully access LP DAAC Cloud Assets


```python
rio_env = rio.Env(GDAL_DISABLE_READDIR_ON_OPEN='TRUE',
                  GDAL_HTTP_COOKIEFILE=os.path.expanduser('~/cookies.txt'),
                  GDAL_HTTP_COOKIEJAR=os.path.expanduser('~/cookies.txt'))
rio_env.__enter__()
```




    <rasterio.env.Env at 0x10604a700>



Create a `Path` object to `DATA` and look what we have inside it. We have a default `aoi.geojson` file that points to somewhere near Egypt's Thoshka Projekt. You can choose to use the default file or create your own AOI


```python
DATA = Path('data')
!ls {DATA}
```

    egypt-thoska-project.geojson


# Select an AOI

We will use `leafmap` to select an AOI & save it as GeoJSON inside the `data/` folder. For reference on how to do this using leafmap please check the create_vector notebook: https://leafmap.org/notebooks/45_create_vector/


```python
import leafmap.leafmap as leafmap
```


```python
m = leafmap.Map(center=(31.5, 22.5), zoom=8,
                draw_control=True, measure_control=False, fullscreen_control=False, attribution_control=True)
m
```


    Map(center=[31.5, 22.5], controls=(ZoomControl(options=['position', 'zoom_in_text', 'zoom_in_title', 'zoom_out…


We can check if our newly created AOI is saved inside the `data/` folder. Here I saving it as `aoi.geojson`.


```python
!ls {DATA}
```

    aoi.geojson                  egypt-thoska-project.geojson



```python
# Hack: Leaflet saves polygons in a clockwise manner in Feature Collection. We can fix this using `geojson_rewind`
aoi = json.load((DATA/"aoi.geojson").open("r"))
aoi = rewind(aoi)
json.dump(aoi, (DATA/"aoi.geojson").open("w"))
aoi
```




    {'type': 'FeatureCollection',
     'features': [{'type': 'Feature',
       'properties': {},
       'geometry': {'type': 'Polygon',
        'coordinates': [[[31.198854, 22.476446],
          [31.460311, 22.476446],
          [31.460311, 22.707661],
          [31.198854, 22.707661],
          [31.198854, 22.476446]]]}}]}



# NASA CMR STAC

NASA's Common Metadata Repository (CMR) is a metadata catalog of NASA Earth Science data. STAC, or SpatioTemporal Asset Catalog, is a specification for describing geospatial data with JSON and GeoJSON. The related STAC-API specification defines an API for searching and browsing STAC catalogs.

To know more about STAC & ARCO data formats please visit https://stacindex.org/ and https://pangeo-forge.readthedocs.io/en/latest/


```python
# NASA CMR STAC URL
CMR_STAC_URL = "https://cmr.earthdata.nasa.gov/stac"
providers = Client.open(CMR_STAC_URL)
```

### Sub Catalog

NASA CMR STAC base catalog has a list of sub-catalog such as NOAA, JAXA, LPCLOUD etc. Let us list them down here for reference.


```python
for provider in providers.get_children():
    print(provider.title)
```

    LARC_ASDC
    USGS_EROS
    ESA
    GHRC
    LAADS
    OBPG
    OB_DAAC
    ECHO
    ISRO
    LPCUMULUS
    EDF_DEV04
    GES_DISC
    ASF
    OMINRT
    EUMETSAT
    NCCS
    NSIDCV0
    PODAAC
    LARC
    USGS
    SCIOPS
    LANCEMODIS
    CDDIS
    JAXA
    AU_AADC
    ECHO10_OPS
    LPDAAC_ECS
    NSIDC_ECS
    ORNL_DAAC
    LM_FIRMS
    SEDAC
    LANCEAMSR2
    NOAA_NCEI
    USGS_LTA
    GESDISCCLD
    GHRSSTCWIC
    ASIPS
    ESDIS
    POCLOUD
    NSIDC_CPRD
    ORNL_CLOUD
    FEDEO
    MLHUB
    XYZ_PROV
    GHRC_DAAC
    CSDA
    NRSCC
    CEOS_EXTRA
    MOPITT
    GHRC_CLOUD
    LPCLOUD
    CCMEO


### We will use the Harmonised Landsat Sentinel (HLS) data available under `LPCLOUD` Sub-Catalog

HLS consists of input data from the joint NASA/USGS Landsat 8 and the ESA (European Space Agency) Sentinel-2A and Sentinel-2B satellites to generate a harmonized, analysis-ready surface reflectance data product with observations every two to three days.

# Access NASA CMR STAC LPCLOUD API using `pystac_client`

We will look at using both the python-client & CLI of `pystac_client` to access STAC data.

## 1. `pystac_client` CLI

Here we are searching for tiles in collection "HLSS30.v2.0" & "HLSL30.v2.0" that intersects our defined AOI. We are defining the date-range between Jan-2019 to Jan-2022 & saving the results inside `data/aoi-catalog.json`


```python
!stac-client search 'https://cmr.earthdata.nasa.gov/stac/LPCLOUD' \
    --collection HLSS30.v2.0 HLSL30.v2.0 \
    --intersects {DATA/'aoi.geojson'} \
    --datetime 2019-01-01/2022-01-31 > data/aoi-catalog.json
```

Now, we can look manually inside the raw json file which has details about each tile like properties, bounds, assets etc.

We can also use [`stacterm`](https://github.com/stac-utils/stac-terminal) which is a library for displaying information (tables, calendars, plots, histograms) about STAC Items in the terminal to get a sense of the data coverage in our AOI.

### List down the days on which we have HLS data available

TODO: Fix calender rendering by stacterm

```python
!cat data/aoi-catalog.json | stacterm cal
```

                                  2019

          January               February               March
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
       [42m 1[0m  2  3  4  5  6               1 [42m 2[0m  3               1  2  3
     7  8  9 10 11 12 13   4  5  6  7  8  9 10   4  5 [42m 6[0m  7  8  9 10
    14 15 16 [42m17[0m 18 19 20  11 12 13 14 15 16 17  11 12 13 14 15 16 17
    21 22 23 24 25 26 27  [42m18[0m 19 20 21 22 23 24  18 19 20 21 [42m22[0m 23 24
    28 29 30 31           25 26 27 28           25 26 27 28 29 30 31

           April                  May                   June
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
     1  2  3  4  5  6 [42m 7[0m         1  2  3  4  5                  1  2
     8  9 10 11 12 13 14   6  7  8 [42m 9[0m 10 11 12   3  4  5  6  7  8  9
    15 16 17 18 19 20 21  13 14 15 16 17 18 19  [42m10[0m 11 12 13 14 15 16
    22 [42m23[0m 24 25 26 27 28  20 21 22 23 24 [42m25[0m 26  17 18 19 20 21 22 23
    29 30                 27 28 29 30 31        24 25 [42m26[0m 27 28 29 30

            July                 August              September
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
     1  2  3  4  5  6  7            1  2  3  4                     1
     8  9 10 11 [42m12[0m 13 14   5  6  7  8  9 10 11   2  3  4  5  6  7  8
    15 16 17 18 19 20 21  12 [42m13[0m 14 15 16 17 18   9 10 11 12 13 [42m14[0m 15
    22 23 24 25 26 27 [42m28[0m  19 20 21 22 23 24 25  16 17 18 19 20 21 22
    29 30 31              26 27 28 [42m29[0m 30 31     23 24 25 26 27 28 29

          October               November              December
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
        1  2  3  4  5  6              [42m 1[0m  2  3                     1
     7  8  9 10 11 12 13   4  5  6  7  8  9 10   2 [42m 3[0m  4  5  6  7  8
    14 15 [42m16[0m 17 18 19 20  11 12 13 14 15 16 [42m17[0m   9 10 11 12 13 14 15
    21 22 23 24 25 26 27  18 19 20 21 22 23 24  16 17 18 [42m19[0m 20 21 22
    28 29 30 31           25 26 27 28 29 30     23 24 25 26 27 28 29

                                  2020

          January               February               March
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
           1  2  3 [42m 4[0m  5                  1  2                     1
     6  7  8  9 10 11 12   3  4 [42m 5[0m  6  7  8  9   2  3  4  5  6  7 [42m 8[0m
    13 14 15 16 17 18 19  10 11 12 13 14 15 16   9 10 11 12 13 14 15
    [42m20[0m 21 22 23 24 25 26  17 18 19 20 [42m21[0m 22 23  16 17 18 19 20 21 22
    27 28 29 30 31        24 25 26 27 28 29     23 [42m24[0m 25 26 27 28 29

           April                  May                   June
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
           1  2  3  4  5               1  2  3   1  2  3  4  5  6  7
     6  7  8 [42m 9[0m 10 11 12   4  5  6  7  8  9 10   8  9 10 11 [42m12[0m 13 14
    13 14 15 16 17 18 19  [42m11[0m 12 13 14 15 16 17  15 16 17 18 19 20 21
    20 21 22 23 24 [42m25[0m 26  18 19 20 21 22 23 24  22 23 24 25 26 27 [42m28[0m
    27 28 29 30           25 26 [42m27[0m 28 29 30 31  29 30

            July                 August              September
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
           1  2  3  4  5                  1  2      1  2  3  4  5  6
     6  7  8  9 10 11 12   3  4  5  6  7  8  9   7  8  9 10 11 12 13
    13 [42m14[0m 15 16 17 18 19  10 11 12 13 14 [42m15[0m 16  14 15 [42m16[0m 17 18 19 20
    20 21 22 23 24 25 26  17 18 19 20 21 22 23  21 22 23 24 25 26 27
    27 28 29 [42m30[0m 31        24 25 26 27 28 29 30  28 29 [43m30[0m

          October               November              December
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
              1 [41m 2[0m  3  4                    [43m 1[0m     [43m 1[0m  2  3 [43m 4[0m [42m 5[0m [43m 6[0m
    [43m 5[0m  6 [43m 7[0m  8  9 [43m10[0m 11   2  3 [43m 4[0m  5 [43m 6[0m  7  8   7  8 [43m 9[0m 10 [43m11[0m 12 13
    [43m12[0m 13 14 [43m15[0m 16 [43m17[0m [42m18[0m  [43m 9[0m 10 [43m11[0m 12 13 [43m14[0m 15  [43m14[0m 15 [43m16[0m 17 18 [43m19[0m 20
    19 [43m20[0m 21 [43m22[0m 23 24 [43m25[0m  [43m16[0m 17 18 [41m19[0m 20 [43m21[0m 22  [41m21[0m 22 23 [43m24[0m 25 [43m26[0m 27
    26 [43m27[0m 28 29 [43m30[0m 31     23 [43m24[0m 25 [43m26[0m 27 28 [43m29[0m  28 [43m29[0m 30 [43m31[0m

                                  2021

          January               February               March
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
                 1  2 [43m 3[0m   1 [43m 2[0m  3 [43m 4[0m  5  6 [41m 7[0m  [43m 1[0m  2  3 [43m 4[0m  5 [43m 6[0m  7
     4 [43m 5[0m [42m 6[0m  7 [43m 8[0m  9 [43m10[0m   8 [43m 9[0m 10 11 [43m12[0m 13 [43m14[0m   8 [43m 9[0m 10 [41m11[0m 12 13 [43m14[0m
    11 12 [43m13[0m 14 [43m15[0m 16 17  15 16 [43m17[0m 18 [43m19[0m 20 21  15 [43m16[0m 17 18 [43m19[0m 20 [43m21[0m
    [43m18[0m 19 [43m20[0m 21 [42m22[0m [43m23[0m 24  [43m22[0m [42m23[0m [43m24[0m 25 26 [43m27[0m 28  22 23 [43m24[0m 25 [43m26[0m [42m27[0m 28
    [43m25[0m 26 27 [43m28[0m 29 [43m30[0m 31                        [43m29[0m 30 [43m31[0m

           April                  May                   June
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
              1  2 [43m 3[0m  4                  1  2      1 [43m 2[0m  3 [43m 4[0m  5  6
    [43m 5[0m  6  7 [43m 8[0m  9 [43m10[0m 11  [43m 3[0m  4 [43m 5[0m  6  7 [43m 8[0m  9  [43m 7[0m  8 [43m 9[0m 10 11 [43m12[0m 13
    [42m12[0m [43m13[0m 14 [43m15[0m 16 17 [43m18[0m  [43m10[0m 11 12 [43m13[0m [42m14[0m [43m15[0m 16  [43m14[0m [42m15[0m 16 [43m17[0m 18 [43m19[0m 20
    19 [43m20[0m 21 22 [43m23[0m 24 [43m25[0m  17 [43m18[0m 19 [43m20[0m 21 22 [43m23[0m  21 [43m22[0m 23 [43m24[0m 25 26 [43m27[0m
    26 27 [41m28[0m 29 [43m30[0m        24 [43m25[0m 26 27 [43m28[0m 29 [41m30[0m  28 [43m29[0m 30

            July                 August              September
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
             [42m 1[0m [43m 2[0m  3 [43m 4[0m                    [43m 1[0m         1 [43m 2[0m [42m 3[0m  4 [43m 5[0m
     5  6 [43m 7[0m  8 [43m 9[0m 10 11  [42m 2[0m [43m 3[0m  4  5 [43m 6[0m  7 [43m 8[0m   6 [43m 7[0m  8  9 [43m10[0m 11 [43m12[0m
    [43m12[0m 13 [43m14[0m 15 16 [41m17[0m 18   9 10 [43m11[0m 12 [43m13[0m 14 15  13 14 [43m15[0m 16 [43m17[0m 18 [42m19[0m
    [43m19[0m 20 21 [43m22[0m 23 [43m24[0m 25  [43m16[0m 17 [41m18[0m 19 20 [43m21[0m 22  [43m20[0m 21 [43m22[0m 23 24 [43m25[0m 26
    26 [43m27[0m 28 [43m29[0m 30 31     [43m23[0m 24 25 [43m26[0m 27 [43m28[0m 29  [43m27[0m 28 29 [43m30[0m

          October               November              December
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
                 1 [43m 2[0m  3  [43m 1[0m  2  3 [43m 4[0m  5 [41m 6[0m  7        [43m 1[0m  2  3 [43m 4[0m  5
     4 [41m 5[0m  6 [43m 7[0m  8  9 [43m10[0m   8  9 10 [43m11[0m 12 13 [43m14[0m  [43m 6[0m  7 [42m 8[0m [43m 9[0m 10 [43m11[0m 12
    11 [43m12[0m 13 14 [43m15[0m 16 [43m17[0m  15 [43m16[0m 17 18 [43m19[0m 20 [43m21[0m  13 14 15 [43m16[0m 17 18 [43m19[0m
    18 19 [43m20[0m [42m21[0m [43m22[0m 23 24  [42m22[0m 23 [43m24[0m 25 [43m26[0m 27 28  20 [43m21[0m 22 23 [41m24[0m 25 [43m26[0m
    [43m25[0m 26 [43m27[0m 28 29 [43m30[0m 31  [43m29[0m 30                 27 28 [43m29[0m 30 [43m31[0m

                                  2022

          January               February               March
    Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su
                    1  2      1  2  3  4  5  6      1  2  3  4  5  6
    [43m 3[0m  4 [43m 5[0m  6  7 [43m 8[0m [42m 9[0m   7  8  9 10 11 12 13   7  8  9 10 11 12 13
    [43m10[0m 11 12 [43m13[0m 14 [43m15[0m 16  14 15 16 17 18 19 20  14 15 16 17 18 19 20
    17 [43m18[0m 19 [43m20[0m 21 22 [43m23[0m  21 22 23 24 25 26 27  21 22 23 24 25 26 27
    24 [41m25[0m 26 27 [43m28[0m 29 [43m30[0m  28                    28 29 30 31
    31

    collection:
      [41mMultiple [0m
      [42mHLSL30.v2.0 [0m
      [43mHLSS30.v2.0 [0m



> We have data from only HLSL30 (Landsat) collection available till Aug 2020, HLSS30 (Sentinel) collection starts appearing from Sept, 2020. We can also represent the same data in a tabular manner by applying filter & sort functions.


```python
!cat data/aoi-catalog.json | stacterm table \
    --fields collection date eo:cloud_cover \
    --sort eo:cloud_cover | head -20
```

    | collection  | date       | eo:cloud_cover |
    |-------------|------------|----------------|
    | HLSS30.v2.0 | 2022-01-30 | 0              |
    | HLSS30.v2.0 | 2021-12-01 | 0              |
    | HLSS30.v2.0 | 2021-03-31 | 0              |
    | HLSS30.v2.0 | 2021-03-31 | 0              |
    | HLSS30.v2.0 | 2021-03-29 | 0              |
    | HLSS30.v2.0 | 2021-12-04 | 0              |
    | HLSS30.v2.0 | 2021-03-26 | 0              |
    | HLSS30.v2.0 | 2021-03-26 | 0              |
    | HLSS30.v2.0 | 2021-12-04 | 0              |
    | HLSS30.v2.0 | 2021-03-21 | 0              |
    | HLSS30.v2.0 | 2021-03-21 | 0              |
    | HLSS30.v2.0 | 2021-03-19 | 0              |
    | HLSS30.v2.0 | 2021-03-19 | 0              |
    | HLSS30.v2.0 | 2021-03-16 | 0              |
    | HLSS30.v2.0 | 2021-03-11 | 0              |
    | HLSS30.v2.0 | 2021-03-11 | 0              |
    | HLSL30.v2.0 | 2021-03-11 | 0              |
    | HLSL30.v2.0 | 2021-03-11 | 0              |
    Exception ignored in: <_io.TextIOWrapper name='<stdout>' mode='w' encoding='utf-8'>
    BrokenPipeError: [Errno 32] Broken pipe


## 2. `pystac_client` Python API

Connect to the LPCLOUD CMR catalog & look at the list of available collections.


```python
catalog = Client.open(f'{CMR_STAC_URL}/LPCLOUD')

collections = catalog.get_children()
for collection in collections:
    print(collection.id, collection.title)
```

    ASTGTM.v003 ASTER Global Digital Elevation Model V003
    HLSL30.v2.0 HLS Landsat Operational Land Imager Surface Reflectance and TOA Brightness Daily Global 30m v2.0
    HLSS30.v2.0 HLS Sentinel-2 Multi-spectral Instrument Surface Reflectance Daily Global 30m v2.0


> We will be using the HLSL30.v2.0 & HLSS30.v2.0 collections in this notebook

### Query the STAC catalog to access HLS data separately for Sentinel & Landsat data

We can also pass in a `query` or `filter` parameter to the `search` function to further filter down the item search results. STAC catalog search API gives us options to filter results based on spatio-temporal factors.


```python
s30 = catalog.search(
        collections=['HLSS30.v2.0'],
        intersects=aoi['features'][0]['geometry'],
        datetime='2019-01-01/2022-01-31',
)
l30 = catalog.search(
        collections=['HLSL30.v2.0'],
        intersects=aoi['features'][0]['geometry'],
        datetime='2019-01-01/2022-01-31',
)
```


```python
s30.matched(), l30.matched()
```




    (387, 140)



> 387 tiles of HLSS30 collection available for our AOI between Jan-2019 - Jan-2022
> 140 tiles of HLSL30 collection available for our AOI between Jan-2019 - Jan-2022

Read the filtered results & call `to_dict()` on them that stores them as `feature collections`


```python
s30_tiles, l30_tiles = s30.get_all_items(), l30.get_all_items()
s30_tiles_json, l30_tiles_json = s30_tiles.to_dict(), l30_tiles.to_dict()
```


```python
display.JSON(s30_tiles_json)
```




    <IPython.core.display.JSON object>




```python
display.JSON(l30_tiles_json)
```




    <IPython.core.display.JSON object>



### Plot the tile boundaries of HLSS30 & HLSL30 collection & our AOI

Convert the `geojsons` into `GeoDataFrames` to visualize inside Leafmap. Use the layers icon to filter different tiles & hover over to look at the properties.


```python
s30_tiles_gdf = gpd.GeoDataFrame.from_features(s30_tiles_json, crs="EPSG:4326")
l30_tiles_gdf = gpd.GeoDataFrame.from_features(l30_tiles_json, crs="EPSG:4326")
aoi_gdf = gpd.GeoDataFrame.from_features(aoi["features"], crs="EPSG:4326")

m = leafmap.Map(center=(40, -74), zoom=9)
m.add_gdf(s30_tiles_gdf, layer_name="Sentinel Tiles", fill_colors=["red"])
m.add_gdf(l30_tiles_gdf, layer_name="Landsat Tiles", fill_colors=["blue"])
m.add_gdf(aoi_gdf, layer_name="AOI", fill_colors=["black"], zoom_to_layer=False)
m
```


    Map(center=[40, -74], controls=(ZoomControl(options=['position', 'zoom_in_text', 'zoom_in_title', 'zoom_out_te…


# Story so far

We used `pystac_client` to query all the tiles from HLSS30 & HLSL30 collections with in our defined spatial & temporal extent.

We want to create montly NDVI composites over our AOI. To do this we have to
- Go over each tile in the collection result from previous steps
- Download the required assets i.e NIR & Red bands
- Clip the tiles to AOI
- Compute NDVI & create a montly composite

**OR**

We can take advantage of STAC & COGs structures in NASA CMR API and use `stackstac` along with `dask` to compute montly NDVI composites over the AOI in an efficient manner without downloading & processing all the tiles.

# Stackstac

`stackstac` converts STAC collections into lazy `xarrays`. It can read STAC metadata into xarray coordinates, that helps in indexing, filtering and computing aggregations over the dataset.

`stackstac` can also use `dask` to perform the computations parallely.

For this example, we will create a local `dask` cluster to perform our `stackstac` operations. You can easily replace this with a cluster in the cloud to speed up the operations.

`Dask` has a nice UI that lets you visualize each step in the process and also provides information on compute & data usage. Visit the dashboard link to see more details.


```python
cluster = distributed.LocalCluster()
client = distributed.Client(cluster)
client.dashboard_link
```




    'http://127.0.0.1:8787/status'




```python
# Configure GDAL options to access COGs from Earthdata system
dist_env = stackstac.DEFAULT_GDAL_ENV.updated(dict(
    GDAL_DISABLE_READDIR_ON_OPEN='TRUE',
    GDAL_HTTP_COOKIEFILE=os.path.expanduser('~/cookies.txt'),
    GDAL_HTTP_COOKIEJAR=os.path.expanduser('~/cookies.txt'))
)
```

# Monthly NDVI composites

We are trying to create monthly NDVI composites from Jan 2019 - Jan 2022 for defined AOI, in this case Thoshka Projekt, Egypt. We will need `NIR` & `Red` bands to compute NDVI from Sentinel & Landsat HLS Imagery.

**Sentinel 2**:
 - "narrow" NIR = B8A
 - Red = B04

**Landsat 8**:
 - NIR = B05
 - Red = B04

`stackstac` can convert the STAC items into lazy xarray's. We can then use them to filter by cloud cover, clip to our defined AOI, compute monthly composite etc.

Here, we define the `bbox` of our AOI, `bands` (NIR, Red) we need & the resolution of imagery to access.


```python
bbox = tuple(map(float, aoi_gdf.bounds.values[0]))

s30_stack = stackstac.stack(
    s30_tiles,
    assets=['B8A', 'B04'],
    bounds_latlon=bbox,
    resolution=30,
    epsg=32636,
    gdal_env=dist_env
)
l30_stack = stackstac.stack(
    l30_tiles,
    assets=['B05', 'B04'],
    bounds_latlon=bbox,
    resolution=30,
    epsg=32636,
    gdal_env=dist_env
)
```

> Great, that's all there is to `stackstac`. Now we have a lazy xarray & can perform all the operations on top of it. Note: All the operations are perfomed on the metadata & actual computation happens only when you call the `persists()` or `compute()` method on lazy xarray object.

#### Fix the band mis-match in Sentinel & Landsat data


```python
s30_stack.coords['band'] = ['nir', 'red']
l30_stack.coords['band'] = ['nir', 'red']
```

#### Combine both into a single stack


```python
stack = xr.concat((s30_stack, l30_stack), dim='time').sortby("time")
stack.data
```




<table>
    <tr>
        <td>
            <table>
                <thead>
                    <tr>
                        <td> </td>
                        <th> Array </th>
                        <th> Chunk </th>
                    </tr>
                </thead>
                <tbody>

                    <tr>
                        <th> Bytes </th>
                        <td> 6.15 GiB </td>
                        <td> 5.98 MiB </td>
                    </tr>

                    <tr>
                        <th> Shape </th>
                        <td> (527, 2, 864, 907) </td>
                        <td> (1, 1, 864, 907) </td>
                    </tr>
                    <tr>
                        <th> Count </th>
                        <td> 5271 Tasks </td>
                        <td> 1054 Chunks </td>
                    </tr>
                    <tr>
                    <th> Type </th>
                    <td> float64 </td>
                    <td> numpy.ndarray </td>
                    </tr>
                </tbody>
            </table>
        </td>
        <td>
        <svg width="462" height="179" style="stroke:rgb(0,0,0);stroke-width:1" >

  <!-- Horizontal lines -->
  <line x1="0" y1="0" x2="69" y2="0" style="stroke-width:2" />
  <line x1="0" y1="25" x2="69" y2="25" style="stroke-width:2" />

  <!-- Vertical lines -->
  <line x1="0" y1="0" x2="0" y2="25" style="stroke-width:2" />
  <line x1="2" y1="0" x2="2" y2="25" />
  <line x1="4" y1="0" x2="4" y2="25" />
  <line x1="6" y1="0" x2="6" y2="25" />
  <line x1="8" y1="0" x2="8" y2="25" />
  <line x1="10" y1="0" x2="10" y2="25" />
  <line x1="12" y1="0" x2="12" y2="25" />
  <line x1="15" y1="0" x2="15" y2="25" />
  <line x1="17" y1="0" x2="17" y2="25" />
  <line x1="19" y1="0" x2="19" y2="25" />
  <line x1="21" y1="0" x2="21" y2="25" />
  <line x1="23" y1="0" x2="23" y2="25" />
  <line x1="26" y1="0" x2="26" y2="25" />
  <line x1="28" y1="0" x2="28" y2="25" />
  <line x1="30" y1="0" x2="30" y2="25" />
  <line x1="32" y1="0" x2="32" y2="25" />
  <line x1="34" y1="0" x2="34" y2="25" />
  <line x1="36" y1="0" x2="36" y2="25" />
  <line x1="39" y1="0" x2="39" y2="25" />
  <line x1="41" y1="0" x2="41" y2="25" />
  <line x1="43" y1="0" x2="43" y2="25" />
  <line x1="45" y1="0" x2="45" y2="25" />
  <line x1="47" y1="0" x2="47" y2="25" />
  <line x1="50" y1="0" x2="50" y2="25" />
  <line x1="52" y1="0" x2="52" y2="25" />
  <line x1="54" y1="0" x2="54" y2="25" />
  <line x1="56" y1="0" x2="56" y2="25" />
  <line x1="58" y1="0" x2="58" y2="25" />
  <line x1="60" y1="0" x2="60" y2="25" />
  <line x1="63" y1="0" x2="63" y2="25" />
  <line x1="65" y1="0" x2="65" y2="25" />
  <line x1="67" y1="0" x2="67" y2="25" />
  <line x1="69" y1="0" x2="69" y2="25" style="stroke-width:2" />

  <!-- Colored Rectangle -->
  <polygon points="0.0,0.0 69.72436604189636,0.0 69.72436604189636,25.412616514582485 0.0,25.412616514582485" style="fill:#8B4903A0;stroke-width:0"/>

  <!-- Text -->
  <text x="34.862183" y="45.412617" font-size="1.0rem" font-weight="100" text-anchor="middle" >527</text>
  <text x="89.724366" y="12.706308" font-size="1.0rem" font-weight="100" text-anchor="middle" transform="rotate(0,89.724366,12.706308)">1</text>


  <!-- Horizontal lines -->
  <line x1="139" y1="0" x2="153" y2="14" style="stroke-width:2" />
  <line x1="139" y1="114" x2="153" y2="129" style="stroke-width:2" />

  <!-- Vertical lines -->
  <line x1="139" y1="0" x2="139" y2="114" style="stroke-width:2" />
  <line x1="146" y1="7" x2="146" y2="121" />
  <line x1="153" y1="14" x2="153" y2="129" style="stroke-width:2" />

  <!-- Colored Rectangle -->
  <polygon points="139.0,0.0 153.9485979497544,14.948597949754403 153.9485979497544,129.2595130544953 139.0,114.3109151047409" style="fill:#ECB172A0;stroke-width:0"/>

  <!-- Horizontal lines -->
  <line x1="139" y1="0" x2="259" y2="0" style="stroke-width:2" />
  <line x1="146" y1="7" x2="266" y2="7" />
  <line x1="153" y1="14" x2="273" y2="14" style="stroke-width:2" />

  <!-- Vertical lines -->
  <line x1="139" y1="0" x2="153" y2="14" style="stroke-width:2" />
  <line x1="259" y1="0" x2="273" y2="14" style="stroke-width:2" />

  <!-- Colored Rectangle -->
  <polygon points="139.0,0.0 259.0,0.0 273.9485979497544,14.948597949754403 153.9485979497544,14.948597949754403" style="fill:#ECB172A0;stroke-width:0"/>

  <!-- Horizontal lines -->
  <line x1="153" y1="14" x2="273" y2="14" style="stroke-width:2" />
  <line x1="153" y1="129" x2="273" y2="129" style="stroke-width:2" />

  <!-- Vertical lines -->
  <line x1="153" y1="14" x2="153" y2="129" style="stroke-width:2" />
  <line x1="273" y1="14" x2="273" y2="129" style="stroke-width:2" />

  <!-- Colored Rectangle -->
  <polygon points="153.9485979497544,14.948597949754403 273.9485979497544,14.948597949754403 273.9485979497544,129.2595130544953 153.9485979497544,129.2595130544953" style="fill:#ECB172A0;stroke-width:0"/>

  <!-- Text -->
  <text x="213.948598" y="149.259513" font-size="1.0rem" font-weight="100" text-anchor="middle" >907</text>
  <text x="293.948598" y="72.104056" font-size="1.0rem" font-weight="100" text-anchor="middle" transform="rotate(-90,293.948598,72.104056)">864</text>
  <text x="136.474299" y="141.785214" font-size="1.0rem" font-weight="100" text-anchor="middle" transform="rotate(45,136.474299,141.785214)">2</text>
</svg>
        </td>
    </tr>
</table>



#### Filter by cloud cover score


```python
cloudless = stack[stack['eo:cloud_cover'] < 10]
```

#### Compute NDVI for the AOI


```python
nir, red = cloudless.sel(band='nir'), cloudless.sel(band='red')
ndvi = (nir - red)/((nir + red) + 1e-10)
```

#### Monthy composite with median


```python
ndvi_monthly = ndvi.resample(time='M').median(dim='time')
ndvi_monthly.data
```




<table>
    <tr>
        <td>
            <table>
                <thead>
                    <tr>
                        <td> </td>
                        <th> Array </th>
                        <th> Chunk </th>
                    </tr>
                </thead>
                <tbody>

                    <tr>
                        <th> Bytes </th>
                        <td> 221.21 MiB </td>
                        <td> 5.98 MiB </td>
                    </tr>

                    <tr>
                        <th> Shape </th>
                        <td> (37, 864, 907) </td>
                        <td> (2, 432, 907) </td>
                    </tr>
                    <tr>
                        <th> Count </th>
                        <td> 10159 Tasks </td>
                        <td> 72 Chunks </td>
                    </tr>
                    <tr>
                    <th> Type </th>
                    <td> float64 </td>
                    <td> numpy.ndarray </td>
                    </tr>
                </tbody>
            </table>
        </td>
        <td>
        <svg width="199" height="183" style="stroke:rgb(0,0,0);stroke-width:1" >

  <!-- Horizontal lines -->
  <line x1="10" y1="0" x2="29" y2="19" style="stroke-width:2" />
  <line x1="10" y1="57" x2="29" y2="76" />
  <line x1="10" y1="114" x2="29" y2="133" style="stroke-width:2" />

  <!-- Vertical lines -->
  <line x1="10" y1="0" x2="10" y2="114" style="stroke-width:2" />
  <line x1="10" y1="0" x2="10" y2="114" />
  <line x1="11" y1="1" x2="11" y2="115" />
  <line x1="12" y1="2" x2="12" y2="116" />
  <line x1="13" y1="3" x2="13" y2="118" />
  <line x1="15" y1="5" x2="15" y2="119" />
  <line x1="16" y1="6" x2="16" y2="120" />
  <line x1="17" y1="7" x2="17" y2="121" />
  <line x1="18" y1="8" x2="18" y2="122" />
  <line x1="19" y1="9" x2="19" y2="123" />
  <line x1="20" y1="10" x2="20" y2="124" />
  <line x1="21" y1="11" x2="21" y2="125" />
  <line x1="22" y1="12" x2="22" y2="126" />
  <line x1="23" y1="13" x2="23" y2="127" />
  <line x1="24" y1="14" x2="24" y2="128" />
  <line x1="25" y1="15" x2="25" y2="129" />
  <line x1="26" y1="16" x2="26" y2="130" />
  <line x1="27" y1="17" x2="27" y2="131" />
  <line x1="28" y1="18" x2="28" y2="132" />
  <line x1="29" y1="19" x2="29" y2="133" style="stroke-width:2" />

  <!-- Colored Rectangle -->
  <polygon points="10.0,0.0 29.5612346709802,19.5612346709802 29.5612346709802,133.87214977572108 10.0,114.3109151047409" style="fill:#8B4903A0;stroke-width:0"/>

  <!-- Horizontal lines -->
  <line x1="10" y1="0" x2="130" y2="0" style="stroke-width:2" />
  <line x1="10" y1="0" x2="130" y2="0" />
  <line x1="11" y1="1" x2="131" y2="1" />
  <line x1="12" y1="2" x2="132" y2="2" />
  <line x1="13" y1="3" x2="133" y2="3" />
  <line x1="15" y1="5" x2="135" y2="5" />
  <line x1="16" y1="6" x2="136" y2="6" />
  <line x1="17" y1="7" x2="137" y2="7" />
  <line x1="18" y1="8" x2="138" y2="8" />
  <line x1="19" y1="9" x2="139" y2="9" />
  <line x1="20" y1="10" x2="140" y2="10" />
  <line x1="21" y1="11" x2="141" y2="11" />
  <line x1="22" y1="12" x2="142" y2="12" />
  <line x1="23" y1="13" x2="143" y2="13" />
  <line x1="24" y1="14" x2="144" y2="14" />
  <line x1="25" y1="15" x2="145" y2="15" />
  <line x1="26" y1="16" x2="146" y2="16" />
  <line x1="27" y1="17" x2="147" y2="17" />
  <line x1="28" y1="18" x2="148" y2="18" />
  <line x1="29" y1="19" x2="149" y2="19" style="stroke-width:2" />

  <!-- Vertical lines -->
  <line x1="10" y1="0" x2="29" y2="19" style="stroke-width:2" />
  <line x1="130" y1="0" x2="149" y2="19" style="stroke-width:2" />

  <!-- Colored Rectangle -->
  <polygon points="10.0,0.0 130.0,0.0 149.56123467098018,19.5612346709802 29.5612346709802,19.5612346709802" style="fill:#8B4903A0;stroke-width:0"/>

  <!-- Horizontal lines -->
  <line x1="29" y1="19" x2="149" y2="19" style="stroke-width:2" />
  <line x1="29" y1="76" x2="149" y2="76" />
  <line x1="29" y1="133" x2="149" y2="133" style="stroke-width:2" />

  <!-- Vertical lines -->
  <line x1="29" y1="19" x2="29" y2="133" style="stroke-width:2" />
  <line x1="149" y1="19" x2="149" y2="133" style="stroke-width:2" />

  <!-- Colored Rectangle -->
  <polygon points="29.5612346709802,19.5612346709802 149.56123467098018,19.5612346709802 149.56123467098018,133.87214977572108 29.5612346709802,133.87214977572108" style="fill:#ECB172A0;stroke-width:0"/>

  <!-- Text -->
  <text x="89.561235" y="153.872150" font-size="1.0rem" font-weight="100" text-anchor="middle" >907</text>
  <text x="169.561235" y="76.716692" font-size="1.0rem" font-weight="100" text-anchor="middle" transform="rotate(-90,169.561235,76.716692)">864</text>
  <text x="9.780617" y="144.091532" font-size="1.0rem" font-weight="100" text-anchor="middle" transform="rotate(45,9.780617,144.091532)">37</text>
</svg>
        </td>
    </tr>
</table>



#### Do the actual computation

With `stackstac` we are not pulling all the tiles into our machine (which would have been several GBs), but just a subset of it i.e our AOI. You can monitor the progress using the dask UI.


```python
data = ndvi_monthly.compute()
```

    /Users/srm/mambaforge/envs/geobox/lib/python3.9/site-packages/numpy/lib/nanfunctions.py:1218: RuntimeWarning: All-NaN slice encountered
      r, k = function_base._ureduce(a, func=_nanmedian, axis=axis, out=out,


#### Save the compute DataArray in NetCDF format


```python
data.to_netcdf('data/egypt-thoska-ndvi-egypt.nc')
```

#### Visualize the NDVI composites


```python
fig, axes = plt.subplots(nrows=3, ncols=12, figsize=(25,25))

for idx, ax in enumerate(axes.flatten()):
    datum = data.isel(time=idx)
    ax.imshow(datum, vmin=-1, vmax=1, cmap='RdYlGn')
    ax.set_title(datum.time.dt.strftime("%b-%Y").values)
    ax.set_axis_off()
    plt.subplots_adjust(hspace=0.1, wspace=0.1, bottom=0.2, top=0.45)
```



![NDVI Grid Plot](../fig/21-ndvi-grid-plot.png)



> Ahh finally! We can see the beautiful crop circles evolving over time as a result of center-pivot irrigation.


```python

```
