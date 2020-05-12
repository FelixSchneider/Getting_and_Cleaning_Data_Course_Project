library(dplyr)

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,"getdata_projectfiles_UCI_HAR_Dataset.zip")
unzip("getdata_projectfiles_UCI_HAR_Dataset.zip")
setwd("UCI HAR Dataset/")

X_train <- read.table("train/X_train.txt")
X_test  <- read.table("test/X_test.txt")
y_train <- read.table("train/y_train.txt",col.names="activity_code")
y_test  <- read.table("test/y_test.txt",  col.names="activity_code")
subject_train <- read.table("train/subject_train.txt",col.names="subject")
subject_test  <- read.table("test/subject_test.txt",  col.names="subject")

# 1. merge the training and test sets to create one data set
X <- rbind(X_train,X_test)
y <- rbind(y_train,y_test)
subject <- rbind(subject_train,subject_test)

features <- read.table("features.txt",stringsAsFactors=FALSE)
features <- features[,2]
pattern <- "mean[(][)]|std[(][)]"
features_cols <- grepl(pattern,features)
features_names <- grep(pattern,features,value=TRUE)
features_names <- gsub("[()-]","",features_names)
features_names <- gsub("mean","Mean",features_names)
features_names <- gsub("std","Std",features_names)

# 2. extract only the measurements of the mean and standard deviation for each measurement
X <- X[,features_cols]

# 3. use descriptive activity names to name the activities in the data set
activities <- read.table("activity_labels.txt",col.names=c("activity_code","activity_label"))
y <- merge(y,activities,sort=FALSE)

# 4. appropriately label the data set with descriptive variable names
names(X) <- features_names

# finally create one dataset
har <- cbind(subject,y,X)
har <- select(har,-activity_code)

# 5. create second, independent tidy data set with the average of each variable
#    for each activity and each subject
har %>%
  group_by(activity_label,subject) %>%
  summarise_all(mean) ->
  har_mean_by_act_subj

write.table(har_mean_by_act_subj,"result_of_step5.txt",row.names=FALSE,col.names=TRUE)