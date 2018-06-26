#!/bin/sh

##STEP0
##Preparation (creates some empty folders where to work in...)
mkdir 1_corpus_raw 2a_corpus_clean 2b_corpus_clean_bw 3_regions_page 4_regions_images 5_regions_images_straight 6_regions_images_straight_page 7_lines_images 8_OCRed_texts 9_OCRed_texts_Transkribus OCR_quality_eval/OCRopus OCR_quality_eval/transcripts OCR_quality_eval/Transkribus

###############
##Page segmentation
##Please run step by step and always check comments 
##Your image files should be in the ./1_corpus_raw directory, with .png extension 
#########

##STEP1
##straighten with OCRopy
##of course, you need to have OCRopy installed in the directory ~/ocropy-master/
##to install OCRopy, see here: https://github.com/tmbdev/ocropy

cd ~/ocropy-master/

###prepare images for Transkribus
./ocropus-nlbin ~/page_segmentation_pipeline/1_corpus_raw/*.png -n -o ~/page_segmentation_pipeline/2a_corpus_clean/

###separate bn and greyscale files
cd ~/page_segmentation_pipeline/2a_corpus_clean/
mv *.bin.png ../2b_corpus_clean_bw/

###restore original names
Rscript ../Code_OCR/Preserve_page_names.R
rm *.nrm.png
cd ../2b_corpus_clean_bw/
Rscript ./Code_OCR/Preserve_page_names.R
rm *.bin.png


##STEP2
##select text regions with Transkribus
##once again, you need to have Transkribus installed in the directory ~/Transkribus-1.3.7/
##to install Transkribus, see here: https://transkribus.eu/Transkribus/

cd ~/Transkribus-1.3.7/
./Transkribus.sh

##############
##operate inside Transkribus: upload Corpus (2a_corpus_clean), Run OCR with Gothic font, manually select text regions (to add inside R program)
##Download images using server download, and save in folder ./3_regions_page
##############


##STEP3
##first segmentation
cd ~/page_segmentation_pipeline/
Rscript ./Code_OCR/Segment_regions_FINAL.R #note: region order/selection is inside the R file and should be modified manually, in case you want to modify Transkribus's selection 
Rscript ./Code_OCR/White_borders_on_regions.R


##STEP4
##second straightening using scantailor
##once again, you need to have ScanTailor installed
##to install ScanTailor, see here: http://scantailor.org/

scantailor

##############
##operate inside Scantailor: upload Corpus from 4_regions_images
##Settings:
##2. Split Pages: 	set to manual and extend to full page
##3. Deskew:		auto and run on all pages
##4. Select Content:auto and run on all pages 
##6. Output 		save mode Black and White
##############

mv ./4_regions_images/out/*.tif ./5_regions_images_straight/
rm -rf ./4_regions_images/out


##STEP5
##lines isolation with Transkribus
cd ~/Transkribus-1.3.7/
./Transkribus.sh

##############
##operate inside Transkribus: upload Corpus (5_regions_images_straight) and run OCR with Gothic font
##Download images using server download, and save in folder ~/page_segmentation_pipeline/6_regions_images_straight_page
##############


##STEP6
##segment and clean lines with Rscript
cd ~/page_segmentation_pipeline/
Rscript ./Code_OCR/Segment_lines_FINAL.R
Rscript ./Code_OCR/Lines_cleaning.R


##STEP7
##OCR of segmented lines
cd ~/ocropy-master/

./ocropus-rpred -Q 4 -m models/fraktur.pyrnn.gz '/home/rsimone/page_segmentation_pipeline/7_lines_images/*.png' #note: OCRopus does not accept "~" in the input folder. Please substitute "/home/rsimone/" with home folder


##STEP8
##collect and order OCRed lines
cd ~/page_segmentation_pipeline/
Rscript ./Code_OCR/Prepare_OCR_output.R


##STEP9
##collect Transkribus OCRed lines

Rscript ./Code_OCR/Prepare_Tranksribus_OCR_output.R


##STEP10
##Quality evaluation

cp ./8_OCRed_texts/* ./OCR_quality_eval/OCRopus
cp ./9_OCRed_texts_Transkribus/* ./OCR_quality_eval/Transkribus

Rscript ./Code_OCR/OCR_quality_check.R
