** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_slides.do
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
    log using "`logpath'\caricom_slides", replace
** HEADER -----------------------------------------------------

do "X:\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w009\caricom_slides_metrics.do"


** BULLET
global bullet = uchar(8226)

** Color palette (red to green gradation)
    colorpalette RdYlGn, nograph n(5)
    local list r(p) 
    local w1 `r(p1)'    
    local w2 `r(p2)'    
    local w3 `r(p3)'    
    local w4 `r(p4)'    
    local w5 `r(p5)' 

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

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** PAGE 1. TITLE, ATTRIBUTION, DATE of CREATION, PRESENTATION GOALS
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
    putpdf table intro1(1,2)=("www.uwi.edu/covid19/surveillance "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph 
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("COVID-19 in the Caribbean: The Situation So Far") , font("Calibri Light", 28, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  We'll take a quick look at the outbreak history in the Caribbean.") , font("Calibri Light", 22, 808080) linebreak
    putpdf text (" ") , font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  We'll then focus on the past few months.") , font("Calibri Light", 22, 808080) linebreak
    putpdf text (" ") , font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  We'll highlight new metrics for monitoring our outbreaks.") , font("Calibri Light", 22, 808080) linebreak
    putpdf text (" ") , font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  And we'll introduce a way of predicting what comes next.") , font("Calibri Light", 22, 808080) linebreak

** SLIDE 2A. COVID outbreaks 2020 (Suriname)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1A.png")
    putpdf paragraph 
    putpdf text ("$bullet  First major outbreak in Suriname") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  Suriname with 3 waves in first 15 months") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  Third wave coincided with arrival of Gamma variant") , font("Calibri Light", 24, 999999) linebreak


** SLIDE 2B (Trinidad)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1B.png")
    putpdf paragraph 
    putpdf text ("$bullet  Trinidad has seen 2 important waves") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  Latest wave coincided with arrival of Gamma variant") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2C (Jamaica)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1C.png")
    putpdf paragraph 
    putpdf text ("$bullet  Jamaica has dominated the Caribbean with high numbers of cases") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  But using rates their outbreaks have been less dramatic") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2D (Guyana)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1D.png")
    putpdf paragraph 
    putpdf text ("$bullet  Guyana has reported an unusual profile") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  No major wave peaks, but also no periods without community transmission") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2E (The Bahamas)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1E.png")
    putpdf paragraph 
    putpdf text ("$bullet  The Bahamas recorded a large / extended outbreak in 2020") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  And has struggled with containment thereafter") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2F (Barbados)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1F.png")
    putpdf paragraph 
    putpdf text ("$bullet  Barbados generally avoided community transmission in 2020") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  Then one high-profile outbreak began in January 2021") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2G (SURINAME current)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1G.png")
    putpdf paragraph 
    putpdf text ("$bullet  Suriname - outbreak #4") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak

** SLIDE 2H (JAMAICA current)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1H.png")
    putpdf paragraph 
    putpdf text ("$bullet  Suriname - outbreak #4") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Jamaica - outbreak #3") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2I (GUYANA current)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1I.png")
    putpdf paragraph 
    putpdf text ("$bullet  Suriname - outbreak #4") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Jamaica - outbreak #3") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Guyana - Now at their peak") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2J (BAHAMAS current)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1J.png")
    putpdf paragraph 
    putpdf text ("$bullet  Suriname - outbreak #4") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Jamaica - outbreak #3") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Guyana - Now at their peak") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  The Bahamas - Now at their peak") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2K (BARBADOS current)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1K.png")
    putpdf paragraph 
    putpdf text ("$bullet  Suriname - outbreak #4") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Jamaica - outbreak #3") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Guyana - Now at their peak") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  The Bahamas - Now at their peak") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Barbados - 2nd outbreak starting") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2L (TRINIDAD current)
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
    putpdf table intro2(1,16)=("SLIDE 2"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1L.png")
    putpdf paragraph 
    putpdf text ("$bullet  Suriname - outbreak #4") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Jamaica - outbreak #3") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Guyana - Now at their peak") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  The Bahamas - Now at their peak") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Barbados - 2nd outbreak starting") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Trinidad - no new wave yet") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 3 - CARICOM
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
    putpdf table intro2(1,16)=("SLIDE 3"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_CAR.png")
    putpdf paragraph 
    putpdf text ("$bullet  Outbreaks are now coinciding across CARICOM") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  CARICOM overall rates are peaking") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  And they continue to rise") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  10% of all cases / 9% of all deaths, in past 2 weeks") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 4 - Countries with rates rising / falling
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Estimate of Daily Cases after vaccination"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 4"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak

    ** TABLE: NUMBERS
    putpdf paragraph 
    putpdf text (" ") , linebreak
    putpdf table t1 = (16,3), width(100%) halign(center)    
    putpdf table t1(1,1), font("Calibri Light", 20, 000000) colspan(1) border(all, nil) 
    putpdf table t1(1,2), font("Calibri Light", 20, 000000) border(all, nil) 
    putpdf table t1(1,3), font("Calibri Light", 20, 000000) border(all, nil) 
    putpdf table t1(2,1), font("Calibri Light", 20, 000000) border(left,nil) border(right,nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(e6e6e6)  
    putpdf table t1(2,2/3), font("Calibri Light", 18, 000000) border(left,nil) border(right,nil)  border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(e6e6e6) 
    putpdf table t1(1,1)=("Current Outbreaks"), colspan(3) halign(left) font("Calibri Light", 24, 000000)
    putpdf table t1(2,1)=("Country"), halign(center) 
    putpdf table t1(2,2)=("% of peak"), halign(center) 
    putpdf table t1(2,3)=("Trend"), halign(center) 

    putpdf table t1(3,1)=("Antigua & Barbuda"), halign(center)
    putpdf table t1(4,1)=("Bahamas"), halign(center)
    putpdf table t1(5,1)=("Barbados"), halign(center)
    putpdf table t1(6,1)=("Belize"), halign(center)
    putpdf table t1(7,1)=("Dominica"), halign(center)
    putpdf table t1(8,1)=("Grenada"), halign(center)
    putpdf table t1(9,1)=("Guyana"), halign(center)
    putpdf table t1(10,1)=("Haiti"), halign(center)
    putpdf table t1(11,1)=("Jamaica"), halign(center)
    putpdf table t1(12,1)=("St Lucia"), halign(center)
    putpdf table t1(13,1)=("St Kitts & Nevis"), halign(center)
    putpdf table t1(14,1)=("St Vincent & Grenadines"), halign(center)
    putpdf table t1(15,1)=("Suriname"), halign(center)
    putpdf table t1(16,1)=("Trinidad & Tobago"), halign(center)

    putpdf table t1(3,2)=("${rate5_ATG}"), halign(center)
    putpdf table t1(4,2)=("${rate5_BHS}"), halign(center)
    putpdf table t1(5,2)=("${rate5_BRB}"), halign(center)
    putpdf table t1(6,2)=("${rate5_BLZ}"), halign(center)
    putpdf table t1(7,2)=("${rate5_DMA}"), halign(center)
    putpdf table t1(8,2)=("${rate5_GRD}"), halign(center)
    putpdf table t1(9,2)=("${rate5_GUY}"), halign(center)
    putpdf table t1(10,2)=("${rate5_HTI}"), halign(center)
    putpdf table t1(11,2)=("${rate5_JAM}"), halign(center)
    putpdf table t1(12,2)=("${rate5_LCA}"), halign(center)
    putpdf table t1(13,2)=("${rate5_KNA}"), halign(center)
    putpdf table t1(14,2)=("${rate5_VCT}"), halign(center)
    putpdf table t1(15,2)=("${rate5_SUR}"), halign(center)
    putpdf table t1(16,2)=("${rate5_TTO}"), halign(center)

    ** Antigua
    if ${m05_ATG} == 1 {
        putpdf table t1(3,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(3,3)=("${up_ATG}"), halign(center)
    }
    else if ${m05_ATG} == 2 {
        putpdf table t1(3,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(3,3)=("${down_ATG}"), halign(center) 
    }
    ** Bahamas
    if ${m05_BHS} == 1 {
        putpdf table t1(4,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(4,3)=("${up_BHS}"), halign(center) 
    }
    else if ${m05_BHS} == 2 {
        putpdf table t1(4,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(4,3)=("${down_BHS}"), halign(center) 
    }
    ** Barbados
    if ${m05_BRB} == 1 {
        putpdf table t1(5,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(5,3)=("${up_BRB}"), halign(center) 
    }
    else if ${m05_BRB} == 2 {
        putpdf table t1(5,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(5,3)=("${down_BRB}"), halign(center) 
    }
    ** Belize
    if ${m05_BLZ} == 1 {
        putpdf table t1(6,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(6,3)=("${up_BLZ}"), halign(center) 
    }
    else if ${m05_BLZ} == 2 {
        putpdf table t1(6,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(6,3)=("${down_BLZ}"), halign(center)  
    }
    ** Dominica
    if ${m05_DMA} == 1 {
        putpdf table t1(7,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(7,3)=("${up_DMA}"), halign(center) 
    }
    else if ${m05_DMA} == 2 {
        putpdf table t1(7,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(7,3)=("${down_DMA}"), halign(center)   
    }
    ** Grenada
    if ${m05_GRD} == 1 {
        putpdf table t1(8,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(8,3)=("${up_GRD}"), halign(center) 
    }
    else if ${m05_GRD} == 2 {
        putpdf table t1(8,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(8,3)=("${down_GRD}"), halign(center) 
    }
    ** Guyana
    if ${m05_GUY} == 1 {
        putpdf table t1(9,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(9,3)=("${up_GUY}"), halign(center) 
    }
    else if ${m05_GUY} == 2 {
        putpdf table t1(9,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(9,3)=("${down_GUY}"), halign(center) 
    }
    ** Haiti
    if ${m05_HTI} == 1 {
        putpdf table t1(10,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(10,3)=("${up_HTI}"), halign(center) 
    }
    else if ${m05_HTI} == 2 {
        putpdf table t1(10,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(10,3)=("${down_HTI}"), halign(center)  
    }
    ** Jamaica
    if ${m05_JAM} == 1 {
        putpdf table t1(11,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(11,3)=("${up_JAM}"), halign(center) 
    }
    else if ${m05_JAM} == 2 {
        putpdf table t1(11,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(11,3)=("${down_JAM}"), halign(center) 
    }
    ** St.Lucia
    if ${m05_LCA} == 1 {
        putpdf table t1(12,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(12,3)=("${up_LCA}"), halign(center) 
    }
    else if ${m05_LCA} == 2 {
        putpdf table t1(12,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(12,3)=("${down_LCA}"), halign(center) 
    }
    ** St.Kitts
    if ${m05_KNA} == 1 {
        putpdf table t1(13,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(13,3)=("${up_KNA}"), halign(center) 
    }
    else if ${m05_KNA} == 2 {
        putpdf table t1(13,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(13,3)=("${down_KNA}"), halign(center)  
    }
    ** St.Vincent
    if ${m05_VCT} == 1 {
        putpdf table t1(14,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(14,3)=("${up_VCT}"), halign(center) 
    }
    else if ${m05_VCT} == 2 {
        putpdf table t1(14,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(14,3)=("${down_VCT}"), halign(center)   
    }
    ** Suriname
    if ${m05_SUR} == 1 {
        putpdf table t1(15,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(15,3)=("${up_SUR}"), halign(center) 
    }
    else if ${m05_SUR} == 2 {
        putpdf table t1(15,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(15,3)=("${down_SUR}"), halign(center) 
    }
    ** Trinidad
    if ${m05_TTO} == 1 {
        putpdf table t1(16,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(16,3)=("${up_TTO}"), halign(center)
    }
    else if ${m05_TTO} == 2 {
        putpdf table t1(16,1/3), font("Calibri Light", 18, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(16,3)=("${down_TTO}"), halign(center)
    }    


** SLIDE 5 - BARBADOS EXAMPLE
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 outbreaks - Barbados"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 5"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (2,1), width(90%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_BRB_clean.png")
    ///putpdf table f2(2,1)=image("`outputpath'/caserate_predict_BRB.png")

