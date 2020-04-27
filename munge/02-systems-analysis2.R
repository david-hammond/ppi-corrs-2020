library(tidyverse)
library(hammond)
library(pbapply)

hdb_login(host = "192.168.0.65", db = "nationalhdb", user = "guest", password = "guest")
toc = hdb_toc()
toc = toc %>% filter(num_geos > 100)

source("./munge/03-get-rid-of-spurious.R")

# toc = toc %>% filter(variablename != "Internal Peace Banded")
# toc = toc %>% filter(source != "IEP")
# #toc$id = seq_along(toc$uid) %/% 100
# toc = split(toc, toc$uid)
# gpi <- hdb_get(hdb_search("Internal Peace Banded")) %>% 
#   filter(year == max(year)) %>% mutate(rank = rank(value))
# bin = 60
# 
# get_corrs = function(id){
#   tmp = hdb_get(id) %>%  
#     mutate(variablename = uid)%>%rbind(gpi %>% select(-rank))
#   all = NULL
#   for(i in seq(1, (nrow(gpi)-bin), by = 3)){
#     tmp2 = gpi %>% filter(between(rank, i, i+bin))
#     tmp3 = tmp %>% filter(geocode %in% tmp2$geocode) # how to do all years
#     tmp3 = try(hcorr(tmp3) %>% filter(n > 40) %>% mutate(group = i) %>%
#       filter(var1 != "Internal Peace Banded", var2 == "Internal Peace Banded")) %>%
#       select(-var2)
#     if(class(tmp3) == "try-error"){
#       tmp3 = NULL
#     }
#     all = rbind(all, tmp3)
#   }
#   return(all)
# }
# 
# 
# all = pblapply(toc, get_corrs)
# all = bind_rows(all) 
# saveRDS(all, file = "./data/all-correlations.rds")
all = readRDS("./data/all-correlations.rds") %>% filter(signif == "***") %>% select( -n, -p, -signif)
toc = hdb_toc()
all = all %>% rename(uid = var1) %>% left_join(toc)
pillars = rio::import("./data/results-correlations-2018-internalpeace.csv")  %>% select(variablename1, category) %>%
  distinct() %>% rename(variablename = variablename1) %>% mutate(variablename = str_trim(variablename))
all = all %>% left_join(pillars) 
all$category[is.na(all$category)] = "other"
thedata = all %>% group_by(category, group) %>%
  top_n(3, abs(r)) %>% ungroup() %>% filter(!(category %in% c("environmental", "other", "statistical", "np")))
# thedata = all %>% filter(variablename %in% thedata$variablename) %>% mutate(r = round(abs(r), 2))
# saveRDS(thedata, file = "./dashboard/thedata.rds")
# tmp = thedata %>% filter(group == 1)
# tmp = as.character(unique(tmp$variablename))
# for (i in sort(unique(thedata$group))[-1]){
#   tmp = union(tmp, unique(thedata$variablename[thedata$group==i]))
# } #This doesn't work

