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

pos = grepl("DK/RF", tmp$variablename)
tmp = tmp[!pos,]
pos = grepl("DK", tmp$variablename)
tmp = tmp[!pos,]
pos = grepl("Imports Merchandise", tmp$variablename)
tmp = tmp[!pos,]
pos = grepl("Percentile Rank", tmp$variablename)
tmp = tmp[!pos,]
pos = grepl("Lower Bound of", tmp$variablename)
tmp = tmp[!pos,]



tmp = tmp %>% 
  gather("group", "r", -c(names(tmp)[c(1:5)]))
tmp$r = as.numeric(tmp$r)
tmp = tmp %>% filter(!is.na(r)) %>% 
  group_by(category, group) %>%
  top_n(3, abs(r))


plot_by_pillar <- function(x) {
  pp = tmp %>% 
    filter(category == x, group != "corall")

  pp$variablename1 = factor(pp$variablename1, rev(unique(pp$variablename1)), ordered = T)

  pp$group = gsub("cor", "Rank ", pp$group)

  p <- ggplot(pp, aes(x = group, y = variablename1, size = abs(r))) +
  geom_point() + theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  p 
  
  return(as.data.frame(pp))} # not quite working,
                             # need a good way to get the numbers alongside the chart



plot_by_pillar("pp-wfg")
plot_by_pillar("pp-llc")
plot_by_pillar("pp-hlh")
plot_by_pillar("pp-sbe")
plot_by_pillar("pp-aro")
plot_by_pillar("pp-grn")
plot_by_pillar("pp-edr")
plot_by_pillar("pp-ffi")
