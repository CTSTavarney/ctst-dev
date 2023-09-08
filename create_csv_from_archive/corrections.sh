#!/bin/bash

#
# Fix erroneous or missing data from the legacy Points Registry data
#
# Competitor numbers from 1400 were assigned to competitors omitted from the legacy Points Registry:
#
# 2016 FreZno Novice 8th Place Follower. Add Jacqueline Welch (1400) with 1 Point
# 2019 Calgary Novice 4th Place Leader. Add Katrina Southernwood (1401) with 2 Points
# 2019 FreZno Novice 11th Place Follower. Add Stacy Thorp (1402) with 1 Point
# 2019 FreZno Novice 12th Place Follower. Add Carol Locke (1403) with 1 Point
# 2020 Worlds Masters 1st Place Leader. Add Dennis Rose (1404) with 0 Points
#

CSV_FILE="${1}"

function add() {
    ADD="${1}"
    sed -i "$ a ${ADD}" "${CSV_FILE}"
}

function remove() {
    REMOVE="${1}"
    sed -i "/^${REMOVE}$/d" "${CSV_FILE}"
}

function replace() {
    FROM="${1}"
    TO="${2}"
    sed -i "s/^${FROM}$/${TO}/" "${CSV_FILE}"
}


add \
'F;Szule, Nicole;752;2013-06-27;Colorado Country Classic;Denver, CO;Novice;1;10'

replace \
'L;Stepenaski, Paul;312;2013-09-26;New Mexico Fiesta;Albuquerque, NM;Novice;8;0' \
'L;Stepenaski, Paul;312;2013-09-26;New Mexico Fiesta;Albuquerque, NM;Novice;9;0'

replace \
'F;Flies, Kat;270;2013-09-26;New Mexico Fiesta;Albuquerque, NM;Novice;8;0' \
'F;Flies, Kat;270;2013-09-26;New Mexico Fiesta;Albuquerque, NM;Novice;9;0'

add \
'L;Helligso, Jacob;965;2014-07-11;Portland Dance Festival;Portland, OR;Novice;2;4'

replace \
'F;Grubb, Julie;649;2014-08-14;Palm Springs Summer;Palm Springs, CA;Novice;3;3' \
'F;Gubb, Julie;1302;2014-08-14;Palm Springs Summer;Palm Springs, CA;Novice;3;3'

add \
'F;Lyles, Linda;480;2014-10-16;Paradise Festival;Ontario, CA;Masters;2;0'

replace \
'F;Caldwell, Norm;799;2015-06-25;Colorado Country Classic;Denver, CO;Intermediate;5;1' \
'L;Caldwell, Norm;799;2015-06-25;Colorado Country Classic;Denver, CO;Intermediate;5;1'

replace \
'L;Palmer, Stuart;122;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;1;0' \
'L;Palmer, Stuart;122;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;1;0'

replace \
'L;Rainey, Jim;755;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;2;0' \
'L;Rainey, Jim;755;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;2;0'

replace \
'L;Sinclair, Andrew;757;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;3;0' \
'L;Sinclair, Andrew;757;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;3;0'

replace \
'L;Palmer, Stuart;122;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;4;0' \
'L;Palmer, Stuart;122;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;4;0'

replace \
'L;Rainey, Jim;755;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;5;0' \
'L;Rainey, Jim;755;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;5;0'

replace \
'F;Wachsberg, Debbie;542;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;1;5' \
'F;Wachsberg, Debbie;542;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;1;5'

replace \
'F;Rainey, Kelli;756;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;2;4' \
'F;Rainey, Kelli;756;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;2;4'

replace \
'F;Kam, Christy;289;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;3;3' \
'F;Kam, Christy;289;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;3;3'

replace \
'F;Williams, Raquel;568;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;4;2' \
'F;Williams, Raquel;568;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;4;2'

