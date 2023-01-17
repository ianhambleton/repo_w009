** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_07press.do
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
    log using "`logpath'\caricom_07press", replace
** HEADER -----------------------------------------------------

** -----------------------------------------
** Pre-Load the COVID metrics --> as Global Macros
** -----------------------------------------
qui do "`dopath'\caricom_04metrics1"
rename country cname
** -----------------------------------------


** CARICOM cases in past week
dis $m62caricom
** CARICOM deaths in past week
dis $m63caricom
** HAITI
dis $m62_HTI
** Reminaing cases
dis $m62caricom - $m62_HTI 
** New cases and deaths in past 24 hours
dis $m60caricom
dis $m61caricom
** Total cases in Haiti
dis $m01_HTI 
** Dom Rep
dis $m01_DOM
dis $m62_DOM
dis $m02_DOM
** Create a tentative standard text for this
** Will never be entirely possible - as text may need to change each week
** But should make the writing process a little easier
** DAY OF THE WEEK
local dow = dow(d("$S_DATE"))
if `dow'==0 {
    local day = "Sun" 
}
if `dow'==1 {
    local day = "Mon" 
}
if `dow'==2 {
    local day = "Tue" 
}
if `dow'==3 {
    local day = "Wed" 
}
if `dow'==4 {
    local day = "Thu" 
}
if `dow'==5 {
    local day = "Fri" 
}
if `dow'==6 {
    local day = "Sat" 
}
** Change over most recent week (62 and 63)
dis $m62caricom
dis $m63caricom
** Weekly change in cases (1 week ago) 
local change1 = $m64caricom - $m62caricom 
local change1d = $m65caricom - $m63caricom 
** Weekly change in cases (2 weeks ago) 
local change2 = $m66caricom - $m64caricom 
local change2d = $m67caricom - $m65caricom 
** Remaining deaths after removing Haiti 
local remain = $m62caricom - $m62_HTI 
** Remaining deaths after removing Haiti and Suriname
local remain2 = $m62caricom - $m62_HTI - $m62_SUR 
**Remaining deaths after countries with >200 cases
local remain3 = $m62caricom - $m62_SUR - $m62_BHS - $m62_HTI
local remain4 = $m62caricom - $m62_JAM - $m62_GUY - $m62_BMU - $m62_TTO
    
    if $m62_ATG>0 {
        local number = `number'+1
    }
    if $m62_BHS>0 {
        local number = `number'+1
    }
    if $m62_BLZ>0 {
        local number = `number'+1
    }
    if $m62_BRB>0 {
        local number = `number'+1
    }
    **if $m62_BMU>0 {
    **    local number = `number'+1
    **}
    if $m62_VGB>0 {
        local number = `number'+1
    }
    if $m62_CYM>0 {
        local number = `number'+1
    }
    if $m62_DMA>0 {
        local number = `number'+1
    }
    if $m62_GRD>0 {
        local number = `number'+1
    }
    **if $m62_GUY>0 {
    **  local number = `number'+1
    **}
    if $m62_HTI>0 {
      local number = `number'+1
    }
    **if $m62_JAM>0 {
    **      local number = `number'+1
    **}
    if $m62_MSR>0 {
        local number = `number'+1
    }
    if $m62_KNA>0 {
        local number = `number'+1
    }
    if $m62_LCA>0 {
        local number = `number'+1
    }
    if $m62_VCT>0 {
        local number = `number'+1
    }
    if $m62_SUR>0 {
        local number = `number'+1
    }
    ** if $m62_TTO>0 {
    **   local number = `number'+1
    **}
     if $m62_TCA>0 {
       local number = `number'+1
     }
