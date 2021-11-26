set more off

cap program drop MatchExactDist
program MatchExactDist

syntax varlist [if] , id(varlist) time(varlist) exact(varlist) distance(varlist) complier(varlist max=1) folder(string) file(string) weight(string)

cap drop unit

sort `exact' `time' `id'
egen unit = group(`id' `time')

preserve
bysort `exact' `time': egen tot_treat = total((`varlist'==1))
bysort `exact' `time': egen tot_ctrl  = total((`varlist'==0))
keep if tot_treat>0 & tot_ctrl>0

sort `exact' `time' `id'
egen bin = group(`exact' `time')

keep unit `varlist' bin `distance'
order unit `varlist' bin `distance'
sort unit

cap mkdir `folder'/data
matwrite unit `varlist' bin `distance' using `folder'/data/data_`file'.mat, replace

cap rm `folder'/data/match_done.txt

shell matlab -noFigureWindows -r "folder='`folder'';file='`file'';weight='`weight'';cd `folder';run('auxiliary/MatchExactDist.m'); quit;" 

capture confirm file `folder'/data/match_done.txt
while _rc{
capture confirm file `folder'/data/match_done.txt
}

import delimited `folder'/data/match_`file'.csv, clear

rename v1 unit_treat
rename v2 unit_ctrl
rename v3 distance
sort unit_treat unit_ctrl
egen unit_match = group(unit_treat unit_ctrl)

keep if unit_match!=.
sort unit_treat
save `folder'/data/match_`file'.dta, replace

restore

cap drop unit_*
gen unit_treat = unit
gen unit_ctrl = unit

cap drop _merge
merge 1:1 unit_treat using `folder'/data/match_`file'.dta, keep(master match) keepusing(unit_match distance) nogen
rename unit_match match
rename distance match_dist
merge 1:m unit_ctrl using `folder'/data/match_`file'.dta, keep(master match) keepusing(unit_match distance) nogen
replace match = unit_match if match==. & unit_match!=.
replace match_dist = distance if match_dist==. & distance!=.
cap drop unit* distance

* rm `folder'/data/data_`file'.mat
cap rm `folder'/data/match_`file'.csv
cap rm `folder'/data/match_`file'.dta

end
