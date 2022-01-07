** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    model_brb_05jan2022_sir.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	31-MAr-2021
    //  algorithm task			    Reading the WHO GHE dataset - disease burden, YLL and DALY

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w009\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w009\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w009\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\model_brb_05jan2022_sir", replace
** HEADER -----------------------------------------------------

** CASE-LOAD : SIMULATION
clear all
version 16.0


** Load dataset from : caricom_02initialprep.do
** ! RUN <caricom_02initialprep> each AM before this model.
use "`datapath'\caricom_covid", clear

** Complete vector of dates : earliest dates missing for some time series
fillin date iso_num 
sort iso_num date

** Replace earliest ZERO counts for some countries
replace total_cases = total_cases[_n-1] if total_cases==. & total_cases[_n-1]>0 & iso_num==iso_num[_n-1] 
replace total_deaths = total_deaths[_n-1] if total_deaths==. & total_deaths[_n-1]>0 & iso_num==iso_num[_n-1] 
replace total_cases = 0 if total_cases==.
replace total_deaths = 0 if total_deaths==.
replace new_cases = 0 if new_cases==.
replace new_deaths = 0 if new_deaths==.

** Fill missing values from rectangularization
bysort iso_num : egen t1 = min(pop)
order t1, after(pop)
drop pop 
rename t1 pop
label var pop "Population"
** Fill -cgroup- (caricom, car-other, ukot)
bysort iso_num : egen t1 = min(cgroup)
order t1, after(cgroup)
drop cgroup
rename t1 cgroup
** Fill -group- (caricom, latin caribbean)
bysort iso_num : egen t1 = min(group)
order t1, after(group)
drop group
rename t1 group
drop _fillin
** Keep selected variables
decode iso_num, gen(country2)
replace iso=country2 if iso==""
drop country2
** Complete country values: again, some earliest entries are missing 
replace countryregion="Anguilla" if countryregion=="" & iso=="AIA"
replace countryregion="Antigua and Barbuda" if countryregion=="" & iso=="ATG"
replace countryregion="Bahamas" if countryregion=="" & iso=="BHS"
replace countryregion="Belize" if countryregion=="" & iso=="BLZ"
replace countryregion="Bermuda" if countryregion=="" & iso=="BMU"
replace countryregion="Barbados" if countryregion=="" & iso=="BRB"
replace countryregion="Cuba" if countryregion=="" & iso=="CUB"
replace countryregion="Cayman Islands" if countryregion=="" & iso=="CYM"
replace countryregion="Dominica" if countryregion=="" & iso=="DMA"
replace countryregion="Dominican Republic" if countryregion=="" & iso=="DOM"
replace countryregion="Grenada" if countryregion=="" & iso=="GRD"
replace countryregion="Guyana" if countryregion=="" & iso=="GUY"
replace countryregion="Haiti" if countryregion=="" & iso=="HTI"
replace countryregion="Jamaica" if countryregion=="" & iso=="JAM"
replace countryregion="Saint Kitts and Nevis" if countryregion=="" & iso=="KNA"
replace countryregion="Saint Lucia" if countryregion=="" & iso=="LCA"
replace countryregion="Montserrat" if countryregion=="" & iso=="MSR"
replace countryregion="Suriname" if countryregion=="" & iso=="SUR"
replace countryregion="Turks and Caicos Islands" if countryregion=="" & iso=="TCA"
replace countryregion="Trinidad and Tobago" if countryregion=="" & iso=="TTO"
replace countryregion="Saint Vincent and the Grenadines" if countryregion=="" & iso=="VCT"
replace countryregion="British Virgin Islands" if countryregion=="" & iso=="VGB"

label define group_ 1 "caricom" 2 "latin caribbean", modify
label values group group_
label define cgroup_ 1 "caricom" 2 "ukot" 3 "car-other", modify
label values cgroup cgroup_ 

** Simplify variable names slightly
    rename new_cases case
    rename new_deaths death
    rename total_cases tcase
    rename total_deaths tdeath 
    rename countryregion country 

