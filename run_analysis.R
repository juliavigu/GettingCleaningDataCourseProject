#Getting and cleaning data course
#Week 4 Course Project

###0. READING THE DATA###

#Download the data
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile="./Data.zip")
#unzip the data
unzip(zipfile="./Data.zip", list=TRUE) #the unzipped folder is called UCI HAR Dataset and has several txt files
#Import the datasets
#Data from subjects is stored on subject(...)
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt", header=FALSE, sep=" ")
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt", header=FALSE, sep=" ")
#Data on features is stored on X(...)
X_test<-read.table("./UCI HAR Dataset/test/X_test.txt", header=FALSE)
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt", header=FALSE)
#Data on activity types is stored on y(...)
y_test<-read.table("./UCI HAR Dataset/test/y_test.txt", header=FALSE, sep=" ")
y_train<-read.table("./UCI HAR Dataset/train/y_train.txt", header=FALSE, sep=" ")
#Data on the LABELS of the features and activities
featureslabels<-read.table("./UCI HAR Dataset/features.txt", header=FALSE)
activitylabels<-read.table("./UCI HAR Dataset/activity_labels.txt", header=FALSE)

####1. MERGING DATASETS###
#train and test df contain different observations of single variable, so we have to stagger (rbind)
#for subject data
subject<-rbind(subject_test, subject_train)
names(subject)<-("subject")
#for features data
features<-rbind(X_test, X_train)
names(features)<-featureslabels$V2
#for activity data
activity<-rbind(y_test, y_train)
names(activity)<-("activity")
#now merge the different types of data (diff vars) into a single dataset
data<-cbind(subject, activity, features)

###2. EXTRACT ONLY MEASURMENTS OF MEAN AND SD FOR EACH MEASURMENT###
#select variables that have the mean or sd calcs of each feature
#in addition to the subject and activity vars that we want to keep as well
subdata<-data[grepl("mean\\(|std\\(|subject|activity", names(data))] #subseted

###3. USE DESCRIPTIVE ACTIVITY NAMES TO NAME THE ACTIVITIES IN THE DATASET###
#Assigning labels to the factor levels of variable "activity"
subdata$activity<-factor(subdata$activity, levels=activitylabels$V1, labels=activitylabels$V2)

###4. APPROPRIATELY LABEL THE DATA SET WITH DESCRIPTIVE VAR NAMES###
#From the features info, we can see that t means time, f means frequency, 
#Gyro means gyroscpoe, Acc means acceleration signal, Mag is magnitude etc
names(subdata)<-gsub("^f", "Frequency", names(subdata))
names(subdata)<-gsub("^t", "Time", names(subdata))
names(subdata)<-gsub("Gyro", "Gyroscope", names(subdata))
names(subdata)<-gsub("Acc", "Accelerometer", names(subdata))
names(subdata)<-gsub("Mag", "Magnitude", names(subdata))
names(subdata)<-gsub("-mean\\(\\)", "Mean", names(subdata))
names(subdata)<-gsub("-std\\(\\)", "STD", names(subdata))
names(subdata)<-gsub("-freq\\(\\)", "Frequency", names(subdata))

###5. CREATE A SECOND INDEPENDENT TIDY DATASET WITH THE AVERAGE OF EACH VARIABLE FOR ###
### EACH ACTIVITY AND EACH SUBJECT ###
#install.packages("dplyr")
library(dplyr)
tidydata<- subdata %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))
write.table(tidydata, "TidyData.txt", row.name=FALSE)

#Make codebook
#install.packages("dataMaid")
library(dataMaid)
makeCodebook(tidydata)
