# PowerAnalyze SVM Module
# This r file takes in a data frame and analyzes it using SVM
#
# This is a sub package interfacing with our SVM module.
#
# Created by David Tran
# Version 0.5.4.0
# Last Modified 02-15-2014

#install.packages('e1071',dependencies=TRUE)
lib('e1071')

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

svmFormatData = function( dataSet, percentage=0.2, guessColumn='label' ){

  # Takes the dataSet and the guessColumn and splits it into the training set
  # and the test set. The test set is min 1 unless only one element is
  # passed. The 'guessColumn' is what we focus on.

  keyVector = unique(unlist(dataSet[[guessColumn]], use.names = FALSE))
  keyVector = keyVector[order(keyVector)]

  boolVector = unlist(
    sapply(keyVector, svmCountSplit,
      dataSet=dataSet, percentage=percentage, guessColumn=guessColumn)
    )

  # Prints out the table combined with the boolVector
  if (DEBUG){
    testData = cbind(dataSet,boolVector)
    print(testData[order(testData[guessColumn]),])
  }

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

  debugprintf("Starting svmMain")

  # Sort data.frame by guessColumn
  #dataSet = dataSet[order(dataSet[guessColumn]),]
  dataSet = sort.data.frame(dataSet, col=guessColumn)

  output = svmFormatData(dataSet, guessColumn=guessColumn)

  testSet = output[[1]]
  trainSet = output[[2]]

  # This is where one can train and test the SVM

  svmModel = svmConstructor(dataSet, guessColumn,
    data=trainSet, degree=3, gamma=0.1, cost=100)
  prediction = predict(svmModel, removeColumn(testSet, guessColumn))

  confusionMatrix = table(pred=prediction, true=testSet[,guessColumn])
  print(summary(svmModel))
  print(confusionMatrix)
  svmStats(confusionMatrix)

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

  error = FALSE

  if (nrow(confusionMatrix) != ncol(confusionMatrix)){
    printf("svmStats: Confusion matrix not square. Dim(%d,%d)",
      nrow(confusionMatrix), ncol(confusionMatrix)
    )
  }
  else if (nrow(confusionMatrix) == 0){
    printf("svmStats: Data Frame size must be 1 or larger")
  }

  if (error){
    printf("svmStats: Ignoring arg and passing to next function")
    return (confusionMatrix)
  }

  lapply(rownames(confusionMatrix), svmStatsCalc, confusionMatrix)

  return (confusionMatrix)
}

svmStatsCalc = function ( key, confusionMatrix ){

  # Summzarizes one diagonal entry on the confusionMatrix
  # selected by key

  curEntry = confusionMatrix[key,key]

  rowSum = sum(confusionMatrix[key,])
  colSum = sum(confusionMatrix[,key])

  printf("Analyzing %s Precision : %-6.4f   Recall : %-6.4f",
    key,
    curEntry/rowSum,
    curEntry/colSum
  )

  return (confusionMatrix)
}

svmTune = function ( trainSet, testColumn='label' ){

  # Tunes an SVM and prints results and guess for best parameters

  tuned <- tune.svm(removeColumn(trainSet,testColumn), dataSet[[testColumn]],
    data=trainSet, gamma = 10^(-6:-1), cost = 10^(-1:2))

  print(summary(tuned))

  return (trainSet)
}
