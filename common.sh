#!/bin/sh

function compile() {
    pdflatex $1 
    biber    $1 
    pdflatex $1 
    pdflatex $1 
}

function cleanup() {
    rm -vf ./*.{aux,log,bbl,bcf,blg,run.xml,toc,tct}
}
