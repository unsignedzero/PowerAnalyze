# PowerAnalyze Library Module
# Library support functions for PowerAnalyze repo
#
# Created by David Tran
# Version 0.5.0.0
# Last Modified 02-15-2014

# Background Functions
body = function ( data, n = 20 ){

  # As oppose to head and tail, we grab all but the first nth
  # and last nth elements of the data, if it is possible.
  # We return the empty container if it is not possible.

  # We want to iterate over lists, not elements in a vector

  if (class(data) == "data.frame"){
    len = nrow(data)
    if ( (n+1) > (len-n) ){
      printf("body: Impossible range %d to %d", n, len-n)
      return (data[NULL,])
    }

    return (data[(n+1):(len-n),])

  } else if (class(data) == "list"   || class(data) == "integer" ||
            class(data) == "numeric" || class(data) == "character" ){
    len = length(data)

    if ( (n+1) > (len-n) ){
      printf("body: Impossible range %d to %d", n, len-n)
      return (NULL)
    }

    output = data[(n+1):(len-n)]
    print(output)
    return(output)

  } else{
    printf("body: Unknown data type %s", class(data))
    return (NA)
  }
}

halt = function ( ... ){

  # Stops the program and prints what it currently has

  print(...)
  stop("Halting execution...")

  # This should NOT happen
  return (...)
}

install = function (pack, ...) {

  # Install package pack at lib with dependencies resolved
  # Default install is .libPaths()[1]

  install.packages(pack, lib='/usr/lib/R/site-library',
  dependencies=TRUE, repos='http://cran.us.r-project.org',
  ...
  )
}
inst = install

libCall = function (pack, ...){

  # Load a lib from .libPaths()[1]

  return (library(pack, lib.loc='/usr/lib/R/site-library',
  logical.return = TRUE, character.only = TRUE,
  ...))
}

lib = function (pack, ...){

  # Wrapper call to load a library

  if (libCall(pack, ...)){
    # Loaded successfully
    return (TRUE)
  }
  else{
    # Try to install and load
    install(pack)
    return (libCall(pack, ...))
  }
}

mag = function(x) {

  # Computes the magnitude

  if (class(x) == "numeric"){
    return (x)
  }
  else if (class(x) == "complex"){
    return (sqrt(Re(x)^2 + Im(x)^2))
  }
  else if ((class(x) == "list") || (class(x) == "numeric") ||
           (class(x) == "integer")){
    return (sqrt(sum(sapply(x, function(x) x^2))))
  }
  else{
    stop("Unknown datatype passed")
  }
}

removeColumn = function( frame , colName ){

  # Removes one column from the data.frame
  # https://stackoverflow.com/questions/11940605/printing-a-subset-of-columns-in-a-data-table-r
  # didn't help due to with ERROR

  logicVector = unlist(lapply(colnames(frame),
    function(x) (!grepl(colName, x))))

  return (frame[logicVector])
}

sort.data.frame = function ( input, col = NULL ){

  if (class(input) == "data.frame"){
    if (is.null(col)){
      return (input[order(input[1]),])
    }
    else if (col %in% colnames(input)){
      return (input[order(input[col]),])
    }
    else{
      stop("sort: Col %s passed does not exist in data frame %s",
        str(col), str(input)
      )
      return (-1)
    }
  }
  else if(class(input) == "list"){
    return (input[order(unlist(input))])
  }
  else if(class(input) == "numeric" || class(input) == "character" ||
          class(input) == "integer" )
        {
    #return (input[order(input)])
    return (sort(input))
  }
  else{
    stop("sort: Unknown data type %s passed.", class(input))
    return (-1)
  }
}

square = function (x) {

  # Squares all elements passed

  if (class(x) == "numeric"){
    return (x^2)
  }
  else{
    return (sapply(x, function(x) x^2))
  }
}


successCount = function ( n = 0, startMsg = "This is the ",
    endMsg = "th successful call" ){

  # This is a factory function that creates an incrementing
  # counter from n onward. Note this returns a function so
  # invoke the return type as a function

  increment = function () {
    n <<- n + 1
    debugprintf("%s%d%s", startMsg, n, endMsg)
    return (n)
  }

  return (increment)
}

tee = function(csvData, file='outputDataFrame'){

  # Writes the current data in the stream to file and passes it
  # to the next invoked function

  write.csv(csvData, file=file)

  return (csvData)
}

to.data.frame = function ( mat ){

  # Converts a list of lists to a data.frame

  return (do.call(rbind.data.frame, mat))
}
