
* generate variables

gen year = 2000

* keep only mayors candidate

keep if COD_CARGO== 11 // Prefeito

* keep only the winner candidate

gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
keep if opa01 == 1
drop opa*

* generate variable depicting the winner party in the mayoral election

gen opa02 =  SGL_PARTIDO
by COD_MUN, sort: egen party_winner = mode(opa02)
tostring party_winner, replace
label variable party_winner "winner party in mayoral election"
drop opa*

* generate variable depincting the number of winner candidate in the mayoral elections

gen opa02 =  NUMERO
by COD_MUN, sort: egen numero_urna = mode(opa02)
tostring numero_urna, replace
label variable numero_urna "number of winner in the ballot"
drop opa*

* generate variable depincting the name of winner candidate in the mayoral elections

gen opa02 =  NOME
by COD_MUN, sort: egen name_of_winner = mode(opa02)
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


* generate variable depicting the gender of the mayor

gen female_mayor =.
replace female_mayor = 0 if SEXO== "Masculino"
replace female_mayor = 1 if SEXO=="Feminino"
label variable female_mayor "1= mayor is a woman"


* generate variable depicting the age of the mayor


gen ano_nascimento = yofd(dofc(DT_NASC)) // generate a year from variable stored as a %tc component 
gen age_mayor = year - ano_nascimento
replace age_mayor = . if age_mayor > 99
replace age_mayor = . if age_mayor < 20

label variable age_mayor "age of the mayor"

* clean data

by COD_MUN, sort: drop if _n>1

destring COD_MUN, replace
rename COD_MUN cod_tse
rename year year_of_election

* keep only relevant variables

keep	cod_tse year_of_election education_mayor female_mayor age_mayor/*
	*/	party_winner numero_urna name_of_winner	
