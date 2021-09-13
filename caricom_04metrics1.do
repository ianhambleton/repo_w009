** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_03profiles.do
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

    ** ianhambleton.com: WEBSITE outputs
    local webpath "X:\OneDrive - The University of the West Indies\repo_ianhambleton\website-ianhambleton\static\uploads"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\caricom_03profiles", replace
** HEADER -----------------------------------------------------

** JH time series COVD-19 data 
** RUN covidprofiles_002_jhopkins.do BEFORE this algorithm
** use "`datapath'\version01\2-working\covid_restricted_001", clear
use "`datapath'\caricom_covid", replace

** ---------------------------------------------------
** THE GLOBAL METRICS
** We use global (not local) macros here as we want them to be available
** after the DO file has completed
** Instead of single quotes (`xx') used for -local- macros
** We use the dollar prefix ($xx) for global macros
** ---------------------------------------------------
** Metric 01: current number of confirmed cases
** Metric 02: current number of confirmed deaths
** Metric 03: date of first confirmed case
** Metric 04: date of first confirmed death
** Metric 05: days since first reported case
** Metric 06: days since first reported death
** 
** Metric 20: Days until N=25 cases
** Metric 21: Days until N=50 cases
** Metric 22: Days until N=100 cases
** Metric 23: Days until N=200 cases
** Metric 24: Days until N=400 cases
** Metric 25: Days until N=800 cases
** Metric 26: Days until N=1600 cases
** Metric 27: Days until N=3200 cases
** Metric 28: Days until N=6400 cases
** Metric 29: Days until N=12800 cases
** 
** Metric 40: Days until N=25 deaths
** Metric 41: Days until N=50 deaths
** Metric 42: Days until N=100 deaths
** Metric 43: Days until N=200 deaths
** Metric 44: Days until N=400 deaths
** Metric 45: Days until N=800 deaths
** Metric 46: Days until N=1600 deaths
** Metric 47: Days until N=3200 deaths
** Metric 48: Days until N=6400 deaths
** Metric 49: Days until N=12800 deaths
**
** METRIC 60: 1-day increase in cases
** METRIC 61: 1-day increase in deaths
** METRIC 62: 7-day increase in cases
** METRIC 63: 7-day increase in deaths
** METRIC 64: 14-day increase in cases
** METRIC 65: 14-day increase in deaths
** METRIC 66: 21-day increase in cases
** METRIC 67: 21-day increase in deaths
**
** METRIC 70: Growth rate in cases
** METRIC 71: Growth rate in deaths 
** METRIC 72: Doubling time in cases
** METRIC 73: Doubling time in deaths
** ---------------------------------------------------

** METRIC 01 : CURRENT CONFIRMED CASES BY COUNTRY 
bysort iso: egen m01 = max(total_cases)
** METRIC 02: CURRENT CONFIRMED DEATHS BY COUNTRY 
bysort iso: egen m02 = max(total_deaths)
** METRIC 03: The DATE OF FIRST CONFIRMED CASE
bysort iso: egen m03 = min(date)
format m03 %td 
** METRIC 04: The DATE OF FIRST CONFIRMED DEATH
gen deaths_i = 0 
replace deaths_i = 1 if total_deaths>0 
bysort iso deaths_i: egen m04t = min(date) if deaths_i==1
bysort iso: egen m04 = min(m04t)
format m04 %td 
** METRIC 05: Days since first reported case
sort iso date 
bysort iso: gen elapsed = _n - 1
bysort iso: egen m05 = max(elapsed)
** METRIC 06: Days since first reported death
sort iso date 
bysort iso deaths_i: gen elapsedd = _n - 1
bysort iso deaths_i: egen m06t = max(elapsedd)
replace m06t = . if deaths_i==0 
bysort iso: egen m06 = min(m06t)
replace m06 = 0 if m06==. 

** METRICS 20-29: DAYS UNTIL N=X CASES
local metric = 20 
local numv = "25 50 100 200 400 800 1600 3200 6400 12800"
foreach num of local numv {
sort iso date 
gen t`num' = date if total_cases>=`num' & total_cases[_n-1]<`num'
bysort iso: egen d`num' = min(t`num')
gen m`metric' = d`num' - m03 
drop t`num' d`num'
local metric = `metric'+1
}

** METRICS 40-49: DAYS UNTIL N=X DEATHS
local metric = 40 
local numv = "25 50 100 200 400 800 1600 3200 6400 12800"
foreach num of local numv {
sort iso date 
gen t`num' = date if total_deaths>=`num' & total_deaths[_n-1]<`num'
bysort iso: egen d`num' = min(t`num')
gen m`metric' = d`num' - m03 
drop t`num' d`num'
local metric = `metric'+1
}

** METRIC 70 and 71:
** Growth rate - Cases / Deaths
sort iso date 
gen m70  = log(total_cases/total_cases[_n-1]) if iso==iso[_n-1] 
gen m71 = log(total_deaths/total_deaths[_n-1]) if iso==iso[_n-1] 

** METRIC 72 and 73: 
** Doubling time - Cases / Deaths
sort iso date 
gen dr_cases  = log(2)/m70
by iso: asrol dr_cases , stat(mean) window(date 10) gen(m72)
gen dr_deaths = log(2)/m71
by iso: asrol dr_deaths , stat(mean) window(date 10) gen(m73)


** Create local macros for the various metrics
** These will be used to create graphics and post to PDF briefings
local numz = "25 50 100 200 400 800 1600 3200 6400 12800"
local clist "AIA ATG BHS BRB BLZ BMU VGB CYM DMA GRD GUY HTI JAM MSR KNA LCA VCT SUR TTO TCA ISL NZL SGP KOR GBR USA CUB DOM"

foreach country of local clist {

    ** METRIC 01
    ** CURRENT NUMBER OF CASES IN EACH COUNTRY
    gen m01_`country'1 = m01 if iso=="`country'"
    egen m01_`country'2 = min(m01_`country'1)
    local m01_`country' = m01_`country'2
    global m01_`country' = m01_`country'2

    ** METRIC 02
    ** CURRENT NUMBER OF DEATHS IN EACH COUNTRY
    gen m02_`country'1 = m02 if iso=="`country'"
    egen m02_`country'2 = min(m02_`country'1)
    local m02_`country' = m02_`country'2
    global m02_`country' = m02_`country'2

    ** METRIC 03
    ** Date of First Confirmed Case
    gen m03_`country'1 = m03 if iso=="`country'"
    egen m03_`country'2 = min(m03_`country'1)
    local m03_`country' : disp %tdDD_Month m03_`country'2
    global m03_`country' : disp %tdDD_Month m03_`country'2

    ** METRIC 04
    ** Date of First Confirmed Death
    gen m04_`country'1 = m04 if iso=="`country'"
    egen m04_`country'2 = min(m04_`country'1)
    local m04_`country' : disp %tdDD_Month m04_`country'2
    global m04_`country' : disp %tdDD_Month m04_`country'2

    ** METRIC 05
    ** Days since first confirmed case
    gen m05_`country'1 = m05 if iso=="`country'"
    egen m05_`country'2 = min(m05_`country'1)
    local m05_`country' = m05_`country'2
    global m05_`country' = m05_`country'2

    ** METRIC 06
    ** Days since first confirmed death
    gen m06_`country'1 = m06 if iso=="`country'"
    egen m06_`country'2 = min(m06_`country'1)
    global m06_`country' = m06_`country'2

    ** METRICS 20-29:
    ** Number of days until N=XX Cases
    local metric20 = 20
    forval metric20 = 20(1)29 {
        gen diff_`country'1 = m`metric20' if iso=="`country'"
        egen diff_`country'2 = min(diff_`country'1)
        local m`metric20'_`country' = diff_`country'2
        global m`metric20'_`country' = diff_`country'2
        drop diff_*
    }
    ** METRICS 40-49:
    ** Number of days until N=XX Deaths
    forval metric40 = 40(1)49 {
        gen diff_`country'1 = m`metric40' if iso=="`country'"
        egen diff_`country'2 = min(diff_`country'1)
        local m`metric40'_`country' = diff_`country'2
        global m`metric40'_`country' = diff_`country'2
        drop diff_*
    }

    ** METRIC 60:
    ** 1 DAY INCREASE in CASES
    sort iso date 
    gen t1 = total_cases - total_cases[_n-1] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m60_`country' = t2 
    global m60_`country' = t2 
    drop t1 t2

    ** METRIC 61:
    ** 1 DAY INCREASE in DEATHS
    sort iso date 
    gen t1 = total_deaths - total_deaths[_n-1] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m61_`country' = t2 
    global m61_`country' = t2 
    drop t1 t2

    ** METRIC 62:
    ** 7 DAY INCREASE in CASES
    sort iso date 
    gen t1 = total_cases - total_cases[_n-7] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m62_`country' = t2
    global m62_`country' = t2
    drop t1 t2 

    ** METRIC 63:
    ** 7 DAY INCREASE in DEATHS
    sort iso date 
    gen t1 = total_deaths - total_deaths[_n-7] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m63_`country' = t2
    global m63_`country' = t2
    drop t1 t2 

    ** METRIC 64:
    ** 14 DAY INCREASE in CASES
    sort iso date 
    gen t1 = total_cases - total_cases[_n-14] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m64_`country' = t2
    global m64_`country' = t2
    drop t1 t2 

    ** METRIC 65:
    ** 14 DAY INCREASE in DEATHS
    sort iso date 
    gen t1 = total_deaths - total_deaths[_n-14] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m65_`country' = t2
    global m65_`country' = t2
    drop t1 t2 

    ** METRIC 66:
    ** 21 DAY INCREASE in CASES
    sort iso date 
    gen t1 = total_cases - total_cases[_n-21] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m66_`country' = t2
    global m66_`country' = t2
    drop t1 t2 

    ** METRIC 67:
    ** 21 DAY INCREASE in DEATHS
    sort iso date 
    gen t1 = total_deaths - total_deaths[_n-21] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m67_`country' = t2
    global m67_`country' = t2
    drop t1 t2 

    ** METRIC 72:
    ** DOUBLING RATE in CASES
    sort iso date 
    gen i1 = 0
    replace i1 = 1 if iso!=iso[_n+1]
    gen m72_`country'1 = int(m72) if i1==1 & iso=="`country'"
    egen m72_`country'2 = min(m72_`country'1) 
    local m72_`country' = m72_`country'2
    global m72_`country' = m72_`country'2
    drop i1 
    **m72_`country'1 m72_`country'2

    ** METRIC 73:
    ** DOUBLING RATE in DEATHS
    sort iso date 
    gen i1 = 0
    replace i1 = 1 if iso!=iso[_n+1]
    gen m73_`country'1 = int(m73) if i1==1 & iso=="`country'"
    egen m73_`country'2 = min(m73_`country'1) 
    local m73_`country' = m73_`country'2
    global m73_`country' = m73_`country'2
    drop i1 
    **m73_`country'1 m73_`country'2

}

