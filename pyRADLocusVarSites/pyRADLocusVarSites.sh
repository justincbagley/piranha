#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                         pyRADLocusVarSites v0.1.0, April 2017                          #
#  CALCULATES NUMBERS OF VARIABLE SITES AND PARSIMONY-INFORMATIVE (i.e. PHYLOGENETICALLY #
#  INFORMATIVE SITES) FOR SET OF SNP LOCI IN pyRAD .loci OUTPUT, THEN RANKS LOCI BY      #
#  VARIABILITY                                                                           #
#  Copyright ©2019 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: April 7, 2017. For questions, please email bagleyj@umsl.edu.                  #
##########################################################################################

echo "
##########################################################################################
#                         pyRADLocusVarSites v0.1.0, April 2017                          #
##########################################################################################
"

###### STEP #1: SETUP.
	MY_PATH=`pwd -P`
	CR=$(printf '\r'); 
	TAB=$(printf '\t');
	calc () { 
		bc -l <<< "$@" 
}

###### STEP #2: DIR TEST.
##--Test whether current working dir is an "outfiles" sub-folder of a pyRAD assembly run.
##--If so, move forward with no changes; if not, assume script was run within the main
##--dir of a pyRAD assembly run, and cd into outfiles folder.
MY_OUTFILES_DIR_TEST="$(echo $MY_PATH | sed 's/.*\///g')"
if [[ "$MY_OUTFILES_DIR_TEST" -eq "outfiles"  ]]; then 
	echo "INFO      | $(date) | Path check PASSED. You're in pyRAD outfiles dir already. "
else
	echo "INFO      | $(date) | Path check FAILED. Now attempting to change into pyRAD outfiles dir... "
	cd ./outfiles
fi

###### STEPS #3 & 4: 3) USE FOR LOOP TO CALCULATE VAR SITE METRICS AND OUTPUT TO FILE, AND THEN 
## RANK LOCI BY NUMBERS OF VARIABLE AND PARSIMONY-INFORMATIVE SITES.
##--Assuming outfiles folder as pwd, run for loop to count and print to file the numbers of 
##--variable sites, and specifically parsimony-informative sites, in each SNP locus of the
##--.loci file.
	(
		echo "INFO      | $(date) | Calculating numbers of variable sites (S) and parsimony-informative sites (PIS) for SNP loci... "
		for i in $(find . -name "*.loci" -type f); do
			echo "INFO      | $(date) |      $i ";
			NUM_LINES="$(grep -h '^\/\/' "$i" | wc -l)"
#
			grep -h "^\/\/" "$i" | sed 's/\ //g; s/^\/\///g' | sed 's/[\*\-\|]*\([0-9]*\)/\1/g; s/\-//g' > "$i"_locusNos.tmp
			## for j in $(seq 1 $NUM_LINES); do echo "  " >> "$i"_tabs.tmp; done
			grep -h "^\/\/" "$i" | sed 's/\ //g; s/\/\///g; s/\|//g; s/[0-9]*//g' > "$i"_varSites.tmp
			awk '{ print length($0); }' "$i"_varSites.tmp > "$i"_varSites.txt
			sed 's/\-//g' "$i"_varSites.tmp > "$i"_parsInformSites.tmp
			awk '{ print length($0); }' "$i"_parsInformSites.tmp > "$i"_parsInformSites.txt
#
			paste "$i"_locusNos.tmp "$i"_varSites.txt "$i"_parsInformSites.txt > "$i"_summTable.tmp
			echo locus > locus.tmp; echo varSites > varSites.tmp; echo parsInfSites > parsInfSites.tmp;
#		
			## OUTPUT S AND PIS ESTIMATES TO FILES.
			echo "INFO      | $(date) | Writing regular (unsorted) results to summary text files... "
			## 3-column summary file:
				paste locus.tmp varSites.tmp parsInfSites.tmp > header.tmp
				cat header.tmp "$i"_summTable.tmp > "$i"_varSitesSummary.txt
			## 2-column var sites (S) file:
				paste locus.tmp varSites.tmp > Sheader.tmp
				paste "$i"_locusNos.tmp "$i"_varSites.txt > "$i"_varSitesTable.tmp
				cat Sheader.tmp "$i"_varSitesTable.tmp > "$i"_S_table.txt
			## 2-column parsimony-informative sites (PIS) file:
				paste locus.tmp parsInfSites.tmp > PISheader.tmp
				paste "$i"_locusNos.tmp "$i"_parsInformSites.txt > "$i"_parsInfSitesTable.tmp
				cat PISheader.tmp "$i"_parsInfSitesTable.tmp > "$i"_PIS_table.txt		
			## Make ranked/sorted S and PIS table files:
			echo "INFO      | $(date) | Ranking loci by number of variable and parsimony-informative sites, and writing tables with ranked loci... "
				sort -nrk2 "$i"_varSitesTable.tmp > Ssorted.tmp
				cat Sheader.tmp Ssorted.tmp > "$i"_S_table-ranked.txt
				sort -nrk2 "$i"_parsInfSitesTable.tmp > PISsorted.tmp
				cat PISheader.tmp PISsorted.tmp > "$i"_PIS_table-ranked.txt
#
			rm ./*.tmp
			rm ./"$i"_varSites.txt
			rm ./"$i"_parsInformSites.txt
		done
	)


echo "INFO      | $(date) | Done calculating numbers of variable sites in pyRAD .loci file(s) and ranking SNP loci by variability. "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
