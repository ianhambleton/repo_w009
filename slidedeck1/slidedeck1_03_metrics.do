** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_slides_metrics.do
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
    log using "`logpath'\caricom_slides_metrics", replace
** HEADER -----------------------------------------------------

** CARICOM region
** Data from -02initialprep- 
use "`datapath'\caricom_covid", clear
    rename new_cases case
    rename new_deaths death
    rename total_cases tcase
    rename total_deaths tdeath 
    rename countryregion country 

    ** Keep CARICOM only
    keep if group==1
        collapse (sum) case death pop , by(date)
        rename pop t1
        egen pop= max(t1) 
        format pop %15.0fc
        drop t1 

        ** Attack Rate (per 1,000 --> not yet used)
        gen rcase = (case / pop) * 100000
        label var rcase "Rate of new case per 100,000"

        label var pop "Country population"
        label var date "Date of outbreak" 
        label var case "New daily cases"
        label var death "New daily deaths"

        format pop %15.1fc

        ** Max rate 
        ** Elapsed days for X-axis
        sort date 
        gen elapsed = _n
        order elapsed , after(date)

        gen tcase = sum(case)
        gen tdeath = sum(death)
    

        ** SMOOTHED CASE rate 
        asrol rcase , stat(mean) window(date 3) gen(rcase_av_3)
        asrol rcase , stat(mean) window(date 7) gen(rcase_av_7)
        asrol rcase , stat(mean) window(date 14) gen(rcase_av_14)
        asrol rcase , stat(mean) window(date 28) gen(rcase_av_28)
        ** LOWESS smooth on 14 day mean rate
        lowess rcase_av_14 date, bwidth(0.1) gen(lowess_14) nograph
        lowess rcase_av_7 date, bwidth(0.1) gen(lowess_7_`country') name(low7_`country') nograph
        lowess rcase_av_3 date, bwidth(0.1) gen(lowess_3_`country') name(low3_`country') nograph

        ** gen accelerate = lowess_14 - lowess_14[_n-1] 

    ** Save CARICOM only dataset - will append to country-data later in DO file 
    tempfile caricom
    save `caricom', replace


** Individual CARICOM countries
use "`datapath'\caricom_covid", clear
    rename new_cases case
    rename new_deaths death
    rename total_cases tcase
    rename total_deaths tdeath 
    rename countryregion country 

    ** Keep CARICOM only
    keep if group==1 

    ** Attack Rate (per 1,000 --> not yet used)
    gen rcase = (case / pop) * 100000
    label var rcase "Rate of new case per 100,000"

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

    ** Max rate 
    ** Elapsed days for X-axis
    sort iso date 
    bysort iso : gen elapsed = _n
    order elapsed , after(date)

    ** SMOOTHED CASE rate 
    bysort iso : asrol rcase , stat(mean) window(date 3) gen(rcase_av_3)
    bysort iso : asrol rcase , stat(mean) window(date 7) gen(rcase_av_7)
    bysort iso : asrol rcase , stat(mean) window(date 14) gen(rcase_av_14)
    bysort iso : asrol rcase , stat(mean) window(date 28) gen(rcase_av_28)

    ** LOWESS smooth on 14 day mean rate for each country separately
    local clist "AIA ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
    foreach country of local clist {    
        lowess rcase_av_14 date if iso=="`country'", bwidth(0.1) gen(lowess_14_`country') name(low_`country') nograph
        lowess rcase_av_7 date, bwidth(0.1) gen(lowess_7_`country') name(low7_`country') nograph
        lowess rcase_av_3 date, bwidth(0.1) gen(lowess_3_`country') name(low3_`country') nograph
    }
    sort iso date

    ** Create single LOWESS variable
    gen lowess_14 = lowess_14_AIA
    drop lowess_14_AIA
    local clist "ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
    foreach country of local clist {  
        replace lowess_14 = lowess_14_`country' if lowess_14==. & lowess_14_`country'<.
        drop lowess_14_`country'
    }

    ** Create single LOWESS 7 variable
    gen lowess_7 = lowess_7_AIA
    drop lowess_7_AIA
    local clist "ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
    foreach country of local clist {  
        replace lowess_7 = lowess_7_`country' if lowess_7==. & lowess_7_`country'<.
        drop lowess_7_`country'
    }

    ** Create single LOWESS 3 variable
    gen lowess_3 = lowess_3_AIA
    drop lowess_3_AIA
    local clist "ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
    foreach country of local clist {  
        replace lowess_3 = lowess_3_`country' if lowess_3==. & lowess_3_`country'<.
        drop lowess_3_`country'
    }


    ** Join country files with CARICOM file
    append using `caricom'
    replace iso = "CAR" if iso==""
    replace country = "CARICOM" if iso=="CAR"
    replace iso_num = 1000 if iso_num==.

    ** Calculate acceleration (does rate incraese, decrease, remain steady)
    gen accelerate14 = lowess_14 - lowess_14[_n-1] if iso_num == iso_num[_n-1]
    gen accelerate7 = lowess_7 - lowess_7[_n-1] if iso_num == iso_num[_n-1]
    gen accelerate3 = lowess_3 - lowess_3[_n-1] if iso_num == iso_num[_n-1]

    ** Save the joined dataset of CARICOM country trajectories
    save "`datapath'\caricom_trajectories", replace




** --------------------------------------
** METRICS for RHS graphic
** --------------------------------------
** 1. Total cases
** 2. Total deaths
** 3. Cases in past 14 days
** 4. Deaths in past 14 days
** 5. Rate increasing, decreasing or steady (-accelerate-)
** 6. Rate at x% of peak
** --------------------------------------

** (1) Total cases
    sort date
    bysort iso: egen m01 = max(tcase)

** (2) Total deaths
    sort date
    bysort iso: egen m02 = max(tdeath)

** (6) Rate --> % of peak
    ** (a) Highest observed case rate in each country
    bysort iso : egen hrate = max(rcase_av_7) 
    ** (b) rate as percetage of highest rate
    sort iso date
    bysort iso : gen rat = (rcase_av_7 / hrate)*100 if iso!=iso[_n+1]
    bysort iso : egen m06 = min(rat)
    drop rat

** Create local macros for the various metrics
** Not: CUB DOM
local clist "AIA ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB CAR"
foreach country of local clist {

** (1) Total cases
    gen m01_`country'1 = m01 if iso=="`country'"
    egen m01_`country'2 = min(m01_`country'1)
    local m01_`country' = m01_`country'2
    global m01_nof_`country' = m01_`country'2
    global m01_`country' : dis %9.0fc m01_`country'2
    drop m01_`country'1 m01_`country'2

** (2) Total deaths
    gen m02_`country'1 = m02 if iso=="`country'"
    egen m02_`country'2 = min(m02_`country'1)
    local m02_`country' = m02_`country'2
    global m02_`country' : dis %9.0fc m02_`country'2
    drop m02_`country'1 m02_`country'2

** (3) Cases in past 7 days
    sort iso date 
    gen t1 = tcase - tcase[_n-7] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m03_`country' = t2
    global m03_nof_`country' = t2
    global m03_`country' : dis %9.0fc t2
    drop t1 t2 

** (3A) Rate in past 7 days
    sort iso date 
    gen t1 = rcase_av_7 if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local rate_`country' = t2
    global rate_`country' : dis %9.0fc t2
    drop t1 t2 

** (3B) Percentage of ALL cases in past 2 weeks
    sort iso date 
    gen t1 = ( ${m03_nof_`country'} / ${m01_nof_`country'} ) * 100
    egen t2 = min(t1)
    local p14_`country' = t2
    global p14_`country' : dis %4.0fc t2
    drop t1 t2 

** (4) Deaths in past 7 days
    sort iso date 
    gen t1 = tdeath - tdeath[_n-7] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m04_`country' = t2
    global m04_`country' : dis %9.0fc t2
    drop t1 t2 

** (5) Rate increasing, decreasing or steady (-accelerate-)
    sort iso date
    gen t1 = 1 if iso!=iso[_n+1] & iso=="`country'"
    gen t2 = accelerate7 if t1==1
    egen t3 = min(t2) if iso=="`country'"
    gen t4 = 1 if t3>0 & t1==1
    replace t4 = 2 if t3<0 & t1==1
    egen t5 = min(t4)
    local m05_`country' = t5
    global m05_`country' = t5

    if ${m05_`country'} == 1 {
        global up_`country' = "Rate rising"
    }
    else if ${m05_`country'} == 2 {
        global down_`country' = "Rate falling"
    }
    drop t1 t2 t3 t4 t5

** (6) Rate at % of peak
    gen m06_`country'1 = m06 if iso=="`country'"
    egen m06_`country'2 = min(m06_`country'1)
    local m06_`country' = m06_`country'2
    global m06_`country' : dis %3.0fc m06_`country'2
    drop m06_`country'1 m06_`country'2

    if ${m06_`country'} == 100 {
        global rate5_`country' = "At peak"
    }
    else if ${m06_`country'} < 100 {
        global rate5_`country' = "${m06_`country'}% of peak"
    }

}

