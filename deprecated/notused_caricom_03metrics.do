** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_03figure.do
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
    log using "`logpath'\caricom_03figure", replace
** HEADER -----------------------------------------------------

** JH time series COVD-19 data 
** RUN covidprofiles_002_jhopkins.do BEFORE this algorithm
use "`datapath'\caricom_covid", clear


** ---------------------------------------------------
** THE METRICS
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
**
** METRIC 70: Growth rate in cases
** METRIC 71: Growth rate in deaths 
** METRIC 72: Doubling time in cases
** METRIC 73: Doubling time in deaths
** ---------------------------------------------------

** METRIC 01 : CURRENT CONFIRMED CASES BY COUNTRY 
bysort iso: egen m01 = max(confirmed)
** METRIC 02: CURRENT CONFIRMED DEATHS BY COUNTRY 
bysort iso: egen m02 = max(deaths)
** METRIC 03: The DATE OF FIRST CONFIRMED CASE
bysort iso: egen m03 = min(date)
format m03 %td 
** METRIC 04: The DATE OF FIRST CONFIRMED DEATH
gen deaths_i = 0 
replace deaths_i = 1 if deaths>0 
bysort iso deaths_i: egen m04t = min(date) if deaths_i==1
bysort iso: egen m04 = min(m04t)
format m04 %td 
** METRIC 05: Days since first reported case
sort iso date 
bysort iso: gen elapsed = _n 
bysort iso: egen m05 = max(elapsed)
** METRIC 06: Days since first reported death
sort iso date 
bysort iso deaths_i: gen elapsedd = _n
bysort iso deaths_i: egen m06t = max(elapsedd)
replace m06t = . if deaths_i==0 
bysort iso: egen m06 = min(m06t)
replace m06 = 0 if m06==. 

** METRICS 20-29: DAYS UNTIL N=X CASES
local metric = 20 
local numv = "25 50 100 200 400 800 1600 3200 6400 12800"
foreach num of local numv {
sort iso date 
gen t`num' = date if confirmed>=`num' & confirmed[_n-1]<`num'
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
gen t`num' = date if deaths>=`num' & deaths[_n-1]<`num'
bysort iso: egen d`num' = min(t`num')
gen m`metric' = d`num' - m03 
drop t`num' d`num'
local metric = `metric'+1
}

** METRIC 70 and 71:
** Growth rate - Cases / Deaths
sort iso date 
gen m70  = log(confirmed/confirmed[_n-1]) if iso==iso[_n-1] 
gen m71 = log(deaths/deaths[_n-1]) if iso==iso[_n-1] 

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
local clist "AIA ATG BHS BLZ BMU BRB CUB CYM DMA DOM GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB NZL SGP ISL FJI VNM KOR ITA GBR DEU SWE CRI SLV GTM HND MEX NIC PAN ARG BOL BRA CHL COL ECU PRY PER URY VEN"
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
    gen t1 = confirmed - confirmed[_n-1] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m60_`country' = t2 
    global m60_`country' = t2 
    drop t1 t2

    ** METRIC 61:
    ** 1 DAY INCREASE in DEATHS
    sort iso date 
    gen t1 = deaths - deaths[_n-1] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m61_`country' = t2 
    global m61_`country' = t2 
    drop t1 t2

    ** METRIC 62:
    ** 7 DAY INCREASE in CASES
    sort iso date 
    gen t1 = confirmed - confirmed[_n-7] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m62_`country' = t2
    global m62_`country' = t2
    drop t1 t2 

    ** METRIC 63:
    ** 7 DAY INCREASE in DEATHS
    sort iso date 
    gen t1 = deaths - deaths[_n-7] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m63_`country' = t2
    global m63_`country' = t2
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

drop if confirmed==0 

drop m* deaths_i dr_cases dr_deaths
order iso iso_num pop date confirmed deaths recovered elapsed elapsedd

** Save the metrics dataset
save "`datapath'\version02\2-working\caricom_covid_metrics", replace
