# PowerAnalyze
# This r file will read power traces and attempt to classify them
# using SVM
#
# Created by David Tran
# Version 0.1.1.0
# Last Modified 01-25-2014

# Add more files with this
# source

printf = function (...) print(sprintf(...))

summary = function (x) {
  # Applies the statistics functions to the input
  funs = c(mean, median, sd, mad, IQR)
  output = lapply(funs, function(f) f(x, na.rm = TRUE))

  names(output) = c("mean", "median", "sd", "mad", "IQR")

  return (output)
}

success = function ( n = 0, startMsg = "This is the ",
    endMsg = "th successful call" ){

  increment = function () {
    n = n + 1
    printf("%s%d%s", startMsg, n, endMsg)
  }

  return (increment)
}

# We create an instance of the above for our record
callCount = success()

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

    output = lapply(data, (function(x) x[n:(len-n)]))

    return (if (isVectorFlag) unlist(output) else output)

  } else{
    printf("Unknown data type %s", class(data))
    return (NA)
  }

}

loadcsv = function ( fin ) {

  if ((is.null(fin))| is.na(fin) | (!file.exists(fin))){
    printf("File passed %s does not exist.", fin )
    return (NA)
  }

  callCount()

  # Grab what we need from the data
  trimmedData = ((body(read.csv(fin))))

  # Get statistical work
  return (lapply(trimmedData,summary))
}

main = function () {

  printf( "Code read successfully. Executing..." )
  args=(commandArgs(TRUE))

  if(length(args)==0){
    stop("No arguments supplied.")
  }

  fileargs=Filter(file.exists,args)
  return (sapply(fileargs, loadcsv))
}

printf("%s",str(main()))
