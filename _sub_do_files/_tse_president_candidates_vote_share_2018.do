* variables regarding total vote
cap destring nr_turno, replace
cap destring qt_votos, replace
cap destring nr_votavel, replace

* keep only candidates for president
keep if nr_turno==1 
keep if cd_cargo== 1

* collapse at municipality level
collapse (sum) qt_votos (firstnm) cd_cargo nr_turno ano_eleicao , by(cd_municipio nr_votavel)

* generate variable depicting total vote for presidential candidates
by cd_municipio cd_cargo nr_turno, sort: gen iten01 = qt_votos
by cd_municipio cd_cargo nr_turno, sort: egen total_vote_pre_cand = sum(iten01)
label variable total_vote_pre_cand "total vote for presidential candidates"
drop iten*

//rename variables to append data of previous elections
gen cod_tse = cd_municipio
destring cod_tse, replace

* generate variable depicting the number of candidate in the presidential elections
gen numero_urna =  nr_votavel
cap tostring numero_urna, replace
label variable numero_urna "number of in the ballot"
cap drop opa*

* generate variable depicting the number of winner candidate in the presidential elections
cap destring nr_votavel, replace
gen opa02 =  nr_votavel	if	nr_votavel	==	17 // PSL WINNER
by cd_municipio, sort: egen numero_urna_winner = mode(opa02), maxmode
cap tostring numero_urna_winner, replace
label variable numero_urna_winner "number of winner in the ballot"
cap drop opa*

* vote share of candidates (comparing with winner total vote)
** except the winner which I will compare winner with the second challenger alone
gsort  cd_municipio -qt_votos
by cd_municipio, sort: gen opa01 = qt_votos  if _n==1 // first position

by cd_municipio, sort: egen aux1_vote_winner = mode(opa01), maxmode
gsort  cd_municipio -qt_votos
by cd_municipio, sort: gen zzz01 = qt_votos  if _n==2 // second position
by cd_municipio, sort: egen aux1_vote_challenger = mode(zzz01), maxmode

gen vote_share_pre_cand = (qt_votos / (aux1_vote_winner + qt_votos))
gsort  cd_municipio -qt_votos
by cd_municipio, sort: replace vote_share_pre_cand = (qt_votos / (aux1_vote_winner + aux1_vote_challenger)) if _n==1 // first position
label variable vote_share_pre_cand "vote share of president candidate"
drop  if vote_share_pre_cand == .
cap drop aux*

* clean data
cap destring cd_municipio, replace
cap rename cd_municipio cod_tse
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
gen year_of_election = ano_eleicao

order cod_tse year_of_election numero_urna
sort cod_tse year_of_election numero_urna

* keep only relevant variables
keep	cod_tse year_of_election	/*
	*/	 numero_urna* vote_share_* 	/*
	*/ 	*winner*


