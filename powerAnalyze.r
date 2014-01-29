# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# This is the main package managing the data flow.
#
# Created by David Tran
# Version 0.2.0.0
# Last Modified 01-28-2014

# Add more files with this
source('svm.r')

# Aliases...
DEBUG = TRUE
printf = function (...) print(sprintf(...))
debugprintf = function (...) if (DEBUG) printf(...)

# Background Functions
successCount = function ( n = 0, startMsg = "This is the ",
    endMsg = "th successful call" ){

  increment = function () {
    n <<- n + 1
    printf("%s%d%s", startMsg, n, endMsg)
  }

  return (increment)
}

# We create an instance of the above for our record
successfulCallCount = successCount()

process_list = function (x) {
  # Applies the statistics functions to the input
  funs = c(mean, median, sd, mad, IQR)
  output = lapply(funs, function(f) f(x, na.rm = TRUE))

  names(output) = c("mean", "median", "sd", "mad", "IQR")

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

loadcsv = function ( fin ) {

  if ((is.null(fin))| is.na(fin) | (!file.exists(fin))){
    printf("File passed %s does not exist.", fin)
    return (NA)
  }
  else {
    printf("Loading %s", fin)
  }

  successfulCallCount()

  # Grab what we need from the data
  trimmedData = ((body(read.csv(fin))))

  usefulColumns = c('Good')
  trimmedData=trimmedData[usefulColumns]

  #names(trimmedData) = c(fin)

  # Get statistical work
  return ((lapply(trimmedData,process_list)))
}

main = function () {

  printf("Code read successfully. Executing...")
  args=(commandArgs(TRUE))

  if(length(args)==0){
    printf("No arguments supplied. Grabbing all files in the current directory")
    args=list.files()
  }
  else{
    setwd(file.path(getwd(),args[1]))
    args=list.files(getwd())
  }

  fileargs=Filter(file.exists, args)

  if (length(fileargs)==0){
    printf("No files were successfully located at %s", getwd())
    stop("Halting execution.")
  }

  meanValue = (sapply(fileargs, loadcsv))

  #names(meanValue) = c(args)

  return (t(do.call(cbind,meanValue)))

}

print(main())
print(mtcars)
