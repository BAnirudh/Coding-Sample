********************************* Anirudh BHARADWAJ - Sciences Po,Paris ******************************************************

cd "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/Data"

***We first load the 'dataset A' and have a feel of the dataset

import delimited "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/Data/DatasetA.csv" //We have  11,216 observation
summarize

//Given that all the variables are 'string' variables, we don't find any summary statistics for most variables

***Task 1: Extracting different variables required
//Note: Looking at the variable 'incentivetext' and being aware of the fact that the central question that we are trying to answer is to look at the 'primary factors which drive banks to use dollar incentives'. Moreover, the variable also has varied information about the incentive structure with most of the variables having two common factors- the 'bonus amount' and the 'minimum deposit amount'. Thus, it makes sense that the primary variables that we'd need to exxtract from the 'incentivestext' variable corresponds to these two factors.

gen bonus = regexs(1) if regexm(incentivetext, "\\$([0-9,]+) ")
gen bonus_final = real(bonus)
//This gives us the bonus amount. The code extracts the amount after the first dollar sign

gen deposit_min = regexs(2) if regexm(incentivetext, "\\$([0-9,]+) .+\\$([0-9,]+)")
gen deposit_min_final = real(deposit_min)
//This gives us the minimum deposit amount. As the above, this code extracts the amount after the ssecond dollar sign. We could further use a similar approach to isolate other variables from the strings


save "NYU_DataA_Bonusamt.dta", replace

***Task 2: Matching the datasets

clear all
cls

import delimited "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/Data/DatasetB.csv",clear //716,733 observations
generate common = trim(fullname)
//We do this to create substrings to clear the data
codebook fullname
gen common1=lower(substr(common,1,60))
save "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/Data/NYU_DataB.dta", replace


use "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/NYU_DataA_Bonusamt.dta"
generate common = trim(primarycompany)
codebook common
gen common1=lower(substr(common,1,57))
save "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/NYU_DataA_Bonusamt.dta", replace
//We repeat the same exercise for the DatasetA

merge m:m common1 using "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/Data/NYU_DataB.dta"
keep if _merge==3
//We finally merge both the datasets and only keep the matched datapoints

save "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/Data/NYU RA Screening_Merged Dataset.dta"

//Note: I find that out of all the observations; 72,685 of them matched and 651,023 of them didn't match. 

***Task 3: Exploring the factors that drive banks to use incentive offers

gen log_assets = log(assets)
bysort bonus_final: egen log_assets_mean = mean(log_assets)
twoway (scatter bonus_final log_assets_mean) (lfit bonus_final log_assets_mean)
graph export "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/Graph1_AssetsVSBonus.png", as(png) name("Graph") replace

gen log_loans = log(loans)
bysort bonus_final: egen log_loans_mean = mean(log_loans)
twoway (scatter bonus_amount_final log_loans_mean) (lfit bonus_amount_final log_loans_mean)
graph export "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/Graph2_TotLoansVSBonus.png", as(png) name("Graph") replace

gen log_netinc = log(netinc)
bysort bonus_final: egen log_netinc_mean = mean(log_netinc)
twoway (scatter bonus_final log_netinc_mean) (lfit bonus_final log_netinc_mean)
g graph export "/Users/anirudhbharadwaj/Desktop/Work/Data Tasks/NYU/Graph3_NetIncVSBonus.png", as(png) name("Graph") replace

//Note: I try to run different regressions with various coefficients to see their inferences

reg bonus_final log_assets log_loans log_netinc nbranch hhi_depsumbr
//without a fixed effect

reg bonus_final log_assets log_loans log_netinc nbranch hhi_depsumbr i.common_float
//With a fixed effect

reghdfe log_bonus_final log_assets log_loans log_netinc nbranch hhi_depsumbr, absorb(i.common_float)
//Running the regression with a fixed effect and taking 'log' on both sides. This gives us the best estimates (I give more details in the short paper)
