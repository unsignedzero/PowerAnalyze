# PowerAnalyze SVM module
# Takes in a given data frame and runs it through an SVM.
#
# Created by David Tran (unsignedzero)
# Version 0.9.0.0
# Last Modified 03-07-2014

lib("e1071")
lib("gplots")

#' A wrapper around the SVM constructor to make it easier to pass in right
#'   columns for grouping and data.
#'
#' This function allows one to control which columns of the input data frame
#' is used for what.
#'
#' @param inputFrame The input data frame that will be used as the model for
#'    the SVM.
#' @param keyColumn The column that will be focused on in the SVM model.
#' @param ... Any other arguments for the SVM constructor.
#' @return The constructed SVM model with the correct formula from the input
#'   data.
svmConstructor <- function ( inputFrame, keyColumn, ... ) {

  if (class(inputFrame) != "data.frame"){
    stop("svmConstructor: dataSet must be a data.frame")
  }

  return(
    svm(removeColumn(inputFrame, keyColumn), inputFrame[[keyColumn]], ... )
  )
}

#' Creates a logical vector can be used to split a data set into the training
#' set and the test set.
#'
#' The first elements are marked false and will be used for testing in this
#' repo. The rest of the elements are marked true and used for training.
#'
#' This function is called on by svmFormatData to split the dataSet.
#'
#' @param key The unique key that identfies one group in the column.
#' @param dataSet The input data frame that will be split.
#' @param percentage (optional, default 0.2) The percentage of elements that
#'   will be thrown into testing min one, if the group size is larger than one.
#'   Should be a numeric value between zero and one. The other 1 - percentage
#'   elements will be used for training. We will take the floor amount of
#'   elements if the percentages results in a non-integer value.
#' @param guessColumn (optional, default "label") The column name containing
#'   the group information.
#' @return A logical vector that can be used to cut the data set in two.
#' @seealso \code{\link{svmFormatData}}
svmCountSplit <- function ( key, dataSet, percentage = 0.2,
    guessColumn = "label" ) {

  count <- nrow(dataSet[dataSet[[guessColumn]] == key, ])
  splitValue <- floor(percentage*count)

  if (count == 0){
    stop("svmCountSplit getting 0 elements to split from. Exiting")
  }

  if (splitValue== 0 && count > 1){
    splitValue <- 1
  }

  boolRetVector <- as.logical(1:count)
  boolRetVector[1:splitValue] <- FALSE

  return(boolRetVector)
}

#' Splits the dataSet into two pieces and returns a list containing said
#' pieces.
#'
#' Takes the dataSet and the guessColumn and splits it into the training set
#' and the test set. The test set is min one, unless only one element is
#' passed. The guessColumn should contain the group information that will
#' be used in the svmCountSplit.
#'
#' This function relies on svmCountSplit to create a logic vector to split the
#' set
#'
#' @param dataSet The input data frame that will be split.
#' @param percentage (optional, default 0.2) The percentage of elements that
#'   will be thrown into testing min one, if the group size is larger than one.
#'   Should be a numeric value between zero and one. The other 1 - percentage
#'   elements will be used for training. We will take the floor amount of
#'   elements if the percentages results in a non-integer value.
#' @param guessColumn (optional, default "label") The column name containing
#'   the group information.
#' @return A two-element list containing the testSet and trainSet data.
#' @seealso \code{\link{svmCountSplit}}
svmFormatData <- function( dataSet, percentage = 0.2, guessColumn = "label" ) {

  dataSet <- sort.data.frame(dataSet, col = guessColumn)

  keyVector <- unique(unlist(dataSet[[guessColumn]], use.names = FALSE))
  keyVector <- keyVector[order(keyVector)]

  boolVector <- unlist(
    sapply(keyVector, svmCountSplit,
      dataSet = dataSet, percentage = percentage, guessColumn = guessColumn)
    )

  if (DEBUG){
    testData <- cbind(dataSet, boolVector)
    print(testData[order(testData[guessColumn]), ])
  }

  trainSet <- dataSet[boolVector, ]
  testSet <- dataSet[!boolVector, ]

  # Creating a list whose names are the element containers
  return(list(testSet = testSet, trainSet = trainSet))
}

