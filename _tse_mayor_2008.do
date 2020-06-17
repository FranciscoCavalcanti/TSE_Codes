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

* Herfindahl–hirschman index political competition

by CODIGO_MUNICIPIO CODIGO_CARGO  NOME_CANDIDATO NUM_TURNO, sort: egen iten01 = total(voto)
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen iten02 = total(voto)
gen iten03 = iten01/iten02
gen iten04 = iten03^2
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen hhi = sum(iten04)
label variable hhi "Herfindahl–hirschman index political competition"
drop iten*

* Replace herfindahl–hirschman index for the second round (when it is the case)

gen iten1 = hhi if NUM_TURNO ==2
gen iten2 = -1 if NUM_TURNO ==2
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten03 = mode(iten2) if iten2==-1
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten04 = mean(iten03)
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten05 = mean(iten1) if iten04==-1
replace hhi = iten05 if iten04==-1
drop iten*

* generate variable depincting total vote for mayoral candidates

by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen iten01 = total(voto)
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen total_vote_mayors_candidate = sum(iten01)
label variable total_vote_mayors_candidate "total vote for mayoral candidates"
drop iten*
** replace it for the  second round (when it is the case)
{
gen iten1 = total_vote_mayors_candidate if NUM_TURNO ==2
gen iten2 = -1 if NUM_TURNO ==2
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten03 = mode(iten2) if iten2==-1
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten04 = mean(iten03)
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten05 = mean(iten1) if iten04==-1
replace total_vote_mayors_candidate = iten05 if iten04==-1
drop iten*
}

* generate variable depincting total vote of winner candidate for mayoral election

gsort CODIGO_MUNICIPIO CODIGO_CARGO -voto

by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen iten01 = total(voto) if elected==1
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen total_vote_winner_candidate = mean(iten01)
label variable total_vote_winner_candidate "total vote of winner candidate for mayoral election"
drop iten*
** replace it for the  second round (when it is the case)
{
gen iten1 = total_vote_winner_candidate if NUM_TURNO ==2
gen iten2 = -1 if NUM_TURNO ==2
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten03 = mode(iten2) if iten2==-1
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten04 = mean(iten03)
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten05 = mean(iten1) if iten04==-1
replace total_vote_winner_candidate = iten05 if iten04==-1
drop iten*
}

* generate variable depincting total vote of the 2 place candidate for mayoral election

gsort CODIGO_MUNICIPIO CODIGO_CARGO -voto

by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: gen opa02 = 1 if _n==2
replace opa02 = . if elected==1
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen iten01 = total(voto) if opa02==1
by CODIGO_MUNICIPIO CODIGO_CARGO NUM_TURNO, sort: egen total_vote_loser_candidate = mean(iten01)
label variable total_vote_loser_candidate "total vote of loser candidate for mayoral election"
drop iten* opa*
** replace it for the  second round (when it is the case)
{
gen iten1 = total_vote_loser_candidate if NUM_TURNO ==2
gen iten2 = -1 if NUM_TURNO ==2
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten03 = mode(iten2) if iten2==-1
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten04 = mean(iten03)
by CODIGO_MUNICIPIO CODIGO_CARGO, sort: egen iten05 = mean(iten1) if iten04==-1
replace total_vote_loser_candidate = iten05 if iten04==-1
drop iten*
}

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

//During the first 2 years (2009-2010) of the term (1t) 

gen president_wing_1t = -1 if SIGLA_PARTIDO	== "PT" /*
	*/	| SIGLA_PARTIDO == "PMDB" /*	
	*/	| SIGLA_PARTIDO == "PRB" /*		
	*/	| SIGLA_PARTIDO == "PSB" /*
	*/	| SIGLA_PARTIDO == "PP" /*	
	*/	| SIGLA_PARTIDO	==	"PDT" /*
	*/	| SIGLA_PARTIDO	==	"PTB" /*
	*/	| SIGLA_PARTIDO	==	"PV" /*
	*/	| SIGLA_PARTIDO	==	"PAN" /*	
	*/	| SIGLA_PARTIDO	==	"PSC" /*		
	*/	| SIGLA_PARTIDO	==	"PC do B" /*
	*/	| SIGLA_PARTIDO	==	"PCdoB" /*	
	*/	| SIGLA_PARTIDO	==	"PTdoB" /*		
	*/	| SIGLA_PARTIDO	==	"PT do B" /*		
	*/	| SIGLA_PARTIDO	==	"PMN" /*		
	*/	| SIGLA_PARTIDO	==	"PHS" /*	
	*/	| SIGLA_PARTIDO	==	"PR"

