# Country Two Step Tour (CTST) Points Database

This project aims to provide a searchable database/web site containing CTST Points Registry data. For now, the web site is hosted on GitHub Pages at: https://ctstpoints.github.io/

This project can be used in the interim to access CTST points data until the new, official CTST web site/database is developed.

Currently, only data from the legacy CTST Points Registry (dated January 14, 2020) is used, which includes all CTST events up to and including the 2020 UCWDC World Championships. Hopefully, the data from all subsequent CTST contests will soon be available, at which time this data/web site will be updated.

**DISCLAIMER: All data contained herein has been obtained from publically-accessible sources, primarily data published by the Country Two Step Tour. This data is not the "official" contest result data. The respective Event Directors and their official score-keepers maintain the "official" contest results. Therefore, expect errors and omissions in the CTST data used by this project.**

This is the development repository, https://github.com/ctstpoints/ctst-dev. Other GitHub repositories are used to host web sites on GitHub Pages:
- https://github.com/ctstpoints/ctstpoints.github.io [The new CTST Points Database web site]
- https://github.com/ctstpoints/ctst-archive [An archived copy of the legacy `countrytwosteptour.com` web site]

Summary of steps involved in creating the project:

1. Acquire the legacy Points Registry data (from archived PDF files) [[README]](archived_docs/README.md)
2. Convert each PDF Points Registry data file into a plain text file (copy/paste from Edge browser)
3. Convert the plain text files into a single, combined CSV file, with corrections (Bash/sed/awk scripts) [[README]](create_csv_from_archive/README.md)
4. Convert the combined CSV file into an Excel Workbook containing normalized data tables in separate Worksheets (Excel/[Power Query](https://learn.microsoft.com/en-us/power-query/power-query-what-is-power-query)) [[README]](create_db_tables/README.md)
5. Manually save each Excel data table worksheet as a CSV file; this CSV collection becomes the Master database (`db_tables_MASTER`) (Excel/Save As)
6. Generate a static, searchable web site from the CSV Master database files (Python/[pandas](https://pandas.pydata.org/) script) [[README]](generate_website/README.md)
7. Copy the static web site files (`ctstpoints\ctst-dev\generate_website\www\*`) to the production web root repository (`ctstpoints\ctstpoints.github.io\`)
8. Push the production web site repository to GitHub Pages and deploy (`git push`)

For further detailed explanation of the steps involved, see the README files in each directory.
