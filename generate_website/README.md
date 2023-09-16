# generate_website

Create a static web site for viewing/searching the CTST Points data.

The web site files are contained in the `www` directory.

The `www` directory contains static files (html, css, js, etc.), as well as a `data` directory.

The `wwww/data` directory contains json index files for competitor, event, and points data,
as well as individual html files with the details of each competitor, event, and points year.

To create the web site data files in `www/data`, run the Python 3 script, `create_www_data.py`.

The script requires the [pandas](https://pandas.pydata.org/) and [numPy](https://numpy.org/) libraries to be installed.

Hint: Before re-generating the static web site, delete all existing files in the `www` subdirectories:
`competitors`, `events`, and `points`.

Hint: If using Visual Studio Code, open the `generate_website` directory, then open the file: `create_www_data.py`,
install recommended VSCode Python extensions,
create a virtual environment (Ctrl+Shift+P then 'Python: Create Environment...' then specify to create a `venv` environment
using the `requirements.txt` file). Then execute the Python script.

The files in the `www` directory can then be copied to the web root of the production web site.
