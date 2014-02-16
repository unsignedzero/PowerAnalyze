# Make file to run this code repo
# Last Modified 02-15-2014

default: normal

normal:
	r --no-save --file=powerAnalyzeNormalMain.r '--args data'

fft:
	r --no-save --file=powerAnalyzeFFTMain.r '--args data'

readin:
	r --no-save --file=powerAnalyzeProocessedMain.r '--args outputDataFrame'

test-repo:
	r --no-save --file=test/testPowerAnalyze.r

clean:
	rm -rvf *.x *.a *.o *.out *.gcda *.gcov *.gcno
	rm -rvf output*
	rm -v outputData

