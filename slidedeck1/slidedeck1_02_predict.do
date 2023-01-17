** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_06predict.do
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

    ** DO file path
    local dopath "X:\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w009\slidedeck1\"

    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w009\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w009\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w009\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\caricom_06predict", replace
** HEADER -----------------------------------------------------

** SIR model scenarios for Barbados modelling
** do "`dopath'/slidedeck1_01_sir_scenarios.do"
** do "`dopath'/slidedeck1_01_sir_scenarios2.do"
do "`dopath'/slidedeck1_01_sir_scenarios3.do"


** Drop X initial observation days from scenarios to recognise that the outbreak has already started
** Do this in collaboration with public health
forval x = 1(1)5 {
    use "`datapath'\covid2021-scenario`x'", replace
    sort days
    drop if _n<=2
    save "`datapath'\sc`x'-leftcensored", replace
}

** ---------------------------------------------
** Use the EIGHT scenarios
** Appending the observed time series
** ---------------------------------------------
use "`datapath'\sc1-leftcensored", replace
append using "`datapath'\sc2-leftcensored"
append using "`datapath'\sc3-leftcensored"
append using "`datapath'\sc4-leftcensored"
append using "`datapath'\sc5-leftcensored"
rename infect_new cases
tempfile scenarios
save `scenarios', replace
append using "`datapath'\BRB_trajectory"

** Order and sort the time series
order scenario date iso country pop cases cases14 cases7 cases3
sort scenario date days

** Fill-in the population size, and country names for the modelling scenarios
gen d1 = date if scenario==0 & scenario[_n+1]==1
egen d2 = min(d1)
global fdate = d2
replace date = $fdate + 3 if date==. & scenario!=scenario[_n-1] 
replace date = date[_n-1] + 1 if date==.
rename pop t1
egen pop= min(t1)
drop t1
global iso = iso
rename iso t1
gen iso = "$iso"
global country = country
rename country t2
gen country = "$country"
drop t1 t2 
order scenario date iso country pop cases 
keep scenario date iso country pop cases cases3 cases7 cases14 rcase_av_14 rcase_av_7
sort scenario date

** Convert cases to case-rate per 100,000 for the 8 scenarios (ie. scenarios 1 to 8)
rename cases t1
gen cases = t1
replace cases = (cases/pop) * 100000 if scenario > 0

** Pull apart the preduictions by scenario
**gen cases_scen4 = cases if scenario==4
**gen cases_scen5 = cases if scenario==5
**gen cases_scen6 = cases if scenario==6
**gen cases_scen7 = cases if scenario==7
**gen cases_scen8 = cases if scenario==8

lowess cases date if iso=="BRB" & scenario==1, bwidth(0.5) gen(cases_scen1) name(sc1) ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==2, bwidth(0.5) gen(cases_scen2) name(sc2) ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==3, bwidth(0.5) gen(cases_scen3) name(sc3) ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==4, bwidth(0.5) gen(cases_scen4) name(sc4)  ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==5, bwidth(0.5) gen(cases_scen5) name(sc5)  ylab(0(20)100)

** Keep 2021 for graphing
keep if date >= d(1jan2021)

gen x0 = 0

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
    colorpalette d3 , 20 nograph
    local list r(p) 
    ** Age groups
    local gre `r(p6)'
    local blu `r(p2)'  
    local pur `r(p10)'
    local yel `r(p18)'
    local ora `r(p4)'    
    local red `r(p8)'       
    local gry `p(p16)'   

        #delimit ;
            gr twoway 
                /// outer boxes 
                /// (scatteri `outer1'  , recast(area) lw(0.2) lc(gs10) fc(none) )                            
                /// (scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) )
                /// (scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) )
                /// (scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) )

                /// Observed
                (line cases3 date if scenario==0 & date>=22462, sort lc("gs8") lw(0.4) lp("-"))
                (line rcase_av_7 date if scenario==0 & date>=22462, sort lc("`ora'*1.2") lw(0.2) lp("l"))
                (rarea x0 rcase_av_7 date if scenario==0 & date>=22462, sort col("`ora'%40") lw(none))        

                /// Predictions 
                /// (rarea cases_scen1 cases_scen2 date if iso=="BRB" , sort col("`red1'%40") lw(none))         
                /// (rarea cases_scen2 cases_scen3 date if iso=="BRB" , sort col("`red2'%40") lw(none))         
                /// (rarea cases_scen3 cases_scen4 date if iso=="BRB" , sort col("`red3'%40") lw(none))         
                /// (rarea cases_scen4 cases_scen5 date if iso=="BRB" , sort col("`red4'%40") lw(none))         
                /// (line cases_scen1 date if scenario==1 & iso=="BRB" , sort lc("gs4") lw(0.2) lp("-"))
                /// (line cases_scen5 date if scenario==5 & iso=="BRB" , sort lc("gs4") lw(0.2) lp("-"))
                /// (line cases_scen2 date if scenario==2 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                /// (line cases_scen3 date if scenario==3 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                /// (line cases_scen4 date if scenario==4 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))

                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    bgcolor(white) 
                    ysize(6) xsize(18)
                

                    xlab(
                            22462 "1 Jul 2021"
                            22524 "1 Sep 2021" 
                            22615 "1 Dec 2021" 
                    , 
                    labs(4) notick nogrid glc(gs16))
                    xscale(noline   range(22462(10)22585)) 
                    xtitle("Outbreak month (2021)", size(4) margin(l=2 r=2 t=4 b=2)) 

                    ylab(0(50)150 
                    ,
                    labs(4) nogrid notick glc(gs16) angle(0) format(%9.0f) labgap(2))
                    ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                    yscale(noline) 
                    ytick(0(10)150)

                    text(40.5 22330 "Barbados"         ,  place(e) size(5.5) color(gs8) just(left))
                    /// text($ypos2 $xpos0 "`date_string2'"         ,  place(e) size(5.5) color(gs0) just(left))

                    /// text($ypos1 $xpos1 "CASES"                      ,  place(w) size(5) color(gs4) just(left))
                    /// text($ypos2 $xpos1 "Total: ${m01_`country'}"    ,  place(w) size(5) color(gs8) just(left))
                    /// text($ypos3 $xpos1 "14-day: ${m03_`country'}"   ,  place(w) size(5) color(`red2') just(left))

                    /// text($ypos1 $xpos2 "DEATHS"                     ,  place(w) size(5) color(gs4) just(right))
                    /// text($ypos2 $xpos2 "Total: ${m02_`country'}"    ,  place(w) size(5) color(gs8) just(right))
                    /// text($ypos3 $xpos2 "14-day: ${m04_`country'}"   ,  place(w) size(5) color(`red2') just(right))

                    /// text($ypos1 $xpos3 "RATE"                       ,  place(w) size(5) color(gs4) just(right))
                    /// text($ypos2 $xpos3 "${rate5_`country'} "        ,  place(w) size(5) color(gs8) just(right))
                    /// text($ypos3 $xpos3 "${up_`country'}"            ,  place(w) size(5) color(`red2') just(right))
                    /// text($ypos3 $xpos3 "${down_`country'}"          ,  place(w) size(5) color(`gre') just(right))


                    legend(off size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                    symysize(5) symxsize(7)
                    order(4 5 6 7) 
                    lab(4 "0-10%")
                    lab(5 "11-25%")
                    lab(6 "26-50%")
                    lab(7 "51-75%")
                    )
                    name(observed_BRB) 
                    ;
            #delimit cr
            graph export "`outputpath'/caserate_BRB_clean.png", replace width(4000) 


