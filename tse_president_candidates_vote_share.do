* Francisco Cavalcanti
* Website: https://sites.google.com/view/franciscocavalcanti/
* GitHub: https://github.com/FranciscoCavalcanti
* Twitter: https://twitter.com/Franciscolc85
* LinkedIn: https://www.linkedin.com/in/francisco-de-lima-cavalcanti-5497b027/

* ------------------------------------------------------------------------
* ------------------------------------------------------------------------
version 16.1 //always set the stata version being used
set more off

*** FOLDERS PATHWAY

* check what your username is in Stata by typing "di c(username)"
if "`c(username)'" == "Francisco"   {
    global ROOT "C:/Users/Francisco/Dropbox"
}
else if "`c(username)'" == "f.cavalcanti"   {
    global ROOT "C:/Users/f.cavalcanti/Dropbox"
}

global datadir  "${ROOT}/data_sources/TSE/6_tse/input"
global codedir	"${ROOT}/data_sources/TSE/code_tse"


global dataout  "${ROOT}/political_alignment_and_droughts/build/6_tse/output"
global tmp     "${ROOT}/political_alignment_and_droughts/build/6_tse/tmp"

******************************************
** 1998 presidental election
******************************************
cd  "${tmp}"
unzipfile	"${datadir}/1998/votacao_partido_munzona_1998.zip"
pwd

* set files
local files : dir . files "*.txt"
display `files'

* loop over files and saving as .dta at the temporary directory
cd  "${tmp}"

foreach uf in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO ZZ {
	import delimited "$tmp/votacao_partido_munzona_1998_`uf'.txt", /*
		*/	delimiter(";", asstring) varname(noname) /*
		*/	encoding(ISO-8859-1) clear
	gen uf="`uf'"
	save "$tmp/1998_`uf'.dta", replace
	erase "$tmp/votacao_partido_munzona_1998_`uf'.txt"
}

* append data
clear
foreach uf in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO ZZ {
	append using "$tmp/1998_`uf'", force
}

* clean data
do "$codedir/_sub_do_files/_tse_president_candidates_vote_share_1998.do"

* save as temporary file
save "$tmp/tse_president_candidates_vote_share_1998.dta", replace
clear

******************************************
** 2002 presidental election
******************************************
cd  "${tmp}"
unzipfile	"${datadir}/2002/votacao_partido_munzona_2002.zip"
pwd

* set files
local files : dir . files "*.txt"
display `files'

* loop over files and saving as .dta at the temporary directory
foreach uf in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO ZZ {
	import delimited "$tmp/votacao_partido_munzona_2002_`uf'.txt", /*
		*/	delimiter(";", asstring) varname(noname) /*
		*/	encoding(ISO-8859-1) clear
	gen uf="`uf'"
	save "$tmp/2002_`uf'.dta", replace
	erase "$tmp/votacao_partido_munzona_2002_`uf'.txt"
}

* append data
clear
foreach uf in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO ZZ {
	append using "$tmp/2002_`uf'", force
}

* clean data
do "$codedir/_sub_do_files/_tse_president_candidates_vote_share_2002.do"

* save as temporary file
save "$tmp/tse_president_candidates_vote_share_2002.dta", replace
clear

******************************************
** 2006 presidental election
******************************************
cd  "${tmp}"
unzipfile	"${datadir}/2006/votacao_partido_munzona_2006.zip"
pwd

* set files
local files : dir . files "*.txt"
display `files'

* loop over files and saving as .dta at the temporary directory
cd  "${tmp}"
foreach uf in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO ZZ {
	import delimited "$tmp/votacao_partido_munzona_2006_`uf'.txt", /*
		*/	delimiter(";", asstring) varname(noname) /*
		*/	encoding(ISO-8859-1) clear
	gen uf="`uf'"
	save "$tmp/2006_`uf'.dta", replace
	erase "$tmp/votacao_partido_munzona_2006_`uf'.txt"
}

* append data
clear
foreach uf in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO ZZ {
append using "$tmp/2006_`uf'", force
}

* clean data
do "$codedir/_sub_do_files/_tse_president_candidates_vote_share_2006.do"

* save as temporary file
save "$tmp/tse_president_candidates_vote_share_2006.dta", replace
clear

******************************************
** 2010 presidental election
******************************************
cd  "${tmp}"
unzipfile	"${datadir}/2010/votacao_secao_2010_BR.zip"
pwd

* set files
local files : dir . files "*.txt"
display `files'

* loop over files and saving as .dta at the temporary directory
cd  "${tmp}"

import delimited "$tmp/votacao_secao_2010_BR.txt", /*
	*/	delimiter(";", asstring) varname(noname) /*
	*/	encoding(ISO-8859-1) clear
	
erase "$tmp/votacao_secao_2010_BR.txt"	

do "$codedir/_sub_do_files/_tse_president_candidates_vote_share_2010.do"

* save as temporary file
save "$tmp/tse_president_candidates_vote_share_2010.dta", replace
clear

******************************************
** 2014 presidental election
******************************************
cd  "${tmp}"
unzipfile	"${datadir}/2014/votacao_secao_2014_BR.zip"
pwd

* set files
local files : dir . files "*.txt"
display `files'

* loop over files and saving as .dta at the temporary directory
cd  "${tmp}"

import delimited "$tmp/votacao_secao_2014_BR.txt", /*
	*/	delimiter(";", asstring) varname(noname) /*
	*/	encoding(ISO-8859-1) clear

erase "$tmp/votacao_secao_2014_BR.txt"	
	
do "$codedir/_sub_do_files/_tse_president_candidates_vote_share_2014.do"

* save as temporary file
save "$tmp/tse_president_candidates_vote_share_2014.dta", replace
clear

******************************************
** 2018 presidental election
******************************************
cd  "${tmp}"
unzipfile	"${datadir}/2018/votacao_secao_2018_BR.zip"
pwd

* set files
local files : dir . files "*.txt"
display `files'

* loop over files and saving as .dta at the temporary directory
cd  "${tmp}"

import delimited "$tmp/votacao_secao_2018_BR.csv", /*
	*/	delimiter(";", asstring)  /*
	*/	encoding(ISO-8859-1) clear
	
erase "$tmp/votacao_secao_2018_BR.csv"

do "$codedir/_sub_do_files/_tse_president_candidates_vote_share_2018.do"

* save as temporary file
save "$tmp/tse_president_candidates_vote_share_2018.dta", replace
clear

******************************************
* append all years
******************************************
foreach year in 1998 2002 2006 2010 2014 2018 {
	append using "$tmp/tse_president_candidates_vote_share_`year'", force
}

* save data in output
save "${dataout}/tse_president_candidates_vote_share.dta", replace

******************************************
* delete temporary files
******************************************
cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.dta"
foreach datafile of local datafiles {
        rm `datafile'
}

cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.csv"
foreach datafile of local datafiles {
        rm `datafile'
}

cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.txt"
foreach datafile of local datafiles {
        rm "`datafile'"
}


cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.pdf"
foreach datafile of local datafiles {
        rm `datafile'
}

cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.mdb"
foreach datafile of local datafiles {
        rm `datafile'
}

* clear all

clear

