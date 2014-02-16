# We invoke the powerAnalyze code base without FFTing the data
# Created by David Tran

source('powerAnalyze.r')

print(str(main(function(x) Re(fft(x)))))

