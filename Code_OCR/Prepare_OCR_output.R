filenames <- list.files("./7_lines_images/", pattern="*.txt", full.names=TRUE)
files_id <- list.files("./7_lines_images/", pattern="*.txt", full.names=F)
files_id <- substring(files_id, 1, 2)
output_folder <- "./8_OCRed_texts/"

output_text <- character()
for(i in 1:length(filenames)){
  TSZ_line <- readLines(filenames[i])
  output_text <- paste(output_text, TSZ_line, sep = "\n")
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
