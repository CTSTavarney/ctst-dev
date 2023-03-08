# generate_website

Create a static web site for viewing/searching the CTST Points data.

The web site files are contained in the `www` directory.

The `www` directory contains static files (html, js, etc.), as well as a `data` directory.

The `wwww/data` directory contains json index files for competitor, event, and points data,
as well as individual html files with the details of each competitor, event, and points year.

To create the web site data files in `www/data`, run the Python 3 script, `create_www_data.py`.

The script requires the [pandas](https://pandas.pydata.org/) and [numPy](https://numpy.org/) libraries to be installed.

The files in the `www` directory can then be copied to the web root of the production web site.
