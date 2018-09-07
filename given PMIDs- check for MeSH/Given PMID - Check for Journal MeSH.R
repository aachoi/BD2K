# GOAL : Given a list of PMIDS, we want to identify whether that journal publishes MESH terms
# Steps : Find out the type of publication
#         Find out the journal name
#         Find all the PMIDS / MH under that journal name

library(rentrez)
library(rjson)
library(dplyr)
library(tidyr)
library(stringr)
library(tm)
library(quanteda)
library(stringi)
options(stringsAsFactors = FALSE)


# ANOMALY-------------
length(extract_from_esummary(multi_summary, "pubtype"))
extract_from_esummary(multi_summary, "pubtype")
multi_summary$'28477389'$pubtype

multi_summary$'28338219'$pubtype <- "Case Report"

summary_results <- bind_rows(summary_results,tibble(PMID = names(unlist(extract_from_esummary(multi_summary, "source"))), AbbrevJournalName = unlist(extract_from_esummary(multi_summary, "source")),FullJournalName = unlist(extract_from_esummary(multi_summary, "fulljournalname")),NLMUniqueID = unlist(extract_from_esummary(multi_summary, "nlmuniqueid")),PubType = unlist(extract_from_esummary(multi_summary, "pubtype"))))
# Remove anomaly 
omit <- c(28338219)
# Index of PMIDS to omit
omit_index <- which(pmid_full_unique %in% omit)
pmid_full_unique <- pmid_full_unique[-omit_index]
# --------------------

# Exploring rentrez package
#************************************************************************
# List of available databases - interested in PubMed (for publication type and MH) and nlmcatalog (journal metadata)
entrez_dbs()

# Set of search terms for PubMed - interested in MESH, JOUR (journal abbreviation of publication), PTYP (type of publication), CNTY (country of publication), PUBN (publisher's name)
entrez_db_searchable("pubmed")

# Set of search terms for NLMCatalog
entrez_db_searchable("nlmcatalog")
#************************************************************************

pmid_full <- as.numeric(fromJSON(file="/Users/Annie/Desktop/nomesh_pmid.json"))
# Remove duplicate PMIDS
pmid_full_unique <- unique (pmid_full)


#------------------------
# create trial chunk
#trial <- pmid_full_unique[1:1400]                                    #CHANGE CHUNK
#------------------------

# Chunk the PMIDS for smaller requests
chunk_size <- 199
pmids_chunked <- split(pmid_full_unique, ceiling(seq_along(pmid_full_unique)/chunk_size))

#GOAL 1:
# Find the Abbreviated Journal Name
# Obtain the distinct Journal Names

# Multiple PMIDS
summary_results <- tibble()
for(i in 1:length(pmids_chunked)){
  # Obtain the summary records back of each PMIDS
  multi_summary <- entrez_summary (db = "pubmed", id = pmids_chunked[[i]])
  # Condense strings in PubType into one string
  for (j in 1: length(extract_from_esummary(multi_summary, "pubtype"))){
    if(length(multi_summary[[j]]$pubtype) >=2){
      multi_summary[[j]]$pubtype <- paste(multi_summary[[j]]$pubtype, collapse = " ")
    }
    # If PubType has an empty list " list()" , then replace with "Not Available"
    if(is.list(multi_summary[[j]]$pubtype) & length(multi_summary[[j]]$pubtype) == 0){
      multi_summary[[j]]$pubtype <- "Not Available"
    }
  }
  # Create a tibble with columns PMID, Abbrev Journal Name, Full Journal Name, NLM ID
  summary_results <- bind_rows(summary_results,tibble(PMID = names(unlist(extract_from_esummary(multi_summary, "source"))), AbbrevJournalName = unlist(extract_from_esummary(multi_summary, "source")),FullJournalName = unlist(extract_from_esummary(multi_summary, "fulljournalname")),NLMUniqueID = unlist(extract_from_esummary(multi_summary, "nlmuniqueid")),PubType = unlist(extract_from_esummary(multi_summary, "pubtype"))))
}
#
# Obtain all the distinct AbbrevJournalNames
distinct_summary_results <- distinct(summary_results, AbbrevJournalName, .keep_all = TRUE)

# Reformatting abbreviated journal name to format AbbrevJournalName[JOUR] so that it searches on PubMed
distinct_summary_results$AbbrevJournalName <- paste (distinct_summary_results$AbbrevJournalName, "[JOUR]", sep = "")

# GOAL 2: 
# Use NLM ID to find all publications under the journal name
# Determine if any of the publications have MeSH terms

# Create a MH_match column in distinct_summary_results
distinct_summary_results$MH_match = rep(TRUE, length(distinct_summary_results$PMID))

# For Loop for to find PMIDs of each distinct NLM IDs
for(i in 1:10){
  # Use AbbrevJournalName to search for the PMIDS 
  journal_pmid <- entrez_search(db = "pubmed", term = distinct_summary_results$AbbrevJournalName[i], retmax = 99999, use_history = TRUE)
  documents <- Corpus(VectorSource(entrez_fetch (db = "pubmed", web_history = journal_pmid$web_history, rettype = "medline", retmode = "text")))
  # Detect MH match
  if (is.na(stri_match_first_regex(documents$content, "\nMH "))) {
    distinct_summary_results$MH_match[i] <- FALSE
  }
}

# GOAL 3: 
# Obtain the Journals that don't have MeSH terms
# Find the corresponding Publisher and Country of Publication

# Only retrieve rows that do NOT have MH match
no_mesh_final_results <- filter(distinct_summary_results, MH_match == FALSE)

# Obtain the summary records back of each NLMID
no_mesh_final_multi_summary <- entrez_summary (db = "nlmcatalog", id = no_mesh_final_results$NLMUniqueID)

# Add columns Publisher and Country of Publication to our final table
# Initialize columns
no_mesh_final_results$Publisher <- rep(NA, length(no_mesh_final_results$PMID))
no_mesh_final_results$CountryOfPublication <- rep(NA, length(no_mesh_final_results$PMID))
# Add data to columns
for (i in 1:length(no_mesh_final_results$PMID)){
  no_mesh_final_results$Publisher[i] <- no_mesh_final_multi_summary[[i]]$publicationinfolist$publisher 
  no_mesh_final_results$CountryOfPublication[i] <- no_mesh_final_multi_summary[[i]]$country 
}

write.csv(no_mesh_final_results, file = "No MH Match Final Results.csv")
