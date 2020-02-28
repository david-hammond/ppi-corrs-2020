library(tidyverse)
library(hammond)
library(pbapply)
hdb_login(host = "192.168.0.65", db = "nationalhdb", user = "guest", password = "guest")
toc = hdb_toc()
toc = toc %>% filter(num_geos > 100)
source("./munge/03-get-rid-of-spurious.R")
toc = toc %>% filter(variablename != "Internal Peace Banded")
toc = split(toc, toc$uid)
gpi <- hdb_get(hdb_search("Internal Peace Banded")) %>% 
  filter(year == max(year)) %>% mutate(rank = rank(value))
bin = 60

get_corrs = function(id){
  tmp = hdb_get(id) %>% rbind(gpi %>% select(-rank))
  all = NULL
  for(i in 1:(nrow(gpi)-bin)){
    tmp2 = gpi %>% filter(between(rank, i, i+bin))
    tmp3 = tmp %>% filter(geocode %in% tmp2$geocode) # how to do all years
    tmp3 = try(hcorr(tmp3) %>% filter(n > 40) %>% mutate(group = i) %>%
      filter(var1 != "Internal Peace Banded"))
    if(class(tmp3) == "try-error"){
      tmp3 = NULL
    }
    all = rbind(all, tmp3)
  }
  return(all)
}


all = pblapply(toc, get_corrs)

#HAVE RUN UP TO HERE
all = rio::import("./data/results-correlations-2018-internalpeace.csv")%>% mutate(variablename1 = str_trim(variablename1))

tmp = tmp %>% select(-gpi, -obsall, -year, -corall) %>% gather("group", "r", -c("category", "variablename1")) %>%
  mutate(group = as.numeric(substr(group, 4,6)))
tmp$r = as.numeric(tmp$r)
thedata = tmp %>% filter(!is.na(r)) %>% group_by(category, group) %>% 
  #filter(abs(r) > 0.2) %>%
  top_n(6, abs(r)) %>% ungroup()
thedata = thedata %>% rename(var1 = variablename1)

thedata = thedata %>% arrange(category, var1) %>%
  mutate(var1 = factor(var1, unique(var1), ordered = T), 
         category = factor(category, unique(category), ordered = T),
         r = abs(r))

for (i in rev(sort(unique(thedata$group)))) {
  x = thedata %>% filter(group == i)

  data = x %>% rename(individual = var1, value = r, slice = group, group = category) %>%
    select(individual, group, value) %>% as.data.frame() %>% mutate(group = factor(group))
  # Set a number of 'empty bar' to add at the end of each group
  empty_bar <- 0
  to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group), ncol(data)) )
  colnames(to_add) <- colnames(data)
  to_add$group <- rep(levels(data$group), each=empty_bar)
  data <- rbind(data, to_add)
  data <- data %>% arrange(group)
  data$id <- seq(1, nrow(data))
  data$alpha = ifelse(data$value > 0.3, 0.75, 0.2)
  # Get the name and the y position of each label
  label_data <- data
  number_of_bar <- nrow(label_data)
  angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
  label_data$hjust <- ifelse( angle < -90, 1, 0)
  label_data$angle <- ifelse(angle < -90, angle+180, angle)
  
  # Make the plot
  p <- ggplot(data, aes(x=as.factor(id), y=value, fill=group)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
    geom_bar(stat="identity", alpha=data$alpha) +
    ylim(0,1) +
    theme_minimal() +
    theme(
      axis.text.x = element_blank(),
      axis.title.x = element_blank(),
      panel.grid.minor = element_blank(),
      plot.margin = unit(rep(-0,4), "cm"),
      axis.text.y = element_text(angle = 90, hjust = 0)
    ) +
    coord_polar() +
    geom_text(data=label_data, aes(x=id, y=0.3, label=individual, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=2.5, angle= label_data$angle, inherit.aes = FALSE ) +
    labs(subtitle = paste("Correlations of countries ranked between", i, "and", i+60),
         y = "R Value", fill = "Pillar")
  
  print(p)
}
