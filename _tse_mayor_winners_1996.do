/*

D0 VOTOCAO_CANDIDATO 1996

*/
rename	SGL_UF	SIGLA_UF	
rename	COD_MUN	SIGLA_UE	
rename	MUNICIPIO	NOME_MUNICIPIO	
rename	COD_CARGO	CODIGO_CARGO	
rename	NUMERO	NUMERO_CAND	
rename	NOME_URNA	NOME_URNA_CANDIDATO	
rename	NOME_COLIGACAO	NOME_COLIGACAO	
rename	COMPOSICAO	COMPOSICAO_LEGENDA	
rename	QTD_VOTOS	TOTAL_VOTOS	

* generate variables

gen year = 1996
gen voto = TOTAL_VOTOS

* keep only mayors

keep if CODIGO_CARGO== 11 // Prefeito

* generate variable depicting the winner party in the mayoral election

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
gen opa02 =  SGL_PARTIDO	if	opa01	==	1
by SIGLA_UE, sort: egen party_winner = mode(opa02), maxmode
tostring party_winner, replace
label variable party_winner "winner party in mayoral election"
drop opa*

* generate variable depicting the number of winner candidate in the mayoral elections

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
gen opa02 =  NUMERO	if	opa01	==	1
by SIGLA_UE, sort: egen numero_urna = mode(opa02), maxmode
tostring numero_urna, replace
label variable numero_urna "number of winner in the ballot"
drop opa*

* generate variable depicting the name of winner candidate in the mayoral elections

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
gen opa02 =  NOME	if	opa01	==	1
by SIGLA_UE, sort: egen name_of_winner = mode(opa02), maxmode
tostring name_of_winner, replace
label variable name_of_winner "name of winner in mayoral election"
drop opa*

* generate variable depicting the coalition of winner candidate in the mayoral elections

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
gen opa02 =  COMPOSICAO_LEGENDA	if	opa01	==	1
by SIGLA_UE, sort: egen coalition_of_winner = mode(opa02), maxmode
tostring coalition_of_winner, replace
label variable coalition_of_winner "winner coalition in mayoral election"
drop opa*

* take out accents and double space
foreach v of varlist coalition_of_winner  name_of_winner party_winner {
di "`v'"
do "${codedir}/_no_accents_etc.do" `v'
do "${codedir}/_no_capital_letters.do" `v'
}	

* clean data

by SIGLA_UE, sort: drop if _n>1

destring SIGLA_UE, replace
rename SIGLA_UE cod_tse
rename year year_of_election

* clean and edit variable "coalition_of_winner"

gen iten = regexm(coalition_of_winner, "nulo")
replace coalition_of_winner ="" if iten==1
replace coalition_of_winner = party_winner if coalition_of_winner ==""
drop iten

* same parties changed the name over time
* solution: replace for the actual name

replace party_winner = subinstr(party_winner,"pfl","dem",.) 
replace coalition_of_winner = subinstr(coalition_of_winner, "pfl", "dem", .) 
replace party_winner = subinstr(party_winner,"pl","pr",.) 
replace coalition_of_winner = subinstr(coalition_of_winner, "pl", "pr", .)

* keep only relevant variables

keep	cod_tse year_of_election	/*
	*/	party_winner numero_urna name_of_winner coalition_of_winner

* save as temporary file

save "$tmp/tse_mayor_winners_1996.dta", replace	
