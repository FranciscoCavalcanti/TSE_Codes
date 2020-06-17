clear
set more off

** 2012 mayoral election

//CANDIDATES

* unzip file
cd "$tmp"
pwd
unzipfile	"${InpDir}/2012/consulta_cand_2012.zip", replace

//CANDIDATES
//import data raw data and save as .dta by state

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2012_`uf'.txt", /*
	*/	delimiter(";", asstring)  /*
	*/ 	varname(noname) 	/*
	*/	stringcols(_all) /*
	*/	encoding(ISO-8859-1) clear
gen uf="`uf'"
save "$tmp/`uf'.dta", replace
}

//append data

foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP {
append using "$tmp/`uf'", force
}

//delete temp files data
foreach uf in AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
erase	"$tmp/`uf'.dta"
erase	"$tmp/consulta_cand_2012_`uf'.txt"
}

erase	"$tmp/LEIAME.pdf"

//rename and edit variables

rename v1	data_geracao
rename v2	hora_geracao
rename v3	ano_eleicao
rename v4	num_turno
rename v5	descricao_eleicao
rename v6	sgl_uf
rename v7	cod_mun
rename v8	municipio
rename v9	cod_cargo
rename v10	cargo
rename v11	nome
rename v12	id_candidato
rename v13	numero
rename v14	nome_urna
rename v15	cod_situacao_candidatura
rename v16	des_situacao_candidatura
rename v17	numero_partido
rename v18	sgl_partido
rename v19	nome_partido
rename v20	codigo_legenda
rename v21	sigla_legenda
rename v22	composicao
rename v23	nome_coligacao
rename v24	ocupacao
rename v25	descricao_ocupacao
rename v26	dt_nasc
rename v27	titulo
rename v28	idade_data_eleicao
rename v29	sexo
rename v30	descricao_sexo
rename v31	grau_instrucao
rename v32	descricao_grau_instrucao
rename v33	estado_civil
rename v34	descricao_estado_civil
rename v35	codigo_nacionalidade
rename v36	descricao_nacionalidade
rename v37	uf_nasc
rename v38	codigo_municipio_nascimento
rename v39	no_mun_nasc
rename v40	vr_gasto
rename v41	cod_sit_tot_turno
rename v42	des_sit_tot_turno

rename sgl_uf sigla_uf
rename cod_mun sigla_ue
rename municipio descricao_ue
rename cod_cargo codigo_cargo
rename cargo descricao_cargo
rename nome nome_candidato
rename id_candidato sequencial_candidato
rename numero numero_candidato
*rename cpf cpf_candidato
rename nome_urna nome_urna_cand
rename sgl_partido sigla_partido
rename composicao comp_legenda
rename nome_coligacao nome_legenda
rename ocupacao codigo_ocupacao
rename dt_nasc data_nascimento
rename titulo num_titulo_eleitoral
rename sexo codigo_sexo 
rename grau_instrucao cod_grau_instrucao
rename estado_civil codigo_estado_civil
rename uf_nasc sigla_uf_nasc
rename no_mun_nasc nome_mun_nasc
rename vr_gasto despesa_max_camp

//drop if vice candidates:
drop if descricao_cargo == "VICE-PREFEITO" //
keep if descricao_cargo == "PREFEITO" | descricao_cargo == "VEREADOR" 

gen iten1 = 0 
replace iten1 =regexm(descricao_cargo,  "VOCÊ É A FAVOR")
drop if iten1==1
drop iten1 

//selection of specific candidates		

//encode candidates by state, number, and political office
drop if missing(numero_candidato)
egen cand=group(sigla_ue descricao_cargo numero_candidato)
egen qtspcand=count(cand), by (cand)

//some candidates appear more than once because of the second round
gen iten1= 1 if des_sit_tot_turno =="ELEITO" 
gen iten2= 1 if des_sit_tot_turno =="ELEITO POR MÉDIA" 
gen iten3= 1 if des_sit_tot_turno =="ELEITO POR QP" 


