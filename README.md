# Power Analyze #

We analyze the power of the needy and provide feedback to those that
need it.

Created by David Tran (unsignedzero)

# TO DO #

* Tinker with values of SVN, like gamma.
* Need more data to get svm to show possible states and possibly graph?

# Notes #

# Questions #

* sapply seems to name your vectors for you?

# Version/Changelog #

* Updated the data names to match new regex mask.
* Created a few more library functions and moved out functions
  as needed.
* Bugfix: Confusion matrix didn't print pred or true before.
* Bugfix: Selecting the right columns for svm, was a position. Now
  selects from the column given.

## 0.4.0.0 [02-03-2013] #
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
