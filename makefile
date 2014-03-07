# Make file to run this code repo
# Last Modified 03-07-2014

default: normal

doc:
	r --no-save --file=R/front/powerAnalyzeGenDoc.r
	r CMD Rd2pdf --title='Power Analyze' -o output.tex man/*.Rd

lnormal:
	r --no-save --file=R/front/powerAnalyzeNormalMainLOO.r '--args data'

lfft:
	r --no-save --file=R/front/powerAnalyzeFFTMainLOO.r '--args data'

normal:
	r --no-save --file=R/front/powerAnalyzeNormalMain.r '--args data'

fft:
	r --no-save --file=R/front/powerAnalyzeFFTMain.r '--args data'

readin:
	r --no-save --file=R/front/powerAnalyzeProcessedMain.r '--args outputDataFrame'

test:
	r --no-save --file=tests/testPowerAnalyze.r

clean:
	rm -rvf *.x *.a *.o *.out *.gcda *.gcov *.gcno
	rm -rvf output*
	rm -v outputData

