---
layout: page
title: Setup
---

# Overview

This workshop is designed to be run on your local machine. First, you will need to download the data we use in the workshop. Then, you need to set up your machine to analyze and process geospatial data. We provide instructions below to either install all components manually (option A), or to use a Docker image that provides all the software and dependencies needed (option B).

## Data

You can download all of the data used in this workshop by clicking
[this download link](https://ndownloader.figshare.com/articles/2009586/versions/10). The file is 218.2 MB.

Clicking the download link will automatically download all of the files to your default download directory as a single compressed
(`.zip`) file. To expand this file, double click the folder icon in your file navigator application (for Macs, this is the Finder application).

For a full description of the data used in this workshop see the [data page](data).

## Option A: Local Installation

### Software

| Software | Install | Manual | Available for | Description |
| -------- | ------------ | ------ | ------------- | ----------- |
| [GDAL](http://www.gdal.org) | [Link](https://gdal.org/download.html) | [Link](https://gdal.org) | Linux, MacOS, Windows | Geospatial model for reading and writing a variety of formats |
| [GEOS](https://trac.osgeo.org/geos) | [Link](https://trac.osgeo.org/geos) | [Link](http://geos.osgeo.org/doxygen/) | Linux, MacOS, Windows | Geometry models and operations |
| [PROJ.4](http://proj4.org) | [Link](http://proj4.org/install.html)| [Link](http://proj4.org/index.html)| Linux, MacOS, Windows | Coordinate reference system transformations |
| [R](https://www.r-project.org) | [Link](https://cloud.r-project.org) | [Link](https://cloud.r-project.org) | Linux, MacOS, Windows | Software environment for statistical and scientific computing |
| [RStudio](https://www.rstudio.com) | [Link](https://www.rstudio.com/products/rstudio/download/#download) | | Linux, MacOS, Windows | GUI for R |
| [UDUNITS](https://www.unidata.ucar.edu/software/udunits/) | [Link](https://www.unidata.ucar.edu/downloads/udunits/index.jsp) | [Link](https://www.unidata.ucar.edu/software/udunits/#documentation) | Linux, MacOS, Windows | Unit conversions |

We provide quick instructions below for installing the various software needed for this workshop. At points, they assume familiarity with the command line and with installation in general. As there are different operating systems and many different versions of operating systems and environments, these may not work on your computer. If an installation doesn't work for you, please refer to the installation instructions for that software listed in the table above.


### GDAL, GEOS, and PROJ.4

The installation of the geospatial libraries GDAL, GEOS, and PROJ.4 varies significantly based on operating system. These are all dependencies for `sf`, the `R` package that we will be using for spatial data operations throughout this workshop.

> ## Windows
>
>To install the geospatial libraries, install the latest version [RTools](https://cran.r-project.org/bin/windows/Rtools/)
>
{: .solution}

> ## macOS - Install with Packages (Beginner)
>
> The simplest way to install these geospatial libraries is to install the latest version of [Kyng Chaos's pre-built package](http://www.kyngchaos.com/software/frameworks) for GDAL Complete. Be aware that several other libraries are also installed, including the UnixImageIO, SQLite3, and `NumPy`.
>
> After downloading the package in the link above, you will need to double-click the cardbord box icon to complete the installation. Depending on your security settings, you may get an error message about "unidentified developers". You can enable the installation by following [these instructions](https://kb.wisc.edu/page.php?id=25443) for installing programs from unidentified developers.
>
{: .solution}

> ## macOS - Install with Homebrew (Advanced)
>
> Alternatively, participants who are comfortable with the command line can install the geospatial libraries individually using [homebrew](https://brew.sh):
>
>~~~
>$ brew tap osgeo/osgeo4mac && brew tap --repair
>$ brew install proj
>$ brew install geos
>$ brew install gdal2
>~~~
>{: .language-bash}
>
{: .solution}

> ## Linux
>
> Steps for installing the geospatial libraries will vary based on which form of Linux you are using. These instructions are adapted from the [`sf` package's `README`](https://github.com/r-spatial/sf).
>
> For **Ubuntu**:
>
>~~~
>$ sudo add-apt-repository ppa:ubuntugis
>$ sudo apt-get update
>$ sudo apt-get install libgdal-dev libgeos-dev libproj-dev
>~~~
>{: .language-bash}
>
> For **Fedora**:
>
>~~~
>$ sudo dnf install gdal-devel proj-devel proj-epsg proj-nad geos-devel
>~~~
>{: .language-bash}
>
> For **Arch**:
>
>~~~
>$ pacman -S gdal proj geos
>~~~
>{: .language-bash}
>
> For **Debian**: The [rocker geospatial](https://github.com/rocker-org/geospatial) Dockerfiles may be helpful. Ubuntu Dockerfiles are found [here](https://github.com/r-spatial/sf/tree/master/inst/docker). These may be helpful to get an idea of the commands needed to install the necessary dependencies.
>
{: .solution}

### UDUNITS

Linux users will have to install UDUNITS separately. Like the geospatial libraries discussed above, this is a dependency for the `R` package `sf`. Due to conflicts, it does not install properly on Linux machines when installed as part of the `sf` installation process. It is therefore necessary to install it using the command line ahead of time.

> ## Linux
>
> Steps for installing the geospatial will vary based on which form of Linux you are using. These instructions are adapted from the [`sf` package's `README`](https://github.com/r-spatial/sf).
>
> For **Ubuntu**:
>
>~~~
>$ sudo apt-get install libudunits2-dev
>~~~
>{: .language-bash}
>
> For **Fedora**:
>
>~~~
>$ sudo dnf install udunits2-devel
>~~~
>{: .language-bash}
>
> For **Arch**:
>
>~~~
>$ pacaur/yaourt/whatever -S udunits
>~~~
>{: .language-bash}
>
> For **Debian**:
>
>~~~
>$ sudo apt-get install -y libudunits2-dev
>~~~
>{: .language-bash}
>
{: .solution}


### R

Participants who do not already have `R` installed should download and install it.

> ## Windows
>
>To install `R`, Windows users should select "Download R for Windows" from RStudio and CRAN's [cloud download page](https://cloud.r-project.org), which will automatically detect a CRAN mirror for you to use. Select the `base` subdirectory after choosing the Windows download page. A `.exe` executable file containing the necessary components of base R can be downloaded by clicking on "Download R 3.x.x for Windows".
>
{: .solution}

> ## macOS
>
>To install `R`, macOS users should select "Download R for (Mac) OS X" from RStudio and CRAN's [cloud download page](https://cloud.r-project.org), which will automatically detect a CRAN mirror for you to use. A `.pkg` file containing the necessary components of base R can be downloaded by clicking on the first available link (this will be the most recent), which will read `R-3.x.x.pkg`.
>
{: .solution}

> ## Linux
>
>To install `R`, Linux users should select "Download R for Linux" from RStudio and CRAN's [cloud download page](https://cloud.r-project.org), which will automatically detect a CRAN mirror for you to use. Instructions for a number of different Linux operating systems are available.
>
{: .solution}

### RStudio
RStudio is a GUI for using `R` that is available for Windows, macOS, and various Linux operating systems. It can be downloaded [here](https://www.rstudio.com/products/rstudio/download/). You will need the **free** Desktop version for your computer. *In order to address issues with `ggplot2`, learners and instructors should run a recent version of RStudio (v1.2 or greater).*

### R Packages

The following `R` packages are used in the various geospatial lessons.

* [`dplyr`](https://cran.r-project.org/package=dplyr)
* [`ggplot2`](https://cran.r-project.org/package=ggplot2)
* [`raster`](https://cran.r-project.org/package=raster)
* [`rgdal`](https://cran.r-project.org/package=rgdal)
* [`rasterVis`](https://cran.r-project.org/package=rasterVis)
* [`remotes`](https://cran.r-project.org/package=remotes)
* [`sf`](https://cran.r-project.org/package=sf)

To install these packages in RStudio, do the following:  
1\. Open RStudio by double-clicking the RStudio application icon. You should see
something like this:

![RStudio layout](/fig/01-rstudio.png)


2\. Type the following into the console and hit enter.

~~~
install.packages(c("dplyr", "ggplot2", "raster", "rgdal", "rasterVis", "sf"))
~~~
{: .language-r}

You should see a status message starting with:

~~~
trying URL 'https://cran.rstudio.com/bin/macosx/el-capitan/contrib/3.5/dplyr_0.7.6.tgz'
Content type 'application/x-gzip' length 5686536 bytes (5.4 MB)
==================================================
downloaded 5.4 MB

trying URL 'https://cran.rstudio.com/bin/macosx/el-capitan/contrib/3.5/ggplot2_3.0.0.tgz'
Content type 'application/x-gzip' length 3577658 bytes (3.4 MB)
==================================================
downloaded 3.4 MB
~~~
{: .output}

When the installation is complete, you will see a status message like:

~~~
The downloaded binary packages are in
/var/folders/7g/r8_n81y534z0vy5hxc6dx1t00000gn/T//RtmpJECKXM/downloaded_packages
~~~
{: .output}

You are now ready for the workshop!

## Option B: Docker

[Docker](https://www.docker.com) provides developers with a means for creating interactive [containers](https://docs.docker.com/glossary/?term=container) that contain pre-installed software. A selection of pre-installed software in Docker is called an [image](https://docs.docker.com/glossary/?term=image). An image can be downloaded and used to create a local container, allowing end-users to get software up and running quickly. This is particularly useful when a local installation of the software could be complex and time consuming. For `R` users, a Docker image can be used to create a virtual installation of `R` and RStudio that can be run through your web browser.

This option involves downloading an Docker image that contains an installation of `R`, RStudio Server, all of the necessary dependencies listed above, and almost all of the `R` packages used in the geospatial lessons. You will need to install the appropriate version of Docker's Community Edition software and then download and use the `rocker/geospatial` Docker image to create a container that will allow you to use `R`, RStudio, and all the required GIS tools without installing any of them locally.

Once up and running - you'll have full access to RStudio right from your browser:

![](/fig/docker.png)

Please be aware that the `R` package `rasterVis` is not included in the `rocker/geospatial` Docker image. If your instructor teaches with this package then you will need to install this `R` package yourself. All other `R` packages will already be installed for you.

> ## Downloading and Installing Docker Community Edition
>
> To get started with Docker, download the [Docker Community Edition](https://www.docker.com/community-edition) from [Docker's store](https://store.docker.com/search?type=edition&offering=community). Community editions are available for [Windows](https://store.docker.com/editions/community/docker-ce-desktop-windows), [macOS](https://store.docker.com/editions/community/docker-ce-desktop-mac), and Linux operating systems including [Debian](https://store.docker.com/editions/community/docker-ce-server-debian), [Fedora](https://store.docker.com/editions/community/docker-ce-server-fedora), and [Ubuntu](https://store.docker.com/editions/community/docker-ce-server-ubuntu).
>
> The download pages for each of these operating systems contain notes about some necessary system requirements and other pre-requisites. Once you download the installer and follow the on-screen prompts.
>
> Additional installation notes are available in Docker's documentation for each of these operating systems: [Windows](https://docs.docker.com/docker-for-windows/install/), [macOS](https://docs.docker.com/docker-for-mac/install/), [Debian](https://docs.docker.com/install/linux/docker-ce/debian/), [Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/), and [Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/).
>
{: .solution}

> ## Using the `rocker/geospatial` Docker Image via the Command Line
>
> #### Download and Set-up
> Once Docker is installed and up and running, you will need to open your computer's command line terminal. We'll use the terminal to download [`rocker/geospatial`](https://github.com/rocker-org/geospatial), a pre-made Docker image that contains an installation of `R`, RStudio Server, all of the necessary dependencies, and all but one of the `R` packages needed for this workshop.
>
> You need to have already installed Docker Community Edition (see instructions above) before proceeding. Once you have Docker downloaded and installed, make sure Docker is running and then enter the following command into the terminal to download the `rocker/geospatial` image:
>
>~~~
>$ docker pull rocker/geospatial
>~~~
>{: .language-bash}
>
> Once the pull command is executed, the image needs to be run to become accessible as a container. In the following example, the image is named `rocker/geospatial` and the container is named `gis`. The [image](https://docs.docker.com/glossary/?term=image) contains the software you've downloaded, and the [container](https://docs.docker.com/glossary/?term=container) is the run-time instance of that image. New Docker users should need only one named container per image.
>
> When `docker run` is used, you can specify a folder on your computer to become accessible inside your RStudio Server instance. The following `docker run` command exposes Jane's `GitHub` directory to RStudio Server. Enter the file path where your workshop resources and data are stored:
>
>~~~
>$ docker run -d -P --name gis -v /Users/jane/GitHub:/home/rstudio/GitHub -e PASSWORD=mypass rocker/geospatial
>~~~
>{: .language-bash}
>
> When she opens her RStudio instance below, she will see a `GitHub` folder in her file tab in the lower righthand corner of the screen. Windows and Linux users will have to adapt the file path above to follow the standards of their operating systems. More details are available on [rocker's Wiki](https://github.com/rocker-org/rocker/wiki/Sharing-files-with-host-machine).
>
> The last step before launching your container in a browser is to identify the port that your Docker container is running in:
>
>~~~
>$ docker port gis
>~~~
>{: .language-bash}
>
> An output, for example, of `8787/tcp -> 0.0.0.0:32768` would indicate that you should point your browser to `http://localhost:32768/`. If prompted, enter `rstudio` for the username and the password provided in the `docker run` command above (`mypass` in the example above).
>
> #### Stopping a Container
> When you are done with a Docker session, make sure all of your files are saved locally on your computer **before closing your browser and Docker**. Once you have ensured all of your files are available (they should be saved at the file path designated in `docker run` above), you can stop your Docker container in the terminal:
>
>~~~
>$ docker stop gis
>~~~
>{: .language-bash}
>
> #### Re-starting a Container
> Once a container has been named and created, you cannot create a container with the same name again using `docker run`. Instead, you can restart it:
>
>~~~
>$ docker start gis
>~~~
>{: .language-bash}
>
> If you cannot remember the name of the container you created, you can use the following command to print a list of all named containers:
>
>~~~
>$ docker ps -a
>~~~
>{: .language-bash}
>
> If you are returning to a session after stopping Docker itself, make sure Docker is running again before re-starting your container!
>
{: .solution}

> ## Using the `rocker/geospatial` Docker Image via Kitematic
> #### Download and Install Kitematic
> [Kitematic](https://github.com/docker/kitematic) is the GUI, currently in beta, that Docker has built for accessing images and containers on Windows, macOS, and Ubuntu. You can download the appropriate installer files from Kitematic's [GitHub release page](https://github.com/docker/kitematic/releases/tag/v0.17.3). You need to have already installed Docker Community Edition (see instructions above) before installing Kitematic!
>
> #### Opening a Container with Kitematic
> Once you have installed Kitematic, make sure the Docker application is running and then open Kitematic. You should not need to create a login to use Kitematic. If prompted for login credentials, there is an option to skip that step. Use the search bar in the main window to find `rocker/geospatial` (pictured below) and click `Create` under that Docker repository.
>
> ![](/fig/kitematicSearch.png)
>
> After downloading and installing the image, your container should start automatically. Before opening your browser, connect your Docker image to a local folder where you have your workshop resources stored by clicking on the `Settings` tab and then choosing `Volumes`. Click `Change` and then select the directory you would like to connect to.
>
> ![](/fig/kitematicLocal.png)
>
> When you open RStudio instance below, you will see the contents of the connected folder inside the `kitematic` directory in the file tab located in the lower righthand corner of the screen.
>
> When you are ready, copy the `Access URL` from the `Home` tab:
>
> ![](/fig/kitematicURL.png)
>
> Paste that url into your browser and, if prompted, enter `rstudio` for both the username and the password.
>
> #### Stopping and Restarting a Container
> When you are done with a Docker session, make sure all of your files are saved locally on your computer **before closing your browser and Docker**. Once you have ensured all of your files are available (they should be saved at the file path designated in `docker run` above), you can stop your Docker container by clicking on the `Stop` icon in Kitematic's toolbar.
>
> You can restart your container later by clicking the `Restart` button.
>
{: .solution}

> ## Managing Docker Containers and Images
> To obtain a list of all of your current Docker containers:
>
>~~~
>$ docker ps -a
>~~~
>{: .language-bash}
>
> To list all of the currently downloaded Docker images:
>
>~~~
>$ docker images -a
>~~~
>{: .language-bash}
>
> These images can take up system resources, and if you'd like to remove them, you can use the `docker prune` command. To remove any Docker resources not affiliated with a container listed under `docker ps -a`:
>
>~~~
>$ docker system prune
>~~~
>{: .language-bash}
>
> To remove **all** Docker resources, including currently named containers:
>
>~~~
>$ docker system prune -a
>~~~
>{: .language-bash}
>
{: .solution}


{% include links.md %}