** Peak prediction rate
forval x = 1(1)5 {
    egen peak`x' = max(cases_scen`x')
    global peak`x'  : dis %6.0f peak`x'
    global loc`x'  : dis %6.0f peak`x' + 5
    global ht`x'  : dis %6.0f peak`x' + 10
}

** Projection period bar
** We want to draw line
gen d1 = c(current_date)
local d1 = d1
gen d2 = d(`d1')
global date1 = d2
global date2 = $date1 + $wlength
global date3 = $date1 + ($wlength/2)
local outer1 5 $date1  5 $date2

** 1 July 2021 and later for this final graphic
keep if date >= 22462
        #delimit ;
            gr twoway 
                /// outer boxes 
                (scatteri `outer1'  , recast(line) lw(2) lc("`red5'%40") fc  (none) )                            

                /// Observed
                (line cases3 date if scenario==0 & date>=22462 , sort lc("gs8") lw(0.4) lp("-"))
                (line rcase_av_7 date if scenario==0 & date>=22462 , sort lc("`ora'*1.2") lw(0.2) lp("l"))
                (rarea x0 rcase_av_7 date if scenario==0 & date>=22462 , sort col("`ora'%40") lw(none))        

                /// Predictions 
                (rarea cases_scen1 cases_scen2 date if iso=="BRB" , sort col("`red1'%40") lw(none))         
                (rarea cases_scen2 cases_scen3 date if iso=="BRB" , sort col("`red2'%40") lw(none))         
                (rarea cases_scen3 cases_scen4 date if iso=="BRB" , sort col("`red3'%40") lw(none))         
                (rarea cases_scen4 cases_scen5 date if iso=="BRB" , sort col("`red4'%40") lw(none))         
                (line cases_scen1 date if scenario==1 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                (line cases_scen2 date if scenario==2 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                (line cases_scen3 date if scenario==3 & iso=="BRB" , sort lc("gs4") lw(0.3) lp("-"))
                (line cases_scen4 date if scenario==4 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                (line cases_scen5 date if scenario==5 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))

                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    bgcolor(white) 
                    ysize(6) xsize(18)

                    xlab(
                            22462 "1 Jul 2021"
                            22524 "1 Sep 2021" 
                            22615 "1 Dec 2021" 
                    , 
                    labs(4) notick nogrid glc(gs16))
                    xscale(noline   range(22462(100)22585)) 
                    xtitle("Outbreak month (2021)", size(4) margin(l=2 r=2 t=4 b=2)) 

                    ylab(0(200)1000 
                    ,
                    labs(4) nogrid notick glc(gs16) angle(0) format(%9.0f) labgap(2))
                    ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                    yscale(noline range(0(100)${ht1})) 
                    ytick(0(50)1000)
                    ymtick(0(25)1000)

                    /// text(800 22465 "Barbados" ,  place(e) size(5.5) color(gs8) just(left))
                    text(${loc1} 22560 "${peak2} per 100k"  ,  place(e) size(5.5) color(gs8) just(left))
                    text(0 $date3 "${wlength} day" "projection"  ,  place(c) size(4.5) color(gs8) just(left))


                    legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                    symysize(5) symxsize(7)
                    order(5 6 7 8) 
                    lab(5 "0-10% vaccination")
                    lab(6 "11-25%")
                    lab(7 "26-50%")
                    lab(8 "51-75%")
                    )
                    name(predicted_BRB) 
                    ;
            #delimit cr
            graph export "`outputpath'/caserate_predict_BRB.png", replace width(4000) 
