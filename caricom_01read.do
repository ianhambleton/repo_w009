** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_01read.do
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
    log using "`logpath'\caricom_01read", replace
** HEADER -----------------------------------------------------

** PRIMARY DATA SOURCE
** DATA DRAWN FROM OWID
** https://ourworldindata.org/
** COVID datasets hosted on GitHub 
** https://github.com/owid/covid-19-data
** -------------------------------------
** SECONDARY DATA SOURCE
** European Centre for Disease Control
** https://opendata.ecdc.europa.eu/covid19/casedistribution/csv
** -------------------------------------
** SECONDARY DATA SOURCE
** Johns Hopkins 
** https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/
** -------------------------------------



** Data Source A1 - OWID full dataset
    python: import pandas as full_csv
    python: full_df = full_csv.read_csv('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv')
    cd "`datapath'"
    python: full_df.to_stata('full_owid.dta')

/// ** Does data for latest data exist
/// ** IF NOT - stop program, and report error code
/// preserve
///     use "`datapath'\full_owid", clear
///     local t1 = c(current_date)
///     gen today = d("`t1'")
///     gen yesterday = today - 1
///     format today %tdNN/DD/CCYY
///     format yesterday %tdNN/DD/CCYY
///     rename date date_orig 
///     gen date = date(date_orig, "YMD", 2020)
///     format date %tdNN/DD/CCYY
///     drop date_orig
///     order date 
///     egen today_dataset = max(date)
///     format today_dataset %tdNN/DD/CCYY
///     if (today_dataset < yesterday ) {
///         dis as error "The data for today ($S_DATE) are not yet available."
///         exit 301
///     }
/// restore 

/// ** Data Source B1 - ECDC counts
/// cap{
///     python: import pandas as count_csv
///     python: count_df2 = count_csv.read_csv('https://opendata.ecdc.europa.eu/covid19/casedistribution/csv')
///     cd "`datapath'"
///     python: count_df2.to_stata('count_ecdc.dta')
///     }
   
** Data Source C1 - JohnsHopkins counts
** Longer import time - includes US county-level data - much larger dataset
** We import this dataset for the UKOTS

** Loading 2020 COVID surveillance data
** This is historical
** RAN on 12-Sep-2021
** So commented out to speed up the daily operation
/// local URL = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"
/// forvalues month = 1/12 {
///    forvalues day = 1/31 {
///       local month = string(`month', "%02.0f")
///       local day = string(`day', "%02.0f")
///       local year = "2020"
///       local today = "`month'-`day'-`year'"
///       local FileName = "`URL'`today'.csv"
///       clear
///       capture import delimited "`FileName'"
///       capture confirm variable ïprovincestate
///       if _rc == 0 {
///          rename ïprovincestate provincestate
///          label variable provincestate "Province/State"
///       }
///       capture rename province_state provincestate
///       capture rename country_region countryregion
///       capture rename last_update lastupdate
///       capture rename lat latitude
///       capture rename long longitude
///       generate tempdate = "`today'"
///       capture save "`today'", replace
///    }
/// }
/// clear
/// forvalues month = 1/12 {
///    forvalues day = 1/31 {
///       local month = string(`month', "%02.0f")
///       local day = string(`day', "%02.0f")
///       local year = "2020"
///       local today = "`month'-`day'-`year'"
///       capture append using "`today'"
///    }
/// }
/// save "`datapath'\jh_time_series2020", replace


