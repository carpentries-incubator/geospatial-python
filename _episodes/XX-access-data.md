---
title: "Access satellite imagery using Python"
teaching: TODO
exercises: TODO
questions:
- "Where can I find open satellite data?"
- "How do I query a STAC API using metadata filters?"
- "How do I fetch remote raster datasets using Python?"
objectives:
- "Search public repositories of satellite imagery using Python."
- "Inspect the search result metadata."
- "Download (a subset of) the assets available for a satellite scene."
- "Open the satellite imagery as raster data and setup some raster calculations."
- "Save the processed satellite data to disk."
keypoints:
- "Accessing satellite images via the providers' API enables a more reliable and scalable data retrieval."
- "STAC catalogs can be browsed and searched using the same tools and scripts."
- "`rioxarry` also allows you to open and download remote raster files."
---

A number of satellites take snapshots of the Earth's surface from space. The images recorded by these remote sensors
represent a very precious data source for any activity that involves monitoring changes on Earth. Satellite imagery is
typically provided in the form of geospatial raster data, with the measurements in each grid cell ("pixel") being
associated to accurate geographic coordinate information.

In this episode we will explore how to access open satellite data using Python. In particular,  we will
consider [the Sentinel-2 data collection that is hosted on AWS](https://registry.opendata.aws/sentinel-2-l2a-cogs).
This dataset consists of multi-band optical images acquired by the two satellites of
[the Sentinel-2 mission](https://sentinel.esa.int/web/sentinel/missions/sentinel-2) and it is continuously updated with
new images.

# Search for satellite imagery

## The SpatioTemporal Asset Catalog (STAC) specification

Current sensor resolutions and satellite revisit periods are such that terabytes of data products are added daily to the
corresponding collections. Such datasets cannot be made accessible to users via full-catalog download. Space agencies
and other data providers often offer access to their data catalogs through interactive graphical user interfaces (GUIs,
see for instance the [Copernicus Open Access Hub portal](https://scihub.copernicus.eu/dhus/#/home) for the Sentinel
missions). Accessing data via a GUI is a nice way to explore a catalog and get familiar with its content, but it
represents a heavy and error-prone task that should be avoided if carried out systematically to retrieve data.

A service that offers programmatic access to the data enables users to reach the desired data in a more reliable,
scalable and reproducible manner. An important element in the software interface exposed to the users (generally called
the application programming interface, API) is the use of standards. Standards, in fact, can significantly facilitate
the reusability of tools and scripts across datasets and applications.

The SpatioTemporal Asset Catalog (STAC) specification is an emerging standard for describing geospatial data. By
organizing metadata in a form that adheres to the STAC specifications, data providers make it possible for users to
access data from different missions, instruments and collections using the same set of tools.

> ## More Resources on STAC
>
> * [The STAC specification](https://github.com/radiantearth/stac-spec)
> * [Tools based on STAC](https://stacindex.org/ecosystem)
> * [STAC catalogs](https://stacindex.org/catalogs)
{: .callout}

## Search a STAC catalog

The Sentinel-2 collection hosted on AWS is indexed in a STAC catalog that is accessible at the following link:

~~~
api_url = "https://earth-search.aws.element84.com/v0"
~~~
{: .language-python}

> ## Exercise: Discover a STAC catalog
> Open the following STAC API link using your web browser: https://earth-search.aws.element84.com/v0.
> Navigate through the links to find out which collections are available and how many scenes are indexed. Where may one
> find information on how to query the API for the desired scenes? Can you find out which parameters can be provided
> in the queries?
{: .challenge}

You can query a STAC API endpoint from Python using the `pystac_client` library. In the following code snippets, we ask
for all the scenes:
* belonging to the `sentinel-s2-l2a-cogs` collection. This dataset includes Seninel-2 data products pre-processed at
  level 2A (bottom-of-atmosphere reflectance) and saved in Cloud Optimized GeoTIFF (COG) format;
* intersecting a geometry provided using [the GeoJSON notation](https://geojson.org) (in this case, a point).

Note: at this stage, we are only dealing with metadata, so no image is going to be downloaded yet. But even metadata can
be quite bulky if a large number of scenes match our search! For this reason, we limit the search result to 10 items.

~~~
from pystac_client import Client

client = Client.open(api_url)

# collection: Sentinel-2, Level 2A, COGs
collection = "sentinel-s2-l2a-cogs"

# AMS coordinates
lat, lon = 52.37, 4.90
geometry = {"type": "Point", "coordinates": (lon, lat)}

mysearch = client.search(
    collections=[collection],
    intersects=geometry,
    max_items=10,
)
~~~
{: .language-python}

We submit the query and find out how many scenes match our search criteria:

~~~
print(mysearch.matched())
~~~
{: .language-python}

~~~
613
~~~
{: .output}

Finally, we retrieve the metadata of the search results:
~~~
items = mysearch.get_all_items()
~~~
{: .language-python}

We can check how many items are included in the returned `ItemCollection`:
~~~
print(len(items))
~~~
{: .language-python}

~~~
10
~~~
{: .output}

which is consistent with the maximum number of items that we have set in the search criteria. We can iterate over
the returned items and print these to show their IDs:

~~~
for item in items:
    print(item)
~~~
{: .language-python}

~~~
<Item id=S2B_31UFU_20220125_0_L2A>
<Item id=S2B_31UFU_20220122_0_L2A>
<Item id=S2A_31UFU_20220120_0_L2A>
<Item id=S2A_31UFU_20220117_0_L2A>
<Item id=S2B_31UFU_20220115_0_L2A>
<Item id=S2B_31UFU_20220112_0_L2A>
<Item id=S2A_31UFU_20220110_0_L2A>
<Item id=S2A_31UFU_20220107_0_L2A>
<Item id=S2B_31UFU_20220105_0_L2A>
<Item id=S2B_31UFU_20220102_0_L2A>
~~~
{: .output}

Each of the items contains information about the scene geometry, its acquisition time, and other metadata that can be
accessed as a dictionary from the `properties` attribute.
To inspect the metadata associated with the first item of the search results:
~~~
item = items[0]
print(item.datetime)
print(item.geometry)
print(item.properties)
~~~
{: .language-python}

~~~
2022-01-25 10:56:17+00:00
{'type': 'Polygon', 'coordinates': [[[6.071664488869862, 52.22257539160586], [4.464995307918359, 52.25346561204129], [4.498475093400055, 53.24019917467795], [6.1417542968794585, 53.20819279121764], [6.071664488869862, 52.22257539160586]]]}
{'datetime': '2022-01-25T10:56:17Z', 'platform': 'sentinel-2b', 'constellation': 'sentinel-2', 'instruments': ['msi'], 'gsd': 10, 'view:off_nadir': 0, 'proj:epsg': 32631, 'sentinel:utm_zone': 31, 'sentinel:latitude_band': 'U', 'sentinel:grid_square': 'FU', 'sentinel:sequence': '0', 'sentinel:product_id': 'S2B_MSIL2A_20220125T105229_N0400_R051_T31UFU_20220125T151458', 'sentinel:data_coverage': 100, 'eo:cloud_cover': 100, 'sentinel:valid_cloud_cover': True, 'sentinel:processing_baseline': '04.00', 'created': '2022-01-25T20:59:17.398Z', 'updated': '2022-01-25T20:59:17.398Z'}
~~~
{: .output}


> ## Exercise: Search satellite scenes using metadata filters
> Search for all the available Sentinel-2 scenes in the `sentinel-s2-l2a-cogs` collection that satisfy the following
> criteria:
> - intersect a provided bounding box (use ±0.05 deg in lat/lon from the point: 52.37N 4.90E);
> - have been recorded in 2021;
> - have a cloud coverage smaller than 5%.
>
> How many scenes are available? Save the search results in  GeoJSON format.
>
> >## Solution
> >
> > ~~~
> > from shapely.geometry import Point
> > p = Point(lon, lat)
> > bbox = p.buffer(0.05).bounds
> > ~~~
> > {: .language-python}
> >
> > ~~~
> > mysearch = client.search(
> >     collections=[collection],
> >     bbox=bbox,
> >     datetime="2021-01-01/2021-12-31",
> >     query=["eo:cloud_cover<5"]
> > )
> > print(mysearch.matched())
> > ~~~
> > {: .language-python}
> >
> > ~~~
> > 42
> > ~~~
> > {: .output}
> >
> > ~~~
> > items = mysearch.get_all_items()
> > items.save_object("mysearch.json")
> > ~~~
> > {: .language-python}
> {: .solution}
{: .challenge}

# Access the assets

So far we have only discussed metadata - but how can one get to the actual images of a satellite scene (the "assets" in
the STAC nomenclature)? These can be reached via links that are made available through the item's attribute `assets`.

~~~
assets = items[-1].assets  # last item's asset dictionary
print(assets.keys())
~~~
{: .language-python}

~~~
dict_keys(['thumbnail', 'overview', 'info', 'metadata', 'visual', 'B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B08', 'B8A', 'B09', 'B11', 'B12', 'AOT', 'WVP', 'SCL'])
~~~
{: .output}

We can print a minimal description of the available assets:

~~~
for key, asset in assets.items():
    print(f"{key}: {asset.title}")
~~~
{: .language-python}

~~~
thumbnail: Thumbnail
overview: True color image
info: Original JSON metadata
metadata: Original XML metadata
visual: True color image
B01: Band 1 (coastal)
B02: Band 2 (blue)
B03: Band 3 (green)
B04: Band 4 (red)
B05: Band 5
B06: Band 6
B07: Band 7
B08: Band 8 (nir)
B8A: Band 8A
B09: Band 9
B11: Band 11 (swir16)
B12: Band 12 (swir22)
AOT: Aerosol Optical Thickness (AOT)
WVP: Water Vapour (WVP)
SCL: Scene Classification Map (SCL)
~~~
{: .output}

Among the others, assets include multiple raster data files (one per optical band, as acquired by the multi-spectral
instrument), a thumbnail, a true-color image ("visual"), instrument metadata and scene-classification information
("SCL"). A URL links to the actual asset:

~~~
print(assets["thumbnail"].href)
~~~
{: .language-python}

~~~
https://roda.sentinel-hub.com/sentinel-s2-l1c/tiles/31/U/FU/2021/1/12/0/preview.jpg
~~~
{: .output}

This can be used to download the corresponding file:

<img src="../fig/XX-STAC-s2-preview.jpg" title="Scene thumbnail" alt="true color image scene preview" width="612" style="display: block; margin: auto;" />

Remote raster data can also be directly opened via `rioxarray`.
~~~
import rioxarray
visual_href = assets["visual"].href
visual = rioxarray.open_rasterio(visual_href)
print(visual)
~~~
{: .language-python}

~~~
<xarray.DataArray (band: 3, y: 10980, x: 10980)>
[361681200 values with dtype=uint8]
Coordinates:
  * band         (band) int64 1 2 3
  * x            (x) float64 6e+05 6e+05 6e+05 ... 7.098e+05 7.098e+05 7.098e+05
  * y            (y) float64 5.9e+06 5.9e+06 5.9e+06 ... 5.79e+06 5.79e+06
    spatial_ref  int64 0
Attributes:
    _FillValue:    0.0
    scale_factor:  1.0
    add_offset:    0.0
~~~
{: .output}

As for local files, where calling `open_rasterio` does not actually load data into memory, also for remote data the only
metadata is fetched when opening a file. The full data content is actually downloaded when required - for instance when
performing some raster calculations, like cropping the image using a bounding box:
~~~
visual_clip = visual.rio.clip_box(
    minx=627000,
    miny=5802000,
    maxx=631000,
    maxy=5806000
)
visual_clip.plot.imshow(figsize=(10,10))
~~~
{: .language-python}

<img src="../fig/XX-STAC-s2-true-color-image-cutout.png" title="Scene cutout true color image" alt="RGB representation of the scene cutout" width="612" style="display: block; margin: auto;" />

Finally, data can be saved to disk:

~~~
# save processed image to disk
visual_clip.rio.to_raster("amsterdam_tci.tif", driver="COG")
~~~
{: .language-python}
