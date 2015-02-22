##Purpose: Reads Samsung Galaxy S Smartphone and organizes into a tidy #format
#Why: As part of coursera data science course project work
#Level: Advanced

require(reshape2)
##prerequisites
#Take note of the working directories
#get current working directory
gwd<-getwd()
if(!file.exists(paste(gwd,"zipped",sep="/"))){dir.create(paste(gwd,"zipped",sep="/"))}
##Download a zipped folder into sub-directory in the working directories declared.
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(fileurl, destfile =paste(gwd,"zipped","Dataset.zip",sep = "/") ,method = "curl")

##Unzip the downloaded folder into th working dorectory
setwd(paste(gwd,"zipped",sep = "/"))
unzip("Dataset.zip")
lst <- list.files()
f<-which(!lst == "Dataset.zip")

#Designate subfolders from where to read the data
train.f<-paste(gwd,"zipped",lst[f],"train",sep="/")
test.f<-paste(gwd,"zipped",lst[f],"test",sep="/")

##Read training data
setwd(train.f)
subject_train <- read.table("subject_train.txt")
X_train <- read.table("X_train.txt")
y_train <- read.table("y_train.txt")

##Read testing data
setwd(test.f)
subject_test <- read.table("subject_test.txt")
X_test <- read.table("X_test.txt")
y_test <- read.table("y_test.txt")

## Now add column names for subject files (both train and test)
names(subject_train) <- "subjectID"
names(subject_test) <- "subjectID"

#Read feature file then add column names for measurement files
featureNames <- read.table(paste(gwd,"zipped",lst[f],"features.txt",sep="/"))
names(X_train) <- featureNames$V2
names(X_test) <- featureNames$V2
# add column name for label files
names(y_train) <- "activity"
names(y_test) <- "activity"

# combine files into one dataset
train <- cbind(subject_train, y_train, X_train)
test <- cbind(subject_test, y_test, X_test)
combined <- rbind(train, test)

## Required 2: Extracts only the measurements on the mean and standard
## deviation for each measurement.
# determine which columns contain "mean()" or "std()"
meanstdcols <- grepl("mean\\(\\)", names(combined)) |grepl("std\\(\\)", names(combined))
# ensure that we also keep the subjectID and activity columns
meanstdcols[1:2] <- TRUE
# remove unnecessary columns
combined <- combined[, meanstdcols]

## Required 3: Uses descriptive activity names to name the activities
## in the data set.Appropriately labels the data set with descriptive
## activity names. 

# Convert the activity column from integer to factor
combined$activity <- factor(combined$activity, labels=c("Walking",
"Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying"))
## STEP 5: Creates a second, independent tidy data set with the
## average of each variable for each activity and each subject.
# create the tidy data set
melted <- melt(combined, id=c("subjectID","activity"))
tidy <- dcast(melted, subjectID+activity ~ variable, mean)
# write the tidy data set to a file
setwd(gwd)
write.csv(tidy, "tidy.csv", row.names=FALSE)







