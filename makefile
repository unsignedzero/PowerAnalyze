# Make file to run this ship

default:
	r --no-save < powerAnalyze.r '--args tutorial/sample.csv'

clean:
	rm -rvf *.x *.a *.o *.out *.gcda *.gcov *.gcno
	rm -rvf output*

