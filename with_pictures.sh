#!/bin/sh

# Converts boilerplate parts of thesis-full.pdf into pictures

echo "split"
pdftk thesis-full.pdf cat 1-8 output tmp1.pdf
pdftk thesis-full.pdf cat 9-end output tmp2.pdf
echo "converting"
convert -density 300 +antialias tmp1.pdf tmp3.pdf
echo "merge"
pdftk tmp3.pdf tmp2.pdf output thesis-full-pics.pdf
echo "cleanup"
#rm tmp*.pdf
