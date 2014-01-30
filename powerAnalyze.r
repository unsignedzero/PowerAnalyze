# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# This is the main package managing the data flow.
#
# Created by David Tran
# Version 0.2.2.1
# Last Modified 01-29-2014

# Add more files with this
source('svm.r')

# Debugger state
DEBUG = FALSE

# Aliases...
printf = function (...) print(sprintf(...))
debugprint = function (...) if (DEBUG) print(...)
debugprintf = function (...) if (DEBUG) printf(...)

# Background Functions
successCount = function ( n = 0, startMsg = "This is the ",
    endMsg = "th successful call" ){

  increment = function () {
    n <<- n + 1
    debugprintf("%s%d%s", startMsg, n, endMsg)
    return (n)
  }

  return (increment)
}


labelTrace = function(dataLabel) {

  if (is.null(dataLabel)){
    return (-1)
  }
  else if (grepl('another', dataLabel)){
    return (1)
  }
  else if (grepl('sample', dataLabel)){
    return (2)
  }
  else{
    return (0)
  }
}

processTrace = function (traceVector, label=NULL){

  # Applies the statistics functions to the input

  funs = c(mean, median, sd, mad, IQR)
  output = lapply(funs, function(f) f(traceVector, na.rm = TRUE))

  # Add 'label' to first entry in vector.
  traceLabel = labelTrace(label)
  output = c(traceLabel,output)

  names(output) = c("label",
    c("mean", "median", "sd", "mad", "IQR")
  )

  return (output)
}

body = function ( data, n = 20 ){

  # As oppose to head and tail we grab all but the first nth
  # and last nth elements of the data, if it is possible

  isVectorFlag = FALSE

  # We want to iterate over lists, not elements in a vector
  if (class(data) == "integer" | class(data) == "numeric" |
      class(data) == "character" ){
    data = list(data)
    isVectorFlag = TRUE
  }

  if (class(data) == "data.frame"){
    len = nrow(data)
    if ( n > len - n ){
      printf("Impossible range %d to %d", n, len-n)
      return (NULL)
    }

    return (data[n:(len-n),])

  } else if (class(data) == "list"){
    len = length(data)
    if ( n > len - n ){
      printf("Impossible range %d to %d", n, len-n)
      return (NULL)
    }

    output = apply(data, (function(x) x[n:(len-n)]))

    return (if (isVectorFlag) unlist(output) else output)

  } else{
    printf("Unknown data type %s", class(data))
    return (NA)
  }

}

loadCsvTrace = function ( fileName, successfulCallCount = function() NULL,
  columnName = 'Good' ) {

  if ((is.null(fileName))| is.na(fileName) | (!file.exists(fileName))){
    printf("File passed %s does not exist.", fileName)
    return (NA)
  }
  else {
    debugprintf("Loading %s", fileName)
  }

  successfulCallCount()

  # Grab what we need from the data
  trimmedData = ((body(read.csv(fileName))))

  usefulColumns = c(columnName)
  trimmedData=trimmedData[usefulColumns]

  names(trimmedData) = c()

  # Get statistical work
  return (lapply(trimmedData,function(x) processTrace(x, fileName)))
}

main = function () {

  debugprintf("Code read successfully. Executing...")
  args=(commandArgs(TRUE))

  if(length(args)==0){
    printf("No arguments supplied. Grabbing all files in the current directory")
  }
  else{
    setwd(file.path(getwd(),args[1]))
  }
  args=list.files()

  fileargs=Filter(file.exists, args)

  if (length(fileargs)==0){
    printf("No files were successfully located at %s", getwd())
    stop("Halting execution.")
  }

  # We create an instance of the above for our record
  callCounter = successCount()

  outputDataFrame = sapply(fileargs, function(x) loadCsvTrace(x, callCounter))

  return (do.call(rbind,outputDataFrame))



}

print(main())
