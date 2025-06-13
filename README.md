# Automated Free-Text Management of Swedish Drugs

This project provides a structured, reproducible approach for cleaning and mapping free-text drug entries in the Swedish Graviditetsregistret to standardized drug identifiers. The goal is to enable researchers and health professionals to link unstructured medication data to a master drug API and ultimately derive ATC codes.

## Background

The Swedish Graviditetsregistret (Pregnancy Register) contains free-text entries of medications used during pregnancy. These entries often contain spelling errors, abbreviations, or incomplete names. To facilitate data harmonization and epidemiological research, we developed a fuzzy-string matching pipeline to automatically link these entries to a curated drug database.

The final output is a clean CSV file with each free-text entry mapped to its corresponding ATC code, where possible.

> **Note**: The Graviditetsregistret data is not included in this repository and is only accessible on secure servers. However, the underlying API and methodology will be made public for reproducibility.

## Overview of Steps

### 1. Extract and Preprocess Free-Text Entries
- Retrieve all free-text drug entries from the Graviditetsregistret.
- Standardize entries by trimming whitespace, converting to lowercase, and removing obvious non-informative tokens (e.g., dosage units, quantities).
- Filter out irrelevant entries such as:
  - Vitamin and mineral supplements (e.g., "folsyra", "järntablett", "vitamin D")
  - Omega fatty acids (e.g., "omega-3", "EPA/DHA")
  - Herbal or non-pharmacological products (e.g., "echinacea", "vitlökstabletter")
- Document and optionally retain a log of removed entries for transparency.



### 2. Prepare Reference Data from the Master API
- Query the internal master drug API to retrieve:
  - Product names
  - Active substances
  - Common misspellings or alternative spellings
  - Associated ATC codes

- Compile the reference data into a structured format suitable for string matching.

### 3. Apply Fuzzy Matching
- Implement a fuzzy-string matching algorithm (e.g., Levenshtein distance or token set ratio).
- For each free-text entry, calculate similarity scores to all entries in the reference dataset.
- Retain the best match(es) based on a predefined similarity threshold (0.5 Jaccard is the default).

### 4. Rule-Based Refinement
- Review low-confidence matches (below threshold) manually or flag them for clinician review.
- Apply additional matching logic, such as:
  - Token reordering (e.g., "paracetamol 500 mg" vs. "500 mg paracetamol")
  - Handling abbreviations and brand names
  - Domain-specific rules (e.g., pregnancy-specific formulations)

### 5. Output Cleaned and Mapped Data
- Create a final output CSV file that includes:
  - Original free-text entry
  - Matched ATC code
  - Matched substance/drug-name/entry
  - Matching confidence score


## Example Output Format

| FreeTextEntry         | MatchedSubstance | ATCCode  | MatchScore |
|-----------------------|------------------|----------|------------|
| "Alvedon 500mg"       | Paracetamol      | N02BE01  | 0.95       |
| "Panodil"             | Paracetamol      | N02BE01  | 0.92       |
| "alvedoon 500"        | Paracetamol      | N02BE01  | 0.78       |

## Contact

For questions, collaboration, or data access requests, please contact:

**Stamatia Tsampa**  
*Project Lead*  
[stamatia.tsampa@ki.se]

**Viktor H Ahlqvist**  
*Principal Investigator*  
[viktor.ahlqvist@ki.se]

---

*This repository does not contain any sensitive or individual-level health data. Only metadata and mappings are shared to promote transparency and reproducibility.*

