* Francisco Cavalcanti
* Website: https://sites.google.com/view/franciscocavalcanti/
* GitHub: https://github.com/FranciscoCavalcanti
* Twitter: https://twitter.com/Franciscolc85
* LinkedIn: https://www.linkedin.com/in/francisco-de-lima-cavalcanti-5497b027/

/* -----------------------------------------------------------------------------
    COMPILA DADOS NO NIVEL DE DOADORES DO TSE

----------------------------------------------------------------------------- */

// caminhos (check your username by typing "di c(username)" in Stata) ----
if "`c(username)'" == "Francisco"   {
    global ROOT "C:/Users/Francisco/Dropbox"
}
else if "`c(username)'" == "f.cavalcanti"   {
    global ROOT "C:/Users/f.cavalcanti/Dropbox"
}
global InpDir     "${ROOT}/data_sources/TSE/6_tse/input"  
global OutDir     "${ROOT}/data_sources/TSE/6_tse/output"
global CodeDir    "${ROOT}/data_sources/TSE/6_tse/code"
global tmp        "${ROOT}/data_sources/TSE/6_tse/tmp"

// IN, OUT & CONSTANTES -------------------------------------------------

* IN
global DO_TSE_2014		    "$CodeDir/_donor_firms_2014.do"
global DO_TSE_2012		    "$CodeDir/_donor_firms_2012.do"
global DO_TSE_2010		    "$CodeDir/_donor_firms_2010.do"
global DO_TSE_2008		    "$CodeDir/_donor_firms_2008.do"
global DO_TSE_2006		    "$CodeDir/_donor_firms_2006.do"
global DO_TSE_2004		    "$CodeDir/_donor_firms_2004.do"
global DO_TSE_2002		    "$CodeDir/_donor_firms_2002.do"

* OUT
global POLITICAL_DONORS_FED_ELECTIONS		"$OutDir/political_donors_federal_elections.dta"
global POLITICAL_DONORS_MAYOR_ELECTIONS		"$OutDir/political_donors_mayoral_elections.dta"

// create yearly files ---------------------------------------------------

do "$DO_TSE_2002"
do "$DO_TSE_2004"
do "$DO_TSE_2006"
do "$DO_TSE_2008"
do "$DO_TSE_2010"
do "$DO_TSE_2012"
do "$DO_TSE_2014"
	
// MAYORAL ELECTIONS	
* append database of donor firms in mayoral elections
clear
append using "$tmp/_tse_doacoes_2004.dta"
append using "$tmp/_tse_doacoes_2008.dta"
append using "$tmp/_tse_doacoes_2012.dta"

* collapse data 
collapse (sum) valorreceita, /*
	*/	by(cpfcnpjdodoador cod_tse ano_eleicao)
	
* label variables
label variable valorreceita "Value of campaign donation"
label variable cod_tse "City code"
label variable cpfcnpjdodoador "CPF or CNPJ"
label variable ano_eleicao "Year of election"

* keep only firms (delete CPF)
gen qtst =length(cpfcnpjdodoador)
	// CPF has a length of 11
	// CNPJ has a length of 14
drop if qtst ~= 11 & qtst ~= 14 	
keep if qtst == 14
drop qtst

* save data
sort cpfcnpjdodoador ano_eleicao cod_tse valorreceita
save "$POLITICAL_DONORS_MAYOR_ELECTIONS", replace

// PRESIDENTIAL ELECTIONS
* append database of donor firms in presidential elections
clear
append using "$tmp/_tse_doacoes_2002.dta"
append using "$tmp/_tse_doacoes_2006.dta"
append using "$tmp/_tse_doacoes_2010.dta"
append using "$tmp/_tse_doacoes_2014.dta"

* collapse data 
collapse (sum) valorreceita, /*
	*/	by(cpfcnpjdodoador uf ano_eleicao)
	
* label variables
label variable valorreceita "Value of campaign donation"
label variable uf "State code"
label variable cpfcnpjdodoador "CPF or CNPJ"
label variable ano_eleicao "Year of election"

* keep only firms (delete CPF)
gen qtst =length(cpfcnpjdodoador)
	// CPF has a length of 11
	// CNPJ has a length of 14
drop if qtst ~= 11 & qtst ~= 14 	
keep if qtst == 14
drop qtst

* save data
sort cpfcnpjdodoador ano_eleicao uf valorreceita
save "$POLITICAL_DONORS_FED_ELECTIONS", replace

* delete temporary files
cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.dta"
foreach datafile of local datafiles {
    rm `datafile'
}

* clear all
clear
