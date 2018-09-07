# GOAL : Given a list of PMIDS, we want to identify whether that journal publishes MESH terms
# Steps : Find out the type of publication
#         Find out the journal name
#         Find all the PMIDS / MH under that journal name

library(rentrez)
library(dplyr)
library(tidyr)
library(stringr)
library(tm)
library(rjson)
library(quanteda)
options(stringsAsFactors = FALSE)

# Exploring rentrez package
#************************************************************************
# List of available databases - interested in PubMed (for publication type and MH) and nlmcatalog (journal metadata)
entrez_dbs()

# Set of search terms for PubMed - interested in MESH, JOUR (journal abbreviation of publication), PTYP (type of publication), CNTY (country of publication), PUBN (publisher's name)
entrez_db_searchable("pubmed")

# Set of search terms for NLMCatalog
entrez_db_searchable("nlmcatalog")
#************************************************************************

search_pmid_full <- as.numeric(fromJSON(file="/Users/Annie/Desktop/nomesh_pmid.json"))

# Chunk the PMIDS for smaller requests
chunk_size <- 250
pmids_chunked <- split(search_pmid_full, ceiling(seq_along(search_pmid_full)/chunk_size))

#our trial pmid chunk
pmids_chunked[[1]]

#GOAL:
# Find the type of publication
# Find the journal name

# Multiple PMIDS
# Create the index for the given list of PMIDS
search_pmid <- c(30145740, 30099694,30176007)
# Obtain the summary records back of each PMIDS
multi_summary <- entrez_summary (db = "pubmed", id = search_pmid)
# Create a tibble with columns PMID, Abbrev Journal Name, Full Journal Name, Publication Type, NLM ID
summary_results <- tibble (PMID = search_pmid, AbbrevJournalName = extract_from_esummary(multi_summary, "source"), FullJournalName = extract_from_esummary(multi_summary, "fulljournalname"), PublicationType = as.list(as.data.frame(extract_from_esummary(multi_summary, "pubtype"), stringsAsFactors = FALSE)[2,]),NLMUniqueID = extract_from_esummary(multi_summary, "nlmuniqueid"))

#---DO NOT RUN---
#Explaining the logic behind obtaining publication type
# We know that we can obtain publication type like so,
PublicationType = extract_from_esummary(multi_summary, "pubtype")
str(PublicationType) # But it returns a list where each section of the list is an atomic vector of length 2 - problematic
PublicationType[[2]]  # We only want the second element each vector of the list
temp <-  as.data.frame(PublicationType) # We coerce into a dataframe and only get the second row
temp[2,]
# Then we have to wrap it all as a list so that it fits into our tibble
# We condense all of it into one line of code so that we don't waste memory saving names
temp2 <- as.list(as.data.frame(PublicationType, stringsAsFactors = FALSE)[2,])
str(temp2)
#FINAL
PublicationType = as.list(as.data.frame(extract_from_esummary(multi_summary, "pubtype"), stringsAsFactors = FALSE)[2,])
#---------------

# Reformatting abbreviated journal name to format AbbrevJournalName[JOUR] so that it searches on PubMed
summary_results$AbbrevJournalName
summary_results$AbbrevJournalName <- paste (summary_results$AbbrevJournalName, "[JOUR]", sep = "")







# GOAL: 
# Obtain all the distinct NLM IDS
# Use NLM ID to find all publications under the journal name
# Determine if any of them have MeSH terms

# Functions
# Transforms raw strings pattern to Colon
toColon <- content_transformer(function(x, pattern) {return (gsub(pattern, "; ", x))})
# Detects pattern match in raw string
detect_match <- content_transformer(function(x, pattern){return (str_detect(x, pattern))})


# Distinct AbbrevJournalName DataFrame
distinct_journal_name <- distinct(summary_results,AbbrevJournalName)


# For Loop for to find PMIDs of each distinct NLM IDs
for(i in 1:length(distinct_journal_name$AbbrevJournalName)){
  # Use AbbrevJournalName to search for the PMIDS 
  journal_pmid <- entrez_search(db = "pubmed", term = distinct_journal_name$AbbrevJournalName[i], retmax = 99999)$ids
  
  
  
}

journal_pmid <- entrez_search(db = "pubmed", term = distinct_journal_name$AbbrevJournalName[2], retmax = 99999)$ids

journal_pmid_1 <- journal_pmid[1:400]
documents <- Corpus(VectorSource(entrez_fetch (db = "pubmed", id = journal_pmid_1, rettype = "medline", retmode = "text")))
writeLines(as.character(documents[[1]]))
# Clean Strings
temp <- tm_map(documents, toColon, "\n")
temp2 <- tm_map(temp, detect_match, "(MH .+?);")
# Detect PMID regexr : (PMID.+?);
temp2[[1]][1]






# Use these IDS to analyze mesh terms
# Have to find a way to efficiently cycle through every single journal






# GOAL: 
# Use NLM ID to find the Publisher and Country of Publication

# NLM ID
# Create the index for the given list of NLMID
search_nid <- 101590450
# Obtain the summary records back of each NLMID
nid_multi_summary <- entrez_summary (db = "nlmcatalog", id = nid)
# Create a tibble with columns NLMID, Publisher, Country of Publication
# Country of publication
nid_multi_summary$country
# Publisher
nid_multi_summary$publicationinfolist$publisher 

summary_results <- tibble (PMID = search_pmid, FullJournalName = extract_from_esummary(multi_summary, "fulljournalname"), PublicationType = as.list(as.data.frame(extract_from_esummary(multi_summary, "pubtype"), stringsAsFactors = FALSE)[2,]),NLMUniqueID = extract_from_esummary(multi_summary, "nlmuniqueid"))














r_search <- entrez_search(db = "pubmed", term = "Mesh term")
r_search$ids #outputs PMIDS

#eutils api 
entrez_fetch() #obtains full records in varying formats
summary_info <- entrez_summary(db = "pubmed", id = 24555091) #returns less information about each record in a simple format
summary_info #summary info behaves like a list
#we would be interested in publishername, pubtype, fulljournalname
rentrez #parse and summarise summary recores
extract_from_summary(summary_info, "fulljournalname")











#single pmid 
trial <- entrez_summary(db = "pubmed", id = 30145740)
trial$uid #PMID
trial$pubtype # publication type
trial$fulljournalname  #journal name
trial$publishername 
trial$nlmuniqueid
