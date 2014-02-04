# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# This is a sub package interfacing with our SVM module.
#
# Created by David Tran
# Version 0.4.2.r1
# Last Modified 02-04-2014

#install.packages('e1071',dependencies=TRUE)
library(e1071)

svmConstructor = function ( inputFrame, keyColumn, ... ){

  # Simplifies the construction call for svm by cutting the data frame in the right place

  if (class(inputFrame) != "data.frame"){
    stop("svmConstructor: dataSet must be a data.frame")
  }

  return (
    svm(removeColumn(inputFrame, keyColumn), inputFrame[[keyColumn]], ... )
  )
}

svmCountSplit = function ( key, dataSet, percentage=0.2, guessColumn='label' ){

  # This creates the logical vector that tells the calling function
  # how to split the datasets. key is what we are looking for in the
  # guessColumn.

  count = nrow(dataSet[dataSet[[guessColumn]]==key,])
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

svmFormatData = function( dataSet, percentage=0.2, guessColumn ='label' ){

  # Takes the dataSet and the guessColumn and splits it into the training set
  # and the test set. The test set is min 1 unless only one element is
  # passed. The 'guessColumn' is what we focus on.

  keyVector = unique(unlist(dataSet[[guessColumn]], use.names = FALSE))

  boolVector = unlist(
    sapply(keyVector, svmCountSplit,
      dataSet=dataSet, percentage=percentage, guessColumn=guessColumn)
    )

  trainSet = dataSet[boolVector,]
  testSet = dataSet[!boolVector,]

  return (list(testSet, trainSet))
}

svmMain = function( dataSet, guessColumn='label' ){

  # Given the dataSet and the column of interest, splits the data
  # into the right pieces and runs the svmModel

  if (is.null(dataSet)){
    stop("svmMain: Getting null data on svmMain")
  }

  if (class(dataSet) == "matrix"){
    stop("svmMain: dataSet must be a data.frame")
  }

  output = svmFormatData(dataSet, guessColumn=guessColumn)

  testSet = output[[1]]
  trainSet = output[[2]]

  svmModel = svmConstructor(dataSet, guessColumn,
    data=trainSet, degree=3, gamma=0.1, cost=100)
  prediction = predict(svmModel, removeColumn(testSet, guessColumn))

  print(summary(svmModel))
  print(table(pred=prediction, true=testSet[,guessColumn]))

  printf("Numbers of training data %d", nrow(trainSet))
  printf("Numbers of test data %d", nrow(testSet))

  return (dataSet)
}

svmStats = function( confusionMatrix ){

  # Summarized the confusion Matrix with these parameters
  # Precision, tp/(tp+fp)
  #   (True/ROW)
  # Recall, tp/(tp+fn)
  #   (True/COL)

  return (confusionMatrix)
}

svmTune = function ( trainSet, testColumn='label' ){

  # Tunes an SVM and prints results and guess for best parameters

  tuned <- tune.svm(removeColumn(trainSet,testColumn), dataSet[[testColumn]],
    data=trainSet, gamma = 10^(-6:-1), cost = 10^(-1:2))

  print(summary(tuned))

  return (trainSet)
}
