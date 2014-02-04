# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# This is a sub package interfacing with our SVM module.
#
# Created by David Tran
# Version 0.4.1.0
# Last Modified 02-04-2014

#install.packages('e1071',dependencies=TRUE)
library(e1071)

svmCountSplit = function ( key, dataset, percentage=0.2, uniqueColumn='label' ){

  # This creates the logical vector that tells the calling function
  # how to split the datasets. key is what we are looking for in the
  # uniqueColumn.

  count = nrow(dataset[dataset[[uniqueColumn]]==key,])
  splitValue = floor(percentage*count)

  if (count == 0){
    stop("svmCountSplit getting 0 elements to split from. Exiting")
  }

  if (splitValue== 0 && count > 1){
    splitValue = 1
  }

  boolRetVector = as.logical(1:count)
  boolRetVector[1:splitValue] = FALSE

  return (boolRetVector)
}

svmFormatData = function( dataset, percentage=0.2, uniqueColumn ='label' ){

  # Takes the dataset and the uniqueColumn and splits it into the training set
  # and the test set. The test set is min 1 unless only one element is
  # passed. The 'uniqueColumn' is what we focus on.

  keyVector = unique(unlist(dataset[[uniqueColumn]], use.names = FALSE))

  boolVector = unlist(
    sapply(keyVector, svmCountSplit,
      dataset=dataset, percentage=percentage, uniqueColumn=uniqueColumn)
    )

  trainList = dataset[boolVector,]
  testList = dataset[!boolVector,]

  return (list(testList, trainList))

}

svmMain = function( dataset, guessColumn='label' ){

  # Given the dataset and the column of interest, splits the data
  # into the right pieces and runs the model

  if (is.null(dataset)){
    stop("Getting null data on svmMain")
  }

  if (class(dataset) == "matrix"){
    stop("dataset must be a data.frame")
  }

  output = svmFormatData(dataset, uniqueColumn=guessColumn)

  testList = output[[1]]
  trainList = output[[2]]

  model = svm(label~., data=trainList, degree=3, gamma=0.1, cost=100)
  prediction = predict(model, removeColumn(testList, guessColumn))

  print(summary(model))
  print(table(pred=prediction, true=testList[,guessColumn]))

  #tuned <- tune.svm(label~., data=trainList, gamma = 10^(-6:-1), cost = 10^(-1:2))
  #print(summary(tuned))

  printf("Numbers of training data %d", nrow(trainList))
  printf("Numbers of test data %d", nrow(testList))

  return (dataset)
}

