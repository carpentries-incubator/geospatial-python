---
title: "The Geospatial Landscape"
teaching: 10
exercises: 0
questions:
- "What programs and applications are available for working with geospatial data?"
objectives:
- "Describe the difference between various approaches to geospatial computing, and their relative strengths and weaknesses."
- "Name some commonly used GIS applications."
- "Name some commonly used R packages that can access and process spatial data."
- "Describe pros and cons for working with geospatial data using a command-line versus a graphical user interface."
keypoints:
- "Many software packages exist for working with geospatial data."
- "Command-line programs allow you to automate and reproduce your work."
- "The RStudio GUI provides a user-friendly interface for working with R."
source: Rmd
---

```{r, include=FALSE}
source("../bin/chunk-options.R")
source("../setup.R")
knitr_fig_path("04-")
```

## Standalone Software Packages 

Most traditional GIS work is carried out in standalone applications that aim to provide
end-to-end geospatial solutions. These applications are available under a wide range of
licenses and price points. Some of the most common are listed below.

### Commercial software 

  * [ESRI (Environmental Systems Research Institute)](https://www.esri.com/en-us/home)
  is an international supplier of geographic information system (GIS) software, web GIS
  and geodatabase management applications. ESRI provides several licenced platforms for
  performing GIS, including [ArcGIS](https://www.arcgis.com/home/index.html), 
  [ArcGIS Online](http://www.esri.com/software/arcgis/arcgisonline), and 
  [Portal for ArcGIS](http://server.arcgis.com/en/portal/) a stand alone version of
  ArGIS Online which you host locally. ESRI welcomes development on their platforms
  through their [DevLabs](https://developers.arcgis.com/). ArcGIS software can be
  installed using 
  [Chef Cookbooks from Github](https://github.com/Esri/arcgis-cookbook).
  * Pitney Bowes produce [MapInfo Professional](https://www.pitneybowes.com/us/location-intelligence/geographic-information-systems/mapinfo-pro.html), 
  which was one of the earliest desktop GIS programs on the market. 
  * [Hexagon Geospatial Power Portfolio](https://www.hexagongeospatial.com/products/power-portfolio) 
  includes many geospatial tools including ERDAS Imagine, a powerful remotely sensed
  image processing platform.
  * [Manifold](http://www.manifold.net/) is a desktop GIS that emphasizes speed through
  the use of parallel and GPU processing. 

### Open-source software 

The [Open Source Geospatial Foundation (OSGEO)](http://www.osgeo.org/) supports several actively managed GIS platforms:

  * [QGIS](https://www.qgis.org/en/site/) is a professional GIS application that is
  built on top of and proud to be itself Free and Open Source Software (FOSS). QGIS is
  written in Python, but has several interfaces written in R including
  [RQGIS](https://cran.r-project.org/package=RQGIS). 
  * [GRASS GIS](https://grass.osgeo.org/), commonly referred to as GRASS 
  (Geographic Resources Analysis Support System), is a FOSS-GIS software suite used for
  geospatial data management and analysis, image processing, graphics and maps
  production, spatial modeling, and visualization. GRASS GIS is currently used in
  academic and commercial settings around the world, as well as by many governmental
  agencies and environmental consulting companies. It is a founding member of the Open
  Source Geospatial Foundation (OSGeo).
  * [GDAL](http://www.gdal.org/) is a multiplatform
  set of tools for translating between geospatial data formats. It can also handle
  reprojection and a variety of geoprocessing tasks. GDAL is built in to many
  applications both FOSS and commercial, including GRASS and QGIS.
  * [SAGA-GIS](http://www.saga-gis.org/en/index.html), or System for Automated
  Geoscientific Analyses, is a FOSS-GIS application developed by a small team of
  researchers from the Dept. of Physical Geography, Göttingen, and the Dept. of
  Physical Geography, Hamburg. SAGA has been designed for an easy and effective
  implementation of spatial algorithms, offers a comprehensive, growing set of
  geoscientific methods, provides an easily approachable user interface with many
  visualisation options, and runs under Windows and Linux operating systems.
  * [PostGIS](https://postgis.net/) is a geospatial extension to the PostGreSQL
  relational database.

### Online + Cloud computing

  * Google has created [Google Earth Engine](https://earthengine.google.com/) which
  combines a multi-petabyte catalog of satellite imagery and geospatial datasets with
  planetary-scale analysis capabilities and makes it available for scientists,
  researchers, and developers to detect changes, map trends, and quantify differences
  on the Earth's surface. [Earth Engine API](https://developers.google.com/earth-engine/) 
  runs in both Python and JavaScript.
  * [ArcGIS Online](http://www.arcgis.com/features/features.html) provides access to
  thousands of maps and base layers.

Private companies have that released SDK platforms for large scale GIS analysis:

 * [Kepler.gl](http://kepler.gl/#/) is Uber's toolkit for handling large datasets (i.e. Uber's data archive).
 * [Boundless Geospatial](https://boundlessgeo.com/) is built upon OSGEO software for enterprise solutions. 

Publically funded open-source platforms for large scale GIS analysis:

 * [PanGEO](http://pangeo.io/) for the Earth Sciences. 
 * [Sepal.io](https://sepal.io/) by [FAO Openforis](http://www.openforis.org/tools/geospatial-toolkit.html) utilizing EOS satellite imagery and cloud resources for global forest monitoring.

## GUI vs CLI 

The earliest computer systems operated without a graphical user interface (GUI),
relying only on the command-line interface (CLI). Since mapping and spatial analysis
are strongly visual tasks, GIS applications benefited greatly from the emergence of
GUIs and quickly came to rely heavily on them. Most modern GIS applications have very
complex GUIs, with all common tools and procedures accessed via buttons and menus. 

Benefits of using a GUI include:

  - Tools are all laid out in front of you
  - Complex commands are easy to build
  - Don't need to learn a coding language
  - Cartography and visualisation is more intuitive and flexible
  
Downsides of using a GUI include:

  - Low reproducibility - you can't record your actions and replay
  - Most are not designed for batch-processing files
  - Limited ability to customise functions or write your own
  - Intimidating interface for new users - so many buttons!
  
In scientific computing, the lack of reproducibility in point-and-click software has
come to be viewed as a critical weakness. As such, scripted CLI-style workflows are
again becoming popular, which leads us to another approach to doing GIS: via a
programming language. This is the approach we will be using throughout this workshop.
  
## GIS in programming languages 

A number of powerful geospatial processing libraries exist for general-purpose
programming languages like Java and C++. However, the learning curve for these
languages is steep and the effort required is excessive for users who only need a
subset of their functionality. 

Higher-level scripting languages like R and Python are easier to learn and use. Both
now have their own packages that wrap up those geospatial processing libraries and make
them easy to access and use safely. A key example is the Java Topology Suite (JTS),
which is implemented in C++ as GEOS. GEOS is accessible in R via the `sf`
package and in Python via `shapely`. R and Python also have interface packages for
GDAL, and for specific GIS apps. 

This last point is a huge advantage for GIS-by-programming; these interface packages
give you the ability to access functions unique to particular programs, but have your
entire workflow recorded in a central document - a document that can be re-run at will.
Below are lists of some of the key spatial packages for R, which we will be using in the
remainder of this workshop.

  * `sf` for working with vector data 
  * `raster` for working with raster data
  * `rgdal` for an R-friendly GDAL interface

We will also be using the `ggplot2` package for spatial data visualisation. 

An overview of these and other R spatial packages can be [accessed here](https://cran.r-project.org/web/views/Spatial.html). 
  
As a programming language, R is a CLI tool. However, using
R together with an IDE (Integrated Development Environment) application
allows some GUI features to become part of your workflow. IDEs allow the best of both
worlds. They provide a place to visually examine data and other software objects,
interact with your file system, and draw plots and maps, but your activities are still
command-driven - recordable and reproducible. There are several IDEs available for R,
but [RStudio](https://www.rstudio.com/) is by far the most well-developed. We will
be using RStudio throughout this workshop.

Traditional GIS apps are also moving back towards providing a scripting environment for
users, further blurring the CLI/GUI divide. ESRI have adopted Python into their
software, and QGIS is both Python and R-friendly.

{% include links.md %}
