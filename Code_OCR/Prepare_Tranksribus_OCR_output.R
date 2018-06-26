library(XML)

filenames <- list.files("./6_regions_images_straight_page/page", pattern="*.xml", full.names=TRUE)
ns <- c(ns="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15")

regions_grouping <- list.files("./5_regions_images_straight", pattern="*.tif", full.names=FALSE)
regions_grouping <- substring(regions_grouping, 1,2)
output_folder <- "./9_OCRed_texts_Transkribus/"

files_id <- regions_grouping

clean_text <- list()
for(iter in 1:length(filenames)){
  result <- xmlTreeParse(filenames[[iter]], useInternalNodes = TRUE)
  rootnode <- xmlRoot(result)
  clean_text[[iter]] <- xpathSApply(rootnode, "//ns:TextLine/ns:TextEquiv/ns:Unicode", xmlValue, namespaces = ns)
  print(iter)
}

output_text_vector <- unlist(lapply(clean_text, function(x){paste(x, collapse = "\n")}))

output_text <- character()
for(i in 1:length(filenames)){
  output_text <- paste(output_text, output_text_vector[i], sep = "\n")
  if(i<(length(filenames)) && files_id[i]!=files_id[i+1]){
    output_text <- substring(output_text, 2, nchar(output_text))
    write(output_text, paste(output_folder, files_id[i], ".txt", sep = ""), sep = "")
    output_text <- character()
    cat("Done", files_id[i], "\n")
  }
  if(i==(length(filenames))){
    output_text <- substring(output_text, 2, nchar(output_text))
    write(output_text, paste(output_folder, files_id[i], ".txt", sep = ""), sep = "")
    output_text <- character()
    cat("Done", files_id[i], "\n")
  }
}
