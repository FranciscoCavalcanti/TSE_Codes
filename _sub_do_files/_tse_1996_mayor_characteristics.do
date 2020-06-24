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

* keep only mayors candidate
keep if CODIGO_CARGO== 11 // Prefeito

* keep only the winner candidate
gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
keep if opa01 == 1
drop opa*

* generate variable depicting the winner party in the mayoral election

gen opa02 =  SGL_PARTIDO
by SIGLA_UE, sort: egen party_winner = mode(opa02)
tostring party_winner, replace
label variable party_winner "winner party in mayoral election"
drop opa*

* generate variable depincting the number of winner candidate in the mayoral elections

gen opa02 =  NUMERO
by SIGLA_UE, sort: egen numero_urna = mode(opa02)
tostring numero_urna, replace
label variable numero_urna "number of winner in the ballot"
drop opa*

* generate variable depincting the name of winner candidate in the mayoral elections

gen opa02 =  NOME
by SIGLA_UE, sort: egen name_of_winner = mode(opa02)
tostring name_of_winner, replace
label variable name_of_winner "name of winner in mayoral election"
drop opa*

* generate variable depicting the years of schooling of the mayor

gen education_mayor = .
replace education_mayor = 1 if  GRAU_INSTRUCAO=="Lê e escreve" 
replace education_mayor = 5.5 if  GRAU_INSTRUCAO=="Fundamental incompleto" 
replace education_mayor = 5.5 if  GRAU_INSTRUCAO=="1º grau incompleto" 
replace education_mayor = 9 if  GRAU_INSTRUCAO=="Fundamental completo" 
replace education_mayor = 9 if  GRAU_INSTRUCAO=="1º grau completo" 
replace education_mayor = 11 if  GRAU_INSTRUCAO=="2º grau incompleto"
replace education_mayor = 11 if  GRAU_INSTRUCAO=="Médio incompleto"
replace education_mayor = 12 if  GRAU_INSTRUCAO=="2º grau completo" 
replace education_mayor = 12 if  GRAU_INSTRUCAO=="Médio completo" 
replace education_mayor = 15 if  GRAU_INSTRUCAO=="Superior incompleto"
replace education_mayor = 17 if  GRAU_INSTRUCAO=="Superior completo" 

label variable education_mayor "years of schooling of the mayor"

* generate dummy for having a high school degree
gen education_mayor_HD = 1  if education_mayor>=12 
replace education_mayor_HD = 0  if education_mayor_HD==. 
label variable education_mayor_HD "dummy for mayor having a high school degree"

* generate dummy for having a university degree
gen education_mayor_UD = 1  if education_mayor>=17 
replace education_mayor_UD = 0  if education_mayor_UD==. 
label variable education_mayor_UD "dummy for mayor having an university degree"

* generate variable depicting the gender of the mayor

gen female_mayor =.
replace female_mayor = 0 if SEXO== "Masculino"
replace female_mayor = 1 if SEXO=="Feminino"

label variable female_mayor "1= mayor is a woman"

* clean data

by SIGLA_UE, sort: drop if _n>1

destring SIGLA_UE, replace
rename SIGLA_UE cod_tse
rename year year_of_election

* keep only relevant variables

keep	cod_tse year_of_election education_mayor education_mayor_HD education_mayor_UD female_mayor/*
	*/	party_winner numero_urna name_of_winner	
