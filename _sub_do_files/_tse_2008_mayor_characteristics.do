rename	v1	DATA_GERACAO 
rename	v2	HORA_GERACAO 
rename	v3	ANO_ELEICAO 
rename	v4	NUM_TURNO // variáveis que podem ser utilizadas para relacionar os arquivos uns com os outros
rename	v5	DESCRICAO_ELEICAO // variáveis que podem ser utilizadas para relacionar os arquivos uns com os outros
rename	v6	SIGLA_UF 
rename	v7	SIGLA_UE // variáveis que podem ser utilizadas para relacionar os arquivos uns com os outros
rename	v8	DESCRICAO_UE 
rename	v9	CODIGO_CARGO // variáveis que podem ser utilizadas para relacionar os arquivos uns com os outros
rename	v10	DESCRICAO_CARGO 
rename	v11	NOME_CANDIDATO 
rename	v12	SEQUENCIAL_CANDIDATO // variáveis que podem ser utilizadas para relacionar os arquivos uns com os outros
rename	v13	NUMERO_CANDIDATO 
rename	v14	NOME_URNA_CANDIDATO 
rename	v15	COD_SITUACAO_CANDIDATURA 
rename	v16	DES_SITUACAO_CANDIDATURA 
rename	v17	NUMERO_PARTIDO 
rename	v18	SIGLA_PARTIDO 
rename	v19	NOME_PARTIDO 
rename	v20	CODIGO_LEGENDA 
rename	v21	SIGLA_LEGENDA 
rename	v22	COMPOSICAO_LEGENDA 
rename	v23	NOME_LEGENDA 
rename	v24	CODIGO_OCUPACAO 
rename	v25	DESCRICAO_OCUPACAO 
rename	v26	DATA_NASCIMENTO 
rename	v27	NUM_TITULO_ELEITORAL_CANDIDATO
rename	v28	IDADE_DATA_ELEICAO 
rename	v29	CODIGO_SEXO 
rename	v30	DESCRICAO_SEXO 
rename	v31	COD_GRAU_INSTRUCAO 
rename	v32	DESCRICAO_GRAU_INSTRUCAO 
rename	v33	CODIGO_ESTADO_CIVIL 
rename	v34	DESCRICAO_ESTADO_CIVIL 
rename	v35	CODIGO_NACIONALIDADE 
rename	v36	DESCRICAO_NACIONALIDADE 
rename	v37	SIGLA_UF_NASCIMENTO 
rename	v38	CODIGO_MUNICIPIO_NASCIMENTO 
rename	v39	NOME_MUNICIPIO_NASCIMENTO 
rename	v40	DESPESA_MAX_CAMPANHA 
rename	v41	COD_SIT_TOT_TURNO 
rename	v42	DESC_SIT_TOT_TURNO 
 

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
*label variable	CPF_CANDIDATO "Número do CPF do Candidato	"
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
label variable	COD_GRAU_INSTRUCAO "Descrição do grau de instrução do candidato	"
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

gen year = 2008

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
replace female_mayor = 0 if DESCRICAO_SEXO== "MASCULINO"
replace female_mayor = 1 if DESCRICAO_SEXO=="FEMININO"
label variable female_mayor "1= mayor is a woman"

* generate variable depicting the age of the mayor

generate ano_nascimento=real(substr(DATA_NASCIMENTO,8,2)) + 1900

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

keep	cod_tse year_of_election education_mayor education_mayor_HD education_mayor_UD female_mayor age_mayor/*
	*/	party_winner numero_urna name_of_winner	