****Creating a macro for countries with cases over 200 (this excludes any countries highlighted as the top hot spots)
local number2 = 0
    if $m62_AIA>200 {
        local number2 = `number2'+1
    }
    if $m62_ATG>200 {
        local number2 = `number2'+1
    }
    if $m62_BHS>200 {
        local number2 = `number2'+1
    }
    if $m62_BLZ>200 {
        local number2 = `number2'+1
    }
    if $m62_BRB>200 {
        local number2 = `number2'+1
    }
    if $m62_BMU>200 {
        local number2 = `number2'+1
    }
    if $m62_VGB>200 {
        local number2 = `number2'+1
    }
    if $m62_CYM>200 {
        local number2 = `number2'+1
    }
    if $m62_DMA>200 {
        local number2 = `number2'+1
    }
    if $m62_GRD>200 {
        local number2 = `number2'+1
    }
    if $m62_GUY>200 {
        local number2 = `number2'+1
    }
    if $m62_HTI>200 {
       local number2 = `number2'+1
    }
    if $m62_JAM>200 {
        local number2 = `number2'+1
    }
    if $m62_MSR>200 {
        local number2 = `number2'+1
    }
    if $m62_KNA>200 {
        local number2 = `number2'+1
    }
    if $m62_LCA>200 {
        local number2 = `number2'+1
    }
    if $m62_VCT>200 {
        local number2 = `number2'+1
    }
    if $m62_SUR>200 {
        local number2 = `number2'+1
     }
    if $m62_TTO>200 {
        local number2 = `number2'+1
    }
    if $m62_TCA>200 {
        local number2 = `number2'+1
    }

** Numbers with commas
global m01caricom_wc : dis %9.0fc $m01caricom
global m02caricom_wc : dis %9.0fc $m02caricom
global m60caricom_wc : dis %9.0fc $m60caricom
global m61caricom_wc : dis %9.0fc $m61caricom
global m62caricom_wc : dis %9.0fc $m62caricom
global m63caricom_wc : dis %9.0fc $m63caricom
global m64caricom_wc : dis %9.0fc $m64caricom
global m65caricom_wc : dis %9.0fc $m65caricom
global m66caricom_wc : dis %9.0fc $m66caricom
global m67caricom_wc : dis %9.0fc $m67caricom


