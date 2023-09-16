# Country Two Step Tour (CTST) Points Database

This project provides a searchable database/web site containing up-to-date CTST Points Registry data. For now, the web site is hosted on GitHub Pages at: https://ctstpoints.github.io/

This project can be linked-to from the official CTST web site, https://countrytwosteptour.com/ (see https://countrytwosteptour.com/index.php/ctst-points-registry/).

Initially, only data from the legacy CTST Points Registry (dated January 14, 2020) was used, which included all CTST events up to and including the 2020 UCWDC World Championships. Subsequently, data from later CTST events has been added. Going forward, the data will be updated as soon
as new Contest result data has been obtained for each Event.

**DISCLAIMER: The data contained herein for events up to 2020 has been obtained from publically-accessible sources, primarily data published by the Country Two Step Tour. This data is not the "official" contest result data. The respective Event Directors and their official score-keepers maintain the "official" contest results. Therefore, expect errors and omissions in the CTST data used by this project. Going forward, the data used should be as accurate
as the data provided to the CTST from the respective event directors.**

This is the development repository, https://github.com/ctstpoints/ctst-dev. Other GitHub repositories are used to host web sites on GitHub Pages:
- https://github.com/ctstpoints/ctstpoints.github.io -- This Points Database web site
- https://github.com/ctstpoints/ctst-archive  -- An archived copy of the legacy `countrytwosteptour.com` web site

Summary of steps involved in creating the project:

1. Acquire the legacy Points Registry data (from Men's and Women's archived PDF Points Registry files) [[README]](archived_docs/README.md)
2. Convert each PDF Points Registry data file into a plain text file (copy/paste from Microsoft Edge browser)
3. Convert the plain text files into a single, combined CSV file (containing both Leader and Follower points), with corrections (Bash/sed/awk scripts) [[README]](create_csv_from_archive/README.md)
4. Convert the combined CSV file into an Excel Workbook containing normalized data tables in separate Worksheets (Excel/[Power Query](https://learn.microsoft.com/en-us/power-query/power-query-what-is-power-query)) [[README]](create_db_tables/README.md)
5. Manually save each Excel data table worksheet as a CSV file; this CSV collection becomes the Master database (`db_tables_MASTER`) (Excel/Save As)
6. Generate a static, searchable web site from the CSV Master database files (Python/[pandas](https://pandas.pydata.org/) script) [[README]](generate_website/README.md)
7. Copy the static web site files (`ctstpoints\ctst-dev\generate_website\www\*`) to the production web root repository (`ctstpoints\ctstpoints.github.io\`)
8. Push the production web site repository to GitHub Pages and deploy (`git push`)
9. For events after 2020, the `create_csv_new` directory is used to store a CSV file for each event, from which new
Competitor IDs are assigned, files combined, then merged into the master database using PowerQuery. [[README]](create_csv_new/README.md)
10. Processes for entering data from future events are under consideration

For further detailed explanation of the steps involved, see the README files in each directory.
