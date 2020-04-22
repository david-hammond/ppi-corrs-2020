library(tidyverse)
tmp = rio::import("S:/Institute for Economics and Peace/Research/Research Briefs/Positive Peace/Positive Peace Systems/Correlations/results-correlations-2018-internalpeace.xlsx",
                  which = 2)

spurious = c("Control of Corruption: Number of Sources", 
             "Control of Corruption: Standard Error",
             "Food and non-alcoholic beverages, Weight, Percent")

tmp = tmp %>% filter(!(variablename1 %in% spurious))


pos = grepl("Approval of China's Leadership", tmp$variablename1)
tmp = tmp[!pos,]
pos = grepl("Approval of U.S. Leadership", tmp$variablename1)
tmp = tmp[!pos,]
pos = grepl("Approval of ", tmp$variablename1)
tmp = tmp[!pos,]

pos = grepl("Religion Important -", tmp$variablename)
tmp = tmp[!pos,]

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



tmp = tmp %>% 
  gather("group", "r", -c(names(tmp)[c(1:5)]))
tmp$r = as.numeric(tmp$r)
tmp = tmp %>% filter(!is.na(r)) %>% 
  group_by(category, group) %>%
  top_n(3, abs(r))





pp_aro = tmp %>% filter(category == "pp-aro", group != "corall")
pp_aro$variablename1 = factor(pp_aro$variablename1, rev(unique(pp_aro$variablename1)), ordered = T)
pp_aro$group = gsub("cor", "Rank ", pp_aro$group)
ggplot(pp_aro, aes(x = group, y = variablename1, size = abs(r))) +
  geom_point() + theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
