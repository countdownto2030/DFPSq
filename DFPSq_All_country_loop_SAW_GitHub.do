* DPFq for all sexually active women - Afganistan, Jordan and Pakistan DHSs ask about contraceptive use only for married women 
* Email Elizabeth hazel with questions - ehazel1@jhu.edu 
* Version 12 APril 2024 

clear all
set maxvar 10000
cd "Enter file path here "

local filelist: dir "." files "*.dta"
 
 foreach file of local filelist {
      use "`file'", clear
	  rename *, lower 
	  
* Generate demand satisfied among married women- definition 3
	tab v502 //married/in union women 
	tab v313 //currently using modern methods 
	tab v626a //met or unmet need (1,2,3,4)

	//Demand satisfied by modern methods - from DHS Git HUB 
		gen dps=0
		replace dps=1 if (v626a==3 | v626a==4) & v313==3
		replace dps=. if !inlist(v626a,1,2,3,4) /*eliminate no need from denominator*/
		label var dps "Demand satisfied by modern methods"

	*browse v626a v313 dps
	
* DPS - pills,iud,implant, injection or female sterilization
	cap drop dps1 _dps1	
	gen dps1 = 0 if inlist(v626a, 1,2,3,4)
	gen _dps1=1 if (v312>0 & v312<5) | v312==11 | v312==6 
		replace _dps1= 1 if v312==19 & v000=="ZA7"  //South Africa - 2m injectable 
		replace _dps1= 1 if v312==19 & v000=="ID7"  //Indonesia - 1m injectable 
	replace dps1=1 if _dps1==1 & dps1==0
	tab dps1 
	label var dps1 "DPS - Current use pills,iud,implant, injection or female sterilization"
	
* DPS - told about side effects and how to manage 
	cap drop dps2 _dps2	
	gen dps2 = 0 if dps1~=.   //restrict to DPS1

	gen _dps2=1 if (v3a02==1 | v3a03==1) & v3a04==1
    replace dps2=1 if _dps2==1 & dps2==0

	replace dps2=. if dps1==0
	tab dps2 	
	label var dps2 "DPS - Current use pills,iud,implant, injection or female sterilization - told about side effects/how to manage"

	
* DPS - told about side effects - JUST SIDE EFFECTS 
	cap drop dps4 _dps4	
	gen dps4 = 0 if dps1~=.   //restrict to DPS1

	gen _dps4=1 if (v3a02==1 | v3a03==1) 
    replace dps4=1 if _dps4==1 & dps4==0

	replace dps4=. if dps1==0
	tab dps4 	
	label var dps4 "DPS - Current use pills,iud,implant, injection or female sterilization - told about side effects only"
	
* DPS - condoms, male sterilization, LAM, female condom, emergnecy bcp, other modern and SDM
	cap drop dps3 _dps3	
	gen dps3 = 0 if inlist(v626a, 1,2,3,4)
	gen _dps3=1 if inlist(v312, 5, 7, 13, 14, 16, 17, 18)
		replace _dps3=1 if v312==19 & v000=="TL7" //Timor-Leste, billings method 
		replace _dps3=1 if v312==20 | v312==21 //Philippines - not on questionniare by v313 ID's as "Modern" - code as "Other modern" 
	replace dps3=1 if _dps3==1 & dps3==0
	tab dps3
	label var dps3 "DPS - Current use condoms, EC SDM, LAM male sterilization, other modern"	

* Any other methods mentions 
	gen method=0 if dps~=.   //restrict to DPS
	gen _method=1 if (v3a05==1 | v3a06==1 | v393a==1 | v395==1) 
	replace method=1 if _method==1 & method==0
	tab method 
	label var method "Told about other methods"

* Quality component indicator - hormonal facility methods only 	
	gen dfs_adjust_fac = 0 if dps~=.
	gen _dfs_adjust_fac = 1 if (dps2==1 & method==1) 
	replace dfs_adjust_fac = 1 if _dfs_adjust_fac==1 & dfs_adjust_fac==0
	label var dfs_adjust_fac "dfsq-facility based"
	
* Quality component indicator - TOTAL
	gen dfs_adjust = 0 if dps~=.
	gen _dfs_adjust = 1 if (dps2==1 & method==1) | (inlist(v312, 5, 7, 13, 14, 16, 17, 18)  & method==1)
	replace dfs_adjust = 1 if _dfs_adjust==1 & dfs_adjust==0
	label var dfs_adjust "dfsq-TOTAL"	
	
   keep v000 v001 v023 v313 v626a v005 v502 v312 v3a02 v3a03 v3a04 v3a05 v3a06 v395 dps dps1 dps2 dps3 method dps4 dfs_adjust_fac dfs_adjust v106 v102 v012 v190 v501 v312 v3a07 v337 source

 save `file', replace
 }
 
   clear
   local filelist: dir "." files "*.dta"
   /* concatenate files */
   local firstfile=`"""'+"`: word 1 of `filelist''"+`"""'
   local otherfiles: list filelist - firstfile
   use `firstfile'
   append using `otherfiles', generate(survey)
   drop survey   
   save appended_dataset.dta, replace