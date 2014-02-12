# Make file to run this ship

default: normal

normal:
	r --no-save --file=powerAnalyzeNormalMain.r '--args data'

fft:
	r --no-save --file=powerAnalyzeFFTMain.r '--args data'

readin:
	r --no-save --file=powerAnalyzeProocessedMain.r '--args outputDataFrame'

clean:
	rm -rvf *.x *.a *.o *.out *.gcda *.gcov *.gcno
	rm -rvf output*
	rm -v outputData