** CARICOM (N=20 countries)

** METRIC 01 
** CURRENT CONFIRMED CASES across region
global m01caricom =  $m01_ATG + $m01_BHS + $m01_BRB + $m01_BLZ + $m01_DMA + $m01_GRD + $m01_GUY ///
            + $m01_HTI + $m01_JAM + $m01_KNA + $m01_LCA + $m01_VCT + $m01_SUR + $m01_TTO        ///
            + $m01_AIA + $m01_BMU + $m01_VGB + $m01_CYM + $m01_MSR + $m01_TCA

** METRIC 02
** CURRENT CONFIRMED DEATHS across region
global m02caricom =  $m02_ATG + $m02_BHS + $m02_BRB + $m02_BLZ + $m02_DMA + $m02_GRD + $m02_GUY ///
            + $m02_HTI + $m02_JAM + $m02_KNA + $m02_LCA + $m02_VCT + $m02_SUR + $m02_TTO        ///
            + $m02_AIA + $m02_BMU + $m02_VGB + $m02_CYM + $m02_MSR + $m02_TCA

** METRIC 60
** Cases in past 1-day across region 
global m60caricom =  $m60_ATG + $m60_BHS + $m60_BRB + $m60_BLZ + $m60_DMA + $m60_GRD + $m60_GUY ///
            + $m60_HTI + $m60_JAM + $m60_KNA + $m60_LCA + $m60_VCT + $m60_SUR + $m60_TTO        ///
            + $m60_AIA + $m60_BMU + $m60_VGB + $m60_CYM + $m60_MSR + $m60_TCA

