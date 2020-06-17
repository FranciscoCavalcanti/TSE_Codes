* ------------------------------------------------------------------------
* The objetive of this do file is to extract information
* regarding the characteristics of the candidates for mayor
* ------------------------------------------------------------------------

* Stata version
version 16.1 //always set the stata version being used
set more off, perm

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

global dataout  "${ROOT}/drought_corruption/build/6_tse/output"
global tmp     "${ROOT}/drought_corruption/build/6_tse/tmp"


* extract data regarding characteristics of candidates

** ** ** ** ** ** ** ** ** ** 
** 1996 mayoral election
** ** ** ** ** ** ** ** ** ** 

cd  "${tmp}"

* import data raw data
use "${datadir}/1996/Candidatos_1996.dta", clear

* clean data
do "$codedir/_sub_do_files/_tse_1996_candidate_characteristics.do"

* save as temporary file
save "$tmp/tse_1996_candidate_characteristics.dta", replace
clear

** ** ** ** ** ** ** ** ** ** 
** 2000 mayoral election
** ** ** ** ** ** ** ** ** ** 

cd  "${tmp}"
unzipfile	"${datadir}/2000/consulta_cand_2000.zip"

* import data raw data
cd  "${tmp}"
* import data raw data and save as .dta by state
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2000_`uf'.txt", clear
gen uf="`uf'"
save "$tmp/2000_candidate_characteristics_`uf'.dta", replace
}

* clean data
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	use "$tmp/2000_candidate_characteristics_`uf'", clear
	do "$codedir/_sub_do_files/_tse_2000_candidate_characteristics.do"
	* save as temporary file
	save "$tmp/2000_candidate_characteristics_`uf'.dta", replace
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
append using "$tmp/2000_candidate_characteristics_`uf'", force
}

* save as temporary file
save "$tmp/tse_2000_candidate_characteristics.dta", replace
clear

** ** ** ** ** ** ** ** ** ** 
** 2004 mayoral election
** ** ** ** ** ** ** ** ** ** 

cd  "${tmp}"
unzipfile	"${datadir}/2004/consulta_cand_2004.zip"

* import data raw data
cd  "${tmp}"
* import data raw data and save as .dta by state
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2004_`uf'.txt", clear
gen uf="`uf'"
save "$tmp/2004_candidate_characteristics_`uf'.dta", replace
}

* clean data
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	use "$tmp/2004_candidate_characteristics_`uf'", clear
	do "$codedir/_sub_do_files/_tse_2004_candidate_characteristics.do"
	* save as temporary file
	save "$tmp/2004_candidate_characteristics_`uf'.dta", replace
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
append using "$tmp/2004_candidate_characteristics_`uf'", force
}


* save as temporary file
save "$tmp/tse_2004_candidate_characteristics.dta", replace
clear

** ** ** ** ** ** ** ** ** ** 
** 2008 mayoral election
** ** ** ** ** ** ** ** ** ** 

cd  "${tmp}"
unzipfile	"${datadir}/2008/consulta_cand_2008.zip" //unzip something not working. needed to check it why.

* import data raw data and save as .dta by state
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2008_`uf'.txt", /*
	*/	delimiter(";", asstring) varname(noname) /*
	*/	encoding(ISO-8859-1) clear
gen uf="`uf'"
save "$tmp/2008_candidate_characteristics_`uf'.dta", replace
}

* clean data
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	use "$tmp/2008_candidate_characteristics_`uf'", clear
	do "$codedir/_sub_do_files/_tse_2008_candidate_characteristics.do"
	* save as temporary file
	save "$tmp/2008_candidate_characteristics_`uf'.dta", replace
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
append using "$tmp/2008_candidate_characteristics_`uf'", force
}

* save as temporary file
save "$tmp/tse_2008_candidate_characteristics.dta", replace
clear

** ** ** ** ** ** ** ** ** ** 
** 2012 mayoral election
** ** ** ** ** ** ** ** ** ** 

cd  "${tmp}"
unzipfile	"${datadir}/2012/consulta_cand_2012.zip", replace 

* import data raw data and save as .dta by state
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2012_`uf'.txt", /*
	*/	delimiter(";", asstring) varname(noname) /*
	*/	encoding(ISO-8859-1) clear
gen uf="`uf'"
save "$tmp/2012_candidate_characteristics_`uf'.dta", replace
}

* clean data
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	use "$tmp/2012_candidate_characteristics_`uf'", clear
	do "$codedir/_sub_do_files/_tse_2012_candidate_characteristics.do"
	* save as temporary file
	save "$tmp/2012_candidate_characteristics_`uf'.dta", replace
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
append using "$tmp/2012_candidate_characteristics_`uf'", force
}

* save as temporary file
save "$tmp/tse_2012_candidate_characteristics.dta", replace
clear

** ** ** ** ** ** ** ** ** ** 
** 2016 mayoral election
** ** ** ** ** ** ** ** ** ** 

cd  "${tmp}"
unzipfile	"${datadir}/2016/consulta_cand_2016.zip"

* import raw data and save as .dta by state
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2016_`uf'.csv", /*
	*/	delimiter(";", asstring) case(upper) /*
	*/	encoding(ISO-8859-1) clear
gen uf="`uf'"
save "$tmp/2016_candidate_characteristics_`uf'.dta", replace
}

* clean data
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	use "$tmp/2016_candidate_characteristics_`uf'", clear
	do "$codedir/_sub_do_files/_tse_2016_candidate_characteristics.do"
	* save as temporary file
	save "$tmp/2016_candidate_characteristics_`uf'.dta", replace
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
append using "$tmp/2016_candidate_characteristics_`uf'", force
}

* save as temporary file
save "$tmp/tse_2016_candidate_characteristics.dta", replace
clear

** ** ** ** ** ** ** ** ** ** 
* append all years
** ** ** ** ** ** ** ** ** ** 
foreach year in 1996 2000 2004 2008 2012 2016 {
append using "$tmp/tse_`year'_candidate_characteristics", force
}

* save data in output
save "${dataout}/tse_candidate_characteristics.dta", replace

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
