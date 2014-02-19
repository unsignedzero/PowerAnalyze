# Make file to run this code repo
# Last Modified 02-15-2014

default: normal

gen-doc:
	r --no-save --file=R/front/powerAnalyzeGenDoc.r
	r CMD Rd2pdf --title='Power Analyze' -o output.tex man/*.Rd

normal:
	r --no-save --file=R/front/powerAnalyzeNormalMain.r '--args data'

fft:
	r --no-save --file=R/front/powerAnalyzeFFTMain.r '--args data'

readin:
	r --no-save --file=R/front/powerAnalyzeProocessedMain.r '--args outputDataFrame'

test-repo:
	r --no-save --file=R/tests/testPowerAnalyze.r

clean:
	rm -rvf *.x *.a *.o *.out *.gcda *.gcov *.gcno
	rm -rvf output*
	rm -v outputData

