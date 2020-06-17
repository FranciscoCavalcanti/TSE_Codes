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

* SUM TOTAL VOTE

by SIGLA_UE CODIGO_CARGO  NOME, sort: egen inst1 = sum(voto)
by SIGLA_UE CODIGO_CARGO  NOME, sort: egen total_vote = mode(inst1)
by SIGLA_UE CODIGO_CARGO  NOME, sort: drop if _n>1
drop inst*

* Herfindahl–hirschman index political competition

by SIGLA_UE CODIGO_CARGO  NOME, sort: egen iten01 = total(total_vote)
by SIGLA_UE CODIGO_CARGO, sort: egen iten02 = total(total_vote)
gen iten03 = iten01/iten02
gen iten04 = iten03^2
by SIGLA_UE CODIGO_CARGO, sort: egen hhi = sum(iten04)
label variable hhi "Herfindahl–hirschman index political competition"
drop iten*

* Replace herfindahl–hirschman index for the second round (when it is the case)

gen leao01 = -1 if SITUACAO2T ~=""
by SIGLA_UE CODIGO_CARGO, sort: egen leao2 = mean(leao01)

by SIGLA_UE CODIGO_CARGO  NOME, sort: egen iten01 = total(total_vote) if leao01==-1
by SIGLA_UE CODIGO_CARGO, sort: egen iten02 = total(total_vote) if leao01==-1
gen iten03 = iten01/iten02
gen iten04 = iten03^2
by SIGLA_UE CODIGO_CARGO, sort: egen leao3 = sum(iten04)
replace hhi = leao3 if leao2==-1
drop iten* leao*

* generate variable depincting total vote for mayoral candidates

by SIGLA_UE CODIGO_CARGO, sort: egen iten01 = total(total_vote)
by SIGLA_UE CODIGO_CARGO, sort: egen total_vote_mayors_candidate = sum(iten01)
label variable total_vote_mayors_candidate "total vote for mayoral candidates"
drop iten*
** replace it for the  second round (when it is the case)
{
gen leao01 = -1 if SITUACAO2T ~=""
by SIGLA_UE CODIGO_CARGO, sort: egen leao2 = mean(leao01)
by SIGLA_UE CODIGO_CARGO, sort: egen iten01 = total(total_vote) if leao01==-1
by SIGLA_UE CODIGO_CARGO, sort: egen iten02 = mean(iten01)
replace total_vote_mayors_candidate = iten02 if leao2==-1
drop iten* leao*
}

* generate variable depincting total vote of winner candidate for mayoral election

gsort SIGLA_UE CODIGO_CARGO -total_vote

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
by SIGLA_UE CODIGO_CARGO, sort: egen iten01 = total(total_vote) if opa01==1
by SIGLA_UE CODIGO_CARGO, sort: egen total_vote_winner_candidate = mean(iten01)
label variable total_vote_winner_candidate "total vote of winner candidate for mayoral election"
drop iten* opa*

* generate variable depincting total vote of the 2 place candidate for mayoral election

gsort SIGLA_UE CODIGO_CARGO -total_vote

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
by SIGLA_UE CODIGO_CARGO, sort: gen opa02 = 1 if _n==2
replace opa02 = . if opa01==1
by SIGLA_UE CODIGO_CARGO, sort: egen iten01 = total(total_vote) if opa02==1
by SIGLA_UE CODIGO_CARGO, sort: egen total_vote_loser_candidate = mean(iten01)
label variable total_vote_loser_candidate "total vote of loser candidate for mayoral election"
drop iten* opa*

