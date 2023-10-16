# Convert PDF Points Registry data to combined CSV (old data) file

All files in this directory exist to extract legacy CTST Points data from the two input files:
- `CTST_Points_Registry_Mens_1142020.pdf` (110 pages)
- `CTST_Points_Registry_Ladies_1142020.pdf` (133 pages)

and output the extracted data to a single CSV file:

- `points_2012_to_2020_legacy.csv` (3,476 result records)

---

To generate a single CSV file (`points_2012_to_2020_legacy.csv`) from the legacy Points Registry Men's and Women's PDF files:

## Download the archived legacy CTST Point Registry PDF files
- `CTST_Points_Registry_Mens_1142020.pdf`
- `CTST_Points_Registry_Ladies_1142020.pdf`

## Convert the PDF files to plain text `.txt` files
- Open each file using the **Microsoft Edge** web browser (data copied using other browsers will not work using these scripts)
- Select all text: <kbd>Ctrl</kbd> + <kbd>A</kbd>
- Copy selected text: <kbd>Ctrl</kbd> + <kbd>C</kbd>
- Paste the copied text into a text editor: <kbd>Ctrl</kbd> + <kbd>V</kbd>

## Convert and combine the `.txt` files to a `.csv` file using the conversion script

```bash
./convert_txt_to_csv.sh -l CTST_Points_Registry_Mens_1142020.txt -f CTST_Points_Registry_Ladies_1142020.txt -o points_2012_to_2020_legacy.csv
```

or, use the following helper script to run the above command:

```bash
./run.sh
```

These Bash scripts can run on Linux, or on Windows using Git Bash/Cygwin/MinGW/WSL, etc.

The script makes the following changes to the original legacy data:

- Split competitor names into separate Last Name and First Name fields for easier data analysis
- Use consistent naming for events and their locations to allow easier data analysis
- Replace event year with date to allow events to be sorted chronologically within each year
- Source the `corrections.sh` script to fix errors in competitors' points data

Copy the resulting `points_2012_to_2020_legacy.csv` file (old, combined data for both Leaders and Followers)
into the `create_csv_new` directory. This legacy data can then be combined with the new (post-2020) event data
to construct the master database.

