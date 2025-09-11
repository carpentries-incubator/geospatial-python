---
site: sandpaper::sandpaper_site
---

### Introduction to Geospatial Raster and Vector Data with Python

In this lesson you will learn how to work with geospatial datasets and how to process these with Python. Python is one of the most popular programming languages for data science and analytics, with a large and steadily growing community in the field of Earth and Space Sciences. The lesson is meant for participants with a basic knowledge of Python and it allows them to familiarize with the world of geospatial raster and vector data. If you are unfamiliar with Python, useful resources to get started include the Software Carpentry's lesson ["Programming with Python"](https://swcarpentry.github.io/python-novice-inflammation/) and the book ["Think Python"](https://allendowney.github.io/ThinkPython/index.html) by Allen Downey. In the *Introduction to Geospatial Raster and Vector Data with Python*  lesson you will be introduced to a set of tools from the Python ecosystem and learn how these can be used to carry out geospatial data analysis tasks. In particular, you will work with satellite images and open topographical geo-datasets, and learn how these spatial datasets can be accessed, explored, manipulated and visualized using Python.

### Case study - Wildfires

As a case study for this lesson we will focus on wildfires. According to [the IPCC assessment report](https://www.ipcc.ch/report/ar6/wg2/about/frequently-asked-questions/keyfaq1/), the wildfire seasons are lengthening as a result of changes in temperature and increasing drought conditions. To analyse the impact of these wildfires, we will focus on the wildfire that occurred on the Greek island of [Rhodes in the summer of 2023](https://news.sky.com/story/wildfires-on-rhodes-force-hundreds-of-holidaymakers-to-flee-their-hotels-12925583), which had a devastating effect and led to the evacuation of [19.000 people](https://en.wikipedia.org/wiki/2023_Greece_wildfires). In this lesson we are going to analyse the effect of this disaster by estimating which built-up areas were affected by these wildfires. Furthermore, we will analyse which vegetation and land-use types have been affected the most by the wildfire in order to get an understanding of which areas are more vulnerable to wildfires. The analysis that we set up provides insights in the effect of the wildfire and generates input for wildfire mitigation strategies.

*Note, that the analyses presented in this lesson are developed for educational purposes. Therefore in some occasions the analysis steps have been simplified and assumptions have been made.*

The data used in this lesson includes optical satellite images from [the Copernicus Sentinel-2 mission][sentinel-2] and topographical data from [OpenStreetMap (OSM)][osm]. These datasets are real-world open data sets that entail sufficient complexity to teach many aspects of data analysis and management. The datasets have been selected to allow participants to focus on the core ideas and skills being taught while offering the chance to encounter common challenges with geospatial data. Furthermore, we have selected datasets which are available anywhere on Earth.

During this lesson we will setup an analysis pipeline which identifies scorched areas based on bands of satellite images collected after the disaster in July 2023. Next, we will calculate the [Normalized Difference Vegetation Index (NDVI)](https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index) to assess the vegetation cover of the areas before and after the wildfire. To investigate the affected built-up areas and main roads, we will use OSM vector data and compare them with the previously identified scorched areas.

To most effectively use this material, make sure to [download the data](learners/setup.md#data-sets) and follow [the software setup instructions](learners/setup.md#software-setup) before working through the lesson (this especially accounts for learners that follow this lesson in a workshop).

### Python libraries used in this lesson

The main python libraries that are used in this lesson are:

- [geopandas](https://geopandas.org/en/stable/)
- [rioxarray](https://github.com/corteva/rioxarray)
- [xarray-spatial](https://xarray-spatial.readthedocs.io)
- [dask](https://www.dask.org/)
- [pystac-client](https://pystac-client.readthedocs.io/)

[sentinel-2]: https://sentinel.esa.int/web/sentinel/missions/sentinel-2
[osm]: https://www.openstreetmap.org/#map=14/45.2935/18.7986
