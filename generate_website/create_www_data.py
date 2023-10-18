import pandas as pd
import numpy as np
from pathlib import Path

parentDirectory         = Path(__file__).parent
projectDirectory        = parentDirectory.parent

dbDirectory             = projectDirectory / 'db_tables_MASTER'
dataDirectory           = parentDirectory / 'www/data'

competitorsDirectory    = dataDirectory / 'competitors'
eventsDirectory         = dataDirectory / 'events'
pointsDirectory         = dataDirectory / 'points'
competitorsIndexPath    = dataDirectory / 'competitors.json'
eventsIndexPath         = dataDirectory / 'events.json'
pointsIndexPath         = dataDirectory / 'points.json'

# Make sure that the data directory and sub-directories already exist
Path(competitorsDirectory).mkdir(parents=True, exist_ok=True)
Path(eventsDirectory).mkdir(parents=True, exist_ok=True)
Path(pointsDirectory).mkdir(parents=True, exist_ok=True)

dfCompetitors           = pd.read_csv(dbDirectory / 'table_Competitors.csv',    index_col='Competitor ID')
dfContests              = pd.read_csv(dbDirectory / 'table_Contests.csv',       index_col='Contest ID')
dfDivisions             = pd.read_csv(dbDirectory / 'table_Divisions.csv',      index_col='Division ID')
dfEventLocations        = pd.read_csv(dbDirectory / 'table_EventLocations.csv', index_col='Event Location ID')
dfEventNames            = pd.read_csv(dbDirectory / 'table_EventNames.csv',     index_col='Event Name ID')
dfEvents                = pd.read_csv(dbDirectory / 'table_Events.csv',         index_col='Event ID', parse_dates=['Event Date'])
dfResults               = pd.read_csv(dbDirectory / 'table_Results.csv',        index_col='Result ID')
dfRoles                 = pd.read_csv(dbDirectory / 'table_Roles.csv',          index_col='Role ID')

# Create a new Year column in the Events table
dfEvents['Year'] = dfEvents['Event Date'].dt.year

# Merge event names and locations into the Events table
dfEvents = pd.merge(dfEvents, dfEventNames, how="left", left_on="Event Name ID", right_index=True)
dfEvents = pd.merge(dfEvents, dfEventLocations, how="left", left_on="Event Location ID", right_index=True)

# Merge events, divisions, and roles into Contests table
dfContests = pd.merge(dfContests, dfEvents, how="left", left_on="Event ID", right_index=True)
dfContests = pd.merge(dfContests, dfDivisions, how="left", left_on="Division ID", right_index=True)
dfContests = pd.merge(dfContests, dfRoles, how="left", left_on="Role ID", right_index=True)

# Merge contests into the Results table
dfResults = pd.merge(dfResults, dfContests, how="left", left_on="Contest ID", right_index=True)

# Create additional columns in the Competitors table for the full name:
# LastFirstName -> Last Name ", " First Name
# FirstLastName -> First Name " " Last Name
dfCompetitors['LastFirstName'] = dfCompetitors['Last Name'] + ', ' + dfCompetitors['First Name']
dfCompetitors['FirstLastName'] = dfCompetitors['First Name'] + ' ' + dfCompetitors['Last Name']

# No longer need individual first and last name columns
dfCompetitors = dfCompetitors.drop(columns=['Last Name', 'First Name'])