** METRIC 61
** Deaths in past 1-day across region 
global m61caricom =  $m61_ATG + $m61_BHS + $m61_BRB + $m61_BLZ + $m61_DMA + $m61_GRD + $m61_GUY ///
            + $m61_HTI + $m61_JAM + $m61_KNA + $m61_LCA + $m61_VCT + $m61_SUR + $m61_TTO        ///
            + $m61_AIA + $m61_BMU + $m61_VGB + $m61_CYM + $m61_MSR + $m61_TCA

** METRIC 62
** Cases in past 7-days across region 
global m62caricom =  $m62_ATG + $m62_BHS + $m62_BRB + $m62_BLZ + $m62_DMA + $m62_GRD + $m62_GUY ///
            + $m62_HTI + $m62_JAM + $m62_KNA + $m62_LCA + $m62_VCT + $m62_SUR + $m62_TTO        ///
            + $m62_AIA + $m62_BMU + $m62_VGB + $m62_CYM + $m62_MSR + $m62_TCA


** METRIC 63
** Deaths in past 7-days across region 
global m63caricom =  $m63_ATG + $m63_BHS + $m63_BRB + $m63_BLZ + $m63_DMA + $m63_GRD + $m63_GUY ///
            + $m63_HTI + $m63_JAM + $m63_KNA + $m63_LCA + $m63_VCT + $m63_SUR + $m63_TTO        ///
            + $m63_AIA + $m63_BMU + $m63_VGB + $m63_CYM + $m63_MSR + $m63_TCA

