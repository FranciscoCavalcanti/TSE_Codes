
* generate variables
gen year = 2016

* keep only mayors candidate
keep if CD_CARGO== 11 // Prefeito

* indicate whether the candidate is elected
gen opa01 = 1 if  DS_SIT_TOT_TURNO == "ELEITO"
gen candidate_elected = opa01
replace candidate_elected=0 if candidate_elected==.
drop opa*

* generate variable depicting the years of schooling of the mayor
gen education_mayor_candidates = .
replace education_mayor_candidates = 0 if  DS_GRAU_INSTRUCAO=="ANALFABETO" 
replace education_mayor_candidates = 1 if  DS_GRAU_INSTRUCAO=="LÊ E ESCREVE" 
replace education_mayor_candidates = 5.5 if  DS_GRAU_INSTRUCAO=="ENSINO FUNDAMENTAL INCOMPLETO" 
replace education_mayor_candidates = 9 if  DS_GRAU_INSTRUCAO=="ENSINO FUNDAMENTAL COMPLETO" 
replace education_mayor_candidates = 11 if  DS_GRAU_INSTRUCAO=="ENSINO MÉDIO INCOMPLETO"
replace education_mayor_candidates = 12 if  DS_GRAU_INSTRUCAO=="ENSINO MÉDIO COMPLETO" 
replace education_mayor_candidates = 15 if  DS_GRAU_INSTRUCAO=="SUPERIOR INCOMPLETO"
replace education_mayor_candidates = 17 if  DS_GRAU_INSTRUCAO=="SUPERIOR COMPLETO"  
label variable education_mayor_candidates "average years of schooling for mayoral candidates"

* generate dummy for having a high school degree
gen education_mayor_candidates_HD = 1  if education_mayor_candidates>=12 
replace education_mayor_candidates_HD = 0  if education_mayor_candidates_HD==. 
label variable education_mayor_candidates_HD "share of mayoral candidates having a high school degree"

* generate dummy for having a university degree
gen education_mayor_candidates_UD = 1  if education_mayor_candidates>=17 
replace education_mayor_candidates_UD = 0  if education_mayor_candidates_UD==. 
label variable education_mayor_candidates_UD "share of mayoral candidates having an university degree"

* generate variable depicting the gender of the mayor
gen female_mayor_candidates=.
replace female_mayor_candidates= 0 if DS_GENERO== "MASCULINO"
replace female_mayor_candidates = 1 if DS_GENERO=="FEMININO"
label variable female_mayor_candidates "share of female mayoral candidates"

* generate variable depicting the age of the mayor
gen age_mayor_candidates = NR_IDADE_DATA_POSSE
replace age_mayor_candidates = . if age_mayor_candidates > 99
replace age_mayor_candidates = . if age_mayor_candidates < 20
label variable age_mayor_candidates "average age of mayoral candidates"

* generate variable depicting the number of mayoral candidates
gen n_mayor_candidates  =1 if CD_CARGO== 11 // Prefeito
label variable n_mayor_candidates "number of mayoral candidates"

* clean data
rename SG_UE cod_tse

**************************************
**	Collapse at municipality level 	**
**************************************

// attach label of variables
local var_mean education_mayor_candidates education_mayor_candidates_HD education_mayor_candidates_UD female_mayor_candidates age_mayor_candidates
local var_sum n_mayor_candidates

foreach v of var `var_mean' `var_sum' {
    local l`v' : variable label `v'
}

* colapse
collapse (mean)`var_mean' (sum) `var_sum', by(cod_tse year)

// copy back the label of variables
foreach v of var `var_mean' `var_sum' {
    label var `v' "`l`v''"
}