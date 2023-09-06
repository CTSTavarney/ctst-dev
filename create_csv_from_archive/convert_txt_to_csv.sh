#!/bin/bash

#
# convert_txt_to_csv.sh
#
# Convert text files containing legacy CTST Points Registry text data for both leaders and followers into a single CSV file.
#

# Script must be run with exactly 3 arguments: the leaders' points text file, the followers' points text file, and the combined output CSV file:
# ./convert_txt_to_csv.sh \
#    --leadertxt=CTST_Points_Registry_Mens_1142020.txt \
#    --followertxt=CTST_Points_Registry_Ladies_1142020.txt \
#    --outcsv=points_combined.csv
#

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function usage() {
    echo "Usage: ${0} LEADER_TXT FOLLOW_TXT OUT_CSV"
    echo "LEADER_TXT    --leadertxt=<file>   | -l <file>"
    echo "FOLLOWER_TXT  --followertxt=<file> | -f <file>"
    echo "OUT_CSV       --outcsv=<file>      | -o <file>"
    exit 1
}

getopt --test &> /dev/null
if [ $? -ne 4 ]
then
    echo "Latest version of getopt from util-linux is not installed. Exiting ..." >&2
    exit 1
fi

GETOPT_ARGS=$(getopt --alternative --options 'l:f:o:h' --longoptions 'followertxt:,leadertxt:,outcsv:,help' -- "${@}")
if [ $? -ne 0 ]
then
    echo "getopt error $?. Exiting ..." >&2
    exit 1
fi

eval set -- "${GETOPT_ARGS}"

while [ $# -gt 0 ]
do
    case "${1}" in
        '-h' | '--help' )
            usage
            exit
            ;;
        '-l' | '--leadertxt' )
            LEADER_TXT="${2}"
            shift 2
            ;;
        '-f' | '--followertxt' )
            FOLLOWER_TXT="${2}"
            shift 2
            ;;
        '-o' | '--outcsv' )
            OUT_CSV="${2}"
            shift 2
            ;;
        '--' )
            shift
            ;;
        * )
            echo "Unknown arguments: ${*}. Exiting ..." >&2
            exit 1
            ;;
    esac
done

if [ -z "${LEADER_TXT}" ] || [ -z "${FOLLOWER_TXT}" ] || [ -z "${OUT_CSV}" ]
then
    usage
    exit
fi

# Make sure the input files exist
if [ ! -f "${LEADER_TXT}" ]
then
    echo "${LEADER_TXT} is not a valid file"
    exit 1
fi

if [ ! -f "${FOLLOWER_TXT}" ]
then
    echo "${FOLLOWER_TXT} is not a valid file"
    exit 1
fi

function txtToCSV() {
    TXTFILE="${1}"
    CSVFILE="${2}"

    cp "${TXTFILE}" "${CSVFILE}"

    # Remove the document header (all lines up to and including the first page header line)
    sed -i -E '0,/Name Event Location Year Division Place Points/d' "${CSVFILE}"

    # Remove all page headers
    sed -i -E '/Name Event Location Year Division Place Points/d' "${CSVFILE}"

    # Remove all lines containing "Country Two Step Tour" or "Points Registry"
    sed -i -E -e '/Country Two Step Tour/d' -e '/Points Registry/d' "${CSVFILE}"

    # Delete all lines containing a date followed by a number (page footer), e.g. 12/30/2020 42
    sed -i -E '/[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4} [0-9]{1,3}/d' "${CSVFILE}"

    # Remove any line containing "Total" (e.g. Total Of All Points 12)
    sed -i -E '/Total/d' "${CSVFILE}"

    # Some Year fields are preceded by a spurious comma; replace these commas with a space
    sed -i -E 's/,[ ]*([0-9]{4})/ \1/' "${CSVFILE}"

    # Insert a semicolon after each competitor number (3 or 4 digits at the end of a line in lines containing a comma)
    sed -i -E '/[A-Z].*,.*[A-Z].*[0-9]{3,4}$/ s/$/;/' "${CSVFILE}"

    # Join any line ending with a semicolon (competitor name and number) with the next line
    # N => appends line from the input file to the pattern space
    sed -i -E '/;$/ { N; s/\n// }' "${CSVFILE}"

    # Append a '%' character to all lines NOT ending in two space-separated numbers (position & points)
    sed -i -E '/( [0-9]{1,2} [0-9]{1,2})$/ !s/$/%/' "${CSVFILE}"

    # Join all the %-terminated lines, also replacing % with space
    # N => appends line from the input file to the pattern space
    sed -i -E ':loop /%$/ { s/%/ /g; N; s/\n//g; bloop }' "${CSVFILE}"

    # Strip all space characters immediately preceding each comma, and ensure only one space following the comma
    sed -i -E 's/[ ]*,[ ]*/, /g' "${CSVFILE}"

    # Insert the preceding competitor name/number at the start of each line not containing a competitor name/number:
    # Act on lines containing a semicolon (<competitor name> <semicolon> <number>)
    # h => copy pattern buffer into hold buffer
    # s => strip everything after first semicolon from pattern buffer
    # x => swap hold buffer and pattern buffer (hold buffer now contains only competitor name and number)
    # b => branch (start new cycle, continuing until next line encountered that does not contain a semicolon)
    # Will only continue to the next instructions in lines that do not contain a semicolon
    # G => appends line from the hold space to the pattern space, with a newline before it
    # s => now competitor number is at the end of the next line, so move it to start of line, removing \n character
    sed -i -E '/;/ { h; s/([^;]*;).*/\1/; x; b }; G; s/^([^\n]*)\n(.*)$/\2\1/' "${CSVFILE}"

    # Fix spurious error in original PDF - division name "Masters" missing for:
    # 'Connery-Walkup,Trish 108 Paradise Country Swing Dance Festival Irvine,CA 2017 1 0'
    sed -i -E 's/( [0-9]{4})( [0-9] [0-9])$/\1 Masters\2/' "${CSVFILE}"

    # Insert ';' characters to delimit Year, Division, Placement, Points
    sed -i -E 's/( )([0-9]{4})( )(.+)( )([0-9]{1,3})( )([0-9]{1,2}$)/;\2;\4;\6;\8/' "${CSVFILE}"

    # Insert ';' between competitor name and number
    sed -i -E 's/^([^0-9]+)([0-9]{3,4})/\1;\2/; s/ ;/;/g' "${CSVFILE}"
}


