
** 2010 election

* unzip file
cd "$tmp"
pwd
unzipfile	"${InpDir}/2010/consulta_cand_2010.zip", replace

//CANDIDATES
//import data raw data and save as .dta by state

foreach uf in DF BR AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2010_`uf'.txt", /*
	*/	delimiter(";", asstring) varname(noname) /*
	*/	stringcols(_all) /*
	*/	encoding(ISO-8859-1) clear
gen uf="`uf'"
save "$tmp/`uf'.dta", replace
}

//append data

foreach uf in DF BR AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP {
append using "$tmp/`uf'", force
}

//delete temp files data
foreach uf in DF BR AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
cap erase	"$tmp/`uf'.dta"
cap erase	"$tmp/consulta_cand_2010_`uf'.txt"
}

//rename and edit variables

rename v1 data_geracao
rename v2 hora_geracao
rename v3 ano_eleicao
rename v4 num_turno
rename v5 descricao_eleicao
rename v6 sigla_uf
rename v7 sigla_ue
rename v8 descricao_ue
rename v9 codigo_cargo
rename v10 descricao_cargo
rename v11 nome_candidato
rename v12 sequencial_candidato
rename v13 numero_candidato
rename v14 cpf_candidato
rename v15 nome_urna_cand
rename v16 cod_situacao_candidatura
rename v17 ds_sit_cand
rename v18 nr_part 
rename v19 sigla_partido
rename v20 nome_partido
rename v21 codigo_legenda
rename v22 sigla_legenda
rename v23 comp_legenda
rename v24 nome_legenda
rename v25 codigo_ocupacao
rename v26 descricao_ocupacao
rename v27 data_nascimento
rename v28 num_titulo_eleitoral
rename v29 idade_data_eleicao
rename v30 codigo_sexo 
rename v31 descricao_sexo 
rename v32 cod_grau_instrucao
rename v33 des_grau_instrucao
rename v34 codigo_estado_civil
rename v35 descricao_estado_civil
rename v36 cd_nacionalidade
rename v37 des_nacionalidade
rename v38 sigla_uf_nasc
rename v39 codmun_nasc
rename v40 nome_mun_nasc
rename v41 despesa_max_camp
rename v42 cod_sit_tot_turno
rename v43 desc_sit_tot_turno

//drop if candidates:

encode desc_sit_tot_turno, gen(situacao)
label list situacao

drop if situacao==8 // 8 REGISTRO NEGADO ANTES DA ELEIÇÃO
drop if situacao==10 // 10 RENÚNCIA/FALECIMENTO/CASSAÇÃO ANTES DA ELEIÇÃO

encode ds_sit_cand, gen(situacao2)
label list situacao2

drop if situacao2==1 // 1 CANCELADO
drop if situacao2==6 // 6 FALECIDO
drop if situacao2==7 // 7 INDEFERIDO
drop if situacao2==8 // 8 INDEFERIDO COM RECURSO
drop if situacao2==9 // 9 NÃO CONHECIMENTO DO PEDIDO
drop if situacao2==10 // 10 RENÚNCIA
drop if situacao2==11 // 11 SUBSTITUTO MAJORITÁRIO PENDENTE DE JULGAMENTO

//selection of specific candidates

keep if 	codigo_cargo == "6" /*  DEPUTADO FEDERAL
	*/	|	codigo_cargo == "1" /*	PRESIDENTE
	*/	|	codigo_cargo == "5" /*	SENADOR
	*/	|	codigo_cargo == "7" /*	DEPUTADO ESTADUAL
	*/	|	codigo_cargo == "3" /*	GOVERNADOR	
	*/	|	codigo_cargo == "8" //	DEPUTADO DISTRITAL			

//encode candidates by state, number, and political office
drop if missing(numero_candidato)
egen cand=group(uf descricao_cargo numero_candidato cpf_candidato)
egen qtspcand=count(cand), by (cand)
destring num_turno, replace

//some candidates appear more than once because of the second round
egen turno2=max(num_turno), by (cand)
gen eleito=0
label list situacao
replace eleito=1 if situacao==4 //4 ELEITO
replace eleito=1 if situacao==6 //6 MÉDIA
egen eleito2=max(eleito), by (cand)
drop eleito
rename eleito2 eleito
duplicates drop cand, force
duplicates drop cpf_candidato, force

//Edit variables

* take out accents and double space

gen normalized_string = ustrto(ustrnormalize(nome_candidato, "nfd"), "ascii", 2)
replace nome_candidato = normalized_string
drop normalized_string

// set format
recast str nome_candidato 
recast str uf 
recast str sigla_partido 
recast str numero_candidato 

// check for unique identifiers 
isid cpf_candidato
isid nome_candidato sequencial_candidato sigla_partido numero_candidato
isid nome_candidato sigla_partido numero_candidato
isid numero_candidato uf sigla_partido
isid nome_candidato numero_candidato 

// save temporary dataset
save "$tmp/candidatos.dta", replace


//POLITICAL DONATIONS

* unzip file
cd "$tmp"
pwd
 unzipfile	"${InpDir}/2010/prestacao_contas_2010.zip", replace

