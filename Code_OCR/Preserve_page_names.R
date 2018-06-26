library(png)

imagenames <- list.files(".", pattern="*.png", full.names=FALSE)
finalnames <- list.files("./1_corpus_raw/", full.names=FALSE)

for(i in 1:length(imagenames)){
  TSZ_page <- readPNG(imagenames[[i]])
  writePNG(TSZ_page, finalnames[i])
  print(i)
}