#
# Calcluate the competitor levels
#
gb = dfResults.groupby('Competitor ID')
for competitorID, dfC in gb:
    # dfC is a DataFrame holding all result records for a given Competitor ID

    # 10 - Newcomer
    # 20 - Sophisticated
    # 30 - Masters
    # 40 - Novice
    # 50 - Intermediate
    # 60 - Advanced
    # 70 - All-Stars

    novicePoints = 0
    intermediatePoints = 0
    advancedPoints = 0
    allstarPoints = 0

    for divisionID, points in dfC.groupby('Division ID')['Points'].sum().items():
        if divisionID == 40:
            novicePoints =  points
        elif divisionID == 50:
            intermediatePoints =  points
        elif divisionID == 60:
            advancedPoints =  points
        elif divisionID == 70:
            allstarPoints =  points

    if allstarPoints > 0 or advancedPoints >= 45:
        levelName = 'All&#8209;Stars'   # use non-breaking hyphen (&#8209;)
        level = 70
    elif advancedPoints > 0 or intermediatePoints >= 30:
        levelName = 'Advanced'
        level = 60
    elif intermediatePoints > 0 or novicePoints >= 15:
        levelName = 'Intermediate'
        level = 50
    else:
        levelName = 'Novice'
        level = 40

    # Include the level name and number in each row of the Competitor's table
    dfCompetitors.at[competitorID, 'Level'] = level
    dfCompetitors.at[competitorID, 'Level Name'] = levelName

# Merge the competitors data into the Results table, which will now be fully merged
df = pd.merge(dfResults, dfCompetitors, how="left", left_on="Competitor ID", right_index=True)

