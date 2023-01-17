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
** HEATMAP -- NEW CASES
** mtype == 1
** -----------------------------------------
replace metric = . if metric<=0 & mtype==1
#delimit ;
    heatplot metric i.corder date if mtype==1
    ,
    bwidth(7) 
    color(RdYlBu , reverse intensify(0.75 ))
    ///cuts(2 5 10 15 20 25 30 40 50 100 200)
    cuts(10 15 20 30 40 50 100 200 300 400 500)
    keylabels(all, range(1))
    p(lcolor(white) lalign(center) lw(0.05))
    /// discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )
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
            22076 "Jun 20"
            22168 "Sep 20"
            22260 "Dec 20"
            22349 "Mar 21"
            22441 "Jun 21"
            22533 "Sep 21"
            22624 "Dec 21"
            22714 "Mar 22" 
            22806 "Jun 22"
            22898 "Sep 22"
            22989 "Dec 22"
            ///$fdate "$fdatef"
    , labs(2.5) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    title("Daily cases by $S_DATE", pos(11) ring(1) size(3.5))
    legend(size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("New" "Cases", size(2.75))
                    )
    name(heatmap_newcases) 
    ;
#delimit cr
graph export "`outputpath'/heatmap_newcases.png", replace width(4000)


** -----------------------------------------
** HEATMAP -- CASES -- CASE RATE
** mtype == 3
** -----------------------------------------
replace metric = . if metric<=0 & mtype==3
#delimit ;
    heatplot metric i.corder date if mtype==3
    ,
    bwidth(7) 
    color(RdYlBu , reverse intensify(0.75 ))
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
    p(lcolor(white) lalign(center) lw(0.05))
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
            22076 "Jun 20"
            22168 "Sep 20"
            22260 "Dec 20"
            22349 "Mar 21"
            22441 "Jun 21"
            22533 "Sep 21"
            22624 "Dec 21"
            22714 "Mar 22" 
            22806 "Jun 22"
            22898 "Sep 22"
            22989 "Dec 22"
            ///$fdate "$fdatef"
    , labs(2.5) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    title("Case rate by $S_DATE", pos(11) ring(1) size(3.5))
    legend(size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Case Rate" "(per 100,000)", size(2.75))
                    )
    name(heatmap_caserate) 
    ;
#delimit cr
graph export "`outputpath'/heatmap_caserate.png", replace width(4000)


