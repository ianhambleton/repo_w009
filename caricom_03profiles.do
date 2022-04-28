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
    ** LOWESS smooth on 14 / 7 / 3 day mean rate
    lowess rcase_av_14 date, bwidth(0.1) gen(lowess_14) nograph
    lowess rcase_av_7 date, bwidth(0.1) gen(lowess_7) nograph
    lowess rcase_av_3 date, bwidth(0.1) gen(lowess_3) nograph

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
        lowess rcase_av_14 date if iso=="`country'", bwidth(0.1) gen(lowess_14_`country') name(low14_`country') nograph
        lowess rcase_av_7 date if iso=="`country'", bwidth(0.1) gen(lowess_7_`country') name(low7_`country') nograph
        lowess rcase_av_3 date if iso=="`country'", bwidth(0.1) gen(lowess_3_`country') name(low3_`country') nograph
    }
    sort iso date

    ** Create single LOWESS 14 variable
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
    bysort iso : egen hrate = max(rcase_av_7) 
    ** (b) rate as percetage of highest rate
    sort iso date
    bysort iso : gen rat = (rcase_av_7 / hrate)*100 if iso!=iso[_n+1]
    bysort iso : egen m06 = min(rat)
    drop rat

** Create local macros for the various metrics
** Not: CUB DOM
local clist "AIA ATG BHS BLZ BMU BRB CYM DMA GRD GUY HTI JAM KNA LCA MSR SUR TCA TTO VCT VGB CAR"
foreach country of local clist {

** (1) Total cases
    gen m01_`country'1 = m01 if iso=="`country'"
    egen m01_`country'2 = min(m01_`country'1)
    local m01_`country' = m01_`country'2
    global m01_`country' : dis %9.0fc m01_`country'2
    drop m01_`country'1 m01_`country'2

** (2) Total deaths
    gen m02_`country'1 = m02 if iso=="`country'"
    egen m02_`country'2 = min(m02_`country'1)
    local m02_`country' = m02_`country'2
    global m02_`country' : dis %9.0fc m02_`country'2
    drop m02_`country'1 m02_`country'2

** (3) Cases in past 7 days
    sort iso date 
    gen t1 = tcase - tcase[_n-7] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m03_`country' = t2
    global m03_`country' : dis %9.0fc t2
    drop t1 t2 

** (4) Deaths in past 7 days
    sort iso date 
    gen t1 = tdeath - tdeath[_n-7] if iso!=iso[_n+1] & iso=="`country'"
    egen t2 = min(t1)
    local m04_`country' = t2
    global m04_`country' : dis %9.0fc t2
    drop t1 t2 

** (5) Rate increasing, decreasing or steady in past 7 days (-accelerate-)
    sort iso date
    gen t1 = 1 if iso!=iso[_n+1] & iso=="`country'"
    gen t2 = accelerate7 if t1==1
    egen t3 = min(t2) if iso=="`country'"
    gen t4 = 1 if t3>0 & t1==1
    replace t4 = 2 if t3<0 & t1==1
    egen t5 = min(t4)
    local m05_`country' = t5
    global m05_`country' = t5

    if ${m05_`country'} == 1 {
        global up_`country' = "Rate rising"
    }
    else if ${m05_`country'} == 2 {
        global down_`country' = "Rate falling"
    }
    drop t1 t2 t3 t4 t5

** (6) Rate at % of peak
    gen m06_`country'1 = m06 if iso=="`country'"
    egen m06_`country'2 = min(m06_`country'1)
    local m06_`country' = m06_`country'2
    global m06_`country' : dis %3.0fc m06_`country'2
    drop m06_`country'1 m06_`country'2

    if ${m06_`country'} == 100 {
        global rate5_`country' = "At peak"
    }
    else if ${m06_`country'} < 100 {
        global rate5_`country' = "${m06_`country'}% of peak"
    }

}


** X-axis origin
gen x0 = 0 
sort iso date 

** -------------------------------------------
** THE GRAPHIC
** -------------------------------------------

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
        global maxy = hrate + (hrate/15)
        sort date 
        egen maxx = max(date)
        global maxx = maxx + 10
        egen minx = min(date)
        global minx = minx - 10
        drop maxx minx
        local outer1   $maxy $minx   -0.5 $minx   -0.5 $maxx   $maxy $maxx   $maxy $minx
        ** METRICS outer box
        global metricy = $maxy + ($maxy/2)
        sort date 
        local outer2a  $maxy $minx          $metricy $minx  
        local outer2b  $metricy $minx       $metricy $maxx    
        local outer2c  $maxy $maxx          $metricy $maxx 
        ** Location of COUNTRY name
        global cnamey = $metricy + ($metricy/10)

    ** TEXT POSITIONS
        ** Total Cases
        global xdiff = $maxx - $minx 
        global ydiff = $metricy - $maxy 
        global xpos0 = $minx + (0.1 * ($xdiff/4))
        global xpos1 = $minx + (1.75 * ($xdiff/4))
        global xpos2 = $minx + (2.75 * ($xdiff/4))
        global xpos3 = $minx + (3.75 * ($xdiff/4))
        global ypos1 = $metricy - (1 * ($ydiff/4))
        global ypos2 = $metricy - (2 * ($ydiff/4))
        global ypos3 = $metricy - (3 * ($ydiff/4))

        ** DATE
        local c_date = c(current_date)
    local date_string2 = subinstr("`c_date'", " ", " ", .)

        #delimit ;
            gr twoway 
                /// outer boxes 
                (scatteri `outer1'  , recast(area) lw(0.2) lc(gs10) fc(none) )                            
                (scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) )
                (scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) )
                (scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) )

                /// CARICOM average
                (line lowess_3 date if iso=="`country'" , sort lc("gs8") lw(0.4) lp("-"))
                (line rcase_av_7 date if iso=="`country'" , sort lc("`pur'*1.2") lw(0.2) lp("l"))
                (rarea x0 rcase_av_7 date if iso=="`country'" , sort col("`pur'%40") lw(none))         
    
                ,
                    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
                    bgcolor(white) 
                    ysize(6) xsize(18)
                

                    xlab(
                            22006 "1 Apr 20"
                            22097 "1 Jul 20"
                            22189 "1 Oct 20"
                            22281 "1 Jan 21"
                            22371 "1 Apr 21"
                            22462 "1 Jul 21" 
                            22554 "1 Oct 21" 
                            22646 "1 Jan 22" 
                            22736 "1 Apr 22"
                    , 
                    labs(4) notick nogrid glc(gs16))
                    xscale(noline) 
                    xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                    

                    ylab(0 $maxy   
                    ,
                    labs(4) nogrid notick glc(gs16) angle(0) format(%9.0f))
                    ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                    yscale(noline) 
                    ///ytick(0(5)50)

                    text($ypos1 $xpos0 "${cname_`country'}"         ,  place(e) size(5.5) color(gs0) just(left))
                    text($ypos2 $xpos0 "`date_string2'"         ,  place(e) size(5.5) color(gs0) just(left))

                    text($ypos1 $xpos1 "CASES"                      ,  place(w) size(5) color(gs4) just(left))
                    text($ypos2 $xpos1 "Total: ${m01_`country'}"    ,  place(w) size(5) color(gs8) just(left))
                    text($ypos3 $xpos1 "7-day: ${m03_`country'}"   ,  place(w) size(5) color(`red2') just(left))

                    text($ypos1 $xpos2 "DEATHS"                     ,  place(w) size(5) color(gs4) just(right))
                    text($ypos2 $xpos2 "Total: ${m02_`country'}"    ,  place(w) size(5) color(gs8) just(right))
                    text($ypos3 $xpos2 "7-day: ${m04_`country'}"   ,  place(w) size(5) color(`red2') just(right))

                    text($ypos1 $xpos3 "RATE"                       ,  place(w) size(5) color(gs4) just(right))
                    text($ypos2 $xpos3 "${rate5_`country'} "        ,  place(w) size(5) color(gs8) just(right))
                    text($ypos3 $xpos3 "${up_`country'}"            ,  place(w) size(5) color(`red2') just(right))
                    text($ypos3 $xpos3 "${down_`country'}"          ,  place(w) size(5) color(`gre') just(right))


                    legend(off size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                    region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                    symysize(5) symxsize(7)
                    order(2 4) 
                    lab(4 "CARICOM")
                    lab(2 "Jamaica")
                    )
                    name(cr_`country') 
                    ;
            #delimit cr
            graph export "`outputpath'/caserate_`country'.png", replace width(4000) 
            ** graph export "`webpath'/caserate_`country'.jpg", replace width(3000) quality(100)
            global cname = country
    restore



** SINGLE PAGE PDF
    putpdf begin, pagesize(letter) landscape font("Calibri", 10) margin(top,1cm) margin(bottom,0.5cm) margin(left,1cm) margin(right,1cm)

** PAGE 1. TITLE, ATTRIBUTION, DATE of CREATION, PRESENTATION GOALS
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: ${cname}"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in ${cname}, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_`country'.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)
    ** Save the PDF
    local c_date = c(current_date)
    local date_string2 = subinstr("`c_date'", " ", " ", .)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`webpath'\caserate_`country'", replace
}


** COMPLETE SET FOR CARICOM
** SINGLE PAGE PDF
    putpdf begin, pagesize(letter) landscape font("Calibri", 10) margin(top,1cm) margin(bottom,0.5cm) margin(left,1cm) margin(right,1cm)

** CARICOM REGION
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: CARICOM"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in CARICOM, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_CAR.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)


** PAGE 1. ANGUILLA
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Anguilla"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Anguilla, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_AIA.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)
    
** PAGE 2. ANTIGUA
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Antigua & Barbuda"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Antigua & Barbuda, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_ATG.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 3. BAHAMAS
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: The Bahamas"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in The Bahamas, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_BHS.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 4. BARBADOS
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Barbados"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Barbados, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_BRB.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 5. BELIZE
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Belize"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Belize, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_BLZ.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 6. Bermuda
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Bermuda"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Bermuda, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_BMU.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 7. British Virgin Islands
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: British Virgin Islands"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in the British Virgin Islands, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_VGB.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 8. the Cayman Islands
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Cayman Islands"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in the Cayman Islands, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_CYM.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 9. Dominica
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Dominica"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Dominica, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_DMA.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 10. Grenada
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Grenada"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Grenada, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_GRD.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 11. Guyana
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Guyana"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Guyana, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_GUY.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 12. Haiti
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Haiti"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Haiti, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_HTI.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 12. Jamaica
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Jamaica"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Jamaica, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_JAM.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 13. Montserrat
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Montserrat"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Montserrat, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_MSR.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 14. St.Kitts & Nevis
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: St.Kitts & Nevis"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in St.Kitts & Nevis, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_KNA.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 15. St.Lucia
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: St.Lucia"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in St.Lucia, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_LCA.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 16. St.Vincent & the Grenadines
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: St.Vincent & the Grenadines"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in St.Vincent & the Grenadines, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_VCT.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 17. Suriname
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Suriname"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Suriname, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_SUR.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 18. Trinidad & Tobago
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Trinidad & Tobago"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Trinidad & Tobago, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_TTO.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)

** PAGE 19. the Turks & Caicos Islands
putpdf pagebreak
    putpdf table intro1 = (1,16), width(100%) halign(left) 
    putpdf table intro1(.,.), border(all, nil)
    putpdf table intro1(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro1(1,1)
    putpdf table intro1(1,2), colspan(15)
    putpdf table intro1(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro1(1,2)=("COVID-19 Case Rate Profile: Turks & Caicos Islands"), halign(left) linebreak font("Calibri Light", 20 , 000000)
    putpdf table intro1(1,2)=("Slide created by Ian Hambleton, George Alleyne Chronic Disease Research Centre "), append halign(left) 
    putpdf table intro1(1,2)=("Caribbean Institute of Health Research, Cave Hill Campus, "), halign(left) append  
    putpdf table intro1(1,2)=("The University of the West Indies. "), halign(left) append 
    putpdf table intro1(1,2)=("COVID-19 Public Health Group Contacts: Ian Hambleton (analytics), Maddy Murphy (public health interventions), "), halign(left) append italic  
    putpdf table intro1(1,2)=("Kim Quimby (logistics planning), Natasha Sobers (surveillance). "), halign(left) append italic linebreak   
    putpdf table intro1(1,2)=("For regular COVID-19 surveillance outputs, go to "), halign(left) append 
    putpdf table intro1(1,2)=("www.ianhambleton.com/covid19 "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in the Turks & Caicos Islands, from April 2020")
    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/caserate_TCA.png")
    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("The Case Rate: "), bold halign(left)
    putpdf table t1(1,1)=("calculated as the number of daily new cases, divided by the country population (x 100,000). Solid line is 14-day smoothed average. Dotted line is lowess smooth, used to define rising or falling case rate."), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case and its inclusion in statistics. "), italic append halign(left)


    ** Save the PDF
    local c_date = c(current_date)
    local date_string2 = subinstr("`c_date'", " ", " ", .)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`webpath'\caserate_CARICOM", replace
