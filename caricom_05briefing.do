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

    ** DO FILEPATH
    local dopath "X:\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w009"

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


** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`dopath'\caricom_04metrics2"
rename country cname
** -----------------------------------------

rename case new_cases 
rename death new_deaths

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

** Scroll through multiple identical graphics
** They vary only by Caribbean country


** Convert Date to weeks
gen eweek1 = elapsed /7
gen eweek = int(eweek1)
drop eweek1
gen dweek = wofd(date)
gen dmonth =  mofd(dofw(dweek))
gen month = month(date)
order dweek dmonth month, after(date)
///format dweek %tw
label define month_ 1 "Jan" 2 "Feb" 3 "Mar" 4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec",modify
label values month month_
gen day = dofw(dweek)
format day %td

** Collapse into weeks
collapse (sum) new_cases new_deaths (mean) cpop=pop, by(cname iso iso_num dweek dmonth month)

** Smoothed CASES and DEATHS for graphic
///by iso: asrol total_cases , stat(mean) window(date 3) gen(cases_av3)
///by iso: asrol total_deaths , stat(mean) window(date 3) gen(deaths_av3)
sort iso dweek 
by iso: asrol new_cases , stat(mean) window(dweek 3) gen(cases_av3)
by iso: asrol new_deaths , stat(mean) window(dweek 3) gen(deaths_av3)

** BY Country: Elapased time in weeks from first case
bysort iso: egen elapsed_max = max(dweek)
gen x0 = 0


label define iso_num 1000 "CAR", modify
label values iso_num iso_num



** LOOP through N=20 CARICOM member states
** The looping structure AFTER the PDF creation
** It means that we create 1 PDF for each COUNTRY ISO listed in the local macros -clist-
local clist "CAR AIA ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
** local clist "BRB"
foreach country of local clist {
    ** This code chunk creates COUNTRY ISO CODE and COUNTRY NAME
    ** for automated use in the PDF reports.
    **      country  = 3-character ISO name
    **      cname    = FULL country name
    **      -country- used in all loop structures
    **      -cname- used for visual display of full country name on PDF
    gen el_`country'1 = elapsed_max if iso=="`country'"
    egen el_`country'2 = min(el_`country'1) 
    local elapsed = el_`country'2
    gen c3 = iso_num if iso=="`country'"
    label values c3 cname_
    egen c4 = min(c3)
    label values c4 cname_
    decode c4, gen(c5)
    local cname = c5


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

