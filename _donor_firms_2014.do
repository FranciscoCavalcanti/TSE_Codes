set more off

** 2014 election

* unzip file
cd "$tmp"
pwd
unzipfile	"${InpDir}/2014/consulta_cand_2014.zip", replace

//CANDIDATES
//import data raw data and save as .dta by state

foreach uf in DF BR AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2014_`uf'.csv", /*
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
erase	"$tmp/`uf'.dta"
}

* delete temporary files
cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.csv"
foreach datafile of local datafiles {
    rm `datafile'
}

//rename and edit variables

keep if ds_eleicao=="Eleições Gerais 2014" 

//drop if candidates:

encode ds_sit_tot_turno, gen(situacao)
label list situacao

encode ds_detalhe_situacao_cand, gen(situacao2)
label list situacao2

//selection of specific candidates

keep if 	cd_cargo == "6" /*  DEPUTADO FEDERAL
	*/	|	cd_cargo == "1" /*	PRESIDENTE
	*/	|	cd_cargo == "5" /*	SENADOR
	*/	|	cd_cargo == "7" /*	DEPUTADO ESTADUAL
	*/	|	cd_cargo == "3" /*	GOVERNADOR	
	*/	|	cd_cargo == "8" //	DEPUTADO DISTRITAL			

//encode candidates by state, number, and political office
drop if missing(nr_candidato)
egen cand=group(uf ds_cargo nr_candidato nr_cpf_candidato)
egen qtspcand=count(cand), by (cand)
destring nr_turno, replace

//some candidates appear more than once because of the second round
egen turno2=max(nr_turno), by (cand)
gen eleito=0
label list situacao
replace eleito=1 if situacao==3 //3 ELEITO
replace eleito=1 if situacao==4 //4 ELEITO POR MÉDIA
replace eleito=1 if situacao==5 //5 ELEITO POR QP
egen eleito2=max(eleito), by (cand)
drop eleito
rename eleito2 eleito
duplicates drop cand, force
duplicates drop nr_cpf_candidato, force

//Edit variables

* take out accents and double space

gen normalized_string = ustrto(ustrnormalize(nm_candidato, "nfd"), "ascii", 2)
replace nm_candidato = normalized_string
drop normalized_string


// check for unique identifiers 
isid nr_cpf_candidato
isid nm_candidato sq_candidato sg_partido nr_candidato
isid nm_candidato sg_partido nr_candidato
isid nr_candidato sg_ue sg_partido nr_cpf_candidato

// keep only relevant variables
keep nm_candidato sg_ue sg_partido nr_candidato cd_cargo ds_cargo eleito sq_candidato nr_titulo_eleitoral_candidato nr_cpf_candidato

// set format
recast str nm_candidato 
recast str sg_ue 
recast str sg_partido 
recast str nr_candidato 
recast str cd_cargo 
recast str sq_candidato 
recast str nr_titulo_eleitoral_candidato 
recast str nr_cpf_candidato 

// save temporary dataset
save "$tmp/candidatos.dta", replace
clear

//POLITICAL DONATIONS

* 1) unzip file
cd "$tmp"
pwd
unzipfile	"${InpDir}/2014/prestacao_final_2014.zip", replace


//Atribuir receitas de comite para presidente
clear
import delimited "$tmp/receitas_comites_2014_brasil.txt", /*
	*/	case(lower)   stringcols(_all) clear

//keep if tipocomite=="Comitê Financeiro Nacional para Presidente da República" 

//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"Recursos de partido político"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"Recursos de origens não identificadas"	/*	
	*/	|	tiporeceita	==	"Recursos de outros candidatos/comitês"	//
	
drop	if	cpfcnpjdodoador	==""
drop	if	cpfcnpjdodoador	=="#NULO"

// Criar variaveis para futuro merge
gen ds_cargo="PRESIDENTE" if tipocomite=="Comitê Financeiro Nacional para Presidente da República"
gen cd_cargo = "1" if tipocomite=="Comitê Financeiro Nacional para Presidente da República"

replace ds_cargo="PRESIDENTE" if tipocomite=="Comitê Financeiro Único"
replace cd_cargo = "1" if tipocomite=="Comitê Financeiro Único"

replace ds_cargo="GOVERNADOR" if tipocomite=="Comitê Financeiro Distrital/Estadual para Deputado Distrital"
replace cd_cargo = "3" if tipocomite=="Comitê Financeiro Distrital/Estadual para Deputado Distrital"

replace ds_cargo="GOVERNADOR" if tipocomite=="Comitê Financeiro Distrital/Estadual para Deputado Estadual"
replace cd_cargo = "3" if tipocomite=="Comitê Financeiro Distrital/Estadual para Deputado Estadual"

replace ds_cargo="GOVERNADOR" if tipocomite=="Comitê Financeiro Distrital/Estadual para Governador"
replace cd_cargo = "3" if tipocomite=="Comitê Financeiro Distrital/Estadual para Governador"

gen sg_partido = siglapartido

//
merge	n:n ds_cargo cd_cargo sg_partido using "$tmp/candidatos"
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

clear
import delimited "$tmp/receitas_partidos_2014_brasil.txt", /*
	*/	case(lower)   stringcols(_all) clear

//keep if tipodiretorio=="Direção Nacional"

//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"Recursos de partido político"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"Recursos de partido político"	/*	
	*/	|	tiporeceita	==	"Recursos de outros candidatos/comitês"	//
	
drop	if	cpfcnpjdodoador	==""
drop	if	cpfcnpjdodoador	=="#NULO"

// Criar variaveis para futuro merge
gen ds_cargo="PRESIDENTE" if tipodiretorio=="Direção Nacional"
gen cd_cargo = "1" if tipodiretorio=="Direção Nacional"

replace ds_cargo="GOVERNADOR" if tipodiretorio=="Direção Estadual/Distrital"
replace cd_cargo = "3" if tipodiretorio=="Direção Estadual/Distrital"

replace ds_cargo="GOVERNADOR" if tipodiretorio=="Direção Municipal"
replace cd_cargo = "3" if tipodiretorio=="Direção Municipal"

gen sg_partido = siglapartido
gen revenue_source ="party"

//
merge	n:n ds_cargo cd_cargo sg_partido using "$tmp/candidatos"
// salvar para doacoes para partido de governadores e presidente
preserve
keep if _merge ==3
drop _merge
save "$tmp/partidopresidentegovernador", replace
// salvar para doacoes para partidos da colisao dos governadores e presidente
restore
keep if _merge ==1
drop _merge
save "$tmp/partidocoalisao", replace
//

clear

//POLITICAL DONATIONS
//Atribuir receitas de candidatos
clear
import delimited "$tmp/receitas_candidatos_2014_brasil.txt", /*
	*/	case(lower)   stringcols(_all) clear

//
/*
keep if		cargo=="Deputado Federal" /*
	*/	|	cargo=="Senador" /*
	*/	|	cargo=="Presidente" //
*/	
	
//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"Recursos de partido político"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"Recursos de partido político"	/*	
	*/	|	tiporeceita	==	"Recursos de outros candidatos/comitês"	//
	
drop	if	cpfcnpjdodoador	==""
drop	if	cpfcnpjdodoador	=="#NULO"

// Criar variaveis para futuro merge
gen sg_partido = siglapartido
gen sq_candidato = sequencialcandidato
gen nm_candidato = nomecandidato
gen nr_cpf_candidato = cpfdocandidato
gen revenue_source ="candidate"

//Edit variables

* take out accents and double space

gen normalized_string = ustrto(ustrnormalize(nm_candidato, "nfd"), "ascii", 2)
replace nm_candidato = normalized_string
drop normalized_string

// 
* matching candidates with observable characteristics
merge	n:1 nr_cpf_candidato nm_candidato sq_candidato sg_partido using "$tmp/candidatos", update

preserve
keep if _merge ==3 | _merge ==4 | _merge ==5
drop _merge
save "$tmp/receitacandidato1", replace
restore

keep if _merge==1
drop _merge
merge	n:1 nr_cpf_candidato nm_candidato sg_partido using "$tmp/candidatos", update

preserve
keep if _merge ==3 | _merge ==4 | _merge ==5
drop _merge
save "$tmp/receitacandidato2", replace
restore

keep if _merge==1
drop _merge
save "$tmp/receitacandidato3", replace
clear

//	merge bases
use "$tmp/comitepresidentegovernador", clear
append using "$tmp/comitecoalisao", force
append using "$tmp/partidopresidentegovernador", force
append using "$tmp/partidocoalisao", force
append using "$tmp/receitacandidato1", force
append using "$tmp/receitacandidato2", force
append using "$tmp/receitacandidato3", force

// gen variables

gen nome_candidato		 =	nm_candidato  
gen numero_candidato 	 =	nr_candidato    
gen codigo_cargo		 =	cd_cargo
gen descricao_cargo		 =	ds_cargo 

//clean data
tostring uf, replace

replace valorreceita =subinstr(valorreceita,`","',".", .)	
destring valorreceita, replace

//collapse data 
collapse (sum) valorreceita (firstnm) revenue_source descricao_cargo eleito, by(nome_candidato numero_candidato uf codigo_cargo cpfcnpjdodoador)

// drop if 
drop if cpfcnpjdodoador ==""

// generate final variables
gen ano_eleicao = "2014"
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
save "$tmp/_tse_doacoes_2014", replace
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

* delete temporary files
cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.pdf"
foreach datafile of local datafiles {
    rm `datafile'
}

* delete temporary files
cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.txt"
foreach datafile of local datafiles {
    rm `datafile'
}

