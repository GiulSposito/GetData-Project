## Getting and Cleaning Data - Coursera Course
## Final Project Code
## Author: Giuliano Sposito
## April/2015

## project tasks
##
## 1) You should create one R script called run_analysis.R that does the following. 
## 2) Merges the training and the test sets to create one data set.
## 3) Extracts only the measurements on the mean and standard deviation for each measurement. 
## 4) Uses descriptive activity names to name the activities in the data set
## 5) Appropriately labels the data set with descriptive variable names. 
## 6) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## constants
DTZIP_URL <- "https://d396qusza40orc.cloudfront.net/getdata/projectfiles/UCI%20HAR%20Dataset.zip"
DT_FOLDER <- "./UCI HAR Dataset"

## test data filenames
DT_TEST_FOLDER  <- paste(sep="/", DT_FOLDER, "test")
TEST_Y_FILENAME <- paste(sep="/", DT_TEST_FOLDER, "Y_test.txt")
TEST_X_FILENAME <- paste(sep="/", DT_TEST_FOLDER, "X_test.txt")
TEST_SUBJECT_FILENAME    <- paste(sep="/", DT_TEST_FOLDER, "subject_test.txt")

## train data filenames
DT_TRAIN_FOLDER  <- paste(sep="/", DT_FOLDER, "train")
TRAIN_Y_FILENAME <- paste(sep="/", DT_TRAIN_FOLDER, "Y_train.txt")
TRAIN_X_FILENAME <- paste(sep="/", DT_TRAIN_FOLDER, "X_train.txt")
TRAIN_SUBJECT_FILENAME   <- paste(sep="/", DT_TRAIN_FOLDER, "subject_train.txt")

## feature file -> column names for data
FEAT_NAMES_FILE <- paste(sep="/", DT_FOLDER, "features.txt")
ACTIVITY_LABEL_FILE <- paste(sep="/", DT_FOLDER, "activity_labels.txt")

## result tidy data filename
RESULT_FILE <- "./resultData.txt"

## check if data folder exists
if(!file.exists(DT_FOLDER)) {
  
  ## if not-> download and unzip data files
  temp <- tempfile()
  download.file(DTZIP_URL, temp)
  unzip(temp, exdir=".")
  unlink(temp)
  
  ## clean memory
  rm(temp)
}

## reading datas
xTest <- read.table(TEST_X_FILENAME)
yTest <- read.table(TEST_Y_FILENAME)
subTest <- read.table(TEST_SUBJECT_FILENAME)

xTrain <- read.table(TEST_X_FILENAME)
yTrain <- read.table(TEST_Y_FILENAME)
subTrain <- read.table(TEST_SUBJECT_FILENAME)

## feature names
dfFeatureNames <- read.table(FEAT_NAMES_FILE, colClasses=c("numeric","character"))
colnames(dfFeatureNames) <- c("featNum", "featName")

## change column name
colnames(xTest) <- dfFeatureNames[,2]
colnames(xTrain) <- dfFeatureNames[,2]

## subsetting only mean and std values
dfMeanStdFeatureIds <- grep("mean|std",dfFeatureNames[,2],value=F)
xTest<-xTest[,dfMeanStdFeatureIds]
xTrain<-xTrain[,dfMeanStdFeatureIds]
dfMeanStdFeatureNames <- dfFeatureNames[dfMeanStdFeatureIds,]

## merging the dataframes and renaming columns
dfFeatures <- rbind(xTest,xTrain)
dfActivity <- rbind(yTest,yTrain)
colnames(dfActivity) <- c("activityId")
dfSubject <- rbind(subTest,subTrain)
colnames(dfSubject) <- c("subject")

## cleaning some memory
rm(xTest, yTest, subTest, xTrain, yTrain, subTrain, dfFeatureNames)

## merging all observations
dfObs <- cbind(dfSubject, dfActivity, dfFeatures)

## clean more memory
rm(dfSubject, dfActivity, dfFeatures)

## importing activity label
dfActivityLabels <- read.table(ACTIVITY_LABEL_FILE, colClasses=c("numeric","factor"))
colnames(dfActivityLabels) <- c("activityId","activityName")

## merging Activity with ActivityLabel
dfObs <- merge(dfObs, dfActivityLabels, by="activityId", all.x=TRUE)

## melting the data set to pivot through subject + activity
library(reshape2)
rawData <- melt(dfObs, id=c("subject","activityName"), measure.vars=dfMeanStdFeatureNames[,2])
pivotTable <- dcast(rawData, subject + activityName ~ variable, fun.aggregate=mean)

## save the new tidy data
write.table(pivotTable,file=RESULT_FILE, sep=" ", dec=".", row.names=F)