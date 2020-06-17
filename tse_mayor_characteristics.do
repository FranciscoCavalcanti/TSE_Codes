* ------------------------------------------------------------------------
* STATA VERSION 14
* ------------------------------------------------------------------------

version 14.2 //always set the stata version being used

*** FOLDERS PATHWAY

* check what your username is in Stata by typing "di c(username)"
if "`c(username)'" == "Francisco"   {
    global ROOT "C:/Users/Francisco/Dropbox/political_alignment_and_droughts/build"
}
else if "`c(username)'" == "f.cavalcanti"   {
    global ROOT "C:/Users/f.cavalcanti/Dropbox/political_alignment_and_droughts/build"
}

global datadir  "${ROOT}/6_tse/input"
global dataout  "${ROOT}/6_tse/output"
global codedir	"${ROOT}/6_tse/code"
global tmp     "${ROOT}/6_tse/tmp"


* extract data regarding characteristics of mayors

set more off, perm
	
cd  "${tmp}"

** 1996 mayoral election
{
unzipfile	"${datadir}/1996/consulta_cand_1996.zip" 

* import data raw data
cd  "${tmp}"
odbc load, table("Candidatos_1996") // sometimes does not work. should be done manually

* clean data

do "$codedir/_tse_1996_mayor_characteristics.do"

* save as temporary file

save "$tmp/tse_1996_mayor_characteristics.dta", replace
clear
}

** 2000 mayoral election
{
unzipfile	"${datadir}/2000/consulta_cand_2000.zip"

* import data raw data

cd  "${tmp}"
odbc load, table("Candidatos_2000") // sometimes does not work. should be done manually

* clean data

do "$codedir/_tse_2000_mayor_characteristics.do"

* save as temporary file

save "$tmp/tse_2000_mayor_characteristics.dta", replace
clear
}

** 2004 mayoral election
{
unzipfile	"${datadir}/2004/consulta_cand_2004.zip"

* import data raw data

cd  "${tmp}"
odbc load, table("Candidatos_2004") // sometimes does not work. should be done manually

* clean data

do "$codedir/_tse_2004_mayor_characteristics.do"

* save as temporary file

save "$tmp/tse_2004_mayor_characteristics.dta", replace
clear
}

** 2008 mayoral election
{
cd  "${tmp}"
unzipfile	"${datadir}/2008/consulta_cand_2008.zip" //unzip something not working. needed to check it why.

* import data raw data and save as .dta by state

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2008_`uf'.txt", /*
	*/	delimiter(";", asstring) varname(noname) /*
	*/	encoding(ISO-8859-1) clear
gen uf="`uf'"
save "$tmp/2008_mayor_characteristics_`uf'.dta", replace
}

* append data

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
append using "$tmp/2008_mayor_characteristics_`uf'", force
}

* clean data

do "$codedir/_tse_2008_mayor_characteristics.do"

* save as temporary file

save "$tmp/tse_2008_mayor_characteristics.dta", replace
clear
}

** 2012 mayoral election
{
cd  "${tmp}"
unzipfile	"${datadir}/2012/consulta_cand_2012.zip", replace 

* import data raw data and save as .dta by state

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2012_`uf'.txt", /*
	*/	delimiter(";", asstring) varname(noname) /*
	*/	encoding(ISO-8859-1) clear
gen uf="`uf'"
save "$tmp/2012_mayor_characteristics_`uf'.dta", replace
}

* append data

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
append using "$tmp/2012_mayor_characteristics_`uf'", force
}

* clean data

do "$codedir/_tse_2012_mayor_characteristics.do"

* save as temporary file

save "$tmp/tse_2012_mayor_characteristics.dta", replace
clear
}

** 2016 mayoral election
{
unzipfile	"${datadir}/2016/consulta_cand_2016.zip"

* import data raw data and save as .dta by state

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2016_`uf'.csv", /*
	*/	delimiter(";", asstring) case(upper) /*
	*/	encoding(ISO-8859-1) clear
gen uf="`uf'"
save "$tmp/2016_mayor_characteristics_`uf'.dta", replace
}

* append data

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
append using "$tmp/2016_mayor_characteristics_`uf'", force
}

* clean data

do "$codedir/_tse_2016_mayor_characteristics.do"

* save as temporary file

save "$tmp/tse_2016_mayor_characteristics.dta", replace
clear
}

* append data 

foreach year in 1996 2000 2004 2008 2012 2016 {
append using "$tmp/tse_`year'_mayor_characteristics", force
}

* take out accents and double space

foreach v of varlist name_of_winner {
di "`v'"
do "${codedir}/_no_accents_etc.do" `v'
do "${codedir}/_no_capital_letters.do" `v'
}

* save data in output

save "${dataout}/tse_mayor_characteristics.dta", replace

* delete temporary files

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
