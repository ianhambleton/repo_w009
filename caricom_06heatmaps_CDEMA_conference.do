** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_06heatmaps.do
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

    ** DO FILEPATH
    local dopath "X:\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w009"

    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w009\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w009\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w009\outputs"

    ** ianhambleton.com: WEBSITE outputs
    local webpath "X:\OneDrive - The University of the West Indies\repo_ianhambleton\website-ianhambleton-2023\static\uploads"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\caricom_06heatmaps", replace
** HEADER -----------------------------------------------------


** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`dopath'\caricom_04metrics3"
rename country cname
** -----------------------------------------

** Country Labels
** Labelling of the internal country numeric
#delimit ; 
label define cname_ 
1                          "Anguilla"
3               "Antigua and Barbuda"
4                           "Bahamas"
5                            "Belize"
6                           "Bermuda"
9                          "Barbados"
13                              "Cuba"
14                    "Cayman Islands"
16                        "Dominica"
17               "Dominican Republic"
21                          "Grenada"
23                           "Guyana"
25                            "Haiti"
28                          "Jamaica"
29            "Saint Kitts and Nevis"
31                      "Saint Lucia"
33                       "Montserrat"
41                         "Suriname"
43         "Turks and Caicos Islands"
44              "Trinidad and Tobago"
46 "Saint Vincent and the Grenadines"
48            "British Virgin Islands"
1000            "CARICOM"
                     ;
#delimit cr 

** COUNTRY RESTRICTION: CARICOM countries only (N=20)
#delimit ; 
    keep if 
        iso=="AIA" |
        iso=="ATG" |
        iso=="BHS" |
        iso=="BRB" |
        iso=="BLZ" |
        iso=="BMU" |
        iso=="VGB" |
        iso=="CYM" |
        iso=="DMA" |
        iso=="GRD" |
        iso=="GUY" |
        iso=="HTI" |
        iso=="JAM" |
        iso=="MSR" |
        iso=="KNA" |
        iso=="LCA" |
        iso=="VCT" |
        iso=="SUR" |
        iso=="TTO" |
        iso=="TCA";
#delimit cr    

rename tcase total_cases
rename tdeath total_deaths

** Keep selected variables
decode iso_num, gen(country2)


keep iso_num pop date case total_cases rcase rcase_av_7 rcase_av_14 lowess_14 death total_deaths 
rename case metric1
rename total_cases metric2
rename rcase_av_7 metric3
rename death metric4 
rename total_deaths metric5
reshape long metric, i(iso_num pop date) j(mtype)
label define mtype_ 1 "new cases" 2 "total cases" 3 "case rate" 4 "new deaths" 5 "total deaths", replace 
label values mtype mtype_
sort iso_num mtype date 

** Automate final date on x-axis 
** Use latest date in dataset 
egen fdate1 = max(date)
global fdate = fdate1 
global fdatef : di %tdD_m date("$S_DATE", "DMY")
** Graphics numeric running from 1 to 20
gen corder = iso_num

** -----------------------------------------
** HEATMAP -- CASES -- CASE RATE
** mtype == 3
** -----------------------------------------
replace metric = . if metric<=0 & mtype==3
#delimit ;
    heatplot metric i.corder date if mtype==3
    ,
    bwidth(10) 
    color(RdYlBu , reverse intensify(0.85))
    ///cuts(1($bingrc)@max)
    cuts(2 4 6 8 10 15 20 30 40 50 100 250 500)
    keylabels(all, 
        range(1) 
        order(15 14 13 12 11 10 9 8 7 6 5 4 3 2 1)
        lab(1 "zero")
        lab(2 "0-1")
        lab(3 "2-3")
        lab(4 "4-5")
        lab(5 "6-7")
        lab(6 "8-9")
        lab(7 "10-14")
        lab(8 "15-19")
        lab(9 "20-29")
        lab(10 "30-39")
        lab(11 "40-49")
        lab(12 "50-99")
        lab(13 "100-249")
        lab(14 "250-499")
        lab(15 "500+")
        )
    p(lcolor(white) lalign(center) lw(0.015))
    /// discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )
    ///color(spmap, blues)
    ///cuts(1($bingrc)@max)
    ///keylabels(all, range(1))
    ///p(lcolor(white) lalign(center) lw(0.05))
    ///discrete
    ///statistic(asis)
    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(9) xsize(15)
    ylab(
            1 "Anguilla"
            2 "Antigua and Barbuda" 
            3 "The Bahamas" 
            4 "Belize"
            5 "Bermuda" 
            6 "Barbados"
            7 "Cayman Islands" 
            8 "Dominica"
            9 "Grenada"
            10 "Guyana"
            11 "Haiti"
            12 "Jamaica"
            13 "St Kitts and Nevis"
            14 "St Lucia"
            15 "Montserrat" 
            16 "Suriname"
            17 "Turks and Caicos Islands"
            18 "Trinidad and Tobago"
            19 "St Vincent"
            20 "British Virgin Islands" 
    , labs(2.75) notick nogrid glc(gs16) angle(0))
    yscale(reverse fill noline range(0(1)14)) 
    ///yscale(log reverse fill noline) 
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    xlab(
            21984 "Mar 20" 
            22168 "Sep 20"
            22349 "Mar 21"
            22533 "Sep 21"
            ///22624 "Dec 21"
            ///22655 "Jan 22"
            22714 "Mar 22"
            $fdate "$fdatef"
    , labs(2.5) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    title("Case rate by $S_DATE", pos(11) ring(1) size(3.5))
    legend(size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Case Rate" "(per 100,000)", size(2.75))
                    )
    name(heatmap_caserate1) 
    ;
#delimit cr
