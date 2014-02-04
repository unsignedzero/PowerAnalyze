# Make file to run this ship

default:
	r --no-save < powerAnalyze.r '--args data'

clean:
	rm -rvf *.x *.a *.o *.out *.gcda *.gcov *.gcno
	rm -rvf output*
	rm -v outputData

