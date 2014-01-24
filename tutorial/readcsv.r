
# https://stackoverflow.com/questions/2151212/how-can-i-read-command-line-parameters-from-an-r-script
# Invoke with
# r --no-save < readcsv.r '--args sample.csv'

# https://stackoverflow.com/questions/2175809/alternative-to-is-null-in-r
is.defined = function(x)!is.null(x)
# http://www.inside-r.org/r-doc/base/file.remove
exists = function(x)file.exists(x)

readcsv = function ( fin ) {

  # http://www.statmethods.net/management/operators.html
  if ((is.null(fin))| (!file.exists(fin)))
   stop("No fin passed")

  # http://www.r-tutor.com/r-introduction/data-frame/data-import
  inputcsv = read.csv(fin)
  print( inputcsv )

}

main = function (){
  args=(commandArgs(TRUE))
  if(length(args)==0){
    stop("No arguments supplied.")
  }
  print( args[[1]] )
  readcsv ( args[[1]] )
}

main()
