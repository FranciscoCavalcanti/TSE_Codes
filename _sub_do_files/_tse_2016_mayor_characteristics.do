
* generate variables

gen year = 2016

* keep only mayors candidate

keep if CD_CARGO== 11 // Prefeito

* keep only the winner candidate

gen opa01 = 1 if  DS_SIT_TOT_TURNO == "ELEITO"
keep if opa01 == 1
drop opa*

* generate variable depicting the winner party in the mayoral election

gen opa02 =  SG_PARTIDO
by SG_UE, sort: egen party_winner = mode(opa02)
tostring party_winner, replace
label variable party_winner "winner party in mayoral election"
drop opa*

* generate variable depincting the number of winner candidate in the mayoral elections

gen opa02 =  NR_CANDIDATO
by SG_UE, sort: egen numero_urna = mode(opa02)
tostring numero_urna, replace
label variable numero_urna "number of winner in the ballot"
drop opa*

* generate variable depincting the name of winner candidate in the mayoral elections

gen opa02 =  NM_CANDIDATO
by SG_UE, sort: egen name_of_winner = mode(opa02)
tostring name_of_winner, replace
label variable name_of_winner "name of winner in mayoral election"
drop opa*

* generate variable depicting the years of schooling of the mayor

gen education_mayor = .
replace education_mayor = 0 if  DS_GRAU_INSTRUCAO=="ANALFABETO" 
replace education_mayor = 1 if  DS_GRAU_INSTRUCAO=="LÊ E ESCREVE" 
replace education_mayor = 5.5 if  DS_GRAU_INSTRUCAO=="ENSINO FUNDAMENTAL INCOMPLETO" 
replace education_mayor = 9 if  DS_GRAU_INSTRUCAO=="ENSINO FUNDAMENTAL COMPLETO" 
replace education_mayor = 11 if  DS_GRAU_INSTRUCAO=="ENSINO MÉDIO INCOMPLETO"
replace education_mayor = 12 if  DS_GRAU_INSTRUCAO=="ENSINO MÉDIO COMPLETO" 
replace education_mayor = 15 if  DS_GRAU_INSTRUCAO=="SUPERIOR INCOMPLETO"
replace education_mayor = 17 if  DS_GRAU_INSTRUCAO=="SUPERIOR COMPLETO" 
  
label variable education_mayor "years of schooling of the mayor"

* generate variable depicting the gender of the mayor

gen female_mayor =.
replace female_mayor = 0 if DS_GENERO== "MASCULINO"
replace female_mayor = 1 if DS_GENERO=="FEMININO"
label variable female_mayor "1= mayor is a woman"

* generate variable depicting the age of the mayor
gen age_mayor = NR_IDADE_DATA_POSSE
replace age_mayor = . if age_mayor > 99
replace age_mayor = . if age_mayor < 20

label variable age_mayor "age of the mayor"

* clean data

by SG_UE, sort: drop if _n>1

destring SG_UE, replace
rename SG_UE cod_tse
rename year year_of_election

* keep only relevant variables

keep	cod_tse year_of_election education_mayor female_mayor age_mayor/*
	*/	party_winner numero_urna name_of_winner	
