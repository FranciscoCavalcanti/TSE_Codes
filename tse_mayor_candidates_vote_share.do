* Francisco Cavalcanti
* Website: https://sites.google.com/view/franciscocavalcanti/
* GitHub: https://github.com/FranciscoCavalcanti
* Twitter: https://twitter.com/Franciscolc85
* LinkedIn: https://www.linkedin.com/in/francisco-de-lima-cavalcanti-5497b027/

cap version 16.1 //always set the stata version being used

*** FOLDERS PATHWAY

* check what your username is in Stata by typing "di c(username)"
if "`c(username)'" == "Francisco"   {
    global ROOT "C:\Users\Francisco\Dropbox"
}
else if "`c(username)'" == "f.cavalcanti"   {
    global ROOT "C:\Users\f.cavalcanti\Dropbox"
}

global datadir  "${ROOT}\data_sources\TSE\6_tse\input"
global dataout  "${ROOT}\political_alignment_and_droughts/build\6_tse\output"
global codedir	"${ROOT}\data_sources\TSE\code_tse"
global tmp		"${ROOT}\political_alignment_and_droughts\build\6_tse\tmp"

* extract files 
set more off, perm	
cd  "${tmp}"

** 1996 mayoral election
{
cd  "${tmp}"
//unzipfile	"${datadir}/1996/votacao_candidato_munzona_1996.zip"
//unzipfile	"$datadir\1996\consulta_cand_1996.zip", replace

* import data raw data
//odbc load, table("Candidatos_1996") //sometimes does work, shoud check versions
use "$datadir\1996\Candidatos_1996.dta", clear // alternative to import data

* generate datafile
do "$codedir/_sub_do_files/_tse_mayor_candidates_vote_share_1996.do"
 
* save as temporary file
compress
save "$tmp/_tse_mayor_candidates_vote_share_1996.dta", replace	
clear
}

** 2000 mayoral election
{
cd  "${tmp}"
unzipfile	"${datadir}/2000/votacao_candidato_munzona_2000.zip", replace

* import data raw data and save as .dta by state
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	import delimited "$tmp/votacao_candidato_munzona_2000_`uf'.txt", /*
		*/	delimiter(";", asstring) varname(noname) /*
		*/	encoding(ISO-8859-1) clear
	gen uf="`uf'"
	save "$tmp/2000_`uf'.dta", replace
	erase "$tmp/votacao_candidato_munzona_2000_`uf'.txt"
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	append using "$tmp/2000_`uf'", force
	erase "$tmp/2000_`uf'.dta"
}

* generate datafile
do "$codedir/_sub_do_files/_tse_mayor_candidates_vote_share_2000.do" 

* save as temporary file
compress
save "$tmp/_tse_mayor_candidates_vote_share_2000.dta", replace	
clear
}

** 2004 mayoral election
{
cd  "${tmp}"
unzipfile	"${datadir}/2004/votacao_candidato_munzona_2004.zip"

* import data raw data and save as .dta by state

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	import delimited "$tmp/votacao_candidato_munzona_2004_`uf'.txt", /*
		*/	delimiter(";", asstring) varname(noname) /*
		*/	encoding(ISO-8859-1) clear
	gen uf="`uf'"
	save "$tmp/2004_`uf'.dta", replace
	erase "$tmp/votacao_candidato_munzona_2004_`uf'.txt"
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	append using "$tmp/2004_`uf'", force
	erase "$tmp/2004_`uf'.dta"
}

* generate datafile
do "$codedir/_sub_do_files/_tse_mayor_candidates_vote_share_2004.do" 

* save as temporary file
compress
save "$tmp/_tse_mayor_candidates_vote_share_2004.dta", replace	
clear
}

** 2008 mayoral election
{
cd  "${tmp}"
unzipfile	"${datadir}/2008/votacao_candidato_munzona_2008.zip"

* import data raw data and save as .dta by state
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/votacao_candidato_munzona_2008_`uf'.txt", /*
		*/	delimiter(";", asstring) varname(noname) /*
		*/	encoding(ISO-8859-1) clear
	gen uf="`uf'"
	save "$tmp/2008_`uf'.dta", replace
	erase "$tmp/votacao_candidato_munzona_2008_`uf'.txt"

}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	append using "$tmp/2008_`uf'", force
	erase "$tmp/2008_`uf'.dta"
}

* generate datafile
do "$codedir/_sub_do_files/_tse_mayor_candidates_vote_share_2008.do" 

* save as temporary file
compress
save "$tmp/_tse_mayor_candidates_vote_share_2008.dta", replace	
clear
}

** 2012 mayoral election
{
cd  "${tmp}"
unzipfile	"${datadir}/2012/votacao_candidato_munzona_2012.zip"

* import data raw data and save as .dta by state

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	import delimited "$tmp/votacao_candidato_munzona_2012_`uf'.txt", /*
		*/	delimiter(";", asstring) varname(noname) /*
		*/	encoding(ISO-8859-1) clear
	gen uf="`uf'"
	save "$tmp/2012_`uf'.dta", replace
	erase "$tmp/votacao_candidato_munzona_2012_`uf'.txt"
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	append using "$tmp/2012_`uf'", force
	erase "$tmp/2012_`uf'.dta"
}

* generate datafile
do "$codedir/_sub_do_files/_tse_mayor_candidates_vote_share_2012.do" 

* save as temporary file
save "$tmp/_tse_mayor_candidates_vote_share_2012.dta", replace	
}

** 2016 mayoral election
{
cd  "${tmp}"    
unzipfile	"${datadir}/2016/votacao_candidato_munzona_2016.zip", replace

* import data raw data and save as .dta by state

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/votacao_candidato_munzona_2016_`uf'.txt", /*
		*/	delimiter(";", asstring) varname(noname) /*
		*/	encoding(ISO-8859-1) clear
	gen uf="`uf'"
	save "$tmp/2016_`uf'.dta", replace
	erase "$tmp/votacao_candidato_munzona_2016_`uf'.txt"
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	append using "$tmp/2016_`uf'", force
	erase "$tmp/2016_`uf'.dta"
}

* generate datafile
do "$codedir/_sub_do_files/_tse_mayor_candidates_vote_share_2016.do" 

* save as temporary file
compress
save "$tmp/_tse_mayor_candidates_vote_share_2016.dta", replace	
clear
}


** 2020 mayoral election
{
cd  "${tmp}"
unzipfile	"${datadir}/2020/votacao_candidato_munzona_2020.zip", replace	

* import data raw data and save as .dta by state
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	import delimited "$tmp/votacao_candidato_munzona_2020_`uf'.csv", /*
		*/	case(preserve)  /*
		*/	encoding(ISO-8859-1) clear
	gen uf="`uf'"
	save "$tmp/2020_`uf'.dta", replace
	erase "$tmp/votacao_candidato_munzona_2020_`uf'.csv"
}

* append data
clear
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
	append using "$tmp/2020_`uf'", force
	erase "$tmp/2020_`uf'.dta"
}

* generate datafile
do "$codedir/_sub_do_files/_tse_mayor_candidates_vote_share_2020.do" 

* save as temporary file
compress
save "$tmp/_tse_mayor_candidates_vote_share_2020.dta", replace	
clear
}

*************************************************
* append all data 
*************************************************
clear
foreach year in 1996 2000 2004 2008 2012 2016 2020 {
	append using "$tmp/_tse_mayor_candidates_vote_share_`year'", force
}

* save data in output
save "${dataout}/tse_mayor_candidates_vote_share.dta", replace

****************************************
* delete temporary files
****************************************

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

