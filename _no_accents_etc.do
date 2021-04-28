
*************************************************
**** Auxiliary file 1                    	    ****
**** qui replace all accents with normal letters ****
*************************************************

*** call: variable name

	qui replace `1' = ustrlower(`1')
	
	//-------------------//
	// lower case
	//-------------------//
	
	foreach c in � � � � � {
		qui replace `1' = usubinstr(`1', "`c'", "a", .)
	}
	foreach c in � � � � {
		qui replace `1' = usubinstr(`1', "`c'", "e", .)
	}
	foreach c in � � � � {
		qui replace `1' = usubinstr(`1', "`c'", "i", .)
	}
	foreach c in � � � � � {
		qui replace `1' = usubinstr(`1', "`c'", "o", .)
	}
	foreach c in � � � {
		qui replace `1' = usubinstr(`1', "`c'", "u", .)
	}
	*
	
	qui replace `1' = usubinstr(`1', "�", "c", .)
	qui replace `1' = usubinstr(`1', "�", "n", .)
	
	//-------------------//
	// upper case
	//-------------------//
	
	foreach C in � � � � � {
		qui replace `1' = usubinstr(`1', "`C'", "A", .)
	}
	foreach c in � � � � {
		qui replace `1' = usubinstr(`1', "`C'", "E", .)
	}
	foreach c in � � � � {
		qui replace `1' = usubinstr(`1', "`C'", "I", .)
	}
	foreach c in � � � � � {
		qui replace `1' = usubinstr(`1', "`C'", "O", .)
	}
	foreach c in � � � {
		qui replace `1' = usubinstr(`1', "`C'", "U", .)
	}
	*
	
	qui replace `1' = usubinstr(`1', "�", "C", .)
	qui replace `1' = usubinstr(`1', "�", "N", .)
	
	//-------------------//
	// other characters
	//-------------------//
	
	qui replace `1' = usubinstr(`1', "_", " ", .)
	qui replace `1' = subinstr(`1', ".", "", .)
	qui replace `1' = subinstr(`1', ",", "", .)
	qui replace `1' = subinstr(`1', "  ", " ", .)
	qui replace `1' = subinstr(`1', "[", "", .)
	qui replace `1' = subinstr(`1', "]", "", .)
	qui replace `1' = subinstr(`1', "{", "", .)
	qui replace `1' = subinstr(`1', "}", "", .)
	*qui replace `1' = subinstr(`1', "'", "", .)
	*qui replace `1' = subinstr(`1', "`", "", .)
	
	//-------------------//
	// spacing
	//-------------------//
	
	qui replace `1' = subinstr(`1', "  ", " ", .)
	qui replace `1' = strtrim(`1')

*** problem: some variables have a blank at the end
** solution: remove the blank at the end
qui replace `1' = rtrim(`1')

*** problem: typo: double space  
qui replace `1' = subinstr(`1',"  "," ",.)

*** replace wierd characters to single space
*qui replace `1' = subinstr(`1',"'"," ",.)  
qui replace `1' = subinstr(`1',"^"," ",.)  
qui replace `1' = subinstr(`1',"?"," ",.) //







