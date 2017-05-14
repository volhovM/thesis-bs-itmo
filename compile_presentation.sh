#!/bin/sh

set -e
source ./common.sh
cleanup
pdflatex presentation
pdflatex presentation
cleanup
