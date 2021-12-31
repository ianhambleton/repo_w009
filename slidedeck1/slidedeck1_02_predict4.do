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

** SIR model scenarios for Barbados OMICRON modelling
do "`dopath'/slidedeck1_01_sir_scenarios4_2waves.do"

** Drop X initial observation days from scenarios to recognise that the outbreak has already started
** Do this in collaboration with public health
forval x = 1(1)10 {
    use "`datapath'\covid2021-scenario`x'", replace
    sort days
    drop if _n<=2
    save "`datapath'\sc`x'-leftcensored", replace
}

** ---------------------------------------------
** Use the TEN scenarios (5 for longer wave, 5 for shorter wave)
** Appending the observed time series
** ---------------------------------------------
use "`datapath'\sc1-leftcensored", replace
append using "`datapath'\sc2-leftcensored"
append using "`datapath'\sc3-leftcensored"
append using "`datapath'\sc4-leftcensored"
append using "`datapath'\sc5-leftcensored"
append using "`datapath'\sc6-leftcensored"
append using "`datapath'\sc7-leftcensored"
append using "`datapath'\sc8-leftcensored"
append using "`datapath'\sc9-leftcensored"
append using "`datapath'\sc10-leftcensored"
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

** Estimate smoothed curves for prediction
lowess cases date if iso=="BRB" & scenario==1, bwidth(0.5) gen(cases_scen1) name(sc1) ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==2, bwidth(0.5) gen(cases_scen2) name(sc2) ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==3, bwidth(0.5) gen(cases_scen3) name(sc3) ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==4, bwidth(0.5) gen(cases_scen4) name(sc4)  ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==5, bwidth(0.5) gen(cases_scen5) name(sc5)  ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==6, bwidth(0.5) gen(cases_scen6) name(sc6)  ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==7, bwidth(0.5) gen(cases_scen7) name(sc7)  ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==8, bwidth(0.5) gen(cases_scen8) name(sc8)  ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==9, bwidth(0.5) gen(cases_scen9) name(sc9)  ylab(0(20)100)
lowess cases date if iso=="BRB" & scenario==10, bwidth(0.5) gen(cases_scen10) name(sc10)  ylab(0(20)100)


