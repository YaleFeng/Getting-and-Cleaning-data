library(reshape2)

# Get dataset
rawDataDir = "./RawData"
rawDataUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataFilename = "rawData.zip"
rawDataDFn = paste(rawDataDir, "/", rawDataFilename, sep = "")
dataDir = "./Data"
path_rf <- file.path(dataDir , "UCI HAR Dataset")

if (!file.exists(rawDataDir)) {
  dir.create(rawDataDir)
  download.file(url = rawDataUrl, destfile = rawDataDFn)
}
if (!file.exists(dataDir)) {
  dir.create(dataDir)
  unzip(zipfile = rawDataDFn, exdir = dataDir)
}

# train data
x_train = read.table(file.path(path_rf, "train" , "X_train.txt" ),header = FALSE)
y_train = read.table(file.path(path_rf, "train" , "Y_train.txt" ),header = FALSE)
s_train = read.table(file.path(path_rf, "train" , "subject_train.txt" ),header = FALSE)

# test data
x_test = read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
y_test = read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
s_test = read.table(file.path(path_rf, "test" , "subject_test.txt" ),header = FALSE)

# merge train, test together
x_data = rbind(x_train, x_test)
y_data = rbind(y_train, y_test)
s_data = rbind(s_train, s_test)


# load information
feature = read.table(file.path(path_rf, "features.txt" ),header = FALSE)

a_label = read.table(file.path(path_rf, "activity_labels.txt" ),header = FALSE)
a_label[,2] = as.character(a_label[,2])

cols = grep("-(mean|std).*", as.character(feature[,2]))
colNames = feature[cols, 2]
colNames = gsub("-mean", "Mean", colNames)
colNames = gsub("-std", "Std", colNames)
colNames = gsub("[-()]", "", colNames)

# Merge
x_data = x_data[selectedCols]
all_data = cbind(s_data, y_data, x_data)
colnames(all_data) = c("Subject", "Activity", colNames)

all_data$Activity = factor(all_data$Activity, levels = a_label[,1], labels = a_label[,2])
all_data$Subject = as.factor(all_data$Subject)

# Write tidy data
melted_data = melt(all_data, id = c("Subject", "Activity"))
tidy_data = dcast(melted_data, Subject + Activity ~ variable, mean)

write.table(tidy_data, "./tidy_dataset.txt", row.names = FALSE)

