library(XML)
library(magick)

setwd("./7_lines_images")

blank_page <- image_read("./Blank_page.png")

filenames <- list.files("./6_regions_images_straight_page/page", pattern="*.xml", full.names=TRUE)
imagenames <- list.files("./5_regions_images_straight", pattern="*.tif", full.names=TRUE)

regions_grouping <- list.files("./5_regions_images_straight", pattern="*.tif", full.names=FALSE)
regions_grouping <- as.numeric(substring(regions_grouping, 1,2))

lines_count <- 1
for(iter in 1:length(filenames)){
  if(iter>1){
    if(regions_grouping[iter]!=regions_grouping[iter-1]){
      lines_count <- 1
    }
  }
  result <- xmlTreeParse(filenames[[iter]], useInternalNodes = TRUE)
  rootnode <- xmlRoot(result)
  ns <- c(ns="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15")
  lines_coord <- xpathSApply(rootnode, "//ns:TextLine/ns:Coords", xmlGetAttr, "points", namespaces = ns)

  full_page <- image_read(imagenames[iter])
  lines_nodes <- xpathSApply(rootnode, "//ns:TextLine", namespaces = ns)
  ###check if lines were not recognized
  if(length(lines_nodes)==0){
    image_write(blank_page, path = paste(sprintf("%04d", lines_count), ".png", sep = ""), format = "png")
    lines_count <- lines_count+1
    print("Error!!!!!!!!!!!")
    next
  }

  for(page_line in 1:length(lines_coord)){
    coords_tmp <- lines_coord[page_line]
    ###extract this from Page file
    dummy <- unlist(strsplit(coords_tmp, " "))
    x_min_line <- as.numeric(unlist(strsplit(dummy[1], ","))[1])
    x_max_line <- as.numeric(unlist(strsplit(dummy[2], ","))[1])
    y_min_line <- as.numeric(unlist(strsplit(dummy[1], ","))[2])
    y_max_line <- as.numeric(unlist(strsplit(dummy[3], ","))[2])
    book_line <- image_crop(blank_page, paste(x_max_line - x_min_line, "x", y_max_line - y_min_line, sep = ""))
    words_coord <- xpathSApply(lines_nodes[[page_line]], "ns:Word/ns:Coords", xmlGetAttr, "points", namespaces = ns)
    for(page_word in 1:length(words_coord)){
      coords_tmp <- words_coord[page_word]
      ###extract this from Page file
      dummy <- unlist(strsplit(coords_tmp, " "))
      x_min_word <- as.numeric(unlist(strsplit(dummy[1], ","))[1])
      x_max_word <- as.numeric(unlist(strsplit(dummy[2], ","))[1])
      y_min_word <- as.numeric(unlist(strsplit(dummy[1], ","))[2])
      y_max_word <- as.numeric(unlist(strsplit(dummy[3], ","))[2])
      book_word <- image_crop(full_page, paste(x_max_word - x_min_word, "x", y_max_word - y_min_word, "+", x_min_word, "+", y_min_word, sep = ""))
      book_line <- image_composite(book_line, book_word, offset = paste("+", x_min_word - x_min_line, "+", y_min_word - y_min_line))
    }
    image_write(book_line, path = paste(sprintf("%02d", regions_grouping[iter]), sprintf("%04d", lines_count), ".png", sep = ""), format = "png")
    lines_count <- lines_count+1
  }
  print(iter)
}
