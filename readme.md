# MatchExactDist
This code repository implements the matching-based event studies of [Humlum (2021)](https://andershumlum.com/s/humlumJMP.pdf).

## Main Scripts 

### `ExactMatchDist.ado` 
Matching procedure of Section OA1.5.1 in [Humlum (2021)](https://andershumlum.com/s/humlumJMP.pdf).

```
syntax varlist [if] , id(varlist) time(varlist) exact(varlist) distance(varlist) complier(varlist max=1) folder(string) file(string) weight(string)
```
#### Description of arguments

`varlist`
  : Treatment indicator

`id`
  : Firm identifier

`time`
  : Time variable

`exact`
  : Variables to match exactly    

`distance`
  : Variables for distance matching

`folder`
  : Output folder

`file`
  : Filename for matched data set

`weight`
  : Options for weighing matrix of Mahalanobis distance metric 


### `EventStudyDid.ado` 
Matching-based event studies described in Section OA2.2.2 of [Humlum (2021)](https://andershumlum.com/s/humlumJMP.pdf).

```
syntax varlist [if] , id(varlist) time(varlist) exact(varlist) distance(varlist) complier(varlist max=1) folder(string) file(string) weight(string)
```
#### Description of arguments

`varlist`
  : Outcome variable

`treat`
  : Treatment indicator

`match`
  : Match group

`cl_var`
  : Variable for clustering of standard errors

`cl`
  : Confidence level 

`folder`
  : Output folder

`file`
  : Output file name

`pre`
  : Number of pre-years in event study

`post`
  : Number of post-years in event study

`survive`
  : Condition that unit survives in period

`reg_out`
  : Save regression output

`graph_out`
  : Export graphical output 


## Auxiliary codes (`~/auxiliary`)
### `ExactMatchDist.m` 
Find matches