#' Sets up which process function that will operate on the data.
#'
#' @param dataSet The input data frame that the SVM will use.
#' @param guessColumn The column name containing the group information.
#' @param workFunction (optional, default NULL) The work function that will
#'   use the data.
#' @return The input dataSet passed in.
svmMain <- function( dataSet, guessColumn = "label",
    svmProcessFunction = NULL ) {

  debugprintf("Starting svmMain")

  if (is.null(dataSet)){
    stop("svmMain: Getting null data on svmMain")
  }

  if (class(dataSet) == "matrix"){
    stop("svmMain: dataSet must be a data.frame")
  }

  if (is.null(svmProcessFunction)){
    svmProcessFunction = svmProcessPercentSplit
  }

  return(svmProcessFunction(dataSet, guessColumn))

}

#' Creates a plot of the confusion matrix.
#'
#' Creates a heat map from the confusion matrix using gplot.
#'
#' @param confusionMatrix The confusion matrix that will be plotted.
#' @return The input confusion matrix.
svmPlot <- function ( confusionMatrix ) {

  heatmap.2(confusionMatrix,
    margins = c(5, 10), Colv = NULL, Rowv = NULL, srtCol = 0,
    xlab = "True", ylab = "Prediction",
    main = "Heat map of confusion matrix",

    dendrogram = "none", trace = "none",

    col = colorRampPalette(c("white", "black")),
    keysize = 1.2,

    labRow = lapply(rownames(confusionMatrix), function(x) {
      return(paste(x, " - pred count", (sum(confusionMatrix[x, ]))))
    }),
  )

  return(confusionMatrix)

}

#' Preforms leave-one-out on the data set.
#'
#' Preforms leave-one-out on the data set which is called k-folds, where k
#' is the number of rows on the data set. Configure gamma and cost to maximize
#' results.
#'
#' @param dataSet The input data frame.
#' @param guessColumn (optional, default "label") The column name containing
#'   the group information.
#' @param ... Any other paramters for the svmConstructor.
#' @return The input data frame.
svmProcessLeaveOneOut <- function ( dataSet, guessColumn = "label", ... ) {

  svmModel <- svmConstructor(dataSet, guessColumn,
    data = trainSet, degree = 3, gamma = 1000, cost = 1000,
    cross = nrow(dataSet), ...
  )

  print(summary(svmModel))

}

#' Splits the data set into training set and test set, by percentages,
#' and runs the SVM.
#'
#' If tuning is desired, it is suggested that the call to
#' \code{\link{svmTune}} be made in this function.
#'
#' @param dataSet The input data frame.
#' @param guessColumn (optional, default "label") The column name containing
#'   the group information.
#' @return The input data frame.
svmProcessPercentSplit <- function( dataSet, guessColumn = "label") {

  output <- svmFormatData(dataSet, guessColumn = guessColumn)

  testSet <- output[["testSet"]]
  trainSet <- output[["trainSet"]]

  # Uncomment and train
  #svmTune(trainSet, guessColumn)

  svmModel <- svmConstructor(dataSet, guessColumn,
    data = trainSet, degree = 3, gamma = 1000, cost = 1000)

  prediction <- predict(svmModel, removeColumn(testSet, guessColumn))

  confusionMatrix <- table(pred = prediction, true = testSet[, guessColumn])

  svmPlot(confusionMatrix)

  print(summary(svmModel))
  print(confusionMatrix)
  svmStats(confusionMatrix)

  printf("Numbers of training data %d", nrow(trainSet))
  printf("Numbers of test data %d", nrow(testSet))

  return(dataSet)
}

