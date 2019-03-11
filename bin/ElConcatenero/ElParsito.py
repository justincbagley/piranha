#!/usr/bin/python3
# Author: Diogo N. Silva
# Version: 1.3.0
# Last update: 30/07/12
# ElParsito.py is a python module with fuctions that can parse genetic data files in FastA, Phylip and Nexus to another format that can be easily used by other software. It also includes some quality checks such as, checking for duplicated taxon names and unequal sequence lenghts.

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

import re
import sys
import subprocess

def loading (current_state,size,prefix,width,suffix):
	""" Function that prints the loading progress of the script """
	percentage = int(((current_state+1)/size)*100)
	complete = int(width*percentage*0.01)
	if percentage == 100:
		sys.stdout.write("\r%s [%s%s] %s%% -- Done!%s\n" % (prefix,"#"*complete,"."*(width-complete),percentage," "*100))
	else:
		sys.stdout.write("\r%s [%s%s] %s%% (%s)" % (prefix,"#"*complete,"."*(width-complete),percentage,suffix))
	sys.stdout.flush()

def size_check(dic,i_file):
	""" Function to test whether all sequences are of the same size and, if not, which are different """
	# Determine the most common length 
	commonSeq = max(set([v for v in dic.values()]),key=[v for v in dic.values()].count)
	# Creates a dictionary with the sequences, and respective length, of different length
	difLength = dict((key,value) for key, value in dic.items() if len(commonSeq) != len(value))
	if difLength != {}:
		print ("\n Unequal sequence lenght detected in %s for the following taxa" % i_file)
		raise SystemExit


def zorro2rax (zorro_infile, zorro_storage):
	""" Function that converts the floating point numbers contained in the original zorro output files into intergers that can be interpreted by RAxML """
	for i in zorro_infile:
		number = float(i.strip())
		int_number = round(number)
		zorro_storage.append(int_number)
	return zorro_storage

def Taxa_gather (Elformat,infile_list):
	""" Function to gather the taxa names of all input files as keys of a dictionary. Must be performed before the ElParsito function in order to complete the dictionary keys over all input files. Returns a dictionary with the complete set of keys and empty values, and a list of taxa to maintain taxa order in subsequent functions """
	storage,taxa_order = {},[]
	for file_i in infile_list:
		file_r = open(file_i,"r")
		x = 1
		if "phylip" in Elformat:
			next(file_r)
			for line in file_r:
				if 	line.strip() != "":
					info = line.split()
					storage[info[0]] = ""
					if info[0] not in taxa_order:
						taxa_order.append(info[0])
		elif "fasta" in Elformat:
			for line in file_r:
				if line.startswith(">") and line.strip() != "":
					tx_id = line[1:].rstrip()
					storage[tx_id] = ""
					if tx_id not in taxa_order:
						taxa_order.append(tx_id)
		elif "nexus" in Elformat:
			for line in file_r:
				if "matrix" in line.lower() and x == 1:
					x += 1
				elif ";" in line and x == 2:
					x = 1
				elif x == 2 and line.strip() != "":
					line_s = line.split()
					storage[line_s[0]] = ""
					if line_s[0] not in taxa_order:
						taxa_order.append(line_s[0])
	return storage,taxa_order

