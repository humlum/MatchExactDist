set more off

cap program drop EventStudyDid
program EventStudyDid

syntax varlist(max=1) [if], treat(varlist max=1) match(varlist max=1) cl_var(varlist max=1) cl(numlist max=1)  folder(string) file(string) pre(numlist max=1) post(numlist max=1) [survive(numlist max=2) reg_out graph_out]

qui{
preserve
keep if `match'!=.
keep `if'
keep if inrange(year_k,-`pre',`post')

if "`survive'"!=""{
    tokenize `survive'
    bysort unit: egen tot_survive = total(survive*inrange(year_k,`1',`2'))
	noisily: keep if tot_survive==`2'-`1'+1
}

bysort `match' year_k: egen tot_treat = total(`treat'==1)
bysort `match' year_k: egen tot_ctrl = total(`treat'!=1)
keep if tot_treat>0 & tot_ctrl>0

* Event Dummies
cap drop all
cap drop `treat'_p* 
cap drop ctrl_p*
gen all=1
foreach v of varlist `treat' ctrl{
cap drop `v'_pre* `v'_post*
foreach k of numlist `pre'/1{
gen `v'_pre`k' = 0
replace `v'_pre`k'   = 1 if (year_k==-`k')&`v'
}
foreach k of numlist 0/`post'{
gen `v'_post`k' = 0
replace `v'_post`k' = 1 if (year_k==`k')&`v'
}
}

/* DiD regression */
noisily: reghdfe `varlist' `treat'_pre`pre'-`treat'_pre2 `treat'_post* /* [aw=weight] */, nocons absorb(`treat' `match'#i.year_k) vce(cl `cl_var')
statsby _b _se, clear: reghdfe `varlist' `treat'_pre`pre'-`treat'_pre2 `treat'_post* /* [aw=weight] */, nocons absorb(`treat' `match'#i.year_k) vce(cl `cl_var') keepsingletons 

/* Generate confidence intervals band variables */
local cv = -invnormal((1-`cl')/2)

local no = 0
foreach grp in `treat'{
foreach k of numlist `pre'/2{
local no = `no'+1
disp `no'
cap drop `grp'_ci_low`no' `grp'_ci_high`no'
gen `grp'_ci_low`no' = _b_`grp'_pre`k' -  `cv'*_se_`grp'_pre`k'
gen `grp'_ci_high`no' = _b_`grp'_pre`k' +  `cv'*_se_`grp'_pre`k'
rename _b_`grp'_pre`k' `grp'_coeff`no'
}
local no = `no' + 1
gen `grp'_coeff`no' = 0
gen `grp'_ci_low`no' = 0
gen `grp'_ci_high`no' = 0
foreach k of numlist 0/`post'{
local no = `no'+1
disp `no'
cap drop `grp'_ci_low`no' `grp'_ci_high`no'
gen `grp'_ci_low`no' = _b_`grp'_post`k' -  `cv'*_se_`grp'_post`k'
gen `grp'_ci_high`no' = _b_`grp'_post`k' +  `cv'*_se_`grp'_post`k'
rename _b_`grp'_post`k' `grp'_coeff`no'
}
}

/* Event study graph */
cap mkdir `folder'
gen cons=1
keep `treat'_coeff* `treat'_ci* cons
reshape long `treat'_coeff `treat'_ci_low `treat'_ci_high, i(cons) j(t)
replace t = _n - (`pre'+1)
twoway 	///
		(rarea `treat'_ci_low `treat'_ci_high t, color(navy%30) lwidth(0))  ///
		(sc `treat'_coeff t, connect(direct) m(O) mc(navy) lc(navy)), ///
		graphregion(color(white)) bgcolor(white) legend(off region(lwidth(none))) ///
		xlabel(-`pre'(1)`post') xline(-0.5, lcolor(black) lpattern(dash)) xtitle("") ytitle("") title("`varlist' (DiD)") name("`varlist'_did", replace)
if "`graph_out'"!=""{
graph export `folder'/`file'_`pre'_`post'_`varlist'_did.png, replace
}
if "`reg_out'"!=""{
gen `varlist'_se = (`treat'_ci_high-`treat'_coeff)/`cv'
rename `treat'_coeff `varlist'_coeff

keep t `varlist'_coeff `varlist'_se

cap confirm file "`folder'/`file'_did.dta"
if _rc==0{
	merge 1:1 t using "`folder'/`file'_did.dta", keep(master match using)
	cap drop _merge
}
save "`folder'/`file'_did.dta", replace

restore

}
}

end
