# PowerAnalyze SVM Module
# This r file takes in a data frame and analyzes it using SVM
#
# This is a sub package interfacing with our SVM module.
#
# Created by David Tran
# Version 0.7.2.0
# Last Modified 02-19-2014

lib('e1071')
lib('gplots')

#' A wrapper around the svm constructor for the purposes for this repo.
#'
#' @param inputFrame the input data frame we will use
#' @param keyColumn the column we will focus on in the formula
#' @return the constructed svm with the formula correctly
svmConstructor = function ( inputFrame, keyColumn, ... ){

  # Simplifies the construction call for svm by cutting the data frame in the right place

  if (class(inputFrame) != "data.frame"){
    stop("svmConstructor: dataSet must be a data.frame")
  }

  return (
    svm(removeColumn(inputFrame, keyColumn), inputFrame[[keyColumn]], ... )
  )
}

#' Creates a logical vector that splits a dataset into training and test.
#' The first elements marked FALSE will be used for testing and TRUE is marked for
#' training
#'
#' This function is called on by svmFormatData to split the dataSet.
#'
#' @param key is the unique key in the column that is our data set
#' @param percentage is the amount of elements that will be thrown into testing
#'   min 1, if the data set is larger than 1. Should be a numeric between 0
#'   and 1.
#' @param guessColumn the column name the key will filter on
#' @return a logical vector that can be used to cut the dataset in two
#' @seealso \code{\link{svmFormatData}}
svmCountSplit = function ( key, dataSet, percentage=0.2, guessColumn='label' ){

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

#' Takes the dataSet and the guessColumn and splits it into the training set
#' and the test set. The test set is min 1 unless only one element is
#' passed. The 'guessColumn' is what we focus on.
#;
#' This function relies on svmCountSplit to create a logic vector to split the
#' set
#'
#' @param dataSet the input data.frame that will be split in
#' @param percentage is the amount of elements that will be thrown into testing
#'   min 1, if the data set is larger than 1. Should be a numeric between 0
#'   and 1.
#' @param guessColumn the column name the key will filter on
#' @return a two element list containing the testSet and trainSet data
#'   partitioned correctly.
#' @seealso \code{\link{svmCountSplit}}
svmFormatData = function( dataSet, percentage=0.2, guessColumn='label' ){

  dataSet = sort.data.frame(dataSet, col=guessColumn)

  keyVector = unique(unlist(dataSet[[guessColumn]], use.names = FALSE))
  keyVector = keyVector[order(keyVector)]

  boolVector = unlist(
    sapply(keyVector, svmCountSplit,
      dataSet=dataSet, percentage=percentage, guessColumn=guessColumn)
    )

  if (DEBUG){
    testData = cbind(dataSet,boolVector)
    print(testData[order(testData[guessColumn]),])
  }

  trainSet = dataSet[boolVector,]
  testSet = dataSet[!boolVector,]

  # Creating a list whose names are the element containers
  return (list(testSet=testSet, trainSet=trainSet))
}

#' Controls the other functions and splits the dataSet into two
#' pieces, trains the SVM and runs the test set on it. Once done,
#' it will print out the confusion matrix.
#'
#' This is where we can train the svn.
#' @seealso \code{\link{svmTune}}
#'
#' @param dataSet the input data.frame that the svm will act on
#' @param guessColumn the column name that the svm will train on
#' @return the dataSet passed in
svmMain = function( dataSet, guessColumn='label' ){

  if (is.null(dataSet)){
    stop("svmMain: Getting null data on svmMain")
  }

  if (class(dataSet) == "matrix"){
    stop("svmMain: dataSet must be a data.frame")
  }

  debugprintf("Starting svmMain")

  output = svmFormatData(dataSet, guessColumn=guessColumn)

  testSet = output[['testSet']]
  trainSet = output[['trainSet']]

  # This is where one can train and test the SVM
  #svmTune(trainSet, guessColumn)

  svmModel = svmConstructor(dataSet, guessColumn,
    data=trainSet, degree=3, gamma=1000, cost=1000)

  prediction = predict(svmModel, removeColumn(testSet, guessColumn))

  confusionMatrix = table(pred=prediction, true=testSet[,guessColumn])

  svmPlot(confusionMatrix)

  print(summary(svmModel))
  print(confusionMatrix)
  svmStats(confusionMatrix)

  printf("Numbers of training data %d", nrow(trainSet))
  printf("Numbers of test data %d", nrow(testSet))

  return (dataSet)
}

#' Creates a plot of the confusion matrix.
#' We use the gplot library to print it.
#'
#' @param confusionMatrix the confusion matrix that we will plot
#' @return the confusion matrix passed in
svmPlot = function ( confusionMatrix ){

  heatmap.2(confusionMatrix,
    margins=c(5,10), Colv=NULL, Rowv=NULL, srtCol=0,
    xlab='True', ylab='Prediction',
    main='Heat map of confusion matrix',

    dendrogram="none", trace="none",

    col=colorRampPalette(c('white','black')),
    keysize=1.2,

    labRow=lapply(rownames(confusionMatrix), function(x){
      return (paste(x, ' - pred count', (sum(confusionMatrix[x,]))))
    }),
  )

  return (confusionMatrix)

}

#' Takes the confusion matrix and prints the precision and recall of each
#' entry and the average of all values.
#'
#' This function relies on svmStatsCalc to print the values.
#'
#' Given the way the table is printer, pred is on the y-axis and true is on
#' the x-axis, these facts are true.
#'
#'  Precision, tp/(tp+fp) which is
#'    (True/ROW)
#'  Recall, tp/(tp+fn) which is
#'    (True/COL)
#'
#' @param confusionMatrix the confusion matrix that we will print the values
#'   on
#' @return the confusion matrix
#' @seealso \code{\link{svmStatsCalc}}
svmStats = function( confusionMatrix ){

  if (nrow(confusionMatrix) != ncol(confusionMatrix)){
    printf("svmStats: Confusion matrix not square. Dim(%d,%d)",
      nrow(confusionMatrix), ncol(confusionMatrix)
    )
  }
  else if (nrow(confusionMatrix) == 0){
    printf("svmStats: Data Frame size must be 1 or larger")
  }

  results = t(sapply(rownames(confusionMatrix), svmStatsCalc, confusionMatrix))
  results = data.frame(results)

  meanSelect = function (colA, table=results) return (mean(unlist(table[[colA]])))
  weightedMeanSelect = function (colMain, colWeight, table=results) {
    return (dotProduct(unlist(table[[colMain]]),
                       unlist(table[[colWeight]]))/
      sum(unlist(table[[colWeight]]))
    )
  }

  printf( "Unweighted average precision : %-0.8f Unweighted average recall %-0.8f",
    meanSelect('precision'), meanSelect('recall')
  )

  printf( "  Weighted average precision : %-0.8f   Weighted average recall %-0.8f",
    weightedMeanSelect('precision', 'precisionDen'),
    weightedMeanSelect('recall', 'recallDen')
  )

  return (confusionMatrix)
}

#' Takes the key and confusion matrix and prints the value on one
#' specific entry on the diagonal and its associated row and column
#'
#' @param key, the diagonal entry this will work on
#' @param confusionMatrix the confusion matrix that we will print the values
#'   on
#' @return a list containing the row, precision and their normalized values
#' @seealso \code{\link{svmStats}}
svmStatsCalc = function ( key, confusionMatrix ){

  curEntry = confusionMatrix[key,key]

  rowSum = sum(confusionMatrix[key,])
  colSum = sum(confusionMatrix[,key])

  precision = curEntry/rowSum
  recall = curEntry/colSum
  precisionDen = rowSum
  recallDen = colSum

  printf("Analyzing %s Precision : %d/%d = %-6.4f | Recall : %d/%d = %-6.4f",
    key,
    curEntry, rowSum,
    precision,
    curEntry, colSum,
    recall
  )

  return (list(
    precision = precision,       recall = recall,
    precisionDen = precisionDen, recallDen = recallDen
  ))
}

#' Tunes an svm machine to get optimal results and prints the value.
#'
#' @param trainSet the data.frame that the svm will train on
#' @param testColumn the column that the svm will train on
#' @param gamma a numeric vector that will be the gamma range we will train on
#' @param cost a numeric vector that will be the cost range we will train on
#' @param ... any other paramters for the tune function
#' @return the training set
svmTune = function ( trainSet, testColumn='label',
    gamma=10^(-6:5), cost=10^(-2:5), ... ){

  tuned = tune.svm(removeColumn(trainSet,testColumn), trainSet[[testColumn]],
    data=trainSet, gamma = gamma, cost = cost, ...)

  print(summary(tuned))

  return (trainSet)
}