#' Takes the confusion matrix and prints the precision and recall of each
#' entry and the average of all values.
#'
#' This function relies on svmStatsCalc to print the values. All NAs are
#' ignored by the mean, which can skew results.
#'
#' Given the way the table is printed, the prediction is on the y-axis and the
#' actual value is printed on the x-axis.
#'
#' Due to the orientation of the table, these are true:
#' Precision is tp/(tp + fp) which is
#'   (True/ROW)
#' Recall is tp/(tp + fn) which is
#'   (True/COL)
#'
#' @param confusionMatrix The confusion matrix that will be analyzed.
#' @return The input confusion matrix.
#' @seealso \code{\link{svmStatsCalc}}
svmStats <- function( confusionMatrix ) {

  if (nrow(confusionMatrix) != ncol(confusionMatrix)){
    printf("svmStats: Confusion matrix not square. Dim(%d, %d)",
      nrow(confusionMatrix), ncol(confusionMatrix)
    )
  }
  else if (nrow(confusionMatrix) == 0){
    printf("svmStats: Data Frame size must be 1 or larger")
  }

  results <- t(sapply(rownames(confusionMatrix),
    svmStatsCalc, confusionMatrix))
  results <- data.frame(results)

  meanSelect <- function (colA, table = results)
      return(mean(unlist(table[[colA]]),
    na.rm = TRUE))
  weightedMeanSelect <- function (colMain, colWeight, table = results) {
    return(dotProduct(unlist(table[[colMain]]),
                       unlist(table[[colWeight]]))/
      sum(unlist(table[[colWeight]]), na.rm = TRUE)
    )
  }

  printf(
      "Unweighted average precision : %-0.8f Unweighted average recall %-0.8f",
    meanSelect("precision"), meanSelect("recall")
  )

  printf(
      "  Weighted average precision : %-0.8f   Weighted average recall %-0.8f",
    weightedMeanSelect("precision", "precisionDen"),
    weightedMeanSelect("recall", "recallDen")
  )

  return(confusionMatrix)
}

#' Prints the recall and precision for one specific entry.
#'
#' Recall should, in the worst case, be zero. The precision may be NA, due to
#' a division by zero. That is to say sum of rows can be zero but sum of
#' columns cannot be.
#'
#' @param colPos The current column (specifically diagonal entry) that
#'   the recall and precision will be printed.
#' @param confusionMatrix The input confusion matrix.
#' @return A list containing the numerator and denominator of precision
#'   and recall.
#' @seealso \code{\link{svmStats}}
svmStatsCalc <- function ( colPos, confusionMatrix ) {

  curEntry <- confusionMatrix[colPos, colPos]

  rowSum <- sum(confusionMatrix[colPos, ])
  colSum <- sum(confusionMatrix[, colPos])

  precision <- curEntry/rowSum
  recall <- curEntry/colSum
  precisionDen <- rowSum
  recallDen <- colSum

  printf(
    "Analyzing precision of group %s: %d/%d = %-6.4f | Recall : %d/%d = %-6.4f",
    colPos,
    curEntry, rowSum,
    precision,
    curEntry, colSum,
    recall
  )

  return(list(
    precision = precision,       recall = recall,
    precisionDen = precisionDen, recallDen = recallDen
  ))
}

#' Tunes an SVM machine to get optimal results and prints a table of the
#' best parameters.
#'
#' This should be used every time a different data set is used as a tuned SVM
#' has a nominally improved precision and recall. This should be the first
#' place to experiment when those two values need to be increased.
#'
#' @param trainSet The input training data frame.
#' @param testColumn (optional, default "label") The column name containing
#'   the group information.
#' @param gamma A numeric vector containing a collection of gamma values used
#'    for exploration.
#' @param cost A numeric vector containing a collection of cost values used
#'    for exploration.
#' @param ... Any other arguments for the tune function.
#' @return The input training frame.
svmTune <- function ( trainSet, testColumn = "label",
    gamma = 10^(-6:5), cost = 10^(-2:5), ... ) {

  tuned <- tune.svm(removeColumn(trainSet, testColumn), trainSet[[testColumn]],
    data = trainSet, gamma = gamma, cost = cost, ...)

  plot(tuned)

  print(summary(tuned))

  return(trainSet)
}

