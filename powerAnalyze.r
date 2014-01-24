# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# Created by David Tran
# Version 0.1.0.0
# Last Modified 01-24-2014

body = function ( data, n = 20 ){

  # As oppose to head and tail we grab all but the first nth
  # and last nth elements of the data, if it is possible

  isVectorFlag = FALSE

  # We want to iterate over lists, not elements in a isvector
  if (class(data) == "integer" | class(data) == "numeric" ){
  	data = list(data)
  	isVectorFlag = TRUE
	}

  len = length(data)
  output = lapply(data, (function(x) x[n:len-n]))

  if (isVectorFlag) unlist(output) else output

}

loadcsv = function ( fin ) {

  if ((is.null(fin))| (!file.exists(fin)))
   stop("No file passed")

  body(read.csv(fin))

}