** -----------------------------------------
** HEATMAP -- CUMULATIVE CASES -- COUNT
** mtype == 2 
** -----------------------------------------
replace metric = . if metric<=0 & mtype==2
#delimit ;
    heatplot metric i.corder date if mtype==2
    ,
    bwidth(7) 
    color(RdYlBu , reverse intensify(0.75 ))
    ///cuts(1($bingrc)@max)
    cuts(100 500 1000 5000 10000 20000 30000 40000 50000 75000 100000)
    keylabels(all, 
        range(1) 
        order(12 11 10 9 8 7 6 5 4 3 2 1)
        lab(1 "zero")
        lab(2 "1-99")
        lab(3 "100-499")
        lab(4 "500-999")
        lab(5 "1k-")
        lab(6 "5k-")
        lab(7 "10k-")
        lab(8 "15k-")
        lab(9 "20k-")
        lab(10 "30k-")
        lab(11 "40k-")
        lab(12 "50k-")
        lab(13 "100k-")
        lab(14 "250k-")
        lab(15 "500k+")
        )
    p(lcolor(white) lalign(center) lw(0.05))
    /// discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )
    
    ///color(spmap, blues)
    ///cuts(@min($binc)@max)
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
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    xlab(
            21984 "Mar 20" 
            22076 "Jun 20"
            22168 "Sep 20"
            22260 "Dec 20"
            22349 "Mar 21"
            22441 "Jun 21"
            22533 "Sep 21"
            22624 "Dec 21"
            22714 "Mar 22" 
            22806 "Jun 22"
            22898 "Sep 22"
            22989 "Dec 22"
            ///$fdate "$fdatef"
    , labs(2.5) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    title("Cumulative cases by $S_DATE", pos(11) ring(1) size(3.5))
    legend(size(2.75) position(2) ring(4) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Cumulative" "Cases", size(2.75))
                    )
    name(heatmap_cases) 
    ;
#delimit cr
graph export "`outputpath'/heatmap_totalcases.png", replace width(4000)


** -----------------------------------------
** HEATMAP -- CUMULATIVE DEATHS -- COUNT
** mtype == 5
** -----------------------------------------
replace metric = . if metric<=0 & mtype==5
#delimit ;
    heatplot metric i.corder date if mtype==5
    ,
    bwidth(14) 
    color(RdYlBu , reverse intensify(0.75 ))
    ///cuts(@min($bind)@max)
    cuts(50 100 200 300 400 500 750 1000 1250 1500 1750 3000)
    keylabels(all, range(1))
    p(lcolor(white) lalign(center) lw(0.05))
    /// discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )
    
    ///cuts(@min($bind)@max)
    ///color(spmap, reds)
    ///keylabels(all, range(1))
    ///p(lcolor(white) lalign(center) lw(0.05))
    ///discrete
    ///statistic(asis)
    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(12) xsize(12)
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
    ytitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    xlab(
            21984 "Mar 20" 
            22076 "Jun 20"
            22168 "Sep 20"
            22260 "Dec 20"
            22349 "Mar 21"
            22441 "Jun 21"
            22533 "Sep 21"
            22624 "Dec 21"
            22714 "Mar 22" 
            22806 "Jun 22"
            22898 "Sep 22"
            22989 "Dec 22"
            ///$fdate "$fdatef"
    , labs(1.75) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    title("Cumulative deaths by $S_DATE", pos(11) ring(1) size(3.5))
    legend(size(2.75) position(2) ring(4) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("Cumulative" "Deaths", size(2.75))
    )
    name(heatmap_deaths) 
    ;
#delimit cr 
graph export "`outputpath'/heatmap_totaldeaths.png", replace width(4000)

** -----------------------------------------
** HEATMAP -- NEW DEATHS
** mtype == 4
** -----------------------------------------
replace metric = . if metric<=0 & mtype==4
#delimit ;
    heatplot metric i.corder date if mtype==4
    ,
    bwidth(14) 
    color(RdYlBu , reverse intensify(0.75 ))
    ///cuts(@min(1){@max+1})
    cuts(5 10 15 20 25 30 35 40 45 50)
    keylabels(all, range(1))
    p(lcolor(white) lalign(center) lw(0.05))
    /// discrete
    statistic(asis)
    missing(label("zero") fc(gs12) lc(gs16) lw(0.05) )
    srange(1)
    ///color(spmap, reds)
    ///cuts(@min(1){@max+1})
    ///keylabels(all, range(1))
    ///p(lcolor(white) lalign(center) lw(0.05))
    ///discrete
    ///statistic(asis)
    ///srange(1)
    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
    ysize(12) xsize(12)
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
            22076 "Jun 20"
            22168 "Sep 20"
            22260 "Dec 20"
            22349 "Mar 21"
            22441 "Jun 21"
            22533 "Sep 21"
            22624 "Dec 21"
            22714 "Mar 22" 
            22806 "Jun 22"
            22898 "Sep 22"
            22989 "Dec 22"
            ///$fdate "$fdatef"
   , labs(1.75) nogrid glc(gs16) angle(45) format(%9.0f))
    xtitle(" ", size(1) margin(l=0 r=0 t=0 b=0)) 
    title("Daily deaths by $S_DATE", pos(11) ring(1) size(3.5))
    legend(size(2.75) position(2) ring(5) colf cols(1) lc(gs16)
    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
    sub("New" "Deaths", size(2.75))
                    )
    name(heatmap_newdeaths) 
    ;
#delimit cr
graph export "`outputpath'/heatmap_newdeaths.png", replace width(4000)


** ------------------------------------------------------
** PDF REGIONAL REPORT (COUNTS OF CONFIRMED CASES)
** ------------------------------------------------------
    putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)
