# Human Activity Recognition using Smartphones
## Getting and Cleaning Data: Course Project
This project builds on top of another project which I call the *base project*, that dealt with measurement data from accelerometers and gyroscopes of smartphones attached to test persons performing six different activities. The documentation of the base project is included in the downloaded files and remains valid in describing the data of the base project. In turn, this Coursera Course Project builds on top of the base project in that it uses the data and manipulate and transforms it.

### This repo consists of the following files:
File           | Contents
---------------|-----------------
README.md      | This file. Explains the analysis files and how the script works.
CodeBook.md    | Codebook that modifies and updates the available codebooks, and describes the variables, the data, and any transformations or work that was performed to clean up the data
run_analysis.R | Script that does all the required steps to generate the file containing the required tidy dataset

### Steps to execute to generate the required resulting data set
Run the script `run_analysis.R`.

### How the script `run_analysis.R` works
First, the scirpt loads the `dplyr` library, since the script needs the functions `select`, `filter`, `group_by` and `summarise` which are part of the `dplyr`library.

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

Then the script reads the files and assigns the contents to objects with names corresponding to the file names. For reading the activity codes (`y_train`, `y_test`) it assigns the column heading `activity_code` to prepare for merging on a column with a common heading later. The subject data (`subject_train`, `subject_test`) are given the heading `subject`.

#### Step 1: Merge the training and the test sets to create one data set
The first step is to undo the train/test-splitting by concatenating the data of the same type (subjects, activity codes, feature variables) thereby getting rid of the `_train` and `_test` suffixes. This is achived by calling the function `rbind()`. Attention is to be paid to the sequence of the training and test data (first `train`, second `test`) since the order of the data records is an implicit key as to which rows belong to the same observational unit.

The second step is to `cbind()` (column binding) the `X`, `y` and `subject` to form the complete data set. I call the resulting data frame `har` for *Human Activity Recognition*.

#### Step 2: Extract only the measurements on the mean and standard deviation for each measurement
My interpretation of this requirement is to select from the complete feature list (`features.txt`) only those features whose name contains the strings `mean()` and `std()`.

First the complete list of features is read from file and loaded to the object `features`. Next, a `pattern` is defined to serve as an argument to  `grepl()`, which selects the desired features in the subsequent call to `filter()`. The pattern is a regular expression with an alternative of the two strings `mean` and `std` followed by opening and closing parenthesis `(` and `)` respectively. Since these are also metacharacters, they need to be escaped. What follows is a call to `filter()` whose criterion is a call to `grepl()` that looks for matches of the pattern with the `name` column of `features`. The result of the filtering is stored in the object `features_selected`. The `id` column of this object is then used in the subsequent `select()` statement to select the desired feature columns. The resulting data set is stored in the object `har2`.

#### Step 3: Use descriptive activity names to name the activities in the data set
The activities are represented by a numeric code in the data set. The mapping between codes and descriptive labels is contained the file `activity_labels.txt`. The script reads this file and assigns its contents to the object `activities`. The substitution of `activity_codes` by `activity_labels` is achieved by calling `merge()` of `har2` with  `activities` on the common column `activity_code`. After that, the column `activity_code` removed by the call to `select()`. The resulting data frame is stored in the object `har3`.

#### Step 4: Appropriately label the data set with descriptive variable names
I consider the variable names in the `features_selected` object already as sufficiently descriptive, given there is a section of the documentation which provides a mapping between the abbreviations and the full terms. This documentation is provided in the Codebook of this project.

Basis of the labeling is the object `features_selected`. From its `name` column, parenthesis `()` and hyphens `-` are removed to avoid problems with using these names as column headers of a data frame. Furthermore, the first letter of the strings `mean` and `std` are capitalized to improve readablity.

The actual labeling is achieved by a call to `names()` and assigning it the character vector of `features_names` amended by the `subject` and `activity_label` columns.

This completes steps 1 to 4 of the assignment. I consider the data set **tidy** since every variable constitutes a column, every observation is a row.

#### Step 5: From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
This requirement translates to grouping the data set `har3` by `activity` and `subject`, and call the `mean` function on each column. This is achived by calling the funcions `group_by()` and `summarise_all()`, and storing the resulting data frame in the object `har_mean_by_act_subj`. The resulting data frame has 180 rows since each of the 30 subjects performed each of the 6 activities.

The resulting data frame is then written to a file called `result_of_step5.txt` which contains the appropriate column names but no row names.