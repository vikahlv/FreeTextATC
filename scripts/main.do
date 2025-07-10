
/********************************************************************************************
 Title   	: Fuzzy Matching Free-Text Medication Names to ATC Codes, "main.do"
 Author  	: Stamatia
 Project 	: Text-to-ATC Mapping
 Purpose 	: This script performs fuzzy matching of free-text medication names to ATC codes 
			  using a pre-built API and saves the best matches.
 Repository : "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/scripts/github/main.do"
********************************************************************************************/

/********************************************************************************************
 STEP 1: Build the API (Skip if already built)
********************************************************************************************/
// do "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/scripts/build_api.do"

/********************************************************************************************
 STEP 2: Load the free-text dataset
********************************************************************************************/
// Option A: Use a small random sample from the full dataset
/*
use "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/database/FT_meds_full.dta", clear
gen rand = runiform()
keep if rand < 0.0001

display "Sample size after random selection: " _N
drop rand
*/

// Option B: Use the full dataset
use "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/database/FT_meds_full.dta", clear

/********************************************************************************************
 STEP 3: Save a copy of the dataset for comparison after matching
********************************************************************************************/
// save "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/database/small_sample.dta", replace

/********************************************************************************************
 STEP 4: Clean the free-text medication entries
********************************************************************************************/
do "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/scripts/dtclean_freetext.do"

/********************************************************************************************
 STEP 5: Perform fuzzy matching with the API
********************************************************************************************/
do "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/scripts/matching.do"

// Save the matched output
cd "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/database/API/run"
save "matched_zerothreeFULL.dta", replace

/********************************************************************************************
 STEP 6: Keep only the best (highest scoring) match for each input observation
********************************************************************************************/
use "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/database/API/run/matched_zerothreeFULL.dta", clear
gen tag = 0
bysort lower (similscore): replace tag = 1 if _n == _N
keep if tag == 1

display "Number of observations with best matches: " _N

/********************************************************************************************
 STEP 7: Merge matched results with the original free-text data
********************************************************************************************/
// Option A: Merge with sampled data
// merge 1:1 i using "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/database/small_sample.dta"

// Option B: Merge with full dataset
merge 1:1 i using "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/database/FT_meds_full.dta"

