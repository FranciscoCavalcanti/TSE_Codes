clear
set more off

** 2004 mayoral election

//CANDIDATES

// should be done manually

//	1)	unzip file
* unzipfile	"${InpDir}/2004/consulta_cand_2004.zip"

//	2)	should convert .mdb to .xls

//	3)	should convert .xls to .dta
//import data raw data and save as .dta by state
import excel "$InpDir/2004/Candidatos_2004.xls", /*
	*/	sheet("Candidatos_2004") firstrow case(lower)  /*
	*/ 	allstring /*
	*/ 	clear

//rename and edit variables
rename sgl_uf sigla_uf
rename cod_mun sigla_ue
rename municipio descricao_ue
rename cod_cargo codigo_cargo
rename cargo descricao_cargo
rename nome nome_candidato
rename id_candidato sequencial_candidato
rename numero numero_candidato
rename cpf cpf_candidato
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
drop if descricao_cargo == "Vice-Prefeito" //

//selection of specific candidates		

//encode candidates by state, number, and political office
drop if missing(numero_candidato)
egen cand=group(sigla_ue descricao_cargo numero_candidato)
egen qtspcand=count(cand), by (cand)


//some candidates appear more than once because of the second round
gen iten1= 1 if situacao1t =="Eleito" 
gen iten2= 1 if situacao1t =="Eleito por Média" 
gen iten3= 1 if situacao2t =="Eleito" 

gen eleito=0
replace eleito=1 if iten1==1 // ELEITO
replace eleito=1 if iten2==1 // ELEITO
replace eleito=1 if iten3==1 // ELEITO
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

// save temporary dataset
save "$tmp/candidatos.dta", replace


//POLITICAL DONATIONS

// not working, should be done manually
* unzip file
* unzipfile	"${InpDir}/2004/prestacao_contas_2004.zip"

//Atribuir receitas de comites
clear

import delimited "$InpDir/2004/prestacao_contas_2004/2004/Comitê/Receita/ReceitaComitê.CSV", /*
	*/	delimiter(`"";""', asstring) varnames(1) bindquote(nobind) asdouble clear

gen tiporeceita = tp_recurso 
gen cpfcnpjdodoador = cd_cpf_cgc_doa
gen nomedodoador = no_doador
gen datadareceita = dt_receita
gen valorreceita = vr_receita

	
drop	if	cpfcnpjdodoador	=="" /*
	*/ |	cpfcnpjdodoador	=="---" /*
	*/ |	cpfcnpjdodoador	=="00000000000000" /*
	*/ |	cpfcnpjdodoador	=="0" /*	
	*/ |	cpfcnpjdodoador	=="00000000000"

// Criar variaveis para futuro merge
gen descricao_cargo="Prefeito" if ds_orgao=="Comitê Financeiro Municipal para Prefeito"
gen codigo_cargo = "11" if ds_orgao=="Comitê Financeiro Municipal para Prefeito"

gen sigla_partido = sg_part
gen sigla_ue = sg_ue  
tostring sigla_ue, replace

//
merge	n:n sigla_ue sigla_partido descricao_cargo codigo_cargo  using "$tmp/candidatos"
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
//Atribuir receitas de candidatos

import delimited "$InpDir/2004/prestacao_contas_2004/2004/Candidato/Receita/ReceitaCandidato.csv", /*
	*/	delimiter(`"";""', asstring) bindquote(nobind) varnames(1) asdouble  clear
	
//
gen cargo = ds_cargo
gen tiporeceita = rtrimltrimdrds_titulo
gen cpfcnpjdodoador = cd_cpf_cgc  
gen situacao_cadastral = rv_meaning
gen sigla_ue = sg_ue
gen valorreceita = vr_receita
	
//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"RECURSOS DE PARTIDO POLÍTICO"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"Rendimentos de Aplicações Financeiras"	/*
	*/	|	tiporeceita	==	"RECURSOS DO FUNDO PARTIDÁRIO"	/*
	*/	|	tiporeceita	==	"RECURSOS DE OUTROS CANDIDATOS/COMITÊS"	/*
	*/	|	tiporeceita	==	"Recursos de Origens não Identificada"	/*	
	*/	|	tiporeceita	==	"Recursos Proprios"
	
/* // sera deve-se dropar situacao cadastral cancelado?
drop if		situacao_cadastral == "Cancelado" /*
	*/	|	situacao_cadastral == "Não batido na RFB"
*/

/*
drop	if	cpfcnpjdodoador	=="" /*
	*/ |	cpfcnpjdodoador	=="." 
*/
	
// Criar variaveis para futuro merge
gen sigla_partido = sg_part 
//gen sequencial_candidato = sequencialcandidato
gen nome_candidato = no_cand 
//gen cpf_candidato = cpfdocandidato
gen numero_candidato = nr_cand 
tostring numero_candidato, replace
tostring sigla_ue, replace
gen revenue_source ="candidate"

* take out accents and double space

gen normalized_string = ustrto(ustrnormalize(nome_candidato, "nfd"), "ascii", 2)
replace nome_candidato = normalized_string
drop normalized_string

// 
* matching candidates with observable characteristics
merge	n:1 nome_candidato sigla_ue sigla_partido numero_candidato using "$tmp/candidatos"

preserve
keep if _merge ==3
drop _merge
save "$tmp/receitacandidato1", replace
restore

keep if _merge==1
drop _merge
merge	n:1 nome_candidato sigla_partido sigla_ue using "$tmp/candidatos"

preserve
keep if _merge ==3
drop _merge
save "$tmp/receitacandidato2", replace
restore

keep if _merge==1
drop _merge
merge	n:1 sigla_ue numero_candidato codigo_cargo using "$tmp/candidatos", update

preserve
keep if _merge ==3 | _merge ==4 | _merge ==5
drop _merge
save "$tmp/receitacandidato3", replace
restore

keep if _merge==1
drop _merge
save "$tmp/receitacandidato4", replace
clear

//	merge bases
use "$tmp/comiteprefeito", clear
append using "$tmp/comitecoalisao", force
//append using "$tmp/partidopresidentegovernador", force
//append using "$tmp/partidocoalisao", force
append using "$tmp/receitacandidato1", force
append using "$tmp/receitacandidato2", force
append using "$tmp/receitacandidato3", force
append using "$tmp/receitacandidato4", force


//clean data
gen cod_tse = sg_ue 
tostring cod_tse, replace

replace valorreceita =subinstr(valorreceita,`","',".", .)	
destring valorreceita, replace

//collapse data 
collapse (sum) valorreceita (firstnm) revenue_source descricao_cargo eleito, by(nome_candidato numero_candidato cod_tse codigo_cargo cpfcnpjdodoador)

// drop if 
drop if cpfcnpjdodoador =="" 


// generate final variables
gen ano_eleicao = "2004"
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
save "$tmp/_tse_doacoes_2004", replace
clear

//delete temp files data
erase	"$InpDir/2004/Candidatos_2004.mdb"
erase	"$InpDir/2004/Candidatos_2004.xls"
erase	"$tmp/candidatos.dta"
erase	"$tmp/comiteprefeito.dta"
erase	"$tmp/comitecoalisao.dta"
erase	"$tmp/receitacandidato1.dta"
erase	"$tmp/receitacandidato2.dta"
erase	"$tmp/receitacandidato3.dta"
erase	"$tmp/receitacandidato4.dta"

//delete folder
shell rd "$InpDir/2004/prestacao_contas_2004" /s /q
