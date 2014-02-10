## Power Analyze Report #

The goal of this code base is to take a collection of power traces, summarize
each individual trace using the mean or some other mathematical function,
run that thought one of support vector machines (SVM) built into R, in this
repo we opted for e1071, and return back a confusion matrix, with recall and
precision values for the associated data.

R provides quite a few libraries for SVM. We opted for e1071 since it seemed to
be the first SVM created for R and also the most popular.

### Overview #

We will assume that ., in the case of this report refers to the repo's base
directory.

The repo is setup to be easy to use but also modular. Assuming the data is in
./data/ the code can be invoke by typing make in the base directory. All
data that ends in .csv will be picked up. The data is ran through a mean
function and each row of the new data frame corresponds to one file. A new
column label is added to group different files together.

Once grouped, this data frame is split into two pieces, a training set and a
test set. This can be configured, but by default we will have 80% training and
20% testing. However, if there is at least two entries in the group, minimally
one is selected to be used for testing.

The resulting output is a summary of the classifier, the confusion matrix and
the precision and recall values for each label. Given multiple labels, it is
suggested that they be exactly one character long for ease of reading the
matrix. Afterwards, a summary of the data frame is printed and the program
ends.

### Code Analysis #

This code bases uses apply heavily as opposed to for loops and embraces
the functional paradigm of programming.

Ignoring the data folder, documents and the makefile, we have three files of
interest in R.

* Root
  * library.r
    * This contains common support functions for powerAnalyze.r and svm.r.
      This file can be used elsewhere as needed.
  * powerAnalyze.r
    * This function loads all other files and executes it. Contained are
      functions that grab the csv and process it. Once finished the data frame
      is passed into the svm module
  * svm.r
    * Performs the SVM work. Takes a data frame, creates the training and test
      set, runs it thought svm and prints the results.

The main use of the makefile is to make it easier for users to use the code
base but that is NOT required. Additional, the makefile can be edited to
load from a different directory, as needed.

We will follow the above Overview in code.

After, svm.r and library.r are loaded in powerAnalyze.r, the rest of the
function symbols are loaded. The last line is executed starting the process.

Main is invokes and it checks for csv files. Should a file directory not be
passed, it will load in the same directory as the repo base directory. Each
file in turn in passed into loadCsvTrace. The columnName SHOULD be specified
to grab the right column that will be further processed. Should the column
name not exist, code will fail and stop. While processing the file, it is
converted into the list and passed into processTrace. That function operates
on the data and returns back the summarized data. Inside processTrace, it
invokes labelTrace, which labels the trace.  As stated before, this should
be short if there are many different possible labels. After this process
is completed, control will be passed to svm.r, specifically svmMain.

Inside this main, we pass the data frame to svmFormatData who splits the data
into our two sets, the training and testing. The split points are created from
a logical vector from svmCountSplit which is called for each label group. The
two data sets are passed into the svm to be procesed. A simplified constructor
svmConstructor, is used to make life easier. Any arguments passed into this
function are passed to the actual SVM call. Afterwards, the model is created
and a confusion matrix is created thereafter. From here, the precision and
recall for each label is calculated in svmStats which makes calls to svmStatsCalc for each
label group. After that, those two values are printed and finally the
number of elements in the data set used in training and testing are printed.

At any point, a tee function can be called to print the output and pass the
data to the next function. This is much like BASH's tee except no actual
piping is performed. DEBUG may also be set to true, to display how many files
powerAnalyze.r was able to process and other information.

Below are a list of additional support functions not stated above and used:
  * body
    * As supposed to head and tail keeps all but the first nth, default 20,
      and last nth, also 20, elements in a data.frame.
  * halt
    * Not used but stops the program and prints everything passed into it.
  * removeColumn
    * Removes exactly one column in a data frame
  * to.data.frame
    * Converts a list of lists to a data frame.

