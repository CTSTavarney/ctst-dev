#!/bin/bash

CSV_FILE="${1}"

#
# Combine old and new numbers:
#

# Change Thomas Deverux [1200] to Thomas Devereux [1111]
sed -i -E '/Deverux/ s/1200/1111/' ${CSV_FILE}
sed -i -E 's/Deverux/Devereux/' ${CSV_FILE}

# Change P.J. Turner [541] to PJ Turner [1319]
sed -i -E '/Turner, P\.J\./ s/541/1319/' ${CSV_FILE}
sed -i -E 's/Turner, P\.J\./Turner, PJ/' ${CSV_FILE}

#
# Name changes/corrections:
#

# Change Laura Atson [1236] to Laura Watson [1236]
sed -i -E '/\b1236\b/ s/\bAtson/Watson/' ${CSV_FILE}

# Change Sharron Ferguson [1218] to Sharon Ferguson [1218]
sed -i -E '/\b1218\b/ s/Sharron/Sharon/' ${CSV_FILE}

# Change Darlene Hoffner [1193] to DeLene Hoffner [1193]
sed -i -E '/\b1193\b/ s/Darlene/DeLene/' ${CSV_FILE}

# Change Tasha Hoffner [596] to Tasha Sumpter [596]
sed -i -E '/\b596\b/ s/Hoffner/Sumpter/' ${CSV_FILE}

# Change Meliss Lucas [1312] to Melissa Lucas [1312]
sed -i -E '/\b1312\b/ s/Meliss\b/Melissa/' ${CSV_FILE}

# Change Angeline Lucia-DeGeorge [454] to Angeline Lucia [454]
sed -i -E '/\b454\b/ s/Lucia-DeGeorge/Lucia/' ${CSV_FILE}

# Change Haley Miller-Skredsvig [176] to Haley Skredsvig [176]
sed -i -E '/\b176\b/ s/Miller-Skredsvig/Skredsvig/' ${CSV_FILE}

# Change Kristina Perez [519] to Kristina Perez-Banda [519]
sed -i -E '/\b519\b/ s/Perez,/Perez-Banda,/' ${CSV_FILE}

# Change Ashlee Reynolds [674] to Ashlee Dickinson [674]
sed -i -E '/674\b/ s/Reynolds/Dickinson/' ${CSV_FILE}

# Change Corinne Satterthwait [1304] to Corinne Satterthwaite [1304]
sed -i -E '/1304\b/ s/Satterthwait,/Satterthwaite,/' ${CSV_FILE}

# Change Stacy Thorp [1402] to Stacy Thorpe [1402]
sed -i -E '/\b1402\b/ s/Thorp,/Thorpe,/' ${CSV_FILE}

# Change Cheryl Williams [825] to Cheryl Brown [825]
sed -i -E '/\b825\b/ s/Williams/Brown/' ${CSV_FILE}
