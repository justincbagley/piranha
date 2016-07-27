#
#
##--------------------------------------- README ---------------------------------------##
##--THIS SCRIPT runs fastSTRUCTURE to infer admixture groups, hence population genetic
##--structuring, in a sample of unlinked, biallelic SNP loci present in the working 
##--directory. 
#
##--This script is written to be interactive, prompting the user for input at
##--several points; however, the script can easily be altered to run on a cluster or in 
##--the background, or even on all of several folders of SNP datasets within the same 
##--parent directory. I have already done this in a separate script that is named
##--"fastSTRUCTUREx.sh" that is also available from my GitHub website. So, if you would 
##--prefer to run non-interactively, you should switch *NOW* to using the non-interactive
##--script (note: in the file name, "x" stands for "not", as in not interactive).
#
##--Aside from dealing only with biallelic SNPs, the following code assumes that you have
##--fastSTRUCTURE v1.0 installed locally and that you know the path to the directory 
##--containing it (structure.py) and other python scripts in the distribution. It is also
##--assumed that, prior to installing fastSTRUCTURE, you correctly installed all of the
##--following four dependencies:
##
##	1. Numpy(http://www.numpy.org/)
##	2. Scipy(http://www.scipy.org/)
##	3. Cython(http://cython.org/)
##	4. GNU Scientific Library (http://www.gnu.org/software/gsl/)
##
##--It is also assumed that your data are in the original Structure data format with 
##--the filename having the extension ".str"; however, it is important to note that when
##--prompted for the name of the input file, you should enter this name WITHOUT the file
##--extension. This is the default usage of fastSTRUCTURE.
#
##--This code takes you through all of the major steps of a simple fastSTRUCTURE analysis.
##--However, the more complex models available in the software program, i.e. the logistic
##--prior model, are not used; instead, the default setting is to run using the simple 
##--prior model. You can change this by calling the logistic model using the prior flag
##--in fastSTRUCTURE, e.g. calling "--prior=logistic" when running "structure.py". This
##--code also follows the fastSTRUCTURE default *NOT* to run a cross-validation step. 
#
##--To understand prompts or run settings, users should refer to the fastSTRUCTURE BioRxiv
##--paper by Raj et al. and README.md file that come with the distribution. These are 
##--available from the regular website (https://rajanil.github.io/fastStructure/) or the
##--GitHub website (https://github.com/rajanil/fastStructure) for the program. 
#
##--References:
##--Raj et al. BioRxiv.
##--------------------------------------------------------------------------------------##
#
#
#