OUT_CSV_LEADER_TMP=$(mktemp)
txtToCSV "${LEADER_TXT}" "${OUT_CSV_LEADER_TMP}"
sed -i -E 's/^/L;/' "${OUT_CSV_LEADER_TMP}"

OUT_CSV_FOLLOWER_TMP=$(mktemp)
txtToCSV "${FOLLOWER_TXT}" "${OUT_CSV_FOLLOWER_TMP}"
sed -i -E 's/^/F;/' "${OUT_CSV_FOLLOWER_TMP}"

cat "${OUT_CSV_LEADER_TMP}" "${OUT_CSV_FOLLOWER_TMP}" > "${OUT_CSV}"


# Move the Year column before the Event column
OUT_CSV_TMP=$(mktemp)
awk 'BEGIN { FS=";"; OFS=";" }; { temp=$4; $4=$5; $5=temp; print; }' "${OUT_CSV}" > "${OUT_CSV_TMP}"
cp "${OUT_CSV_TMP}" "${OUT_CSV}"

# Insert CSV Header before line 1
sed -i -E '1 i Role\;Competitor Name\;Competitor ID\;Event Date\;Event Name\;Event Location\;Division\;Result\;Points' "${OUT_CSV}"

# Apply consistent event naming
sed -i -E \
-e 's/(.*;).*ACDA[^;]*(;.*)/\1ACDA Championships, Fort Worth, TX\2/I' \
-e 's/(.*;).*Arizona[^;]*(;.*)/\1Arizona Dance Classic, Mesa, AZ\2/I' \
-e 's/(.*;).*Calgary[^;]*(;.*)/\1Calgary Dance Stampede, Calgary, AB\2/I' \
-e 's/(.*;).*Colorado[^;]*(;.*)/\1Colorado Country Classic, Denver, CO\2/I' \
-e 's/(.*;).*Dallas Dance[^;]*(;.*)/\1Dallas Dance Festival, Dallas, TX\2/I' \
-e 's/(.*;).*Chicago[^;]*(;.*)/\1Dance Camp Chicago, Elmhurst, IL\2/I' \
-e 's/(.*;).*FreZno[^;]*(;.*)/\1FreZno Dance Classic, Fresno, CA\2/I' \
-e 's/(.*;).*Harrisburg[^;]*(;.*)/\1Halloween in Harrisburg, Harrisburg, PA\2/I' \
-e 's/(.*;).*Desert[^;]*(;.*)/\1High Desert Classic, Lancaster, CA\2/I' \
-e 's/(.*;).*Hoe.*Down[^;]*(;.*)/\1Texas Hoedown, Fort Worth, TX\2/I' \
-e 's/(.*;).*Indy Dance[^;]*(;.*)/\1Indy Dance Explosion, Indianapolis, IN\2/I' \
-e 's/(.*;).*Vegas[^;]*(;.*)/\1Las Vegas Finale, Las Vegas, NV\2/I' \
-e 's/(.*;).*Lone[ ]*Star[^;]*(;.*)/\1Lone Star Invitational, Austin, TX\2/I' \
-e 's/(.*;).*Louisiana[^;]*(;.*)/\1Louisiana Hayride, Alexandria, LA\2/I' \
-e 's/(.*;).*Atlantic[^;]*(;.*)/\1MidAtlantic Classic, Herndon, VA\2/I' \
-e 's/(.*;).*Magic[^;]*(;.*)/\1Mountain Magic, Lake Tahoe, NV\2/I' \
-e 's/(.*;).*New Mexico[^;]*(;.*)/\1New Mexico Fiesta, Albuquerque, NM\2/I' \
-e 's/(.*;).*Palm Springs Swing Dance[^;]*(;.*)/\1Palm Springs New Year, Palm Springs, CA\2/I' \
-e 's/(.*;).*Paradise.*Bernardino[^;]*(;.*)/\1Paradise Festival, Ontario, CA\2/I' \
-e 's/(.*;).*Paradise.*Ontario[^;]*(;.*)/\1Paradise Festival, Ontario, CA\2/I' \
-e 's/(.*;).*Paradise.*Orange[^;]*(;.*)/\1Paradise Festival, Orange Co, CA\2/I' \
-e 's/(.*;).*Paradise.*Irvine[^;]*(;.*)/\1Paradise Festival, Orange Co, CA\2/I' \
-e 's/(.*;).*Peach[^;]*(;.*)/\1Peach State Festival, Atlanta, GA\2/I' \
-e 's/(.*;).*Portland[^;]*(;.*)/\1Portland Dance Festival, Portland, OR\2/I' \
-e 's/(.*;).*Edmonton[^;]*(;.*)/\1River City Festival, Edmonton, AB\2/I' \
-e 's/(.*;).*San Diego[^;]*(;.*)/\1San Diego Festival, San Diego, CA\2/I' \
-e 's/(.*;).*South Bay[^;]*(;.*)/\1South Bay Dance Fling, San Jose, CA\2/I' \
-e 's/(.*;).*Summer.*Palm Springs[^;]*(;.*)/\1Palm Springs Summer, Palm Springs, CA\2/I' \
-e 's/(.*;).*Texas Classic[^;]*(;.*)/\1Texas Classic, Houston, TX\2/I' \
-e 's/(.*;).*World.*San Francisco[^;]*(;.*)/\1UCWDC World\x27s, San Francisco, CA\2/I' \
-e 's/(.*;).*UCWDC.*Nashville[^;]*(;.*)/\1UCWDC World\x27s, Nashville, TN\2/I' \
-e 's/(.*;).*UCWDC.*Orlando[^;]*(;.*)/\1UCWDC World\x27s, Orlando, FL\2/I' \
-e 's/(.*;).*Waltz[^;]*(;.*)/\1Waltz Across Texas, Houston, TX\2/I' \
"${OUT_CSV}"

