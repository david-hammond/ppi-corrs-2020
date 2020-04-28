
# Dave said to use this data
# NB: are NAs intentional?
df = rio::import("S:/Institute for Economics and Peace/Research/Research Briefs/Positive Peace/Positive Peace Systems/Correlations/results-correlations-2018-internalpeace.xlsx",
                 which = 2)

tmp = df %>% 
  gather("group", "r", -c(names(df)[c(1:5)]))

spurious = c("Control of Corruption: Number of Sources", 
             "Control of Corruption: Standard Error",
             "LLC: Control of Corruption",
             "Food and non-alcoholic beverages, Weight, Percent",
             "Acceptance of the Rights of Others",
             "Good Relations with Neighbours",
             "High Levels of Human Capital",
             "Low Levels of Corruption",
             "Sound Business Environment",
             "Free Flow of Information",
             "Well-Functioning Government")

tmp = tmp %>% filter(!(variablename1 %in% spurious))

pos = grepl("Approval of China's Leadership", tmp$variablename1)
tmp = tmp[!pos,]
pos = grepl("Approval of U.S. Leadership", tmp$variablename1)
tmp = tmp[!pos,]
pos = grepl("Approval of ", tmp$variablename1)
tmp = tmp[!pos,]

pos = grepl("Religion Important -", tmp$variablename1)
tmp = tmp[!pos,]

pos = grepl("DK/RF", tmp$variablename1)
tmp = tmp[!pos,]
pos = grepl("DK", tmp$variablename1)
tmp = tmp[!pos,]
pos = grepl("Imports Merchandise", tmp$variablename1)
tmp = tmp[!pos,]
pos = grepl("Percentile Rank", tmp$variablename1)
tmp = tmp[!pos,]
pos = grepl("Lower Bound of", tmp$variablename1)
tmp = tmp[!pos,]


pos = grepl("W-FG: ", tmp$variablename1)
tmp = tmp[!pos,]
pos = grepl("Rule of ", tmp$variablename1)
tmp = tmp[!pos,]

tmp$r = as.numeric(tmp$r)
tmp = tmp %>% 
  filter(!is.na(r)) %>% 
  group_by(category, group) %>%
  top_n(3, abs(r))
