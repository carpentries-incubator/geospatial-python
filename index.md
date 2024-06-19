---
site: sandpaper::sandpaper_site
---

## Data Carpentries

[Data Carpentry’s](https://datacarpentry.org/) teaching is hands-on. Participants are encouraged to use their own computers to ensure the proper setup of tools for an efficient workflow.

## Geospatial Raster and Vector Data with Python

In this lesson you will learn how to work with geospatial data and how to process these with python. Python is one of the most popular programming languages for data science and analytics, with a large and steadily growing community in the field of Earth and Space Sciences. The lesson is meant for participants with a working basic knowledge of Python and allow them to to familiarize with the world of geospatial raster and vector data. (If you are unfamiliar to python we recommend you to follow [this course](https://swcarpentry.github.io/python-novice-inflammation/) or have a look [here](https://greenteapress.com/thinkpython2/thinkpython2.pdf) ). In the *Introduction to Geospatial Raster and Vector Data with Python*  lesson you will be introduced to a set of tools from the Python ecosystem and learn how these can be used to carry out geospatial data analysis tasks. In particular, you will learn to work with  satellite images (i.e. [the Copernicus Sentinel-2 mission][sentinel-2] ) and open topographical geo-datasets (i.e. [OpenStreetmap][osm]). You will learn how these spatial datasets can be accessed, explored, manipulated and visualized using Python.

## Case study - Wildfires

As a case study for this lesson we will focus on wildfires. According to the IPCC assessment report, the wildfire seasons are lengthening as a result of changes in temperature and increasing drought conditions [IPCC](https://www.ipcc.ch/report/ar6/wg2/about/frequently-asked-questions/keyfaq1/). To analyse the impact of these wildfires, we will focus on the wildfire that occured on the Greek island [Rhodes in the summer of 2023](https://news.sky.com/story/wildfires-on-rhodes-force-hundreds-of-holidaymakers-to-flee-their-hotels-12925583), which had a devastating effect and led to the evacuation of [19.000 people](https://en.wikipedia.org/wiki/2023_Greece_wildfires). In this lesson we are going analyse the effect of this disaster by estimating which built-up areas were affected by these wildfires. Furthermore, we will analyse which vegetation and land-use types have been affected the most by the wildfire in order to get an understanding of which areas are more vulnerable to wildfires. Finally we are going to estimate which locations would be most suitable for placing watchtowers in the region. The analysis that we set up provides insights in the effect of the wildfire and generates input for wildfire mitigation strategies.

*Note, that the analyses presented in this lesson are developed for educational purposes. Therefore in some occasions the analysis steps have been simplified and assumptions have been made.*

The data used in this lesson includes optical satellite images from [the Copernicus Sentinel-2 mission][sentinel-2] and topographical data from [OpenStreetMap (OSM)][osm]. These datasets are real-world open data sets that entail sufficient complexity to teach many aspects of data analysis and management. The datasets have been selected to allow participants to focus on the core ideas and skills being taught while offering the chance to encounter common challenges with geospatial data. Furthermore, we have selected datasets which are available anywhere on earth.

During this lesson we will setup an analysis pipeline which identifies scorched areas based bands of satelite images collected after the disaster in july 2023. Next, we will analyse the vegetation type, by calculating the [NDVI index](https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index), that was present in these areas before the wildfire by looking at satellite images before the disaster and compare them with the scorched areas. To confront the effected built-up areas and most important roads, we will be using OSM vector data and compare that with the scorched areas identified above. Finally, we will use elevation data to perform viewshed analyses in order to locate the best locations for (hypothetical) watchtowers, which in theory would allow to identify a wildfire earlier, thus allowing to react more quickly.

To most effectively use these materials, make sure to download the data and install everything before working through this lesson (this especially accounts for learners that follow this lesson in a workshop).

## Python libraries used in this lesson

The main python libraries that are used in this lesson are:

- [geopandas](https://geopandas.org/en/stable/)
- [rioxarray](https://github.com/corteva/rioxarray)
- [xarray-spatial](https://xarray-spatial.org/)
- [dask](https://www.dask.org/)
- [pystac](https://pystac.readthedocs.io/en/stable/)

[sentinel-2]: https://sentinel.esa.int/web/sentinel/missions/sentinel-2
[osm]: https://www.openstreetmap.org/#map=14/45.2935/18.7986
