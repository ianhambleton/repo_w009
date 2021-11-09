** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_05scenarios.do
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
    log using "`logpath'\caricom_05scenarios", replace
** HEADER -----------------------------------------------------

** SOCIAL DISTANCING POLICY SIMULATION

clear all
version 16.0


use "`datapath'\caricom_trajectories", clear

** TEST procedures in Barbados
keep if iso=="BRB"

** Order from latest to oldest date
gsort -date
keep date iso country pop lowess_14 accelerate rcase_av_14
order date iso country pop rcase_av_14 lowess_14 accelerate 

** Find most recent nadir
gen acc1 = 1 if accelerate > 0
replace acc1 = 2 if accelerate < 0
gen acc2 = _n if acc1==2 & acc1[_n-1]==1
egen acc3 = min(acc2)
**keep if _n < acc3
drop acc1 acc2 acc3
sort date

** Final LOWESS daily value - becomes the entry value for the modelling
** The LOWESS value is a rate, so we need to convert rate to count for applying to the modelling
sort date 
gen elapsed = _n 
egen t1 = max(elapsed) 
gen t2 = lowess_14 if t1==elapsed
gen t3 = (t2/100000) * pop
egen t4 = min(t3) 
global frate = t4
drop elapsed t1 t2 t3 t4

** Save the observed dataset
gen scenario = 0
keep scenario date iso country pop lowess_14 rcase_av_14
order scenario date iso country pop rcase_av_14 lowess_14 
rename lowess_14 cases
save "`datapath'\BRB_trajectory", replace


** ---------------------------------------------------
** MODELS
** All models have the same infectivity
** Model 4 = no vaccination
** Model 5 = 10% vaccination
** Model 6 = 25% vaccination
** Model 7 = 50% vaccination
** Model 8 = 75% vaccination
** ---------------------------------------------------
** Infectivity across the FIVE weeks are

** scenario 1
global wk1 = 3
global wk2 = 1.5
global wk3 = 0.8
global wk4 = 0.6
global wk5 = 0.5

** scenario 2
global wk1 = 1.65
global wk2 = 1.4
global wk3 = 1.1
global wk4 = 0.8
global wk5 = 0.5

** scenario 3 (25-Sep-2021)
global wk1 = 1.4
global wk2 = 1.2
global wk3 = 1.1
global wk4 = 0.8
global wk5 = 0.5

** scenario 4 (6-Oct-2021)
global wk1 = 1.45
global wk2 = 1.25
global wk3 = 1.1
global wk4 = 0.8
global wk5 = 0.5

** scenario 5 (28-Oct-2021)
global wk1 = 1.25
global wk2 = 1.15
global wk3 = 1.1
global wk4 = 0.8
global wk5 = 0.5

** scenario 6 (9-Nov-2021)
global wk1 = 1.15
global wk2 = 1.05
global wk3 = 0.9
global wk4 = 0.8
global wk5 = 0.5

** wlength: Length of model window
**      w1: Period 1 
**      p2: Period 2 
**      p3: Period 3 
**      p4: Period 4 
**      p5: Perpod 5 
global wlength = 45
global p1 = $wlength/5
global p2 = ($wlength/5)*2
global p3 = ($wlength/5)*3
global p4 = ($wlength/5)*4
global p5 = ($wlength/5)*5


** -------------------------------------------------------------------------
** MODEL PARAMETERS
** -------------------------------------------------------------------------

** Scenario 1
local scenario = 1

** Effective population
global epop = 280000

** Initial number infected
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength
local modelwindow1=$wlength-$p4
local modelwindow2=$wlength-$p3
local modelwindow3=$wlength-$p2
local modelwindow4=$wlength-$p1

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
** BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** FIRST WEEK
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** AFTER 1 WEEK
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
** AFTER 2 WEEKS
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
** AFTER 3 WEEKS
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
** AFTER 4 WEEKS
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
        keep if t <= $wlength
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
** MODEL PARAMETERS
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
global inf = $frate

