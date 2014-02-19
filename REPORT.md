## Power Analyze Report #

The goal of this code base is to take a collection of power traces, summarize
each individual trace using the mean or some other mathematical function,
run that thought one of support vector machines (SVM) built into R, in this
repo we opted for e1071, and return back a confusion matrix with recall and
precision values for the associated data.

Although the focus of this report is on leveraging this code base for power
signature analysis, this code can, with little modification, work on different data sets.

R provides quite a few libraries for SVM. We opted for e1071 since it seemed to
be the first SVM created for R and also the most popular.

### Overview #

We will assume that ., in the case of this report refers to the repo's base
directory.

The repo is setup to be easy to use but also modular. Assuming the data is in
./data/ the code can be invoke by typing make in the base directory. All
data that ends in .csv will be picked up. The data is ran through a few statistical
functions (mean, median, sd, mad and ITR) and each row of the new data frame
corresponds to one file. A new column label is added to group different files together.

Once grouped, this data frame is split into two pieces, a training set and a
test set. This can be configured, but by default we will have 80% training and
20% testing. However, if there is at least two entries in the group, minimally
one is selected to be used for testing. This is fed into the SVM.

The resulting output is a summary of the classifier, the confusion matrix,
the precision and recall values for each label and a weighted average.
If multiple labels as used, it is suggested that they be exactly one character'
long for ease of reading the matrix. Afterwards, a summary of the data frame is printed
and the program ends.

The data itself may be transformed, via FFT or other algorithms, before condensing
it using a mean or some other statistical function.

### Code Analysis #

This code base uses apply heavily as opposed to for loops and embraces
the functional paradigm of programming.

Ignoring the data folder, documents and the makefile, we have three files of
interest in R.

* Root
  * R/
    * front/
      * A set a files that runs the library.
    * library.r
      * This contains common support functions for powerAnalyze.r and svm.r.
        This file can be used elsewhere as needed.
    * powerAnalyze.r
      * This function loads all other files Contained are
        functions that grab the csv and process it. Once finished the data frame
        is passed into the SVM module
    * svm.r
      * Performs the SVM work. Takes a data frame, creates the training and test
        set, runs it thought svm and prints the results.

Some of the other R files are in R/front directory. These are the small snippets
of code that load the above, three files, and execute them. This allows users to
use sections above independently without it executing. These files are called
by the makefile which, in turn, start the invocation chain.

The repo makes use of the makefile is to make it easier for users to use the code
base but that is NOT required. Additional, the makefile can be edited to
load from a different directory, as needed.

We will follow the above Overview in code.

After, svm.r and library.r are loaded in powerAnalyze.r, the rest of the
function symbols are loaded. The last line is executed starting the process.

Main is invokes and it checks for csv files. Should a file directory not be
passed, it will load in the same directory as the repo base directory. Each
file in turn is passed into loadCsvTrace. The columnName SHOULD be specified
to grab the right column that will be further processed for grouping. Should
the column name not exist, code will fail and stop. While processing the file,
it is converted into the data.frame and passed into processTrace. That function operates
on the data and returns back the summarized data. Inside processTrace, it
invokes labelTrace, which labels the trace.  As stated before, the label name should
be short if there are many different possible labels. After this process
is completed, control will be passed to svm.r, specifically svmMain. The output here
is a data frame with label as the first column and each output from a statistical
function as the other columns. Each row is a file.

Inside the SVM main, we pass the data frame to svmFormatData who splits the data
into our two sets, the training and testing. The split points are created from
a logical vector from svmCountSplit which is called for each label group. The
two data sets are passed into the svm to be processed. A simplified constructor
svmConstructor, is used to make life easier. Any arguments passed into this
function are passed to the actual SVM call. Afterwards, the model is created
and a confusion matrix is created thereafter. The output of the confusion matrix
is plotted on a heatmap.  After the model is created,
one can tune the SVM to maximize its precision and recall. From here, the precision and
recall for each label is calculated in svmStats which makes calls to svmStatsCalc for each
label group. After that, those two values are printed as well as the unweighted and
weighted averages of the precision and recall. Finally the number of elements
in the data set used in training and testing are printed.

