##
## Download the data and read it into R
##
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,"getdata_projectfiles_UCI_HAR_Dataset.zip")
unzip("getdata_projectfiles_UCI_HAR_Dataset.zip")
setwd("UCI HAR Dataset/")

# 4. appropriately label the dataset with descriptive variable names
features <- read.table("features.txt",stringsAsFactors=FALSE)
features <- features[,2]
pattern <- "mean[(][)]|std[(][)]"
features_cols <- grepl(pattern,features)
features_names <- grep(pattern,features,value=TRUE)
features_names <- gsub("[()]","",features_names)

X_train <- read.table("train/X_train.txt",col.names=features,check.names=FALSE)
X_test  <- read.table("test/X_test.txt",  col.names=features,check.names=FALSE)
# 2. extract only the measurements of the mean and standard deviation for each measurement
X_train <- X_train[,features_cols]
X_test  <- X_test[,features_cols]
names(X_train) <- features_names
names(X_test)  <- features_names

y_train <- read.table("train/y_train.txt",col.names="activity_code",colClasses="character")
y_test  <- read.table("test/y_test.txt",  col.names="activity_code",colClasses="character")

subject_train <- read.table("train/subject_train.txt",col.names="subject")
subject_test  <- read.table("test/subject_test.txt",col.names="subject")

# 1. merge the training and test sets to create one dataset
train <- cbind(subject_train,X_train,y_train)
test  <- cbind(subject_test, X_test, y_test)

har <- rbind(train,test)

activities <- read.table("activity_labels.txt",col.names=c("activity_code","activity_label"))

