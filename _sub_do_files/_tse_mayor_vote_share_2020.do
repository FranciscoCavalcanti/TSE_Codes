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

by CODIGO_MUNICIPIO NOME_CANDIDATO NUM_TURNO, sort: gen voto = sum(voto1)
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

append using "$tmp/tse_mayor_winners_2016.dta"

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
by cod_tse, sort: gen iten01 = voto if year_of_election == 2020 & year_of_election[_n-1] == 2016 & numero_urna[_n] == numero_urna[_n-1] 
by cod_tse, sort: egen iten02 = mean(iten01) //vote for a party trying reelection

gsort  cod_tse  year_of_election name_of_winner 
by cod_tse, sort: gen iten03 = voto if year_of_election == 2020 & year_of_election[_n-1] == 2016 & name_of_winner[_n] == name_of_winner[_n-1] 
by cod_tse, sort: egen iten04 = mean(iten03) //vote for a mayor trying reelection

gen iten05 = iten04 // first consider the name of the candidate
replace iten05 = iten02 if iten04==. & iten05==. & iten02~=. // second check for the number of the party
gen iten06 = iten05/total_vote_mayors_candidate // first consider the name of the candidate

by cod_tse year, sort: egen share_vote_mayors_party = mean(iten06)
label variable share_vote_mayors_party "share vote mayor's party"
drop iten*

* clean data

keep if year_of_election == 2020

by CODIGO_MUNICIPIO, sort: drop if _n>1

* keep only relevant variables

keep	cod_tse year_of_election /*
	*/	share_vote_mayors_party
	
* save as temporary file

save "$tmp/tse_mayor_vote_share_2020.dta", replace	