At any point, a tee function can be called to print the output and pass the
data to the next function. This is much like BASH's tee except no actual
piping is performed. DEBUG may also be set to true, to display how many files
powerAnalyze.r was able to process and other information.

As stated before, one may transform the data before condensing it down. This is
easily done by passing a function into powerAnalyze's main. Note that there will
be errors when writing complex numbers to the data.frame. (This can be avoided
by forcing all numbers to be complex but that is beyond the scope of this
report, currently.)

### Additional library functions #

Below are a list of additional support functions not stated above and mostly used:

* body
  * As supposed to head and tail, body keeps all but the first nth, default 20,
    and last nth, also 20, elements in a data.frame.
* halt
  * Not used but stops the program and prints everything passed into it.
* install
  * Installs a given package at /usr/lib/R/site-library from the US Repo and its
    dependencies.
* libCheck
  * Checks if a library/package is installed and returns a boolean value with its
    result.
* lib
  * Together with libCheck and install, checks if the dependencies for the code
    is installed and does so if it isn't.
* mag
  * Computes the magnitude of a given input.
* object.exists
  * Checks if an object (variable) exists.
* removeColumn
  * Removes exactly one column in a data frame.
* sort.data.frame
  * Sorts a given data.frame by a column, or the first column if none specified.
* SuccessCount
  * A simplistic one method object that increments and prints out it values,
    if debugged is on, and returns it. In general, it is an incrementing counter.
* to.data.frame
  * Converts a list of lists to a data frame.

### Experimentation #

Initially, we started to focus on using just condensing our data set into a mean.
This yielded lackluster results. (gamma=0.1, cost=100). Less than half of the data
had precision and recall with only two entries having both values above 50%.
The rest were between 0% to 20%.

At that point, we opted to explore the FFT domain to see if we can get better results.
Given the nature of Power Traces being real, we opted to converted the FFT output to
a real number. We started with the real component only and that yielded worse results.
This is similarly seen if we take only the imaginary component as well as the magnitude,
with the magnitude being the best, real only second and imaginary only last. Our best
result here does not hold well against the untransformed data. We have over half NaNs for
precision, a quarter 0% and only two with some values. For recall we only have two values
100% and 40% and the rest are 0%.

At that point, we tuned the SVM and improved our results drastically (gamma=cost=1000).
In the time domain, we have one NaN for precision but over half got 100% and similarly
for recall. From worst to best ,we get 57%, 67%, 75%, 83%, and the rest 100% for precision
and 0%, 50%, 60%, 75% and the rest 100% for recall.

FFT, tuned, achieved even better results. Our worst values for precision are
67%, 67% and 80% with the rest being 100%. Similarly for recall we yield, 60%, 75%, 75%,
80% and finally 100% for the rest. These results come from taking just the mean of each trace
alone.

When we take both the mean and median of our data sets we yield 100% precision and recall for
both FFT and normal versions. It is, however, interesting to note that the untransformed
data is still sensitive to noise and by adding bogus files, negatively affects the SVM.
For the FFT, this is not seen in the results as all values are still 100%. Adding more columns
has little effect at this point.

### Dependencies #

This code base relies primarily on e1071 to run. For documentation, roxygen2 is required and
for plots gplots is required. Gplots may be commented out if a plot is not desired and roxygen2
is only required when running make gen-doc.

### Running the code base #

As stated earlier, this code base can be executed by using the make file. Assuming the csv data
is in data/, the code base can be started with make or make fft, depending on if fft is desired.
If the data is already parsed, make readin may be used to read in the data and run through an SVM.
The columns selected may be selected in the R file.