** Keep CARICOM countries only
    keep if group==1 

** Create and Append CARICOM region to country-level dataset 
    preserve
        tempfile caricom
        collapse (sum) case death pop , by(date)
        rename pop t1
        egen pop= max(t1) 
        format pop %15.0fc
        drop t1
        gen iso="CAR" 
        gen iso_num = 1000
        gen country = "caricom" 
        gen tcase = sum(case) 
        gen tdeath = sum(death) 
        gen cgroup = 1
        gen group = 1
        save `caricom' 
    restore    
    append using `caricom'

** Case Rate (per 1,000 --> not yet used)
    gen rcase = (case / pop) * 100000

** Variable Labelling
    label var rcase "Rate of new cases per 100,000"
    label var country "Country name"
    label var iso "unique ISO-3 text"
    label var iso_num "unique ISO-3 numeric"
    label var pop "Country population"
    label var date "Date of outbreak" 
    label var case "New daily cases"
    label var death "New daily deaths"
    label var tcase "Cumulative cases"
    label var tdeath "Cumulative deaths"
    label var group "Caribbean country groups"
    format pop %15.1fc

    ** Elapsed days since initial onset of COVID
    sort iso date 
    bysort iso : gen elapsed = _n
    order elapsed , after(date)

    ** FIRST SMOOTH
    ** SMOOTHED CASE rates - running mean
    ** Repeat this for each country 
    ** 28-days, 14-days, 7-days, 3-days 
    bysort iso : asrol rcase , stat(mean) window(date 3) gen(rcase_av_3)
    bysort iso : asrol rcase , stat(mean) window(date 7) gen(rcase_av_7)
    bysort iso : asrol rcase , stat(mean) window(date 14) gen(rcase_av_14)
    bysort iso : asrol rcase , stat(mean) window(date 28) gen(rcase_av_28)

    ** SECOND SMOOTH
    ** Repeat this for each country 
    ** LOWESS smooth on running mean : bandwidth (0.1)
    ** LOWESS + 14-day running mean : lowess_14_`country'
    ** LOWESS + 7-day running mean : lowess_7_`country'
    ** LOWESS + 3-day running mean : lowess_3_`country'
    local clist "AIA ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
    foreach country of local clist {    
        lowess rcase_av_14 date if iso=="`country'", bwidth(0.1) gen(lowess_14_`country') name(low14_`country') nograph
        lowess rcase_av_7 date if iso=="`country'", bwidth(0.1) gen(lowess_7_`country') name(low7_`country') nograph
        lowess rcase_av_3 date if iso=="`country'", bwidth(0.1) gen(lowess_3_`country') name(low3_`country') nograph
    }
    sort iso date

    ** Create single LOWESS 14 (LOWESS + 14-day RUNNING MEAN) variable in LONG dataset format
    gen lowess_14 = lowess_14_AIA
    drop lowess_14_AIA
    local clist "ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
    foreach country of local clist {  
        replace lowess_14 = lowess_14_`country' if lowess_14==. & lowess_14_`country'<.
        drop lowess_14_`country'
    }

    ** Create single LOWESS 7  (LOWESS + 7-day RUNNING MEAN) variable in LONG dataset format
    gen lowess_7 = lowess_7_AIA
    drop lowess_7_AIA
    local clist "ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
    foreach country of local clist {  
        replace lowess_7 = lowess_7_`country' if lowess_7==. & lowess_7_`country'<.
        drop lowess_7_`country'
    }

    ** Create single LOWESS 3  (LOWESS + 3-day RUNNING MEAN) variable in LONG dataset format
    gen lowess_3 = lowess_3_AIA
    drop lowess_3_AIA
    local clist "ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
    foreach country of local clist {  
        replace lowess_3 = lowess_3_`country' if lowess_3==. & lowess_3_`country'<.
        drop lowess_3_`country'
    }

    ** Calculate acceleration (is rate increasing, decreasing, remaining steady on any given day)
    ** Acceleration uses the double-smoothed values
    gen accelerate14 = lowess_14 - lowess_14[_n-1] if iso_num == iso_num[_n-1]
    gen accelerate7 = lowess_7 - lowess_7[_n-1] if iso_num == iso_num[_n-1]
    gen accelerate3 = lowess_3 - lowess_3[_n-1] if iso_num == iso_num[_n-1]


** KEEP BARBADOS ONLY
        keep if iso=="BRB"

** Order from latest to oldest date
gsort -date
keep date iso country pop case rcase lowess_14 lowess_7 lowess_3 accelerate14 accelerate7 accelerate3 rcase_av_14 rcase_av_7 rcase_av_3
order date iso country pop case rcase rcase_av_14 lowess_14 rcase_av_7 lowess_7 rcase_av_3 lowess_3 accelerate14 accelerate7 accelerate3 
label var lowess_14 "Lowess smooth on 14-day running mean" 
label var lowess_7 "Lowess smooth on 7-day running mean" 
label var lowess_3 "Lowess smooth on 3-day running mean" 
label var accelerate14 "Is double-smoothed rate (14-day) incr. or decr. ?" 
label var accelerate7 "Is double-smoothed rate (7-day) incr. or decr. ?" 
label var accelerate3 "Is double-smoothed rate (3-day) incr. or decr. ?" 


** Final LOWESS daily value - becomes the entry value for the modelling
** The LOWESS value is a rate, so we need to convert rate back to count before applying to the modelling
** -frate- becomes the model starting value 
        ** STARTING VALUE: 3-DAY DOUBLE smooth
        sort date 
        gen elapsed = _n 
        egen t1 = max(elapsed) 
        gen t2 = lowess_3 if t1==elapsed
        gen t3 = (t2/100000) * pop
        egen t4 = min(t3) 
        global frate_d3 = t4
        drop elapsed t1 t2 t3 t4
        ** STARTING VALUE: 3-DAY SINGLE smooth
        sort date 
        gen elapsed = _n 
        egen t1 = max(elapsed) 
        gen t2 = rcase_av_3 if t1==elapsed
        gen t3 = (t2/100000) * pop
        egen t4 = min(t3) 
        global frate_s3 = t4
        drop elapsed t1 t2 t3 t4
        ** STARTING VALUE: 7-DAY DOUBLE smooth
        sort date 
        gen elapsed = _n 
        egen t1 = max(elapsed) 
        gen t2 = lowess_7 if t1==elapsed
        gen t3 = (t2/100000) * pop
        egen t4 = min(t3) 
        global frate_d7 = t4
        drop elapsed t1 t2 t3 t4
        ** STARTING VALUE: 7-DAY SINGLE smooth
        sort date 
        gen elapsed = _n 
        egen t1 = max(elapsed) 
        gen t2 = rcase_av_7 if t1==elapsed
        gen t3 = (t2/100000) * pop
        egen t4 = min(t3) 
        global frate_s7 = t4
        drop elapsed t1 t2 t3 t4

** Save the observed dataset
gen scenario = 0
keep scenario date iso country pop case rcase lowess_14 lowess_7 lowess_3 rcase_av_14 rcase_av_7 rcase_av_3 accelerate14 accelerate7 accelerate3
order scenario date iso country pop case rcase lowess_14 lowess_7 lowess_3 rcase_av_14 rcase_av_7 rcase_av_3 accelerate14 accelerate7 accelerate3
rename lowess_14 cases14
rename lowess_7 cases7
rename lowess_3 cases3
save "`datapath'\BRB_trajectory_2022", replace



** ---------------------------------------------------
** BUILD 10 MODELLING SCENARIOS
** 5 LEVELS OF IMMUNE RESPONSE 
** 2 WAVE LENGTHS
** ---------------------------------------------------
** MODELS
** All models have the same infectivity
** Model 1 = no immune response
** Model 2 = 10% with immune response
** Model 3 = 25% with immune response
** Model 4 = 50% with immune response
** Model 5 = 75% with immune response
** ---------------------------------------------------

** R-values across the FIVE time periods
global wk1 = 2.5
global wk2 = 2.4
global wk3 = 2.3
global wk4 = 2.2
global wk5 = 2.1

** SET THE STARTING VALUE 
** Initial number infected
** Can be:
** frate_d3 / frate_d7 (double smooth) 
** frate_s3 / frate_s7 (single smooth) 
global frate = $frate_d3

** WAVELENGTH for first 5 scenarios
** wlength1: Length of model window
** Which we split into 5 equal-length periods
**      p1: Period 1 
**      p2: Period 2 
**      p3: Period 3 
**      p4: Period 4 
**      p5: PerIod 5 
global jan1 = d(1jan2022)
global temp1 = c(current_date)
global temp2 = d($temp1)
global temp3 = $temp2 - $jan1
global wlength1 = 30 - $temp3
global wlength1 = 15
gen t1 = int($wlength1/5)
gen t2 = int(($wlength1/5)*2)
gen t3 = int(($wlength1/5)*3)
gen t4 = int(($wlength1/5)*4)
gen t5 = int(($wlength1/5)*5)
global p1 = int(t1)
global p2 = int(t2)
global p3 = int(t3)
global p4 = int(t4)
global p5 = int(t5)




** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 1
** WAVE LENGTH 30, IMMUNE RESPONSE 0%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Scenario 1
local scenario = 1

** Effective population
global epop = 280000

** Initial starting value
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-TIME PERIODS
local modelwindow=$wlength1
local modelwindow1=$wlength1-$p4
local modelwindow2=$wlength1-$p3
local modelwindow3=$wlength1-$p2
local modelwindow4=$wlength1-$p1

** DAY 0. Initial beta = equates to R value of 5 (5 new infections over 14 days) 
local betaA = $wk1 * `gamma'

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 2.5 (2.5 new infections over 14 days) 
local betaB = $wk2 * `gamma'

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 1.75 (1.75 new infections over 14 days) 
local betaC = $wk3 * `gamma'

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 1.25 (1.25 new infections over 14 days) 
local betaD = $wk4 * `gamma'

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma'

** Final date 
local interventiondateF=$p1+1

** ----------------------------------------------------------
** SCENARIO 1: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 1: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 1: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 1: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 1: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 1: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE PERIODS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength1
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario1", replace





** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 2
** WAVE LENGTH 30, IMMUNE RESPONSE 10%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Reduced risk of infection amongst fully vaccinated
local reduced = 0.25

** Scenario 2
local scenario = 2

** Effective population (10% vaccination coverage)
global epop = 280000
global epop_ = 280000 * (1 - (0.1 * `reduced'))
global epop1 = 1 - (0.1 * `reduced')

** Initial number infected
** Can be:
** frate_d3 / frate_d7 (double smooth) 
** frate_s3 / frate_s7 (single smooth) 
global inf = $frate_d3


** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength1
local modelwindow1=$wlength1-$p4
local modelwindow2=$wlength1-$p3
local modelwindow3=$wlength1-$p2
local modelwindow4=$wlength1-$p1

** DAY 0. Initial beta = equates to R value of 7 (7 new infections over 14 days) 
local betaA = $wk1 * `gamma' * $epop1

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 5 (5 new infections over 14 days) 
local betaB = $wk2 * `gamma' * $epop1

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 3 (3 new infections over 14 days) 
local betaC = $wk3 * `gamma' * $epop1

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 2 (2 new infections over 14 days) 
local betaD = $wk4 * `gamma' * $epop1

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma' * $epop1

** Final date 
local interventiondateF = $p1+1



** ----------------------------------------------------------
** SCENARIO 2: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 2: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 2: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 2: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 2: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 2: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE WEEKLY MODELS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength1
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario2", replace



** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 3
** WAVE LENGTH 30, IMMUNE RESPONSE 25%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Reduced risk of infection amongst fully vaccinated
local reduced = 0.25

** Scenario 3
local scenario = 3

** Effective population (25% vaccination coverage)
global epop = 280000
global epop_ = 280000 * (1 - (0.25 * `reduced'))
global epop1 = 1 - (0.25 * `reduced')

** Initial number infected
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength1
local modelwindow1=$wlength1-$p4
local modelwindow2=$wlength1-$p3
local modelwindow3=$wlength1-$p2
local modelwindow4=$wlength1-$p1

** DAY 0. Initial beta = equates to R value of 7 (7 new infections over 14 days) 
local betaA = $wk1 * `gamma' * $epop1

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 5 (5 new infections over 14 days) 
local betaB = $wk2 * `gamma' * $epop1

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 3 (3 new infections over 14 days) 
local betaC = $wk3 * `gamma' * $epop1

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 2 (2 new infections over 14 days) 
local betaD = $wk4 * `gamma' * $epop1

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma' * $epop1

** Final date 
local interventiondateF=$p1+1



** ----------------------------------------------------------
** SCENARIO 3: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 3: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 3: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 3: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 3: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 3: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE WEEKLY MODELS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength1
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario3", replace





** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 4
** WAVE LENGTH 30, IMMUNE RESPONSE 50%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Reduced risk of infection amongst fully vaccinated
local reduced = 0.25

** Scenario 4
local scenario = 4

** Effective population (50% vaccination coverage)
global epop = 280000
global epop_ = 280000 * (1 - (0.5 * `reduced'))
global epop1 = 1 - (0.5 * `reduced')

** Initial number infected
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength1
local modelwindow1=$wlength1-$p4
local modelwindow2=$wlength1-$p3
local modelwindow3=$wlength1-$p2
local modelwindow4=$wlength1-$p1

** DAY 0. Initial beta = equates to R value of 7 (7 new infections over 14 days) 
local betaA = $wk1 * `gamma' * $epop1

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 5 (5 new infections over 14 days) 
local betaB = $wk2 * `gamma' * $epop1

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 3 (3 new infections over 14 days) 
local betaC = $wk3 * `gamma' * $epop1

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 2 (2 new infections over 14 days) 
local betaD = $wk4 * `gamma' * $epop1

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma' * $epop1

** Final date 
local interventiondateF=$p1+1

** ----------------------------------------------------------
** SCENARIO 4: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 4: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 4: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 4: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 4: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 4: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE WEEKLY MODELS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength1
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario4", replace




** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 5
** WAVE LENGTH 30, IMMUNE RESPONSE 75%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Reduced risk of infection amongst fully vaccinated
local reduced = 0.25

** Scenario 5
local scenario = 5

** Effective population (75% vaccination coverage)
global epop = 280000
global epop_ = 280000 * (1 - (0.75 * `reduced'))
global epop1 = 1 - (0.75 * `reduced')

** Initial number infected
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength1
local modelwindow1=$wlength1-$p4
local modelwindow2=$wlength1-$p3
local modelwindow3=$wlength1-$p2
local modelwindow4=$wlength1-$p1

** DAY 0. Initial beta = equates to R value of 7 (7 new infections over 14 days) 
local betaA = $wk1 * `gamma' * $epop1

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 5 (5 new infections over 14 days) 
local betaB = $wk2 * `gamma' * $epop1

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 3 (3 new infections over 14 days) 
local betaC = $wk3 * `gamma' * $epop1

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 2 (2 new infections over 14 days) 
local betaD = $wk4 * `gamma' * $epop1

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma' * $epop1

** Final date 
local interventiondateF=$p1+1



** ----------------------------------------------------------
** SCENARIO 5: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 5: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 5: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 5: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 5: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 5: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE WEEKLY MODELS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength1
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario5", replace






*! * ---------------------------------------------------
*! * ---------------------------------------------------
*! * LONGER WAVE LENGTH
*! * ---------------------------------------------------
*! * ---------------------------------------------------

** MODELS
** All models have the same infectivity
** Model 6 = no immune response
** Model 7 = 10% with immune response
** Model 8 = 25% with immune response
** Model 9 = 50% with immune response
** Model 10 = 75% with immune response
** ---------------------------------------------------
** Infectivity across the FIVE weeks are

/// ** scenario (1-JAN-2022)
/// global wk1 = 4.5
/// global wk2 = 3.4
/// global wk3 = 1.6
/// global wk4 = 0.5
/// global wk5 = 0.3

/// ** SET THE STARTING VALUE 
/// ** Initial number infected
/// ** Can be:
/// ** frate_d3 / frate_d7 (double smooth) 
/// ** frate_s3 / frate_s7 (single smooth) 
/// global frate = frate_d3

** WAVELENGTH for scenarios 6 to 10
** wlength2: Length of model window
**      w1: Period 1 
**      p2: Period 2 
**      p3: Period 3 
**      p4: Period 4 
**      p5: Perpod 5 
global jan1 = d(1jan2022)
global temp1 = c(current_date)
global temp2 = d($temp1)
global temp3 = $temp2 - $jan1
global wlength2 = 45 - $temp3
global wlength2 = 15
gen t1 = int($wlength2/5)
gen t2 = int(($wlength2/5)*2)
gen t3 = int(($wlength2/5)*3)
gen t4 = int(($wlength2/5)*4)
gen t5 = int(($wlength2/5)*5)
global p1 = int(t1)
global p2 = int(t2)
global p3 = int(t3)
global p4 = int(t4)
global p5 = int(t5)

** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 6
** WAVE LENGTH 45, IMMUNE RESPONSE 0%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Scenario 6
local scenario = 6

** Effective population
global epop = 280000

** Initial number infected
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength2
local modelwindow1=$wlength2-$p4
local modelwindow2=$wlength2-$p3
local modelwindow3=$wlength2-$p2
local modelwindow4=$wlength2-$p1

** DAY 0. Initial beta = equates to R value of 5 (5 new infections over 14 days) 
local betaA = $wk1 * `gamma'

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 2.5 (2.5 new infections over 14 days) 
local betaB = $wk2 * `gamma'

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 1.75 (1.75 new infections over 14 days) 
local betaC = $wk3 * `gamma'

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 1.25 (1.25 new infections over 14 days) 
local betaD = $wk4 * `gamma'

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma'

** Final date 
local interventiondateF=$p1+1



** ----------------------------------------------------------
** SCENARIO 6: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 6: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 6: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 6: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 6: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 6: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE WEEKLY MODELS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength2
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario6", replace





** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 7
** WAVE LENGTH 45, IMMUNE RESPONSE 10%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Reduced risk of infection amongst fully vaccinated
local reduced = 0.25

** Scenario 7
local scenario = 7

** Effective population (10% vaccination coverage)
global epop = 280000
global epop_ = 280000 * (1 - (0.1 * `reduced'))
global epop1 = 1 - (0.1 * `reduced')

** Initial number infected
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength2
local modelwindow1=$wlength2-$p4
local modelwindow2=$wlength2-$p3
local modelwindow3=$wlength2-$p2
local modelwindow4=$wlength2-$p1

** DAY 0. Initial beta = equates to R value of 7 (7 new infections over 14 days) 
local betaA = $wk1 * `gamma' * $epop1

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 5 (5 new infections over 14 days) 
local betaB = $wk2 * `gamma' * $epop1

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 3 (3 new infections over 14 days) 
local betaC = $wk3 * `gamma' * $epop1

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 2 (2 new infections over 14 days) 
local betaD = $wk4 * `gamma' * $epop1

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma' * $epop1

** Final date 
local interventiondateF = $p1+1



** ----------------------------------------------------------
** SCENARIO 7: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 7: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 7: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 7: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 7: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 7: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE WEEKLY MODELS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength2
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario7", replace



** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 8
** WAVE LENGTH 45, IMMUNE RESPONSE 25%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Reduced risk of infection amongst fully vaccinated
local reduced = 0.25

** Scenario 8
local scenario = 8

** Effective population (25% vaccination coverage)
global epop = 280000
global epop_ = 280000 * (1 - (0.25 * `reduced'))
global epop1 = 1 - (0.25 * `reduced')

** Initial number infected
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength2
local modelwindow1=$wlength2-$p4
local modelwindow2=$wlength2-$p3
local modelwindow3=$wlength2-$p2
local modelwindow4=$wlength2-$p1

** DAY 0. Initial beta = equates to R value of 7 (7 new infections over 14 days) 
local betaA = $wk1 * `gamma' * $epop1

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 5 (5 new infections over 14 days) 
local betaB = $wk2 * `gamma' * $epop1

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 3 (3 new infections over 14 days) 
local betaC = $wk3 * `gamma' * $epop1

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 2 (2 new infections over 14 days) 
local betaD = $wk4 * `gamma' * $epop1

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma' * $epop1

** Final date 
local interventiondateF=$p1+1



** ----------------------------------------------------------
** SCENARIO 8: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 8: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 8: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 8: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 8: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 8: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE WEEKLY MODELS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength2
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario8", replace





** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 9
** WAVE LENGTH 45, IMMUNE RESPONSE 50%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Reduced risk of infection amongst fully vaccinated
local reduced = 0.25

** Scenario 9
local scenario = 9

** Effective population (50% vaccination coverage)
global epop = 280000
global epop_ = 280000 * (1 - (0.5 * `reduced'))
global epop1 = 1 - (0.5 * `reduced')

** Initial number infected
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength2
local modelwindow1=$wlength2-$p4
local modelwindow2=$wlength2-$p3
local modelwindow3=$wlength2-$p2
local modelwindow4=$wlength2-$p1

** DAY 0. Initial beta = equates to R value of 7 (7 new infections over 14 days) 
local betaA = $wk1 * `gamma' * $epop1

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 5 (5 new infections over 14 days) 
local betaB = $wk2 * `gamma' * $epop1

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 3 (3 new infections over 14 days) 
local betaC = $wk3 * `gamma' * $epop1

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 2 (2 new infections over 14 days) 
local betaD = $wk4 * `gamma' * $epop1

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma' * $epop1

** Final date 
local interventiondateF=$p1+1



** ----------------------------------------------------------
** SCENARIO 9: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 9: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 9: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 9: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 9: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 9: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE WEEKLY MODELS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength2
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario9", replace




** -------------------------------------------------------------------------
** -------------------------------------------------------------------------
** SCENARIO 10
** WAVE LENGTH 45, IMMUNE RESPONSE 75%
** -------------------------------------------------------------------------
** -------------------------------------------------------------------------

** Reduced risk of infection amongst fully vaccinated
local reduced = 0.25

** Scenario 10
local scenario = 10

** Effective population (75% vaccination coverage)
global epop = 280000
global epop_ = 280000 * (1 - (0.75 * `reduced'))
global epop1 = 1 - (0.75 * `reduced')

** Initial number infected
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength2
local modelwindow1=$wlength2-$p4
local modelwindow2=$wlength2-$p3
local modelwindow3=$wlength2-$p2
local modelwindow4=$wlength2-$p1

** DAY 0. Initial beta = equates to R value of 7 (7 new infections over 14 days) 
local betaA = $wk1 * `gamma' * $epop1

** Intervention date + 1 week (use 7+1 as model run starts on Day 0)
local interventiondateB = $p1+1
** Interim beta = equates to R value of 5 (5 new infections over 14 days) 
local betaB = $wk2 * `gamma' * $epop1

** Intervention date + 2 weeks (use 7+1 as model run starts on Day 0)
local interventiondateC = $p1+1
** Interim beta = equates to R value of 3 (3 new infections over 14 days) 
local betaC = $wk3 * `gamma' * $epop1

** Intervention date + 3 weeks (use 7+1 as model run starts on Day 0)
local interventiondateD = $p1+1
** Interim beta = equates to R value of 2 (2 new infections over 14 days) 
local betaD = $wk4 * `gamma' * $epop1

** Intervention date + 4 weeks (use 7+1 as model run starts on Day 0)
local interventiondateE = $p1+1
** Interim beta = equates to R value of 1 (1 new infection over 14 days) 
local betaE = $wk5 * `gamma' * $epop1

** Final date 
local interventiondateF=$p1+1



** ----------------------------------------------------------
** SCENARIO 10: BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** SCENARIO 10: PERIOD 1
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** SCENARIO 10: PERIOD 2
** ----------------------------------------------------------
        local inicond1 = "susceptible(`=S[`interventiondateB']') " + "infected(`=I[`interventiondateB']') " + "recovered(`=R[`interventiondateB']')"

        epi_sir, beta(`betaB') gamma(`gamma') `inicond1' ///
                days(`=`modelwindow4'') ///
                clear nograph
                
        local mB `r(maxinfect)'
        rename S SB
        rename I IB
        rename R RB
        replace t = t + $p1
        sort t

        tempfile datasetB
        save `datasetB'

** ----------------------------------------------------------
** SCENARIO 10: PERIOD 3
** ----------------------------------------------------------
        local inicond2 = "susceptible(`=SB[`interventiondateC']') " ///
                    + "infected(`=IB[`interventiondateC']') " ///
                    + "recovered(`=RB[`interventiondateC']')"

        epi_sir, beta(`betaC') gamma(`gamma') `inicond2' ///
                days(`=`modelwindow3'') ///
                clear nograph
                
        local mC `r(maxinfect)'
        rename S SC
        rename I IC
        rename R RC
        replace t = t + $p2
        sort t
        tempfile datasetC
        save `datasetC'

** ----------------------------------------------------------
** SCENARIO 10: PERIOD 4
** ----------------------------------------------------------
        local inicond3 = "susceptible(`=SC[`interventiondateD']') " ///
                    + "infected(`=IC[`interventiondateD']') " ///
                    + "recovered(`=RC[`interventiondateD']')"

        epi_sir, beta(`betaD') gamma(`gamma') `inicond3' ///
                days(`=`modelwindow2' ') ///
                clear nograph
                
        local mD `r(maxinfect)'
        rename S SD
        rename I ID
        rename R RD
        replace t = t + $p3
        sort t
        tempfile datasetD
        save `datasetD'

** ----------------------------------------------------------
** SCENARIO 10: PERIOD 5
** ----------------------------------------------------------
        local inicond4 = "susceptible(`=SD[`interventiondateE']') " ///
                    + "infected(`=ID[`interventiondateE']') " ///
                    + "recovered(`=RD[`interventiondateE']')"

        epi_sir, beta(`betaE') gamma(`gamma') `inicond4' ///
                days(`=`modelwindow1' ') ///
                clear nograph
                
        local mE `r(maxinfect)'
        rename S SE
        rename I IE
        rename R RE
        replace t = t + $p4
        sort t
        tempfile datasetE
        save `datasetE'

** ----------------------------------------------------------
** JOIN THE FIVE WEEKLY MODELS
** ----------------------------------------------------------
        use `datasetA'
        merge 1:1 t using `datasetB'
        drop _merge
        merge 1:1 t using `datasetC'
        drop _merge
        merge 1:1 t using `datasetD'
        drop _merge
        merge 1:1 t using `datasetE'
        drop _merge
        keep if t <= $wlength2
        order t S I R 
        sort t
        rename t days

** Cumulative Infected 
    gen infect_new = I
    replace infect_new  = IB if days >= $p1
    replace infect_new  = IC if days >= $p2
    replace infect_new  = ID if days >= $p3
    replace infect_new  = IE if days >= $p4

keep days infect_new 
gen scenario = `scenario'
order scenario days infect_new 
sort days
label var days "day count running from Day 1"
label var infect_new "New daily infections"
label var scenario "Model scenario"
save "`datapath'\covid2021-scenario10", replace
