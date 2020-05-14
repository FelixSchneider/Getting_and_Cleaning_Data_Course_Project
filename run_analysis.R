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
har <- cbind(X,y,subject)

# 2. extract only the measurements of the mean and standard deviation for each measurement
features <- read.table("features.txt",col.names=c("id","name"),stringsAsFactors=FALSE)
pattern <- "mean\\(\\)|std\\(\\)"
features_selected <- filter(features,grepl(pattern,name))
har2 <- select(har,features_selected$id,activity_code,subject)

# 3. use descriptive activity names to name the activities in the data set
activities <- read.table("activity_labels.txt",col.names=c("activity_code","activity_label"))
har3 <- merge(har2,activities,sort=FALSE)
har3 <- select(har3,-activity_code)

# 4. appropriately label the data set with descriptive variable names
features_names <- gsub("[()\\-]","",features_selected$name)
features_names <- gsub("mean","Mean",features_names)
features_names <- gsub("std","Std",features_names)
names(har3) <- c(features_names,"subject","activity_label")

# 5. create second, independent tidy data set with the average of each variable
#    for each activity and each subject
har3 %>%
  group_by(activity_label,subject) %>%
  summarise_all(mean) ->
  har_mean_by_act_subj

write.table(har_mean_by_act_subj,"../result_of_step5.txt",row.names=FALSE,col.names=TRUE)
