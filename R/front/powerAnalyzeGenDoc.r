# Generates the documentation using
# Created by David Tran

source('R/library.r')
lib('roxygen2')

docBuild <- TRUE
print(roxygenize('.'))
