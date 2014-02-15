# Power Analyze #

We analyze the power of the needy and provide feedback to those that
need it.

Created by David Tran (unsignedzero)

# TO DO #

# Notes #

* : has greater precedence than - so [20:40-20] = [(20:40)-20]

# Questions #

* sapply seems to name your vectors for you?

# Version/Changelog #

* Unit test checks if dataset exists before starting.
* Added object.check to check if an object(variable) is assigned.
* Created unit tests for powerAnalyze.r
* Created unit testing for library file.
* Created simple test harness for code base with one test. Run with make
  test-repo.
* New functions added to install a library if its not installed and then
  load it.
* Bugfix: Body removed the first (n-1) elements, not n.
* Sort function created for data frames in library.
* Code base can now take in a processed and labeled csv and run svm on it.

## 0.6.0.0 [02-11-2014] #
* Merging FFT into Development Branch.
* Tested Re, Im and mag to see which one has the best results.
* FFT and not-FFT (normal) versions can be executed separately.
* FFT initial base working.
* Adding space around = if not a keyword assign.
* Bugfix: Precision and recall corrected.
* Bugfix: Missing comma in printf.
* Report first draft created.
* Bugfix: Mistaking precision for call and vice-versa.
* Added more debugging and renamed a variable.
* Bugfix: Input data frame to SVM needs to be sorted.
* Bugfix: calib is labeled B and not C.
* No need for pipes with R.
* Added more base cases. Accuracy increased.

## 0.5.0.0 [02-04-2014] #
* SVM Module now spits out the parameters of interest from the confusion
  matrix.
* Error messages will display the function name as well for debugging purposes.
* Created simplified SVM constructor function.
* Renamed for variables for consistency.
* Using hex for the table.
* body returns the empty container rather than just NULL.
* Pulled SVM tuner coder into a function.
* Fixed some bad comments.
* Bugfix: SVM now uses the column passed in as, rather than a default
  label string, which breaks if the column we are interested in is NOT label.
* Updated the data names to match new regex mask.
* Created a few more library functions and moved out functions as needed.
* Bugfix: Confusion matrix didn't print pred or true before.
* Bugfix: Selecting the right columns for svm, was a position. Now
  selects from the column given.

## 0.4.0.0 [02-03-2014] #
* Failed to update version numbers correctly on files.
* Added extra check to see if the column we select from the file
  doesn't exist.
* Added extra comments and broke powerAnalyze.r into two files for
  easier reading.
* For the working directory, we move back to the default once we process
  the data.
* For the model, the data is split by a percentage now.

# 0.3.0.0 [01-30-2014] #
* Base data added.
* SVM working and printing confusion matrix.
* Bugfix: Main now creates a data.frame and not matrix.
* SVM module working.
* Simplified matrix creation call.
* Added label to process vector.
* Used closure to remove global counter.
* Cleaned up function names.
* BUgfix: Extra information in trace name.
* Bugfix: Removing extra print for extra table.

# 0.2.0.0 [01-28-2014] #
* List is now an acceptable data format for the SVM.
* Reading multiple data and returning a labeled list.
* Organized folder hierarchy.
* Added outline of SVM function.
* Summary function implemented in chain.
* Tested initial r script.
* Created make script to automate running r.

# 0.1.0.0 [01-24-2014] #
* Small support functions created for project.
* Created small reference page.
* Function now cuts of first and last 20 points.
* References left in file.
* Initial tutorial files created.
* Repo initially created with README and gitignore.