** Gamma (1/length of infectivity in days)
local gamma = 1/14

** MODEL WINDOW = 5-WEEKS (35-DAYS - with model starting on day 0)
local modelwindow=$wlength
local modelwindow1=$wlength-$p4
local modelwindow2=$wlength-$p3
local modelwindow3=$wlength-$p2
local modelwindow4=$wlength-$p1

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
** BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

**! CHANGE Number SUSCEPTIBLE HERE (N=100,000)
**! SHould I change Susceptible because of vaccination? If so, by how much?
**! 73,000 vaccinated but some of these will become infected. AZ reduces transmission **! 40-60% so half of those vaccinated are still susceptible
**! CHANGE Initial number infected here (n=45)
local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** FIRST WEEK
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** AFTER 1 WEEK
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
** AFTER 2 WEEKS
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
** AFTER 3 WEEKS
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
** AFTER 4 WEEKS
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
        keep if t <= $wlength
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
** MODEL PARAMETERS
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
local modelwindow=$wlength
local modelwindow1=$wlength-$p4
local modelwindow2=$wlength-$p3
local modelwindow3=$wlength-$p2
local modelwindow4=$wlength-$p1

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
** BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

**! CHANGE Number SUSCEPTIBLE HERE (N=100,000)
**! SHould I change Susceptible because of vaccination? If so, by how much?
**! 73,000 vaccinated but some of these will become infected. AZ reduces transmission **! 40-60% so half of those vaccinated are still susceptible
**! CHANGE Initial number infected here (n=45)
local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** FIRST WEEK
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** AFTER 1 WEEK
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
** AFTER 2 WEEKS
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
** AFTER 3 WEEKS
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
** AFTER 4 WEEKS
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
        keep if t <= $wlength
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
** MODEL PARAMETERS
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
local modelwindow=$wlength
local modelwindow1=$wlength-$p4
local modelwindow2=$wlength-$p3
local modelwindow3=$wlength-$p2
local modelwindow4=$wlength-$p1

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
** BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

**! CHANGE Number SUSCEPTIBLE HERE (N=100,000)
**! SHould I change Susceptible because of vaccination? If so, by how much?
**! 73,000 vaccinated but some of these will become infected. AZ reduces transmission **! 40-60% so half of those vaccinated are still susceptible
**! CHANGE Initial number infected here (n=45)
local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** FIRST WEEK
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** AFTER 1 WEEK
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
** AFTER 2 WEEKS
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
** AFTER 3 WEEKS
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
** AFTER 4 WEEKS
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
        keep if t <= $wlength
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
** MODEL PARAMETERS
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
local modelwindow=$wlength
local modelwindow1=$wlength-$p4
local modelwindow2=$wlength-$p3
local modelwindow3=$wlength-$p2
local modelwindow4=$wlength-$p1

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
** BASELINE
** ----------------------------------------------------------
local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondateB' days."

**! CHANGE Number SUSCEPTIBLE HERE (N=100,000)
**! SHould I change Susceptible because of vaccination? If so, by how much?
**! 73,000 vaccinated but some of these will become infected. AZ reduces transmission **! 40-60% so half of those vaccinated are still susceptible
**! CHANGE Initial number infected here (n=45)
local inicond0 "susceptible($epop) " + "infected($inf) " + "recovered(0)"


** ----------------------------------------------------------
** FIRST WEEK
** ----------------------------------------------------------
        epi_sir, beta(`betaA') gamma(`gamma') `inicond0' ///
                        days(`modelwindow') clear nograph

        local mA `r(maxinfect)'
        tempfile datasetA
        **replace t = t + 1
        save `datasetA'		 

** ----------------------------------------------------------
** AFTER 1 WEEK
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
** AFTER 2 WEEKS
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
** AFTER 3 WEEKS
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
** AFTER 4 WEEKS
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
        keep if t <= $wlength
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
