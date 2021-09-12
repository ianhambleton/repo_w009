** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        slidedeck1_00_run.do
    //  project:		                COVID-19 sureveillance. Sep2021 slidedeck.
    //  analysts:				Ian HAMBLETON
    // 	date last modified	    	        12-SEP-2021
    //  algorithm task			        Run files in sequence to generate the slide-deck

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
    log using "`logpath'\slidedeck1_00_run", replace
** HEADER -----------------------------------------------------

** SIR model scenarios for Barbados modelling
do "`dopath'/slidedeck1_01_sir_scenarios.do"

** Graphics of Barbados prediction
do "`dopath'/slidedeck1_02_predict.do"

** GLobal macros for dynamic messaging in slide-deck
** do "`dopath'/slidedeck1_03_metrics.do"

** Graphics for slide-deck: Slide 1 (profiles)
** do "`dopath'/slidedeck1_04_slide1.do"

** Graphics for slide-deck: Slide 5 (Barbados models)
** do "`dopath'/slidedeck1_05_slide5.do"

** Building the slides - including ALL regional profiles
** do "`dopath'/slidedeck1_06_slides.do"