replace \
'F;Yee, Kimberly;369;2015-03-19;Peach State Festival;Atlanta, GA;Intermediate;5;1' \
'F;Yee, Kimberly;369;2015-03-19;Peach State Festival;Atlanta, GA;Advanced;5;1'

replace \
'F;Giles, Pam;110;2015-09-03;South Bay Dance Fling;San Jose, CA;Intermediate;5;1' \
'L;Sai, John;790;2015-09-03;South Bay Dance Fling;San Jose, CA;Intermediate;5;1'

remove \
'L;Beckler, Robert;203;2016-05-26;FreZno Dance Classic;Fresno, CA;Novice;8;1'

add \
'F;Welch, Jacqueline;1400;2016-05-26;FreZno Dance Classic;Fresno, CA;Novice;8;1'

replace \
'L;Williams, Charles;490;2016-10-20;Paradise Festival;Ontario, CA;Masters;1;0' \
'F;Williams, Cheryl;825;2016-10-20;Paradise Festival;Ontario, CA;Masters;1;0'

add \
'F;Cinciripini, Theresa;839;2017-01-01;UCWDC World\x27s;Nashville, TN;Novice;9;1'

replace \
'L;Williams, Charles;490;2017-04-13;San Diego Festival;San Diego, CA;Advanced;2;4' \
'F;Williams, Cheryl;825;2017-04-13;San Diego Festival;San Diego, CA;Advanced;2;4'

replace \
'L;Kashack, Gene;930;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Intermediate;1;0' \
'L;Kashack, Gene;930;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Masters;1;0'

replace \
'L;Patterson, Richard;816;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Intermediate;2;0' \
'L;Patterson, Richard;816;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Masters;2;0'

replace \
'L;Markovic, Wally;739;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Intermediate;3;0' \
'L;Markovic, Wally;739;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Masters;3;0'

replace \
'L;Rose, David;611;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Intermediate;4;0' \
'L;Rose, David;611;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Masters;4;0'

replace \
'F;Eubanks, Debbie;547;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Intermediate;1;0' \
'F;Eubanks, Debbie;547;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Masters;1;0'

replace \
'F;Reuss, Celia;1094;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Intermediate;2;0' \
'F;Reuss, Celia;1094;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Masters;2;0'

replace \
'F;Roisen, Julie;1095;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Intermediate;3;0' \
'F;Roisen, Julie;1095;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Masters;3;0'

replace \
'F;Garringer, Jessie;809;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Intermediate;4;0' \
'F;Garringer, Jessie;809;2017-07-06;Indy Dance Explosion;Indianapolis, IN;Masters;4;0'

replace \
'F;Hall, Marilyn;634;2017-08-31;South Bay Dance Fling;San Jose, CA;Novice;5;1' \
'L;Santos, Elgin;1063;2017-08-31;South Bay Dance Fling;San Jose, CA;Novice;5;1'

replace \
'L;Williams, Charles;490;2017-10-19;Paradise Festival;Orange Co, CA;Masters;5;0' \
'F;Williams, Cheryl;825;2017-10-19;Paradise Festival;Orange Co, CA;Masters;5;0'

add \
'L;Housego, Cliff;376;2018-03-09;High Desert Classic;Lancaster, CA;Intermediate;1;5'

replace \
'L;Plagens, Patrick;125;2018-03-29;San Diego Festival;San Diego, CA;Advanced;1;1' \
'L;Plagens, Patrick;125;2018-03-29;San Diego Festival;San Diego, CA;Advanced;5;1'

replace \
'F;Hoffner, Tasha;596;2018-03-29;San Diego Festival;San Diego, CA;Advanced;1;1' \
'F;Hoffner, Tasha;596;2018-03-29;San Diego Festival;San Diego, CA;Advanced;5;1'

replace \
'L;Johnson, Craig;112;2018-03-29;San Diego Festival;San Diego, CA;Advanced;2;2' \
'L;Johnson, Craig;112;2018-03-29;San Diego Festival;San Diego, CA;Advanced;4;2'

