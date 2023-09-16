# create_csv_new

More to come, but for now ...


Legacy points CSV data file, `points_2012_to_2020_legacy.csv`, is copied here from `create_csv_archive`.

New event CSV result files are put into folders containing one or more CSV files.

Each time a new event data folder is added, the PowerQuery script in `power_query.xlsx` is run
to add the new folder's data to the existing 'latest' CSV file, including the generation of new Competitor IDs.
The `all_results` data table in the `power_query.xlsx` file is saved to a CSV file with the same name as
the folder that was used to add the new data.

After the new CSV file has been saved from the `power_query.xlsx` script, it is copied to the file, `points_latest.csv`.

The `points_latest.csv` file can then be used as input to the PowerQuery script, `create_db_tables.xlsx` file
in the `create_db_tables` directory to generate the master database tables.