** GRAPHIC 1: DEATHS
        #delimit ;
        gr twoway 
            (bar new_deaths dweek if iso=="`country'" & elapsed<=`elapsed', barw(0.9)  col("`red'")
            )
            ,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(14)
            
            xlab(
                    3133 "Apr"
                    3146 "Jul"
                    3160 "Oct"
                    3172 "Jan"
                    3185 "Apr"
                    3198 "Jul"
                    3211 "Oct"
            , labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle("Outbreak timeline (2020-2021)", size(5.5) margin(l=2 r=2 t=5 b=2)) 
                
            ylab(
            , labs(5) notick nogrid glc(gs16) angle(0))
            yscale(fill noline) 
            ytitle("Weekly deaths", size(5.5) margin(l=2 r=2 t=2 b=2)) 
            
            legend(off size(6) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(deaths_`country') 
                ;
        #delimit cr
        graph export "`outputpath'/deaths_`country'.png", replace width(4000)


** GRAPHIC 1: CASES
        #delimit ;
        gr twoway 
            (bar new_cases dweek if iso=="`country'" & elapsed<=`elapsed', barw(0.9)  col("`pur'")
            )
            ,
            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
            bgcolor(white) 
            ysize(5) xsize(14)
            
            xlab(
                    3133 "Apr"
                    3146 "Jul"
                    3160 "Oct"
                    3172 "Jan"
                    3185 "Apr"
                    3198 "Jul"
                    3211 "Oct"
            , labs(5) nogrid glc(gs16) angle(0) format(%9.0f))
            xtitle("Outbreak timeline (2020-2021)", size(5.5) margin(l=2 r=2 t=5 b=2)) 
                
            ylab(
            , labs(5) notick nogrid glc(gs16) angle(0))
            yscale(fill noline) 
            ytitle("Weekly cases", size(5.5) margin(l=2 r=2 t=2 b=2)) 
            
            legend(off size(6) position(5) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lc(gs16)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                )
                name(cases_`country') 
                ;
        #delimit cr
        graph export "`outputpath'/cases_`country'.png", replace width(4000)

        drop c3 c4 c5 el_*


** ------------------------------------------------------
** PDF COUNTRY REPORT
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro = (1,12), width(100%) halign(left)    
    putpdf table intro(.,.), border(all, nil)
    putpdf table intro(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro(1,1)
    putpdf table intro(1,2), colspan(11)
    putpdf table intro(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro(1,2)=("COVID-19 trajectory for `cname'"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("We present the number of confirmed cases and deaths ")
    putpdf text ("1"), script(super) 
    putpdf text (" from COVID-19 infection in `cname' since the start of the outbreak, which ") 
    putpdf text ("we measure as the number of days since the first confirmed case. We report whether the case rate (per 100,000 people) is currently increasing or decreasing, ") 
    putpdf text ("and describe the current `cname' case load compared to the `cname' outbreak peak. "),  
    putpdf text ("For more on case rates, download the associated "),  
    putpdf text ("country profile "), italic bold  
    putpdf text ("For `cname'. "), linebreak 

** TABLE: KEY SUMMARY METRICS
    putpdf table t1 = (4,5), width(85%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, single,999999) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(2,1), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,1), font("Calibri Light", 12, 000000) border(all,single,999999) bgcolor(ffffff) 
    putpdf table t1(4,1), font("Calibri Light", 12, 000000) border(all,single,999999) bgcolor(ffffff) 

    putpdf table t1(1,2), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top,single,999999) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(2,2), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 
    putpdf table t1(4,2), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 

    putpdf table t1(1,3), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top,single,999999) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(2,3), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 
    putpdf table t1(4,3), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 

    putpdf table t1(1,4), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(ffffff)
    putpdf table t1(2,4), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(ffffff)
    putpdf table t1(3,4), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(ffffff) 
    putpdf table t1(4,4), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(ffffff) 

    putpdf table t1(1,5), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top,single,999999) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(2,5), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 
    putpdf table t1(4,5), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 

    putpdf table t1(1,2)=("Total"), halign(center) 
    putpdf table t1(1,3)=("New"), halign(center) 
    putpdf table t1(2,3)=("(14 days)"), halign(center) 
    putpdf table t1(1,4)=(""), halign(center) 
    putpdf table t1(2,4)=(""), halign(center) 
    putpdf table t1(1,5)=("Case Rate"), halign(center) 
    putpdf table t1(2,5)=(""), halign(center) 
    putpdf table t1(1,1)=("Confirmed"), halign(center) 
    putpdf table t1(2,1)=("Events"), halign(center) 
    putpdf table t1(3,1)=("Cases"), halign(center) 
    putpdf table t1(4,1)=("Deaths"), halign(center)  

    putpdf table t1(3,2)=("${m01_`country'}"), halign(center) 
    putpdf table t1(4,2)=("${m02_`country'}"), halign(center) 
    putpdf table t1(3,3)=("${m03_`country'}"), halign(center) 
    putpdf table t1(4,3)=("${m04_`country'}"), halign(center) 
    putpdf table t1(3,5)=("${rate5_`country'}"), halign(center) 
    if ${m05_`country'} == 1 {
        putpdf table t1(4,5), font("Calibri Light", 11, 000000) border(left, single, 999999) border(right, single, 999999) border(top, single, 999999) border(bottom, single, 999999) bgcolor(ffcccc) 
        putpdf table t1(4,5)=("${up_`country'}"), halign(center) 
    }
    else if ${m05_`country'} == 2 {
        putpdf table t1(4,5), font("Calibri Light", 11, 000000) border(left, single, 999999) border(right, single, 999999) border(top, single, 999999) border(bottom, single, 999999) bgcolor(d6f5d6) 
        putpdf table t1(4,5)=("${down_`country'}"), halign(center)  
    }


** TEXT TO ACCOMPANY FIGURE 1
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("These graphs show the absolute numbers of cases and deaths in `cname' since the start of the outbreak. ")
    putpdf text ("They are the core information for assessing the extent of the COVID-19 burden over time. ")

** FIGURE 1. OF COVID-19 trajectory
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Graph."), bold
    putpdf text (" New cases per week in `cname' as of $S_DATE"), linebreak
    putpdf table f1 = (1,1), width(85%) border(all,nil) halign(center)
    putpdf table f1(1,1)=image("`outputpath'/cases_`country'.png")

** FIGURE 2. OF COVID-19 trajectory
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Graph."), bold
    putpdf text (" New deaths per week in `cname' as of $S_DATE"), linebreak
    putpdf table f2 = (1,1), width(85%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/deaths_`country'.png")

** DATA REFERENCE
    putpdf table p3 = (1,1), width(100%) halign(center) 
    putpdf table p3(1,1), font("Calibri Light", 8) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p3(1,1)=("(1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`webpath'/briefing_`country'", replace
}



** -----------------------------------------------
** ALL BRIEFINGS IN A SINGLE PDF
** -----------------------------------------------


** ------------------------------------------------------
** PDF COUNTRY REPORT
** ------------------------------------------------------
putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

local clist "CAR AIA ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB"
foreach country of local clist {
    ** This code chunk creates COUNTRY ISO CODE and COUNTRY NAME
    ** for automated use in the PDF reports.
    **      country  = 3-character ISO name
    **      cname    = FULL country name
    **      -country- used in all loop structures
    **      -cname- used for visual display of full country name on PDF
    gen el_`country'1 = elapsed_max if iso=="`country'"
    egen el_`country'2 = min(el_`country'1) 
    local elapsed = el_`country'2
    gen c3 = iso_num if iso=="`country'"
    label values c3 cname_
    egen c4 = min(c3)
    label values c4 cname_
    decode c4, gen(c5)
    local cname = c5
    drop c3 c4 c5 el_*


** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro = (1,12), width(100%) halign(left)    
    putpdf table intro(.,.), border(all, nil)
    putpdf table intro(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro(1,1)
    putpdf table intro(1,2), colspan(11)
    putpdf table intro(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro(1,2)=("COVID-19 trajectory for `cname'"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro(1,2)=("Briefing created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Aim of this briefing. ") , bold
    putpdf text ("We present the number of confirmed cases and deaths ")
    putpdf text ("1"), script(super) 
    putpdf text (" from COVID-19 infection in `cname' since the start of the outbreak, which ") 
    putpdf text ("we measure as the number of days since the first confirmed case. We report whether the case rate (per 100,000 people) is currently increasing or decreasing, ") 
    putpdf text ("and describe the current `cname' case load compared to the `cname' outbreak peak. "),  
    putpdf text ("For more on case rates, download the associated "),  
    putpdf text ("country profile "), italic bold  
    putpdf text ("For `cname'. "), linebreak 

** TABLE: KEY SUMMARY METRICS
    putpdf table t1 = (4,5), width(85%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, single,999999) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(2,1), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,1), font("Calibri Light", 12, 000000) border(all,single,999999) bgcolor(ffffff) 
    putpdf table t1(4,1), font("Calibri Light", 12, 000000) border(all,single,999999) bgcolor(ffffff) 

    putpdf table t1(1,2), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top,single,999999) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(2,2), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(e6e6e6) 
    putpdf table t1(3,2), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 
    putpdf table t1(4,2), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 

    putpdf table t1(1,3), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top,single,999999) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(2,3), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,3), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 
    putpdf table t1(4,3), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 

    putpdf table t1(1,4), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(ffffff)
    putpdf table t1(2,4), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(ffffff)
    putpdf table t1(3,4), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(ffffff) 
    putpdf table t1(4,4), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(ffffff) 

    putpdf table t1(1,5), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top,single,999999) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(2,5), font("Calibri Light", 11, 000000) border(left,single,999999) border(right,single,999999) border(top, nil) border(bottom, nil) bgcolor(e6e6e6)
    putpdf table t1(3,5), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 
    putpdf table t1(4,5), font("Calibri Light", 11, 000000) border(all,single,999999) bgcolor(ffffff) 

    putpdf table t1(1,2)=("Total"), halign(center) 
    putpdf table t1(1,3)=("New"), halign(center) 
    putpdf table t1(2,3)=("(14 days)"), halign(center) 
    putpdf table t1(1,4)=(""), halign(center) 
    putpdf table t1(2,4)=(""), halign(center) 
    putpdf table t1(1,5)=("Case Rate"), halign(center) 
    putpdf table t1(2,5)=(""), halign(center) 
    putpdf table t1(1,1)=("Confirmed"), halign(center) 
    putpdf table t1(2,1)=("Events"), halign(center) 
    putpdf table t1(3,1)=("Cases"), halign(center) 
    putpdf table t1(4,1)=("Deaths"), halign(center)  

    putpdf table t1(3,2)=("${m01_`country'}"), halign(center) 
    putpdf table t1(4,2)=("${m02_`country'}"), halign(center) 
    putpdf table t1(3,3)=("${m03_`country'}"), halign(center) 
    putpdf table t1(4,3)=("${m04_`country'}"), halign(center) 
    putpdf table t1(3,5)=("${rate5_`country'}"), halign(center) 
    if ${m05_`country'} == 1 {
        putpdf table t1(4,5), font("Calibri Light", 11, 000000) border(left, single, 999999) border(right, single, 999999) border(top, single, 999999) border(bottom, single, 999999) bgcolor(ffcccc) 
        putpdf table t1(4,5)=("${up_`country'}"), halign(center) 
    }
    else if ${m05_`country'} == 2 {
        putpdf table t1(4,5), font("Calibri Light", 11, 000000) border(left, single, 999999) border(right, single, 999999) border(top, single, 999999) border(bottom, single, 999999) bgcolor(d6f5d6) 
        putpdf table t1(4,5)=("${down_`country'}"), halign(center)  
    }


** TEXT TO ACCOMPANY FIGURE 1
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("These graphs show the absolute numbers of cases and deaths in `cname' since the start of the outbreak. ")
    putpdf text ("They are the core information for assessing the extent of the COVID-19 burden over time. ")

** FIGURE 1. OF COVID-19 trajectory
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Graph."), bold
    putpdf text (" New cases per week in `cname' as of $S_DATE"), linebreak
    putpdf table f1 = (1,1), width(85%) border(all,nil) halign(center)
    putpdf table f1(1,1)=image("`outputpath'/cases_`country'.png")

** FIGURE 2. OF COVID-19 trajectory
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Graph."), bold
    putpdf text (" New deaths per week in `cname' as of $S_DATE"), linebreak
    putpdf table f2 = (1,1), width(85%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/deaths_`country'.png")

** DATA REFERENCE
    putpdf table p3 = (1,1), width(100%) halign(center) 
    putpdf table p3(1,1), font("Calibri Light", 8) border(all,nil,000000) bgcolor(ffffff)
    putpdf table p3(1,1)=("(1) Data Source. "), bold halign(left)
    putpdf table p3(1,1)=("Dong E, Du H, Gardner L. An interactive web-based dashboard to track COVID-19 "), append 
    putpdf table p3(1,1)=("in real time. Lancet Infect Dis; published online Feb 19. https://doi.org/10.1016/S1473-3099(20)30120-1"), append
}

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`webpath'/briefing_CARICOM", replace