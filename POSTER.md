## Power Analyze Report #

Created: David Tran
Faculty Advisor: Dr. Suzanne Rivoire
Author Affiliations: SSU CS Department

### Background #

Computers from cellphones, and Raspberry Pis, to laptops are ubiquitous in many peoples' lives.
Servers and super computers are less noticed until problems occur. Mostly all run on
electricity and one important goal is to try to conserve energy. From the hardware to the software,
many techniques are employed. These many include powering down idle cores, sleeping and
ordering applications in a specific order.

### Objective #

* Use given power traces to train a classifier model.

* Use different power traces to test the model and evaluate its accuracy.

* Transform the data, via FFT, and see if its beneficial

### Method #

* Used R to clean, process the power trace and test the classifier model.

* Analyzed the output of the classifier.

* Tested different configurations on the input data to maximize accuracy.

### Classifier #

* Attempts to create a model given the power traces.

* Creates different domains (regions) for each group of traces.

### Future Work #

In the future, we would like to use the SVM on more data sets and see if the
SVM maintains precision and recall.

### Learned #

* Use a functional paradigm in R.
* Use SVM models, and how to tune them correctly.
* Create comments that leverage the R document generator.
* Create BDD tests to show that the code works.
