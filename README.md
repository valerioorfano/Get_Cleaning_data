##This document explains in details the content of the script run_analysis.R 

**Data source:**
The training and test data sets input of the script are extracted from
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
We suppose that the content of the above zip file is downloaded and stored belowe the current working directory.
####Scope of the script:
* **1.	Merges the training and the test sets to create one data set.**
* **2.	Extracts only the measurements on the mean and standard deviation for each measurement. **
* **3.	Uses descriptive activity names to name the activities in the data set**
* **4.	Appropriately labels the data set with descriptive activity names.**
* **5.	Creates a second, independent tidy data set with the average of each variable for each activity and each subject.**

####Belowe the description of the run_analysis.R script
*Some variables are initialized to the proper folder and file names.*
	dataDir <- "UCI HAR Dataset"
	trainDir <-"train"
	testDir <- "test"
	trainFiles <- c("X_train.txt", "subject_train.txt", "y_train.txt")
	testFiles<- c("X_test.txt", "subject_test.txt", "y_test.txt")
	genFiles<-c("activity_labels.txt", "features.txt")

*Checkout function: It is used to verify that all the files are in the proper folders.*


	checkout<-function(dataDir,subDataDir,dataFiles){
		for (i in 1: length(dataFiles)){
			if (!(file.exists(file.path(dataDir,subDataDir,dataFiles[i])))) {
				print(file.exists(file.path(dataDir,subDataDir,dataFiles[i])))
				stop("File: ", file.path(dataDir,subDatabDir,dataFiles[i]), " - has not been found. Please check the file exists.")	
			}
		}
	}	

*checkout is invoked 3 times, one for each type of files(train,test,generic)*

	checkout(dataDir,trainDir,trainFiles)
	checkout(dataDir,testDir,testFiles)
	checkout(dataDir,"",genFiles)

If any file/folder is missing then the execution of the script is interrupted with an error message. 
stop("File: ", file.path(dataDir,subDatabDir,dataFiles[i]), " - has not been found. Please check the file exists.")	

*Otherwise it proceeds with the script execution, initializing the variables that will contain all the input file contents.*


	activity<-read.table("UCI HAR Dataset/activity_labels.txt",header=FALSE,stringsAsFactors=FALSE)
	features<-read.table("UCI HAR Dataset/features.txt",header=FALSE,stringsAsFactors=FALSE)
	xtest<-read.table("UCI HAR Dataset/test/X_test.txt",header=FALSE,stringsAsFactors=FALSE)
	ytest<-read.table("UCI HAR Dataset/test/y_test.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("activity"))
	subjecttest<-read.table("UCI HAR Dataset/test/subject_test.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("subjectid"))
	xtrain<-read.table("UCI HAR Dataset/train/X_train.txt",header=FALSE,stringsAsFactors=FALSE)
	ytrain<-read.table("UCI HAR Dataset/train/y_train.txt",header=FALSE,col.names=c("activity"))
	subjecttrain<-read.table("UCI HAR Dataset/train/subject_train.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("subjectid"))
	train and test data are merged respectively using cbind function
	train<-cbind(ytrain,subjecttrain,xtrain)
	test<-cbind(ytest,subjecttest,xtest)

* **1	Merges the training and the test sets to create one data set.**
*Train and test data are merged together using rbind function*


	data<-rbind(train,test)
	
* **2	Extracts only the measurements on the mean and standard deviation for each measurement. **

*The “features” dataframe contains all the activity names. It is used to search all the activity columns containing word “mean” and/or “std” in their name.
The first 2 columns of the “data” df containing activity type and subjectid are left unchanged.*
 
 
	measure<-data[,c(c(1:2),grep(".*mean|std.*",features$V2)+2)]

* **3	Uses descriptive activity names to name the activities in the data set.**

*measure$activity column is converted from integer type to factor, and its level is changed according to activity df value.*


	measure$activity<-as.factor(measure$activity)
	levels(measure$activity)<-activity$V2)

* **4	Appropriately labels the data set with descriptive activity names.**

*The column name containing “mean” and “std “are lightly modified removing meaningless charcter like “()”,”-“,”.” etc..Again the first columns “activity” and “subjectid” are left unchanged.*


	newnames<-grep(".*mean|std.*",features$V2,value=TRUE)
	newnames <- gsub("[-(),]", ".", newnames)
	newnames <- gsub("[^0-9A-Za-z]+$", "", newnames) 
	newnames <- gsub("[^0-9A-Za-z]+", ".", newnames)
	names(measure)<-c("activity","subjectid", newnames)

* **5	Creates a second, independent tidy data set with the average of each variable for each activity and each subject.**

*The function ddply calculates all the column means of the “measure” dataframe grouped by “activity” and “subjectid” columns. To properly associate the colmean to the column name a new column called “measurefeature” is added to the “measure” dataframe. This column contains the column name replicated  6(activity) * 30(subjectid) = 180 times.*


	final<-ddply(measure, c(.(activity),.(subjectid)),summarize,Means=colMeans(measure[3:(length(names(measure)))]))
	activitynames<-rep( names(measure[,3:(length(names(measure)))]),
	nrow(activity)*length(c(unique(subjecttrain$subjectid),unique(subjecttest$subjectid))))
	final$measuredfeature<-activitynames

*Replicate function has been left as much generic as possible:*


	activitynames<-rep( names(measure[,3:(length(names(measure)))]),nrow(activity)*
	length(c(unique(subjecttrain$subjectid),unique(subjecttest$subjectid))))

**5.1  The final dataframe is saved into a text file**


	write.table(final, "final.txt",row.names=FALSE)