** BULLET
local bullet = uchar(8226)
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
    putpdf table intro(1,2)=("COVID-19 Weekly Summary"), halign(left) linebreak font("Calibri Light", 12, 000000)
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
    putpdf text ("Weekly Summary for the week ending `day' $S_DATE. ") , bold linebreak
    putpdf text ("In the week to `day' $S_DATE among the 20 CARICOM members and associate members: "), linebreak
    putpdf paragraph ,  font("Calibri Light", 10) indent(left, 35pt)
    putpdf text ("`bullet' There have been "),
    putpdf text ("$m62caricom "), 
    putpdf text ("new confirmed cases (compared to `change1' last week, and `change2' two weeks ago) "), linebreak  
    putpdf text ("`bullet' There have been $m63caricom new confirmed deaths (compared to `change1d' last week, and `change2d' two weeks ago). "), linebreak 
    putpdf text ("`bullet' In the past 24 hours there have been $m60caricom new confirmed cases and $m61caricom new confirmed deaths. "), linebreak

    putpdf paragraph ,  font("Calibri Light", 10) 
    putpdf text ("The numbers of cases and deaths in the past week in the 20 CARICOM member states were: "), linebreak

    putpdf paragraph ,  font("Calibri Light", 10) indent(left, 35pt)
    ** Anguilla
    if $m62_AIA!=1 & $m63_AIA!=1 {
        putpdf text ("`bullet' Anguilla ($m62_AIA cases, $m63_AIA deaths) "), linebreak 
    }
    else if $m62_AIA!=1 & $m63_AIA==1 {
        putpdf text ("`bullet' Anguilla ($m62_AIA cases, $m63_AIA death) "), linebreak 
    }
    else if $m62_AIA==1 & $m63_AIA!=1 {
        putpdf text ("`bullet' Anguilla ($m62_AIA case, $m63_AIA deaths) "), linebreak 
    }
    else if $m62_AIA==1 & $m63_AIA==1 {
        putpdf text ("`bullet' Anguilla ($m62_AIA case, $m63_AIA death) "), linebreak 
    }

    ** Antigua and Barbuda
    if $m62_ATG!=1 & $m63_ATG!=1 {
        putpdf text ("`bullet' Antigua and Barbuda ($m62_ATG cases, $m63_ATG deaths) "), linebreak 
    }
    else if $m62_ATG!=1 & $m63_ATG==1 {
        putpdf text ("`bullet' Antigua and Barbuda ($m62_ATG cases, $m63_ATG death) "), linebreak 
    }
    else if $m62_ATG==1 & $m63_ATG!=1 {
        putpdf text ("`bullet' Antigua and Barbuda ($m62_ATG case, $m63_ATG deaths) "), linebreak 
    }
    else if $m62_ATG==1 & $m63_ATG==1 {
        putpdf text ("`bullet' Antigua and Barbuda ($m62_ATG case, $m63_ATG death) "), linebreak 
    }

    ** The Bahamas
    if $m62_BHS!=1 & $m63_BHS!=1 {
        putpdf text ("`bullet' The Bahamas ($m62_BHS cases, $m63_BHS deaths) "), linebreak 
    }
    else if $m62_BHS!=1 & $m63_BHS==1 {
        putpdf text ("`bullet' The Bahamas ($m62_BHS cases, $m63_BHS death) "), linebreak 
    }
    else if $m62_BHS==1 & $m63_BHS!=1 {
        putpdf text ("`bullet' The Bahamas ($m62_BHS case, $m63_BHS deaths) "), linebreak 
    }
    else if $m62_BHS==1 & $m63_BHS==1 {
        putpdf text ("`bullet' The Bahamas ($m62_BHS case, $m63_BHS death) "), linebreak 
    }

    ** Barbados
    if $m62_BRB!=1 & $m63_BRB!=1 {
        putpdf text ("`bullet' Barbados ($m62_BRB cases, $m63_BRB deaths) "), linebreak 
    }
    else if $m62_BRB!=1 & $m63_BRB==1 {
        putpdf text ("`bullet' Barbados ($m62_BRB cases, $m63_BRB death) "), linebreak 
    }
    else if $m62_BRB==1 & $m63_BRB!=1 {
        putpdf text ("`bullet' Barbados ($m62_BRB case, $m63_BRB deaths) "), linebreak 
    }
    else if $m62_BRB==1 & $m63_BRB==1 {
        putpdf text ("`bullet' Barbados ($m62_BRB case, $m63_BRB death) "), linebreak 
    }

    ** Belize
    if $m62_BLZ!=1 & $m63_BLZ!=1 {
        putpdf text ("`bullet' Belize ($m62_BLZ cases, $m63_BLZ deaths) "), linebreak 
    }
    else if $m62_BLZ!=1 & $m63_BLZ==1 {
        putpdf text ("`bullet' Belize ($m62_BLZ cases, $m63_BLZ death) "), linebreak 
    }
    else if $m62_BLZ==1 & $m63_BLZ!=1 {
        putpdf text ("`bullet' Belize ($m62_BLZ case, $m63_BLZ deaths) "), linebreak 
    }
    else if $m62_BLZ==1 & $m63_BLZ==1 {
        putpdf text ("`bullet' Belize ($m62_BLZ case, $m63_BLZ death) "), linebreak 
    }

    ** Bermuda
    if $m62_BMU!=1 & $m63_BMU!=1 {
        putpdf text ("`bullet' Bermuda ($m62_BMU cases, $m63_BMU deaths) "), linebreak 
    }
    else if $m62_BMU!=1 & $m63_BMU==1 {
        putpdf text ("`bullet' Bermuda ($m62_BMU cases, $m63_BMU death) "), linebreak 
    }
    else if $m62_BMU==1 & $m63_BMU!=1 {
        putpdf text ("`bullet' Bermuda ($m62_BMU case, $m63_BMU deaths) "), linebreak 
    }
    else if $m62_BMU==1 & $m63_BMU==1 {
        putpdf text ("`bullet' Bermuda ($m62_BMU case, $m63_BMU death) "), linebreak 
    }

    ** The British Virgin Islands
    if $m62_VGB!=1 & $m63_VGB!=1 {
        putpdf text ("`bullet' The British Virgin Islands ($m62_VGB cases, $m63_VGB deaths) "), linebreak 
    }
    else if $m62_VGB!=1 & $m63_VGB==1 {
        putpdf text ("`bullet' The British Virgin Islands ($m62_VGB cases, $m63_VGB death) "), linebreak 
    }
    else if $m62_VGB==1 & $m63_VGB!=1 {
        putpdf text ("`bullet' The British Virgin Islands ($m62_VGB case, $m63_VGB deaths) "), linebreak 
    }
    else if $m62_VGB==1 & $m63_VGB==1 {
        putpdf text ("`bullet' The British Virgin Islands ($m62_VGB case, $m63_VGB death) "), linebreak 
    }


    ** Cayman Islands
    if $m62_CYM!=1 & $m63_CYM!=1 {
        putpdf text ("`bullet' Cayman Islands ($m62_CYM cases, $m63_CYM deaths) "), linebreak 
    }
    else if $m62_CYM!=1 & $m63_CYM==1 {
        putpdf text ("`bullet' Cayman Islands ($m62_CYM cases, $m63_CYM death) "), linebreak 
    }
    else if $m62_CYM==1 & $m63_CYM!=1 {
        putpdf text ("`bullet' Cayman Islands ($m62_CYM case, $m63_CYM deaths) "), linebreak 
    }
    else if $m62_CYM==1 & $m63_CYM==1 {
        putpdf text ("`bullet' Cayman Islands ($m62_CYM case, $m63_CYM death) "), linebreak 
    }


    ** Dominica
    if $m62_DMA!=1 & $m63_DMA!=1 {
        putpdf text ("`bullet' Dominica ($m62_DMA cases, $m63_DMA deaths) "), linebreak 
    }
    else if $m62_DMA!=1 & $m63_DMA==1 {
        putpdf text ("`bullet' Dominica ($m62_DMA cases, $m63_DMA death) "), linebreak 
    }
    else if $m62_DMA==1 & $m63_DMA!=1 {
        putpdf text ("`bullet' Dominica ($m62_DMA case, $m63_DMA deaths) "), linebreak 
    }
    else if $m62_DMA==1 & $m63_DMA==1 {
        putpdf text ("`bullet' Dominica ($m62_DMA case, $m63_DMA death) "), linebreak 
    }



    ** Grenada
    if $m62_GRD!=1 & $m63_GRD!=1 {
        putpdf text ("`bullet' Grenada ($m62_GRD cases, $m63_GRD deaths) "), linebreak 
    }
    else if $m62_GRD!=1 & $m63_GRD==1 {
        putpdf text ("`bullet' Grenada ($m62_GRD cases, $m63_GRD death) "), linebreak 
    }
    else if $m62_GRD==1 & $m63_GRD!=1 {
        putpdf text ("`bullet' Grenada ($m62_GRD case, $m63_GRD deaths) "), linebreak 
    }
    else if $m62_GRD==1 & $m63_GRD==1 {
        putpdf text ("`bullet' Grenada ($m62_GRD case, $m63_GRD death) "), linebreak 
    }

    ** Guyana
    if $m62_GUY!=1 & $m63_GUY!=1 {
        putpdf text ("`bullet' Guyana ($m62_GUY cases, $m63_GUY deaths) "), linebreak 
    }
    else if $m62_GUY!=1 & $m63_GUY==1 {
        putpdf text ("`bullet' Guyana ($m62_GUY cases, $m63_GUY death) "), linebreak 
    }
    else if $m62_GUY==1 & $m63_GUY!=1 {
        putpdf text ("`bullet' Guyana ($m62_GUY case, $m63_GUY deaths) "), linebreak 
    }
    else if $m62_GUY==1 & $m63_GUY==1 {
        putpdf text ("`bullet' Guyana ($m62_GUY case, $m63_GUY death) "), linebreak 
    }


    ** Haiti
    if $m62_HTI!=1 & $m63_HTI!=1 {
        putpdf text ("`bullet' Haiti ($m62_HTI cases, $m63_HTI deaths) "), linebreak 
    }
    else if $m62_HTI!=1 & $m63_HTI==1 {
        putpdf text ("`bullet' Haiti ($m62_HTI cases, $m63_HTI death) "), linebreak 
    }
    else if $m62_HTI==1 & $m63_HTI!=1 {
        putpdf text ("`bullet' Haiti ($m62_HTI case, $m63_HTI deaths) "), linebreak 
    }
    else if $m62_HTI==1 & $m63_HTI==1 {
        putpdf text ("`bullet' Haiti ($m62_HTI case, $m63_HTI death) "), linebreak 
    }


    ** Jamaica
    if $m62_JAM!=1 & $m63_JAM!=1 {
        putpdf text ("`bullet' Jamaica ($m62_JAM cases, $m63_JAM deaths) "), linebreak 
    }
    else if $m62_JAM!=1 & $m63_JAM==1 {
        putpdf text ("`bullet' Jamaica ($m62_JAM cases, $m63_JAM death) "), linebreak 
    }
    else if $m62_JAM==1 & $m63_JAM!=1 {
        putpdf text ("`bullet' Jamaica ($m62_JAM case, $m63_JAM deaths) "), linebreak 
    }
    else if $m62_JAM==1 & $m63_JAM==1 {
        putpdf text ("`bullet' Jamaica ($m62_JAM case, $m63_JAM death) "), linebreak 
    }

    ** Montserrat
    if $m62_MSR!=1 & $m63_MSR!=1 {
        putpdf text ("`bullet' Montserrat ($m62_MSR cases, $m63_MSR deaths) "), linebreak 
    }
    else if $m62_MSR!=1 & $m63_MSR==1 {
        putpdf text ("`bullet' Montserrat ($m62_MSR cases, $m63_MSR death) "), linebreak 
    }
    else if $m62_MSR==1 & $m63_MSR!=1 {
        putpdf text ("`bullet' Montserrat ($m62_MSR case, $m63_MSR deaths) "), linebreak 
    }
    else if $m62_MSR==1 & $m63_MSR==1 {
        putpdf text ("`bullet' Montserrat ($m62_MSR case, $m63_MSR death) "), linebreak 
    }


    ** St Kitts and Nevis
    if $m62_KNA!=1 & $m63_KNA!=1 {
        putpdf text ("`bullet' St Kitts and Nevis ($m62_KNA cases, $m63_KNA deaths) "), linebreak 
    }
    else if $m62_KNA!=1 & $m63_KNA==1 {
        putpdf text ("`bullet' St Kitts and Nevis ($m62_KNA cases, $m63_KNA death) "), linebreak 
    }
    else if $m62_KNA==1 & $m63_KNA!=1 {
        putpdf text ("`bullet' St Kitts and Nevis ($m62_KNA case, $m63_KNA deaths) "), linebreak 
    }
    else if $m62_KNA==1 & $m63_KNA==1 {
        putpdf text ("`bullet' St Kitts and Nevis ($m62_KNA case, $m63_KNA death) "), linebreak 
    }


    ** St Lucia
    if $m62_LCA!=1 & $m63_LCA!=1 {
        putpdf text ("`bullet' St Lucia ($m62_LCA cases, $m63_LCA deaths) "), linebreak 
    }
    else if $m62_LCA!=1 & $m63_LCA==1 {
        putpdf text ("`bullet' St Lucia ($m62_LCA cases, $m63_LCA death) "), linebreak 
    }
    else if $m62_LCA==1 & $m63_LCA!=1 {
        putpdf text ("`bullet' St Lucia ($m62_LCA case, $m63_LCA deaths) "), linebreak 
    }
    else if $m62_LCA==1 & $m63_LCA==1 {
        putpdf text ("`bullet' St Lucia ($m62_LCA case, $m63_LCA death) "), linebreak 
    }


    ** St Vincent and the Grenadines
    if $m62_VCT!=1 & $m63_VCT!=1 {
        putpdf text ("`bullet' St Vincent and the Grenadines ($m62_VCT cases, $m63_VCT deaths) "), linebreak 
    }
    else if $m62_VCT!=1 & $m63_VCT==1 {
        putpdf text ("`bullet' St Vincent and the Grenadines ($m62_VCT cases, $m63_VCT death) "), linebreak 
    }
    else if $m62_VCT==1 & $m63_VCT!=1 {
        putpdf text ("`bullet' St Vincent and the Grenadines ($m62_VCT case, $m63_VCT deaths) "), linebreak 
    }
    else if $m62_VCT==1 & $m63_VCT==1 {
        putpdf text ("`bullet' St Vincent and the Grenadines ($m62_VCT case, $m63_VCT death) "), linebreak 
    }


    ** Suriname
    if $m62_SUR!=1 & $m63_SUR!=1 {
        putpdf text ("`bullet' Suriname ($m62_SUR cases, $m63_SUR deaths) "), linebreak 
    }
    else if $m62_SUR!=1 & $m63_SUR==1 {
        putpdf text ("`bullet' Suriname ($m62_SUR cases, $m63_SUR death) "), linebreak 
    }
    else if $m62_SUR==1 & $m63_SUR!=1 {
        putpdf text ("`bullet' Suriname ($m62_SUR case, $m63_SUR deaths) "), linebreak 
    }
    else if $m62_SUR==1 & $m63_SUR==1 {
        putpdf text ("`bullet' Suriname ($m62_SUR case, $m63_SUR death) "), linebreak 
    }


    ** Trinidad and Tobago
    if $m62_TTO!=1 & $m63_TTO!=1 {
        putpdf text ("`bullet' Trinidad and Tobago ($m62_TTO cases, $m63_TTO deaths) "), linebreak 
    }
    else if $m62_TTO!=1 & $m63_TTO==1 {
        putpdf text ("`bullet' Trinidad and Tobago ($m62_TTO cases, $m63_TTO death) "), linebreak 
    }
    else if $m62_TTO==1 & $m63_TTO!=1 {
        putpdf text ("`bullet' Trinidad and Tobago ($m62_TTO case, $m63_TTO deaths) "), linebreak 
    }
    else if $m62_TTO==1 & $m63_TTO==1 {
        putpdf text ("`bullet' Trinidad and Tobago ($m62_TTO case, $m63_TTO death) "), linebreak 
    }


    ** Turks and Caicos Islands
    if $m62_TCA!=1 & $m63_TCA!=1 {
        putpdf text ("`bullet' Turks and Caicos Islands ($m62_TCA cases, $m63_TCA deaths) "), linebreak 
    }
    else if $m62_TCA!=1 & $m63_TCA==1 {
        putpdf text ("`bullet' Turks and Caicos Islands ($m62_TCA cases, $m63_TCA death) "), linebreak 
    }
    else if $m62_TCA==1 & $m63_TCA!=1 {
        putpdf text ("`bullet' Turks and Caicos Islands ($m62_TCA case, $m63_TCA deaths) "), linebreak 
    }
    else if $m62_TCA==1 & $m63_TCA==1 {
        putpdf text ("`bullet' Turks and Caicos Islands ($m62_TCA case, $m63_TCA death) "), linebreak 
    }

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`webpath'/caricom_week_summary", replace,