htmlTemplate = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="theme-color" content="#909090">
<meta name="description" content="Country Two Step Tour (CTST) Points Registry">
<link rel="apple-touch-icon-precomposed" href="../../apple-touch-icon-precomposed.png">
<link rel="apple-touch-icon" href="../../apple-touch-icon.png">
<link rel="stylesheet" href="../../index.css">
<link rel="manifest" href="../../manifest.webmanifest">
<link rel="icon" type="image/png" sizes="32x32" href="../../icons/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="../../icons/favicon-16x16.png">
<title>{title}</title>
</head>
<body>
<div id="appleMobileWebAppStatusBarId"></div>
<div id="contentId">
<div id="homeId"><a href="../../" title="Back to Home Page">&#x2302;</a></div>
<h2>{h2}</h2>
{content}
</div>
</body>
</html>
'''

#######################
# Generate Index Files
#######################

# Competitors
dfTop = pd.DataFrame(data={ 'v': ['LIST OF COMPETITORS & LEVELS -->'] }, index=[1])
dfTop.index.names = ['k']

dfC = dfCompetitors.sort_values('LastFirstName')
dfC['v'] = dfC['LastFirstName'] + '  -  ' + dfC.index.astype(str)
dfC.index.names = ['k']

pd.concat([dfTop, dfC])['v'].to_json(competitorsIndexPath, orient="table")

# Events
dfE = dfEvents.sort_values(by='Event Date', ascending=False)
dfE.index.names = ['k']
dfE['v'] = dfE['Year'].astype(str) + ' - ' + dfE['Event Name'] + ', '  + dfE['Event Location']
dfE['v'].to_json(eventsIndexPath, orient="table")

# Point Rankings
dfTop = pd.DataFrame(data={ 'v': ['Overall Point Rankings', 'Overall Division Rankings'] }, index=[1, 2])
dfTop.index.names = ['k']

years = sorted(dfEvents['Year'].unique(), reverse=True)
titles = [ str(y) + ' Point Rankings' for y in years ]
dfP = pd.DataFrame(data={ 'v': titles }, index=years)
dfP.index.names = ['k']

pd.concat([dfTop, dfP])['v'].to_json(pointsIndexPath, orient="table")

#############################
# Generate Competitor Files
#############################

def generateCompetitorFiles():

    #
    # Generate list of all competitors by last name with their CTST ID and Level
    # --------------------------------------------------------------------------

    # Reset the index (Competitor ID), so it can be used as a column
    dfC = dfCompetitors.reset_index()

    # Select the columns we need
    dfC = dfC[['LastFirstName', 'Competitor ID', 'Level Name']]

    # Order by Competitor Name (last name, first name)
    dfC = dfC.sort_values(by=['LastFirstName'])

    # Turn competitor names into links
    dfC.loc[:, 'LastFirstName'] = f'<a href="../competitors/c-' + dfC['Competitor ID'].astype(str) + '.html">' + dfC['LastFirstName'] + '</a>'

    # Shorten column names
    dfC = dfC.rename(columns={'Competitor ID': 'ID', 'LastFirstName': 'Competitor Name', 'Level Name': 'Level'})

    # Generate the html
    title = f"CTST &ndash; Competitors &amp; Levels"
    h2 = f"Competitors &amp; Levels"
    content = dfC.to_html(border=0, classes='tableColoredHeader tableInnerBorders tableStickyHeader', \
                           col_space='1em', justify='left', index=False, render_links=True, escape=False)

    html = htmlTemplate.format(title=title, h2=h2, content=content)

    # Write the html file
    with open(competitorsDirectory / f'c-1.html', 'w') as f:
        f.write(html)

    #
    # Generate details pages for each individual competitor
    # ------------------------------------------------------

    gb = df.groupby('Competitor ID')

    for competitorID, dfC in gb:
        # dfC is a DataFrame holding all result records for a given Competitor ID

        #
        # Get the competitor's points by division, omitting divisions with no points
        #
        dfP = dfC[dfC['Points'] > 0]
        pointsByDivision = dfP.groupby(['Division ID', 'Division'], as_index=False)['Points'].sum()[['Division', 'Points']]
        content = '<div>' + pointsByDivision.to_html(border=0, classes='tableNoBorder', justify='left', index=False) + '</div>'

        #
        # Get the chronological list of this competitor's contest results
        #
        dfC['Event'] = f'<a href="../events/e-' + dfC['Event ID'].astype(str) + '.html">' + \
                                                  dfC['Event Name'] + ', ' + dfC['Event Location'] + '</a>'

        # Abbreviate column names to fit on a small phone screen
        dfC = dfC.rename(columns={'Division': 'Div', 'Role': 'L/F', 'Result': 'Res', 'Points': 'Pts'})

        # Abbreviate division names to fit on a small phone screen
        dfC['Div'] = dfC['Div'].replace({
            'Newcomer': 'New',
            'Masters': 'Mas',
            'Sophisticated': 'Soph',
            'Novice': 'Nov',
            'Intermediate': 'Int',
            'Advanced': 'Adv',
            'All Stars': 'Als'
        })

        dfC['Date'] = '<span style="float:left">' +  dfC['Event Date'].dt.strftime('%b') + '&nbsp;</span>' + \
                      '<span style="float:right">' + dfC['Event Date'].dt.strftime('%Y') + '</span>'

        content += '<div>' + dfC.to_html(border=0, classes='tableColoredHeader tableNoBorder', \
                                         justify='left', index=False, render_links=True, escape=False, \
                                         columns=['Date', 'Event', 'Div', 'L/F', 'Res', 'Pts']) + '</div>'

        #
        # Get the competitor's points by year
        #
        content += '<div>' + \
                        dfC.loc[dfC['Pts'] > 0] \
                           .sort_values(by='Year', ascending=False) \
                           .groupby(['Year'], as_index=False, sort=False)['Pts'] \
                           .sum()[['Year', 'Pts']] \
                           .to_html(border=0, classes='tableNoBorder', col_space='5em', justify='left', index=False) + '\n</div>'

        #
        # Generate the html for each competitor
        #
        competitorName = dfC['FirstLastName'].iat[0]
        competitorID = str(competitorID)
        levelName = dfC['Level Name'].iat[0]

        title = f"CTST &ndash; {competitorName}"
        h2 = f"{competitorName}  [{competitorID}] &mdash; {levelName}"
        html = htmlTemplate.format(title=title, h2=h2, content=content)

        # Write an html file for each competitor
        with open(competitorsDirectory / f'c-{competitorID}.html', 'w') as f:
            f.write(html)

########################
# Generate Event Files
########################

def generateEventFiles():

    # Generate files for each event, sorting within event by Division in the following order:
    # Newcomer (10), Novice (40), Intermediate (50), Advanced (60), All-Stars (70),
    # Sophisticated (20), Masters (30)
    sortArr = np.array([10, 40, 50, 60, 70, 20, 30])

    gb = df.groupby('Event ID')

    for eventID, dfE in gb:
        # Event header information
        [eventDate, eventName, eventLocation] = dfE.iloc[0][['Event Date', 'Event Name', 'Event Location']]
        dateString = eventDate.strftime('%d %b %Y').lstrip('0')
        eventTitle = f"{dateString} &mdash; {eventName}, {eventLocation}"

        content = ''

        # Create a new column for the sort order initially using the Division ID as the sort order value
        dfE['Sort Order'] = dfE['Division ID']

        # Re-order the divisions using the index of the Division ID in sortArr (0-6) as the sort order
        # If a division ID is not in sortArr, then just use the Division ID as the sort order
        dfE['Sort Order'] = dfE['Sort Order'].map(lambda x: np.where(sortArr == x)[0][0] if x in sortArr else x)

        # Separate by Division, so that each Division's Tier can be displayed
        gb1 = dfE.groupby('Sort Order')

        for _, df1 in gb1:

            division = df1.iloc[0]['Division']

            # Group by Role ID to get the Tier information for each Role
            gbRole = df1.groupby('Role ID')
            h = []
            j = []
            for _, dfRole in gbRole:
                [role, tier, numEntries] = dfRole.iloc[0][['Role', 'Tier', 'Num Entries']]
                h.append(f"{role}&nbsp;&ndash;&nbsp;Tier&nbsp;{str(tier)}")
                if numEntries >= 0:
                    j.append(f"{numEntries}/{role}")
            if len(j) > 0:
                content += f'<h3>{division}&nbsp;&nbsp;<small>({", ".join(h)})&nbsp;&nbsp;[{", ".join(j)}]</small></h3>'
            else:
                content += f'<h3>{division}&nbsp;&nbsp;<small>({", ".join(h)})</small></h3>'

            df1.loc[:, 'FirstLastName'] = f'<a href="../competitors/c-' + \
                                            df1['Competitor ID'].astype(str) + '.html">' + \
                                            df1['FirstLastName'] + '</a>'

            df2 = df1[['Role ID', 'Result', 'Division', 'Role', 'FirstLastName', 'Points']].sort_values(by=['Result', 'Role ID'])

            # Change column label from 'FirstLastName' to 'Competitor Name'
            df2 = df2.rename(columns = {'FirstLastName': 'Competitor Name'})

            df3 = df2.pivot_table(index=['Result'], columns='Role', values=['Competitor Name', 'Points'], fill_value='N/A', \
                    aggfunc={'Competitor Name': lambda x:x, 'Points': lambda x:x}, sort=False)

            df3 = df3.reset_index()
            df3 = df3.rename(columns={'Result': ''})

            # Event Contests
            content += df3.to_html(border=0, classes='tableColoredHeader tableInnerBorders', \
                                   col_space='1.5em', justify='left', index=False, index_names=False, render_links=True, escape=False, \
                                   float_format='{:.0f}'.format)

            # Remove non-compliant html
            content = content.replace(' halign="left"', '')

        # Generate the html for each event
        title = 'CTST &ndash; Event Details'
        h2 = f"{eventTitle}"
        html = htmlTemplate.format(title=title, h2=h2, content=content)

        # Write an html file for each event
        with open(eventsDirectory / f'e-{str(eventID)}.html', 'w') as f:
            f.write(html)

############################
# Generate Rankings Files
############################

def divisionIdNameAbbrev(divisionId):

    divisionDict = {
        10: 'New',
        20: 'Sop',
        30: 'Mas',
        40: 'Nov',
        50: 'Int',
        60: 'Adv',
        70: 'Als'
    }

    return divisionDict[divisionId] if divisionId in divisionDict else divisionId

def roleIdToName(roleId):
    if roleId == 1:
        return 'Leader'
    elif roleId == 2:
        return 'Follower'
    else:
         return str(roleId)

#
# Get points rankings by role for the specified DataFrame (may be for all years, or for a single year)
#
def getRoleYearRankings(dfIn, includeRanks = True, limit = 0):

    # Create a GroupBy object containing a list of DataFrames, one for each Role ID
    gbRole = dfIn.groupby('Role ID')

    # List of the resulting DataFrames for each Role
    listDf = []

    # Process each Role's DataFrame: 1st iteration for Leaders, 2nd iteration for Followers
    for roleId, dfRole in gbRole:
        # Get the total number of points for each competitor
        dfP = dfRole.groupby(['Competitor ID']).sum('Points')

        # Remove competitors with no points
        dfP = dfP[dfP['Points'] > 0]

        # Generate rankings in order of Points
        dfP['Rank'] = dfP['Points'].rank(method='min', ascending=False).astype(int)

        # Only consider the highest competitor rankings
        if limit > 0:
            dfP = dfP[dfP['Rank'] <= limit]

        # Sort by Rank
        dfP = dfP.sort_values(by='Rank', ascending=True)

        # Include the Competitor Name in each row
        dfP = pd.merge(dfP, dfCompetitors, how="left", left_on="Competitor ID", right_index=True)

        # Turn each Competitor Name into a link
        dfP['FirstLastName'] = f'<a href="../competitors/c-' + dfP.index.astype(str) + '.html">' + dfP['FirstLastName'] + '</a>'

        # Re-index
        dfP = dfP.reset_index()

        nameCol = roleIdToName(roleId)

        # Only include the Rank column if requested
        if includeRanks:
            dfP = dfP[['Rank', 'FirstLastName', 'Points']]
            # Shorten column names for use on small screens
            dfP = dfP.rename(columns={'Rank': '', 'FirstLastName': nameCol, 'Points': 'Pts'})
        else:
            dfP = dfP[['FirstLastName', 'Points']]
            # Shorten column names for use on small screens
            dfP = dfP.rename(columns={'FirstLastName': nameCol, 'Points': 'Pts'})

        # Add to the list of DataFrames that will be concatenated
        listDf.append(dfP)

    # Concatenate each Role's dataframe across the column axis
    dfLF = pd.concat(listDf, axis=1)

    # With different numbers of each Role, some values will be filled by NaN
    # Convert all NaN values to zero
    dfLF = dfLF.fillna(0)

    # Columns that had contained NaN values were designated as floating point columns
    # Now that all the NaN values are converted back to integers, convert all columns to integers
    floatCols = dfLF.select_dtypes(include=['float64'])
    for col in floatCols.columns.values:
        dfLF[col] = dfLF[col].astype('int64')

    # Replace zeroes with spaces
    dfLF = dfLF.replace(to_replace = 0, value = '')

    return dfLF

#
# Get points rankings by role by division over all years
#
def getDivisionRankings(dfIn):

    dfP = dfIn[dfIn['Points'] > 0]

    dfP = pd.pivot_table(dfP, index='Competitor ID', columns='Division ID', values='Points', aggfunc='sum', fill_value=0)

    # Reverse column order (highest-value division IDs come first)
    dfP = dfP.sort_index(axis='columns', ascending=False)

    # Order competitiors by points per division using highest to lowest division
    dfP = dfP.sort_values(by=list(dfP.columns), ascending=False)

    dfP = pd.merge(dfP, dfCompetitors, how="left", left_on="Competitor ID", right_index=True)

    # Move the FirstLastName column to the front, followed by the Level column
    col = dfP.pop('Level')
    dfP.insert(0, col.name, col)
    col = dfP.pop('FirstLastName')
    dfP.insert(0, col.name, col)

    # Remove the 'LastFirstName' column (we only need the 'FirstLastName' column,)
    dfP = dfP.drop(columns=['LastFirstName'])

    # Remove the 'Level Name' column (we only need the 'Level' column, the abbreviated level name)
    dfP = dfP.drop(columns=['Level Name'])

    # Map column names from Division ID to abbreviated division names (ignore first two columns)
    colList = dfP.columns.tolist()
    colList[2:] = map(divisionIdNameAbbrev, colList[2:])
    dfP.columns = colList

    # Map level names from Division ID to abbreviated division names
    dfP['Level'] = dfP['Level'].map(divisionIdNameAbbrev)

    # Turn each Competitor Name into a link
    dfP['FirstLastName'] = f'<a href="../competitors/c-' + dfP.index.astype(str) + '.html">' + dfP['FirstLastName'] + '</a>'

    dfP = dfP.rename(columns={'FirstLastName': 'Competitor Name'})

    # With different numbers of each Role, some values will be filled by NaN
    # Convert all NaN values to zero
    dfP = dfP.fillna(0)

    # Columns that had contained NaN values were designated as floating point columns
    # Now that all the NaN values are converted back to integers, convert all columns to integers
    floatCols = dfP.select_dtypes(include=['float64'])
    for col in floatCols.columns.values:
        dfP[col] = dfP[col].astype('int64')

    # Replace zeroes with spaces
    dfP = dfP.replace(to_replace = 0, value = '')

    return dfP

def generateRankingsFiles():

    #
    # Generate overall points ranking file
    # -------------------------------------

    # Get rankings for all years
    dfLF = getRoleYearRankings(df)

    # Generate the html
    title = f"CTST &ndash; Overall Point Rankings"
    h2 = f"Overall Point Rankings"
    content = dfLF.to_html(border=0, classes='tableColoredHeader tableInnerBorders tableStickyHeader', \
                           col_space='1em', justify='left', index=False, render_links=True, escape=False)

    html = htmlTemplate.format(title=title, h2=h2, content=content)

    # Write the html file
    with open(pointsDirectory / f'p-1.html', 'w') as f:
        f.write(html)

    #
    # Generate overall division rankings file
    # ----------------------------------------

    # Get rankings for all years by Division
    dfLF = getDivisionRankings(df)

    # Generate the html
    title = f"CTST &ndash; Overall Division Rankings"
    h2 = f"Overall Division Rankings"
    content = '<div class="divisionKey">Novice&nbsp;(Nov), Intermediate&nbsp;(Int), Advanced&nbsp;(Adv), All&#8209;Stars&nbsp;(Als)</div>' + \
              dfLF.to_html(border=0, classes='tableColoredHeader tableInnerBorders tableStickyHeader', \
                           col_space='1em', justify='left', index=False, render_links=True, escape=False)

    html = htmlTemplate.format(title=title, h2=h2, content=content)

    # Write the html file
    with open(pointsDirectory / f'p-2.html', 'w') as f:
        f.write(html)

    #
    # Generate points for each year
    # -----------------------------

    gb = df.groupby('Year')

    for year, dfYear in gb:
        # Get rankings for each year
        dfLF = getRoleYearRankings(dfYear, False, 10)

        # Generate the html
        title = f"CTST &ndash; {year} Point Rankings"
        h2 = f"{year}&nbsp;Point Rankings"
        content = dfLF.to_html(border=0, classes='tableColoredHeader tableInnerBorders', \
                               col_space='1em', justify='left', index=False, render_links=True, escape=False)
        html = htmlTemplate.format(title=title, h2=h2, content=content)

        # Write an html file for each year
        with open(pointsDirectory / f'p-{year}.html', 'w') as f:
            f.write(html)

generateCompetitorFiles()
generateEventFiles()
generateRankingsFiles()
