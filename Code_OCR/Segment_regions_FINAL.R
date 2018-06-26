library(XML)
library(magick)

filenames <- list.files("./3_regions_page/page", pattern="*.xml", full.names=TRUE)
imagenames <- list.files("./2b_corpus_clean_bw", pattern="*.png", full.names=TRUE)
output_folder <- "./4_regions_images/"

##select regions with transcribed text (still manual, based on Transkribus areas...)
##the following is an example, it should be modified according to specific needs
regions_selection <- list(c(20:21), 
  c(2:4, 10:13, 5:8, 14:15), 
  c(2:4, 10:14, 5:7), 
  c(8:22), 
  c(2:8), 
  c(2:9), 
  c(2:10), 
  c(2:6), 
  c(5:12), 
  c(23:24), 
  c(1:5, 8:11), 
  c(7:13), 
  c(2:6), 
  c(3:10), 
  c(2:19), 
  c(9:12), 
  c(1:3, 8:9, 4:6, 10:11),
  c(2:7),
  c(2:4), 
  c(3:9), 
  c(5:8), 
  c(8:12), 
  c(2:6), 
  c(2:8), 
  c(1:3, 11),
  c(3:5),
  c(23:25),
  c(1:2, 4),
  c(8:15),
  c(2:3, 7),
  c(7:18),
  c(2:3),
  c(2:7),
  c(2:12),
  c(2:8),
  c(9:14),
  c(2:7),
  c(5:12),
  c(2:9),
  c(2:7),
  c(2:3),
  c(4:11),
  c(2:7),
  c(1:7),
  c(1:3, 6:8),
  c(2:7),
  c(2:5),
  c(2:9),
  c(2:7),
  c(2:3),
  c(2:11),
  c(3:6))

regions_grouping <- list.files("./2a_corpus_clean", pattern="*.png", full.names=FALSE)
regions_grouping <- strsplit(regions_grouping, "-")
regions_grouping <- unlist(lapply(regions_grouping, function(x){(x)[1]}))
regions_grouping <- as.numeric(substring(regions_grouping, 4,5))

final_coords <- character()
ns <- c(ns="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15")

#############
##Functions

update_coords <- function(region_coord_tmp){
  coords_tmp <- region_coord_tmp
  ###extract this from Page file
  dummy <- unlist(strsplit(coords_tmp, " "))
  x_min_region <- as.numeric(unlist(strsplit(dummy[1], ","))[1])
  x_max_region <- as.numeric(unlist(strsplit(dummy[2], ","))[1])
  y_min_region <- as.numeric(unlist(strsplit(dummy[1], ","))[2])
  y_max_region <- as.numeric(unlist(strsplit(dummy[3], ","))[2])
  if(length(final_coords)==4){
    x_min_region <- min(x_min_region, final_coords[1])
    x_max_region <- max(x_max_region, final_coords[2])
    y_min_region <- min(y_min_region, final_coords[3])
    y_max_region <- max(y_max_region, final_coords[4])
  }
  final_coords <- c(x_min_region, x_max_region, y_min_region, y_max_region)
  return(final_coords)
}

center_crossing <- function(){
  coords_tmp <- region_coord[regions_selection[[iter]][section]]
  ###extract this from Page file
  dummy <- unlist(strsplit(coords_tmp, " "))
  x_min_region <- as.numeric(unlist(strsplit(dummy[1], ","))[1])
  x_max_region <- as.numeric(unlist(strsplit(dummy[2], ","))[1])
  coords_tmp <- region_coord[regions_selection[[iter]][section+1]]
  dummy <- unlist(strsplit(coords_tmp, " "))
  x_min_region2 <- as.numeric(unlist(strsplit(dummy[1], ","))[1])
  x_max_region2 <- as.numeric(unlist(strsplit(dummy[2], ","))[1])
  region2_mean <- (x_min_region2+x_max_region2)/2
  if(region2_mean < x_max_region & region2_mean > x_min_region){
    return(FALSE)
  }
  else{return(TRUE)}
}

