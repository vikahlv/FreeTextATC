/****************************************************************************************
* PROJECT     : Fuzzy Matching Free-Text Medication Names to ATC Codes
* SCRIPT NAME : build_drug_api.do
* PURPOSE     : Merge and clean data from multiple sources (NPL, NSL, FASS) into one API
*               that maps cleaned drug names to ATC codes, removing irrelevant entries
*               and handling common misspellings.
* AUTHOR      : Stamatia 
****************************************************************************************/

// Set paths
local base "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/text_to_atc/database/API"

// Load and append data from all sources
use "/Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/NPL from lakemedelsverket/npl2025_06_cleared.dta", clear
append using "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/Lakemedelverket_referens.dta"
append using "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/NSL from lakemedelsverket/ATC2025_06.dta"
append using "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/NSL from lakemedelsverket/SEnsl_other2025_06.dta"
append using "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/NSL from lakemedelsverket/SEnsl_ssi2025_06.dta"
append using "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/NSL from lakemedelsverket/SEnsl_ssi2025_06_cleared.dta"
append using "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/fass_fuzzy.dta"

save "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API//drug_api.dta", replace

// Re-open merged file for cleaning
use "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API//drug_api.dta", clear

// Remove entries with missing ATC code
drop if ATC == ""

// Drop veterinary drugs (ATC codes starting with Q)
gen flag_vet = ustrregexm(ATC, "^Q")
drop if flag_vet == 1

// Clean and standardize drug names
replace drugname_lower = trim(drugname_lower)

// Add spacing between digits and non-digits
replace drugname_lower = ustrregexra(drugname_lower, "([0-9]+)([^0-9])", "$1 $2")
replace drugname_lower = ustrregexra(drugname_lower, "([^0-9])([0-9]+)", "$1 $2")

// Remove numbers and special characters
replace drugname_lower = ustrregexra(drugname_lower, "[0-9]+", " ")
replace drugname_lower = ustrregexra(drugname_lower, "[^A-Za-zÅÄÖåäö]+", " ")

// Remove extra spaces and trim
replace drugname_lower = ustrregexra(drugname_lower, "[ ]{2,}", " ")
replace drugname_lower = trim(drugname_lower)

// Drop duplicates based on cleaned name
duplicates drop drugname_lower, force

// Flag and drop non-relevant products (e.g., vitamins, supplements)
gen flag_vitamins = ustrregexm(drugname_lower, ///
"(kosttillskot|kostillskot|kostillskott|mamma|mama|mamavital|minitotal|multivitamin|mumomega|vitamin|vitaminer|mittval|mitval|mitvla|mitt val|kvinna|gravid|vegerian|veget|vegetarian|comfort|omega|mitt|aloe|fisk|järn|frigg|gravi|multi|foster|kvinno|vitami|apoliv|elevit|mittva|iron|multivit|multivitamin|vitmin|apotek|apoteket|magnesium|tillskott|calci|calsi)")
drop if flag_vitamins == 1

save "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API//drug_api_changed.dta", replace

/****************************************************************************************
* STAGE 2: Handling misspellings and unmatched entries using SoS substance list
****************************************************************************************/

// Load substance list and merge to find additional ATC codes
use "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/substanser.dta", clear
merge m:1 drugname_lower using "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/drug_api_changed.dta"

// Save intermediate dataset
save "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/misspellings.dta", replace

// Re-load cleaned drug API
use "Volumes/projects/c6_Ahlqvist_Tsampa_DOHAD/Stamatia/database/API/drug_api_changed.dta", clear

// Append known misspellings and manually added entries
append using "`base'/drugs_to_add_to_API.dta"
append using "`base'/misspellings_to_add_to_API.dta"

// Final cleaning
replace drugname_lower = trim(drugname_lower)

// Flag vitamins/supplements again to re-remove after misspelling merge
gen flag_vitamins = ustrregexm(drugname_lower, ///
"(kosttillskot|kostillskot|kostillskott|mamma|mama|mamavital|minitotal|multivitamin|mumomega|vitamin|vitaminer|mittval|mitval|mitvla|mitt val|kvinna|gravid|vegerian|veget|vegetarian|comfort|omega|mitt|aloe|fisk|järn|frigg|gravi|multi|foster|kvinno|vitami|apoliv|elevit|mittva|iron|multivit|multivitamin|vitmin|apotek|apoteket|magnesium|tillskott|calci|calsi)")
drop if flag_vitamins == 1

// Save final version
save "`base'/api.dta", replace
