# Import entire data from the .txt file
library(readr)
library(data.table)
library(reshape)
library(dplyr)
library(tidyr)

# Read in raw data
test <- read_delim(file = "/Users/Annie/Desktop/BD2K/RAW DATA/Terms/Hypertension.txt", delim = "\n", col_names = FALSE) 

# --- Run the next few lines only if PMID is not attached to the top of the dataframe
# Shows indices of each PMID
a <- as.data.frame(which(grepl("^PMID", test$X1)))
colnames(a) <- "X1"
# Bind first entry's PMID to top of dataframe
first_pmid <- test[a[1, 1], ]
test <- rbind(first_pmid, test) 
# Shows indices of each PMID after the bind
a <- as.data.frame(lapply(a, FUN = function(x) x+1)) # recalibrate indices by adding 1
test <- test[-a[2, 1], 1] # remove duplicate 1st PMID
remove(first_pmid)
remove(a)
# --- Resume normal code

# Keep only PMID, MH, RN, PST
test <- test[substr(test$X1, 1, 4) == "PMID" | substr(test$X1, 1, 2) == "MH" |
               substr(test$X1, 1, 2) == "RN" | substr(test$X1, 1, 3) == "PST", ]
# Remove MHDA
test <- filter(test, !grepl(pattern = "MHDA", x = test$X1))

# Coerce tibble to data table
setDT(test)
# Reorder variables suggestion 1
test <- test[, old_order := 1:.N]
pst_index <- c(0, which(grepl("^PST", test$X1)))
test <- test[, grp := unlist(lapply(1:(length(pst_index)-1), function(x) rep(x, times = (pst_index[x+1] - pst_index[x]))))]
test <- test[ , -c("old_order")]

# Rename column
names(test) <- c("All", "group")
# Create column names
test$Variable <- sub("-.*", '', test$All)
# Extract only the data
test$Value <- sub(".*- ", '', test$All)
# Reshape from wide to long, thereby collapsing strings if necessary
test <- test %>% group_by(group, Variable) %>% summarise(Value = paste(gsub(' ', ' ', Value), collapse='_ ')) %>% spread(Variable, Value)

# Clean up dataframe
test <- test[ , -which(names(test) %in% c("group", "PST"))]
test <- test[ , c(2, 1, 4)]
# Rename because column names have spaces in them
colnames(test) <- c("PMID", "MH", "RN") 
# Test <- test[complete.cases(test), ]
# Change class
test$PMID <- as.numeric(test$PMID)
test$MH <- as.character(test$MH)
test$RN <- as.character(test$RN)

# Save dataframe
save(test, file = "Hypertension.RData")