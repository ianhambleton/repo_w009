** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_slide1.do
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
    log using "`logpath'\caricom_slide1", replace
** HEADER -----------------------------------------------------

** Data from -02initialprep- 
use "`datapath'\caricom_covid", clear
rename new_cases case
rename new_deaths death
rename total_cases tcase
rename total_deaths tdeath 
rename countryregion country 

** Keep CARICOM only
keep if group==1 | group==2 

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

** SMOOTHED CASE rate 
bysort iso : asrol rcase , stat(mean) window(date 14) gen(rcase_av_14)
bysort iso : asrol rcase , stat(mean) window(date 28) gen(rcase_av_28)

** X-axis origin
gen x0 = 0 
sort iso date



** SURINAME
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%45") lw(none))

            /// TRINIDAD
            /// (line rcase_av_14 date if iso=="TTO" , sort lc("`pur'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="TTO" , sort col("`pur'%35") lw(none))

            /// JAMAICA
            /// (line rcase_av_14 date if iso=="JAM" , sort lc("`blu'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="JAM"  , sort col("`blu'%35") lw(none))

            /// GUYANA
            /// (line rcase_av_14 date if iso=="GUY" , sort lc("`gre'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="GUY"  , sort col("`gre'%35") lw(none))

            /// BAHAMAS
            /// (line rcase_av_28 date if iso=="BHS" , sort lc("`red'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_28 date if iso=="BHS"  , sort col("`red'%35") lw(none))

            /// BARBADOS
            /// (line rcase_av_14 date if iso=="BRB" , sort lc("`ora'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="BRB" , sort col("`ora'%35") lw(none))
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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline range(22006(10)22645)) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(10)60   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(5)60)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 ) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1A) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1A.png", replace width(4000) 

** SURINAME + TRINIDAD
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%45") lw(none))

            /// JAMAICA
            /// (line rcase_av_14 date if iso=="JAM"  & date < d(1apr2021), sort lc("`blu'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1apr2021) , sort col("`blu'%35") lw(none))

            /// GUYANA
            /// (line rcase_av_14 date if iso=="GUY" & date < d(1apr2021) , sort lc("`gre'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1apr2021)  , sort col("`gre'%35") lw(none))

            /// BAHAMAS
            /// (line rcase_av_28 date if iso=="BHS" & date < d(1apr2021) , sort lc("`red'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1apr2021)  , sort col("`red'%35") lw(none))

            /// BARBADOS
            /// (line rcase_av_14 date if iso=="BRB" & date < d(1apr2021) , sort lc("`ora'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1apr2021) , sort col("`ora'%35") lw(none))
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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline range(22006(10)22645)) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(10)60   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(5)60)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1B) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1B.png", replace width(4000) 

** SURINAME + TRINIDAD + JAMAICA
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%10") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%45") lw(none))

            /// GUYANA
            /// (line rcase_av_14 date if iso=="GUY" & date < d(1apr2021) , sort lc("`gre'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1apr2021)  , sort col("`gre'%35") lw(none))

            /// BAHAMAS
            /// (line rcase_av_28 date if iso=="BHS" & date < d(1apr2021) , sort lc("`red'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1apr2021)  , sort col("`red'%35") lw(none))

            /// BARBADOS
            /// (line rcase_av_14 date if iso=="BRB" & date < d(1apr2021) , sort lc("`ora'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1apr2021) , sort col("`ora'%35") lw(none))
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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline range(22006(10)22645)) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(10)60   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(5)60)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1C) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1C.png", replace width(4000) 


** SURINAME + TRINIDAD + JAMAICA + GUYANA
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%10") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%10") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY" & date < d(1aug2021) , sort lc("`gre'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1aug2021)  , sort col("`gre'%45") lw(none))

            /// BAHAMAS
            /// (line rcase_av_28 date if iso=="BHS" & date < d(1apr2021) , sort lc("`red'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1apr2021)  , sort col("`red'%35") lw(none))

            /// BARBADOS
            /// (line rcase_av_14 date if iso=="BRB" & date < d(1apr2021) , sort lc("`ora'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1apr2021) , sort col("`ora'%35") lw(none))
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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline range(22006(10)22645)) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(10)60   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(5)60)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1D) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1D.png", replace width(4000) 


