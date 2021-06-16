---
layout: lesson
root: .
---

Data Carpentry's aim is to teach researchers basic concepts, skills, and tools for working with data so that they can get more done in less time, and with less pain. 

> ## Getting Started
>
> Data Carpentry’s teaching is hands-on, so participants are encouraged to use 
> their own computers to ensure the proper setup of tools for an efficient 
> workflow. To most effectively use these materials, please make sure to download 
> the data and install everything before working through this lesson. 
> 
> This workshop assumes no prior experience with the tools covered in the workshop. However, **learners with prior experience working with geospatial data may be able to skip episodes 1-4, which focus on geospatial concepts and tools.** 
> Similarly, learners who have prior experience with the `Python` programming language may wish to skip the 
> [Plotting and Programming in Python](https://swcarpentry.github.io/python-novice-gapminder/index.html) lesson.
>
> To get started, follow the directions in the [Setup](setup.html) tab to
> get access to the required software and data for this workshop.
{: .prereq}

> ## Data
>
> The data and lessons in this workshop were originally developed through a hackathon funded by the 
> [National Ecological Observatory Network (NEON)](https://www.neonscience.org/) - an NSF funded observatory in Boulder, Colorado - in 
> collaboration with Data Carpentry, SESYNC and CYVERSE. NEON is collecting data for 30 years to help scientists understand
> how aquatic and terrestrial ecosystems are changing. The data used in these lessons cover two NEON field sites:
> * Harvard Forest (HARV) - Massachusetts, USA - [fieldsite description](https://www.neonscience.org/field-sites/field-sites-map/HARV)
> * San Joaquin Experimental Range (SJER) - California, USA - [fieldsite description](https://www.neonscience.org/field-sites/field-sites-map/SJER)
> 
> You can download all of the data used in this workshop by clicking 
> [this download link](https://ndownloader.figshare.com/files/21618735). 
> Clicking the download link will download all of the files as a single compressed
> (`.zip`) file. To expand this file, double-click the folder icon in your file navigator application (for Macs, this is the Finder 
> application).
> 
> These data files represent teaching version of the data, with sufficient complexity to teach many aspects of  data analysis and 
> management, but with many complexities removed to allow students to focus on the core ideas and skills being taught.  
> 
> | Dataset | File name | Description |
> | ---- | ------| ---- | 
> | Site layout shapefiles | NEON-DS-Site-Layout-Files.zip | A set of shapefiles for the NEON's Harvard Forest field site and (some) state boundary layers. | 
> | Airborne remote sensing data | NEON-DS-Airborne-RemoteSensing.zip | LiDAR data collected by the NEON Airborne Observation Platform (AOP) and processed at NEON including a canopy height model, digital elevation model and digital surface model for NEON's Harvard Forest and San Joaquin Experimental Range field sites. | 
> 
> 
{: .prereq} 

# Workshop Overview

| Lesson Starting Points   | Overview |
| ------- | ---------- |
| [Episode 1: Introduction to Raster Data]({{ site.baseurl }}/01-intro-raster-data/) | Understand data structures and common storage and transfer formats for spatial data. Start here if you want to understand fundamental geospatial concepts like coordinate reference systems, rasters, and vectors.|
| [Plotting and Programming in Python](https://swcarpentry.github.io/python-novice-gapminder/index.html) | Import data into Python, calculate summary statistics, and create publication-quality graphics. Start here if you have an understanding of geospatial concepts but want to learn Python fundamentals. |
| [Episode 5: Intro to Raster Data in Python]({{ site.baseurl }}/05-raster-structure/) | Open, work with, and plot vector and raster-format spatial data in Python. Start here if you already have a good grasp of geospatial concepts and a working knowledge of Python.|

{% include links.md %}
