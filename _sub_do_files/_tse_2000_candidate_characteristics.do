rename	v1	DATA_GERACAO 
rename	v2	HORA_GERACAO 
rename	v3	ANO_ELEICAO 
rename	v4	NUM_TURNO
rename	v5	DESCRICAO_ELEICAO
rename	v6	SIGLA_UF 
rename	v7	SIGLA_UE
rename	v8	DESCRICAO_UE 
rename	v9	CODIGO_CARGO
rename	v10	DESCRICAO_CARGO 
rename	v11	NOME_CANDIDATO 
rename	v12	SEQUENCIAL_CANDIDATO
rename	v13	NUMERO_CANDIDATO 
rename	v14	CPF_CANDIDATO 
rename	v15	NOME_URNA_CANDIDATO 
rename	v16	COD_SITUACAO_CANDIDATURA 
rename	v17	DES_SITUACAO_CANDIDATURA 
rename	v18	NUMERO_PARTIDO 
rename	v19	SIGLA_PARTIDO 
rename	v20	NOME_PARTIDO 
rename	v21	CODIGO_LEGENDA 
rename	v22	SIGLA_LEGENDA 
rename	v23	COMPOSICAO_LEGENDA 
rename	v24	NOME_LEGENDA 
rename	v25	CODIGO_OCUPACAO 
rename	v26	DESCRICAO_OCUPACAO 
rename	v27	DATA_NASCIMENTO 
rename	v28	NUM_TITULO_ELEITORAL_CANDIDATO 
rename	v29	IDADE_DATA_ELEICAO 
rename	v30	CODIGO_SEXO 
rename	v31	DESCRICAO_SEXO 
rename	v32	COD_GRAU_INSTRUCAO 
rename	v33	DESCRICAO_GRAU_INSTRUCAO 
rename	v34	CODIGO_ESTADO_CIVIL 
rename	v35	DESCRICAO_ESTADO_CIVIL 
rename	v36	CODIGO_NACIONALIDADE 
rename	v37	DESCRICAO_NACIONALIDADE 
rename	v38	SIGLA_UF_NASCIMENTO 
rename	v39	CODIGO_MUNICIPIO_NASCIMENTO 
rename	v40	NOME_MUNICIPIO_NASCIMENTO 
rename	v41	DESPESA_MAX_CAMPANHA 
rename	v42	COD_SIT_TOT_TURNO 
rename	v43	DESC_SIT_TOT_TURNO 

label variable	DATA_GERACAO "Data de geração do arquivo (data da extração)	"
label variable	HORA_GERACAO "Hora de geração do arquivo (hora da extração) - Horário de Brasília"
label variable	ANO_ELEICAO "Ano da eleição	"
label variable	NUM_TURNO	"Número do turno	"
label variable	DESCRICAO_ELEICAO	"Descrição da eleição	"
label variable	SIGLA_UF "Sigla da Unidade da Federação em que ocorreu a eleição	"
label variable	SIGLA_UE	"Sigla da Unidade Eleitoral"
label variable	DESCRICAO_UE "Descrição da Unidade Eleitoral	"
label variable	CODIGO_CARGO	"Código do cargo a que o candidato concorre	"
label variable	DESCRICAO_CARGO "Descrição do cargo a que o candidato concorre	"
label variable	NOME_CANDIDATO "Nome completo do candidato	"
label variable	SEQUENCIAL_CANDIDATO	"Número sequencial do candidato"
label variable	NUMERO_CANDIDATO "Número do candidato na urna	"
label variable	CPF_CANDIDATO "Número do CPF do Candidato	"
label variable	NOME_URNA_CANDIDATO "Nome de urna do candidato	"
label variable	COD_SITUACAO_CANDIDATURA "Código da situação de candidatura	"
label variable	DES_SITUACAO_CANDIDATURA "Descrição da situação de candidatura	"
label variable	NUMERO_PARTIDO "Número do partido	"
label variable	SIGLA_PARTIDO "Sigla do partido	"
label variable	NOME_PARTIDO "Nome do partido	"
label variable	CODIGO_LEGENDA "Código sequencial da legenda gerado pela Justiça Eleitoral	"
label variable	SIGLA_LEGENDA "Sigla da legenda	"
label variable	COMPOSICAO_LEGENDA "Composição da legenda	"
label variable	NOME_LEGENDA "Nome da legenda	"
label variable	CODIGO_OCUPACAO "Código da ocupação do candidato	"
label variable	DESCRICAO_OCUPACAO "Descrição da ocupação do candidato	"
label variable	DATA_NASCIMENTO "Data de nascimento do candidato	"
label variable	NUM_TITULO_ELEITORAL_CANDIDATO "Número do Título eleitoral do candidato	"
label variable	IDADE_DATA_ELEICAO "Idade do candidato da data da eleição	"
label variable	CODIGO_SEXO "Código do sexo do candidato	"
label variable	DESCRICAO_SEXO "Descrição do sexo do candidato	"
label variable	COD_GRAU_INSTRUCAO "Código do grau de instrução do candidato. Gerado internamente pelos sistemas eleitorais"
label variable	DESCRICAO_GRAU_INSTRUCAO "Descrição do grau de instrução do candidato	"
label variable	CODIGO_ESTADO_CIVIL "Código do estado civil do candidato	"
label variable	DESCRICAO_ESTADO_CIVIL "Descrição do estado civil do candidato	"
label variable	CODIGO_NACIONALIDADE "Código da nacionalidade do candidato	"
label variable	DESCRICAO_NACIONALIDADE "Descrição da nacionalidade do candidato	"
label variable	SIGLA_UF_NASCIMENTO "Sigla da UF de nascimento do candidato	"
label variable	CODIGO_MUNICIPIO_NASCIMENTO "Código TSE do município da nascimento do candidato	"
label variable	NOME_MUNICIPIO_NASCIMENTO "Nome do município de nascimento do candidato	"
label variable	DESPESA_MAX_CAMPANHA "Despesa máxima de campanha declarada pelo partido para aquele cargo. Valores em Reais."
label variable	COD_SIT_TOT_TURNO "Código da situação de totalização do candidato naquele turno	"
label variable	DESC_SIT_TOT_TURNO 	"Descrição da situação de totalização do candidato naquele turno"