** PAGE 1. DAILY CURVES
** PAGE 1. TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro1 = (1,16), width(100%) halign(left)    
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Heatmap: Daily Cases in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro1(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro1(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append
** PAGE 1. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("On this page we present the number of confirmed daily COVID-19 cases ")
    putpdf text ("(see note 1)"), bold 
    putpdf text (" among 20 Caribbean countries and territories ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" since the start of the outbreak. ") 
    putpdf text ("We present this information as a heatmap to visually summarise the situation as of $S_DATE. ") 
    putpdf text ("The heatmap was created: (A) to highlight outbreak hotspots, and (B) to track locations that have seen small numbers of recent cases. ") 
    putpdf text ("An extended period with no or sporadic isolated cases might be used as one of several ") 
    putpdf text ("potential triggers needed before considering the easing of national COVID-19 control measures.")
** PAGE 1. FIGURE OF DAILY COVID-19 COUNT
    putpdf table f1 = (1,1), width(92%) border(all,nil) halign(center)
    putpdf table f1(1,1)=image("`outputpath'/heatmap_newcases.png")


** PAGE 2. CASE RATES 
** PAGE 2. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,16), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil)
    putpdf table intro2(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(15)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 Heatmap: Case Rates (per 100,000) in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro2(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro2(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro2(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro2(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro2(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro2(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro2(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro2(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** PAGE 2. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("On this page we present the case rate (per 100,000 people) for confirmed COVID-19 cases ")
    putpdf text ("(see note 1)"), bold 
    putpdf text (" among 20 Caribbean countries and territories ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" since the start of the outbreak. ") 
    putpdf text ("We present this information as a heatmap to visually summarise the situation as of $S_DATE. ") 
    putpdf text ("The case rate is a better metric for directly comparing ") 
    putpdf text ("outbreaks between countries with different population sizes. ") 
    
** PAGE 2. FIGURE OF COVID-19 GROWTH RATE
    putpdf table f2 = (1,1), width(92%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/heatmap_caserate.png")



** PAGE 3. CUMULATIVE CASES
** PAGE 3. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro2 = (1,16), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil)
    putpdf table intro2(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(15)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 Heatmap: Cumulative Cases in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro2(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro2(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro2(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro2(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro2(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro2(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro2(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro2(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** PAGE 3. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("We present the cumulative number of confirmed COVID-19 cases ")
    putpdf text ("(see note 1)"), bold 
    putpdf text (" among 20 Caribbean countries and territories ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" since the start of the outbreak. ") 
    putpdf text ("We use heatmaps to visually summarise the situation as of $S_DATE. ") 
    putpdf text ("The intention is to highlight outbreak hotspots."), linebreak 

** PAGE 3. FIGURE OF COVID-19 CUMULATIVE CASES
    putpdf table f2 = (1,1), width(92%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/heatmap_totalcases.png")



** PAGE 4. DEATHS
** PAGE 4. TITLE, ATTRIBUTION, DATE of CREATION
putpdf pagebreak
    putpdf table intro4 = (1,16), width(100%) halign(left)    
    putpdf table intro4(.,.), border(all, nil)
    putpdf table intro4(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro4(1,1)
    putpdf table intro4(1,2), colspan(15)
    putpdf table intro4(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro4(1,2)=("COVID-19 Heatmap: Deaths in 20 Caribbean Countries and Territories"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro4(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro4(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro4(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro4(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro4(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro4(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro4(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro4(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** PAGE 4. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 9)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("On this page we present the number of confirmed daily and cumulative COVID-19 deaths ")
    putpdf text ("(see note 1)"), bold 
    putpdf text (" among 20 Caribbean countries and territories ") 
    putpdf text ("(see note 2)"), bold
    putpdf text (" since the start of the outbreak. ") 
    putpdf text ("We present this information as a heatmap to visually summarise the situation as of $S_DATE. ") 

** PAGE 4. FIGURE OF COVID-19 DEATHS
    putpdf table f3 = (1,2), width(95%) border(all,nil) halign(center)
    putpdf table f3(1,1)=image("`outputpath'/heatmap_newdeaths.png")
    putpdf table f3(1,2)=image("`outputpath'/heatmap_totaldeaths.png")

** REPORT PAGE 4 - FOOTNOTE 1. DATA REFERENCE
** REPORT PAGE 4 - FOOTNOTE 2. CARICOM COUNTRIES
** REPORT PAGE 4 - FOOTNOTE 3. GROWTH RATE
    putpdf table p3 = (3,1), width(100%) halign(center) 
    putpdf table p3(.,1), font("Calibri Light", 8) border(all,nil) bgcolor(ffffff)
    putpdf table p3(1,1)=("(NOTE 1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append

    putpdf table p3(2,1)=("(NOTE 2) Countries and territories included in this briefing: "), bold halign(left)
    putpdf table p3(2,1)=("Countries and territories included in this briefing: "), halign(left) append
    putpdf table p3(2,1)=("CARICOM member states: "), italic halign(left) append
    putpdf table p3(2,1)=("Antigua and Barbuda, The Bahamas, Barbados, Belize, Dominica, Grenada, Guyana, Haiti, Jamaica, "), append 
    putpdf table p3(2,1)=("St. Kitts and Nevis, St. Lucia, St. Vincent and the Grenadines, Suriname, Trinidad and Tobago."), append
    putpdf table p3(2,1)=("United Kingdom Overseas Territories (UKOTS): "), italic append
    putpdf table p3(2,1)=("Anguilla, Bermuda, British Virgin Islands, Cayman Islands, Montserrat, Turks and Caicos Islands."), append 

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`webpath'/heatmaps_CARICOM", replace
    