gen president_party_1t = -1 if SIGLA_PARTIDO == "PT" 

gen ministry_party_1t = -1 if SIGLA_PARTIDO == "PMDB"

//During the last 2 years (2011-2012) of the term (2t)

gen president_wing_2t = -1 if SIGLA_PARTIDO	== "PT" /*
	*/	| SIGLA_PARTIDO == "PMDB" /*	
	*/	| SIGLA_PARTIDO == "PRB" /*		
	*/	| SIGLA_PARTIDO == "PSB" /*
	*/	| SIGLA_PARTIDO == "PP" /*	
	*/	| SIGLA_PARTIDO	==	"PDT" /*
	*/	| SIGLA_PARTIDO	==	"PTC" /*	
	*/	| SIGLA_PARTIDO	==	"PSC" /*	
	*/	| SIGLA_PARTIDO	==	"PC do B" /*
	*/	| SIGLA_PARTIDO	==	"PCdoB" /*						
	*/	| SIGLA_PARTIDO	==	"PR"
	
gen president_party_2t = -1 if SIGLA_PARTIDO == "PT" 

gen ministry_party_2t = -1 if SIGLA_PARTIDO == "PSB"

//mayor elected in question was elected or not?

*During the first 2 years of the term (1t) 

drop if DESC_SIT_CAND_TOT == "2º TURNO"
gen opa = 1 if  elected == 1 &  president_wing_1t ~= .
by CODIGO_MUNICIPIO, sort: egen elected_president_wing_1t = mean(opa)
by CODIGO_MUNICIPIO, sort: replace elected_president_wing_1t = 0 if elected_president_wing_1t==.
label variable elected_president_wing_1t "mayor in a party of the presidential coalition"
drop opa

gen opa = 1 if  elected == 1 &  president_party_1t ~= .
by CODIGO_MUNICIPIO, sort: egen elected_president_party_1t = mean(opa)
by CODIGO_MUNICIPIO, sort: replace elected_president_party_1t = 0 if elected_president_party_1t==.
label variable elected_president_party_1t "mayor in the same party of the president"
drop opa

gen opa = 1 if  elected == 1 &  ministry_party_1t ~= .
by CODIGO_MUNICIPIO, sort: egen elected_ministry_party_1t = mean(opa)
by CODIGO_MUNICIPIO, sort: replace elected_ministry_party_1t = 0 if elected_ministry_party_1t==.
label variable elected_ministry_party_1t "mayor in the same party of the ministry"
drop opa

*During the last 2 years of the term (2t) 

drop if DESC_SIT_CAND_TOT == "2º TURNO"
gen opa = 1 if  elected == 1 &  president_wing_2t ~= .
by CODIGO_MUNICIPIO, sort: egen elected_president_wing_2t = mean(opa)
by CODIGO_MUNICIPIO, sort: replace elected_president_wing_2t = 0 if elected_president_wing_2t==.
label variable elected_president_wing_2t "mayor in a party of the presidential coalition"
drop opa

gen opa = 1 if  elected == 1 &  president_party_2t ~= .
by CODIGO_MUNICIPIO, sort: egen elected_president_party_2t = mean(opa)
by CODIGO_MUNICIPIO, sort: replace elected_president_party_2t = 0 if elected_president_party_2t==.
label variable elected_president_party_2t "mayor in the same party of the president"
drop opa

gen opa = 1 if  elected == 1 &  ministry_party_2t ~= .
by CODIGO_MUNICIPIO, sort: egen elected_ministry_party_2t = mean(opa)
by CODIGO_MUNICIPIO, sort: replace elected_ministry_party_2t = 0 if elected_ministry_party_2t==.
label variable elected_ministry_party_2t "mayor in the same party of the ministry"
drop opa

