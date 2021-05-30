/*
D0 VOTOCAO_CANDIDATO 2000, 2004, 2008, 2012, 2016
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

cap  gen SGL_UF			=	SIGLA_UF	
cap  gen COD_MUN		=	SIGLA_UE	
cap  gen COD_MUN		=	CODIGO_MUNICIPIO
cap  gen MUNICIPIO		=	NOME_MUNICIPIO	
cap  gen COD_CARGO		=	CODIGO_CARGO	
cap  gen NUMERO			=	NUMERO_CAND	
cap  gen NOME			=	NOME_CANDIDATO	
cap  gen NOME_URNA		=	NOME_URNA_CANDIDATO	
cap  gen NOME_COLIGACAO	=	NOME_COLIGACAO	
cap  gen COMPOSICAO		=	COMPOSICAO_LEGENDA	
cap  gen QTD_VOTOS		=	TOTAL_VOTOS	
cap  gen SGL_PARTIDO = 	SIGLA_PARTIDO

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

* generate variable depicting total vote for mayoral candidates
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: gen iten01 = voto
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen total_vote_mayors_candidate = sum(iten01)
label variable total_vote_mayors_candidate "total vote for mayoral candidates"
drop iten*

//rename variables to append data of previous elections
gen cod_tse = CODIGO_MUNICIPIO
destring cod_tse, replace
gen year_of_election = year

* generate variable depicting the party in the mayoral election
gen party_candidate =  SGL_PARTIDO
cap tostring party_candidate, replace
label variable party_candidate "party in mayoral election"
cap drop opa*

* generate variable depicting the number of candidate in the mayoral elections
gen numero_urna =  NUMERO
cap tostring numero_urna, replace
label variable numero_urna "number of in the ballot"
cap drop opa*

* generate variable depicting the name of candidate in the mayoral elections
gen name_of_candidate =  NOME	 
cap tostring name_of_candidate, replace
label variable name_of_candidate "name of in mayoral election"
cap drop opa*

* generate variable depicting the coalition of candidate in the mayoral elections
gen coalition_of_candidate =  COMPOSICAO_LEGENDA
cap tostring coalition_of_candidate, replace
label variable coalition_of_candidate "coalition in mayoral election"

* generate variable depicting the winner party in the mayoral election
gen opa02 =  SGL_PARTIDO	if	elected	==	1
by SIGLA_UE, sort: egen party_winner = mode(opa02), maxmode
cap tostring party_winner, replace
label variable party_winner "winner party in mayoral election"
cap drop opa*

* generate variable depicting the number of winner candidate in the mayoral elections
gen opa02 =  NUMERO	if	elected	==	1
by SIGLA_UE, sort: egen numero_urna_winner = mode(opa02), maxmode
cap tostring numero_urna_winner, replace
label variable numero_urna_winner "number of winner in the ballot"
cap drop opa*

* generate variable depicting the name of winner candidate in the mayoral elections
gen opa02 =  NOME	if	elected	==	1
by SIGLA_UE, sort: egen name_of_winner = mode(opa02), maxmode
cap tostring name_of_winner, replace
label variable name_of_winner "name of winner in mayoral election"
cap drop opa*

* generate variable depicting the coalition of winner candidate in the mayoral elections
gen opa02 =  COMPOSICAO_LEGENDA	if	elected	==	1
by SIGLA_UE, sort: egen coalition_of_winner = mode(opa02), maxmode
cap tostring coalition_of_winner, replace
label variable coalition_of_winner "winner coalition in mayoral election"
cap drop opa*


* vote share of candidates (comparing with winner total vote)
** except the winner which I will compare winner with the second challenger alone
gen opa01 = voto if  elected	==	1
by SIGLA_UE, sort: egen aux1_vote_winner = mode(opa01), maxmode
gsort  SIGLA_UE -voto
by SIGLA_UE, sort: gen zzz01 = voto  if _n==2 // second position
by SIGLA_UE, sort: egen aux1_vote_challenger = mode(zzz01), maxmode

gen vote_share_candidate = (voto / (aux1_vote_winner + voto))
replace vote_share_candidate = (voto / (aux1_vote_winner + aux1_vote_challenger)) if elected	==	1
label variable vote_share_candidate "vote share of mayor candidate"
drop  if vote_share_candidate == .

* take out accents and double space
foreach v of varlist coalition_of_* name_of_* party_* {
di "`v'"
do "${codedir}/_no_accents_etc.do" `v'
do "${codedir}/_no_capital_letters.do" `v'
}

* clean data
cap destring SIGLA_UE, replace
cap rename SIGLA_UE cod_tse
cap rename year year_of_election

* clean and edit variable "coalition_of_winner"
cap gen iten = regexm(coalition_of_winner, "nulo")
cap replace coalition_of_winner ="" if iten==1
cap replace coalition_of_winner = party_winner if coalition_of_winner ==""
cap drop iten

* same parties changed the name over time
* solution: replace for the actual name
cap replace party_winner = subinstr(party_winner,"pfl","dem",.) 
cap replace coalition_of_winner = subinstr(coalition_of_winner, "pfl", "dem", .) 
cap replace party_winner = subinstr(party_winner,"pl","pr",.) 
cap replace coalition_of_winner = subinstr(coalition_of_winner, "pl", "pr", .)

* keep only relevant variables
keep	cod_tse year_of_election	/*
	*/	party_*  numero_urna* name_of_* coalition_of_* vote_share_* 	/*
	*/ 	elected