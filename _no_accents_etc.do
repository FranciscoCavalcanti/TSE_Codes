
*************************************************
**** Auxiliary file 1                        ****
**** qui replace all accents with normal letters ****
*************************************************

*** call: variable name

qui replace `1' = subinstr(`1',"ã","a",.) // a tilde
qui replace `1' = subinstr(`1',"Ã","A",.) // a tilde
qui replace `1' = subinstr(`1',"õ","o",.) // a tilde
qui replace `1' = subinstr(`1',"Õ","O",.) // a tilde
qui replace `1' = subinstr(`1',"ç","c",.) // cedille
qui replace `1' = subinstr(`1',"Ç","C",.) // cedille

qui replace `1' = subinstr(`1'," Â"," A",.) // some strange a (capital letter)
qui replace `1' = subinstr(`1',"Â","a",.) // some strange a (minor letter)

qui replace `1' = subinstr(`1'," Ä"," A",.) // some strange a (capital letter)
qui replace `1' = subinstr(`1',"Ä","a",.) // some strange a (minor letter)
qui replace `1' = subinstr(`1'," â"," A",.) // ⠨capital letter)
qui replace `1' = subinstr(`1',"â","a",.) // 
qui replace `1' = subinstr(`1'," À"," A",.) // some strange a (capital letter)
qui replace `1' = subinstr(`1',"À"," A",.) // some strange a (capital letter)
qui replace `1' = subinstr(`1'," à","A",.) // ⠨capital letter)
qui replace `1' = subinstr(`1',"à","a",.) // some strange a (minor letter)

qui replace `1' = subinstr(`1'," Á"," A",.) // �  (capital letter)
qui replace `1' = subinstr(`1',"Á","a",.) // �
qui replace `1' = subinstr(`1'," á"," A",.) // �  (capital letter)
qui replace `1' = subinstr(`1',"á","a",.) // �

qui replace `1' = subinstr(`1'," í"," I",.) // �  (capital letter)
qui replace `1' = subinstr(`1',"í","i",.) // �
qui replace `1' = subinstr(`1'," Í"," I",.) // 𘀨capital letter)
qui replace `1' = subinstr(`1',"Í","i",.) // 

qui replace `1' = subinstr(`1'," ú"," U",.) // � (capital letter)
qui replace `1' = subinstr(`1',"ú","u",.) // � 
qui replace `1' = subinstr(`1'," Ú"," U",.) // (capital letter)
qui replace `1' = subinstr(`1',"Ú","u",.) // some strange U
qui replace `1' = subinstr(`1'," û"," U",.) // 򠨣apital letter)
qui replace `1' = subinstr(`1',"û","u",.) // 򠍊qui replace `1' = subinstr(`1'," Ú"," U",.) // (capital letter)
qui replace `1' = subinstr(`1',"Û","u",.) // some strange U


qui replace `1' = subinstr(`1'," Ó"," O",.) // some strange O (capital letter)
qui replace `1' = subinstr(`1',"Ó","o",.) // some strange O
qui replace `1' = subinstr(`1'," ó"," O",.) // some strange O (capital letter)
qui replace `1' = subinstr(`1',"ó","o",.) // some strange O
qui replace `1' = subinstr(`1'," Ô"," O",.) // some strange O (capital letter)
qui replace `1' = subinstr(`1',"Ô","o",.) // some strange O
qui replace `1' = subinstr(`1'," ô"," O",.) // some strange O (capital letter)
qui replace `1' = subinstr(`1',"ô","o",.) // some strange O
qui replace `1' = subinstr(`1'," õ"," O",.) // some strange O (capital letter)
qui replace `1' = subinstr(`1',"õ","o",.) // some strange O
qui replace `1' = subinstr(`1'," ô"," O",.) // 𠨣apital letter)
qui replace `1' = subinstr(`1',"ô","o",.) // 𠀀

qui replace `1' = subinstr(`1'," Ê"," E",.) // some strange E (capital letter)
qui replace `1' = subinstr(`1',"Ê","e",.) // some strange E
qui replace `1' = subinstr(`1'," ê"," E",.) // some strange E (capital letter)
qui replace `1' = subinstr(`1',"ê","e",.) // some strange E
qui replace `1' = subinstr(`1'," É"," E",.) // some strange E (capital letter)
qui replace `1' = subinstr(`1',"É","e",.) // some strange E
qui replace `1' = subinstr(`1'," é"," E",.) // (capital letter)
qui replace `1' = subinstr(`1',"é","e",.) // 

qui replace `1' = subinstr(`1'," Í"," I",.) // some strange I (capital letter)
qui replace `1' = subinstr(`1',"Í","i",.) // some strange I
qui replace `1' = subinstr(`1'," Î"," I",.) // some strange I (capital letter)
qui replace `1' = subinstr(`1',"Î","i",.) // some strange I
qui replace `1' = subinstr(`1',"î","i",.) // some strange I

*** problem: some variables have a blank at the end
** solution: remove the blank at the end
qui replace `1' = rtrim(`1')

*** problem: typo: double space  
qui replace `1' = subinstr(`1',"  "," ",.)

*** replace wierd characters to single space
qui replace `1' = subinstr(`1',"'"," ",.) //
qui replace `1' = subinstr(`1',"^"," ",.) //
qui replace `1' = subinstr(`1',"?"," ",.) //







