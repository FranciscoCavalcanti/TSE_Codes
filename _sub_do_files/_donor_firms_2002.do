set more off

** 2002 mayoral election

// not working, should be done manually
* unzip file
/*
cd "$tmp"
pwd
 unzipfile	"${InpDir}/2002/consulta_cand_2002.zip"
*/

//CANDIDATES
//import data raw data and save as .dta by state

foreach uf in DF BR AC AL AM AP BA CE ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO {
import delimited "$InpDir/2002/consulta_cand_2002/consulta_cand_2002_`uf'.txt", /*
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

drop if situacao==6 // 6 REGISTRO NEGADO ANTES DA ELEIÇÃO
drop if situacao==9 // 9 RENÚNCIA/FALECIMENTO/CASSAÇÃO ANTES DA ELEIÇÃO

encode ds_sit_cand, gen(situacao2)
label list situacao2

drop if situacao2==1 // 1 CANCELADO
drop if situacao2==3 // 3 FALECIMENTO
drop if situacao2==4 // 4 INDEFERIDO
drop if situacao2==5 // 5 INELEGÍVEL
drop if situacao2==6 // 6 NÃO CONHECIMENTO DO PEDIDO
drop if situacao2==7 // 7 RENÚNCIA

//selection of specific candidates

keep if 	codigo_cargo == "6" /*  DEPUTADO FEDERAL
	*/	|	codigo_cargo == "1" /*	PRESIDENTE
	*/	|	codigo_cargo == "5" /*	SENADOR
	*/	|	codigo_cargo == "7" /*	DEPUTADO ESTADUAL
	*/	|	codigo_cargo == "3" /*	GOVERNADOR	
	*/	|	codigo_cargo == "8" //	DEPUTADO DISTRITAL			

//encode candidates by state, number, and political office
drop if missing(numero_candidato)
egen cand=group(uf descricao_cargo numero_candidato)
egen qtspcand=count(cand), by (cand)
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

//Edit variables

* take out accents and double space

gen normalized_string = ustrto(ustrnormalize(nome_candidato, "nfd"), "ascii", 2)
replace nome_candidato = normalized_string
drop normalized_string


// check for unique identifiers 
isid nome_candidato sequencial_candidato sigla_partido numero_candidato, missok
isid nome_candidato sigla_partido numero_candidato, missok
isid numero_candidato uf sigla_partido, missok

// save temporary dataset
save "$tmp/candidatos.dta", replace


//POLITICAL DONATIONS

// not working, should be done manually
* unzip file
* unzipfile	"${InpDir}/2002/prestacao_contas_2002.zip"

//Atribuir receitas de comites
clear

import delimited "$InpDir/2002/prestacao_contas_2002/prestacao_contas_2002/2002/Comitê/Receita/ReceitaComite.CSV", /*
	*/	delimiter(`"""') varnames(1) stripquote(yes) clear
	
replace sg_uf=subinstr(sg_uf,";","", .)	
replace sg_part=subinstr(sg_part,";","", .)	
replace ds_orgao=subinstr(ds_orgao,";","", .)	
replace dt_receita=subinstr(dt_receita,";","", .)	
replace cd_cpf_cgc_doa=subinstr(cd_cpf_cgc_doa,";","", .)	
replace sg_uf_doador=subinstr(sg_uf_doador,";","", .)	
replace no_doador=subinstr(no_doador,";","", .)	
replace vr_receita=subinstr(vr_receita,";","", .)	
replace tp_recurso=subinstr(tp_recurso,";","", .)	

gen tiporeceita = tp_recurso 
gen cpfcnpjdodoador = cd_cpf_cgc_doa
gen nomedodoador = no_doador
gen datadareceita = dt_receita
gen valorreceita = vr_receita

/*
keep if 	ds_orgao=="Comitê Financeiro Nacional para Presidente da República" /*
	*/	|	ds_orgao=="Comitê Financeiro Único" 
*/

//	Limpar doações nao idenfiticadas / irrelevantes

/*
drop	if	tiporeceita	==	"RECURSOS DE PARTIDO POLÍTICO"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"RECURSOS DE OUTROS CANDIDATOS/COMITÊS"	//
*/
	
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

clear

//POLITICAL DONATIONS
//Atribuir receitas de candidatos

import delimited "$InpDir/2002/prestacao_contas_2002/prestacao_contas_2002/2002/Candidato/Receita/ReceitaCandidato.csv", /*
	*/	delimiter(`"";"', asstring) varnames(1) stripquote(yes) clear
	
replace sg_uf=subinstr(sg_uf,";","", .)	
replace sg_part=subinstr(sg_part,";","", .)	
//replace ds_orgao=subinstr(ds_orgao,";","", .)	
replace dt_receita=subinstr(dt_receita,";","", .)	
replace cd_cpf_cgc =subinstr(cd_cpf_cgc ,";","", .)	
replace sg_uf_doador=subinstr(sg_uf_doador,";","", .)	
replace no_doador=subinstr(no_doador,";","", .)	
replace vr_receita=subinstr(vr_receita,";","", .)	
replace tp_recurso=subinstr(tp_recurso,";","", .)		
replace tp_recurso=subinstr(tp_recurso,";","", .)		


//
gen cargo = ds_cargo
gen tiporeceita = tp_recurso
gen cpfcnpjdodoador = cd_cpf_cgc  
gen valorreceita = vr_receita

/*
keep if		cargo=="Deputado Federal" /*
	*/	|	cargo=="Senador" /*
	*/	|	cargo=="Presidente" //
*/	
	
	
//	Limpar doações nao idenfiticadas / irrelevantes

/*
drop	if	tiporeceita	==	"RECURSOS DE PARTIDO POLÍTICO"	/*
	*/	|	tiporeceita	==	"Rendimentos de aplicações financeiras"	/*
	*/	|	tiporeceita	==	"RECURSOS DE OUTROS CANDIDATOS/COMITÊS"	//
*/

/*
drop if		situacao_cadastral == "Cancelado" /*
	*/	|	situacao_cadastral == "Não batido na RFB"
*/

drop	if	cpfcnpjdodoador	=="" /*
	*/ |	cpfcnpjdodoador	=="---" /*
	*/ |	cpfcnpjdodoador	=="00000000000000" /*
	*/ |	cpfcnpjdodoador	=="0" /*	
	*/ |	cpfcnpjdodoador	=="  0" /*		
	*/ |	cpfcnpjdodoador	==" 0" /*		
	*/ |	cpfcnpjdodoador	=="0000000000000" /*			
	*/ |	cpfcnpjdodoador	==" 0000000000000" /*			
	*/ |	cpfcnpjdodoador	=="00000000000"	/*
	*/ |	cpfcnpjdodoador	=="AC" /*
	*/ |	cpfcnpjdodoador	=="AM" /*
	*/ |	cpfcnpjdodoador	=="AP" /*
	*/ |	cpfcnpjdodoador	=="AL" /*	
	*/ |	cpfcnpjdodoador	=="BA" /*
	*/ |	cpfcnpjdodoador	=="BR" /*
	*/ |	cpfcnpjdodoador	=="CE" /*
	*/ |	cpfcnpjdodoador	=="Comercialização de Bens ou Realização de Eventos" /*
	*/ |	cpfcnpjdodoador	=="DF" /*
	*/ |	cpfcnpjdodoador	=="ES" /*
	*/ |	cpfcnpjdodoador	=="GO" /*
	*/ |	cpfcnpjdodoador	=="MA" /*
	*/ |	cpfcnpjdodoador	=="MG" /*
	*/ |	cpfcnpjdodoador	=="MS" /*
	*/ |	cpfcnpjdodoador	=="MT" /*
	*/ |	cpfcnpjdodoador	=="PA" /*
	*/ |	cpfcnpjdodoador	=="PB" /*
	*/ |	cpfcnpjdodoador	=="PE" /*
	*/ |	cpfcnpjdodoador	=="PI" /*
	*/ |	cpfcnpjdodoador	=="PR" /*
	*/ |	cpfcnpjdodoador	=="RJ" /*
	*/ |	cpfcnpjdodoador	=="RS" /*
	*/ |	cpfcnpjdodoador	=="RN" /*
	*/ |	cpfcnpjdodoador	=="RO" /*	
	*/ |	cpfcnpjdodoador	=="SC" /*	
	*/ |	cpfcnpjdodoador	=="SE" /*	
	*/ |	cpfcnpjdodoador	=="SP" /*		
	*/ |	cpfcnpjdodoador	=="TO" /*			
	*/ |	cpfcnpjdodoador	=="RR"		
	

// Criar variaveis para futuro merge
gen sigla_partido = sg_part 
//gen sequencial_candidato = sequencialcandidato
gen nome_candidato = no_cand 
//gen cpf_candidato = cpfdocandidato
gen numero_candidato = nr_cand 
gen revenue_source ="candidate"

tostring sequencial_candidato, replace
tostring numero_candidato, replace

* take out accents and double space

gen normalized_string = ustrto(ustrnormalize(nome_candidato, "nfd"), "ascii", 2)
replace nome_candidato = normalized_string
drop normalized_string

// 
* matching candidates with observable characteristics
merge	n:1 nome_candidato sequencial_candidato sigla_partido numero_candidato using "$tmp/candidatos"

preserve
keep if _merge ==3
drop _merge
save "$tmp/receitacandidato1", replace
restore

keep if _merge==1
drop _merge
merge	n:1 nome_candidato sigla_partido numero_candidato using "$tmp/candidatos"

preserve
keep if _merge ==3
drop _merge
save "$tmp/receitacandidato2", replace
restore

keep if _merge==1
drop _merge
merge	n:1 numero_candidato uf sigla_partido using "$tmp/candidatos", update

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
gen ano_eleicao = "2002"
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
save "$tmp/_tse_doacoes_2002", replace
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
shell rd "$InpDir/2002/prestacao_contas_2002" /s /q
shell rd "$InpDir/2002/consulta_cand_2002" /s /q

