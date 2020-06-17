* first, edit data by electoral year

set more off, perma

* elections years of 2002, 2006, 2010, and 2014

foreach k in 2002 2006 2010 2014 {

use "$tmp/_tse_doacoes_`k'", clear

* definition of electoral cycle

gen electoral_cycle = ano_eleicao
label var electoral_cycle "election year of the political contribution"

//edited variables
replace valorreceita=subinstr(valorreceita,",",".", .)
replace valorreceita=subinstr(valorreceita,"|",".", .)
replace valorreceita=subinstr(valorreceita,"/",".", .)
destring valorreceita, replace

* identifying how many digits string "cpfcnpjdodoador" has

gen qtst = length(cpfcnpjdodoador)
	//	cpf:	has a length of 11
	//	cnpj:	has a length of 14
drop if qtst ~= 11 & qtst ~= 14 	

* definition of CNPJ raiz (first 8 numbers)

gen cnpj_raiz = substr(cpfcnpjdodoador,1,8) if qtst ==14

* definition of CPF

gen cpf = cpfcnpjdodoador if qtst ==11

* dummies for donor firms - CNPJ

by cnpj_raiz, sort: gen iten1 = 1 
gen donor_pj_all = iten1 if cnpj_raiz ~=""
replace donor_pj_all  = 0 if donor_pj_all~=1 & cnpj_raiz ~=""
drop iten*

by cnpj_raiz, sort: gen iten1 = 1 if eleito ==1
by cnpj_raiz, sort: egen iten2 = max(iten1)
gen donor_pj_elected = iten2 if cnpj_raiz ~=""
replace donor_pj_elected  = 0 if donor_pj_elected~=1 & cnpj_raiz ~=""
drop iten*

by cnpj_raiz, sort: gen iten1 = 1 if ( descricao_cargo == "PRESIDENTE" )
by cnpj_raiz, sort: egen iten2 = max(iten1)
gen donor_pj_exec_nat = iten2 if cnpj_raiz ~=""
replace donor_pj_exec_nat  = 0 if donor_pj_exec_nat~=1 & cnpj_raiz ~=""
drop iten*


by cnpj_raiz, sort: gen iten1 = 1 if eleito ==1 & ( descricao_cargo == "PRESIDENTE" )
by cnpj_raiz, sort: egen iten2 = max(iten1)
gen donor_pj_exec_nat_elected = iten2 if cnpj_raiz ~=""
replace donor_pj_exec_nat_elected  = 0 if donor_pj_exec_nat_elected~=1 & cnpj_raiz ~=""
drop iten*

by cnpj_raiz, sort: gen iten1 = 1 if ( descricao_cargo == "DEPUTADO FEDERAL" | descricao_cargo == "SENADOR" )
by cnpj_raiz, sort: egen iten2 = max(iten1)
gen donor_pj_legis_nat = iten2 if cnpj_raiz ~=""
replace donor_pj_legis_nat  = 0 if donor_pj_legis_nat~=1 & cnpj_raiz ~=""
drop iten*

by cnpj_raiz, sort: gen iten1 = 1 if eleito ==1 & ( descricao_cargo == "DEPUTADO FEDERAL" | descricao_cargo == "SENADOR" )
by cnpj_raiz, sort: egen iten2 = max(iten1)
gen donor_pj_legis_nat_elected = iten2 if cnpj_raiz ~=""
replace donor_pj_legis_nat_elected  = 0 if donor_pj_legis_nat_elected~=1 & cnpj_raiz ~=""
drop iten*

* Donation amount of donor firms - CNPJ

by cnpj_raiz, sort: egen iten1 = sum(valorreceita) 
gen value_donor_pj_all = iten1 if cnpj_raiz ~=""
drop iten*

by cnpj_raiz, sort: egen iten1 = sum(valorreceita) if eleito ==1
by cnpj_raiz, sort: egen iten2 = mean(iten1)
gen value_donor_pj_elected = iten2 if cnpj_raiz ~=""
drop iten*

by cnpj_raiz, sort: egen iten1 = sum(valorreceita) if ( descricao_cargo == "PRESIDENTE" )
by cnpj_raiz, sort: egen iten2 = mean(iten1)
gen value_donor_pj_exec_nat = iten2 if cnpj_raiz ~=""
drop iten*


by cnpj_raiz, sort: egen iten1 = sum(valorreceita) if eleito ==1 & ( descricao_cargo == "PRESIDENTE" )
by cnpj_raiz, sort: egen iten2 = mean(iten1)
gen value_donor_pj_exec_nat_elected = iten2 if cnpj_raiz ~=""
drop iten*

by cnpj_raiz, sort: egen iten1 = sum(valorreceita) if ( descricao_cargo == "DEPUTADO FEDERAL" | descricao_cargo == "SENADOR" )
by cnpj_raiz, sort: egen iten2 = mean(iten1)
gen value_donor_pj_legis_nat = iten2 if cnpj_raiz ~=""
drop iten*

by cnpj_raiz, sort: egen iten1 = sum(valorreceita) if eleito ==1 & ( descricao_cargo == "DEPUTADO FEDERAL" | descricao_cargo == "SENADOR" )
by cnpj_raiz, sort: egen iten2 = mean(iten1)
gen value_donor_pj_legis_nat_elected = iten2 if cnpj_raiz ~=""
drop iten*

* define winning presidential coalition parties
{
if ano_eleicao == "2002" {
gen iten1 = .
replace iten1 = 1 if sigla_partido == "PT"
replace iten1 = 1 if sigla_partido == "PL"
replace iten1 = 1 if sigla_partido == "PMN"
replace iten1 = 1 if sigla_partido == "PCdoB"
replace iten1 = 1 if sigla_partido == "PCB"
by cnpj_raiz, sort: egen iten2 = max(iten1) if cnpj_raiz ~=""
* dummie for donation
gen donor_pj_win_nat_coal = iten2 if cnpj_raiz ~=""
replace donor_pj_win_nat_coal  = 0 if donor_pj_win_nat_coal ~=1 & cnpj_raiz ~=""
* donation amount
by cnpj_raiz, sort: egen tmp1 = sum(valorreceita) if iten1 ==1 & cnpj_raiz ~=""
by cnpj_raiz, sort: egen tmp2 = mean(tmp1)
gen value_donor_pj_win_nat_coal = tmp2 if cnpj_raiz ~=""
drop iten* tmp*
}

else if ano_eleicao == "2006" {
gen iten1 = .
replace iten1 = 1 if sigla_partido == "PT"
replace iten1 = 1 if sigla_partido == "PMDB"
replace iten1 = 1 if sigla_partido == "PDT"
replace iten1 = 1 if sigla_partido == "PCdoB"
replace iten1 = 1 if sigla_partido == "PSB"
replace iten1 = 1 if sigla_partido == "PR"
replace iten1 = 1 if sigla_partido == "PL"
replace iten1 = 1 if sigla_partido == "PTB"
replace iten1 = 1 if sigla_partido == "PPS"
replace iten1 = 1 if sigla_partido == "PV"
replace iten1 = 1 if sigla_partido == "PRONA"
by cnpj_raiz, sort: egen iten2 = max(iten1) if cnpj_raiz ~=""
* dummie for donation
gen donor_pj_win_nat_coal = iten2 if cnpj_raiz ~=""
replace donor_pj_win_nat_coal  = 0 if donor_pj_win_nat_coal ~=1 & cnpj_raiz ~=""
* donation amount
by cnpj_raiz, sort: egen tmp1 = sum(valorreceita) if iten1 ==1 & cnpj_raiz ~=""
by cnpj_raiz, sort: egen tmp2 = mean(tmp1)
gen value_donor_pj_win_nat_coal = tmp2 if cnpj_raiz ~=""
drop iten* tmp*
}

else if ano_eleicao == "2010" {
gen iten1 = .
replace iten1 = 1 if sigla_partido == "PT"
replace iten1 = 1 if sigla_partido == "PMDB"
replace iten1 = 1 if sigla_partido == "PDT"
replace iten1 = 1 if sigla_partido == "PCdoB"
replace iten1 = 1 if sigla_partido == "PSB"
replace iten1 = 1 if sigla_partido == "PR"
replace iten1 = 1 if sigla_partido == "PRB"
replace iten1 = 1 if sigla_partido == "PSC"
replace iten1 = 1 if sigla_partido == "PTC"
replace iten1 = 1 if sigla_partido == "PTN"
by cnpj_raiz, sort: egen iten2 = max(iten1) if cnpj_raiz ~=""
* dummie for donation
gen donor_pj_win_nat_coal = iten2 if cnpj_raiz ~=""
replace donor_pj_win_nat_coal  = 0 if donor_pj_win_nat_coal ~=1 & cnpj_raiz ~=""
* donation amount
by cnpj_raiz, sort: egen tmp1 = sum(valorreceita) if iten1 ==1 & cnpj_raiz ~=""
by cnpj_raiz, sort: egen tmp2 = mean(tmp1)
gen value_donor_pj_win_nat_coal = tmp2 if cnpj_raiz ~=""
drop iten* tmp*
}

else if ano_eleicao == "2014" {
gen iten1 = .
replace iten1 = 1 if sigla_partido == "PT"
replace iten1 = 1 if sigla_partido == "PMDB"
replace iten1 = 1 if sigla_partido == "PDT"
replace iten1 = 1 if sigla_partido == "PCdoB"
replace iten1 = 1 if sigla_partido == "PR"
replace iten1 = 1 if sigla_partido == "PRB"
replace iten1 = 1 if sigla_partido == "PROS"
replace iten1 = 1 if sigla_partido == "PSD"
replace iten1 = 1 if sigla_partido == "PP"
by cnpj_raiz, sort: egen iten2 = max(iten1) if cnpj_raiz ~=""
* dummie for donation
gen donor_pj_win_nat_coal = iten2 if cnpj_raiz ~=""
replace donor_pj_win_nat_coal  = 0 if donor_pj_win_nat_coal ~=1 & cnpj_raiz ~=""
* donation amount
by cnpj_raiz, sort: egen tmp1 = sum(valorreceita) if iten1 ==1 & cnpj_raiz ~=""
by cnpj_raiz, sort: egen tmp2 = mean(tmp1)
gen value_donor_pj_win_nat_coal = tmp2 if cnpj_raiz ~=""
drop iten* tmp*
}
}


* dummies for donor individuals - CPF

by cpf, sort: gen iten1 = 1 
gen donor_pf_all = iten1 if cpf ~=""
replace donor_pf_all  = 0 if donor_pf_all~=1 & cpf ~=""
drop iten*

by cpf, sort: gen iten1 = 1 if eleito ==1
by cpf, sort: egen iten2 = max(iten1)
gen donor_pf_elected = iten2 if cpf ~=""
replace donor_pf_elected  = 0 if donor_pf_elected~=1 & cpf ~=""
drop iten*

by cpf, sort: gen iten1 = 1 if ( descricao_cargo == "PRESIDENTE" )
by cpf, sort: egen iten2 = max(iten1)
gen donor_pf_exec_nat = iten2 if cpf ~=""
replace donor_pf_exec_nat  = 0 if donor_pf_exec_nat~=1 & cpf ~=""
drop iten*


by cpf, sort: gen iten1 = 1 if eleito ==1 & ( descricao_cargo == "PRESIDENTE" )
by cpf, sort: egen iten2 = max(iten1)
gen donor_pf_exec_nat_elected = iten2 if cpf ~=""
replace donor_pf_exec_nat_elected  = 0 if donor_pf_exec_nat_elected~=1 & cpf ~=""
drop iten*

by cpf, sort: gen iten1 = 1 if ( descricao_cargo == "DEPUTADO FEDERAL" | descricao_cargo == "SENADOR" )
by cpf, sort: egen iten2 = max(iten1)
gen donor_pf_legis_nat = iten2 if cpf ~="" 
replace donor_pf_legis_nat  = 0 if donor_pf_legis_nat~=1 & cpf ~=""
drop iten*


by cpf, sort: gen iten1 = 1 if eleito ==1 & ( descricao_cargo == "DEPUTADO FEDERAL" | descricao_cargo == "SENADOR" )
by cpf, sort: egen iten2 = max(iten1)
gen donor_pf_legis_nat_elected = iten2
replace donor_pf_legis_nat_elected  = 0 if donor_pf_legis_nat_elected~=1 & cpf ~=""
drop iten*

* Donation amount of donor individuals - CPF

by cpf, sort: egen iten1 = sum(valorreceita) if cpf ~=""
gen value_donor_pf_all = iten1 if cpf ~=""
drop iten*

by cpf, sort: egen iten1 = sum(valorreceita) if eleito ==1 & cpf ~=""
by cpf, sort: egen iten2 = mean(iten1)
gen value_donor_pf_elected = iten2 if cpf ~=""
drop iten*

by cpf, sort: egen iten1 = sum(valorreceita) if ( descricao_cargo == "PRESIDENTE" ) & cpf ~=""
by cpf, sort: egen iten2 = mean(iten1)
gen value_donor_pf_exec_nat = iten2 if cpf ~=""
drop iten*


by cpf, sort: egen iten1 = sum(valorreceita) if eleito ==1 & ( descricao_cargo == "PRESIDENTE" ) & cpf ~=""
by cpf, sort: egen iten2 = mean(iten1)
gen value_donor_pf_exec_nat_elected = iten2 if cpf ~=""
drop iten*

by cpf, sort: egen iten1 = sum(valorreceita) if ( descricao_cargo == "DEPUTADO FEDERAL" | descricao_cargo == "SENADOR" ) & cpf ~=""
by cpf, sort: egen iten2 = mean(iten1)
gen value_donor_pf_legis_nat = iten2 if cpf ~=""
drop iten*

by cpf, sort: egen iten1 = sum(valorreceita) if eleito ==1 & ( descricao_cargo == "DEPUTADO FEDERAL" | descricao_cargo == "SENADOR" ) & cpf ~=""
by cpf, sort: egen iten2 = mean(iten1)
gen value_donor_pf_legis_nat_elected = iten2 if cpf ~=""
drop iten*

* define winning presidential coalition parties
{
if ano_eleicao == "2002" {
gen iten1 = .
replace iten1 = 1 if sigla_partido == "PT"
replace iten1 = 1 if sigla_partido == "PL"
replace iten1 = 1 if sigla_partido == "PMN"
replace iten1 = 1 if sigla_partido == "PCdoB"
replace iten1 = 1 if sigla_partido == "PCB"
by cpf, sort: egen iten2 = max(iten1) if cpf ~=""
* dummie for donation
gen donor_pf_win_nat_coal = iten2 if cpf ~=""
replace donor_pf_win_nat_coal  = 0 if donor_pf_win_nat_coal ~=1 & cpf ~=""
* donation amount
by cpf, sort: egen tmp1 = sum(valorreceita) if iten1 ==1 & cpf ~=""
by cpf, sort: egen tmp2 = mean(tmp1)
gen value_donor_pf_win_nat_coal = tmp2 if cpf ~=""
drop iten* tmp*
}

else if ano_eleicao == "2006" {
gen iten1 = .
replace iten1 = 1 if sigla_partido == "PT"
replace iten1 = 1 if sigla_partido == "PMDB"
replace iten1 = 1 if sigla_partido == "PDT"
replace iten1 = 1 if sigla_partido == "PCdoB"
replace iten1 = 1 if sigla_partido == "PSB"
replace iten1 = 1 if sigla_partido == "PR"
replace iten1 = 1 if sigla_partido == "PL"
replace iten1 = 1 if sigla_partido == "PTB"
replace iten1 = 1 if sigla_partido == "PPS"
replace iten1 = 1 if sigla_partido == "PV"
replace iten1 = 1 if sigla_partido == "PRONA"
by cpf, sort: egen iten2 = max(iten1) if cpf ~=""
* dummie for donation
gen donor_pf_win_nat_coal = iten2 if cpf ~=""
replace donor_pf_win_nat_coal  = 0 if donor_pf_win_nat_coal ~=1 & cpf ~=""
* donation amount
by cpf, sort: egen tmp1 = sum(valorreceita) if iten1 ==1 & cpf ~=""
by cpf, sort: egen tmp2 = mean(tmp1)
gen value_donor_pf_win_nat_coal = tmp2 if cpf ~=""
drop iten* tmp*

}

else if ano_eleicao == "2010" {
gen iten1 = .
replace iten1 = 1 if sigla_partido == "PT"
replace iten1 = 1 if sigla_partido == "PMDB"
replace iten1 = 1 if sigla_partido == "PDT"
replace iten1 = 1 if sigla_partido == "PCdoB"
replace iten1 = 1 if sigla_partido == "PSB"
replace iten1 = 1 if sigla_partido == "PR"
replace iten1 = 1 if sigla_partido == "PRB"
replace iten1 = 1 if sigla_partido == "PSC"
replace iten1 = 1 if sigla_partido == "PTC"
replace iten1 = 1 if sigla_partido == "PTN"
by cpf, sort: egen iten2 = max(iten1) if cpf ~=""
* dummie for donation
gen donor_pf_win_nat_coal = iten2 if cpf ~=""
replace donor_pf_win_nat_coal  = 0 if donor_pf_win_nat_coal ~=1 & cpf ~=""
* donation amount
by cpf, sort: egen tmp1 = sum(valorreceita) if iten1 ==1 & cpf ~=""
by cpf, sort: egen tmp2 = mean(tmp1)
gen value_donor_pf_win_nat_coal = tmp2 if cpf ~=""
drop iten* tmp*

}

else if ano_eleicao == "2014" {
gen iten1 = .
replace iten1 = 1 if sigla_partido == "PT"
replace iten1 = 1 if sigla_partido == "PMDB"
replace iten1 = 1 if sigla_partido == "PDT"
replace iten1 = 1 if sigla_partido == "PCdoB"
replace iten1 = 1 if sigla_partido == "PR"
replace iten1 = 1 if sigla_partido == "PRB"
replace iten1 = 1 if sigla_partido == "PROS"
replace iten1 = 1 if sigla_partido == "PSD"
replace iten1 = 1 if sigla_partido == "PP"
by cpf, sort: egen iten2 = max(iten1) if cpf ~=""
* dummie for donation
gen donor_pf_win_nat_coal = iten2 if cpf ~=""
replace donor_pf_win_nat_coal  = 0 if donor_pf_win_nat_coal ~=1 & cpf ~=""
* donation amount
by cpf, sort: egen tmp1 = sum(valorreceita) if iten1 ==1 & cpf ~=""
by cpf, sort: egen tmp2 = mean(tmp1)
gen value_donor_pf_win_nat_coal = tmp2 if cpf ~=""
drop iten* tmp*
}
}

* all together

gen donor_all = donor_pj_all
replace donor_all = donor_pf_all if donor_pj_all == . & donor_pf_all ~=.
gen donor_elected = donor_pj_elected
replace donor_elected = donor_pf_elected if donor_pj_elected == . & donor_pf_elected ~=.
gen donor_exec_nat = donor_pj_exec_nat
replace donor_exec_nat = donor_pf_exec_nat if donor_pj_exec_nat == . & donor_pf_exec_nat ~=.
gen donor_exec_nat_elected = donor_pj_exec_nat_elected
replace donor_exec_nat_elected = donor_pf_exec_nat_elected if donor_pj_exec_nat_elected == . & donor_pf_exec_nat_elected ~=.
gen donor_legis_nat = donor_pj_legis_nat
replace donor_legis_nat = donor_pf_legis_nat if donor_pj_legis_nat == . & donor_pf_legis_nat ~=.
gen donor_legis_nat_elected = donor_pj_legis_nat_elected
replace donor_legis_nat_elected = donor_pf_legis_nat_elected if donor_pj_legis_nat_elected == . & donor_pf_legis_nat_elected ~=.
gen donor_win_nat_coal = donor_pj_win_nat_coal
replace donor_win_nat_coal = donor_pf_win_nat_coal if donor_pj_win_nat_coal == . & donor_pf_win_nat_coal ~=.

gen value_donor_all = value_donor_pj_all
replace value_donor_all = value_donor_pf_all if value_donor_pj_all == . & value_donor_pf_all ~=.
gen value_donor_elected = value_donor_pj_elected
replace value_donor_elected = value_donor_pf_elected if value_donor_pj_elected == . & value_donor_pf_elected ~=.
gen value_donor_exec_nat = value_donor_pj_exec_nat
replace value_donor_exec_nat = value_donor_pf_exec_nat if value_donor_pj_exec_nat == . & value_donor_pf_exec_nat ~=.
gen value_donor_exec_nat_elected = value_donor_pj_exec_nat_elected
replace value_donor_exec_nat_elected = value_donor_pf_exec_nat_elected if value_donor_pj_exec_nat_elected == . & value_donor_pf_exec_nat_elected ~=.
gen value_donor_legis_nat = value_donor_pj_legis_nat
replace value_donor_legis_nat = value_donor_pf_legis_nat if value_donor_pj_legis_nat == . & value_donor_pf_legis_nat ~=.
gen value_donor_legis_nat_elected = value_donor_pj_legis_nat_elected
replace value_donor_legis_nat_elected = value_donor_pf_legis_nat_elected if value_donor_pj_legis_nat_elected == . & value_donor_pf_legis_nat_elected ~=.
gen value_donor_win_nat_coal = value_donor_pj_win_nat_coal
replace value_donor_win_nat_coal = value_donor_pf_win_nat_coal if value_donor_pj_win_nat_coal == . & value_donor_pf_win_nat_coal ~=.

* drop variables

drop donor_p*

drop value_donor_p*

* edit data
gen numero_documento = ""
replace numero_documento = cpf if cpf ~="" 
replace numero_documento = cnpj_raiz if cnpj_raiz ~="" 

gen tipo_documento = ""
replace tipo_documento = "CPF" if cpf ~="" 
replace tipo_documento = "CNPJ RAIZ" if cnpj_raiz ~="" 

* clean data

by cpfcnpjdodoador, sort: drop if _n>1
order tipo_documento numero_documento  cpfcnpjdodoador donor_*  value_* electoral_cycle
keep numero_documento tipo_documento cpfcnpjdodoador donor_*  value_* electoral_cycle
save "$tmp/donor_`k'.dta", replace
}

