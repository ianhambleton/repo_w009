** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_02initialprep.do
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
    log using "`logpath'\caricom_02initialprep", replace
** HEADER -----------------------------------------------------

** RUN covidprofiles_002_jhopkins.do BEFORE this algorithm
local c_date = c(current_date)
local date_string = subinstr("`c_date'", " ", "", .)
use "`datapath'\owid_time_series_`date_string'", clear 


** RESTRICT TO SELECTED COUNTRIES
** We keep 14 CARICOM countries:    --> ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO
** We keep 6 UKOTS                  --> AIA BMU VGB CYM MSR TCA 
** + Cuba                           --> CUB
** + Dominican Republic             --> DOM
#delimit ;
keep if
    iso_code == "AIA" |
    iso_code == "ATG" |
    iso_code == "BHS" |
    iso_code == "BRB" |
    iso_code == "BLZ" |
    iso_code == "BMU" |
    iso_code == "VGB" |
    iso_code == "CYM" |
    iso_code == "CUB" |
    iso_code == "DMA" |
    iso_code == "DOM" |
    iso_code == "GRD" |
    iso_code == "GUY" |
    iso_code == "HTI" |
    iso_code == "JAM" |
    iso_code == "MSR" |
    iso_code == "KNA" |
    iso_code == "LCA" |
    iso_code == "VCT" |
    iso_code == "SUR" |
    iso_code == "TCA" |
    iso_code == "TTO" |

    iso_code == "NZL" |
    iso_code == "SGP" |
    iso_code == "ISL" |
    iso_code == "FJI" |
    iso_code == "VNM" |
    iso_code == "KOR" |
    iso_code == "ITA" |
    iso_code == "GBR" |
    iso_code == "DEU" |
    iso_code == "SWE" |

    iso_code == "CRI" |
    iso_code == "SLV" |
    iso_code == "GTM" |
    iso_code == "HND" |
    iso_code == "MEX" |
    iso_code == "NIC" |
    iso_code == "PAN" |

    iso_code == "ARG" |
    iso_code == "BOL" |
    iso_code == "BRA" |
    iso_code == "CHL" |
    iso_code == "COL" |
    iso_code == "ECU" |
    iso_code == "PRY" |
    iso_code == "PER" |
    iso_code == "URY" |
    iso_code == "VEN" 
    ;
#delimit cr

** Sort the dataset, ready for morning manual review 
sort iso date

** ---------------------------------------------------------
** FINAL PREPARATION
** ---------------------------------------------------------
rename iso_code iso

preserve
    tempfile tto 
    keep if iso=="TTO"
    replace iso="TTO2"
    save `tto', replace
restore


** Create internal numeric variable for countries 
encode iso, gen(iso_num)
order iso_num pop, after(iso)

** CARICOM (14), UKOT (6), OTHER (2), COMPARATOR (10)
gen cgroup = .
replace cgroup = 1 if iso=="ATG" | iso=="BHS" | iso=="BRB" | iso=="BLZ" | iso=="DMA" | iso=="GRD" | iso=="GUY" | iso=="HTI" | iso=="JAM" | iso=="KNA" | iso=="LCA" | iso=="VCT" | iso=="SUR" | iso=="TTO" 
replace cgroup = 2 if iso=="AIA" | iso=="BMU" | iso=="VGB" | iso=="CYM" | iso=="MSR" | iso=="TCA"
replace cgroup = 3 if iso=="CUB" | iso=="DOM"
replace cgroup = 4 if iso=="NZL" | iso=="SGP" | iso=="ISL" | iso=="FJI" | iso=="VNM" | iso=="KOR" | iso=="ITA" | iso=="GBR" | iso=="DEU" | iso=="SWE"
replace cgroup = 5 if iso=="CRI" | iso=="SLV" | iso=="GTM" | iso=="HND" | iso=="MEX" | iso=="NIC" | iso=="PAN"
replace cgroup = 6 if iso=="ARG" | iso=="BOL" | iso=="BRA" | iso=="CHL" | iso=="COL" | iso=="ECU" | iso=="PRY" | iso=="PER" | iso=="URY" | iso=="VEN"
label define cgroup_ 1 "caricom" 2 "ukot" 3 "car-other" 4 "comparator" 5 "central america" 6 "south america"
label values cgroup cgroup_ 

** Fill-in missing data 
replace new_deaths = 0 if new_deaths==. 
replace total_deaths = 0 if total_deaths==. 

** ALL COVID
** This dataset includes the comparator countries
** Save the cleaned and restricted dataset
drop if cgroup==5 | cgroup==6
save "`datapath'\all_covid", replace


** Keep just the Caribbean right now AND regroup
keep if cgroup==1 | cgroup==2 | cgroup==3
gen group = 1 if cgroup==1 | cgroup==2
replace group = 2 if cgroup==3
label define group_ 1 "caricom" 2 "latin caribbean"
label values group group_


** Save the cleaned and restricted dataset
save "`datapath'\caricom_covid", replace