* generate variable depicting the winner party in the mayoral election

gen opa01 = 1 if  elected == 1
gen opa02 =  SIGLA_PARTIDO	if	opa01	==	1
by CODIGO_MUNICIPIO, sort: egen party_winner = mode(opa02)
tostring party_winner, replace
label variable party_winner "winner party in mayoral election"
drop opa*

* generate variable depincting the number of winner candidate in the mayoral elections

gen opa01 = 1 if  elected == 1
gen opa02 =  NUMERO_CAND	if	opa01	==	1
by CODIGO_MUNICIPIO, sort: egen numero_urna = mode(opa02)
tostring numero_urna, replace
label variable numero_urna "number of winner in the ballot"
drop opa*

* generate variable depincting the name of winner candidate in the mayoral elections

gen opa01 = 1 if  elected == 1
gen opa02 =  NOME_CANDIDATO	if	opa01	==	1
by CODIGO_MUNICIPIO, sort: egen name_of_winner = mode(opa02)
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

	gsort CODIGO_MUNICIPIO -voto president_wing_1t
	
		*select the two most voted candidates
		by CODIGO_MUNICIPIO, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent presidential COALITION?
		by CODIGO_MUNICIPIO, sort: egen iten = sum(president_wing_1t) if inst==1
		*elections that there is just one candidate in the incumbent presidetial COALITION
		by CODIGO_MUNICIPIO, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort CODIGO_MUNICIPIO iten1 president_wing_1t  -voto
		by CODIGO_MUNICIPIO, sort: egen all_vote = sum(voto) if iten1==1	
		by CODIGO_MUNICIPIO, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by CODIGO_MUNICIPIO, sort: replace opa = . if _n>1
		by CODIGO_MUNICIPIO, sort: egen mv_wing_1t = mean(opa)
		label variable mv_wing_1t "margin of victory of candidate in a party of the presidential coalition"

	drop opa* iten* inst all_vote

	**2 mayor candidate in the PRESIDENT PARTY only x all candidate minus in the same president party

	gsort CODIGO_MUNICIPIO -voto president_party_1t
	
		*select the two most voted candidates
		by CODIGO_MUNICIPIO, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent PRESIDENTIAL PARTY?
		by CODIGO_MUNICIPIO, sort: egen iten = sum(president_party_1t)  if inst==1
		*elections that there is just one candidate in the incumbent PRESIDENTIAL PARTY
		by CODIGO_MUNICIPIO, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort CODIGO_MUNICIPIO president_party_1t  -voto
		by CODIGO_MUNICIPIO, sort: egen all_vote = sum(voto) if iten1==1	
		by CODIGO_MUNICIPIO, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by CODIGO_MUNICIPIO, sort: replace opa = . if _n>1
		by CODIGO_MUNICIPIO, sort: egen mv_party_1t = mean(opa)
		label variable mv_party_1t "margin of victory of candidate in the same party of the president"

	drop opa* iten* inst all_vote
	
	**3 mayor candidate in the MINISTRY PARTY only x all candidate minus in the same ministry party

	gsort CODIGO_MUNICIPIO -voto ministry_party_1t
	
		*select the two most voted candidates
		by CODIGO_MUNICIPIO, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent MINISTRY PARTY?
		by CODIGO_MUNICIPIO, sort: egen iten = sum(ministry_party_1t)  if inst==1
		*elections that there is just one candidate in the incumbent MINISTRY PARTY
		by CODIGO_MUNICIPIO, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort CODIGO_MUNICIPIO ministry_party_1t  -voto
		by CODIGO_MUNICIPIO, sort: egen all_vote = sum(voto) if iten1==1	
		by CODIGO_MUNICIPIO, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by CODIGO_MUNICIPIO, sort: replace opa = . if _n>1
		by CODIGO_MUNICIPIO, sort: egen mv_min_1t = mean(opa)
		label variable mv_min_1t "margin of victory of candidate in the same party of the ministry"

	drop opa* iten* inst all_vote
		
