rename v1	DATA_GERACAO
rename v2	HORA_GERACAO
rename v3	ANO_ELEICAO
rename v4	NUM_TURNO
rename v5	DESCRICAO_ELEICAO
rename v6	SIGLA_UF
rename v7	SIGLA_UE
rename v8	CODIGO_MUNICIPIO
rename v9	NOME_MUNICIPIO
rename v10	NUMERO_ZONA
rename v11	NUM_SECAO
rename v12	CODIGO_CARGO
rename v13	DESCRICAO_CARGO
rename v14	NUMERO_PARTIDO
rename v15	TOTAL_VOTOS

* variables regarding total vote
cap destring NUM_TURNO, replace
cap destring TOTAL_VOTOS, replace
cap destring NUMERO_PARTIDO, replace

* keep only candidates for president
keep if NUM_TURNO==1 
keep if CODIGO_CARGO== 1

* collapse at municipality level
collapse (sum) TOTAL_VOTOS (firstnm) CODIGO_CARGO NUM_TURNO ANO_ELEICAO , by(CODIGO_MUNICIPIO NUMERO_PARTIDO)

* generate variable depicting total vote for presidential candidates
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: gen iten01 = TOTAL_VOTOS
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen total_vote_pre_cand = sum(iten01)
label variable total_vote_pre_cand "total vote for presidential candidates"
drop iten*

//rename variables to append data of previous elections
gen cod_tse = CODIGO_MUNICIPIO
destring cod_tse, replace

* generate variable depicting the number of candidate in the presidential elections
gen numero_urna =  NUMERO_PARTIDO
cap tostring numero_urna, replace
label variable numero_urna "number of in the ballot"
cap drop opa*

* generate variable depicting the number of winner candidate in the presidential elections
cap destring NUMERO_PARTIDO, replace
gen opa02 =  NUMERO_PARTIDO	if	NUMERO_PARTIDO	==	13 // PT WINNER
by CODIGO_MUNICIPIO, sort: egen numero_urna_winner = mode(opa02), maxmode
cap tostring numero_urna_winner, replace
label variable numero_urna_winner "number of winner in the ballot"
cap drop opa*

* vote share of candidates (comparing with winner total vote)
** except the winner which I will compare winner with the second challenger alone
gsort  CODIGO_MUNICIPIO -TOTAL_VOTOS
by CODIGO_MUNICIPIO, sort: gen opa01 = TOTAL_VOTOS  if _n==1 // first position

by CODIGO_MUNICIPIO, sort: egen aux1_vote_winner = mode(opa01), maxmode
gsort  CODIGO_MUNICIPIO -TOTAL_VOTOS
by CODIGO_MUNICIPIO, sort: gen zzz01 = TOTAL_VOTOS  if _n==2 // second position
by CODIGO_MUNICIPIO, sort: egen aux1_vote_challenger = mode(zzz01), maxmode

gen vote_share_pre_cand = (TOTAL_VOTOS / (aux1_vote_winner + TOTAL_VOTOS))
gsort  CODIGO_MUNICIPIO -TOTAL_VOTOS
by CODIGO_MUNICIPIO, sort: replace vote_share_pre_cand = (TOTAL_VOTOS / (aux1_vote_winner + aux1_vote_challenger)) if _n==1 // first position
label variable vote_share_pre_cand "vote share of president candidate"
drop  if vote_share_pre_cand == .
cap drop aux*

* clean data
cap destring CODIGO_MUNICIPIO, replace
cap rename CODIGO_MUNICIPIO cod_tse
cap rename year year_of_election

* clean and edit variable "coalition_of_winner"
cap gen iten = regexm(coalition_of_winner, "nulo")
cap replace coalition_of_winner ="" if iten==1
cap replace coalition_of_winner = party_winner if coalition_of_winner ==""
cap drop iten

cap gen iten = regexm(coalition_of_pre_cand, "nulo")
cap replace coalition_of_pre_cand ="" if iten==1
cap replace coalition_of_pre_cand = party_pre_cand if coalition_of_pre_cand ==""
cap drop iten

* same parties changed the name over time
* solution: replace for the actual name
cap replace party_winner = subinstr(party_winner,"pfl","dem",.) 
cap replace coalition_of_winner = subinstr(coalition_of_winner, "pfl", "dem", .) 
cap replace party_winner = subinstr(party_winner,"pl","pr",.) 
cap replace coalition_of_winner = subinstr(coalition_of_winner, "pl", "pr", .)

* preparing variables
gen year_of_election = ANO_ELEICAO

order cod_tse year_of_election numero_urna
sort cod_tse year_of_election numero_urna

* keep only relevant variables
keep	cod_tse year_of_election	/*
	*/	 numero_urna* vote_share_* 	/*
	*/ 	*winner*


