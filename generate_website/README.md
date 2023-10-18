# generate_website

Create a static web site for viewing/searching the CTST Points Registry.

The web site files are contained in the `www` directory.

The `www` directory contains static files (html, css, etc.), as well as a `www/data` directory.

The `wwww/data` directory contains json index files for competitor, event, and point rankings,
as well as individual html files with the details of each competitor, event, and points year.

To create the web site data files in `www/data`, run the Python script, `create_www_data.py` (requires **Python 3**).

The script requires the [pandas](https://pandas.pydata.org/) and [numPy](https://numpy.org/) libraries to be installed.

The script must be run from the project's `generate_website` directory.
This directory's parent directory must contain a sub-directory, `db_tables_MASTER`, that contains the database CSV files.

Hint: Before re-generating the static web site, delete all existing files in the `www/data/` sub-directory.

Hint: If using Visual Studio Code, open the `generate_website` directory (not the project directory or www directory), then open the file: `create_www_data.py`,
install recommended VSCode Python extensions,
create a virtual environment (Ctrl+Shift+P then 'Python: Create Environment...' then specify to create a `venv` environment
using the `requirements.txt` file). Then execute the Python script.

The files in the `www` directory can then be copied to the web root of the production web site, or deployed to run on [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages)