* append database of donor firms

clear

foreach x in 2002 2006 2010 2014 {

append using "$tmp/donor_`x'"

}

* drop duplicates observations

duplicates drop cpfcnpjdodoador electoral_cycle, force

* encode tipo_documento
encode tipo_documento, generate(ien)
drop tipo_documento
rename ien tipo_documento

* destring variables

destring electoral_cycle, replace

* label variables 

label var electoral_cycle "Election year of the political contribution"
label var tipo_documento "Donor identification type"

label var donor_all "=1 if an agent donated at least once"
label var donor_elected "=1 if an agent donated to an elected"
label var donor_exec_nat "=1 if an agent donated to the national executive branch"
label var donor_exec_nat_elected "=1 if an agent donated to an elected in the national executive branch"
label var donor_legis_nat "=1 if an agent donated to the national legislative branch"
label var donor_legis_nat_elected "=1 if an agent donated to an elected in the national legislative branch"
label var donor_win_nat_coal "=1 if an agent donated to winning presidential coalition parties"

label var value_donor_all "Donation amount of an agent that donated at least once"
label var value_donor_elected "Donation amount of an agent that donated to an elected"
label var value_donor_exec_nat "Donation amount of an agent that donated to the national executive branch"
label var value_donor_exec_nat_elected "Donation amount of an agent that donated to an elected in the national executive branch"
label var value_donor_legis_nat "Donation amount of an agent that donated to the national legislative branch"
label var value_donor_legis_nat_elected "Donation amount of an agent that donated to an elected in the national legislative branch"
label var value_donor_win_nat_coal "Donation amount of an agent that donated to winning presidential coalition parties"