//Atribuir receitas de comite para presidente

foreach uf in  BR DF AC AL AM AP BA DF CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO  {

clear
import delimited "$tmp/comite/`uf'/ReceitasComites.txt", delimiter(";") /*
	*/	varname(1) /*
	*/	stringcols(_all) /*
	*/	encoding(ISO-8859-1)
save "$tmp/ReceitasComites_`uf'.dta", replace
}

//append files
foreach uf in BR DF AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP {
append using "$tmp/ReceitasComites_`uf'.dta", force
}


//delete temp files data
foreach uf in DF BR AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
erase	"$tmp/ReceitasComites_`uf'.dta"
}

//keep if tipocomite=="Comitê Financeiro Nacional para Presidente da República"

//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"RECURSOS DE PARTIDO POLÍTICO"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"RECURSOS DE OUTROS CANDIDATOS/COMITÊS"	//
	
drop	if	cpfcnpjdodoador	=="" /*
	*/ | cpfcnpjdodoador	=="---" 

// Criar variaveis para futuro merge

gen descricao_cargo="PRESIDENTE" if tipocomite=="Comitê Financeiro Nacional para Presidente da República"
gen codigo_cargo = "1" if tipocomite=="Comitê Financeiro Nacional para Presidente da República"

replace descricao_cargo="PRESIDENTE" if tipocomite=="Comitê Financeiro Único"
replace codigo_cargo = "1" if tipocomite=="Comitê Financeiro Único"

replace descricao_cargo="GOVERNADOR" if tipocomite=="Comitê Financeiro Distrital/Estadual para Deputado Distrital"
replace codigo_cargo = "3" if tipocomite=="Comitê Financeiro Distrital/Estadual para Deputado Distrital"

replace descricao_cargo="GOVERNADOR" if tipocomite=="Comitê Financeiro Distrital/Estadual para Deputado Estadual"
replace codigo_cargo = "3" if tipocomite=="Comitê Financeiro Distrital/Estadual para Deputado Estadual"

replace descricao_cargo="GOVERNADOR" if tipocomite=="Comitê Financeiro Distrital/Estadual para Governador"
replace codigo_cargo = "3" if tipocomite=="Comitê Financeiro Distrital/Estadual para Governador"

gen sigla_partido = siglapartido

//
merge	n:n descricao_cargo codigo_cargo sigla_partido uf using "$tmp/candidatos"
// salvar para doacoes para governadores e presidente
preserve
keep if _merge ==3
drop _merge
gen revenue_source ="comite"
save "$tmp/comitepresidentegovernador", replace
// salvar para doacoes para a colisao dos governadores e presidente
restore
keep if _merge ==1
drop _merge
gen revenue_source ="comite"
save "$tmp/comitecoalisao", replace
//
clear

//POLITICAL DONATIONS
//Atribuir receitas para diretorio nacional para candidatos a presidente

foreach uf in  BR DF AC AL AM AP BA DF CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO  {

clear
import delimited "$tmp/partido/`uf'/ReceitasPartidos.txt", delimiter(";") /*
	*/	varname(1) /*
	*/	stringcols(_all) /*
	*/	encoding(ISO-8859-1)
save "$tmp/ReceitasPartidos_`uf'.dta", replace
}

//append files
foreach uf in BR DF AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP  {
append using "$tmp/ReceitasPartidos_`uf'.dta", force
}

//delete temp files
foreach uf in DF BR AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
erase	"$tmp/ReceitasPartidos_`uf'.dta"
}

//
//keep if tipopartido=="Direção Nacional"

//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"RECURSOS DE PARTIDO POLÍTICO"	/*
	*/	|	tiporeceita	==	"Recursos de origens não identificadas"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*	
	*/	|	tiporeceita	==	"RECURSOS DE OUTROS CANDIDATOS/COMITÊS"	//
	
drop	if	cpfcnpjdodoador	==""

// Criar variaveis para futuro merge

gen descricao_cargo="PRESIDENTE" if tipopartido=="Direção Nacional"
gen codigo_cargo = "1" if tipopartido=="Direção Nacional"

replace descricao_cargo="GOVERNADOR" if tipopartido=="Direção Estadual/Distrital"
replace codigo_cargo = "3" if tipopartido=="Direção Estadual/Distrital"

gen sigla_partido = siglapartido
gen revenue_source ="party"

//
merge	n:n descricao_cargo codigo_cargo sigla_partido uf using "$tmp/candidatos"
// salvar para doacoes para governadores e presidente
preserve
keep if _merge ==3
drop _merge
save "$tmp/partidopresidentegovernador", replace
// salvar para doacoes para a colisao dos governadores e presidente
restore
keep if _merge ==1
drop _merge
save "$tmp/partidocoalisao", replace

clear

//POLITICAL DONATIONS
//Atribuir receitas de candidatos

foreach uf in  BR DF AC AL AM AP BA DF CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO  {

clear
import delimited "$tmp/candidato/`uf'/ReceitasCandidatos.txt", delimiter(";") /*
	*/	varname(1) /*
	*/	stringcols(_all) /*
	*/	encoding(ISO-8859-1)
save "$tmp/ReceitasCandidatos_`uf'.dta", replace
}

