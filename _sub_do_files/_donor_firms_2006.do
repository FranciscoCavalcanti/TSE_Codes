
** 2006 election

* unzip file
cd "$tmp"
pwd
unzipfile	"${InpDir}/2006/consulta_cand_2006.zip", replace

//CANDIDATES
//import data raw data and save as .dta by state

foreach uf in DF BR AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$tmp/consulta_cand_2006_`uf'.txt", /*
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
erase	"$tmp/`uf'.dta"
erase	"$tmp/consulta_cand_2006_`uf'.txt"
}

erase	"$tmp/LEIAME.pdf"

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

drop if situacao==6 // 6 REGISTRO NEGADO ANTES DA ELEIÇÃO
drop if situacao==9 // 9 RENÚNCIA/FALECIMENTO/CASSAÇÃO ANTES DA ELEIÇÃO

encode ds_sit_cand, gen(situacao2)
label list situacao2

drop if situacao2==1 // 1 CANCELADO
drop if situacao2==5 // 5 FALECIDO
drop if situacao2==6 // 6 INDEFERIDO
drop if situacao2==7 // 7 INDEFERIDO COM RECURSO
drop if situacao2==8 // 8 NÃO CONHECIMENTO DO PEDIDO
drop if situacao2==9 // 9 RENÚNCIA

//selection of specific candidates

keep if 	codigo_cargo == "6" /*  DEPUTADO FEDERAL
	*/	|	codigo_cargo == "1" /*	PRESIDENTE
	*/	|	codigo_cargo == "5" /*	SENADOR
	*/	|	codigo_cargo == "7" /*	DEPUTADO ESTADUAL
	*/	|	codigo_cargo == "3" /*	GOVERNADOR	
	*/	|	codigo_cargo == "8" //	DEPUTADO DISTRITAL			

//encode candidates by state, number, and political office
drop if missing(numero_candidato)
egen cand=group(cpf_candidato sigla_ue descricao_cargo numero_candidato)
egen qtspcand=count(cand), by (cand)
egen qtspcand2=max(qtspcand), by (cand)
destring num_turno, replace

//some candidates appear more than once because of the second round
egen turno2=max(num_turno), by (cand)
gen eleito=0
label list situacao
replace eleito=1 if situacao==3 //3 ELEITO
replace eleito=1 if situacao==4 //4 MÉDIA
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

// check for unique identifiers 
isid cpf_candidato
isid nome_candidato sequencial_candidato sigla_partido numero_candidato
isid nome_candidato sigla_partido numero_candidato
isid numero_candidato uf sigla_partido
isid nome_candidato sigla_partido uf

// save temporary dataset
save "$tmp/candidatos.dta", replace


//POLITICAL DONATIONS

// not working, should be done manually
* unzip file
* unzipfile	"${InpDir}/2006/prestacao_contas_2006.zip"

//Atribuir receitas de comite para presidente

