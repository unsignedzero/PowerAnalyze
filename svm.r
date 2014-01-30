# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# This is a sub package interfacing with our SVM module.
#
# Created by David Tran
# Version 0.2.0.0
# Last Modified 01-30-2014

#install.packages('e1071',dependencies=TRUE)
library(e1071)

svmFormatData = function( dataset, percentage=0.5 ){

  index = 1:nrow(dataset)
  testindex = sample(index, trunc(length(index)*percentage))
  testset = dataset[testindex,]
  trainset = dataset[-testindex,]

  return (c(testset, trainset))

}

svmMain = function( dataset ){

  if (is.null(dataset)){
    stop("Getting null data on svmMain")
  }
  if (class(dataset) == "matrix"){
    stop("dataset must be a data.frame")
    newdataset=data.frame(dataset)
  }

  #print(dataset)

  logicArray = c(1:nrow(dataset) %% 3 != 0)
  trainset = dataset[logicArray,]
  logicArray = c(1:nrow(dataset) %% 3 == 0)
  testset = dataset[logicArray,]

  model = svm(label~., data=trainset)
  prediction = predict(model, testset[2])
  print(table(pred=prediction, true=testset[,1]))
  return (dataset)
}

#print(svmMain(read.csv('data/outputData')))
