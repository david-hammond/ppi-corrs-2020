

plot_by_pillar <- function(x) {
  pp = tmp %>% 
    filter(category == x, group != "corall")
  
  pp$variablename1 = factor(pp$variablename1, rev(unique(pp$variablename1)), ordered = T)
  
  pp$group = gsub("cor", "Rank ", pp$group)
  
  p <- ggplot(pp, aes(x = group, y = variablename1, size = abs(r))) +
    geom_point() + theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  p 
  
} # need a good way to get the numbers alongside the chart

