<a href="https://imgur.com/AQte6eh"><img src="https://i.imgur.com/AQte6eh.png" title="source: Justin C. Bagley" width=60% height=60% align="center" /></a>

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/6ebf8b42a35f4b74a6a733312ac1d632)](https://www.codacy.com/app/justincbagley/PIrANHA?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=justincbagley/PIrANHA&amp;utm_campaign=Badge_Grade) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)<!-- [![Unicorn](https://img.shields.io/badge/nyancat-approved-ff69b4.svg)](https://www.youtube.com/watch?v=QH2-TGUlwu4) --> 
[![Tweet](https://img.shields.io/badge/twitter-share-76abec.svg)](https://goo.gl/QJzJu1) 
[![Twitter](https://img.shields.io/twitter/url/https/twitter.com/cloudposse.svg?style=social&label=Follow%20%40justincbagley)](https://twitter.com/justincbagley)

Scripts for file processing and analysis in phylogenomics &amp; phylogeography

## PIrANHA

PIrANHA provides a set of tools for automating file processing and analysis steps in the (phylo\*=) fields of phylogenomics and phylogeography (including population genomics). PIrANHA is fully command line-based and contains a series of functions for automating tasks during evolutionary analyses of genetic data. 

A variety of functions manipulate DNA sequence alignments, while others conduct custom analysis pipelines; for example, one set conducts reference-based assembly, allele phasing, and alignment of allelic sequences, starting from cleaned targeted sequence capture reads. Many functions are wrappers around existing software, allowing for straightforward automation of common analysis steps in evolutionary genetics. PIrANHA is under development (join in!), but the [alpha release](https://github.com/justincbagley/piranha/releases) is now stable! 

_New features_ include tab completion of function names, as follows:

<!-- ![piranha-tab-completion](https://raw.githubusercontent.com/justincbagley/piranha/master/assets/piranha_tab_completion2-min.gif) -->
<p align="center"><img src="/assets/piranha_tab_completion2-min.gif?raw=true"/></p>

## LICENSE

All code within **PIrANHA v0.4a3** repository is available "AS IS" under a 3-Clause BSD license. See the [LICENSE](LICENSE) file for more information.

## CITATION

Should you cite **PIrANHA**? See https://github.com/mr-c/shouldacite/blob/master/should-I-cite-this-software.md.

If you use scripts from this repository as part of your published research, please cite the repository as follows (also see DOI information below): 
  
- Bagley, J.C. 2020. PIrANHA v0.4a3. GitHub repository, Available at: http://github.com/justincbagley/PIrANHA.

Alternatively, provide the following link to this software repository in your manuscript:

- https://github.com/justincbagley/PIrANHA

## DOI

The DOI for PIrANHA, via [Zenodo](https://zenodo.org) (also indexed by [OpenAIRE](https://explore.openaire.eu/)), is as follows:  [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.596766.svg)](https://doi.org/10.5281/zenodo.596766). Here are some examples of citing PIrANHA using the DOI: 
  
  Bagley, J.C. 2020. PIrANHA v0.4a3. GitHub package, Available at: http://doi.org/10.5281/zenodo.596766.

  Bagley, J.C. 2020. PIrANHA. Zenodo, Available at: http://doi.org/10.5281/zenodo.596766.  

## DOCUMENTATION

For additional information on this distribution, including overview, dependencies, installation, updating, usage, workflows, etc., please see the documentation given in the **Quick Guide** ([here](https://github.com/justincbagley/piranha/wiki#quick-guide-for-the-impatient) or [here](Quick_Guide.pdf)) and the **[PIrANHA wiki!!!](https://github.com/justincbagley/PIrANHA/wiki)**

## CONTENTS

Directory tree...

```
.
├── LICENSE
├── README.md
├── changeLog.md
├── piranha
├── Quick_Guide.md
├── Quick_Guide.pdf
├── assets
│   └── ...
├── bin
│   ├── README.md
│   ├── calcAlignmentPIS
│   ├── NEXUS2PHYLIP
│   ├── PHYLIP2NEXUS
│   ├── PHYLIP2FASTA
│   ├── PHYLIP2Mega
│   ├── PHYLIP2PFSubsets
│   └── ...
├── install
│   ├── README.md
│   ├── INSTALL
│   ├── brew_piranha
│   └── local_piranha
├── lib
│   ├── README.md
│   ├── setupScriptFunctions.sh
│   ├── sharedFunctions.sh
│   ├── sharedVariables.sh
│   ├── utils.sh
│   └── virtualenv.txt
├── etc
│   ├── README.md
│   ├── beast_runner_default.cfg
│   ├── dadi_runner_default.cfg
│   ├── pushover.cfg.sample
│   ├── raxml_runner.cfg
│   ├── snapp_runner.cfg
│   └── .gitignore
├── test
│   ├── test.fasta
│   ├── test.phy
│   ├── test.nex
│   └── ...
└── tmp
    └── .gitignore
```
