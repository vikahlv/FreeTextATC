/******************************************************************************************
* Project       : Fuzzy Matching Free-Text Medication Names to ATC Codes
* Script Name   : dtclean_freetext.do
* Purpose       : Clean and standardize medication names for analysis
* Author        : Stamatia
* Output        : A cleaned string variable `lower` from original variable `med`
******************************************************************************************/

/*** STEP 0: Setup ***/
// Assumes dataset is already loaded and contains a string variable `med`

/*** STEP 1: Replace corrupted letters ***/
//tranfer to dummy var to hedge
gen correct_letters = med

// Define the corrupted (wrong) and correct (target) characters
local wrongs "Ã¤ Ã¶ Ã¥ Ã– Ã© Í Ì É À Á Â Ã Ï Î Ó"
local rights "Ä Ö Å Ö Ä I I E A A Å Ä I I O"

// Loop through each pair and replace
forvalues i = 1/15 {
    local bad : word `i' of `wrongs'
    local good : word `i' of `rights'
    replace correct_letters = subinstr(correct_letters, "`bad'", "`good'", .)
}

/*** STEP 2: Normalize case and trim whitespace ***/
gen lower = trim(correct_letters)
replace lower = lower(lower)

/*** STEP 3: Filter out unwanted words BEFORE spacing ***/
gen flag_exclude = ustrregexm(lower, "(\b)(b|d|b-vitamin|d-vitamin|blutsaft|b-vit|d-vit|f-rörelser|fe|kosttillskot|kostillskot|kostillskott|apotekets|mamma|mama|mamavital|minitotal|multivitamin|mumomega|vitamin|vitaminer|vit|plus|puls|mittval|mitval|mitvla|mitt_val|kvinna|gravid|veg|vegerian|veget|vegetarian|fam|comfort|sport|omega|mitt|alfa|aloe|alov|apot|fisk|femb|järn|aco|omega|frigg|gravi|multi|foster|kvinno|vitami|apoliv|elevit|mittva|multivit|vitmin)(\b)")
drop if flag_exclude == 1
drop flag_exclude


/*** STEP 4: Insert spaces and clean format ***/
//space between digits and nondigits
replace lower = ustrregexra(lower, "([0-9]{1,})([^0-9]{1,})", "$1 $2")
//space between nondigits and digits
replace lower = ustrregexra(lower, "([^0-9]{1,})([0-9]{1,})", "$1 $2")
//drop all numbers, replace it with space
replace lower = ustrregexra(lower, "([0-9]{1,})", " ")
//drop all special characters, replace it with space
replace lower = ustrregexra(lower, "([^A-Za-zÅÄÖåäö ]{1,})", " ")
//remove inbetween multiple spaces, replace with single space
replace lower = ustrregexra(lower, "([ ]{2,})", " ")
replace lower = trim(lower)

/*** STEP 5: Filter out unwanted words AFTER spacing ***/
gen flag_exclude = ustrregexm(lower, "(\b)(b|d|b-vitamin|d-vitamin|blutsaft|f-rörelser|fe|kosttillskot|kostillskot|kostillskott|tillskott|mamma|mama|mamavital|minitotal|multivitamin|mumomega|vitamin|vitaminer|vit|plus|puls|mittval|mitval|mitvla|apotekets|mitt val|kvinna|gravid|veg|vegerian|veget|vegetarian|fam|comfort|sport|omega|mitt|alfa|aloe|alov|apot|fisk|femb|järn|aco|omega|frigg|gravi|multi|foster|kvinno|vitami|apoliv|elevit|mittva|fe|alg|iron|multivit|vitmin)(\b)")
drop if flag_exclude == 1
drop flag_exclude

// Additional filtering with broader substrings
gen flag_exclude = ustrregexm(lower, "(kosttillskot|kostillskot|kostillskott|mamma|mama|mamavital|minitotal|multivitamin|mumomega|vitamin|vitaminer|mittval|mitval|mitvla|mitt val|kvinna|gravid|vegerian|veget|vegetarian|comfort|sport|omega|mitt|aloe|fisk|järn|frigg|gravi|multi|foster|kvinno|vitami|apoliv|elevit|mittva|iron|multivit|multivitamin|vitmin|apotek|apoteket|magnesium|tillskott|calci|calsi)")
drop if flag_exclude == 1
drop flag_exclude

/*** STEP 6: Filter out commercial prefixes ***/
gen flag_exclude = ustrregexm(lower, "^aco")
drop if flag_exclude == 1
drop flag_exclude

