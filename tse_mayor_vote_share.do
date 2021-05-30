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


* extract files .csv by states of Brazil
set more off, perm
	
******************************************
** 1996 mayoral election
******************************************
cd  "${tmp}"
//unzipfile	"${datadir}/1996/votacao_candidato_munzona_1996.zip"
use "$datadir\1996\Candidatos_1996.dta", clear // alternative to import data

* generate datafile of the winners
preserve
do "$codedir/_sub_do_files/_tse_mayor_winners_1996.do" //this do file generate a datafile that contains the winners
restore

* generate datafile of the vote share
** I need the datafile _tse_mayor_winners_1992 do run the do file below
//do "$codedir/_sub_do_files/_tse_mayor_vote_share_1996.do" //this do file generate a datafile that contains the vote share of the incumbent

clear

******************************************
** 2000 mayoral election
******************************************
cd  "${tmp}"
unzipfile	"${datadir}/2000/votacao_candidato_munzona_2000.zip"

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
}

* generate datafile of the winners
preserve
do "$codedir/_sub_do_files/_tse_mayor_winners_2000.do" //this do file generate a datafile that contains the winners
restore

* generate datafile of the vote share
** I need the datafile _tse_mayor_winners_1996 do run the do file below
do "$codedir/_sub_do_files/_tse_mayor_vote_share_2000.do" //this do file generate a datafile that contains the vote share of the incumbent

clear

******************************************
** 2004 mayoral election
******************************************
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
}

* generate datafile of the winners
preserve
do "$codedir/_sub_do_files/_tse_mayor_winners_2004.do" //this do file generate a datafile that contains the winners
restore

* generate datafile of the vote share
** I need the datafile _tse_mayor_winners_2000 do run the do file below
do "$codedir/_sub_do_files/_tse_mayor_vote_share_2004.do" //this do file generate a datafile that contains the vote share of the incumbent

clear

******************************************
** 2008 mayoral election
******************************************
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
}

* generate datafile of the winners
preserve
do "$codedir/_sub_do_files/_tse_mayor_winners_2008.do" //this do file generate a datafile that contains the winners
restore

* generate datafile of the vote share
** I need the datafile _tse_mayor_winners_2004 do run the do file below
do "$codedir/_sub_do_files/_tse_mayor_vote_share_2008.do" //this do file generate a datafile that contains the vote share of the incumbent

clear

******************************************
** 2012 mayoral election
******************************************
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
}

* generate datafile of the winners
preserve
do "$codedir/_sub_do_files/_tse_mayor_winners_2012.do" //this do file generate a datafile that contains the winners
restore

* generate datafile of the vote share
** I need the datafile _tse_mayor_winners_2008 do run the do file below
do "$codedir/_sub_do_files/_tse_mayor_vote_share_2012.do" //this do file generate a datafile that contains the vote share of the incumbent

clear

******************************************
** 2016 mayoral election
******************************************
cd  "${tmp}"
unzipfile	"${datadir}/2016/votacao_candidato_munzona_2016.zip"

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
}

* clean data

* generate datafile of the winners
preserve
do "$codedir/_sub_do_files/_tse_mayor_winners_2016.do" //this do file generate a datafile that contains the winners
restore

* generate datafile of the vote share
** I need the datafile _tse_mayor_winners_2012 do run the do file below
do "$codedir/_sub_do_files/_tse_mayor_vote_share_2016.do" //this do file generate a datafile that contains the vote share of the incumbent

clear

******************************************
** 2020 mayoral election
******************************************
cd  "${tmp}"
unzipfile	"${datadir}/2020/votacao_candidato_munzona_2020.zip"

* domicilios
local datafiles: dir "${tmp}/" files "*2020_BRASIL.csv"
import delimited using `datafiles', clear

* delete files
local delete_files: dir "${tmp}/" files "*.csv"
foreach datafile of local delete_files {
	erase "${tmp}/`datafile'"	
}

* generate datafile of the winners
preserve
do "$codedir/_sub_do_files/_tse_mayor_winners_2020.do" //this do file generate a datafile that contains the winners
restore

* generate datafile of the vote share
** I need the datafile _tse_mayor_winners_2016 do run the do file below
do "$codedir/_sub_do_files/_tse_mayor_vote_share_2020.do" //this do file generate a datafile that contains the vote share of the incumbent

clear

******************************************
* append all years
******************************************
clear
foreach year in 2000 2004 2008 2012 2016 2020 {
append using "$tmp/tse_mayor_vote_share_`year'", force
}

* save data in output

save "${dataout}/tse_mayor_vote_share.dta", replace

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