In the `create_db_tables` directory is an Excel workbook that uses [Power Query](https://learn.microsoft.com/en-us/power-query/power-query-what-is-power-query) to read the CSV files in `create_csv_new` and construct the master database as a set of relational, normalized data tables in the `db_tables_MASTER` directory.

## Corrections made to Competitor Points

`corrections.sh` script (sourced from `convert_txt_to_csv.sh`):

```
2013 MidAtlantic Intermediate 4th Place Follower. Change Sheila Lancelona to Sheila Lancelotta

2013 Colorado Novice 1st Place Follower. Add Nicole Szule (752) with 10 Points

2013 Albuquerque Novice 9th Place Leader. Move Paul Stepenaski (312) from 8th Place to 9th Place with 0 Points
2013 Albuquerque Novice 9th Place Follower. Move Kat Flies (270) from 8th Place to 9th Place with 0 Points

2014 Portland Novice 2nd Place Leader. Add Jacob Hellisgo (965) with 4 Points

2014 Palm Springs Novice 3rd Place Follower. Change Julie Grubb (649) to Julie Gubb (1302) with 3 Points

2014 Paradise Masters 2nd Place Follower. Add Linda Lyles (480) with 0 Points

2015 Colorado Intermediate 5th Place Leader. Change Norm Caldwell (799) from Follower to Leader with 1 Point

2015 Peach State Advanced 1st Place Leader. Move Stuart Palmer (122) from Intermediate to Advanced with 0 Points
2015 Peach State Advanced 2nd Place Leader. Move Jim Rainey (755) from Intermediate to Advanced with 0 Points
2015 Peach State Advanced 3rd Place Leader. Move Andrew Sinclair (757) from Intermediate to Advanced with 0 Points
2015 Peach State Advanced 4th Place Leader. Move Stuart Palmer (122) from Intermediate to Advanced with 0 Points
2015 Peach State Advanced 5th Place Leader. Move Jim Rainey (755) from Intermediate to Advanced with 0 Points
2015 Peach State Advanced 1st Place Follower. Move Debbie Wachsberg (542) from Intermediate to Advanced with 5 Points
2015 Peach State Advanced 2nd Place Follower. Move Kelli Rainey (756) from Intermediate to Advanced with 4 Points
2015 Peach State Advanced 3rd Place Follower. Move Christy Kam (289) from Intermediate to Advanced 3 Points
2015 Peach State Advanced 4th Place Follower. Move Raquel Williams (568) from Intermediate to Advanced 2 Points
2015 Peach State Advanced 5th Place Follower. Move Kimberly Yee (369) from Intermediate to Advanced 1 Point

2015 South Bay Intermediate 5th Place Leader. Replace Pam Giles (110) with John Sai (790) with 1 Point

See http://steprightsolutions.com/events/frezno2016/round/1691
2016 FreZno Novice 8th Place Leader. Remove Robert Beckler (203) with 1 Point
2016 FreZno Novice 8th Place Follower. Add Jacqueline Welch (1400) with 1 Point

2016 Paradise Masters 1st Place Follower. Replace Charles Williams (490) with Cheryl Williams (825) with 0 Points

2017 Worlds Novice 9th Place Follower. Add Theresa Cinciripini (839) with 1 Point

2017 San Diego Advanced 2nd Place Follower. Replace Charles Williams (490) with Cheryl Williams (825) with 4 Points

2017 Indianapolis Intermediate 1st Place Leader. Move Gene Kashak (930) from Intermediate to Masters with 0 Points
2017 Indianapolis Intermediate 2nd Place Leader. Move Richard Patterson (816) from Intermediate to Masters with 0 Points
2017 Indianapolis Intermediate 3rd Place Leader. Move Wally Markovic (739) from Intermediate to Masters with 0 Points
2017 Indianapolis Intermediate 4th Place Leader. Move David Rose (611) from Intermediate to Masters with 0 Points
2017 Indianapolis Intermediate 1st Place Follower. Move Debbie Eubanks (547) from Intermediate to Masters with 0 Points
2017 Indianapolis Intermediate 2nd Place Follower. Move  Celia Reuss (1094) from Intermediate to Masters with 0 Points
2017 Indianapolis Intermediate 3rd Place Follower. Move Julie Roisen (1095) from Intermediate to Masters with 0 Points
2017 Indianapolis Intermediate 4th Place Follower. Move Jessie Garringer (809) from Intermediate to Masters with 0 Points

2017 South Bay Novice 5th Place Leader. Replace Marilyn Hall (634) with Elgin Santos (1063) with 1 Points

2017 Paradise Masters 5th Place Follower. Replace Charles Williams (490) with Cheryl Williams (825) with 0 Points

2018 High Desert Intermediate 1st Place Leader. Add Cliff Housego (376) with 5 Points

2018 San Diego Advanced 1st Place Leader. Change Patrick Plagens (125) from 1st place to 5th Place with 1 Point
2018 San Diego Advanced 1st Place Follower. Change Tasha Hoffner (596) from 1st place to 5th Place with 1 Point
2018 San Diego Advanced 2nd Place Leader. Change Craig Johnson (112) from 2nd place to 4th Place with 2 Points
2018 San Diego Advanced 2nd Place Follower. Change Carrie Lucas (1065) from 2nd place to 4th Place with 2 Points

2018 FreZno Novice 2nd Place Follower. Change Jenna Krova (1181) to Jenna Korver (1221)
2018 FreZno Advanced 7th Place Leader. Replace Sarah Wolfe (138) with Mike Eads (238) with 1 Point

2019 Calgary Novice 4th Place Leader. Add Katrina Southernwood (1401) with 2 Points

2019 San Diego Advanced 2nd Place Follower. Change Julie Grubb (649) to Julie Gubb (1302) with 4 Points

Points for Fresno 2019 Novice Followers were incorrectly awarded as Tier 2, instead of Tier 3
There were 32 followers, see: http://steprightsolutions.com/events/frezno2019/round/3335
2019 FreZno Novice 1st Place Follower. Change Points for Marsue May (1256) from 10 Points to 15 Points
2019 FreZno Novice 2nd Place Follower. Change Points for Theresa Colberg (1257) from 8 Points to 12 Points
2019 FreZno Novice 3rd Place Follower. Change Points for Rachel Moran (1258) from 6 Points to 10 Points
2019 FreZno Novice 4th Place Follower. Change Points for Carin Stoker (1109) from 4 Points to 8 Points
2019 FreZno Novice 5th Place Follower. Change Points for Anna-Lena Clark (1216) from 2 Points to 6 Points
2019 FreZno Novice 11th Place Follower. Add Stacy Thorp (1402) with 1 Point
2019 FreZno Novice 12th Place Follower. Add Carol Locke (1403) with 1 Point
2019 FreZno Novice 13th Place Follower. Add Ashlee Reynolds (674) with 1 Point
2019 FreZno Novice 14th Place Follower. Add Nikki Adams (1301) with 1 Point

2019 Portland Advanced 5th Place Follower. Replace Charles Williams (490) with Cheryl Williams (825) with 1 Point
2019 Portland Masters 1st Place Follower. Replace Charles Williams (490) with Cheryl Williams (825) with 0 Points

2019 Paradise Intermediate 4th Place Follower. Replace Larry Sanders (362) with Lisa Sandoval (583) with 2 Points
2019 Paradise Advanced 5th Place Leader. Replace Jean Ann Taylor (924) with Jonathan Taylor (968) with 1 Point
2019 Paradise Masters 4th Place Follower. Replace Larry Sanders (362) with Lisa Sandoval (583) with 0 Points

2020 Worlds Masters 1st Place Leader. Replace David Rose (611) with Dennis Rose (1404) with 0 Points
```

## Competitor numbers from 1400 were assigned to competitors omitted from the legacy Points Registry

```
2016 FreZno Novice 8th Place Follower. Add Jacqueline Welch (1400) with 1 Point
2019 Calgary Novice 4th Place Leader. Add Katrina Southernwood (1401) with 2 Points
2019 FreZno Novice 11th Place Follower. Add Stacy Thorp (1402) with 1 Point
2019 FreZno Novice 12th Place Follower. Add Carol Locke (1403) with 1 Point
2020 Worlds Masters 1st Place Leader. Add Dennis Rose (1404) with 0 Points
```