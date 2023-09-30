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

dfCompetitors           = pd.read_csv(dbDirectory / 'table_Competitors.csv',    index_col='Competitor ID')
dfContests              = pd.read_csv(dbDirectory / 'table_Contests.csv',       index_col='Contest ID')
dfDivisions             = pd.read_csv(dbDirectory / 'table_Divisions.csv',      index_col='Division ID')
dfEventLocations        = pd.read_csv(dbDirectory / 'table_EventLocations.csv', index_col='Event Location ID')
dfEventNames            = pd.read_csv(dbDirectory / 'table_EventNames.csv',     index_col='Event Name ID')
dfEvents                = pd.read_csv(dbDirectory / 'table_Events.csv',         index_col='Event ID', parse_dates=['Event Date'])
dfResults               = pd.read_csv(dbDirectory / 'table_Results.csv',        index_col='Result ID')
dfRoles                 = pd.read_csv(dbDirectory / 'table_Roles.csv',          index_col='Role ID')           

df = dfResults

df = pd.merge(df, dfContests,       how="left", left_on="Contest ID",           right_index=True)
df = pd.merge(df, dfEvents,         how="left", left_on="Event ID",             right_index=True)
df = pd.merge(df, dfEventNames,     how="left", left_on="Event Name ID",        right_index=True)
df = pd.merge(df, dfEventLocations, how="left", left_on="Event Location ID",    right_index=True)
df = pd.merge(df, dfDivisions,      how="left", left_on="Division ID",          right_index=True)
df = pd.merge(df, dfRoles,          how="left", left_on="Role ID",              right_index=True)
df = pd.merge(df, dfCompetitors,    how="left", left_on="Competitor ID",        right_index=True)

df['Year'] = df['Event Date'].dt.year

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
<div id="apple-mobile-web-app-status-bar"></div>
<div id="content">
<div id="home"><a href="../../" title="Back to Home Page">&#x2302;</a></div>
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
dfC = dfCompetitors.sort_values('Competitor Name')
dfC.index.names = ['k']
dfC['v'] = dfC['Competitor Name'] + '  -  ' + dfC.index.astype(str)
dfC['v'].to_json(competitorsIndexPath, orient="table")

# Events
dfE = pd.merge(dfEvents, dfEventNames, how="left", left_on="Event Name ID", right_index=True)
dfE = pd.merge(dfE, dfEventLocations, how="left", left_on="Event Location ID", right_index=True)
dfE = dfE.sort_values(by='Event Date', ascending=False)
dfE.index.names = ['k']
dfE['v'] = dfE['Event Date'].dt.year.astype(str) + ' - ' + dfE['Event Name'] + ', '  + dfE['Event Location']
dfE['v'].to_json(eventsIndexPath, orient="table")

# Point Rankings
dfP = pd.DataFrame(dfEvents['Event Date'].dt.year.sort_values(ascending=False).drop_duplicates())
dfP.set_index('Event Date', inplace=True)
dfP.index.names = ['k']
dfP['v'] = dfP.index.astype(str) + ' Point Rankings'
dfP.to_json(pointsIndexPath, orient="table")

# Swap first and last names
def reverseName(fullName):
    wordList = fullName.rsplit(',', 1)
    lastName = wordList.pop() if len(wordList) > 0 else ''
    return (lastName.strip() + ' ' + ''.join(wordList)).strip()
    
#############################
# Generate Competitor Files
#############################

