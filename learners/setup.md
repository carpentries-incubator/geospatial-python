---
title: Setup
---

## Data Sets

1. Create a new directory on your Desktop called `geospatial-python`.
2. Within `geospatial-python`, create a directory called `data`.
3. Download the following files and save them to the just created `data` directory (**do not unzip the files**, we will read from them directly):
  * [brpgewaspercelen_definitief_2020_small.gpkg](https://figshare.com/ndownloader/files/37729413)
  * [brogmwvolledigeset.zip](https://figshare.com/ndownloader/files/37729416)
  * [status_vaarweg.zip](https://figshare.com/ndownloader/files/37729419)

## Software Setup

### Installing Python Using Anaconda

[Python][python] is a popular language for scientific computing, and great for
general-purpose programming as well. Installing all of its scientific packages
individually can be a bit difficult, however, so we recommend the all-in-one
installer [Anaconda][anaconda].

Regardless of how you choose to install it, please make sure you install Python
version 3.x (e.g., 3.9 is fine). Also, please set up your python environment at
least a day in advance of the workshop.  If you encounter problems with the
installation procedure, ask your workshop organizers via e-mail for assistance so
you are ready to go as soon as the workshop begins.

::::::::::::::::::::::::::::::::::::::: discussion

### Installing Anaconda

:::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::: solution

### Windows

[Video tutorial][video-windows]

1. Open [https://www.anaconda.com/download][anaconda-windows] with your web browser.

2. Download the Anaconda for Windows installer with Python 3.

3. Install Python 3 by running the Anaconda Installer, using all of the defaults for installation *except* make sure that:
  * **Register Anaconda as my default Python 3.x** option is checked (it should be in the latest version of Anaconda).
  * **Add Anaconda to my PATH environment variable** is selected.


:::::::::::::::::::::::::

:::::::::::::::: solution

### Mac OS

[Video tutorial][video-mac]

1. Open [https://www.anaconda.com/download][anaconda-mac] with your web browser.

2. Download the Anaconda installer with Python 3 for OS X. These instructions assume that you use the "Graphical Installer" `.pkg` file

3. Follow the Python 3 installation instructions. Make sure that the install location is set to **Install only for me** so Anaconda will install its files locally, relative to your home directory. Installing the software for all users tends to create problems in the long run and should be avoided.

:::::::::::::::::::::::::


:::::::::::::::: solution

### Linux

Note that the following installation steps require you to work from the shell.
If you run into any difficulties, please request help before the workshop begins.

1. Open [https://www.anaconda.com/download][anaconda-linux] with your web browser.

2. Download the Anaconda installer with Python 3 for Linux.

3. Open a terminal window and navigate to the directory where the executable is downloaded (e.g., `cd ~/Downloads`).

4. Type:

   ```bash
   bash Anaconda3-
   ```

   and press "Tab" to autocomplete the full file name. The name of file you just downloaded should appear.

5. Press "Enter" (or "Return" depending on your keyboard).

6. Follow the text-only prompts.  When the license agreement appears (a colon will be present at the bottom of the screen) press "Spacebar" until you see the bottom of the text. Type `yes` and press "Enter" to approve the license. Press "Enter" again to approve the default location for the files. Type `yes` and press "Enter" to prepend Anaconda to your `PATH` (this makes the Anaconda distribution your user's default Python).

7. Close the terminal window.

:::::::::::::::::::::::::

### Setting up the workshop environment from Anaconda
After installing Anaconda follow the steps below:
1. Open [https://raw.githubusercontent.com/carpentries-incubator/geospatial-python/main/files/environment.yaml][https://raw.githubusercontent.com/carpentries-incubator/geospatial-python/main/files/environment.yaml] in your web browser, right-click on the page, and select Save As... Keep the default name and click Save.
2. Open Anaconda-Navigator and click the **Environments** tab on the left of the GUI.
3. Then while on the **Environments** tab, from the bottom of the GUI click **Import**.
4. From the popup that appears, click the folder icon next to the local drive text field and choose the "environment.yaml" file downloaded earlier.
5. Accept the default name, then click the ""Import"" button from the popup and wait while the environment is created.
6. Now click the newly created **geospatial** environement. A play icon should appear next to it once activated.

### Setting up the workshop environment using conda

If Anaconda was properly installed, you should have access to the `conda`
command in your terminal (use the **Anaconda prompt** on **Windows**).

1. Test that `conda` is correctly installed by typing:

   ```bash
   conda --version
   ```

   which should print the version of conda that is currently installed, e.g. :

   ```output
   conda 22.9.0
   ```

2. Run the following command:

   ```bash
   conda install -c conda-forge mamba
   ```

   IMPORTANT: If your terminal responds to the above command with `conda: command not found` see the [Troubleshooting section](#troubleshooting-conda-command-not-found).

3. Create the Python environment for the workshop by running:

   ```bash
   mamba env create -n geospatial -f https://raw.githubusercontent.com/carpentries-incubator/geospatial-python/main/files/environment.yaml
   ```

   Note that this step can take several minutes.

4. When installation has finished you should see the following message in the terminal:

   ```output
   # To activate this environment, use
   #    $ conda activate geospatial
   #
   # To deactivate an active environment, use
   #    $ conda deactivate
   ```

5. Activate the `geospatial` environment:

   ```bash
   conda activate geospatial
   ```

If successful, the text `(base)` in your terminal prompt will now read
`(geospatial)` indicating that you are now in the Anaconda virtual environment
named `geospatial`. The command `which python` should confirm that we're using
the Python installation in the `geospatial` virtual environment. For example:

```bash
which python
```

```output
/Users/your-username/anaconda3/envs/geospatial/bin/python
```

IMPORTANT: If you close the terminal, you will need to reactivate this
environment with `conda activate geospatial` to use the Python libraries
required for the lesson and to start JupyterLab, which is also installed in the
`geospatial` environment.

### Starting JupyterLab from Anaconda-Navigator
With the **geospatial** virtual environment selected from the **Environements** tab:
Click the **Home** tab and then click the Launch button beneath JupyterLab.

Once you have launched JupyterLab, create a new Python 3 notebook, type the following code snippet in a cell and press the "Play" button:

```python
import rioxarray
```

### Starting JupyterLab from the Command Line

In order to follow the lesson, you should launch JupyterLab. After activating the
geospatial conda environment, enter the following command in your terminal (use the **Anaconda prompt** on **Windows**):

```bash
jupyter lab
```

Once you have launched JupyterLab, create a new Python 3 notebook, type the following code snippet in a cell and press the "Play" button:

```python
import rioxarray
```

If all the steps above completed successfully you are ready to follow along with the lesson!

### Troubleshooting `conda: command not found`

* **Mac OS and Linux users:**

  1. First, find out where Anaconda is installed.

     The typical install location is in your `$HOME` directory (i.e., `/Users/your-username/`) so use `ls ~` to check whether an `anaconda3` directory is present in your home directory:

     ```bash
     ls ~
     ```

     ```output
     Applications      Downloads       Pictures
     anaconda3         Library         Public
     Desktop           Movies
     Documents         Music
     ```

     If, like above, you see a directory called `anaconda3` in the output we're in good shape. If not, **contact the instructor for help**.

  2. Activate the `conda` command-line program by entering the following command:

     ```bash
     source ~/anaconda3/bin/activate
     ```
     If all goes well, nothing will print to the terminal and your prompt will now have `(base)` floating around somewhere
     on the left. This is an indication that you are in the base Anaconda environment.

     Continue from the beginning of step 3 to complete the creation of the `geospatial` virtual environment.


[anaconda]: https://www.anaconda.com/
[anaconda-mac]: https://www.anaconda.com/download/#macos
[anaconda-linux]: https://www.anaconda.com/download/#linux
[anaconda-windows]: https://www.anaconda.com/download/#windows
[python]: https://python.org
[video-mac]: https://www.youtube.com/watch?v=TcSAln46u9U
[video-windows]: https://www.youtube.com/watch?v=xxQ0mzZ8UvA

