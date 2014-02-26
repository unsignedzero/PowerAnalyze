# We invoke the powerAnalyze code base without FFTing the data
# Created by David Tran

source('R/powerAnalyze.r')

print(str(main(function(x) mag(fft(x)), svmProcessFunction=svmProcessLeaveOneOut)))
