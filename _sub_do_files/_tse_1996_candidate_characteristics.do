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

* indicate whether the candidate is elected
gen opa01 = 1 if  SITUACAO1T == "Eleito"
replace opa01 = 1 if SITUACAO2T == "Eleito"
gen candidate_elected = opa01
replace candidate_elected=0 if candidate_elected==.
drop opa*

* generate variable depicting the years of schooling of the mayor
gen education_mayor_candidates = .
replace education_mayor_candidates = 1 if  GRAU_INSTRUCAO=="Lê e escreve" 
replace education_mayor_candidates = 5.5 if  GRAU_INSTRUCAO=="Fundamental incompleto" 
replace education_mayor_candidates = 5.5 if  GRAU_INSTRUCAO=="1º grau incompleto" 
replace education_mayor_candidates = 9 if  GRAU_INSTRUCAO=="Fundamental completo" 
replace education_mayor_candidates = 9 if  GRAU_INSTRUCAO=="1º grau completo" 
replace education_mayor_candidates = 11 if  GRAU_INSTRUCAO=="2º grau incompleto"
replace education_mayor_candidates = 11 if  GRAU_INSTRUCAO=="Médio incompleto"
replace education_mayor_candidates = 12 if  GRAU_INSTRUCAO=="2º grau completo" 
replace education_mayor_candidates = 12 if  GRAU_INSTRUCAO=="Médio completo" 
replace education_mayor_candidates = 15 if  GRAU_INSTRUCAO=="Superior incompleto"
replace education_mayor_candidates = 17 if  GRAU_INSTRUCAO=="Superior completo" 
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
gen female_mayor_candidates =.
replace female_mayor_candidates = 0 if SEXO== "Masculino"
replace female_mayor_candidates = 1 if SEXO=="Feminino"
label variable female_mayor_candidates "share of female mayoral candidates"

* generate variable depicting the age of the mayor
gen ano_nascimento = yofd(dofc(DT_NASC)) // generate a year from variable stored as a %tc component 
gen age_mayor_candidates = year - ano_nascimento
replace age_mayor_candidates = . if age_mayor_candidates > 99
replace age_mayor_candidates = . if age_mayor_candidates < 20
label variable age_mayor_candidates "average age of mayoral candidates"

* generate variable depicting the number of mayoral candidates
gen n_mayor_candidates  =1 if CODIGO_CARGO== 11 // Prefeito
label variable n_mayor_candidates "number of mayoral candidates"

* clean data
rename SIGLA_UE cod_tse

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