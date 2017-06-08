#!/bin/sh

set -e
source ./common.sh
cleanup
compile thesis
cleanup
mv thesis.pdf thesis-full.pdf
pdftk thesis-full.pdf cat 1-2 output title-page.pdf
pdftk thesis-full.pdf cat 3-4 output specification.pdf
pdftk thesis-full.pdf cat 5-6 output annotation.pdf
pdftk thesis-full.pdf cat 7-end output thesis.pdf
