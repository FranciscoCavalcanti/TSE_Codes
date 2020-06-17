/*

D0 VOTOCAO_CANDIDATO 2000, 2004, 2008 e 2012

*/


rename	v1	DATA_GERACAO
rename	v2	HORA_GERACAO
rename	v3	ANO_ELEICAO
rename	v4	NUM_TURNO
rename	v5	DESCRICAO_ELEICAO
rename	v6	SIGLA_UF
rename	v7	SIGLA_UE
rename	v8	CODIGO_MUNICIPIO
rename	v9	NOME_MUNICIPIO
rename	v10	NUMERO_ZONA
rename	v11	CODIGO_CARGO
rename	v12	NUMERO_CAND
rename	v13	SQ_CANDIDATO
rename	v14	NOME_CANDIDATO
rename	v15	NOME_URNA_CANDIDATO
rename	v16	DESCRICAO_CARGO
rename	v17	COD_SIT_CAND_SUPERIOR
rename	v18	DESC_SIT_CAND_SUPERIOR
rename	v19	CODIGO_SIT_CANDIDATO
rename	v20	DESC_SIT_CANDIDATO
rename	v21	CODIGO_SIT_CAND_TOT
rename	v22	DESC_SIT_CAND_TOT
rename	v23	NUMERO_PARTIDO
rename	v24	SIGLA_PARTIDO
rename	v25	NOME_PARTIDO
rename	v26	SEQUENCIAL_LEGENDA
rename	v27	NOME_COLIGACAO
rename	v28	COMPOSICAO_LEGENDA
rename	v29	TOTAL_VOTOS

/*
rename	vol1	DATA_GERACAO	
rename	vol2	HORA_GERACAO	
rename	vol3	ANO_ELEICAO	
rename	vol4	NUM_TURNO	
rename	vol5	DESCRICAO_ELEICAO	
rename	vol6	SIGLA_UF	
rename	vol7	SIGLA_UE	
rename	vol8	CODIGO_MUNICIPIO	
rename	vol9	NOME_MUNICIPIO	
rename	vol10	NUMERO_ZONA	
rename	vol11	CODIGO_CARGO	
rename	vol12	NUMERO_CAND	
rename	vol13	SQ_CANDIDATO	
rename	vol14	NOME_CANDIDATO	
rename	vol15	NOME_URNA_CANDIDATO	
rename	vol16	DESCRICAO_CARGO	
rename	vol17	COD_SIT_CAND_SUPERIOR	
rename	vol18	DESC_SIT_CAND_SUPERIOR	
rename	vol19	CODIGO_SIT_CANDIDATO	
rename	vol20	DESC_SIT_CANDIDATO	
rename	vol21	CODIGO_SIT_CAND_TOT	
rename	vol22	DESC_SIT_CAND_TOT	
rename	vol23	NUMERO_PARTIDO	
rename	vol24	SIGLA_PARTIDO	
rename	vol25	NOME_PARTIDO	
rename	vol26	SEQUENCIAL_LEGENDA	
rename	vol27	NOME_COLIGACAO	
rename	vol28	COMPOSICAO_LEGENDA	
rename	vol29	TOTAL_VOTOS	
*/

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

keep if DESCRICAO_CARGO=="PREFEITO" 


gen keepar = regexm(DESCRICAO_ELEICAO, "ELEIÇÕES 2008") // Keep obs of regular elections
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

save "$tmp/tse_mayor_winners_2008.dta", replace	