** SURINAME + TRINIDAD + JAMAICA + GUYANA + BAHAMAS
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%10") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%10") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY" & date < d(1aug2021) , sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1aug2021)  , sort col("`gre'%10") lw(none))

            /// BAHAMAS
            (line rcase_av_28 date if iso=="BHS" & date < d(1aug2021) , sort lc("`red'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1aug2021)  , sort col("`red'%45") lw(none))

            /// BARBADOS
            /// (line rcase_av_14 date if iso=="BRB" & date < d(1apr2021) , sort lc("`ora'%50") lw(0.2) lp("l"))
            /// (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1apr2021) , sort col("`ora'%35") lw(none))
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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline range(22006(10)22645)) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(10)60   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(5)60)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8 10) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1E) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1E.png", replace width(4000) 

** SURINAME + TRINIDAD + JAMAICA + GUYANA + BAHAMAS + BARBADOS
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%10") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%10") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY" & date < d(1aug2021) , sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1aug2021)  , sort col("`gre'%10") lw(none))

            /// BAHAMAS
            (line rcase_av_28 date if iso=="BHS" & date < d(1aug2021) , sort lc("`red'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1aug2021)  , sort col("`red'%10") lw(none))

            /// BARBADOS
            (line rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort lc("`ora'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort col("`ora'%45") lw(none))
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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline range(22006(10)22645)) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(10)60   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(5)60)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8 10 12) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1F) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1F.png", replace width(4000) 



** SURINAME - to END 2021
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%45") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%10") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%10") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY" & date < d(1aug2021) , sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1aug2021)  , sort col("`gre'%10") lw(none))

            /// BAHAMAS
            (line rcase_av_28 date if iso=="BHS" & date < d(1aug2021) , sort lc("`red'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1aug2021)  , sort col("`red'%10") lw(none))

            /// BARBADOS
            (line rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort lc("`ora'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort col("`ora'%10") lw(none))

            // SURINAME to now
            (line rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`yel'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`yel'%45") lw(none))
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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(20)160   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(20)160)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8 10 12) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1G) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1G.png", replace width(4000) 



** SURINAME + JAMAICA - to now
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%10") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%45") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY" & date < d(1aug2021) , sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1aug2021)  , sort col("`gre'%10") lw(none))

            /// BAHAMAS
            (line rcase_av_28 date if iso=="BHS" & date < d(1aug2021) , sort lc("`red'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1aug2021)  , sort col("`red'%10") lw(none))

            /// BARBADOS
            (line rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort lc("`ora'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort col("`ora'%10") lw(none))

            // SURINAME to now
            (line rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`yel'%10") lw(none))

            // JAMAICA to now
            (line rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`blu'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`blu'%45") lw(none))


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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(20)160   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(20)160)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8 10 12) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1H) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1H.png", replace width(4000) 


** SURINAME + JAMAICA + GUYANA - to now
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%10") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%10") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY" & date < d(1aug2021) , sort lc("`gre'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1aug2021)  , sort col("`gre'%45") lw(none))

            /// BAHAMAS
            (line rcase_av_28 date if iso=="BHS" & date < d(1aug2021) , sort lc("`red'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1aug2021)  , sort col("`red'%10") lw(none))

            /// BARBADOS
            (line rcase_av_14 date if iso=="BRB" & date < d(3aug2021) , sort lc("`ora'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(3aug2021) , sort col("`ora'%10") lw(none))

            // SURINAME to now
            (line rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`yel'%10") lw(none))

            // JAMAICA to now
            (line rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`blu'%10") lw(none))

            // GUYANA to now
            (line rcase_av_14 date if iso=="GUY" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`gre'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`gre'%45") lw(none))

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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(20)160   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(20)160)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8 10 12) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1I) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1I.png", replace width(4000) 


** SURINAME + JAMAICA + GUYANA + BAHAMAS - to now
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%10") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%10") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY" & date < d(1aug2021) , sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1aug2021)  , sort col("`gre'%10") lw(none))

            /// BAHAMAS
            (line rcase_av_28 date if iso=="BHS" & date < d(1aug2021) , sort lc("`red'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1aug2021)  , sort col("`red'%45") lw(none))

            /// BARBADOS
            (line rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort lc("`ora'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort col("`ora'%10") lw(none))

            // SURINAME to now
            (line rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`yel'%10") lw(none))

            // JAMAICA to now
            (line rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`blu'%10") lw(none))

            // GUYANA to now
            (line rcase_av_14 date if iso=="GUY" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`gre'%10") lw(none))

            // BAHAMAS to now
            (line rcase_av_14 date if iso=="BHS" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`red'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BHS" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`red'%45") lw(none))

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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(20)160   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(20)160)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8 10 12) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1J) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1J.png", replace width(4000) 



** SURINAME + JAMAICA + GUYANA + BAHAMAS + BARBADOS - to now
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%10") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%10") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY" & date < d(1aug2021) , sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1aug2021)  , sort col("`gre'%10") lw(none))

            /// BAHAMAS
            (line rcase_av_28 date if iso=="BHS" & date < d(1aug2021) , sort lc("`red'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1aug2021)  , sort col("`red'%10") lw(none))

            /// BARBADOS
            (line rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort lc("`ora'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort col("`ora'%45") lw(none))

            // SURINAME to now
            (line rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`yel'%10") lw(none))

            // JAMAICA to now
            (line rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`blu'%10") lw(none))

            // GUYANA to now
            (line rcase_av_14 date if iso=="GUY" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`gre'%10") lw(none))

            // BAHAMAS to now
            (line rcase_av_14 date if iso=="BHS" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`red'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BHS" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`red'%10") lw(none))

            // BARBADOS to now
            (line rcase_av_14 date if iso=="BRB" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`ora'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`ora'%45") lw(none))

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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(20)160   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(20)160)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8 10 12) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1K) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1K.png", replace width(4000) 




** SURINAME + JAMAICA + GUYANA + BAHAMAS + BARBADOS + TRINIDAD - to now
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR" & date < d(1aug2021), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date < d(1aug2021)  , sort col("`yel'%10") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort lc("`pur'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO"  & date < d(1aug2021), sort col("`pur'%45") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  & date < d(1aug2021), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"  & date < d(1aug2021) , sort col("`blu'%10") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY" & date < d(1aug2021) , sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date < d(1aug2021)  , sort col("`gre'%10") lw(none))

            /// BAHAMAS
            (line rcase_av_28 date if iso=="BHS" & date < d(1aug2021) , sort lc("`red'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_28 date if iso=="BHS" & date < d(1aug2021)  , sort col("`red'%10") lw(none))

            /// BARBADOS
            (line rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort lc("`ora'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB" & date < d(1aug2021) , sort col("`ora'%10") lw(none))

            // SURINAME to now
            (line rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`yel'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`yel'%10") lw(none))

            // JAMAICA to now
            (line rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`blu'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`blu'%10") lw(none))

            // GUYANA to now
            (line rcase_av_14 date if iso=="GUY" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`gre'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`gre'%10") lw(none))

            // BAHAMAS to now
            (line rcase_av_14 date if iso=="BHS" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`red'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BHS" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`red'%10") lw(none))

            // BARBADOS to now
            (line rcase_av_14 date if iso=="BRB" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`ora'%20") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`ora'%10") lw(none))

            // TRINIDAD to now
            (line rcase_av_14 date if iso=="TTO" & date >= d(3aug2021) & date < d(31jan2022), sort lc("`pur'%50") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO" & date >= d(3aug2021) & date < d(31jan2022)  , sort col("`pur'%45") lw(none))


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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(20)160   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(20)160)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8 10 12) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1L) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1L.png", replace width(4000) 




** SURINAME + JAMAICA + GUYANA + BAHAMAS + BARBADOS + TRINIDAD - to now
    #delimit ;
        gr twoway             
            /// SURINAME
            (line rcase_av_14 date if iso=="SUR"  , sort lc("`yel'%40") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="SUR" , sort col("`yel'%25") lw(none))

            /// TRINIDAD
            (line rcase_av_14 date if iso=="TTO"  , sort lc("`pur'%40") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="TTO" , sort col("`pur'%25") lw(none))

            /// JAMAICA
            (line rcase_av_14 date if iso=="JAM"  , sort lc("`blu'%40") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="JAM"   , sort col("`blu'%25") lw(none))

            /// GUYANA
            (line rcase_av_14 date if iso=="GUY"  , sort lc("`gre'%40") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="GUY"  , sort col("`gre'%25") lw(none))

            /// BAHAMAS
            (line rcase_av_28 date if iso=="BHS" , sort lc("`red'%40") lw(0.2) lp("l"))
            (rarea x0 rcase_av_28 date if iso=="BHS"   , sort col("`red'%25") lw(none))

            /// BARBADOS
            (line rcase_av_14 date if iso=="BRB"  , sort lc("`ora'%40") lw(0.2) lp("l"))
            (rarea x0 rcase_av_14 date if iso=="BRB"  , sort col("`ora'%25") lw(none))


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
                        22676 " "
                   , 
                labs(3) notick nogrid glc(gs16))
                xscale(noline) 
                xtitle("Outbreak month (2020 to 2021)", size(4) margin(l=2 r=2 t=4 b=2)) 
                

                ylab(0(20)160   
                ,
                labs(3) nogrid glc(gs16) angle(0) format(%9.0f))
                ytitle("Case rate per 100,000", size(4) margin(l=2 r=2 t=2 b=2)) 
                ytick(0(20)160)

                legend(size(4) position(11) ring(0) bm(t=1 b=1 l=1 r=1) colf cols(1) lw(0.1)
                region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2) lc(gs16)) 
                symysize(5) symxsize(7)
                order(2 4 6 8 10 12) 
                lab(2 "Suriname")
                lab(4 "Trinidad & Tobago")
                lab(6 "Jamaica")
                lab(8 "Guyana")
                lab(10 "The Bahamas")
                lab(12 "Barbados")
                )
                name(slide_1M) 
                ;
        #delimit cr
        graph export "`outputpath'/slide1M.png", replace width(4000) 


/*
** Proportion of deaths in EACH outbreak
** Outbreak 1: Aug-Nov 2020
** Outbreak 2: May onwards
keep if iso=="TTO"
gen outbreak = 0
replace outbreak = 1 if date >= d(1aug2020) & date <= d(30nov2020)
replace outbreak = 2 if date >= d(1may2021)
collapse (sum) case death , by(outbreak)
egen tcase = sum(case)
egen tdeath = sum(death)
gen pdeath = (death / tdeath) * 100


    ** Save to PDF file
    putpdf begin, pagesize(letter) landscape font("Calibri", 10) margin(top,1cm) margin(bottom,0.5cm) margin(left,1cm) margin(right,1cm)

    ** Figure 1 Title 
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate `sup1' in Trinidad & Tobago, and in 4 CARICOM comparator countries, between April 2020 and August 2021")

    putpdf table fig1 = (1,1), width(100%) halign(left)    
    putpdf table fig1(.,.), border(all, nil) valign(center)
    putpdf table fig1(1,1) = image("`outputpath'/paper_tto_caserate_$S_DATE.png")

    putpdf table t1 = (2,1), width(95%) halign(center)    
    putpdf table t1(1/2,1), font("Calibri Light", 9, 808080) border(all, nil) 
    putpdf table t1(1,1)=("(1) "), bold halign(left)
    putpdf table t1(1,1)=("Case rate was calculated as the number of daily new cases, divided by the country population (x 100,000), and presented as 14-day smoothed average. "), append halign(left)
    putpdf table t1(2,1)=("Data Source: "), bold italic append halign(left)
    putpdf table t1(2,1)=("The Center for Systems Science and Engineering (CSSE) at Johns Hopkins University (JHU) "), italic append halign(left)
    putpdf table t1(2,1)=("(https://github.com/CSSEGISandData/COVID-19). This cases & deaths dataset is updated daily. "), italic append halign(left)
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)
    putpdf table t1(2,1)=("Negative case and death values can sometimes appear when a country corrects historical data. "), italic append halign(left)

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'\caricom_figure_`date_string'", replace
