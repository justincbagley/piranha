#!/usr/bin/python3

# ElConcatenero v2.0.4
# Author: Diogo N Silva
# Last update: 11/04/2012
# ElConcatenero is tool to convert and concatenate several commonly used data format types. Currently, supported input formats include Nexus, FastA and Phylip. Output may be in Nexus, Phylip (wiht part file for RaXML), FastA or IMa2 format. Please type "ElConcatenero -h" or read the README.md file for information on usage.

#  Copyright 2012 Diogo N Silva <diogo@arch>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not,  If not, see <http://www.gnu.org/licenses/>.

import argparse
import ElParsito


##### ARGUMENT LIST ######

parser = argparse.ArgumentParser(description="Concatenates DNA data matrices")
parser.add_argument("-g",dest="gap",default="-",help="Symbol for gap (default is '%(default)s')")
parser.add_argument("-m",dest="missing",default="n",help="Symbol for missing data (default is '%(default)s')")
parser.add_argument("-if",dest="InputFormat",default="fasta",choices=["fasta","nexus","phylip"],help="Format of the input file(s) (default is '%(default)s')")
parser.add_argument("-of",dest="OutputFormat",default="nexus",choices=["nexus","phylip","fasta","ima2"],help="Format of the ouput file (default is '%(default)s')")
parser.add_argument("-c",dest="Conversion",action="store_const",const=True,help="Used for convertion of the input files passed as arguments with the -in option. This flag precludes the usage of the -o option, as the output file name is automatically generated based on the input file name.")
parser.add_argument("-o",dest="outfile",help="Name of the output file")
parser.add_argument("-z",dest="zorro",action="store_const",const=True,help="Use this option if you wish to concatenate auxiliary Zorro files associated with each alignment. Note that the auxiliary files must have the same prefix of the alignment file, with the addition of '_zorro.out'")
parser.add_argument("-in",dest="infile",nargs="+",required=True,help="Provide the input file name. If multiple files are provided, plase separated the names with spaces")
arg = parser.parse_args()

##### FUNCTION PARAMETERS ######

# The space (in characters) available for the taxon name before the sequence begins
seq_space_nex = 10
seq_space_phy = 26
seq_space_ima2 = 10 # Required by IMa2! Changing this value will most likely break the input file 

# Cut the taxa names by the following character:
cut_space_nex = 20
cut_space_phy = 50
cut_space_ima2 = 8

# If you wish to include a whitespace (tab) between loci, set the variable to "yes", ortherwise "no".
tab_delimited_loci = "no"

##### MAIN FUNCTIONS ######

def remove_illegal (name):
	""" Function that removes illegal characters from taxa names """
	illegal_chars = [":",",",")","(",";","[","]","'"]
	clean_name = "".join([char for char in name if char not in illegal_chars])
	return clean_name

def dataset_creator(infile_list):
	initial_storage,taxa_order = ElParsito.Taxa_gather(arg.InputFormat,infile_list)
	storage,part_list,sizes,zorro_list = ElParsito.Elparsito(arg.InputFormat,initial_storage,infile_list,arg.OutputFormat,tab_delimited_loci,arg.zorro)
	return storage,part_list,sizes,taxa_order,zorro_list
	
def output_creator(output_format,storage,part_list,sizes,taxa_order,zorro,outfile):
	if output_format == "ima2":
		out_file = open(outfile+".txt","w")
		info = input("Please provide (separated by semicolon): number of populations, "
					"name of populations, population tree:\nExample: 3;pop1 pop2 pop3; "
					"((0,1):2\n>>> ")
		# Collecting information about number of populations, population names and population tree
		npops,pop_names,poptree = info.split(";")
		out_file.write("Input file for IMa2 using the following dataset(s): "+", ".join(arg.infile)+"\n"+str(npops).strip()+"\n"+pop_names.strip()+"\n"+poptree.strip()+"\n"+str(len(arg.infile))+"\n")
		for file_i in arg.infile:
			storage,part_list,sizes,taxa_order, zorro = dataset_creator(file_i.split())
			locus_info = input("Please provide (separated by semicolon): Sample size for each population in this locus ("+file_i+"), Model of evolution, Mutation rate (if available) and ploidy:\nExample:13 21 32; I; 0.00000003; 1\n>>>")
			sample_size,model,rate,ploidy = locus_info.split(";")
			out_file.write(file_i.split(".")[0]+" "+sample_size+" "+str(sizes-1)+" "+model.strip()+" "+ploidy.strip()+" "+rate.strip()+"\n")
			for key in taxa_order:
				out_file.write(key.replace(" ","_")[:cut_space_ima2].ljust(seq_space_ima2)+storage[key]+"\n")
	elif output_format == "phylip":
		out_file = open(outfile+".phy","w")
		out_file.write(str(len(storage))+" "+str(sizes-1)+"\n")
		for key in taxa_order:
			clean_key = remove_illegal(key) # Removes illegal characters from the taxon name
			if arg.Conversion == None:
				out_file.write(clean_key.replace(" ","_")[:cut_space_phy].ljust(seq_space_phy)+" "+storage[key]+"\n")
				part_file = open(outfile.split(".")[0]+"_part.File","a")
				part_file.write("".join(part_list))
			else:
				out_file.write(clean_key.replace(" ","_")[:cut_space_phy].ljust(seq_space_phy)+" "+storage[key]+"\n")

	elif output_format == "nexus":
		out_file = open(outfile+".nex","w")
		if arg.Conversion:
			out_file.write("#NEXUS\n\nBegin data;\n\tdimensions ntax="+str(len(storage))+" nchar="+str(sizes-1)+";\n\tformat datatype=DNA interleave=no gap="+arg.gap+" missing="+arg.missing+";\n\tmatrix\n")
		else:
			partition_str = "".join(part_list)
			out_file.write("#NEXUS\n\nBegin data;\n\tdimensions ntax="+str(len(storage))+" nchar="+str(sizes-1)+";\n\tformat datatype=mixed ("+"".join(part_list)[:-1]+") interleave=no gap="+arg.gap+" missing="+arg.missing+";\n\tmatrix\n")
		for key in taxa_order:
			out_file.write(key.replace(" ","_")[:cut_space_nex].ljust(seq_space_nex)+" "+storage[key]+"\n")
		out_file.write("\t;\nend;")
	elif output_format == "fasta":
		out_file = open(outfile+".fas","w")
		for key in taxa_order:
			out_file.write(">"+key.replace(" ","_")+"\n"+storage[key]+"\n")
	# Zorro implementation
	if zorro != []:
		zorro_outfile = open(outfile+"_zorro.out","w")
		for i in zorro:
			zorro_outfile.write("%s\n" % (i))
				
##### EXECUTION ######
				
if arg.Conversion:
	for file_i in arg.infile:
		if arg.InputFormat == arg.OutputFormat:
			output_code = file_i.split(".")[0]+"_2"
		else:
			output_code = file_i.split(".")[0]
		storage,part_list,sizes,taxa_order,zorro = dataset_creator(file_i.split())
		output_creator(arg.OutputFormat,storage,part_list,sizes,taxa_order,zorro,output_code)
else:
	if arg.outfile == None:
		print ("\nOooops!\n>>>If you wish to concatenate, please provide an output file name with the -o option\n>>>If you wish to convert multiple sequences, please use the -c flag\n")
		raise SystemExit
	storage,part_list,sizes,taxa_order,zorro = dataset_creator(arg.infile)
	output_creator(arg.OutputFormat, storage, part_list, sizes, taxa_order, zorro, arg.outfile)