** Loading 2021 COVID surveillance data
** We split this into blocks to minimise the daily operation
** Chunk: Running 2021 from JAN (01) to JUN (06)
/// local URL = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"
/// forvalues month = 1/6 {
///    forvalues day = 1/31 {
///       local month = string(`month', "%02.0f")
///       local day = string(`day', "%02.0f")
///       local year = "2021"
///       local today = "`month'-`day'-`year'"
///       local FileName = "`URL'`today'.csv"
///       clear
///       capture import delimited "`FileName'"
///       capture confirm variable ïprovincestate
///       if _rc == 0 {
///          rename ïprovincestate provincestate
///          label variable provincestate "Province/State"
///       }
///       capture rename province_state provincestate
///       capture rename country_region countryregion
///       capture rename last_update lastupdate
///       capture rename lat latitude
///       capture rename long longitude
///       generate tempdate = "`today'"
///       capture save "`today'", replace
///    }
/// }
/// clear
/// forvalues month = 1/6 {
///    forvalues day = 1/31 {
///       local month = string(`month', "%02.0f")
///       local day = string(`day', "%02.0f")
///       local year = "2021"
///       local today = "`month'-`day'-`year'"
///       capture append using "`today'"
///    }
/// }
/// save "`datapath'\jh_time_series2021_jan_jun", replace