** SLIDE 5 - BARBADOS EXAMPLE
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 outbreaks - Barbados"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=("SLIDE 5"), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (2,1), width(90%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_BRB_clean.png")
    putpdf table f2(2,1)=image("`outputpath'/caserate_predict_BRB.png")

** COUNTRY SURVEILLANCE
** PAGE 1. TITLE, ATTRIBUTION, DATE of CREATION, PRESENTATION GOALS
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
    putpdf table intro1(1,2)=("www.uwi.edu/covid19/surveillance "), halign(left) underline append linebreak 
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

    putpdf paragraph , halign(center) 
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("CARICOM Country Surveillance") , font("Calibri Light", 32, 000000) linebreak


    ** CARICOM 
putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in the Caribbean Community, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

    ** ATG
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Antigua & Barbuda, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

    ** BHS
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in The Bahamas, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

    ** BRB 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Barbados, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)


    ** BLZ
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Belize, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

** DMA 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Dominica, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)


** GRD 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Grenada, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

** GUY 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Guyana, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)


        ** HTI 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Haiti, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)


    ** JAM 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Jamaica, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

        ** KNA 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in St. Kitts & Nevis, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)


        ** LCA 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in St. Lucia, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)


        ** VCT 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in St. Vincent & the Grenadines, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

        ** SUR 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Suriname, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)


    ** TTO 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Trinidad & Tobago, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

** THE UKOTS

    ** AIA 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Anguilla, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)


** BMU 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Bermuda, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

** CYM 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in The Cayman Islands, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

    ** MSR 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Montserrat, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

    ** TCA 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in Turks and Caicos Islands, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)

    ** VGB 
    putpdf pagebreak
    putpdf paragraph ,  font("Calibri Light", 12)
    putpdf text ("Figure. ") , bold
    putpdf text ("COVID-19 case rate in The British Virgin Islands, since April 2020")

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
    putpdf table t1(2,1)=("The number of cases or deaths reported by JHU on a "), italic append halign(left)
    putpdf table t1(2,1)=("given day does not necessarily represent the actual number on that date. "), italic append halign(left)
    putpdf table t1(2,1)=("This is because of the reporting chain that exists between a new case/death and its inclusion in statistics. "), italic append halign(left)


** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/COVID-slides-`date_string'", replace