# Create separate fields for Event Name and Event Location
sed -i -E 's/(^.*), ([^,]+,.*$)/\1;\2/' "${OUT_CSV}"

# It's hard to order events on year alone, so update all events with the actual date
sed -i -E \
-e '/FreZno Dance Classic/ s/;2012;/;2012-05-24;/' \
-e '/Colorado Country Classic/ s/;2012;/;2012-06-24;/' \
-e '/Portland Dance Festival/ s/;2012;/;2012-07-13;/' \
-e '/Arizona Dance Classic/ s/;2012;/;2012-08-03;/' \
-e '/South Bay Dance Fling/ s/;2012;/;2012-08-30;/' \
-e '/River City Festival/ s/;2012;/;2012-09-21;/' \
-e '/New Mexico Fiesta/ s/;2012;/;2012-09-27;/' \
-e '/Paradise Festival/ s/;2012;/;2012-10-11;/' \
-e '/Las Vegas Finale/ s/;2012;/;2012-11-29;/' \
-e '/UCWDC World\x27s/ s/;2013;/;2013-01-01;/' \
-e '/Peach State Festival/ s/;2013;/;2013-03-14;/' \
-e '/MidAtlantic Classic/ s/;2013;/;2013-04-04;/' \
-e '/FreZno Dance Classic/ s/;2013;/;2013-05-23;/' \
-e '/Colorado Country Classic/ s/;2013;/;2013-06-27;/' \
-e '/Portland Dance Festival/ s/;2013;/;2013-07-11;/' \
-e '/Arizona Dance Classic/ s/;2013;/;2013-08-02;/' \
-e '/South Bay Dance Fling/ s/;2013;/;2013-08-29;/' \
-e '/New Mexico Fiesta/ s/;2013;/;2013-09-26;/' \
-e '/Paradise Festival/ s/;2013;/;2013-10-17;/' \
-e '/Halloween in Harrisburg/ s/;2013;/;2013-10-25;/' \
-e '/Dallas Dance Festival/ s/;2013;/;2013-11-07;/' \
-e '/Las Vegas Finale/ s/;2013;/;2013-12-05;/' \
-e '/UCWDC World\x27s/ s/;2014;/;2014-01-01;/' \
-e '/Peach State Festival/ s/;2014;/;2014-03-20;/' \
-e '/Calgary Dance Stampede/ s/;2014;/;2014-04-24;/' \
-e '/MidAtlantic Classic/ s/;2014;/;2014-05-08;/' \
-e '/Texas Classic/ s/;2014;/;2014-05-15;/' \
-e '/FreZno Dance Classic/ s/;2014;/;2014-05-26;/' \
-e '/Colorado Country Classic/ s/;2014;/;2014-06-26;/' \
-e '/Indy Dance Explosion/ s/;2014;/;2014-07-03;/' \
-e '/Portland Dance Festival/ s/;2014;/;2014-07-11;/' \
-e '/Palm Springs Summer/ s/;2014;/;2014-08-14;/' \
-e '/South Bay Dance Fling/ s/;2014;/;2014-08-28;/' \
-e '/New Mexico Fiesta/ s/;2014;/;2014-09-25;/' \
-e '/Paradise Festival/ s/;2014;/;2014-10-16;/' \
-e '/Mountain Magic/ s/;2014;/;2014-10-30;/' \
-e '/Dallas Dance Festival/ s/;2014;/;2014-11-06;/' \
-e '/Las Vegas Finale/ s/;2014;/;2014-12-04;/' \
-e '/UCWDC World\x27s/ s/;2015;/;2015-01-01;/' \
-e '/Palm Springs New Year/ s/;2015;/;2015-01-02;/' \
-e '/Dance Camp Chicago/ s/;2015;/;2015-02-27;/' \
-e '/High Desert Classic/ s/;2015;/;2015-03-13;/' \
-e '/Peach State Festival/ s/;2015;/;2015-03-19;/' \
-e '/Texas Hoedown/ s/;2015;/;2015-03-27;/' \
-e '/Calgary Dance Stampede/ s/;2015;/;2015-04-09;/' \
-e '/Louisiana Hayride/ s/;2015;/;2015-04-24;/' \
-e '/FreZno Dance Classic/ s/;2015;/;2015-05-21;/' \
-e '/Colorado Country Classic/ s/;2015;/;2015-06-25;/' \
-e '/Indy Dance Explosion/ s/;2015;/;2015-07-03;/' \
-e '/Portland Dance Festival/ s/;2015;/;2015-07-10;/' \
-e '/Lone Star Invitational/ s/;2015;/;2015-08-07;/' \
-e '/South Bay Dance Fling/ s/;2015;/;2015-09-03;/' \
-e '/New Mexico Fiesta/ s/;2015;/;2015-09-24;/' \
-e '/Waltz Across Texas/ s/;2015;/;2015-10-09;/' \
-e '/Paradise Festival/ s/;2015;/;2015-10-22;/' \
-e '/Mountain Magic/ s/;2015;/;2015-11-05;/' \
-e '/Dallas Dance Festival/ s/;2015;/;2015-11-12;/' \
-e '/ACDA Championships/ s/;2015;/;2015-11-20;/' \
-e '/Las Vegas Finale/ s/;2015;/;2015-12-03;/' \
-e '/UCWDC World\x27s/ s/;2016;/;2016-01-03;/' \
-e '/Dance Camp Chicago/ s/;2016;/;2016-02-26;/' \
-e '/High Desert Classic/ s/;2016;/;2016-03-11;/' \
-e '/Texas Hoedown/ s/;2016;/;2016-03-12;/' \
-e '/Peach State Festival/ s/;2016;/;2016-03-17;/' \
-e '/San Diego Festival/ s/;2016;/;2016-03-24;/' \
-e '/Calgary Dance Stampede/ s/;2016;/;2016-04-07;/' \
-e '/FreZno Dance Classic/ s/;2016;/;2016-05-26;/' \
-e '/Colorado Country Classic/ s/;2016;/;2016-06-23;/' \
-e '/Indy Dance Explosion/ s/;2016;/;2016-06-30;/' \
-e '/Portland Dance Festival/ s/;2016;/;2016-07-07;/' \
-e '/Lone Star Invitational/ s/;2016;/;2016-08-12;/' \
-e '/South Bay Dance Fling/ s/;2016;/;2016-09-01;/' \
-e '/Paradise Festival/ s/;2016;/;2016-10-20;/' \
-e '/Mountain Magic/ s/;2016;/;2016-11-03;/' \
-e '/Dallas Dance Festival/ s/;2016;/;2016-11-11;/' \
-e '/UCWDC World\x27s/ s/;2017;/;2017-01-01;/' \
-e '/High Desert Classic/ s/;2017;/;2017-03-10;/' \
-e '/Peach State Festival/ s/;2017;/;2017-03-16;/' \
-e '/Texas Hoedown/ s/;2017;/;2017-03-24;/' \
-e '/Calgary Dance Stampede/ s/;2017;/;2017-03-30;/' \
-e '/San Diego Festival/ s/;2017;/;2017-04-13;/' \
-e '/FreZno Dance Classic/ s/;2017;/;2017-05-25;/' \
-e '/Colorado Country Classic/ s/;2017;/;2017-06-25;/' \
-e '/Indy Dance Explosion/ s/;2017;/;2017-07-06;/' \
-e '/Portland Dance Festival/ s/;2017;/;2017-07-07;/' \
-e '/Lone Star Invitational/ s/;2017;/;2017-08-11;/' \
-e '/South Bay Dance Fling/ s/;2017;/;2017-08-31;/' \
-e '/Waltz Across Texas/ s/;2017;/;2017-10-13;/' \
-e '/Paradise Festival/ s/;2017;/;2017-10-19;/' \
-e '/Mountain Magic/ s/;2017;/;2017-11-02;/' \
-e '/UCWDC World\x27s/ s/;2018;/;2018-01-01;/' \
-e '/High Desert Classic/ s/;2018;/;2018-03-09;/' \
-e '/San Diego Festival/ s/;2018;/;2018-03-29;/' \
-e '/Calgary Dance Stampede/ s/;2018;/;2018-04-12;/' \
-e '/FreZno Dance Classic/ s/;2018;/;2018-05-24;/' \
-e '/Colorado Country Classic/ s/;2018;/;2018-06-23;/' \
-e '/Indy Dance Explosion/ s/;2018;/;2018-07-05;/' \
-e '/Portland Dance Festival/ s/;2018;/;2018-07-12;/' \
-e '/Lone Star Invitational/ s/;2018;/;2018-08-10;/' \
-e '/Paradise Festival/ s/;2018;/;2018-10-18;/' \
-e '/Mountain Magic/ s/;2018;/;2018-11-01;/' \
-e '/UCWDC World\x27s/ s/;2019;/;2019-01-01;/' \
-e '/High Desert Classic/ s/;2019;/;2019-03-08;/' \
-e '/Calgary Dance Stampede/ s/;2019;/;2019-04-11;/' \
-e '/San Diego Festival/ s/;2019;/;2019-04-18;/' \
-e '/FreZno Dance Classic/ s/;2019;/;2019-05-23;/' \
-e '/Indy Dance Explosion/ s/;2019;/;2019-06-27;/' \
-e '/Colorado Country Classic/ s/;2019;/;2019-07-04;/' \
-e '/Portland Dance Festival/ s/;2019;/;2019-07-11;/' \
-e '/New Mexico Fiesta/ s/;2019;/;2019-09-26;/' \
-e '/Paradise Festival/ s/;2019;/;2019-10-17;/' \
-e '/Mountain Magic/ s/;2019;/;2019-10-31;/' \
-e '/UCWDC World\x27s/ s/;2020;/;2020-01-05;/' \
"${OUT_CSV}"

# Apply corrections to legacy points data
source "${SCRIPT_DIR}/corrections.sh" "${OUT_CSV}"

# Convert semicolons to commas, since some applications (GitHub Code display),
# don't support CSV files with separators other than commas
OUT_CSV_TMP=$(mktemp)
awk -v Q="\x22" 'BEGIN { FS=";"; OFS="," }; { print $1,Q$2Q,$3,$4,Q$5Q,Q$6Q,$7,$8,$9 }' "${OUT_CSV}" > "${OUT_CSV_TMP}"
cp "${OUT_CSV_TMP}" "${OUT_CSV}"

# Apply competitor name/number changes
source "${SCRIPT_DIR}/name_number_changes.sh" "${OUT_CSV}"

# Convert Unix line endings (LF) to Windows line endings (CRLF)
unix2dos "${OUT_CSV}"
