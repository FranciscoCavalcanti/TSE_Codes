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

* keep only the winner candidate

gen opa01 = 1 if  DESC_SIT_TOT_TURNO == "ELEITO"
keep if opa01 == 1
drop opa*

* generate variable depicting the winner party in the mayoral election

gen opa02 =  SIGLA_PARTIDO
by SIGLA_UE, sort: egen party_winner = mode(opa02)
tostring party_winner, replace
label variable party_winner "winner party in mayoral election"
drop opa*

* generate variable depincting the number of winner candidate in the mayoral elections

gen opa02 =  NUMERO_CANDIDATO
by SIGLA_UE, sort: egen numero_urna = mode(opa02)
tostring numero_urna, replace
label variable numero_urna "number of winner in the ballot"
drop opa*

* generate variable depincting the name of winner candidate in the mayoral elections

gen opa02 =  NOME_CANDIDATO
by SIGLA_UE, sort: egen name_of_winner = mode(opa02)
tostring name_of_winner, replace
label variable name_of_winner "name of winner in mayoral election"
drop opa*

* generate variable depicting the years of schooling of the mayor

gen education_mayor = .
replace education_mayor = 0 if  DESCRICAO_GRAU_INSTRUCAO=="ANALFABETO" 
replace education_mayor = 1 if  DESCRICAO_GRAU_INSTRUCAO=="LÊ E ESCREVE" 
replace education_mayor = 5.5 if  DESCRICAO_GRAU_INSTRUCAO=="ENSINO FUNDAMENTAL INCOMPLETO" 
replace education_mayor = 9 if  DESCRICAO_GRAU_INSTRUCAO=="ENSINO FUNDAMENTAL COMPLETO" 
replace education_mayor = 11 if  DESCRICAO_GRAU_INSTRUCAO=="ENSINO MÉDIO INCOMPLETO"
replace education_mayor = 12 if  DESCRICAO_GRAU_INSTRUCAO=="ENSINO MÉDIO COMPLETO" 
replace education_mayor = 15 if  DESCRICAO_GRAU_INSTRUCAO=="SUPERIOR INCOMPLETO"
replace education_mayor = 17 if  DESCRICAO_GRAU_INSTRUCAO=="SUPERIOR COMPLETO" 
  
label variable education_mayor "years of schooling of the mayor"

* generate variable depicting the gender of the mayor

gen female_mayor =.
replace female_mayor = 0 if DESCRICAO_SEXO== "MASCULINO"
replace female_mayor = 1 if DESCRICAO_SEXO=="FEMININO"
label variable female_mayor "1= mayor is a woman"

* generate variable depicting the age of the mayor

generate ano_nascimento=real(substr(DATA_NASCIMENTO,7,4))

gen age_mayor = year - ano_nascimento
replace age_mayor = . if age_mayor > 99
replace age_mayor = . if age_mayor < 20

label variable age_mayor "age of the mayor"

* clean data

by SIGLA_UE, sort: drop if _n>1

destring SIGLA_UE, replace
rename SIGLA_UE cod_tse
rename year year_of_election

* keep only relevant variables

keep	cod_tse year_of_election education_mayor female_mayor age_mayor/*
	*/	party_winner numero_urna name_of_winner	
