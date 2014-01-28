# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# This is a sub package interfacing with our SVM module.
#
# Created by David Tran
# Version 0.1.1.0
# Last Modified 01-28-2014

#install.packages('e1071',dependencies=TRUE)
library(e1071)

formatData = function( dataset, percentage=0.3 ){

  index <- 1:nrow(dataset)
  testindex <- sample(index, trunc(length(index)*percentage))
  testset <- dataset[testindex,]
  trainset <- dataset[-testindex,]

}
