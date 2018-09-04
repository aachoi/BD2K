
For this project, I was asked quantify the relationships between specific MeSH terms and published PubMed documents. In essence, the research question was: Given a list of MeSH terms, how many PubMed documents contain that particular MeSH term and what are their corresponding PMIDs? 

To begin, the MeSH terms of interest were: 

Metabolic Syndrome
Diabetes Complications
Diabetes, Gestational
Diabetes, Mellitus, Experimental
Diabetes Mellitus, Type 1
Diabetes Mellitus, Type 2
Donohue Syndrome
Latent Autoimmune Diabetes in Adults
Prediabetic State 
Essential Hypertension
Hypertension, Malignant
Hypertension, Pregnancy-Induced
Hypertension, Renal
Hypertensive Retinopathy
Masked Hypertension
White Coat Hypertension

All of these MeSH terms fall under two different types of risk factor categories - diabetes and hypertension. 

I condensed the identical terms into umbrella groupings, so that my final PubMED search yielded 6 MEDLINE files, which were: 

“Metabolic Syndrome”[Mesh terms]: 27,005 results
“Diabetes”[Mesh terms]: 388,800 results
“Donohue Syndrome”[Mesh terms]: 57 results
“Latent Autoimmune Diabetes in Adults”[Mesh terms]: 29 results
“Hypertension”[Mesh terms]: 238,946 results

This project consisted of two steps: transforming the 6 MEDLINE files of the umbrella terms into structured data frames and using text analysis to clean the strings to retrieve the PMIDs of each MeSH term.

I have included the code for the 2 steps above, as well as the resulting excel file that lists all the PMIDS of each MeSH term. For clarity, I have also included ‘Donohue Syndrome.txt’ to illustrate the formatting of the unstructured raw MEDLINE file and ‘Donohue Syndrome.RData’ to show the resulting data frame after running the ‘import and clean df’ code. 