//Mayors in the same coalition of president party at national level. //Based on the paper of Brollo "Tying Your Enemy’s Hands in Close Races: The Politics of Federal Transfers in Brazil"
//Available here: http://www.journals.cambridge.org/psr2012016
//To understand the process to choose the way to compute the variables see the paper of Brollo "Tying Your Enemy’s Hands in Close Races: The Politics of Federal Transfers in Brazil"
//FHC 1
//in 1994 - PSDB, PFL and PTB
//in 1995-1996 - PMDB, PSDB, PFL, PP, PTB, PPS
//in 1997-1998 - PMDB, PSDB, PFL, PP, PPS
//FHC 2
//in 1999-2000 - PMDB, PSDB, PFL, PP
//in 2001-2002 - PMDB, PSDB, PFL, PP
//LULA 1
//in 2003-2004 - PT, PSB, PDT, PL, PTB, PPS, PV, PC do B, PL/PR
//in 2004-2005 - PT, PMDB, PSB, PDT, PL, PTB, PPS, PV, PC do B, PL/PR
//in 2005-2006 - PT, PMDB, PSB, PDT, PL, PTB, PPS, PV, PC do B, PL/PR
//in 2006-2007 - PT, PMDB, PSB, PDT, PL, PTB, PPS, PV, PC do B, PL/PR
//LULA 2
//in 2007-2008 - PT, PMDB, PRB, PCdoB, PSB, PP, PR, PTB, PV, PDT, PAN, PSC, PTdoB, PMN, PHS
//in 2008-2009 - PT, PMDB, PRB, PCdoB, PSB, PP, PR, PTB, PV, PDT, PAN, PSC, PTdoB, PMN, PHS
//in 2009-2010 - PT, PMDB, PRB, PCdoB, PSB, PP, PR, PTB, PV, PDT, PAN, PSC, PTdoB, PMN, PHS
//in 2010-2011 - PT, PMDB, PRB, PCdoB, PSB, PP, PR, PTB, PV, PDT, PAN, PSC, PTdoB, PMN, PHS
//DILMA 1
//in 2011-2012 - PT, PMDB, PP, PR, PSB ,PDT ,PSC ,PCdoB ,PRB , PTC
//in 2012-2013 - PT, PMDB, PP, PR, PSB ,PDT ,PSC ,PCdoB ,PRB , PTC
//in 2013-2014 - PT, PMDB, PP, PR, PSB ,PDT ,PSC ,PCdoB ,PRB , PTC 
//DILMA 2
//in 2014-2015 - PT, PMDB, PDT, PL, PTB, PPS, PV, PC do B
//in 2015-2016 - PT, PMDB, PDT, PL, PTB, PPS, PV, PC do B
//TEMER
//in 2016-2017 - PMDB, PP, PSDB, PSD, DEM, PRB, PV, PTB, PR
//in 2017-2018 - PMDB, PP, PSDB, PSD, DEM, PRB, PV, PTB, PR

//Parties the ruled the ministry of integration
//in 1999-2001	- PDT	-	Fernando Bezerra
//in 2001		- PMDB	-	Ramez Tebet
//in 2001-2002	- PMDB	-	Ney Suassuna
//in 2002		- PMDB	-	Luciano Barbosa
//in 2003-2005	- PPS	-	Ciro Gomes 
//in 2005-2006	- PSB	-	Ciro Gomes 
//in 2006-2007	- PSB	-	Pedro Brito 
//in 2007-2010	- PMDB	-	Geddel Lima 
//in 2010-2010	- PMDB	-	João Santana 
//in 2011-2013	- PSB	-	Fernando Bezerra Coelho
//in 2015-2016	- PP	-	Gilberto Occhi
//in 2016-2018	- PMDB	-	Helder Barbalho

//During the first 2 years (1997-1998) of the term (1t) 

gen president_wing_1t = -1 if SGL_PARTIDO	== "PMDB" /*
	*/	| SGL_PARTIDO == "PSDB" /*
	*/	| SGL_PARTIDO	==	"PFL" /*
	*/	| SGL_PARTIDO	==	"PTB" /*
	*/	| SGL_PARTIDO	==	"PP" /*
	*/	| SGL_PARTIDO	==	"PPS"

gen president_party_1t = -1 if SGL_PARTIDO == "PSDB" 

gen ministry_party_1t =. 

//During the last 2 years (1999-2000) of the term (2t)

gen president_wing_2t = -1 if SGL_PARTIDO	== "PMDB" /*
	*/	| SGL_PARTIDO == "PSDB" /*
	*/	| SGL_PARTIDO	==	"PFL" /*
	*/	| SGL_PARTIDO	==	"PTB" /*
	*/	| SGL_PARTIDO	==	"PP" /*
	*/	| SGL_PARTIDO	==	"PPS"

gen president_party_2t = -1 if SGL_PARTIDO == "PSDB" 

gen ministry_party_2t =.

//mayor elected in question was elected or not?

*During the first 2 years of the term (1t) 

gen opa = 1 if  SITUACAO1T == "Eleito" &  president_wing_1t ~= .
replace opa = 1 if SITUACAO2T == "Eleito" &  president_wing_1t ~= .
by SIGLA_UE, sort: egen elected_president_wing_1t = mean(opa)
by SIGLA_UE, sort: replace elected_president_wing_1t = 0 if elected_president_wing_1t==.
label variable elected_president_wing_1t "mayor in a party of the presidential coalition"
drop opa

gen opa = 1 if  SITUACAO1T == "Eleito" &  president_party_1t ~= .
replace opa = 1 if SITUACAO2T == "Eleito" &  president_party_1t ~= .
by SIGLA_UE, sort: egen elected_president_party_1t = mean(opa)
by SIGLA_UE, sort: replace elected_president_party_1t = 0 if elected_president_party_1t==.
label variable elected_president_party_1t "mayor in the same party of the president"
drop opa

