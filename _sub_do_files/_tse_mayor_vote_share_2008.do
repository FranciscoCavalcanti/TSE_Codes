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

by CODIGO_MUNICIPIO NOME_CANDIDATO NUM_TURNO, sort: gen voto = sum(voto1)
drop voto1
by CODIGO_MUNICIPIO NOME_CANDIDATO NUM_TURNO, sort: drop if _n>1

//who is elected?

gen elected = 1 if  DESC_SIT_CAND_TOT== "ELEITO"
replace elected =1 if DESC_SIT_CAND_TOT == "ELEITO POR QUOCIENTE PARTIDÁRIO" 
by CODIGO_MUNICIPIO CODIGO_CARGO NOME_CANDIDATO, sort: egen iten1= mean(elected)
by CODIGO_MUNICIPIO CODIGO_CARGO NOME_CANDIDATO, sort: replace elected = iten1 if iten1 ==1
drop iten*

* generate variable depicting total vote for mayoral candidates

by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: gen iten01 = voto
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen total_vote_mayors_candidate = sum(iten01)
label variable total_vote_mayors_candidate "total vote for mayoral candidates"
drop iten*

//rename variables to append data of previous elections

gen cod_tse = CODIGO_MUNICIPIO
destring cod_tse, replace
gen year_of_election = year

//append data from previous elections in order to define the incumbent candidates

append using "$tmp/tse_mayor_winners_2004.dta"

//edit data

replace party_winner = SIGLA_PARTIDO if party_winner==""
replace name_of_winner = NOME_CANDIDATO if name_of_winner==""
destring numero_urna, replace
replace numero_urna = NUMERO_CAND if numero_urna==.

* take out accents and double space

foreach v of varlist name_of_winner party_winner {
di "`v'"
do "${codedir}/_no_accents_etc.do" `v'
do "${codedir}/_no_capital_letters.do" `v'
}

* generate share vote mayor's party
** first I will consider the name of the incumbent mayor
** second I will consider the party of the incumbent mayor

gsort  cod_tse  year_of_election numero_urna 
by cod_tse, sort: gen iten01 = voto if year_of_election == 2008 & year_of_election[_n-1] == 2004 & numero_urna[_n] == numero_urna[_n-1] 
by cod_tse, sort: egen iten02 = mean(iten01) //vote for a party trying reelection

gsort  cod_tse  year_of_election name_of_winner 
by cod_tse, sort: gen iten03 = voto if year_of_election == 2008 & year_of_election[_n-1] == 2004 & name_of_winner[_n] == name_of_winner[_n-1] 
by cod_tse, sort: egen iten04 = mean(iten03) //vote for a mayor trying reelection

gen iten05 = iten04 // first consider the name of the candidate
replace iten05 = iten02 if iten04==. & iten05==. & iten02~=. // second check for the number of the party
gen iten06 = iten05/total_vote_mayors_candidate // first consider the name of the candidate

by cod_tse year, sort: egen share_vote_mayors_party = mean(iten06)
label variable share_vote_mayors_party "share vote mayor's party"
drop iten*

* clean data
keep if year_of_election == 2008
by CODIGO_MUNICIPIO, sort: drop if _n>1

* keep only relevant variables

keep	cod_tse year_of_election /*
	*/	share_vote_mayors_party
	
	
* save as temporary file

save "$tmp/tse_mayor_vote_share_2008.dta", replace
