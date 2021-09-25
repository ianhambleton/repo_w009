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

    ** DO file path
    local dopath "X:\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w009\slidedeck1\"

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
    log using "`logpath'\caricom_slides", replace
** HEADER -----------------------------------------------------

** Gather globals
** We do this via 
** slidedeck1_03_metrics.do
do "`dopath'/slidedeck1_03_metrics.do"


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

** PAGE 2. TITLE, ATTRIBUTION, DATE of CREATION, PRESENTATION GOALS
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
    putpdf text ("COVID-19 in the Caribbean") , font("Calibri Light", 32, 000000) linebreak
    putpdf text ("Situation Analysis") , font("Calibri Light", 28, 808080) linebreak
    ///putpdf text (" ") , font("Calibri Light", 22, 808080) linebreak
    ///putpdf text ("      $bullet  We'll highlight new metrics for monitoring our outbreaks.") , font("Calibri Light", 22, 808080) linebreak
    ///putpdf text (" ") , font("Calibri Light", 22, 808080) linebreak
    ///putpdf text ("      $bullet  And we'll introduce a way of predicting what comes next.") , font("Calibri Light", 22, 808080) linebreak


** PAGE 1. TITLE THE STORY SO FAR
putpdf pagebreak
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
    putpdf text ("COVID-19 in the Caribbean") , font("Calibri Light", 32, 000000) linebreak
    putpdf text ("Part 1: The Story So Far") , font("Calibri Light", 28, 808080) linebreak
    putpdf text (" ") , font("Calibri Light", 28, 000000) linebreak
    putpdf text ("      $bullet  We'll take a quick look at the outbreak history in the Caribbean.") , font("Calibri Light", 22, 808080) linebreak
    putpdf text ("      $bullet  We'll then focus on the past few months.") , font("Calibri Light", 22, 808080) linebreak


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
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
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
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
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
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
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
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
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
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
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
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
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
    putpdf table intro2(1,2)=("COVID-19 outbreaks - now adding Aug and Sep 2021"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
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
    putpdf table intro2(1,2)=("COVID-19 outbreaks - now adding Aug and Sep 2021"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
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
    putpdf table intro2(1,2)=("COVID-19 outbreaks - now adding Aug and Sep 2021"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
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
    putpdf table intro2(1,2)=("COVID-19 outbreaks - now adding Aug and Sep 2021"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1J.png")
    putpdf paragraph 
    putpdf text ("$bullet  Suriname - outbreak #4") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Jamaica - outbreak #3") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Guyana - Now at their peak") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  The Bahamas - Experiencing a third extended wave") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2K (BARBADOS current)
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 outbreaks - now adding Aug and Sep 2021"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1K.png")
    putpdf paragraph 
    putpdf text ("$bullet  Suriname - outbreak #4") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Jamaica - outbreak #3") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Guyana - Now at their peak") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  The Bahamas - Experiencing a third extended wave") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Barbados - 2nd outbreak underway") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 2L (TRINIDAD current)
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 outbreaks - now adding Aug and Sep 2021"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/slide1L.png")
    putpdf paragraph 
    putpdf text ("$bullet  Suriname - outbreak #4") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Jamaica - outbreak #3") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Guyana - Now at their peak") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  The Bahamas - Experiencing a third extended wave") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Barbados - 2nd outbreak underway") , font("Calibri Light", 24, 999999) linebreak
    putpdf text ("$bullet  Trinidad - no new wave yet") , font("Calibri Light", 24, 999999) linebreak




** SLIDE 3. CURRENT SITUATION
putpdf pagebreak
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

    putpdf paragraph, halign(center)  
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("COVID-19 in the Caribbean") , font("Calibri Light", 32, 000000) linebreak
    putpdf text ("Part 2: Current Situation") , font("Calibri Light", 28, 808080) linebreak




** SLIDE 4 - CARICOM
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("COVID-19 outbreaks - CARICOM rates"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (1,1), width(100%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_CAR.png")
    putpdf paragraph 
    putpdf text ("$bullet  Outbreaks are now coinciding across CARICOM") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  CARICOM overall rates are peaking") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  And they continue to rise") , font("Calibri Light", 24, 999999) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("$bullet  ${p14_CAR} percent of all cases in past 2 weeks") , font("Calibri Light", 24, 999999) linebreak

** SLIDE 5 - Countries with rates rising / falling
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Summary of CARICOM cases "), halign(left) 
    putpdf table intro2(1,2)=("(Updated: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak

    ** TABLE: NUMBERS
    putpdf paragraph 
    ///putpdf text (" ") , linebreak
    putpdf table t1 = (21,5), width(100%) halign(center)    
    ///putpdf table t1(1,1/5), font("Calibri Light", 18, 000000) border(all, nil) 
    putpdf table t1(1,1), font("Calibri Light", 16, 000000) border(left,nil) border(right,nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(e6e6e6)  
    putpdf table t1(1,2/5), font("Calibri Light", 14, 000000) border(left,nil) border(right,nil)  border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(e6e6e6) 
    ///putpdf table t1(1,1)=("Current Outbreaks"), colspan(3) halign(left) font("Calibri Light", 24, 000000)
    putpdf table t1(1,1)=("Country"), halign(center) 
    putpdf table t1(1,2)=("# cases (14d)"), halign(center) 
    putpdf table t1(1,3)=("rate (100k)"), halign(center) 
    putpdf table t1(1,4)=("% of peak"), halign(center) 
    putpdf table t1(1,5)=("Trend"), halign(center) 

    putpdf table t1(2,1)=("Antigua & Barbuda"), halign(center)
    putpdf table t1(3,1)=("Bahamas"), halign(center)
    putpdf table t1(4,1)=("Barbados"), halign(center)
    putpdf table t1(5,1)=("Belize"), halign(center)
    putpdf table t1(6,1)=("Dominica"), halign(center)
    putpdf table t1(7,1)=("Grenada"), halign(center)
    putpdf table t1(8,1)=("Guyana"), halign(center)
    putpdf table t1(9,1)=("Haiti"), halign(center)
    putpdf table t1(10,1)=("Jamaica"), halign(center)
    putpdf table t1(11,1)=("St Lucia"), halign(center)
    putpdf table t1(12,1)=("St Kitts & Nevis"), halign(center)
    putpdf table t1(13,1)=("St Vincent & Gren"), halign(center)
    putpdf table t1(14,1)=("Suriname"), halign(center)
    putpdf table t1(15,1)=("Trinidad & Tobago"), halign(center)
    putpdf table t1(16,1)=("Anguilla"), halign(center)
    putpdf table t1(17,1)=("Bermuda"), halign(center)
    putpdf table t1(18,1)=("BVI"), halign(center)
    putpdf table t1(19,1)=("Cayman"), halign(center)
    putpdf table t1(20,1)=("Montserrat"), halign(center)
    putpdf table t1(21,1)=("Turks & Caicos"), halign(center)

    putpdf table  t1(2,2)=("${m03_ATG}"), halign(center)
    putpdf table  t1(3,2)=("${m03_BHS}"), halign(center)
    putpdf table  t1(4,2)=("${m03_BRB}"), halign(center)
    putpdf table  t1(5,2)=("${m03_BLZ}"), halign(center)
    putpdf table  t1(6,2)=("${m03_DMA}"), halign(center)
    putpdf table  t1(7,2)=("${m03_GRD}"), halign(center)
    putpdf table  t1(8,2)=("${m03_GUY}"), halign(center)
    putpdf table  t1(9,2)=("${m03_HTI}"), halign(center)
    putpdf table t1(10,2)=("${m03_JAM}"), halign(center)
    putpdf table t1(11,2)=("${m03_LCA}"), halign(center)
    putpdf table t1(12,2)=("${m03_KNA}"), halign(center)
    putpdf table t1(13,2)=("${m03_VCT}"), halign(center)
    putpdf table t1(14,2)=("${m03_SUR}"), halign(center)
    putpdf table t1(15,2)=("${m03_TTO}"), halign(center)
    putpdf table t1(16,2)=("${m03_AIA}"), halign(center)
    putpdf table t1(17,2)=("${m03_BMU}"), halign(center)
    putpdf table t1(18,2)=("${m03_VGB}"), halign(center)
    putpdf table t1(19,2)=("${m03_CYM}"), halign(center)
    putpdf table t1(20,2)=("${m03_MSR}"), halign(center)
    putpdf table t1(21,2)=("${m03_TCA}"), halign(center)

    putpdf table  t1(2,3)=("${rate_ATG}"), halign(center)
    putpdf table  t1(3,3)=("${rate_BHS}"), halign(center)
    putpdf table  t1(4,3)=("${rate_BRB}"), halign(center)
    putpdf table  t1(5,3)=("${rate_BLZ}"), halign(center)
    putpdf table  t1(6,3)=("${rate_DMA}"), halign(center)
    putpdf table  t1(7,3)=("${rate_GRD}"), halign(center)
    putpdf table  t1(8,3)=("${rate_GUY}"), halign(center)
    putpdf table  t1(9,3)=("${rate_HTI}"), halign(center)
    putpdf table t1(10,3)=("${rate_JAM}"), halign(center)
    putpdf table t1(11,3)=("${rate_LCA}"), halign(center)
    putpdf table t1(12,3)=("${rate_KNA}"), halign(center)
    putpdf table t1(13,3)=("${rate_VCT}"), halign(center)
    putpdf table t1(14,3)=("${rate_SUR}"), halign(center)
    putpdf table t1(15,3)=("${rate_TTO}"), halign(center)
    putpdf table t1(16,3)=("${rate_AIA}"), halign(center)
    putpdf table t1(17,3)=("${rate_BMU}"), halign(center)
    putpdf table t1(18,3)=("${rate_VGB}"), halign(center)
    putpdf table t1(19,3)=("${rate_CYM}"), halign(center)
    putpdf table t1(20,3)=("${rate_MSR}"), halign(center)
    putpdf table t1(21,3)=("${rate_TCA}"), halign(center)

    putpdf table  t1(2,4)=("${rate5_ATG}"), halign(center)
    putpdf table  t1(3,4)=("${rate5_BHS}"), halign(center)
    putpdf table  t1(4,4)=("${rate5_BRB}"), halign(center)
    putpdf table  t1(5,4)=("${rate5_BLZ}"), halign(center)
    putpdf table  t1(6,4)=("${rate5_DMA}"), halign(center)
    putpdf table  t1(7,4)=("${rate5_GRD}"), halign(center)
    putpdf table  t1(8,4)=("${rate5_GUY}"), halign(center)
    putpdf table  t1(9,4)=("${rate5_HTI}"), halign(center)
    putpdf table t1(10,4)=("${rate5_JAM}"), halign(center)
    putpdf table t1(11,4)=("${rate5_LCA}"), halign(center)
    putpdf table t1(12,4)=("${rate5_KNA}"), halign(center)
    putpdf table t1(13,4)=("${rate5_VCT}"), halign(center)
    putpdf table t1(14,4)=("${rate5_SUR}"), halign(center)
    putpdf table t1(15,4)=("${rate5_TTO}"), halign(center)
    putpdf table t1(16,4)=("${rate5_AIA}"), halign(center)
    putpdf table t1(17,4)=("${rate5_BMU}"), halign(center)
    putpdf table t1(18,4)=("${rate5_VGB}"), halign(center)
    putpdf table t1(19,4)=("${rate5_CYM}"), halign(center)
    putpdf table t1(20,4)=("${rate5_MSR}"), halign(center)
    putpdf table t1(21,4)=("${rate5_TCA}"), halign(center)

    ** Antigua
    if ${m05_ATG} == 1 {
        putpdf table t1(2,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(2,5)=("${up_ATG}"), halign(center)
    }
    else if ${m05_ATG} == 2 {
        putpdf table t1(2,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(2,5)=("${down_ATG}"), halign(center) 
    }
    ** Bahamas
    if ${m05_BHS} == 1 {
        putpdf table t1(3,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(3,5)=("${up_BHS}"), halign(center) 
    }
    else if ${m05_BHS} == 2 {
        putpdf table t1(3,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(3,5)=("${down_BHS}"), halign(center) 
    }
    ** Barbados
    if ${m05_BRB} == 1 {
        putpdf table t1(4,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(4,5)=("${up_BRB}"), halign(center) 
    }
    else if ${m05_BRB} == 2 {
        putpdf table t1(4,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(4,5)=("${down_BRB}"), halign(center) 
    }
    ** Belize
    if ${m05_BLZ} == 1 {
        putpdf table t1(5,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(5,5)=("${up_BLZ}"), halign(center) 
    }
    else if ${m05_BLZ} == 2 {
        putpdf table t1(5,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(5,5)=("${down_BLZ}"), halign(center)  
    }
    ** Dominica
    if ${m05_DMA} == 1 {
        putpdf table t1(6,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(6,5)=("${up_DMA}"), halign(center) 
    }
    else if ${m05_DMA} == 2 {
        putpdf table t1(6,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(6,5)=("${down_DMA}"), halign(center)   
    }
    ** Grenada
    if ${m05_GRD} == 1 {
        putpdf table t1(7,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(7,5)=("${up_GRD}"), halign(center) 
    }
    else if ${m05_GRD} == 2 {
        putpdf table t1(7,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(7,5)=("${down_GRD}"), halign(center) 
    }
    ** Guyana
    if ${m05_GUY} == 1 {
        putpdf table t1(8,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(8,5)=("${up_GUY}"), halign(center) 
    }
    else if ${m05_GUY} == 2 {
        putpdf table t1(8,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(8,5)=("${down_GUY}"), halign(center) 
    }
    ** Haiti
    if ${m05_HTI} == 1 {
        putpdf table t1(9,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(9,5)=("${up_HTI}"), halign(center) 
    }
    else if ${m05_HTI} == 2 {
        putpdf table t1(9,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(9,5)=("${down_HTI}"), halign(center)  
    }
    ** Jamaica
    if ${m05_JAM} == 1 {
        putpdf table t1(10,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(10,5)=("${up_JAM}"), halign(center) 
    }
    else if ${m05_JAM} == 2 {
        putpdf table t1(10,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(10,5)=("${down_JAM}"), halign(center) 
    }
    ** St.Lucia
    if ${m05_LCA} == 1 {
        putpdf table t1(11,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(11,5)=("${up_LCA}"), halign(center) 
    }
    else if ${m05_LCA} == 2 {
        putpdf table t1(11,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(11,5)=("${down_LCA}"), halign(center) 
    }
    ** St.Kitts
    if ${m05_KNA} == 1 {
        putpdf table t1(12,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(12,5)=("${up_KNA}"), halign(center) 
    }
    else if ${m05_KNA} == 2 {
        putpdf table t1(12,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(12,5)=("${down_KNA}"), halign(center)  
    }
    ** St.Vincent
    if ${m05_VCT} == 1 {
        putpdf table t1(13,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(13,5)=("${up_VCT}"), halign(center) 
    }
    else if ${m05_VCT} == 2 {
        putpdf table t1(13,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(13,5)=("${down_VCT}"), halign(center)   
    }
    ** Suriname
    if ${m05_SUR} == 1 {
        putpdf table t1(14,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(14,5)=("${up_SUR}"), halign(center) 
    }
    else if ${m05_SUR} == 2 {
        putpdf table t1(14,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(14,5)=("${down_SUR}"), halign(center) 
    }
    ** Trinidad
    if ${m05_TTO} == 1 {
        putpdf table t1(15,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(15,5)=("${up_TTO}"), halign(center)
    }
    else if ${m05_TTO} == 2 {
        putpdf table t1(15,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(15,5)=("${down_TTO}"), halign(center)
    }    
    ** Anguilla
    if ${m05_AIA} == 1 {
        putpdf table t1(16,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(16,5)=("${up_AIA}"), halign(center)
    }
    else if ${m05_AIA} == 2 {
        putpdf table t1(16,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(16,5)=("${down_AIA}"), halign(center)
    }    
    ** Bermuda
    if ${m05_BMU} == 1 {
        putpdf table t1(17,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(17,5)=("${up_BMU}"), halign(center)
    }
    else if ${m05_BMU} == 2 {
        putpdf table t1(17,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(17,5)=("${down_BMU}"), halign(center)
    }   
    ** British Virgin Islands
    if ${m05_VGB} == 1 {
        putpdf table t1(18,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(18,5)=("${up_VGB}"), halign(center)
    }
    else if ${m05_VGB} == 2 {
        putpdf table t1(18,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(18,5)=("${down_VGB}"), halign(center)
    } 
    ** Cayman
    if ${m05_CYM} == 1 {
        putpdf table t1(19,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(19,5)=("${up_CYM}"), halign(center)
    }
    else if ${m05_CYM} == 2 {
        putpdf table t1(19,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(19,5)=("${down_CYM}"), halign(center)
    } 
    ** Montserrat
    if ${m05_MSR} == 1 {
        putpdf table t1(20,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(20,5)=("${up_MSR}"), halign(center)
    }
    else if ${m05_MSR} == 2 {
        putpdf table t1(20,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(20,5)=("${down_MSR}"), halign(center)
    } 
    ** Turks & Caicos
    if ${m05_TCA} == 1 {
        putpdf table t1(21,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(ffcccc) 
        putpdf table t1(21,5)=("${up_TCA}"), halign(center)
    }
    else if ${m05_TCA} == 2 {
        putpdf table t1(21,1/5), font("Calibri Light", 14, 000000) border(left, nil) border(right, nil) border(top, single, 8c8c8c) border(bottom, single, 8c8c8c) bgcolor(d6f5d6) 
        putpdf table t1(21,5)=("${down_TCA}"), halign(center)
    } 

** SLIDE 6 - ALL PROFILES CURVES ON ONE SLIDES
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Summary of CARICOM cases "), halign(left) 
    putpdf table intro2(1,2)=("(Updated: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak

** FIGURE 
    putpdf table f2 = (10,4), width(100%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("Antigua & Barbuda:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(1,1)=("${p14_ATG}%"), halign(left) font("Calibri Light", 12, 808080) append 
    putpdf table f2(1,2)=("Bahamas:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(1,2)=("${p14_BHS}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(1,3)=("Barbados:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(1,3)=("${p14_BRB}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(1,4)=("Belize:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(1,4)=("${p14_BLZ}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(2,1)=image("`outputpath'/caserate_spark_ATG.png")
    putpdf table f2(2,2)=image("`outputpath'/caserate_spark_BHS.png")
    putpdf table f2(2,3)=image("`outputpath'/caserate_spark_BRB.png")
    putpdf table f2(2,4)=image("`outputpath'/caserate_spark_BLZ.png")

    putpdf table f2(3,1)=("Dominica:%"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(3,1)=("${p14_DMA}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(3,2)=("Grenada:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(3,2)=("${p14_GRD}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(3,3)=("Guyana:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(3,3)=("${p14_GUY}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(3,4)=("Haiti:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(3,4)=("${p14_HTI}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(4,1)=image("`outputpath'/caserate_spark_DMA.png")
    putpdf table f2(4,2)=image("`outputpath'/caserate_spark_GRD.png")
    putpdf table f2(4,3)=image("`outputpath'/caserate_spark_GUY.png")
    putpdf table f2(4,4)=image("`outputpath'/caserate_spark_HTI.png")

    putpdf table f2(5,1)=("Jamaica:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(5,1)=("${p14_JAM}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(5,2)=("St Kitts & Nevis:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(5,2)=("${p14_KNA}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(5,3)=("St Lucia:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(5,3)=("${p14_LCA}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(5,4)=("St Vincent & Grenadines:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(5,4)=("${p14_VCT}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(6,1)=image("`outputpath'/caserate_spark_JAM.png")
    putpdf table f2(6,2)=image("`outputpath'/caserate_spark_KNA.png")
    putpdf table f2(6,3)=image("`outputpath'/caserate_spark_LCA.png")
    putpdf table f2(6,4)=image("`outputpath'/caserate_spark_VCT.png")

    putpdf table f2(7,1)=("Suriname:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(7,1)=("${p14_SUR}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(7,2)=("Trinidad:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(7,2)=("${p14_TTO}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(7,3)=("Anguilla:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(7,3)=("${p14_AIA}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(7,4)=("Bermuda:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(7,4)=("${p14_BMU}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(8,1)=image("`outputpath'/caserate_spark_SUR.png")
    putpdf table f2(8,2)=image("`outputpath'/caserate_spark_TTO.png")
    putpdf table f2(8,3)=image("`outputpath'/caserate_spark_AIA.png")
    putpdf table f2(8,4)=image("`outputpath'/caserate_spark_BMU.png")

    putpdf table f2(9,1)=("BVI:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(9,1)=("${p14_VGB}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(9,2)=("Cayman:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(9,2)=("${p14_CYM}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(9,3)=("Montserrat:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(9,3)=("${p14_MSR}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(9,4)=("Turks & Caicos:"), halign(left) font("Calibri Light", 12, 000000)  
    putpdf table f2(9,4)=("${p14_TCA}%"), halign(left) font("Calibri Light", 12, 808080) append  
    putpdf table f2(10,1)=image("`outputpath'/caserate_spark_VGB.png")
    putpdf table f2(10,2)=image("`outputpath'/caserate_spark_CYM.png")
    putpdf table f2(10,3)=image("`outputpath'/caserate_spark_MSR.png")
    putpdf table f2(10,4)=image("`outputpath'/caserate_spark_TCA.png")





** SLIDE 7. PREDICTION
putpdf pagebreak
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

    putpdf paragraph, halign(center) 
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("COVID-19 in the Caribbean") , font("Calibri Light", 32, 000000) linebreak
    putpdf text ("Part 3: Prediction") , font("Calibri Light", 28, 808080) linebreak




** SLIDE 8 - BARBADOS EXAMPLE
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Prediction of Daily Cases: example Barbados"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (2,1), width(90%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_BRB_clean.png")
    ///putpdf table f2(2,1)=image("`outputpath'/caserate_predict_BRB.png")

** SLIDE 8 - BARBADOS EXAMPLE
putpdf pagebreak
    putpdf table intro2 = (1,20), width(100%) halign(left)    
    putpdf table intro2(.,.), border(all, nil) valign(center)
    putpdf table intro2(1,.), font("Calibri Light", 24, 000000)  
    putpdf table intro2(1,1)
    putpdf table intro2(1,2), colspan(14)
    putpdf table intro2(1,16), colspan(5)
    putpdf table intro2(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro2(1,2)=("Prediction of Daily Cases: example Barbados"), halign(left) linebreak
    putpdf table intro2(1,2)=("(Updated on: $S_DATE)"), halign(left) append  font("Calibri Light", 18, 000000)  
    putpdf table intro2(1,16)=(" "), halign(right)  font("Calibri Light", 16, 8c8c8c) linebreak
    putpdf table f2 = (2,1), width(90%) border(all,nil) halign(left)
    putpdf table f2(1,1)=image("`outputpath'/caserate_BRB_clean.png")
    putpdf table f2(2,1)=image("`outputpath'/caserate_predict_BRB.png")


** SLIDE 9. WEB-PAGE LOCATION
putpdf pagebreak
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
    putpdf table intro1(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append linebreak

    putpdf paragraph , halign(center) 
    putpdf text (" ") , font("Calibri Light", 20, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 20, 000000) linebreak
    putpdf text ("COVID-19 in the Caribbean") , font("Calibri Light", 32, 000000) linebreak
    putpdf text ("Our new location for CARICOM COVID-19 Surveillance") , font("Calibri Light", 28, 808080) linebreak
    putpdf text (" ") , font("Calibri Light", 20, 000000) linebreak

    putpdf table f2 = (1,1), width(50%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/slide1M.png") 

    putpdf paragraph , halign(center) 
    putpdf text (" ") , font("Calibri Light", 20, 000000) linebreak
    putpdf text ("https://ianhambleton.com/covid19/ "), font("Calibri Light", 28, 999999) underline linebreak 
    
    



** COUNTRY SURVEILLANCE
** PAGE 1. TITLE, ATTRIBUTION, DATE of CREATION, PRESENTATION GOALS
putpdf pagebreak
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

    putpdf paragraph , halign(center) 
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text (" ") , font("Calibri Light", 24, 000000) linebreak
    putpdf text ("COVID-19 in the Caribbean") , font("Calibri Light", 32, 000000) linebreak
    putpdf text ("Part 4: Country Profiles") , font("Calibri Light", 28, 808080) linebreak


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
    putpdf save "`webpath'/COVID-slides-01", replace,