//////////////////////////////////////////////////////////
//		Lets compute the first half of term (2t)		//
//////////////////////////////////////////////////////////

	**1 mayor candidate in the PRESIDENT WING x candidate that is NO PRESIDENT WING

	gsort CODIGO_MUNICIPIO -voto president_wing_2t
	
		*select the two most voted candidates
		by CODIGO_MUNICIPIO, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent presidential COALITION?
		by CODIGO_MUNICIPIO, sort: egen iten = sum(president_wing_2t) if inst==1
		*elections that there is just one candidate in the incumbent presidetial COALITION
		by CODIGO_MUNICIPIO, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort CODIGO_MUNICIPIO iten1 president_wing_2t  -voto
		by CODIGO_MUNICIPIO, sort: egen all_vote = sum(voto) if iten1==1	
		by CODIGO_MUNICIPIO, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by CODIGO_MUNICIPIO, sort: replace opa = . if _n>1
		by CODIGO_MUNICIPIO, sort: egen mv_wing_2t = mean(opa)
		label variable mv_wing_2t "margin of victory of candidate in a party of the presidential coalition"

	drop opa* iten* inst all_vote

	**2 mayor candidate in the PRESIDENT PARTY only x all candidate minus in the same president party

	gsort CODIGO_MUNICIPIO -voto president_party_2t
	
		*select the two most voted candidates
		by CODIGO_MUNICIPIO, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent PRESIDENTIAL PARTY?
		by CODIGO_MUNICIPIO, sort: egen iten = sum(president_party_2t)  if inst==1
		*elections that there is just one candidate in the incumbent PRESIDENTIAL PARTY
		by CODIGO_MUNICIPIO, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort CODIGO_MUNICIPIO president_party_2t  -voto
		by CODIGO_MUNICIPIO, sort: egen all_vote = sum(voto) if iten1==1	
		by CODIGO_MUNICIPIO, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by CODIGO_MUNICIPIO, sort: replace opa = . if _n>1
		by CODIGO_MUNICIPIO, sort: egen mv_party_2t = mean(opa)
		label variable mv_party_2t "margin of victory of candidate in the same party of the president"

	drop opa* iten* inst all_vote
	
	**3 mayor candidate in the MINISTRY PARTY only x all candidate minus in the same ministry party

	gsort CODIGO_MUNICIPIO -voto ministry_party_2t
	
		*select the two most voted candidates
		by CODIGO_MUNICIPIO, sort: gen inst = _n
		replace inst = . if inst >2
		replace inst = 1 if inst~=.
		*what are the elections that candidates are in the same incumbent MINISTRY PARTY?
		by CODIGO_MUNICIPIO, sort: egen iten = sum(ministry_party_2t)  if inst==1
		*elections that there is just one candidate in the incumbent MINISTRY PARTY
		by CODIGO_MUNICIPIO, sort: gen iten1 = 1 if iten == -1

		*margin of victory
		gsort CODIGO_MUNICIPIO ministry_party_2t  -voto
		by CODIGO_MUNICIPIO, sort: egen all_vote = sum(voto) if iten1==1	
		by CODIGO_MUNICIPIO, sort: gen opa = (voto[_n] - voto[_n + 1 ])/all_vote if iten1 == 1
		by CODIGO_MUNICIPIO, sort: replace opa = . if _n>1
		by CODIGO_MUNICIPIO, sort: egen mv_min_2t = mean(opa)
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

by CODIGO_MUNICIPIO, sort: drop if _n>1

destring CODIGO_MUNICIPIO, replace
rename CODIGO_MUNICIPIO cod_tse
rename year year_of_election

* keep only relevant variables

keep	cod_tse year_of_election hhi /*
	*/	elected_president_wing_1t elected_president_party_1t elected_ministry_party_1t /*
	*/	elected_president_wing_2t elected_president_party_2t elected_ministry_party_2t	/*
	*/	mv_*	/*	
	*/	party_winner numero_urna name_of_winner	/*
	*/	total_vote_mayors_candidate total_vote_winner_candidate total_vote_loser_candidate



