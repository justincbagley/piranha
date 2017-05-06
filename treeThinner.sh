#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                           treeThinner v1.0, November 2016                              #
#   SHELL SCRIPT FOR DOWNSAMPLING ("THINNING") TREES IN MRBAYES .T FILES SO THAT THEY    #
#   CONTAIN EVERY NTH TREE                                                               #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: November 17, 2016. For questions, please email     #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

echo "
##########################################################################################
#                           treeThinner v1.0, November 2016                              #
##########################################################################################"

## NOTE: try to expand to multipel treefile formats in future versions.

###### A method specific to MrBayes .t trees files: 1) count the number of lines in the
## header (NEXUS top and beginning of TREES block with translated taxon names) by 
## subtracting 1 from the line on which the first ampersand occurs; 2) cut the header 
## section out of the .t file and save it; 3) working only with lines containing trees 
## (thus with ampersands or "&U"; get these lines by using grep), get every nth line of 
## the trees; and 4) paste the header, the trees, and an appropriate final 1-2 lines 
## back together as a final output .t file that has been "thinned".

### STEP #1:
read -p "Please enter the name of your MrBayes .t trees file : " MY_TFILE
read -p "Please enter the frequency (n) of nth lines that you would like to keep : " NTH_LINES

   calc () {												## Make the "handy bash function 'calc'" for subsequent use.
      bc -l <<< "$@"
}
   MY_FIRST_TREELINE=$(awk '/&U/{ print NR}' $MY_TFILE | head -n1)
   MY_NUM_HEADER_LINES="$(calc $MY_FIRST_TREELINE - 1)"

### STEP #2:
   head -n$MY_NUM_HEADER_LINES $MY_TFILE > header.txt
   ## alternatively, extracting only interior lines: ~$ sed -n <first_line>,<second_line>p filename > newfile

### STEP #3:
   grep "&U" $MY_TFILE > trees.txt
   awk 'NR == 1 || NR % '$NTH_LINES' == 0' ./trees.txt | sed '1d' > thinned_trees.txt

### STEP #4:
   echo "END;
" > ./end.txt

   cat ./header.txt ./thinned_trees.txt ./end.txt > ./nth_line_trees.t

### CLEANUP.
   rm ./header.txt
   rm ./trees.txt
   rm ./thinned_trees.txt
   rm ./end.txt 

#
#
#
######################################### END ############################################

exit 0
