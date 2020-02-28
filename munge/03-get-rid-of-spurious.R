
spurious = c("Control of Corruption: Number of Sources", 
             "Control of Corruption: Standard Error",
             "LLC: Control of Corruption",
             "Food and non-alcoholic beverages, Weight, Percent")
toc = toc %>% filter(!(variablename %in% spurious))
pos = grepl("Approval of China's Leadership", toc$variablename)
toc = toc[!pos,]
pos = grepl("Approval of U.S. Leadership", toc$variablename)
toc = toc[!pos,]
pos = grepl("Approval of ", toc$variablename)
toc = toc[!pos,]
pos = grepl("Religion Important ", toc$variablename)
toc = toc[!pos,]
pos = grepl("DK/RF", toc$variablename)
toc = toc[!pos,]
pos = grepl("DK", toc$variablename)
toc = toc[!pos,]
pos = grepl("Imports Merchandise", toc$variablename)
toc = toc[!pos,]
pos = grepl("Percentile Rank", toc$variablename)
toc = toc[!pos,]
pos = grepl("Lower Bound of", toc$variablename)
toc = toc[!pos,]
toc = toc %>% 
  filter(!(variablename %in% 
             c("Acceptance of the Rights of Others",
               "Good Relations with Neighbours",
               "High Levels of Human Capital",
               "Low Levels of Corruption",
               "Sound Business Environment",
               "Free Flow of Information",
               "Well-Functioning Government")))