gen opa = 1 if  SITUACAO1T == "Eleito" &  ministry_party_1t ~= .
replace opa = 1 if SITUACAO2T == "Eleito" &  ministry_party_1t ~= .
by SIGLA_UE, sort: egen elected_ministry_party_1t = mean(opa)
by SIGLA_UE, sort: replace elected_ministry_party_1t = 0 if elected_ministry_party_1t==.
label variable elected_ministry_party_1t "mayor in the same party of the ministry"
drop opa

*During the last 2 years of the term (2t) 

gen opa = 1 if  SITUACAO1T == "Eleito" &  president_wing_2t ~= .
replace opa = 1 if SITUACAO2T == "Eleito" &  president_wing_2t ~= .
by SIGLA_UE, sort: egen elected_president_wing_2t = mean(opa)
by SIGLA_UE, sort: replace elected_president_wing_2t = 0 if elected_president_wing_2t==.
label variable elected_president_wing_2t "mayor in a party of the presidential coalition"
drop opa

gen opa = 1 if  SITUACAO1T == "Eleito" &  president_party_2t ~= .
replace opa = 1 if SITUACAO2T == "Eleito" &  president_party_2t ~= .
by SIGLA_UE, sort: egen elected_president_party_2t = mean(opa)
by SIGLA_UE, sort: replace elected_president_party_2t = 0 if elected_president_party_2t==.
label variable elected_president_party_2t "mayor in the same party of the president"
drop opa

gen opa = 1 if  SITUACAO1T == "Eleito" &  ministry_party_2t ~= .
replace opa = 1 if SITUACAO2T == "Eleito" &  ministry_party_2t ~= .
by SIGLA_UE, sort: egen elected_ministry_party_2t = mean(opa)
by SIGLA_UE, sort: replace elected_ministry_party_2t = 0 if elected_ministry_party_2t==.
label variable elected_ministry_party_2t "mayor in the same party of the ministry"
drop opa

* generate variable depicting the winner party in the mayoral election

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
gen opa02 =  SGL_PARTIDO	if	opa01	==	1
by SIGLA_UE, sort: egen party_winner = mode(opa02)
tostring party_winner, replace
label variable party_winner "winner party in mayoral election"
drop opa*

* generate variable depincting the number of winner candidate in the mayoral elections

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
gen opa02 =  NUMERO	if	opa01	==	1
by SIGLA_UE, sort: egen numero_urna = mode(opa02)
tostring numero_urna, replace
label variable numero_urna "number of winner in the ballot"
drop opa*

* generate variable depincting the name of winner candidate in the mayoral elections

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
gen opa02 =  NOME	if	opa01	==	1
by SIGLA_UE, sort: egen name_of_winner = mode(opa02)
tostring name_of_winner, replace
label variable name_of_winner "name of winner in mayoral election"
drop opa*

//Margin of victory of candidates
//variable names with "1t" represents the first two years of mayoral term (first half of term)
//variable names with "2t" represents the second two years of mayoral term (second half of term)

//////////////////////////////////////////////////////////
//		Lets compute the first half of term (1t)		//
//////////////////////////////////////////////////////////

	**1 mayor candidate in the PRESIDENT WING x candidate that is NO PRESIDENT WING

	gsort SIGLA_UE -voto president_wing_1t
	
		*select the two most voted candidates
		by SIGLA_UE, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent presidential COALITION?
		by SIGLA_UE, sort: egen iten = sum(president_wing_1t) if inst==1
		*elections that there is just one candidate in the incumbent presidetial COALITION
		by SIGLA_UE, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort SIGLA_UE iten1 president_wing_1t  -voto
		by SIGLA_UE, sort: egen all_vote = sum(voto) if iten1==1	
		by SIGLA_UE, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by SIGLA_UE, sort: replace opa = . if _n>1
		by SIGLA_UE, sort: egen mv_wing_1t = mean(opa)
		label variable mv_wing_1t "margin of victory of candidate in a party of the presidential coalition"

	drop opa* iten* inst all_vote

	**2 mayor candidate in the PRESIDENT PARTY only x all candidate minus in the same president party

	gsort SIGLA_UE -voto president_party_1t
	
		*select the two most voted candidates
		by SIGLA_UE, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent PRESIDENTIAL PARTY?
		by SIGLA_UE, sort: egen iten = sum(president_party_1t)  if inst==1
		*elections that there is just one candidate in the incumbent PRESIDENTIAL PARTY
		by SIGLA_UE, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort SIGLA_UE president_party_1t  -voto
		by SIGLA_UE, sort: egen all_vote = sum(voto) if iten1==1	
		by SIGLA_UE, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by SIGLA_UE, sort: replace opa = . if _n>1
		by SIGLA_UE, sort: egen mv_party_1t = mean(opa)
		label variable mv_party_1t "margin of victory of candidate in the same party of the president"

	drop opa* iten* inst all_vote
	
	**3 mayor candidate in the MINISTRY PARTY only x all candidate minus in the same ministry party

	gsort SIGLA_UE -voto ministry_party_1t
	
		*select the two most voted candidates
		by SIGLA_UE, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent MINISTRY PARTY?
		by SIGLA_UE, sort: egen iten = sum(ministry_party_1t)  if inst==1
		*elections that there is just one candidate in the incumbent MINISTRY PARTY
		by SIGLA_UE, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort SIGLA_UE ministry_party_1t  -voto
		by SIGLA_UE, sort: egen all_vote = sum(voto) if iten1==1	
		by SIGLA_UE, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by SIGLA_UE, sort: replace opa = . if _n>1
		by SIGLA_UE, sort: egen mv_min_1t = mean(opa)
		label variable mv_min_1t "margin of victory of candidate in the same party of the ministry"

	drop opa* iten* inst all_vote
		
