library(tidyverse)

###prepare texts for comparison
setwd("./OCR_quality_eval")

##transcripts
filenames <- list.files(path = "transcripts", pattern="*.txt", full.names=TRUE)
ldf <- lapply(filenames, function(x){readLines(x, encoding = "UTF-8")})
for(i in 1:length(ldf)){
  ldf[[i]] <- ldf[[i]][ldf[[i]]!=""]
}
full_transcripts <- lapply(ldf, function(x){paste(x, collapse = " ")})

##OCRopus
filenames <- list.files(path = "OCRopus", pattern="*.txt", full.names=TRUE)
ldf <- lapply(filenames, function(x){readLines(x, encoding = "UTF-8")})
for(i in 1:length(ldf)){
  ldf[[i]] <- ldf[[i]][ldf[[i]]!=""]
}
full_OCRopus_texts <- lapply(ldf, function(x){paste(x, collapse = "#NEWLINE#")})
full_OCRopus_texts <- lapply(full_OCRopus_texts, function(x) {gsub("-#NEWLINE#","",x)})
full_OCRopus_texts <- lapply(full_OCRopus_texts, function(x) {gsub("#NEWLINE#"," ",x)})
full_OCRopus_texts <- lapply(full_OCRopus_texts, function(x) {gsub("\\s+"," ",x)})

##Transkribus
filenames <- list.files(path = "Transkribus", pattern="*.txt", full.names=TRUE)
ldf <- lapply(filenames, function(x){readLines(x, encoding = "UTF-8")})
for(i in 1:length(ldf)){
  ldf[[i]] <- ldf[[i]][ldf[[i]]!=""]
}
full_Transkribus_texts <- lapply(ldf, function(x){paste(x, collapse = "#NEWLINE#")})
full_Transkribus_texts <- lapply(full_Transkribus_texts, function(x) {gsub("¬#NEWLINE#","",x)})
full_Transkribus_texts <- lapply(full_Transkribus_texts, function(x) {gsub("#NEWLINE#"," ",x)})
full_Transkribus_texts <- lapply(full_Transkribus_texts, function(x) {gsub("\\s+"," ",x)})


##Error-rate calculation
error_rate_OCRopus <- vector("numeric", length(full_transcripts))
error_rate_AbbyyFR  <- vector("numeric", length(full_transcripts))

for(i in 1:length(full_transcripts)){
  print(i)
  ###OCRopus
  total_length <- nchar(full_OCRopus_texts[[i]])
  total_errors <- adist(full_OCRopus_texts[[i]], full_transcripts[[i]])
  error_rate_OCRopus[i] <- total_errors/total_length
  ###Transkribus
  total_length <- nchar(full_Transkribus_texts[[i]])
  total_errors <- adist(full_Transkribus_texts[[i]], full_transcripts[[i]])
  error_rate_AbbyyFR[i] <- total_errors/total_length
}

OCR_quality_df <- data.frame(text=1:length(full_transcripts), error_rate_OCRopus=error_rate_OCRopus*100, error_rate_AbbyyFR=error_rate_AbbyyFR*100)

OCR_quality_df$text <- as.character(OCR_quality_df$text)

library(reshape2)
OCR_quality_melt <- melt(OCR_quality_df, variable.name = )

OCR_quality_melt$text <- as.factor(OCR_quality_melt$text)
OCR_quality_melt$text <- factor(OCR_quality_melt$text, levels = OCR_quality_melt$text[1:length(full_transcripts)])

colnames(OCR_quality_melt) <- c("text", "OCR_method", "error_percentage")

p1 <- ggplot(OCR_quality_melt) + 
  geom_line(mapping = aes(text, error_percentage, color = OCR_method, group = OCR_method)) +
  theme_light()

p2 <- ggplot(OCR_quality_melt) + 
  geom_line(mapping = aes(text, error_percentage, color = OCR_method, group = OCR_method)) +
  coord_cartesian(ylim = c(0, 10)) +
  theme_light()
p2

ggsave("OCR_QualityCheck.png", p2, height = 15, width = 25, units = "cm")

print("OCRopus")
print(mean(error_rate_OCRopus))
print("Transkribus/ABBYY")
print(mean(error_rate_Transkribus))