gen eleito=0
replace eleito=1 if iten1==1 //3 ELEITO
replace eleito=1 if iten2==1 //3 ELEITO
replace eleito=1 if iten3==1 //3 ELEITO
egen eleito2=max(eleito), by (cand)
drop eleito iten*
rename eleito2 eleito
duplicates drop cand, force

//Edit variables

* take out accents and double space
gen normalized_string = ustrto(ustrnormalize(nome_candidato, "nfd"), "ascii", 2)
replace nome_candidato = normalized_string
drop normalized_string

// check for unique identifiers 
isid nome_candidato sequencial_candidato sigla_partido numero_candidato, missok
isid nome_candidato sigla_partido numero_candidato sigla_ue, missok
isid numero_candidato sigla_ue sigla_partido, missok

// keep only relevant variables
keep nome_candidato sigla_ue sigla_partido numero_candidato codigo_cargo descricao_cargo eleito sequencial_candidato num_titulo_eleitoral

// set format
recast str nome_candidato 
recast str sigla_ue 
recast str sigla_partido 
recast str numero_candidato 
recast str codigo_cargo 
recast str sequencial_candidato 
recast str num_titulo_eleitoral 

// save temporary dataset
save "$tmp/candidatos.dta", replace


//POLITICAL DONATIONS

// problem: after unzip it should convert data from .csv to txt
// reason: import command is not working properly

* 1) unzip file
cd "$tmp"
pwd
unzipfile	"${InpDir}/2012/prestacao_final_2012.zip", replace


//Atribuir receitas de comites
clear
import delimited "$tmp/receitas_comites_2012_brasil.txt", /*
	*/	case(lower)   stringcols(_all) clear

cap gen tiporeceita = ds_esp_recurso 
cap gen cpfcnpjdodoador = cd_cpf_cnpj_doador
cap gen nomedodoador = nm_doador
cap gen datadareceita = dt_receita
cap gen valorreceita = vr_receita
cap gen ds_orgao = tipocomite 

// Criar variaveis para futuro merge
gen descricao_cargo="PREFEITO" if ds_orgao=="Comitê Financeiro para Prefeito"
gen codigo_cargo = "11" if ds_orgao=="Comitê Financeiro para Prefeito"

gen sigla_partido = siglapartido
gen sigla_ue = númeroue  
tostring sigla_ue, replace

//
merge	n:n sigla_ue sigla_partido codigo_cargo  using "$tmp/candidatos"
// salvar para doacoes para prefeitos
preserve
keep if _merge ==3
drop _merge
gen revenue_source ="comite"
save "$tmp/comiteprefeito", replace
// salvar para doacoes para a coalisao dos prefeitos e vereadores
restore
keep if _merge ==1
drop _merge
gen revenue_source ="comite"
save "$tmp/comitecoalisao", replace

clear

//POLITICAL DONATIONS

//Atribuir receitas de partidos
clear
import delimited "$tmp/receitas_partidos_2012_brasil.txt", /*
	*/	case(lower)   stringcols(_all) clear

	
//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"Recursos de origens não identificadas"	/*
	*/	|	tiporeceita	==	"Recursos de outros candidatos/comitês"	/*
	*/	|	tiporeceita	==	"Recursos de partido político"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	
	
	
// Criar variaveis para futuro merge
gen descricao_cargo="PREFEITO" if tipodiretorio=="Direção Municipal"
gen codigo_cargo = "11" if tipodiretorio=="Direção Municipal"
	
// Criar variaveis para futuro merge
gen sigla_partido = siglapartido 
gen sigla_ue = númeroue 
gen revenue_source ="party"

//
merge	n:n codigo_cargo sigla_partido sigla_ue using "$tmp/candidatos"
// salvar para doacoes para governadores e presidente
preserve
keep if _merge ==3
drop _merge
save "$tmp/partidoprefeito", replace
// salvar para doacoes para a colisao dos governadores e presidente
restore
keep if _merge ==1
drop _merge
save "$tmp/partidocoalisao", replace

clear

//POLITICAL DONATIONS

//Atribuir receitas de candidatos
clear
import delimited "$tmp/receitas_candidatos_2012_brasil.txt", /*
	*/	case(lower)   stringcols(_all) clear

	
