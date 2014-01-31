# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# This is a sub package interfacing with our SVM module.
#
# Created by David Tran
# Version 0.2.1.0
# Last Modified 01-30-2014

#install.packages('e1071',dependencies=TRUE)
library(e1071)

svmCountSplit = function ( key, dataset, percentage=0.2, uniqueColumn='label' ){

  count= nrow(dataset[dataset[[uniqueColumn]]==key,])
  splitValue = floor(percentage*count)

  if (splitValue== 0 && count > 1)
    splitValue = 1

  boolRetVector = as.logical(1:count)
  boolRetVector[1:splitValue] = FALSE

  return (boolRetVector)
}

svmFormatData = function( dataset, percentage=0.2, uniqueColumn ='label' ){

  keyVector = unique(unlist(dataset[[uniqueColumn]], use.names = FALSE))

  boolVector = unlist(
    sapply(keyVector, svmCountSplit,
      dataset=dataset, percentage=percentage, uniqueColumn=uniqueColumn)
    )

  #boolVector = NULL
  #for (key in keyVector){
  #  boolVector = c(boolVector,svmCountSplit(key, dataset, percentage, uniqueColumn))
  #}

  trainList = dataset[boolVector,]
  testList = dataset[!boolVector,]

  return (list(testList, trainList))

}

svmMain = function( dataset, guessColumn='label' ){

  if (is.null(dataset)){
    stop("Getting null data on svmMain")
  }
  if (class(dataset) == "matrix"){
    stop("dataset must be a data.frame")
    newdataset=data.frame(dataset)
  }

  output = svmFormatData(dataset, uniqueColumn=guessColumn)

  testList = output[[1]]
  trainList = output[[2]]

  model = svm(label~., data=trainList)
  prediction = predict(model, testList[2])
  print(table(pred=prediction, true=testList[,1]))

  return (dataset)
}

