# MatchExactDist
Software that implement the matching algorithm and event-study regression model in [Humlum (2021)](https://andershumlum.com/s/humlumJMP.pdf).
&nbsp;
## Main Scripts 
### `ExactMatchDist.ado` 
Program that implement the exact-distance matching procedure described in Section OA1.5.1 in [Humlum (2021)](https://andershumlum.com/s/humlumJMP.pdf).

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
  : Variables for exact matching   

`distance`
  : Variables for distance matching

`folder`
  : Output folder

`file`
  : File name for matched data set

`weight`
  : Options for weighing matrix of Mahalanobis distance metric 


&nbsp;

### `EventStudyDid.ado` 
Program for the matching-based event-study regression model described in Section OA2.2.2 of [Humlum (2021)](https://andershumlum.com/s/humlumJMP.pdf).

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
  : Number of pre-years in event study window

`post`
  : Number of post-years in event study window

`survive`
  : Condition that unit survives in a period

`reg_out`
  : Save regression output

`graph_out`
  : Export graphical output 


&nbsp;
## Auxiliary Codes (`~/auxiliary`)
### `ExactMatchDist.m` 
Program for finding matches called by `ExactMatchDist.ado'.
