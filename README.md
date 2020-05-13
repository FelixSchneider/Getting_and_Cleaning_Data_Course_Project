# Human Activity Recognition using Smartphones
## Getting and Cleaning Data: Course Project
This README file explains the analysis files and how the script works.

### This repo consists of the following files:
File           | Contents
---------------|-----------------
README.md      | this file
CodeBook.md    |codebook that modifies and updates the available codebooks, and describes the variables, the data, and any transformations or work that was performed to clean up the data
run_analysis.R | script that does all the required steps to generate the file containing the required tidy dataset

### Steps to execute to generate the required resulting data set
Run the script `run_analysis.R`.

### How the script `run_analysis.R` works
First, the scirpt loads the `dplyr` library, since the script needs the functions `select`, `group_by` and `summarise` which are part of the `dplyr`library.

Then the script downloads the zip-file with the data for the analysis and unzips it in the current working directory from which the script was called. This creates a subdirectory `UCI HAR Dataset` containing the following files:

- 'README.txt'
- 'features_info.txt': Shows information about the variables used on the feature vector.
- 'features.txt': List of all features.
- 'activity_labels.txt': Links the class labels with their activity name.
- 'train/X_train.txt': Training set.
- 'train/y_train.txt': Training labels.
- 'train/subject_train.txt': identifier of the subject who performed the activity in the Training set
- 'test/X_test.txt': Test set.
- 'test/y_test.txt': Test labels.
- 'test/subject_test.txt': identifier of the subject who performed the activity in the Test set

Then the script changes its working directory to `UCI HAR Dataset`. In my opinion this is in alignment with the assignment requirement *"The code should have a file run_analysis.R in the main directory that can be run as long as the Samsung data is in your working directory."*

Then the script reads the files and assigns the contents to objects with names corresponding to the file names. For reading the activity labels (`y_train`, `y_test`) it assigns the column heading `activity_code` to prepare for merging on a column with a common heading later. The subject data (`subject_train`, `subject_test`) are given the heading `subject`.

#### Step 1: Merge the training and the test sets to create one data set
The first step is to undo the train/test-splitting by concatenating the data of the same type (subjects, activity codes, feature variables) thereby getting rid of the `_train` and `_test` suffixes. This is achived by calling the function `rbind`. Attention is to be paid to the sequence of the training and test data (first `train`, second `test`) since the order of the data records is an implicit key as to which rows belong to the same observational unit.

The second step, column binding the `subject`, `y` and `X` to form the complete data set, is deferred to after the required features are selected from `X`.

#### Step 2: Extract only the measurements on the mean and standard deviation for each measurement
My interpretation of this requirement is to select from the complete feature list (`features.txt`) only those features whose name contains the strings `mean()` and `std()`.

First the complete list of features are read and loaded to the object `features`. Then only the second column of the resulting data frame is retained getting rid of the unnecessary order number. Next, a pattern is defined to serve as a common argument to the calls to `grepl` and `grep` that follow. The pattern is a regular expression with an alternative of the two strings `mean` and `std` followed by opening and closing parenthesis `(` and `)` respectively. Since these are also metacharacters, I put them in square brackets `[` and `]`.

Next, the logical vector `features_cols` is created using `grepl` to mark the desired features. Then, the corresponding character vector `features_names` is created with the corresponding features names. From the resulting features names, any parenthesis and dashes are removed to avoid problems with using the names as columns headers. Finally, the first letters of `mean` and `std` are capitalized to make the resulting variable names more readable.

After these preparations, the observables data set `X` is subset with `features_cols`, which completes this step of the assignment.

#### Step 4: Appropriately label the data set with descriptive variable names
This step is performed before step 3 since it is very natural at this point and all preparations for it are complete. It is achived by assigning the character vector `features_names` to the names attribute of the observables data set `X`.

Now, everything is prepared to complete Step 1 by column binding `subject`, `y` and `X`. I call the resulting data frame `har` for *Human Activity Recognition*.

#### Step 3: Use descriptive activity names to name the activities in the data set
The activities are represented by a numeric code in the data set. The mapping between codes and descriptive labels is contained the file `activity_labels.txt`. The script reads this file and assigns its contents to the object `activities`. The substitution of activity_codes by activity_labels is achieved by calling `merge` of `activities` and `har`on the common column `activity_code`. After that, the column `activity_code` removed by the call to `select`.

This completes steps 1 to 4 of the assignment. I consider the data set **tidy** since every variable constitutes a column, every observation is a row.

#### Step 5: From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
This requirement translates to grouping the data set `har` by `activity` and `subject`, and call the `mean` function on each column. This is achived by calling the funcions `group_by()` and `summarise_all()`, and storing the resulting data frame in the object `har_mean_by_act_subj`. The resulting data frame has 180 rows since each of the 30 subjects performed each of the 6 activities.

The resulting data frame is then written to a file called `result_of_step5.txt` which contains the appropriate column names but no row names.