** METRIC 64
** Cases in past 14-days across region 
global m64caricom =  $m64_ATG + $m64_BHS + $m64_BRB + $m64_BLZ + $m64_DMA + $m64_GRD + $m64_GUY ///
            + $m64_HTI + $m64_JAM + $m64_KNA + $m64_LCA + $m64_VCT + $m64_SUR + $m64_TTO        ///
            + $m64_AIA + $m64_BMU + $m64_VGB + $m64_CYM + $m64_MSR + $m64_TCA

** METRIC 65
** Deaths in past 14-days across region 
global m65caricom =  $m65_ATG + $m65_BHS + $m65_BRB + $m65_BLZ + $m65_DMA + $m65_GRD + $m65_GUY ///
            + $m65_HTI + $m65_JAM + $m65_KNA + $m65_LCA + $m65_VCT + $m65_SUR + $m65_TTO        ///
            + $m65_AIA + $m65_BMU + $m65_VGB + $m65_CYM + $m65_MSR + $m65_TCA

** METRIC 66
** Cases in past 21-days across region 
global m66caricom =  $m66_ATG + $m66_BHS + $m66_BRB + $m66_BLZ + $m66_DMA + $m66_GRD + $m66_GUY ///
            + $m66_HTI + $m66_JAM + $m66_KNA + $m66_LCA + $m66_VCT + $m66_SUR + $m66_TTO        ///
            + $m66_AIA + $m66_BMU + $m66_VGB + $m66_CYM + $m66_MSR + $m66_TCA

** METRIC 67
** Deaths in past 21-days across region 
global m67caricom =  $m67_ATG + $m67_BHS + $m67_BRB + $m67_BLZ + $m67_DMA + $m67_GRD + $m67_GUY ///
            + $m67_HTI + $m67_JAM + $m67_KNA + $m67_LCA + $m67_VCT + $m67_SUR + $m67_TTO        ///
            + $m67_AIA + $m67_BMU + $m67_VGB + $m67_CYM + $m67_MSR + $m67_TCA


keep country iso iso_num pop date new_cases new_deaths total_cases total_deaths elapsed
order country iso iso_num pop date new_cases new_deaths total_cases total_deaths elapsed 


** Save 
local c_date = c(current_date)
local date_string = subinstr("`c_date'", " ", "", .)
** save "`datapath154'\version01\2-working\covid_daily_surveillance_`date_string'", replace
save "`datapath'\covid_daily_surveillance_`date_string'", replace


