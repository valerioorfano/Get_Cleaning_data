library(plyr)
dataDir <- "UCI HAR Dataset"
trainDir <-"train"
testDir <- "test"
trainFiles <- c("X_train.txt", "subject_train.txt", "y_train.txt")
testFiles<- c("X_test.txt", "subject_test.txt", "y_test.txt")
genFiles<-c("activity_labels.txt", "features.txt")
checkout(dataDir,trainDir,trainFiles)
checkout(dataDir,testDir,testFiles)
checkout(dataDir,"",genFiles)
activity<-read.table("UCI HAR Dataset/activity_labels.txt",header=FALSE,stringsAsFactors=FALSE)
features<-read.table("UCI HAR Dataset/features.txt",header=FALSE,stringsAsFactors=FALSE)
xtest<-read.table("UCI HAR Dataset/test/X_test.txt",header=FALSE,stringsAsFactors=FALSE)
ytest<-read.table("UCI HAR Dataset/test/y_test.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("activity"))
subjecttest<-read.table("UCI HAR Dataset/test/subject_test.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("subjectid"))
xtrain<-read.table("UCI HAR Dataset/train/X_train.txt",header=FALSE,stringsAsFactors=FALSE)
ytrain<-read.table("UCI HAR Dataset/train/y_train.txt",header=FALSE,col.names=c("activity"))
subjecttrain<-read.table("UCI HAR Dataset/train/subject_train.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("subjectid"))
train<-cbind(ytrain,subjecttrain,xtrain)
test<-cbind(ytest,subjecttest,xtest)
data<-rbind(train,test)
measure<-data[,c(c(1:2),grep(".*mean|std.*",features$V2)+2)]
measure$activity<-as.factor(measure$activity)
levels(measure$activity)<-activity$V2)
newnames<-grep(".*mean|std.*",features$V2,value=TRUE)
newnames <- gsub("[-(),]", ".", newnames)
newnames <- gsub("[^0-9A-Za-z]+$", "", newnames) 
newnames <- gsub("[^0-9A-Za-z]+", ".", newnames)
names(measure)<-c("activity","subjectid", newnames)
final<-ddply(measure, c(.(activity),.(subjectid)),summarize,Means=colMeans(measure[3:(length(names(measure)))]))
activitynames<-rep( names(measure[,3:(length(names(measure)))]),nrow(activity)*length(c(unique(subjecttrain$subjectid),unique(subjecttest$subjectid))))
final$measuredfeature<-activitynames
write.table(final, "tidy_data.txt",row.names=FALSE)



checkout<-function(dataDir,subDataDir,dataFiles)
{
	for (i in 1: length(dataFiles)){
		if (!(file.exists(file.path(dataDir,subDataDir,dataFiles[i])))) {
			print(file.exists(file.path(dataDir,subDataDir,dataFiles[i])))
			stop("File: ", file.path(dataDir,subDatabDir,dataFiles[i]), " - has not been found. Please check the file exists.")	
		}
	}
}