replace \
'F;Lucas, Carrie;1065;2018-03-29;San Diego Festival;San Diego, CA;Advanced;2;2' \
'F;Lucas, Carrie;1065;2018-03-29;San Diego Festival;San Diego, CA;Advanced;4;2'

replace \
'F;Krova, Jenna;1181;2018-05-24;FreZno Dance Classic;Fresno, CA;Novice;2;8' \
'F;Korver, Jenna;1221;2018-05-24;FreZno Dance Classic;Fresno, CA;Novice;2;8'

replace \
'F;Wolfe, Sarah;138;2018-05-24;FreZno Dance Classic;Fresno, CA;Advanced;7;1' \
'L;Eads, Mike;238;2018-05-24;FreZno Dance Classic;Fresno, CA;Advanced;7;1'

add \
'L;Southernwood, Katrina;1401;2019-04-11;Calgary Dance Stampede;Calgary, AB;Novice;4;2'

replace \
'F;Grubb, Julie;649;2019-04-18;San Diego Festival;San Diego, CA;Advanced;2;4' \
'F;Gubb, Julie;1302;2019-04-18;San Diego Festival;San Diego, CA;Advanced;2;4'

replace \
'F;May, Marsue;1256;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;1;10' \
'F;May, Marsue;1256;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;1;15'

replace \
'F;Colberg, Theresa;1257;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;2;8' \
'F;Colberg, Theresa;1257;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;2;12'

replace \
'F;Moran, Rachel;1258;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;3;6' \
'F;Moran, Rachel;1258;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;3;10'

replace \
'F;Stoker, Carin;1109;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;4;4' \
'F;Stoker, Carin;1109;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;4;8'

replace \
'F;Clark, Anna-Lena;1216;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;5;2' \
'F;Clark, Anna-Lena;1216;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;5;6'

add \
'F;Thorp, Stacy;1402;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;11;1'

add \
'F;Locke, Carol;1403;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;12;1'

add \
'F;Reynolds, Ashlee;674;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;13;1'

add \
'F;Adams, Nikki;1301;2019-05-23;FreZno Dance Classic;Fresno, CA;Novice;14;1'

replace \
'L;Williams, Charles;490;2019-07-11;Portland Dance Festival;Portland, OR;Advanced;5;1' \
'F;Williams, Cheryl;825;2019-07-11;Portland Dance Festival;Portland, OR;Advanced;5;1'

replace \
'L;Williams, Charles;490;2019-07-11;Portland Dance Festival;Portland, OR;Masters;1;0' \
'F;Williams, Cheryl;825;2019-07-11;Portland Dance Festival;Portland, OR;Masters;1;0'

replace \
'L;Sanders, Larry;362;2019-10-17;Paradise Festival;Orange Co, CA;Intermediate;4;2' \
'F;Sandoval, Lisa;583;2019-10-17;Paradise Festival;Orange Co, CA;Intermediate;4;2'

replace \
'F;Taylor, Jean Ann;924;2019-10-17;Paradise Festival;Orange Co, CA;Advanced;5;1' \
'L;Taylor, Jonathan;968;2019-10-17;Paradise Festival;Orange Co, CA;Advanced;5;1'

replace \
'L;Sanders, Larry;362;2019-10-17;Paradise Festival;Orange Co, CA;Masters;4;0' \
'F;Sandoval, Lisa;583;2019-10-17;Paradise Festival;Orange Co, CA;Masters;4;0'

replace \
'F;Lancelona, Sheila;392;2013-04-04;MidAtlantic Classic;Herndon, VA;Intermediate;4;2' \
'F;Lancelotta, Sheila;392;2013-04-04;MidAtlantic Classic;Herndon, VA;Intermediate;4;2'

replace \
"L;Rose, David;611;2020-01-05;UCWDC World's;Nashville, TN;Masters;1;0" \
"L;Rose, Dennis;1404;2020-01-05;UCWDC World's;Nashville, TN;Masters;1;0"
