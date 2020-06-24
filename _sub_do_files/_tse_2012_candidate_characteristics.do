rename v1	DATA_GERACAO
rename v2	HORA_GERACAO
rename v3	ANO_ELEICAO
rename v4	NUM_TURNO
rename v5	DESCRICAO_ELEICAO
rename v6	SIGLA_UF
rename v7	SIGLA_UE
rename v8	DESCRICAO_UE
rename v9	CODIGO_CARGO
rename v10	DESCRICAO_CARGO
rename v11	NOME_CANDIDATO
rename v12	SEQUENCIAL_CANDIDATO
rename v13	NUMERO_CANDIDATO
rename v14	NOME_URNA_CANDIDATO
rename v15	COD_SITUACAO_CANDIDATURA
rename v16	DES_SITUACAO_CANDIDATURA
rename v17	NUMERO_PARTIDO
rename v18	SIGLA_PARTIDO
rename v19	NOME_PARTIDO
rename v20	CODIGO_LEGENDA
rename v21	SIGLA_LEGENDA
rename v22	COMPOSICAO_LEGENDA
rename v23	NOME_LEGENDA
rename v24	CODIGO_OCUPACAO
rename v25	DESCRICAO_OCUPACAO
rename v26	DATA_NASCIMENTO
rename v27	NUM_TITULO_ELEITORAL_CANDIDATO
rename v28	IDADE_DATA_ELEICAO
rename v29	CODIGO_SEXO
rename v30	DESCRICAO_SEXO
rename v31	COD_DESCRICAO_GRAU_INSTRUCAO
rename v32	DESCRICAO_GRAU_INSTRUCAO
rename v33	CODIGO_ESTADO_CIVIL
rename v34	DESCRICAO_ESTADO_CIVIL
rename v35	CODIGO_NACIONALIDADE
rename v36	DESCRICAO_NACIONALIDADE
rename v37	SIGLA_UF_NASCIMENTO
rename v38	CODIGO_MUNICIPIO_NASCIMENTO
rename v39	NOME_MUNICIPIO_NASCIMENTO
rename v40	DESPESA_MAX_CAMPANHA
rename v41	COD_SIT_TOT_TURNO
rename v42	DESC_SIT_TOT_TURNO

* generate variables
gen year = 2012

* keep only mayors candidate
keep if CODIGO_CARGO== 11 // Prefeito

* indicate whether the candidate is elected
gen opa01 = 1 if  DESC_SIT_TOT_TURNO == "ELEITO"
gen candidate_elected = opa01
replace candidate_elected=0 if candidate_elected==.
drop opa*

* generate variable depicting the years of schooling of the mayor
gen education_mayor_candidates = .
replace education_mayor_candidates = 0 if  DESCRICAO_GRAU_INSTRUCAO=="ANALFABETO" 
replace education_mayor_candidates = 1 if  DESCRICAO_GRAU_INSTRUCAO=="LÊ E ESCREVE" 
replace education_mayor_candidates = 5.5 if  DESCRICAO_GRAU_INSTRUCAO=="ENSINO FUNDAMENTAL INCOMPLETO" 
replace education_mayor_candidates = 9 if  DESCRICAO_GRAU_INSTRUCAO=="ENSINO FUNDAMENTAL COMPLETO" 
replace education_mayor_candidates = 11 if  DESCRICAO_GRAU_INSTRUCAO=="ENSINO MÉDIO INCOMPLETO"
replace education_mayor_candidates = 12 if  DESCRICAO_GRAU_INSTRUCAO=="ENSINO MÉDIO COMPLETO" 
replace education_mayor_candidates = 15 if  DESCRICAO_GRAU_INSTRUCAO=="SUPERIOR INCOMPLETO"
replace education_mayor_candidates = 17 if  DESCRICAO_GRAU_INSTRUCAO=="SUPERIOR COMPLETO" 
label variable education_mayor_candidates "average years of schooling for mayoral candidates"

* generate variable depicting the gender of the mayor
gen female_mayor_candidates =.
replace female_mayor_candidates = 0 if DESCRICAO_SEXO== "MASCULINO"
replace female_mayor_candidates = 1 if DESCRICAO_SEXO=="FEMININO"
label variable female_mayor_candidates "share of female mayoral candidates"

* generate variable depicting the age of the mayor
generate ano_nascimento=real(substr(DATA_NASCIMENTO,-4,4))
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