//append files
foreach uf in BR DF AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP  {
append using "$tmp/ReceitasCandidatos_`uf'.dta", force
}

//delete temp files
foreach uf in DF BR AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
erase	"$tmp/ReceitasCandidatos_`uf'.dta"
}


//
/*
keep if		cargo=="Deputado Federal" /*
	*/	|	cargo=="Senador" /*
	*/	|	cargo=="Presidente" //
*/	
	
//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"RECURSOS DE PARTIDO POLÍTICO"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"Recursos de origens não identificadas"	/*			
	*/	|	tiporeceita	==	"RECURSOS DE OUTROS CANDIDATOS/COMITÊS"	//
	
drop	if	cpfcnpjdodoador	==""

// Criar variaveis para futuro merge
gen sigla_partido = siglapartido
gen sequencial_candidato = sequencialcandidato
gen nome_candidato = nomecandidato
gen cpf_candidato = cpfdocandidato
gen numero_candidato = númerocandidato
gen revenue_source ="candidate"


//Edit variables

* take out accents and double space
/*
foreach v of varlist nome_candidato {
di "`v'"
do "${CodeDir}/_no_accents_etc.do" `v'
do "${CodeDir}/_no_capital_letters.do" `v'
}
*/

* take out accents and double space

gen normalized_string = ustrto(ustrnormalize(nome_candidato, "nfd"), "ascii", 2)
replace nome_candidato = normalized_string
drop normalized_string

// set format
recast str nome_candidato 
recast str uf 
recast str sigla_partido 
recast str numero_candidato 

// 
* matching candidates with observable characteristics
merge	n:1 cpf_candidato nome_candidato sequencial_candidato sigla_partido uf using "$tmp/candidatos", update

preserve
keep if _merge ==3 | _merge ==4 | _merge ==5
drop _merge
save "$tmp/receitacandidato1", replace
restore

keep if _merge==1
drop _merge
merge	n:1 sequencial_candidato sigla_partido numero_candidato using "$tmp/candidatos", update

preserve
keep if _merge ==3 | _merge ==4 | _merge ==5
drop _merge
save "$tmp/receitacandidato2", replace
restore

keep if _merge==1
drop _merge
merge	n:1 sigla_partido numero_candidato uf  using "$tmp/candidatos", update

preserve
keep if _merge ==3 | _merge ==4 | _merge ==5
drop _merge
save "$tmp/receitacandidato3", replace
restore

keep if _merge==1
drop _merge
merge	n:1 cpf_candidato using "$tmp/candidatos", update

preserve
keep if _merge ==3 | _merge ==4 | _merge ==5
drop _merge
save "$tmp/receitacandidato4", replace
restore

keep if _merge==1
drop _merge
save "$tmp/receitacandidato5", replace
clear


//	merge bases

use "$tmp/comitepresidentegovernador", clear
append using "$tmp/comitecoalisao", force
append using "$tmp/partidopresidentegovernador", force
append using "$tmp/partidocoalisao", force
append using "$tmp/receitacandidato1", force
append using "$tmp/receitacandidato2", force
append using "$tmp/receitacandidato3", force
append using "$tmp/receitacandidato4", force
append using "$tmp/receitacandidato5", force

//clean data
tostring uf, replace

replace valorreceita =subinstr(valorreceita,`","',".", .)	
destring valorreceita, replace

//collapse data 
collapse (sum) valorreceita (firstnm) revenue_source descricao_cargo eleito, by(nome_candidato numero_candidato uf codigo_cargo cpfcnpjdodoador)

// drop if 
drop if cpfcnpjdodoador ==""

// generate final variables
gen ano_eleicao = "2010"
label variable ano_eleicao "Election year"

//label variables
label variable valorreceita "Value of campaign donation"
label variable eleito "Candidate was elected?"
label variable nome_candidato "Name of candidate"
label variable numero_candidato "Number of candidate"
label variable uf "UF code"
label variable codigo_cargo "Code of position"
label variable descricao_cargo "Description of position"
label variable cpfcnpjdodoador "CPF or CNPJ"
label variable revenue_source "The direct beneficiary of the donation"

//Save and clear
save "$tmp/_tse_doacoes_2010", replace
clear

//delete temp files data
cap erase "$tmp/candidatos.dta"
cap erase "$tmp/comitecoalisao.dta"
cap erase "$tmp/comitepresidentegovernador.dta"
cap erase "$tmp/partidocoalisao.dta"
cap erase "$tmp/partidopresidentegovernador.dta"
cap erase "$tmp/receitacandidato1.dta"
cap erase "$tmp/receitacandidato2.dta"
cap erase "$tmp/receitacandidato3.dta"
cap erase "$tmp/receitacandidato4.dta"
cap erase "$tmp/receitacandidato5.dta"

cap erase "$tmp/LEIAME.pdf"

//delete folder
shell rd "$tmp/candidato" /s /q
shell rd "$tmp/comite" /s /q
shell rd "$tmp/partido" /s /q

