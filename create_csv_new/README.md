# create_csv_new

More to come, but for now ...


Legacy points CSV data file, `points_2012_to_2020_legacy.csv`, is copied here from `create_csv_archive`.

New event CSV result files are put into folders containing one or more CSV files.

Each time a new event data folder is added, the PowerQuery script in `power_query.xlsx` is run
to add the new folder's data to the existing 'latest' CSV file, including the generation of new Competitor IDs.

New Competitor IDs are generated in the PowerQuery script on the 'new_competitors' sheet. As of 2023/11/13 the starting index must be manually updated. This is done in Excel on the Data ribbon click Get Data then Open Power Query Editor. Make sure it is on the 'new_competitors' query. On the right-hand side, the step 'Added Index' has a function equation where the starting value (inclusive) is manually entered.

Prior to 2023/11/13, the sheet 'all_competitors' would list duplicates for first-time CTST competitors with their newly generated Competitor ID and the default value of 99999.
As of 2023/11/13, the query 'all_competitors' was given an additional step of 'Filtered Rows' where Rows with a Competitor ID not equal to 99999 were kept.

As of 2023/11/13, the 'all_results' data table is formed by combining 'previous_results' with 'all_new_results_numbered'. The necessity of this query remains to be seen. Additionally, when changes are made to the query and data is refreshed, the 'previous_results' have become the erroneous data. Currently, the sheet 'all_new_results_numbered' was used in place of 'all_results'.

Prior to 2023/11/13, the `all_results` data table in the `power_query.xlsx` file is saved to a CSV file with the same name as
the folder that was used to add the new data.

After the new CSV file has been saved from the `power_query.xlsx` script, it is copied to the file, `points_latest.csv`.

The `points_latest.csv` file can then be used as input to the PowerQuery script, `create_db_tables.xlsx` file
in the `create_db_tables` directory to generate the master database tables.