//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"Recursos de origens não identificadas"	/*
	*/	|	tiporeceita	==	"Recursos de outros candidatos/comitês"	/*
	*/	|	tiporeceita	==	"Recursos de partido político"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	
	
drop	if	cpfcnpjdodoador	=="" /*
	*/ |	cpfcnpjdodoador	=="." 
	
// Criar variaveis para futuro merge
gen codigo_cargo = "13" if cargo == "Vereador"
replace codigo_cargo = "11" if cargo =="Prefeito"
gen sigla_partido = siglapartido
gen sequencial_candidato = sequencialcandidato
gen nome_candidato = nomecandidato
gen cpf_candidato = cpfdocandidato
gen numero_candidato = númerocandidato
gen sigla_ue = numeroue
gen revenue_source ="candidate"

 
tostring numero_candidato, replace
tostring sigla_ue, replace

* take out accents and double space

gen normalized_string = ustrto(ustrnormalize(nome_candidato, "nfd"), "ascii", 2)
replace nome_candidato = normalized_string
drop normalized_string

// set format
recast str nome_candidato 
recast str sigla_ue 
recast str sigla_partido 
recast str numero_candidato 
recast str codigo_cargo 

// 
* matching candidates with observable characteristics
merge	n:1 nome_candidato sigla_ue sequencial_candidato sigla_partido numero_candidato using "$tmp/candidatos"

preserve
keep if _merge ==3
drop _merge
save "$tmp/receitacandidato1", replace
restore

keep if _merge==1
drop _merge
merge	n:1 nome_candidato sigla_ue sigla_partido numero_candidato using "$tmp/candidatos"

preserve
keep if _merge ==3
drop _merge
save "$tmp/receitacandidato2", replace
restore

keep if _merge==1
drop _merge
save "$tmp/receitacandidato3", replace
clear

//	merge bases

use "$tmp/comiteprefeito", clear
append using "$tmp/comitecoalisao", force
//append using "$tmp/partidopresidentegovernador", force
//append using "$tmp/partidocoalisao", force
append using "$tmp/receitacandidato1", force
append using "$tmp/receitacandidato2", force
append using "$tmp/receitacandidato3", force

//clean data
gen cod_tse = sigla_ue 
tostring cod_tse, replace

replace valorreceita =subinstr(valorreceita,`","',".", .)	
destring valorreceita, replace

//collapse data 
collapse (sum) valorreceita (firstnm) revenue_source descricao_cargo eleito, by(nome_candidato numero_candidato cod_tse codigo_cargo cpfcnpjdodoador)

// drop if 
drop if cpfcnpjdodoador =="" /*
	*/ 	| cpfcnpjdodoador ==" FERREIRA"  	/*
	*/ 	| cpfcnpjdodoador ==". LOUREIRO"  

// generate final variables
gen ano_eleicao = "2012"
label variable ano_eleicao "Election year"

//label variables
label variable valorreceita "Value of campaign donation"
label variable eleito "Candidate was elected?"
label variable nome_candidato "Name of candidate"
label variable numero_candidato "Number of candidate"
label variable cod_tse "City code"
label variable codigo_cargo "Code of position"
label variable descricao_cargo "Description of position"
label variable cpfcnpjdodoador "CPF or CNPJ"
label variable revenue_source "The direct beneficiary of the donation"

//Save and clear
save "$tmp/_tse_doacoes_2012", replace
clear

//delete temp files data
erase	"$tmp/candidatos.dta"
erase	"$tmp/comiteprefeito.dta"
erase	"$tmp/comitecoalisao.dta"
erase	"$tmp/partidoprefeito.dta"
erase	"$tmp/partidocoalisao.dta"
erase	"$tmp/receitacandidato1.dta"
erase	"$tmp/receitacandidato2.dta"
erase	"$tmp/receitacandidato3.dta"

* delete temporary files
cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.txt"
foreach datafile of local datafiles {
    rm `datafile'
}

* delete temporary files
cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.pdf"
foreach datafile of local datafiles {
    rm `datafile'
}