** --------------------------------------------------------------
** GRAPH PREPARATION
** --------------------------------------------------------------
        ** Keep last half of 2021 for graphing
        keep if date >= d(1jul2021)

        ** Zero vector
        gen x0 = 0

        ** COLORS - SFSO reds
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

        ** Peak prediction rate
        forval x = 1(1)10 {
            egen peak`x' = max(cases_scen`x')
            global peak`x'  : dis %6.0fc peak`x'
            global nloc`x'  : dis %6.0f peak`x' + 5
            global loc`x'  : dis %6.0fc peak`x' + 5
            global ht`x'  : dis %6.0fc peak`x' + 10
        }

        ** Total number of cases in wave (rate * 2.8, the size of BRB population --> 100,000*2.8 = 280,000)
        forval x = 1(1)10 {
            gen ctot`x' = cases_scen`x' * 2.8 
            egen tot`x' = sum(ctot`x')
            global tot`x'  : dis %7.0fc tot`x'
            }

        ** Projection period bar
        ** We want to draw line
        ** Shorter period
        gen d1 = c(current_date)
        local d1 = d1
        gen d2 = d(`d1')
        global date1 = d2
        global date2 = $date1 + $wlength1
        global date3 = $date1 + ($wlength1/2)
        local outer1 5 $date1  5 $date2
        global locw  : dis %6.0f $nloc6 - 125

        ** Longer period
        global ldate2 = $date1 + $wlength2
        global ldate3 = $date1 + ($wlength2/2)
        local louter1 5 $date1  5 $ldate2



** --------------------------------------------------------------
** BARBADOS OUTBREAK CURVE - JUL to DEC 2021
** --------------------------------------------------------------
        #delimit ;
            gr twoway 
                /// outer boxes 
                /// (scatteri `outer1'  , recast(line) lw(2) lc("`red5'%40") fc  (none) )                            
                /// (scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) )
                /// (scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) )
                /// (scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) )

                /// Observed
                ///(line cases date if scenario==0 & iso=="BRB" , sort lc("gs4") lw(0.4) lp("-"))
                (line cases3 date if scenario==0 , sort lc("gs8") lw(0.4) lp("-"))
                (line rcase_av_7 date if scenario==0 , sort lc("`ora'*1.2") lw(0.2) lp("l"))
                (rarea x0 rcase_av_7 date if scenario==0 , sort col("`ora'%40") lw(none))        

                /// (rarea cases_scen6 cases_scen7 date if iso=="BRB" , sort col("gs16") lw(none))         
                /// (rarea cases_scen7 cases_scen8 date if iso=="BRB" , sort col("gs16") lw(none))         
                /// (rarea cases_scen8 cases_scen9 date if iso=="BRB" , sort col("gs16") lw(none))         
                /// (rarea cases_scen9 cases_scen10 date if iso=="BRB" , sort col("gs16") lw(none))         
                
                /// 60-day wavelength
                /// (line cases_scen6 date if scenario==6 & iso=="BRB" , sort lc("gs16") lw(0.1) lp("-"))
                /// (line cases_scen7 date if scenario==7 & iso=="BRB" , sort lc("gs16") lw(0.1) lp("-"))
                /// (line cases_scen8 date if scenario==8 & iso=="BRB" , sort lc("gs16") lw(0.3) lp("-"))
                /// (line cases_scen9 date if scenario==9 & iso=="BRB" , sort lc("gs16") lw(0.1) lp("-"))
                /// (line cases_scen10 date if scenario==10 & iso=="BRB" , sort lc("gs16") lw(0.1) lp("-"))

                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    bgcolor(white) 
                    ysize(6) xsize(18)

                    xlab(
                            22462 "1 Jul 2021"
                            22524 "1 Sep 2021" 
                            22585 "1 Nov 2021"
                            22646 "1 Jan 2022"
                            22677 "1 Feb 2022"
                    , 
                    labs(4) notick nogrid glc(gs16))
                    xscale(noline   range(22462(10)22691)) 
                    xtitle("Outbreak month (2021-22)", size(4) margin(l=2 r=2 t=4 b=2)) 

                    ylab(0(25)150 
                    ,
                    labs(4) nogrid notick glc(gs16) angle(0) format(%9.0f) labgap(2))
                    ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                    yscale(noline range(0(10)150)) 
                    ytick(0(50)150)
                    ymtick(0(25)150)

                    text(40.5 22330 "Barbados" ,  place(e) size(5.5) color(gs8) just(left))

                    legend(off)
                    name(predicted_BRB) 
                    ;
            #delimit cr
            graph export "`outputpath'/caserate_BRB_clean4.png", replace width(4000) 

** --------------------------------------------------------------
** LONGER WAVE LENGTH
** --------------------------------------------------------------
        #delimit ;
            gr twoway 
                /// outer boxes 
                (scatteri `louter1'  , recast(line) lw(2) lc("`red5'%40") fc  (none) )                            
                /// (scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) )
                /// (scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) )
                /// (scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) )

                /// Observed
                ///(line cases date if scenario==0 & iso=="BRB" , sort lc("gs4") lw(0.4) lp("-"))
                (line cases3 date if scenario==0 , sort lc("gs8") lw(0.4) lp("-"))
                (line rcase_av_7 date if scenario==0 , sort lc("`ora'*1.2") lw(0.2) lp("l"))
                (rarea x0 rcase_av_7 date if scenario==0 , sort col("`ora'%40") lw(none))        

                (rarea cases_scen6 cases_scen8 date if iso=="BRB" , sort col("`red1'%60") lw(none))         
                ///(rarea cases_scen7 cases_scen8 date if iso=="BRB" , sort col("`red2'%60") lw(none))         
                ///(rarea cases_scen8 cases_scen9 date if iso=="BRB" , sort col("`red3'%60") lw(none))         
                (rarea cases_scen8 cases_scen10 date if iso=="BRB" , sort col("`red4'%60") lw(none))         
                
                /// 60-day wavelength
                (line cases_scen6 date if scenario==6 & iso=="BRB" , sort lc("gs6") lw(0.3) lp("-"))
                ///(line cases_scen7 date if scenario==7 & iso=="BRB" , sort lc("gs1") lw(0.3) lp("-"))
                (line cases_scen8 date if scenario==8 & iso=="BRB" , sort lc("gs6") lw(0.3) lp("-"))
                ///(line cases_scen9 date if scenario==9 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                (line cases_scen10 date if scenario==10 & iso=="BRB" , sort lc("gs6") lw(0.3) lp("-"))

                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    bgcolor(white) 
                    ysize(6) xsize(18)

                    xlab(
                            22462 "1 Jul 2021"
                            22524 "1 Sep 2021" 
                            22585 "1 Nov 2021"
                            22646 "1 Jan 2022"
                    , 
                    labs(4) notick nogrid glc(gs16))
                    xscale(noline   range(22462(10)${date2})) 
                    xtitle("Outbreak month (2021-22)", size(4) margin(l=2 r=2 t=4 b=2)) 

                    ylab(0(200)1000 
                    ,
                    labs(4) nogrid notick glc(gs16) angle(0) format(%9.0f) labgap(2))
                    ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                    yscale(noline range(0(10)${ht1})) 
                    ytick(0(50)1000)
                    ymtick(0(25)1000)

                    text(40.5 22330 "Barbados" ,  place(e) size(5.5) color(gs8) just(left))
                    text(${nloc6} 22514 "${wlength2}-day wave: Peak of ${peak7} per 100k (Total cases, ${tot7})"  ,  place(e) size(7.5) color(gs8) just(left))
                    text(0 $date3 "${wlength2} day" ,  place(c) size(4.5) color(gs4) just(left))


                    legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                    symysize(5) symxsize(7)
                    order(5 6) 
                    lab(5 "Lower protection")
                    lab(6 "Higher protection")
                    )
                    name(predicted_BRB_long) 
                    ;
            #delimit cr
            graph export "`outputpath'/caserate_predict_long.png", replace width(4000) 



** --------------------------------------------------------------
** SHORTER WAVE LENGTH
** --------------------------------------------------------------
        #delimit ;
            gr twoway 
                /// outer boxes 
                (scatteri `outer1'  , recast(line) lw(2) lc("`red5'%40") fc  (none) )                            
                /// (scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) )
                /// (scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) )
                /// (scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) )

                /// Observed
                ///(line cases date if scenario==0 & iso=="BRB" , sort lc("gs4") lw(0.4) lp("-"))
                (line cases3 date if scenario==0 , sort lc("gs8") lw(0.4) lp("-"))
                (line rcase_av_7 date if scenario==0 , sort lc("`ora'*1.2") lw(0.2) lp("l"))
                (rarea x0 rcase_av_7 date if scenario==0 , sort col("`ora'%40") lw(none))        

                /// Predictions 
                (rarea cases_scen6 cases_scen8 date if iso=="BRB" , sort col("`red1'%10") lw(none))         
                ///(rarea cases_scen7 cases_scen8 date if iso=="BRB" , sort col("`red2'%10") lw(none))         
                ///(rarea cases_scen8 cases_scen9 date if iso=="BRB" , sort col("`red3'%10") lw(none))         
                (rarea cases_scen8 cases_scen10 date if iso=="BRB" , sort col("`red4'%10") lw(none))    

                (rarea cases_scen1 cases_scen3 date if iso=="BRB" , sort col("`red1'%60") lw(none))         
                ///(rarea cases_scen2 cases_scen3 date if iso=="BRB" , sort col("`red2'%60") lw(none))         
                ///(rarea cases_scen3 cases_scen4 date if iso=="BRB" , sort col("`red3'%60") lw(none))         
                (rarea cases_scen3 cases_scen5 date if iso=="BRB" , sort col("`red4'%60") lw(none))         

                /// 60-day wavelength
                (line cases_scen6 date if scenario==6 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                ///(line cases_scen7 date if scenario==7 & iso=="BRB" , sort lc("gs10") lw(0.3) lp("-"))
                (line cases_scen8 date if scenario==8 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                ///(line cases_scen9 date if scenario==9 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                (line cases_scen10 date if scenario==10 & iso=="BRB" , sort lc("gs10") lw(0.1) lp("-"))
                /// 45-day wavelength
                (line cases_scen1 date if scenario==1 & iso=="BRB" , sort lc("gs6") lw(0.3) lp("-"))
                ///(line cases_scen2 date if scenario==2 & iso=="BRB" , sort lc("gs1") lw(0.3) lp("-"))
                (line cases_scen3 date if scenario==3 & iso=="BRB" , sort lc("gs10") lw(0.3) lp("-"))
                ///(line cases_scen4 date if scenario==4 & iso=="BRB" , sort lc("gs6") lw(0.3) lp("-"))
                (line cases_scen5 date if scenario==5 & iso=="BRB" , sort lc("gs10") lw(0.3) lp("-"))
                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    bgcolor(white) 
                    ysize(6) xsize(18)

                    xlab(
                            22462 "1 Jul 2021"
                            22524 "1 Sep 2021" 
                            22585 "1 Nov 2021"
                            22646 "1 Jan 2022"
                    , 
                    labs(4) notick nogrid glc(gs16))
                    xscale(noline   range(22462(10)${date2})) 
                    xtitle("Outbreak month (2021-22)", size(4) margin(l=2 r=2 t=4 b=2)) 

                    ylab(0(200)1000 
                    ,
                    labs(4) nogrid notick glc(gs16) angle(0) format(%9.0f) labgap(2))
                    ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                    yscale(noline range(0(10)${ht1})) 
                    ytick(0(50)1000)
                    ymtick(0(25)1000)

                    text(40.5 22330 "Barbados" ,  place(e) size(5.5) color(gs8) just(left))
                    text(${nloc6} 22514 "${wlength2}-day wave: Peak of ${peak7} per 100k (Total cases, ${tot7})"  ,  place(e) size(7.5) color(gs8) just(left))
                    text(${locw} 22514 "${wlength1}-day wave:  Peak of ${peak2} per 100k (Total cases, ${tot2})"  ,  place(e) size(7.5) color(gs8) just(left))
                    text(0 $date3 "${wlength1} day" ,  place(c) size(4.5) color(gs4) just(left))


                    legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                    symysize(5) symxsize(7)
                    order(7 8) 
                    lab(7 "Lower protection")
                    lab(8 "Higher protection")
                    )
                    name(predicted_BRB_short) 
                    ;
            #delimit cr
            graph export "`outputpath'/caserate_predict_short.png", replace width(4000) 



** Proportion / Numbers severe
** Adults infected with OMICRON approx 1/3 less likely to be hospitalised
** 41. Mia Malan (@miamalan) / Twitter. Twitter. Accessed December 14, 2021. 
** https://twitter.com/miamalan 
** UK Dec 15th (https://www.fil.ion.ucl.ac.uk/spm/covid-19/dashboard/)
**      Dec 15: Approx 74,000 cases
**      Dec 15: Approx 900 admissions
**      Dec 15: Admission rate = 1.2%
**
** Alternatively - lag admissions 1 week behind cases identification
**      Dec 08: Approx 53,000 on Dec 8th
**      Dec 15: Approx 900 admissions 
**      Dec 15: Admission rate = 1.7%

** Percentage hospitalised
global hosp_lo = 0.012
global hosp_hi = 0.020
local ldays = 5
local hdays = 7

** Using 60-day wavelength under assumption of 25% immunity
** Variable = cases_scen7
keep if cases_scen7<.

** Number hospitalised per day
** Low 
gen dhosp_lo = cases_scen7 * $hosp_lo
gen dhosp_hi = cases_scen7 * $hosp_hi

** Cumulative hospitalisation
** Assume a 5 day stay and a 7-day stay
sort date

gen chosp`ldays'_lo = .
gen chosp`hdays'_lo = .
replace chosp`ldays'_lo = (cases_scen7[_n] + cases_scen7[_n-1] + cases_scen7[_n-2] + cases_scen7[_n-3] + cases_scen7[_n-4]) * $hosp_lo
replace chosp`hdays'_lo = (cases_scen7[_n] + cases_scen7[_n-1] + cases_scen7[_n-2] + cases_scen7[_n-3] + cases_scen7[_n-4]) * $hosp_lo

gen chosp`ldays'_hi = .
gen chosp`hdays'_hi = .
replace chosp`ldays'_hi = (cases_scen7[_n] + cases_scen7[_n-1] + cases_scen7[_n-2] + cases_scen7[_n-3] + cases_scen7[_n-4] + cases_scen7[_n-5] + cases_scen7[_n-6]) * $hosp_hi
replace chosp`hdays'_hi = (cases_scen7[_n] + cases_scen7[_n-1] + cases_scen7[_n-2] + cases_scen7[_n-3] + cases_scen7[_n-4] + cases_scen7[_n-5] + cases_scen7[_n-6]) * $hosp_hi

order dhosp* chosp* , after(cases_scen7) 

** Actual Hospital Totals rather than rates
gen clo`ldays' = chosp`ldays'_lo * 2.8
gen chi`ldays' = chosp`ldays'_hi * 2.8
gen clo`hdays' = chosp`hdays'_lo * 2.8
gen chi`hdays' = chosp`hdays'_hi * 2.8
egen pa1 = max(clo`ldays')
egen pa2 = max(chi`ldays')
egen pa3 = max(clo`hdays')
egen pa4 = max(chi`hdays')
global pa1 : dis %5.0fc pa1
global pa2 : dis %5.0fc pa2
global pa3 : dis %5.0fc pa3
global pa4 : dis %5.0fc pa4

** --------------------------------------------------------------
** HOSPITALISATION
** Under scenario: 60-day wave length and 11-25% immunity (cases_scen7)
** --------------------------------------------------------------
        #delimit ;
            gr twoway                           
                (rarea cases_scen7 chosp5_lo date if iso=="BRB" , sort col("`red5'%60") lw(none))         
                (rarea chosp7_hi x0 date if iso=="BRB" , sort col("`red3'%60") lw(none))         
                (rarea chosp5_lo x0 date if iso=="BRB" , sort col("`red2'%60") lw(none))         
        
                (line cases_scen7 date if scenario==7 & iso=="BRB" , sort lc("gs1") lw(0.3) lp("-"))
                (line chosp7_hi date if scenario==7 & iso=="BRB" , sort lc("gs1") lw(0.3) lp("-"))
                (line chosp5_lo date if scenario==7 & iso=="BRB" , sort lc("gs4") lw(0.3) lp("-"))
                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    bgcolor(white) 
                    ysize(6) xsize(18)

                    xlab(
                            22646 "1 Jan 2022"
                            22677 "1 Feb 2022"
                    , 
                    labs(4) notick nogrid glc(gs16))
                    xscale(noline range(22646(10)22677)) 
                    xtitle("Outbreak month (2022)", size(4) margin(l=2 r=2 t=4 b=2)) 

                    ylab(0(200)1000 
                    ,
                    labs(4) nogrid notick glc(gs16) angle(0) format(%9.0f) labgap(2))
                    ytitle("Rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                    yscale(noline range(0(10)${ht1})) 
                    ytick(0(50)1000)
                    ymtick(0(25)1000)

                    text(400 22665 "Peak in hospital (higher): $pa4"  ,  place(e) size(7.5) color(gs8) just(left))
                    text(300 22665 "Peak in hospital (lower): $pa3"  ,  place(e) size(7.5) color(gs8) just(left))
                    /// text(0 $date3 "${wlength2} day" ,  place(c) size(4.5) color(gs4) just(left))


                    legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                    symysize(5) symxsize(7)
                    order(1 2 3) 
                    lab(1 "Cases")
                    lab(2 "Hospitalised (higher estimate)")
                    lab(3 "Hospitalised (lower estimate)")
                    )
                    name(predicted_BRB_hosp) 
                    ;
            #delimit cr
            graph export "`outputpath'/caserate_predict_hosp.png", replace width(4000) 


** Average number of hospitalisations per week over span of outbreak
gen week = week(date) 
order week, after(date)
collapse (mean) av_lo=dhosp_lo av_hi=dhosp_hi , by(week)
tabdisp week, c(av_lo av_hi) format(%9.1f)



/*

** --------------------------------------------------------------
** CONSTRUCTING THE SLIDE SET
** --------------------------------------------------------------

** BULLET
global bullet = uchar(8226)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** SLIDE 1. TITLE THE STORY SO FAR
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 SLIDE DECK"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide deck created by staff of the George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("and the Public Health Group of The Faculty of Medical Sciences, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic   
    putpdf table intro1(1,2)=("For all our COVID-19 surveillance outputs, go to "), halign(left) append
    putpdf table intro1(1,2)=("https://ianhambleton.com/covid19/ "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph  , halign(center) 
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("COVID-19") , font("Calibri Light", 32, 000000) linebreak
    putpdf text ("OMICRON variant: Initial Estimates") , font("Calibri Light", 28, 808080) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  Case estimates.") , font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  Hospitalisation estimates.") , font("Calibri Light", 22, 808080) linebreak

** SLIDE 2. BASIC ASSUMPTIONS
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 outbreaks - the first 15-months"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak

    putpdf paragraph  , halign(left) 
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("CASE RATE ASSUMPTIONS") , font("Calibri Light", 32, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  R-values: Confidence Low to Moderate") , bold font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  R-values: 4.0 then 2.5 then 1.5 then 0.4 then 0.2") , font("Calibri Light", 22, 808080) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  Length of OMICRON wave: Confidence Very Low") , bold font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  Wave length either 60-days or 45-days.") , font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  note: Delta wave was around 3-months") , italic font("Calibri Light", 22, 808080) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  Prior Immunity: Confidence Low") , bold font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  Approx 63% of population double vaccinated.") , font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  Another 10% with prior infection.") , font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  Therefore, almost 75% of residents with some immunity.") , font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  Approx one-third (or 25%) with some immunity might avoid OMICRON.") , font("Calibri Light", 22, 808080) linebreak

** SLIDE 3 - 2021 delta wave
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Estimated OMICRON cases"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_BRB_clean4.png")
    putpdf paragraph 
    putpdf text ("$bullet  Barbados wave 2021 - primarily Delta variant") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    
** SLIDE 4 - 2022 Omicron wave long
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Estimated OMICRON cases"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_predict_long.png")
    putpdf paragraph 
    putpdf text ("$bullet  Barbados wave 2022 - Longer anticipated wave") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak

** SLIDE 5 - 2022 Omicron wave long
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Estimated OMICROM cases"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_predict_short.png")
    putpdf paragraph 
    putpdf text ("$bullet  Barbados wave 2022 - Shortened wave through NPIs") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak


** SLIDE 7 - 2022 Omicron HOSPITALISED
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 outbreaks - the first 15-months"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak

    putpdf paragraph  , halign(left) 
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("HOSPITALISATION ASSUMPTIONS") , font("Calibri Light", 32, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  Hospitalisation Rate: Confidence Low") , bold font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  Higher estimate: 2.0% hospitalised") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("      $bullet  Lower estimate: 1.2% hospitalised") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  Hospitalisation Length: Confidence Very Low") , bold font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  Higher estimate: 7 days in hospital on average") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("      $bullet  Lower estimate: 5 days in hospital on average") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 8 - 2022 Omicron HOSPITALISED graphic
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Estimated OMICROM hospitalisations"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_predict_hosp.png")
    putpdf paragraph 
    putpdf text ("$bullet  Barbados wave 2022 - 60-day wave, 25% immunity") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak



** SLIDE 9 - CONCLUSIONS
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 - OMICRON"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak

    putpdf paragraph  , halign(left) 
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("KEY MESSAGES") , font("Calibri Light", 32, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  CASES") , bold font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  XX") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("      $bullet  XX") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  HOSPITALISATIONS") , bold font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  XX") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("      $bullet  XX") , font("Calibri Light", 24, 999999) linebreak

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    * putpdf save "`outputpath'/COVID-slides-`date_string'", replace
    putpdf save "`outputpath'/COVID-slides-omicron-dec2021", replace,




