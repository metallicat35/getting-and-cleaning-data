## R script for getting and cleaning data project
library(downloader)
library(plyr);
library(knitr)
## 1st Step: Download the dataset and unzip folder

if(!file.exists("./projectData")){
  dir.create("./projectData")
  }
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./projectData/project_Dataset.zip")){
  download.file(Url,destfile="./projectData/project_Dataset.zip",mode = "wb")
  }

if(!file.exists("./projectData/UCI HAR Dataset")){
  unzip(zipfile="./projectData/project_Dataset.zip",exdir="./projectData")
}
path <- file.path("./projectData" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)

## 2nd Step: Load activity, subject and feature info.
ActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)
SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
FeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

## 3rd Step Merge the training and the test sets to create one data set.
dataSubject <- rbind(SubjectTrain, SubjectTest)
dataActivity<- rbind(ActivityTrain, ActivityTest)
dataFeatures<- rbind(FeaturesTrain, FeaturesTest)
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## 4th Step: Extracts only the measurements on the mean and standard deviation for each measurement.
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

## 5th Step: Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
Data$activity<-factor(Data$activity,labels=activityLabels[,2])
head(Data$activity,30)

## 6th step: Appropriately labels the data set with descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
names(Data)

## 7th Step: Creates a independent tidy data set
newData<-aggregate(. ~subject + activity, Data, mean)
newData<-newData[order(newData$subject,newData$activity),]
write.table(newData, file = "tidydata.txt",row.name=FALSE,quote = FALSE, sep = '\t')