def generateCompetitorFiles():

    # 10 - Newcomer
    # 20 - Sophisticated
    # 30 - Masters
    # 40 - Novice
    # 50 - Intermediate
    # 60 - Advanced
    # 70 - All-Stars

    # Generate files for each competitor
    gb = df.groupby('Competitor ID')
    for competitorID, dfC in gb:

        competitorName = reverseName(str(dfCompetitors.loc[competitorID]['Competitor Name']))
        competitorID = str(competitorID)

        dfC['Year'] = dfC['Event Date'].dt.year
        dfC['Date'] = '<span style="float:left">' + dfC['Event Date'].dt.strftime('%b') + '&nbsp;</span>' + \
                      '<span style="float:right">' +dfC['Event Date'].dt.strftime('%Y') + '</span>'
        dfC['Event'] = dfC['Event Name'] + ', ' + dfC['Event Location']

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
            level = 'All&#8209;Stars'   # use non-breaking hyphen (&#8209;)
        elif advancedPoints > 0 or intermediatePoints >= 30:
            level = 'Advanced'
        elif intermediatePoints > 0 or novicePoints >= 15:
            level = 'Intermediate'
        else:
            level = 'Novice'

        pointsByDivision = dfC.groupby(['Division ID', 'Division'], as_index=False)['Points'].sum()[['Division', 'Points']]

        content = '<div>' + pointsByDivision.to_html(justify='left', index=False, border=0) + '</div>'

        # Get the chronological list of this competitor's contest results
        dfC['Event'] = f'<a href="../events/e-' + dfC['Event ID'].astype(str) + '.html">' + dfC['Event'] + '</a>'

        # Abbreviate column names to fit on a small phone screen
        dfC.rename(columns={'Division': 'Div', 'Role': 'L/F', 'Result': 'Res', 'Points': 'Pts'}, inplace=True)

        dfC['Div'] = dfC['Div'].replace({
            'Newcomer': 'New',
            'Masters': 'Mas',
            'Sophisticated': 'Soph',
            'Novice': 'Nov',
            'Intermediate': 'Int',
            'Advanced': 'Adv',
        })

        content += '<div>' + dfC.to_html(justify='left', index=False, border=0, render_links=True, escape=False, \
                    columns=['Date', 'Event', 'Div', 'L/F', 'Res', 'Pts']) + '</div>'

        # Get the competitor's points by year
        content += '<div>' + \
                        dfC.loc[dfC['Pts'] > 0] \
                            .sort_values(by='Year', ascending=False) \
                            .groupby(['Year'], as_index=False, sort=False)['Pts'] \
                            .sum()[['Year', 'Pts']] \
                            .to_html(col_space='5em', justify='left', index=False, border=0) + '\n</div>'

        # Generate the html for each competitor
        title = f"CTST &ndash; {competitorName}"
        h2 = f"{competitorName}  [{competitorID}] &mdash; {level}"
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

            df1.loc[:, 'Competitor Name'] = df1['Competitor Name'].apply(reverseName)

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

            df1.loc[:, 'Competitor Name'] = f'<a href="../competitors/c-' + \
                                    df1['Competitor ID'].astype(str) + \
                                    '.html">' + df1['Competitor Name'] + '</a>'

            df2 = df1[['Role ID', 'Result', 'Division', 'Role', 'Competitor Name', 'Points']] \
                    .sort_values(by=['Result', 'Role ID'])

            df3 = df2.pivot_table(index=['Result'], columns='Role', values=['Competitor Name', 'Points'], fill_value='N/A', \
                    aggfunc={'Competitor Name': lambda x:x, 'Points': lambda x:x}, sort=False)

            # Event Contests
            content += df3.to_html(col_space='2em', justify='left', index=True, border=2, render_links=True, \
                                    escape=False, float_format='{:.0f}'.format)

        # Generate the html for each event
        title = 'CTST &ndash; Event Details'
        h2 = f"{eventTitle}"
        html = htmlTemplate.format(title=title, h2=h2, content=content)

        # Write an html file for each event
        with open(eventsDirectory / f'e-{str(eventID)}.html', 'w') as f:
            f.write(html)

#########################
# Generate Points Files
#########################

def generatePointsFiles():

    # Generate files for each year
    gb = df.groupby('Year')

    for year, dfYear in gb:
        # Start this loop with a DataFrame for a single year
        # Will split this DataFrame into multiple DataFrames, one for each Role

        # Create a GroupBy object containing a list of DataFrames, one for each Role ID
        gbRole = dfYear.groupby('Role ID')

        # Turn this GroupBy object into a list of DataFrame objects, one for each Role ID
        # Then iterate through the list generating a DataFrame for each Role for this Year
        dfRoleList = [ gbRole.get_group(x) for x in gbRole.groups ]

        # List of the resulting DataFrames for each Role
        listDf = []

        # Process each Role's DataFrame; 1st iteration for Leaders, 2nd iteration for Followers
        for dfRole in dfRoleList:
            # Get the total number of points for each competitor
            dfP = dfRole.groupby(['Competitor ID']).sum('Points')

            # Remove competitors with no points
            dfP = dfP[dfP['Points'] > 0]

            # Generate rankings in order of Points
            dfP['Rank'] = dfP['Points'].rank(method='min', ascending=False).astype(int)

            # Only consider the Top 10 competitor rankings
            dfP = dfP[dfP['Rank'] <= 10]

            # Sort by Rank
            dfP = dfP.sort_values(by='Rank', ascending=True)

            # Include the Competitor Name in each row
            dfP = pd.merge(dfP, dfCompetitors, how="left", left_on="Competitor ID", right_index=True)

            # Convert "LastName, FirstName" to "FirstName LastName"
            dfP['Competitor Name'] = dfP['Competitor Name'].apply(reverseName)

            # Turn each Competitor Name into a link
            dfP['Competitor Name'] = f'<a href="../competitors/c-' + dfP.index.astype(str) + '.html">' + dfP['Competitor Name'] + '</a>'

            # Re-index
            dfP = dfP.reset_index()

            # The columns we need are: Rank, Competitor Name, Points
            dfP = dfP[['Rank', 'Competitor Name', 'Points']]

            # Shorten column names for use on small screens
            dfP = dfP.rename(columns={'Rank': '', 'Competitor Name': 'Name', 'Points': 'Pts'})

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
        dfLF.replace(to_replace = 0, value = '', inplace=True)

        # Generate the html
        title = f"CTST &ndash; {year} Point Rankings"
        h2 = f"{year}&nbsp;Point Rankings (Leaders/Followers)"
        content = dfLF.to_html(col_space='1em', justify='left', index=False, border=1, render_links=True, escape=False)
        html = htmlTemplate.format(title=title, h2=h2, content=content)

        # Write an html file for each year
        with open(pointsDirectory / f'p-{year}.html', 'w') as f:
            f.write(html)

generateCompetitorFiles()
generateEventFiles()
generatePointsFiles()
