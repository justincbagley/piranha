<a href="http://imgur.com/qLNrh5B"><img src="http://i.imgur.com/qLNrh5B.png" title="source: Justin C. Bagley" width=60% height=60% align="center" /></a>

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/6ebf8b42a35f4b74a6a733312ac1d632)](https://www.codacy.com/app/justincbagley/PIrANHA?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=justincbagley/PIrANHA&amp;utm_campaign=Badge_Grade) [![License](http://img.shields.io/badge/license-GPL%20%28%3E=%202%29-green.svg?style=flat)](LICENSE)

Scripts for file processing and analysis in phylogenomics &amp; phylogeography

<!-- ```diff
- red
+ green
! orange
# gray
```
-->

<h3>
  
```diff
! ** WARNING! PIrANHA v0.2-alpha.1c is a pre-release version of a new release that
! involves a complete rewrite of PIrANHA. PLEASE DO NOT DOWNLOAD THIS RELEASE!!! **
```

</h3>

This release is only available publicly to ease issues related to lack of support for Homebrew taps for private repositories.

## LICENSE

All code within **PIrANHA v0.2-alpha.1c** repository is available "AS IS" under a 3-Clause BSD license. See the [LICENSE](LICENSE) file for more information.

## CITATION

If you use scripts from this repository as part of your published research, I require that you cite the repository as follows (also see DOI information below): 
  
- Bagley, J.C. 2019. PIrANHA v0.2-alpha.1c. GitHub repository, Available at: http://github.com/justincbagley/PIrANHA.

Alternatively, please provide the following link to this software repository in your manuscript:

- https://github.com/justincbagley/PIrANHA

## DOI

The DOI for ```PIrANHA```, via [Zenodo](https://zenodo.org), is as follows:  [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.890815.svg)](https://doi.org/10.5281/zenodo.890815). Here are some examples of citing PIrANHA using the DOI: 
  
  Bagley, J.C. 2019. PIrANHA v0.2-alpha.1c. GitHub package, Available at: http://doi.org/10.5281/zenodo.596766.

  Bagley, J.C. 2019. PIrANHA. Zenodo, Available at: http://doi.org/10.5281/zenodo.596766.  

## DOCUMENTATION

For additional information on this distribution, including pipelines, installation, capabilities, etc., please see the documentation given in the [PIrANHA wiki!!!](https://github.com/justincbagley/PIrANHA/wiki)

## CONTENTS

Directory tree...

```
.
├── LICENSE
├── README.md
├── changeLog.md
├── piranha
├── bin
│   ├── README.md
│   ├── calcAlignmentPIS
│   ├── NEXUS2PHYLIP
│   ├── PHYLIP2NEXUS
│   ├── PHYLIP2FASTA
│   ├── PHYLIP2Mega
│   ├── PHYLIP2PFSubsets
│   └── ...
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
└── tmp
    └── .gitignore
```
