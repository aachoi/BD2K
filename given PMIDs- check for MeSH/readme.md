# Given PMIDs, Check for Journal MeSH

* This is an ongoing project that will be updated daily until completed

__GOAL:__ Given a list of 4.4 million PMIDS (JSON), identify whether or not the corresponding Journal (that published the document) utilized the MeSH indexing system. In addition, obtain the corresponding Journal Name, NLM Unique ID, Publication Type, Publisher, and Country of Publication.

__Packages used :__ rentrez, dplyr, tidyr, stringr, quantedata, stringi


This project consisted of 3 steps
- [ ] Cleaning the PMID list (removing duplicate PMIDS, invalid PMIDs)
- [ ] From the cleaned PMID list, obtaining the unique Journals 
- [ ] For each unique Journal, parse through every publications to identify any MeSH terms

Ongoing challenges:
* Optimizing code (particularly 3rd step) since I have to go through every publication of every unique journal
* Finding a way to allow for bigger chunks of queries to rentrez
