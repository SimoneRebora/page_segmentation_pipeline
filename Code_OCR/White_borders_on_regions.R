library(png)

setwd("./4_regions_images/")
imagenames <- list.files(".", pattern="*.png", full.names=FALSE)

for(i in 1:length(imagenames)){
  TSZ_page <- readPNG(imagenames[[i]])
  white_line <- matrix(1, 100, dim(TSZ_page)[2])
  TSZ_page <- rbind(white_line, TSZ_page)
  TSZ_page <- rbind(TSZ_page, white_line)
  white_column <- matrix(1, dim(TSZ_page)[1], 100)
  TSZ_page <- cbind(white_column, TSZ_page)
  TSZ_page <- cbind(TSZ_page, white_column)
  writePNG(TSZ_page, imagenames[i])
  print(i)
}