//////////////////////////////////////////////////////////
//		Lets compute the first half of term (2t)		//
//////////////////////////////////////////////////////////

	**1 mayor candidate in the PRESIDENT WING x candidate that is NO PRESIDENT WING

	gsort SIGLA_UE -voto president_wing_2t
	
		*select the two most voted candidates
		by SIGLA_UE, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent presidential COALITION?
		by SIGLA_UE, sort: egen iten = sum(president_wing_2t) if inst==1
		*elections that there is just one candidate in the incumbent presidetial COALITION
		by SIGLA_UE, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort SIGLA_UE iten1 president_wing_2t  -voto
		by SIGLA_UE, sort: egen all_vote = sum(voto) if iten1==1	
		by SIGLA_UE, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by SIGLA_UE, sort: replace opa = . if _n>1
		by SIGLA_UE, sort: egen mv_wing_2t = mean(opa)
		label variable mv_wing_2t "margin of victory of candidate in a party of the presidential coalition"

	drop opa* iten* inst all_vote

	**2 mayor candidate in the PRESIDENT PARTY only x all candidate minus in the same president party

	gsort SIGLA_UE -voto president_party_2t
	
		*select the two most voted candidates
		by SIGLA_UE, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent PRESIDENTIAL PARTY?
		by SIGLA_UE, sort: egen iten = sum(president_party_2t)  if inst==1
		*elections that there is just one candidate in the incumbent PRESIDENTIAL PARTY
		by SIGLA_UE, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort SIGLA_UE president_party_2t  -voto
		by SIGLA_UE, sort: egen all_vote = sum(voto) if iten1==1	
		by SIGLA_UE, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by SIGLA_UE, sort: replace opa = . if _n>1
		by SIGLA_UE, sort: egen mv_party_2t = mean(opa)
		label variable mv_party_2t "margin of victory of candidate in the same party of the president"

	drop opa* iten* inst all_vote
	
	**3 mayor candidate in the MINISTRY PARTY only x all candidate minus in the same ministry party

	gsort SIGLA_UE -voto ministry_party_2t
	
		*select the two most voted candidates
		by SIGLA_UE, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent MINISTRY PARTY?
		by SIGLA_UE, sort: egen iten = sum(ministry_party_2t)  if inst==1
		*elections that there is just one candidate in the incumbent MINISTRY PARTY
		by SIGLA_UE, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort SIGLA_UE ministry_party_2t  -voto
		by SIGLA_UE, sort: egen all_vote = sum(voto) if iten1==1	
		by SIGLA_UE, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by SIGLA_UE, sort: replace opa = . if _n>1
		by SIGLA_UE, sort: egen mv_min_2t = mean(opa)
		label variable mv_min_2t "margin of victory of candidate in the same party of the ministry"

	drop opa* iten* inst all_vote

** obs: there are municipalities with the vote of candidates, but not an indication who was elected
** this could create the following anomaly in the data:
** variables depicting margin of victory are positive, but dummy of elected is = 0
** solution: introduce a missing observation in those problematic observations

foreach x of newlist wing_1t wing_2t party_1t party_2t {
replace mv_`x' = . if mv_`x' ~=. & mv_`x' > 0 & elected_president_`x' ==0 
 }
 

foreach x of newlist _1t _2t {
replace mv_min`x' = . if mv_min`x' ~=. & mv_min`x' > 0 & elected_ministry_party`x' ==0 
 }
 	
 	
* clean data

by SIGLA_UE, sort: drop if _n>1

destring SIGLA_UE, replace
rename SIGLA_UE cod_tse
rename year year_of_election

* keep only relevant variables

keep	cod_tse year_of_election hhi /*
	*/	elected_president_wing_1t elected_president_party_1t elected_ministry_party_1t /*
	*/	elected_president_wing_2t elected_president_party_2t elected_ministry_party_2t	/*
	*/	mv_*	/*
	*/	party_winner numero_urna name_of_winner	/*
	*/	total_vote_mayors_candidate total_vote_winner_candidate total_vote_loser_candidate