empty_space <- function(){
  coords_tmp <- region_coord[regions_selection[[iter]][section]]
  ###extract this from Page file
  dummy <- unlist(strsplit(coords_tmp, " "))
  y_max_region <- as.numeric(unlist(strsplit(dummy[3], ","))[2])
  lines_coord <- xpathSApply(region_nodes[[page_region]], "ns:TextLine/ns:Coords", xmlGetAttr, "points", namespaces = ns)
  lines_limit <- 0
  for(i in 1:length(lines_coord)){
    coords_tmp <- lines_coord[i]
    dummy <- unlist(strsplit(coords_tmp, " "))
    y_min <- as.numeric(unlist(strsplit(dummy[1], ","))[2])
    y_max <- as.numeric(unlist(strsplit(dummy[3], ","))[2])
    lines_limit <- max(lines_limit, y_max-y_min)
  }
  coords_tmp <- region_coord[regions_selection[[iter]][section+1]]
  dummy <- unlist(strsplit(coords_tmp, " "))
  y_min_region2 <- as.numeric(unlist(strsplit(dummy[1], ","))[2])
  regions_distance <- y_min_region2 - y_max_region
  if(regions_distance > lines_limit){
    return(TRUE)
  }
  else{return(FALSE)}
}

################
## Main iteration

actual_sections <- sum(sapply(regions_selection, length))
computed_sections <- 0

for(iter in 1:length(regions_selection)){
  result <- xmlTreeParse(filenames[[iter]], useInternalNodes = TRUE)
  rootnode <- xmlRoot(result)
  region_coord <- xpathSApply(rootnode, "//ns:TextRegion/ns:Coords", xmlGetAttr, "points", namespaces = ns)
  region_nodes <- xpathSApply(rootnode, "//ns:TextRegion", namespaces = ns)
  full_page <- image_read(imagenames[iter])
  #plot(full_page)
  new_section <- 1
  section <- 1
  for(page_region in regions_selection[[iter]]){
    if(section==length(regions_selection[[iter]])){
      cat(iter, section, "\n")
      print("Final line")
      final_coords <- update_coords(region_coord[page_region])
      book_region <- image_crop(full_page, paste(final_coords[2] - final_coords[1], "x", final_coords[4] - final_coords[3], "+", final_coords[1], "+", final_coords[3], sep = ""))
      plot(book_region)
      image_write(book_region, path = paste(output_folder, sprintf("%02d", regions_grouping[iter]), sprintf("%02d", iter), sprintf("%02d", new_section), ".png", sep = ""), format = "png")
      final_coords <- character()
      section <- section+1
      new_section <- new_section+1
      computed_sections <- computed_sections+1
      next
    }
    if(center_crossing()==TRUE){
      cat(iter, section, "\n")
      print("Column switch")
      final_coords <- update_coords(region_coord[page_region])
      book_region <- image_crop(full_page, paste(final_coords[2] - final_coords[1], "x", final_coords[4] - final_coords[3], "+", final_coords[1], "+", final_coords[3], sep = ""))
      plot(book_region)
      image_write(book_region, path = paste(output_folder, sprintf("%02d", regions_grouping[iter]), sprintf("%02d", iter), sprintf("%02d", new_section), ".png", sep = ""), format = "png")
      final_coords <- character()
      section <- section+1
      new_section <- new_section+1
      computed_sections <- computed_sections+1
      next
    }
    if(empty_space()==TRUE){
      cat(iter, section, "\n")
      print("Empty space detected")
      final_coords <- update_coords(region_coord[page_region])
      book_region <- image_crop(full_page, paste(final_coords[2] - final_coords[1], "x", final_coords[4] - final_coords[3], "+", final_coords[1], "+", final_coords[3], sep = ""))
      plot(book_region)
      image_write(book_region, path = paste(output_folder, sprintf("%02d", regions_grouping[iter]), sprintf("%02d", iter), sprintf("%02d", new_section), ".png", sep = ""), format = "png")
      final_coords <- character()
      section <- section+1
      new_section <- new_section+1
      computed_sections <- computed_sections+1
      next
    }
    final_coords <- update_coords(region_coord[page_region])
    cat(iter, section, "\n")
    section <- section+1
    computed_sections <- computed_sections+1
  }
}
if(actual_sections!=computed_sections){print("ERROR: a line got lost!!!!")}