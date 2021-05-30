/*

D0 VOTOCAO_CANDIDATO 2000, 2004, 2008 e 2012

*/


rename	 dt_geracao 	DATA_GERACAO
rename	 hh_geracao 	HORA_GERACAO
rename	 ano_eleicao 	ANO_ELEICAO
rename	 nr_turno 	NUM_TURNO
rename	 ds_eleicao 	DESCRICAO_ELEICAO
rename	 sg_uf 	SIGLA_UF
rename	 sg_ue 	SIGLA_UE
rename	 cd_municipio 	CODIGO_MUNICIPIO
rename	 nm_municipio 	NOME_MUNICIPIO
rename	 nr_zona 	NUMERO_ZONA
rename	 cd_cargo 	CODIGO_CARGO
rename	 nr_candidato 	NUMERO_CAND
rename	 sq_candidato 	SQ_CANDIDATO
rename	 nm_candidato 	NOME_CANDIDATO
rename	 nm_urna_candidato 	NOME_URNA_CANDIDATO
rename	 ds_cargo 	DESCRICAO_CARGO
rename	 cd_situacao_candidatura 	COD_SIT_CAND_SUPERIOR
rename	 ds_situacao_candidatura 	DESC_SIT_CAND_SUPERIOR
rename	 cd_detalhe_situacao_cand 	CODIGO_SIT_CANDIDATO
rename	 ds_detalhe_situacao_cand 	DESC_SIT_CANDIDATO
rename	 cd_sit_tot_turno 	CODIGO_SIT_CAND_TOT
rename	 ds_sit_tot_turno 	DESC_SIT_CAND_TOT
rename	 nr_partido 	NUMERO_PARTIDO
rename	 sg_partido 	SIGLA_PARTIDO
rename	 nm_partido 	NOME_PARTIDO
rename	 sq_coligacao 	SEQUENCIAL_LEGENDA
rename	 nm_coligacao 	NOME_COLIGACAO
rename	 ds_composicao_coligacao 	COMPOSICAO_LEGENDA
rename	 qt_votos_nominais 	TOTAL_VOTOS

* clean data
gen teste = 1 if   DESC_SIT_CANDIDATO=="DEFERIDO"
replace teste =1 if   DESC_SIT_CANDIDATO=="DEFERIDO COM RECURSO"
replace teste =1 if   DESC_SIT_CANDIDATO=="SUB JUDICE"
replace teste =1 if   DESC_SIT_CANDIDATO=="SUB JÚDICE"
drop if teste ==.
drop teste

gen year = ANO_ELEICAO
gen voto1 = TOTAL_VOTOS

* keep only mayors
keep if CODIGO_CARGO== 11 // Prefeito

gen keepar = regexm(DESCRICAO_ELEICAO, "ELEIÇÕES MUNICIPAIS 2020") // Keep obs of regular elections
drop if keepar ~= 1
drop keepar	

gen dropar = regexm(DESCRICAO_ELEICAO, "SUPL") /*
	*/	| regexm(DESCRICAO_ELEICAO, "MAJORIT") /*
	*/	| regexm(DESCRICAO_ELEICAO, "SUP.") // Drop obs of suplementaries elections
drop if dropar == 1
drop dropar

//Somar os votos de cada candidato em cada Zona

by CODIGO_MUNICIPIO NOME_CANDIDATO NUM_TURNO, sort: egen voto = sum(voto1)
drop voto1
by CODIGO_MUNICIPIO NOME_CANDIDATO NUM_TURNO, sort: drop if _n>1

//who is elected?
gen elected = 1 if  DESC_SIT_CAND_TOT== "ELEITO"
replace elected =1 if DESC_SIT_CAND_TOT == "ELEITO POR QUOCIENTE PARTIDÁRIO" 
replace elected =1 if DESC_SIT_CAND_TOT == "ELEITO POR MÉDIA" 
replace elected =1 if DESC_SIT_CAND_TOT == "ELEITO POR QP" 
by CODIGO_MUNICIPIO CODIGO_CARGO NOME_CANDIDATO, sort: egen iten1= mean(elected)
by CODIGO_MUNICIPIO CODIGO_CARGO NOME_CANDIDATO, sort: replace elected = iten1 if iten1 ==1
drop iten*

* generate variable depicting the winner party in the mayoral election

gen opa01 = 1 if  elected == 1
gen opa02 =  SIGLA_PARTIDO	if	opa01	==	1
by CODIGO_MUNICIPIO, sort: egen party_winner = mode(opa02), maxmode
tostring party_winner, replace
label variable party_winner "winner party in mayoral election"
drop opa*

* generate variable depicting the number of winner candidate in the mayoral elections

gen opa01 = 1 if  elected == 1
gen opa02 =  NUMERO_CAND	if	opa01	==	1
by CODIGO_MUNICIPIO, sort: egen numero_urna = mode(opa02), maxmode
tostring numero_urna, replace
label variable numero_urna "number of winner in the ballot"
drop opa*

* generate variable depicting the name of winner candidate in the mayoral elections

gen opa01 = 1 if  elected == 1
gen opa02 =  NOME_CANDIDATO	if	opa01	==	1
by CODIGO_MUNICIPIO, sort: egen name_of_winner = mode(opa02), maxmode
tostring name_of_winner, replace
label variable name_of_winner "name of winner in mayoral election"
drop opa*

* generate variable depicting the coalition of winner candidate in the mayoral elections

gen opa01 = 1 if  elected == 1
gen opa02 =  COMPOSICAO_LEGENDA	if	opa01	==	1
by CODIGO_MUNICIPIO, sort: egen coalition_of_winner = mode(opa02), maxmode
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

by CODIGO_MUNICIPIO, sort: drop if _n>1

destring CODIGO_MUNICIPIO, replace
rename CODIGO_MUNICIPIO cod_tse
destring cod_tse, replace
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

save "$tmp/tse_mayor_winners_2020.dta", replace	
