* ------------------------------------------------------------------------
* STATA VERSION 14
* ------------------------------------------------------------------------

* rename variables

/*
rename v1	dt_geracao
rename v2	hh_geracao
rename v3	aa_eleicao
rename v4	CD_TIPO_ELEICAO
rename v5	NM_TIPO_ELEICAO
rename v6	nr_turno
rename v7	CD_ELEICAO
rename v8	DS_ELEICAO
rename v9	DT_ELEICAO
rename v10	TP_ABRANGENCIA
rename v11	SG_UF
rename v12	SG_UE
rename v13	NM_UE
rename v14	cd_municipio
rename v15	NM_MUNICIPIO
rename v16	NM_ZONA
rename v17	NM_SECAO
rename v18	CD_CARGO
rename v19	ds_cargo
rename v20	nr_votavel
rename v21	NM_VOTAVEL
rename v22	qt_votos
*/


* variables regarding total vote

destring nr_turno, replace
destring qt_votos, replace
destring nr_votavel, replace

* generating a variable the depicts the vote share of party of the incumbent president
	* first round
by cd_municipio, sort: egen leao01 =  total(qt_votos) if nr_turno ==1 & ds_cargo =="PRESIDENTE" // total vote for president
by cd_municipio, sort: egen total_vote_by_city_1round =  mean(leao01) 
by cd_municipio, sort: egen iten01 =  total(qt_votos) if nr_votavel==13 & nr_turno ==1 & ds_cargo =="PRESIDENTE" // total vote for incument party 
by cd_municipio, sort: egen total_vote_pres_by_city_1round =  mean(iten01)
by cd_municipio, sort: gen vote_share_pres_1round =  total_vote_pres_by_city_1round/total_vote_by_city_1round // the vote share
drop leao* iten*

	* second round
by cd_municipio, sort: egen leao02 =  total(qt_votos) if nr_turno ==2 & ds_cargo =="PRESIDENTE" // total vote for president
by cd_municipio, sort: egen total_vote_by_city_2round =  mean(leao02) 
by cd_municipio, sort: egen iten02 =  total(qt_votos) if nr_votavel==13 & nr_turno ==2 & ds_cargo =="PRESIDENTE" // total vote for incument party 
by cd_municipio, sort: egen total_vote_pres_by_city_2round =  mean(iten02)
by cd_municipio, sort: gen vote_share_pres_2round =  total_vote_pres_by_city_2round/total_vote_by_city_2round // the vote share
drop leao* iten*

* 

collapse (mean) vote_share_pres_1round vote_share_pres_2round, by(cd_municipio)

* rename variables

gen cod_tse = cd_municipio

* label variables

label variable vote_share_pres_1round "The vote share of party of the incumbent president"
label variable vote_share_pres_2round "The vote share of party of the incumbent president"

* preparing variables

gen year_of_election = 2018

* keep variables

keep cod_tse year_of_election vote_share_pres_1round vote_share_pres_2round

