library(png)

imagenames <- list.files("./7_lines_images", pattern="*.png", full.names=TRUE)

clean_line <- function(TSZ_line){
  TSZ_line_clean <- TSZ_line
  ##check empty lines starting from beginning
  for(i in 1:dim(TSZ_line)[1]){
    TSZ_subline <- TSZ_line[i,]
    if(length(which(TSZ_subline==0))==0){
      print("white line stripped")
      TSZ_line_clean <- TSZ_line_clean[-1,]
    }
    else{break}
  }
  ##starting from end
  for(i in 1:dim(TSZ_line)[1]){
    TSZ_subline <- TSZ_line[(dim(TSZ_line)[1]+1-i),]
    if(length(which(TSZ_subline==0))==0){
      TSZ_line_clean <- TSZ_line_clean[-(dim(TSZ_line_clean)[1]),]
      print("white line stripped")
    }
    else{break}
  }
  return(TSZ_line_clean)
}

for(i in 1:(length(imagenames))){
  TSZ_line <- readPNG(imagenames[[i]])
  TSZ_line <- clean_line(TSZ_line)
  writePNG(TSZ_line, imagenames[i])
  print(i)
}