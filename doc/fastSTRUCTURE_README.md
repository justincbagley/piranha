# fastSTRUCTURE

THIS SCRIPT runs **fastSTRUCTURE** (Raj et al. 2014) to infer admixture groups, hence population genetic structuring, in a sample of unlinked, biallelic SNP loci present in the working  directory. 

Whereas the original script ("fastSTRUCTURE.sh", available on my website) was written to be interactive, prompting the user for input at several points, this shell script provides users a means of running fastSTRUCTURE in _non-interactive_ fashion, and thus must contain all information for a run internally. 

Aside from dealing only with biallelic SNPs, the following code assumes that you have fastSTRUCTURE v1.0 installed locally and that you know the path to the directory  containing it (structure.py) and other python scripts in the distribution. It is also assumed that, prior to installing fastSTRUCTURE, you correctly installed all of the following four dependencies:

	1. Numpy(http://www.numpy.org/)
	2. Scipy(http://www.scipy.org/)
	3. Cython(http://cython.org/)
	4. GNU Scientific Library (http://www.gnu.org/software/gsl/)

It is also assumed that your data are in the original Structure data format with  the filename having the extension ".str"; however, it is important to note that when you enter the name of the input file below to assign it to the variable "fsInput", **you should enter this name WITHOUT the file extension. This is consistent with the default usage of fastSTRUCTURE.**

This code takes you through all of the major steps of a simple fastSTRUCTURE analysis. However, the more complex models available in the software program, i.e. the logistic prior model, are not used; instead, the default setting is to run using the simple prior model. You can change this by calling the logistic model using the prior flag in fastSTRUCTURE, e.g. calling "--prior=logistic" when running "structure.py". This code also follows the fastSTRUCTURE default *NOT* to run a cross-validation step. 

**To understand prompts or run settings, users should refer to the fastSTRUCTURE Genetics paper by Raj et al. (2014) and README.md file that come with the distribution. These are available from the regular website (https://rajanil.github.io/fastStructure/) or the GitHub website (https://github.com/rajanil/fastStructure) for the program.**

## REFERENCES

- Raj A, Stephens M, and Pritchard JK (2014) fastSTRUCTURE: Variational Inference of Population Structure in Large SNP Data Sets. Genetics, 197, 573-589.

August 23, 2017 Justin C. Bagley, Richmond, VA, USA