def Elparsito(Elformat, storage, infile_list, outputFormat,tab_delimited_loci="no", zorro=None):
	""" Function to populate a dictionary with taxa names as keys and their corresponding sequence as values. Returns a complete dictionary, a list of partitions and the total sequence size. """
	""" The new argument 'tab_delimited_loci' can be set to True when the user wants to separate loci with whitespace (Tab is used here). This is usefull for some programs such as Arlequin """
	part_list,sizes,cur_file = [],1,0
	zorro_storage = []
	for file_i in infile_list:
		counter = 0
		#loading (cur_file, len(infile_list), "Processing alignments", 50, "Processing file %s" % (file_i,))
		temp_storage, x = {}, 1
		file_r = open(file_i,"r")
		### Zorro implementation
		if zorro == True:
			file_prefix = file_i.split(".")[0]
			zorro_file = open(file_prefix+"_zorro.out")
			zorro_storage = zorro2rax(zorro_file,zorro_storage)
		if "phylip" in Elformat and counter == 0:
			for line in file_r:
				## Collects information on the number of taxa and locus size that are found on the first line of the file ##
				if x == 1:
					seq_size = line.split()[0]
					x += 1
					if "phylip" in outputFormat and len(infile_list) > 1:
						part_list.append("DNA, "+file_i.split(".")[0]+" = "+str(sizes)+"-"+str(sizes+int(seq_size)-1)+"\n")
					elif "nexus" in outputFormat and len(infile_list) > 1:
						part_list.append("DNA:"+str(sizes)+"-"+str(sizes+int(seq_size)-1)+",")
					sizes += int(seq_size)
					
				## Collects information about the taxa name (info[0]) and respective sequence (info[1]) and stores it in a dictionary. There is no withspace separating loci ##
				elif x == 2 and line.strip() != "" and tab_delimited_loci == "no":
					info = line.split()
					if info[0] in storage.keys():
						storage[info[0]] += info[1]
						temp_storage[info[0]] = info[1]
						
				## Collects information about the taxa name (info[0]) and respective sequence (info[1]) and stores it in a dictionary. A "Tab" whitspace is included at the beginning of each locus, except for the first one ##
				elif x == 2 and line.strip() != "" and tab_delimited_loci == "yes":
					info = line.split()
					if info[0] in storage.keys():
						if storage[info[0]] == "":
							storage[info[0]] += info[1]
							temp_storage[info[0]] = info[1]
						elif storage[info[0]] != "":
							storage[info[0]] += "\t"+info[1]
							temp_storage[info[0]] = info[1]
							
			## Checks if all keys (taxa) in the initial "storage" dictionary are present in the current file. If not, missing data is added for those taxa ## 
			for key in storage.keys():
				if key not in temp_storage.keys():
					if tab_delimited_loci == "no":
						storage[key] += "n"*int(seq_size)
					elif tab_delimited_loci == "yes" and storage[key] != "":
						storage[key] += "\t"+"n"*int(seq_size)
					elif tab_delimited_loci == "yes" and storage[key] == "":
						storage[key] += "n"*int(seq_size)
			
			counter = 1
			### Zorro implementation for phylip input format
					
					
		elif "fasta" in Elformat and counter == 0:
			for line in file_r:
				## When lines start with the character ">" the name of the current taxon is associated with the "id_name" variable ##
				if line.startswith(">") and line.strip() != "" and tab_delimited_loci == "no":
					id_name = line[1:].rstrip()
					temp_storage[id_name] = ""
					
				## If the the tab_delimited_loci argument is set to "yes", besides associating the taxon name with the "id_name" variable, a "Tab" is added at the begginig of the current sequence (if the corresponding dictionary value is not empty) ##
				elif line.startswith(">") and line.strip() != "" and tab_delimited_loci == "yes":
					id_name = line[1:].rstrip()
					temp_storage[id_name] = ""
					if storage[id_name] != "":
						storage[id_name] += "\t"
				elif line.strip() != "":
					line = line.replace(" ","") # Patch for files from Gblocks, which come with whitespaces within each line
					storage[id_name] += line.strip()
					temp_storage[id_name] += line.strip()
			for i in temp_storage.values():
				seq_size = len(i)
			
				
			## Creates lists for phylip and nexus output formats containing the the size, range and ID of the current partition ##
			if "phylip" in outputFormat and len(infile_list) > 1:
				part_list.append("DNA, "+file_i.split(".")[0]+" = "+str(sizes)+"-"+str(sizes+int(seq_size)-1)+"\n")
			elif "nexus" in outputFormat and len(infile_list) > 1:
				part_list.append("DNA:"+str(sizes)+"-"+str(sizes+seq_size-1)+",")
			sizes += int(seq_size)
			
			## Checks if all keys (taxa) in the initial "storage" dictionary are present in the current file. If not, missing data is added for those taxa ## 
			for key in storage.keys():
				if key not in temp_storage.keys():
					if tab_delimited_loci == "no":
						storage[key] += "n"*int(seq_size)
					elif tab_delimited_loci == "yes" and storage[key] != "":
						storage[key] += "\t"+"n"*int(seq_size)
					elif tab_delimited_loci == "yes" and storage[key] == "":
						storage[key] += "n"*int(seq_size)
			
			counter = 1		
					
		elif "nexus" in Elformat and counter == 0:
			nchar = "nchar=[0-9]*[0-9]"
			nchar_regex = re.compile(nchar)
			temp_storage = {}
			for line in file_r:
				## Parses the header of a Nexus file to collect information about the sequence size (seq_size) ##
				if "nchar" and "ntax" in line.lower():
					seq_size = nchar_regex.findall(line.lower())
					seq_size = "".join(seq_size)
					seq_size = seq_size[6:]
					
					## Uses the information on the current sequence size to create lists for phylip and nexus output formats containing the the size, range and ID of the current partition ##
					if "phylip" in outputFormat and len(infile_list) > 1:
						part_list.append("DNA, "+file_i.split(".")[0]+" = "+str(sizes)+"-"+str(sizes+int(seq_size)-1)+"\n")
					elif "nexus" in outputFormat and len(infile_list) > 1:
						part_list.append("DNA:"+str(sizes)+"-"+str(sizes+int(seq_size)-1)+",")
					sizes += int(seq_size)
				elif "matrix" in line.lower() and x == 1:
					x += 1
				elif ";" in line and x == 2:
					x = 1
				elif x == 2 and line.strip() != "":
					line_s = line.split()
					seq = "".join(line_s[1:])
					storage[line_s[0]] += seq
					temp_storage[line_s[0]] = ""
					temp_storage[line_s[0]] += seq
			for key in storage.keys():
				if key not in temp_storage.keys() and tab_delimited_loci == "no":
					storage[key] += "n"*int(seq_size)
				elif key not in temp_storage.keys() and tab_delimited_loci == "yes":
					storage[key] += "n"*int(seq_size)+"\t"
				elif storage[key] in temp_storage.keys() and tab_delimited_loci == "yes":
					storage[key] += "\t"
			counter = 1
		cur_file += 1
		file_r.close()
		#size_check(temp_storage,file_i)
	return storage, part_list, sizes, zorro_storage
