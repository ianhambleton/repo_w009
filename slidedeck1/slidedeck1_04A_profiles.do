** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    slidedeck1_04A_profiles.do
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
    log using "`logpath'\slidedeck1_04A_profiles", replace
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
    lowess rcase_av_3 date, bwidth(0.1) gen(lowess_3) nograph
    lowess rcase_av_7 date, bwidth(0.1) gen(lowess_7) nograph
    lowess rcase_av_14 date, bwidth(0.1) gen(lowess_14) nograph

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
        lowess rcase_av_7 date if iso=="`country'", bwidth(0.1) gen(lowess_7_`country') name(low7_`country') nograph
        lowess rcase_av_3 date if iso=="`country'", bwidth(0.1) gen(lowess_3_`country') name(low3_`country') nograph
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
** 3. Cases in past 28 days
** 4. Deaths in past 28 days
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
    bysort iso : egen hrate = max(lowess_7) 

** X-axis origin
gen x0 = 0 
sort iso date 

** -------------------------------------------
** THE GRAPHIC
** -------------------------------------------

** Graphics for 2021 only
keep if date >= 22281

local clist "AIA ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB CAR"
foreach country of local clist {
    
preserve
    keep if iso=="`country'"
    global cname_`country' = country

** COLORS - PURPLES for CVD
    colorpalette sfso, red nograph
    local list r(p) 
    ** Age groups
    local red1 `r(p1)'  
    local red2 `r(p2)'    
    local red3 `r(p3)'    
    local red4 `r(p4)'    
    local red5 `r(p5)'  
    local red6 `r(p6)'
** COLORS - W3 flat colors
    colorpalette w3 flat, nograph
    local list r(p) 
    ** Age groups
    local gre `r(p7)'
    local blu `r(p8)'  
    local pur `r(p9)'
    local yel `r(p11)'
    local ora `r(p12)'    
    local red `r(p13)'       
    local gry `p(p19)'   

    ** OUTLINE BORDERS
    ** These outlines needs to be above the maximum of the y-axis
        ** GRAPHIC outer box
        global maxy = hrate 
        sort date 
        egen minx = min(date)
        global minx = minx
        drop minx
        sort date 

    ** TEXT POSITIONS
        ** Total Cases
        global xdiff = $maxx - $minx 
        global ydiff = $metricy - $maxy 
        global xpos1 = $minx + (0.1 * ($xdiff/4))
        global ypos1 = $metricy - (1 * ($ydiff/4))

        ** DATE
        local c_date = c(current_date)
        local date_string2 = subinstr("`c_date'", " ", " ", .)

        #delimit ;
            gr twoway 

                /// CARICOM average
                (line lowess_3 date if iso=="`country'" & date>=22281 & lowess_14>=0, sort lc("gs8") lw(0.4) lp("-"))
                (rarea x0 lowess_3 date if iso=="`country'" & date>=22281  & lowess_14>=0, sort col("`pur'%40") lw(none))         
    
                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    bgcolor(white) 
                    ysize(6) xsize(15)
                
                    xlab(none
                    , 
                    labs(4) notick nogrid glc(gs16))
                    xscale(noline) 
                    xtitle("", size(4) margin(l=2 r=2 t=4 b=2)) 
                    
                    ylab(none   
                    ,
                    labs(4) nogrid notick glc(gs16) angle(0) format(%9.0f))
                    ytitle("", size(4) margin(l=2 r=2 t=2 b=2)) 
                    yscale(noline) 
                    ///ytick(0(5)50)

                    /// text($maxy $minx "${cname_`country'}"         ,  place(e) size(10) color(gs0) just(left))


                    legend(off)
                    name(cr_`country') 
                    ;
            #delimit cr
            graph export "`outputpath'/caserate_spark_`country'.png", replace width(4000) 
            ** graph export "`webpath'/caserate_`country'.jpg", replace width(3000) quality(100)
            global cname = country
    restore

}
