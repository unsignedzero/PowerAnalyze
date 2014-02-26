# We invoke the powerAnalyze code base and FFTing the data
# Created by David Tran

source('R/powerAnalyze.r')

print(str(main(svmProcessFunction=svmProcessLeaveOneOut)))
