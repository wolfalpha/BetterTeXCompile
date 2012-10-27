#!/bin/bash

#defining input

input=$1

#analysing if $input contains the file extension ".tex"

datatempstring=$1.tex
datasubstring=.tex.tex #this must not be found!

case $datatempstring in
	*"$datasubstring"*)
		datafile=`echo $datatempstring |sed 's/.\{4\}$//'` #removes additional ".tex" if necessary
	;;
	*)
		datafile=$datatempstring #assigns texfile, if form of $string is already correct
	;;
esac

#defining unique variables

file=`echo $datafile |sed 's/.\{4\}$//'` #deliveres filename WITHOUT extensions
auxfile=$file.aux
pdffile=$file.pdf

#finding bibfile reference in $datafile and assigning variable $bibfile

bibtempstring=`sed -n 's:\\bibliography{\(.*\)\(\.bib\)\{0,1\}}:\1.bib:p ' $datafile 2> /dev/null` #searches for \bibliography{} entry in $datafile and adds .bib (error messages hidden)
bibsubstr=.bib.bib #this must not be found!

bibstring=`echo $bibtempstring | sed 's/^.//'` #removes the backslash in front of $tempstring

case $bibstring in
     *"$bibsubstr"*)
		bibfile=`echo $bibstring |sed 's/.\{4\}$//'` #removes additional ".bib" if necessary
	;;
     *)
		bibfile=$bibstring #assigns bibfile, if form of $string is already correct
	;;
esac

compile(){
	if test -e $datafile #tests if $datafile exists
		then
		echo "precompiling $datafile and creating auxfile ..."
			pdflatex -interaction=nonstopmode -halt-on-error $datafile >/dev/null
		if test -e $pdffile #tests if a PDF was created in the first run (true if compiling was successful)
			then
			if [ ! -z "$bibstring" ] #tests if any bibliography command was defined/found in $datafile (true if $string is not empty)
				then
				if test -e $bibfile #tests if $bibfile exists (or if it was defined wrong in $datafile)
					then
					echo "using $bibfile ..."
					bibtex $auxfile >/dev/null
				else #bibliography command present in $datafile, but no corresponding $bibfile exists
					echo "No $bibfile found! Please check/edit $datafile""!"
					pdfsize=$(ls -lah $file.pdf | awk '{ print $5}')
					echo "Output written on $file"".pdf ($pdfsize)."
					echo "Transcript written on $file"".log."
					exit 1
				fi
			else #no bibliography defined/found in $datafile
				echo "No bibliogaphy defined in $datafile""!"
				pdfsize=$(ls -lah $file.pdf | awk '{ print $5}')
				echo "Output written on $file"".pdf ($pdfsize)."
				echo "Transcript written on $file"".log."
				exit 0
			fi
			echo "recompiling ..." #if bibfile was defined properly AND exists
				pdflatex -interaction=nonstopmode -halt-on-error $datafile >/dev/null
				pdflatex -interaction=nonstopmode -halt-on-error $datafile >/dev/null
			pdfsize=$(ls -lah $file.pdf | awk '{ print $5}')
			echo "Output written on $file"".pdf ($pdfsize)."
			echo "Transcript written on $file"".log."
		else #if no PDF was produced and compiling was not successful
			echo "==> Fatal error occurred, no output PDF file produced!"
			echo "Please check/edit $datafile""!"
			exit 1
		fi
	else #if $datafile was not found
		echo "$datafile: No such file!"
		echo "==> Fatal error occurred, no output PDF file produced!"
		exit 1
	fi
}

pkgcheck(){
	echo "Checking for installed packages ..."
	texpath=`which pdflatex`
	if [ ! -n "$texpath" ]
		then
		echo "No TeX distribution was found! Please install and/or add pdflatex to your PATH!"
		echo "==> Fatal error occurred, no output PDF file produced!"
		exit 1
	fi	
	bibtexpath=`which bibtex`
	if [ ! -n "$bibtexpath" ]
		then
		echo "No BibTeX was found! Please install and/or add bibtex to your PATH!"
		echo "==> Fatal error occurred, no output PDF file produced!"
		exit 1
	fi
	sedpath=`which sed`
	if [ ! -n "$sedpath" ]
		then
		echo "No Stream Editor was found! Please install and/or add sed to your PATH!"
		echo "==> Fatal error occurred, no output PDF file produced!"
		exit 1
	fi
}

if test $# -ne 1
	then
	echo "Please specify the document name!"
	exit 1
else
	if test -e $auxfile
		then
		pkgcheck
		echo "removing $auxfile ..."
		rm $auxfile
		compile
		exit 0
	else
		pkgcheck
		compile
		exit 0
	fi
fi