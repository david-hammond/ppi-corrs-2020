
library('ProjectTemplate')
load.project(override.config = list(data_loading =T))

rmarkdown::render("notebook.Rmd", output_format = "word_document", output_file = "S:/Institute for Economics and Peace/Research/Research Briefs/Positive Peace/Peace group correlation analysis.doc")
