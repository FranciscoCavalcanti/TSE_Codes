* ------------------------------------------------------------------------
* STATA VERSION 14
* ------------------------------------------------------------------------

* rename variables

rename v1	DATA_GERACAO
rename v2	HORA_GERACAO
rename v3	ANO_ELEICAO
rename v4	NUM_TURNO
rename v5	DESCRICAO_ELEICAO
rename v6	SIGLA_UF
rename v7	SIGLA_UE
rename v8	CODIGO_MUNICIPIO
rename v9	NOME_MUNICIPIO
rename v10	NUMERO_ZONA
rename v11	CODIGO_CARGO
rename v12	DESCRICAO_CARGO 
rename v13	TIPO_LEGENDA 
rename v14	NOME_COLIGACAO 
rename v15	COMPOSICAO_LEGENDA
rename v16	SIGLA_PARTIDO
rename v17	NUMERO_PARTIDO
rename v18	NOME_PARTIDO
rename v19	TOTAL_VOTOS

* variables regarding total vote

destring NUM_TURNO, replace
destring TOTAL_VOTOS, replace
destring NUMERO_PARTIDO, replace

* generating a variable the depicts the vote share of party of the incumbent president
	* first round
by CODIGO_MUNICIPIO, sort: egen leao01 =  total(TOTAL_VOTOS) if NUM_TURNO ==1 // total vote for president
by CODIGO_MUNICIPIO, sort: egen total_vote_by_city_1round =  mean(leao01) 
by CODIGO_MUNICIPIO, sort: egen iten01 =  total(TOTAL_VOTOS) if NUMERO_PARTIDO==45 & NUM_TURNO ==1 // total vote for incument party 
by CODIGO_MUNICIPIO, sort: egen total_vote_pres_by_city_1round =  mean(iten01)
by CODIGO_MUNICIPIO, sort: gen vote_share_pres_1round =  total_vote_pres_by_city_1round/total_vote_by_city_1round // the vote share
drop leao* iten*

	* second round
by CODIGO_MUNICIPIO, sort: egen leao02 =  total(TOTAL_VOTOS) if NUM_TURNO ==2 & DESCRICAO_CARGO =="PRESIDENTE" // total vote for president
by CODIGO_MUNICIPIO, sort: egen total_vote_by_city_2round =  mean(leao02) 
by CODIGO_MUNICIPIO, sort: egen iten02 =  total(TOTAL_VOTOS) if NUMERO_PARTIDO==13 & NUM_TURNO ==2 & DESCRICAO_CARGO =="PRESIDENTE" // total vote for incument party 
by CODIGO_MUNICIPIO, sort: egen total_vote_pres_by_city_2round =  mean(iten02)
by CODIGO_MUNICIPIO, sort: gen vote_share_pres_2round =  total_vote_pres_by_city_2round/total_vote_by_city_2round // the vote share
drop leao* iten*

* 

collapse (mean) vote_share_pres_1round vote_share_pres_2round, by(CODIGO_MUNICIPIO)

* rename variables

gen cod_tse = CODIGO_MUNICIPIO

* label variables

label variable vote_share_pres_1round "The vote share of party of the incumbent president"
label variable vote_share_pres_2round "The vote share of party of the incumbent president"

* preparing variables

gen year_of_election = 2002

* keep variables

keep cod_tse year_of_election vote_share_pres_1round vote_share_pres_2round