* generate variables
cap gen year = 2000

* keep only mayors candidate
keep if CODIGO_CARGO== 11 // Prefeito

* indicate whether the candidate is elected
gen opa01 = 1 if  DESC_SIT_TOT_TURNO == "ELEITO"
gen candidate_elected = opa01
replace candidate_elected=0 if candidate_elected==.
drop opa*

* generate variable depicting the years of schooling of the mayor
gen education_mayor_candidates = .
replace education_mayor_candidates = 1 if  COD_GRAU_INSTRUCAO== 2 		// "LÊ E ESCREVE" 
replace education_mayor_candidates = 5.5 if  COD_GRAU_INSTRUCAO== 3 	//  1º GRAU INCOMPLETO "ENSINO FUNDAMENTAL INCOMPLETO" 
replace education_mayor_candidates = 9 if  COD_GRAU_INSTRUCAO==4 		// 1º GRAU COMPLETO "ENSINO FUNDAMENTAL COMPLETO" 
replace education_mayor_candidates = 11 if  COD_GRAU_INSTRUCAO==5 		// 2º GRAU INCOMPLETO "ENSINO MÉDIO INCOMPLETO"
replace education_mayor_candidates = 12 if  COD_GRAU_INSTRUCAO==6 		// 2º GRAU COMPLETO "ENSINO MÉDIO COMPLETO" 
replace education_mayor_candidates = 15 if  COD_GRAU_INSTRUCAO==7 		// SUPERIOR INCOMPLETO 
replace education_mayor_candidates = 17 if  COD_GRAU_INSTRUCAO==8 		// "SUPERIOR COMPLETO" 
label variable education_mayor_candidates "average years of schooling for mayoral candidates"

* generate variable depicting the gender of the mayor
gen female_mayor_candidates =.
replace female_mayor_candidates = 0 if DESCRICAO_SEXO== "MASCULINO"
replace female_mayor_candidates = 1 if DESCRICAO_SEXO=="FEMININO"
label variable female_mayor_candidates "share of female mayoral candidates"

* generate variable depicting the age of the mayor
tostring DATA_NASCIMENTO, generate(tool1)
generate ano_nascimento=real(substr(tool1,-4,4)) 
gen age_mayor_candidates = year - ano_nascimento
replace age_mayor_candidates = . if age_mayor_candidates > 99
replace age_mayor_candidates = . if age_mayor_candidates < 20
label variable age_mayor_candidates "average age of mayoral candidates"
cap drop tool1

* generate variable depicting the number of mayoral candidates
gen n_mayor_candidates  =1 if CODIGO_CARGO== 11 // Prefeito
label variable n_mayor_candidates "number of mayoral candidates"

* clean data
rename SIGLA_UE cod_tse

**************************************
**	Collapse at municipality level 	**
**************************************

// attach label of variables
local var_mean education_mayor_candidates female_mayor_candidates age_mayor_candidates
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