clear
import delimited "$InpDir/2006/prestacao_contas_2006/prestacao_contas_2006/2006/Comitê/Receita/ReceitaComitê.CSV", /*
	*/ 	delimiter(`"";""') 	/*
	*/ 	varnames(1) /*
	*/	stringcols(_all) /*
	*/ 	bindquote(nobind) 	/*
	*/	encoding(ISO-8859-1) 	/*
	*/ 	clear
	
drop v9 v8 v6 v5 v45 v44 v42 v41 v39 v38 v36 v35 v33 v32 v30 v3 v29 v27 v26 v24 v23 v21 v20 v2 v18 v17 v15 v14 v12 v11

gen tiporeceita = rtrimltrimdrds_titulo 
gen cpfcnpjdodoador = cd_cpf_cgc_doa
gen nomedodoador = no_doador
gen datadareceita = dt_receita
gen valorreceita = vr_receita

/*
keep if 	ds_orgao=="Comitê Financeiro Nacional para Presidente da República" /*
	*/	|	ds_orgao=="Comitê Financeiro Único" 
*/

//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"RECURSOS DE PARTIDO POLÍTICO"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"Recursos de origens não identificadas"	/*	
	*/	|	tiporeceita	==	"RECURSOS DE OUTROS CANDIDATOS/COMITÊS"	//
	
drop	if	cpfcnpjdodoador	=="" /*
	*/ |	cpfcnpjdodoador	=="---" /*
	*/ |	cpfcnpjdodoador	=="00000000000000" /*
	*/ |	cpfcnpjdodoador	=="00000000000"

// Criar variaveis para futuro merge
gen descricao_cargo="PRESIDENTE" if ds_orgao=="Direção Nacional"
gen codigo_cargo = "1" if ds_orgao=="Direção Nacional"

replace descricao_cargo="PRESIDENTE" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Deputado Federal"
replace codigo_cargo = "1" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Deputado Federal"

replace descricao_cargo="PRESIDENTE" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Senador da República"
replace codigo_cargo = "1" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Senador da República"

replace descricao_cargo="PRESIDENTE" if ds_orgao=="Comitê Financeiro Nacional para Presidente da República"
replace codigo_cargo = "1" if ds_orgao=="Comitê Financeiro Nacional para Presidente da República"

replace descricao_cargo="PRESIDENTE" if ds_orgao=="Comitê Financeiro Único"
replace codigo_cargo = "1" if ds_orgao=="Comitê Financeiro Único"

replace descricao_cargo="GOVERNADOR" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Governador"
replace codigo_cargo = "3" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Governador"


replace descricao_cargo="GOVERNADOR" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Deputado Estadual"
replace codigo_cargo = "3" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Deputado Estadual"

replace descricao_cargo="GOVERNADOR" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Deputado Estadual"
replace codigo_cargo = "3" if ds_orgao=="Comitê Financeiro Distrital/Estadual para Deputado Estadual"

gen sigla_partido = sg_part

//
merge	n:n descricao_cargo codigo_cargo sigla_partido using "$tmp/candidatos"
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
//Atribuir receitas de candidatos

clear
import delimited "$InpDir/2006/prestacao_contas_2006/prestacao_contas_2006/2006/Candidato/Receita/ReceitaCandidato.csv", delimiter(";") /*
	*/	stringcols(_all) /*
	*/	encoding(ISO-8859-1) clear

//edited variables
replace valor_receita=subinstr(valor_receita,",","|", .)
replace valor_receita=subinstr(valor_receita,".","/", .)
replace valor_receita=subinstr(valor_receita,"|",".", .)
replace valor_receita=subinstr(valor_receita,"/",",", .)

gen tiporeceita = tipo_receita
gen cpfcnpjdodoador = numero_cpf_cgc_doador

//
gen cargo = descricao_cargo
/*
keep if		cargo=="Deputado Federal" /*
	*/	|	cargo=="Senador" /*
	*/	|	cargo=="Presidente" //
*/	
	
//	Limpar doações nao idenfiticadas / irrelevantes

drop	if	tiporeceita	==	"RECURSOS DE PARTIDO POLÍTICO"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"RECURSOS PRÓPRIOS"	/*	
	*/	|	tiporeceita	==	"RECURSOS DE OUTROS CANDIDATOS/COMITÊS"	//

drop	if	cpfcnpjdodoador	=="" /*
	*/ |	cpfcnpjdodoador	=="---" /*
	*/ |	cpfcnpjdodoador	=="00000000000000" /*
	*/ |	cpfcnpjdodoador	=="00000000000"	

//Edit variables

* take out accents and double space

gen normalized_string = ustrto(ustrnormalize(nome_candidato, "nfd"), "ascii", 2)
replace nome_candidato = normalized_string
drop normalized_string

gen nomedodoador = nome_doador
gen datadareceita = data_receita
gen valorreceita = valor_receita
gen revenue_source ="candidate"

// Criar variaveis para futuro merge
gen uf = unidade_eleitoral_candidato
//gen sigla_partido = siglapartido
//gen sequencial_candidato = sequencialcandidato
//gen nome_candidato = nomecandidato
//gen cpf_candidato = numero_cnpj_candidato
// 

* matching candidates with observable characteristics
merge	n:1 uf nome_candidato sequencial_candidato sigla_partido using "$tmp/candidatos", update

preserve
keep if _merge ==3 | _merge ==4 | _merge ==5
drop _merge
save "$tmp/receitacandidato1", replace
restore

keep if _merge ==1
drop _merge
merge	n:n numero_candidato uf sigla_partido using "$tmp/candidatos", update

preserve
keep if _merge ==3 | _merge ==4 | _merge ==5
drop _merge
save "$tmp/receitacandidato2", replace
restore

keep if _merge==1
drop _merge
merge	n:1 nome_candidato sigla_partido uf using "$tmp/candidatos", update
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
use "$tmp/comitepresidentegovernador", clear
append using "$tmp/comitecoalisao", force
//append using "$tmp/partidopresidentegovernador", force
//append using "$tmp/partidocoalisao", force
append using "$tmp/receitacandidato1", force
append using "$tmp/receitacandidato2", force
append using "$tmp/receitacandidato3", force
append using "$tmp/receitacandidato4", force

//clean data
tostring uf, replace

replace valorreceita =subinstr(valorreceita,`","',".", .)	
destring valorreceita, replace

//collapse data 
collapse (sum) valorreceita (firstnm) revenue_source descricao_cargo eleito, by(nome_candidato numero_candidato uf codigo_cargo cpfcnpjdodoador)

// drop if 
drop if cpfcnpjdodoador ==""

// generate final variables
gen ano_eleicao = "2006"
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
save "$tmp/_tse_doacoes_2006", replace
clear

//delete temp files data
erase	"$tmp/candidatos.dta"
erase	"$tmp/comitepresidentegovernador.dta"
erase	"$tmp/comitecoalisao.dta"
erase	"$tmp/receitacandidato1.dta"
erase	"$tmp/receitacandidato2.dta"
erase	"$tmp/receitacandidato3.dta"
erase	"$tmp/receitacandidato4.dta"

//delete folder
shell rd "$InpDir/2006/prestacao_contas_2006" /s /q