/*** STEP 7: Final cleanup and unwanted word removal, same again ***/
replace lower = ustrregexra(lower, "(\b)(droppar|eo|m|ie|vacc|vtrd|μg|mg|gr|g|ug|inj|mcg|x|mgr|vb|mikrogram|mikrog|injektion|injektioner|dos|vag|micr|ml|tabl|t\.|t|ficota|enterotabl|tablet|kaps|gel1|gel|cream|kräm|injnf|injlö|injsb|injsk|injsubs kf|injsubst|injvä|solinj|susinj|vagcah|vagcre|vagdel|vagde|vaggel|vagsol|vagtab|vagtabl|cutsol|lö kutan|kutan lösn|kutan lösning|cutemu|kutan emuls|kutan emulsion|eydrsu|ögdro|ögondr|naspsu|naspso|naspin|näspy|nasspray|vätsk|vätske|dagar)(\b)", " ")


// REMOVE these letters from the observations
replace lower = ustrregexra(lower, "(droppar|injektion|injektioner|enterotabl|tablet|kaps|gel1|gel|cream|injnf|injlö|injsb|injsk|injsubs kf|injsubst|injvä|solinj|susinj|vagcah|vagcre|vagdel|vagde|vaggel|vagsol|vagtab|vagtabl|cutsol|lö kutan|kutan lösn|kutan lösning|cutemu|kutan emuls|kutan emulsion|eydrsu|ögdro|ögondr|naspsu|naspso|naspin|näspy|nasspray|vätsk|vätske|gravid|kvinn|järn|salva)", " ")

gen flag_exclude = ustrregexm(lower, "(\b)(b|d|b-vitamin|d-vitamin|blutsaft|f-rörelser|kosttillskot|kostillskot|kostillskott|tillskott|mamma|mama|mamavital|minitotal|multivitamin|mumomega|vitamin|vitaminer|vit|plus|puls|mittval|mitval|apotekets|mitvla|mitt val|kvinna|gravid|veg|vegerian|veget|vegetarian|fam|comfort|kräm|sport|acne|also|omega|mitt|alfa|aloe|alov|apot|fisk|femb|järn|aco|omega|frigg|gravi|multi|foster|kvinno|vitami|apoliv|elevit|mittva|fe|fe-|alg|iron|multivit|multivitamin|vitmin)(\b)")
drop if flag_exclude == 1
drop flag_exclude

gen flag_exclude = ustrregexm(lower, "(kosttillskot|kostillskot|kostillskott|mamma|mama|mamavital|minitotal|multivitamin|mumomega|vitamin|vitaminer|mittval|mitval|mitvla|mitt val|kvinna|gravid|vegerian|veget|vegetarian|comfort|sport|omega|mitt|aloe|fisk|järn|frigg|gravi|multi|foster|kvinno|vitami|apoliv|elevit|mittva|iron|multivit|multivitamin|vitmin|apotek|apoteket|magnesium|tillskott|calci|calsi)")
drop if flag_exclude == 1
drop flag_exclude

replace lower = trim(lower)

gen flag_exclude = ustrregexm(lower, "(\b)(b|d|b-vitamin|d-vitamin|blutsaft|f-rörelser|kosttillskot|kostillskot|kostillskott|tillskott|mamma|mama|mamavital|minitotal|multivitamin|mumomega|vitamin|vitaminer|vit|plus|puls|mittval|mitval|apotekets|mitvla|mitt val|kvinna|gravid|veg|vegerian|veget|vegetarian|fam|comfort|spor|also|omega|mega|mitt|alfa|aloe|alov|apot|fisk|femb|järn|aco|omega|frigg|gravi|multi|foster|kvinno|vitami|apoliv|elevit|mittva|fe|alg|fe-|iron|multivit|vitmin|inh|e|v|dgr|uq|var|mikro|mlx|x)(\b)")
drop if flag_exclude == 1
drop flag_exclude


/*** STEP 8: Repeat formatting clean-up ***/
//space between digits and nondigits
replace lower = ustrregexra(lower, "([0-9]{1,})([^0-9]{1,})", "$1 $2")
//space between nondigits and digits
replace lower = ustrregexra(lower, "([^0-9]{1,})([0-9]{1,})", "$1 $2")
//drop all numbers, replace it with space
replace lower = ustrregexra(lower, "([0-9]{1,})", " ")
//drop all special characters, replace it with space
replace lower = ustrregexra(lower, "([^A-Za-zÅÄÖåäö ]{1,})", " ")
//remove inbetween multiple spaces, replace with single space
replace lower = ustrregexra(lower, "([ ]{2,})", " ")
replace lower = trim(lower)


/*** STEP 9: Remove duplicates as per lower&med because we need to keep the various meds ***/ 
duplicates drop med lower, force



/*** END OF SCRIPT ***/
