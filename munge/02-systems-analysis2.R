library(tidyverse)
library(hammond)
library(pbapply)
hdb_login(host = "192.168.0.65", db = "nationalhdb", user = "guest", password = "guest")
toc = hdb_toc()
toc = toc %>% filter(num_geos > 100)
source("./munge/03-get-rid-of-spurious.R")
toc = toc %>% filter(variablename != "Internal Peace Banded")
toc = toc %>% filter(source != "IEP")
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
all = bind_rows(all) 
saveRDS(all, file = "./data/all-correlations.rds")
all = readRDS("./data/all-correlations.rds") %>% filter(signif == "***") %>% select(-var2, -n, -p, -signif)
pillars = rio::import("./data/results-correlations-2018-internalpeace.csv")  %>% select(variablename1, category) %>%
  distinct() %>% rename(var1 = variablename1) %>% mutate(var1 = str_trim(var1))
all = all %>% left_join(pillars) 
all$category[is.na(all$category)] = "other"
thedata = all %>% group_by(category, group) %>%
  top_n(3, abs(r)) %>% ungroup() %>% filter(!(category %in% c("statistical", "np")))
thedata = all %>% filter(var1 %in% thedata$var1) %>% mutate(r = round(abs(r), 2))
saveRDS(thedata, file = "./dashboard/thedata.rds")
