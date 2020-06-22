# TSE_Codes

Codes in **Stata** to extract the raw data provided by the [Brazilian Superior Electoral Court (TSE)](http://www.tse.jus.br/eleicoes/estatisticas/repositorio-de-dados-eleitorais-1/repositorio-de-dados-eleitorais "Superior Electoral Court (TSE)") and generate a database in **.dta** format collapsed at the year and municipality level.

There are several codes for different purposes. They cover elections from **1996** and **2018**. Each main Stata do file is a compilation of many others do files that are stored in the folder [sub_do_file](./_sub_do_file). The main do files and their purpose are listed below:

## Main codes

* [**tse_mayor.do**](./tse_mayor.do):  extract information regarding the elected mayor  

* [**tse_mayor_characteristics.do**](./tse_mayor_characteristics.do): extract information regarding the charactersitics of the elected mayor 

* [**tse_mayor_vote_share.do**](./tse_mayor_vote_share.do): extract information regarding the vote share of the elected mayor 

* [**tse_president.do**](./tse_president.do): extract information regarding the president

* [**tse_donor_firms.do**](./tse_donor_firms.do): extract information regarding political donor firms

* [**tse_candidates_characteristics.do**](./tse_candidates_characteristics.do): extract information regarding the charactersitics of the candidates for mayor 

