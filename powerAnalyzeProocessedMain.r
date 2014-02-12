# We invoke the powerAnalyze code base with data in hand
# Created by David Tran

source('powerAnalyze.r')

print(str(processedMain( selectedCols=c('label', 'mean') )))
