** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        caricom_00run.do
    //  project:		                COVID-19 sureveillance. Daily surveillance
    //  analysts:				        Ian HAMBLETON
    // 	date last modified	    	    12-SEP-2021
    //  algorithm task			        Run files in sequence to generate CARICOM daily surveilance

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DO file path
    local dopath "X:\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w009\"

    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w009\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w009\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w009\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\caricom_00run", replace
** HEADER -----------------------------------------------------

** LOAD the latest data from Johns Hopkins
** do "`dopath'/caricom_01read.do"

** Initial dataset preparation: restrict to CARICOM countries
do "`dopath'/caricom_02initialprep"

** Case-Rate Profiles
** 20 individual profiles:          - caserate_<country>.pdf
** All profiles in a single PDF:    - caserate_CARICOM.pdf
do "`dopath'/caricom_03profiles.do"

** Country-level 1-page descriptive briefings of #cases and #deaths over time
** Calls on DO file to create global metrics used in PDF pages:
** - caricom_04metrics2
do "`dopath'/caricom_05briefing.do"

** CARICOm regional heatmaps
** new cases / cumulative cases
** new deaths / cumulative deaths
** case rate per 100,000
do "`dopath'/caricom_06heatmaps.do"

** Weekly summary of cases - 1-page text 
do "`dopath'/caricom_07press.do"