** Loading 2021 COVID surveillance data
** We split this into blocks to minimise the daily operation
** Chunk: Running 2021 from JUL (07) to DEC (12)
local URL = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"
forvalues month = 7/12 {
   forvalues day = 1/31 {
      local month = string(`month', "%02.0f")
      local day = string(`day', "%02.0f")
      local year = "2021"
      local today = "`month'-`day'-`year'"
      local FileName = "`URL'`today'.csv"
      clear
      capture import delimited "`FileName'"
      capture confirm variable ïprovincestate
      if _rc == 0 {
         rename ïprovincestate provincestate
         label variable provincestate "Province/State"
      }
      capture rename province_state provincestate
      capture rename country_region countryregion
      capture rename last_update lastupdate
      capture rename lat latitude
      capture rename long longitude
      generate tempdate = "`today'"
      capture save "`today'", replace
   }
}
clear
forvalues month = 7/12 {
   forvalues day = 1/31 {
      local month = string(`month', "%02.0f")
      local day = string(`day', "%02.0f")
      local year = "2021"
      local today = "`month'-`day'-`year'"
      capture append using "`today'"
   }
}
save "`datapath'\jh_time_series2021_jul_dec", replace


** Join the JH files
use "`datapath'\jh_time_series2020", clear
append using "`datapath'\jh_time_series2021_jan_jun"
append using "`datapath'\jh_time_series2021_jul_dec"
save "`datapath'\jh_time_series_full", replace



tempfile TCA AIA BMU CYM MSR VGB
** 18-jun-2020
** We keep UKOTS from JH dataset for appending to ECDC/OWID
** TCA has been missing in ECDC data since 18-Jun-2020. Reason unknown. No response to email enquiry.
** We have included an IF-ASSERT statement to allow for the 
** re-appearance of TCA in ECDC in a later edition

**TCA
 use "`datapath'\jh_time_series_full", clear 
    keep if provincestate=="Turks and Caicos Islands" 
    ** Match JH format to OWID format before appending
    generate date = date(tempdate, "MDY")
    format date %tdNN/DD/CCYY
    drop tempdate 
    rename provincestate location 
    rename confirmed total_cases
    rename deaths total_deaths 
    * Fix data error (1-Apr-2020). Recorded as 6, should be 5
    *replace total_cases = total_cases[_n+1] if total_cases>total_cases[_n+1] 
    * Two new variables - daily cases and deaths
    sort date 
    *by location: gen new_cases = total_cases - total_cases[_n-1]
    gen new_cases = total_cases - total_cases[_n-1]
    replace new_cases = total_cases if new_cases==. & _n==1 
    gen new_deaths = total_deaths - total_deaths[_n-1]
    replace new_deaths = total_deaths if new_deaths==. & _n==1
    keep date location new_cases new_deaths total_cases total_deaths
    save `TCA', replace

**AIA
use "`datapath'\jh_time_series_full", clear 
keep if provincestate=="Anguilla" 
    ** Match JH format to OWID format before appending
    generate date = date(tempdate, "MDY")
    format date %tdNN/DD/CCYY
    drop tempdate 
    rename provincestate location 
    rename confirmed total_cases
    rename deaths total_deaths 
    * Two new variables - daily cases and deaths
    sort date 
    *by location: gen new_cases = total_cases - total_cases[_n-1]
    gen new_cases = total_cases - total_cases[_n-1]
    replace new_cases = total_cases if new_cases==. & _n==1 
    gen new_deaths = total_deaths - total_deaths[_n-1]
    replace new_deaths = total_deaths if new_deaths==. & _n==1
    keep date location new_cases new_deaths total_cases total_deaths
    save `AIA', replace

    **BMU
 use "`datapath'\jh_time_series_full", clear 
keep if provincestate=="Bermuda"
    ** Match JH format to OWID format before appending
    generate date = date(tempdate, "MDY")
    format date %tdNN/DD/CCYY
    drop tempdate 
    rename provincestate location 
    rename confirmed total_cases
    rename deaths total_deaths 
    * Two new variables - daily cases and deaths
    sort date 
    *by location: gen new_cases = total_cases - total_cases[_n-1]
    gen new_cases = total_cases - total_cases[_n-1]
    replace new_cases = total_cases if new_cases==. & _n==1 
    gen new_deaths = total_deaths - total_deaths[_n-1]
    replace new_deaths = total_deaths if new_deaths==. & _n==1
    keep date location new_cases new_deaths total_cases total_deaths
    save `BMU', replace


       **CYM
        use "`datapath'\jh_time_series_full", clear 
keep if provincestate=="Cayman Islands" 
    ** Match JH format to OWID format before appending
    generate date = date(tempdate, "MDY")
    format date %tdNN/DD/CCYY
    drop tempdate 
    rename provincestate location 
    rename confirmed total_cases
    rename deaths total_deaths 
    * Two new variables - daily cases and deaths
    sort date 
    *by location: gen new_cases = total_cases - total_cases[_n-1]
    gen new_cases = total_cases - total_cases[_n-1]
    replace new_cases = total_cases if new_cases==. & _n==1 
    gen new_deaths = total_deaths - total_deaths[_n-1]
    replace new_deaths = total_deaths if new_deaths==. & _n==1
    keep date location new_cases new_deaths total_cases total_deaths
    save `CYM', replace

 **MSR
  use "`datapath'\jh_time_series_full", clear 
keep if provincestate=="Montserrat" 
    ** Match JH format to OWID format before appending
    generate date = date(tempdate, "MDY")
    format date %tdNN/DD/CCYY
    drop tempdate 
    rename provincestate location 
    rename confirmed total_cases
    rename deaths total_deaths 
    * Two new variables - daily cases and deaths
    sort date 
    *by location: gen new_cases = total_cases - total_cases[_n-1]
    gen new_cases = total_cases - total_cases[_n-1]
    replace new_cases = total_cases if new_cases==. & _n==1 
    gen new_deaths = total_deaths - total_deaths[_n-1]
    replace new_deaths = total_deaths if new_deaths==. & _n==1
    keep date location new_cases new_deaths total_cases total_deaths
    save `MSR', replace


     **VGB
      use "`datapath'\jh_time_series_full", clear 
keep if provincestate=="British Virgin Islands" 
    ** Match JH format to OWID format before appending
    generate date = date(tempdate, "MDY")
    format date %tdNN/DD/CCYY
    drop tempdate 
    rename provincestate location 
    rename confirmed total_cases
    rename deaths total_deaths 
    * Two new variables - daily cases and deaths
    sort date 
    *by location: gen new_cases = total_cases - total_cases[_n-1]
    gen new_cases = total_cases - total_cases[_n-1]
    replace new_cases = total_cases if new_cases==. & _n==1 
    gen new_deaths = total_deaths - total_deaths[_n-1]
    replace new_deaths = total_deaths if new_deaths==. & _n==1
    keep date location new_cases new_deaths total_cases total_deaths
    save `VGB', replace

**----------------------------------------------------------------------------

use "`datapath'\full_owid", clear

rename date date_orig 
gen date = date(date_orig, "YMD", 2020)
format date %tdNN/DD/CCYY
drop date_orig
order date 
sort location date 

******************
** Temp fix on 18-jun-2020 (updated 14Dec2020 to include other UKOTS)
** Append JH data if TCA does not exist
** Included as TCA has been lost from ECDC web data 
** Assert should not highlight any TCA entries (_rc will equal 0 - ie no error)

*added 15-Feb-2021, as TCA data have started to be added to OWID but the fields are blank
drop if iso_code=="TCA"
    capture assert iso !="TCA"
    ** Append JH data if assert condition met
    if _rc == 0 {
        append using `TCA'
        replace iso = "TCA" if iso=="" & location=="Turks and Caicos Islands"
        replace population = 42953 if population==. & location=="Turks and Caicos Islands"
             }

**AIA
*added 13-Fev-2021, as AIA data have started to be added to OWID but the fields are blank
drop if iso_code=="AIA"
 capture assert iso !="AIA"
    ** Append JH data if assert condition met
    if _rc == 0 {
        append using `AIA'
        replace iso = "AIA" if iso=="" & location=="Anguilla"
        replace population = 15002 if population==. & location=="Anguilla"
             }

**BMU
*added 13-Fev-2021, as Bermuda data have started to be added to OWID but the fields are blank
drop if iso_code=="BMU"

 capture assert iso !="BMU"
    ** Append JH data if assert condition met
    if _rc == 0 {
        append using `BMU'
        replace iso = "BMU" if iso=="" & location=="Bermuda"
        replace population = 62273 if population==. & location=="Bermuda"
             }

**CYM
*added 13-Feb-2021, as Cayman islands data have started to be added to OWID but the fields are blank
drop if iso_code=="CYM"

 capture assert iso !="CYM"
    ** Append JH data if assert condition met
    if _rc == 0 {
        append using `CYM'
        replace iso = "CYM" if iso=="" & location=="Cayman Islands"
        replace population = 65720 if population==. & location=="Cayman Islands"
             }

**MSR
*added 13-Feb-2021, as MSR data have started to be added to OWID but the fields are blank
drop if iso_code=="MSR"
 capture assert iso !="MSR"
    ** Append JH data if assert condition met
    if _rc == 0 {
        append using `MSR'
        replace iso = "MSR" if iso=="" & location=="Montserrat"
        replace population = 4999 if population==. & location=="Montserrat"
             }             

**VGB
*added 13-Feb-2021, as Bermuda data have started to be added to OWID but the fields are blank
drop if iso_code=="VGB"
 capture assert iso !="VGB"
    ** Append JH data if assert condition met
    if _rc == 0 {
        append using `VGB'
        replace iso = "VGB" if iso=="" & location=="British Virgin Islands"
        replace population = 30237 if population==. & location=="British Virgin Islands"
             }   


** 19-Jun-2020
** ERROR correction 
** 08-Apr-2020 NZL has 8 identical entries 
** Otehr countries are affected by this error - not sure why the imported dataset would have dups like this
** To investigate (at some point!) 
bysort iso date: gen dups = _n 
drop if dups>1 
drop dups 

** TEXT NAME FOR COUNTRY (STRING)
rename location countryregion 
** POPULATION
rename population pop

** Save out the dataset for next DO file
/// rename iso_code iso 
/// keep countryregion iso pop date new_cases new_deaths total_cases total_deaths 
/// order countryregion iso pop date new_cases new_deaths total_cases total_deaths 
/// gsort countryregion -date 
/// save "`datapath'\owid_time_series", replace

** Added 18-Jun-2020
** Save a daily backup of the data
local c_date = c(current_date)
local date_string = subinstr("`c_date'", " ", "", .)
keep iso date new_cases new_deaths total_cases total_deaths country pop
save "`datapath'\owid_time_series_`date_string'", replace
