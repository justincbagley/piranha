#!/usr/bin/perl

my $usage="Usage: $0 [-g] [-n replacementChar] [-x n] [-s siteList] [-f siteListFile] [-r [1,2,3]] [-cd] [-i splicingData] fastaFile\n" .
    " -g : replace unwanted sites with - instead of removing them\n" .
    " -n : replace unwanted sites with replacementChar\n" .
    " -x n: Remove all gap sites after sites are selected.  If n=1, all\n".
    "     gap-only-sites are removed.  If n=3, the gap-only-sites are\n".
    "     removed by multiple of n(=3).  With 7 neighboring gap-only sites,\n".
    "     6 of them will be removed, and 1 site will be left. n can be any integer.\n".
    " -s : specify the site lists, do not put any spaces between elements\n" .
    "     example siteList : 1-4,8,90-\n" .
    " -r '1,2' : first and 2nd position of the codon triplets are selected\n". 
    " -f : read site list from a file.\n".
    " -c : site list is codon number\n" .
    " -i : individual splicing data for each sequences are given\n" .
    " -e : with -i, sequence not listed in the splicingData is excluded\n" .
    " -d : delete (instead of select) the sites specified\n" .
    "\n".
    " For -f option, you can use spaces, tab, comma, or new-line delimited\n".
    " site numbers. You can use the range specifiers (see -s), but be\n".
    " CAREFUL not to use spaces around '-'; e.g. 1-4 is ok, but 1 - 4 is not.\n".
    " In this file, you can also add comments. For each line, any characters\n".
    " after the 1st # is considered as comments and ignored.\n".
    " Example of site list file:\n\n" .
    "# This file can be given to -f\n".
    "  1-4,     8  # COMMENT: first 5 bases\n".
    "90-\n".
    "# end of file\n";

my $sep = "\t";  # if you use tab in the sequence name, change this to
                 # other characters such as ","
my $lineWidth = 70; # used to break the long sequences into lines for FASTA out

use Getopt::Std;
getopts('hx:i:ecgn:df:s:r:') || die "$usage\n";

if (defined($opt_h)) {
    die "$usage\n";
}

die "$usage\n" if (@ARGV > 1);

@ARGV = ('-') unless @ARGV; # take STDIN when no arg.
my $dnaFile = shift @ARGV;

# initialize the @seqArray, @seqNameArray, and $maxSeqLen
my @dat = ReadInFASTA($dnaFile);
my $numSeq = @dat;
my $maxLen = MaxSeqLen(@dat);

if (defined($opt_c)) {
    $maxLen = int (($maxLen + 2) / 3);
}

my $replaceChar = "-"; # for -g, this character is used to replace
if (defined($opt_g) && defined($opt_n)) {
    die "ERROR: -g and -n can not be specified simultaneously.  ".
	"Choose either -g or -n";
} elsif (defined($opt_g)) {
    $replaceChar = '-';
} elsif (defined($opt_n)) {
    $replaceChar = $opt_n;
}

if (defined($opt_i)) {
    my @result = Splice(@dat);
    PrintFASTA(@result);
    exit (0);
}

if (defined($opt_r)) {
    if (defined($opt_s) || defined($opt_f) || defined($opt_c)) {
	die "When -r is specified, -c, -f, or -s can't be used\n";
    }
    @index = RepeatIndex($maxLen, $opt_r);
} elsif (defined($opt_s)) {
    if (defined($opt_f)) {
	die "-s and -f can't be used at the same time\n";
    }
    @index = MkSelIndex($maxLen, $opt_s);
} elsif (defined($opt_f)) {
    @index = MkIndexFromFile($maxLen, $opt_f);
} else {
    @index = 0..($maxLen - 1);
}


if (defined($opt_d))  {
    @allSites = 0..($maxLen - 1) ;
    @index = InANotInB (\@allSites, \@index);
}

if (defined($opt_c)) {
    @index = CodonToBaseIndex(@index);
}
# @dat = AdjustSeqLength(@dat);

@index = sort {$a <=> $b} (@index);
@index = ExtractUnique (@index);

@dat = Sites (\@dat, \@index);

if (defined ($opt_x)) {
    @dat = RemoveGapOnlySites(\@dat, $opt_x);
}

PrintFASTA (@dat);

exit(0);

#### functions

sub RepeatIndex {
    my ($max, $optionR) = @_;
    $optionR =~ s/\s+//g;
    if ($optionR !~ /^[123,]+$/) {
	print STDERR "$usage";
	die "\nERROR: give comma delimited integer (1, 2, or 3) as the " .
	    " argument of -r.\ne.g. -r '2,3'\n";
    }
    my @repList = split (",", $optionR);
    my @result = ();
    for my $i (1..$max) {
	if (MemberQ(($i - 1) % 3 + 1, \@repList) == 1) {
	    push @result, $i-1;
	}
    }
    return(@result);
}

sub MkSelIndex {
    my ($max, $siteList) = @_;
    $siteList =~ s/^\s+//;
    $siteList =~ s/\s+$//;

    my @sites = split(/\s*,\s*/, $siteList);

    my @result = ();
    foreach my $item (@sites) {
	if ($item =~ /^(\d+)-(\d+)$/) {
	    die "ERROR: 1st number is larger than 2nd in $item\n" if ($1 > $2);
	    $beginPos = $1 - 1;
	    $endPos = $2 - 1;
	} elsif ($item =~ /^-(\d+)$/) {
	    $beginPos = 0;
	    $endPos = $1 - 1;
	} elsif ($item =~ /^(\d+)-$/) {
	    $beginPos = $1 - 1;
	    $endPos = $max-1;
	} elsif ($item =~ /^(\d+)$/) {
	    $beginPos = $1 - 1;
	    $endPos = $1 - 1;
	} else {
	    die "$siteList given as the list of sites.  " . 
		"Make sure it is comma delimitted, and each element is " .
		    " one of the forms: 23-26, 29, -10, 40-\n";  
	}
	push (@result, $beginPos..$endPos);
    }
    return(@result);
}

sub MkIndexFromFile {
    my ($max, $file) = @_;
    open (IN,"<$file") || die "Can't open the file $file\n";
    my @result=();
    while(<IN>) {
	chomp();
	s/#.*$//;  # remove comments
	
	s/^\s+//; s/\s+$//;
	next if (/^$/);
	s/,/\t/g;  # convert commans to tab
	s/\s+/\t/g;
	unless(/^[\d\t-]+$/) {
	    warn "This line contains non-numeric, skipped:\n$_\n";
	    next;
	}
	my @line = split;
	push @result, @line;
    }
    my $siteString = join ",", @result;
    @result = MkSelIndex($max, $siteString);
    
    # change unit offset index to 0-offset.
#    for $i (0..$#result) {
#	if ($max < $i) {
#	    warn "site $i is too large.  should be less than $max\n";
#	}
#	$result[$i] -= 1;
#    }
    return @result;
}

# convert codon index (0 offset) to nucleotide index (0 offset)
sub CodonToBaseIndex {
    my @list = @_;
    my @result=();
    for my $i (@list) {
	push (@result, $i*3, $i*3+1, $i*3+2);
    }
    return (@result);
}

# takes an arg; name of a file from which data are read Then read in
# the data and make an array.  Each element of this array corresponds
# to a sequence, name tab data.
sub ReadInFASTA {
    my $infile = shift;
    my @line;
    my $i = -1;
    my @result = ();
    my @seqName = ();
    my @seqDat = ();

    open (INFILE, "<$infile") || die "Can't open $infile\n";

    while (<INFILE>) {
        chomp;
        if (/^>/) {  # name line in fasta format
            $i++;
            s/^>\s*//; s/^\s+//; s/\s+$//;
            $seqName[$i] = $_;
            $seqDat[$i] = "";
        } else {
            s/^\s+//; s/\s+$//;
	    s/\s+//g;                  # get rid of any spaces
            next if (/^$/);            # skip empty line
            s/[uU]/T/g;                  # change U to T
            $seqDat[$i] = $seqDat[$i] . uc($_);
        }

	# checking no occurence of internal separator $sep.
	die ("ERROR: \"$sep\" is an internal separator.  Line $. of " .
	     "the input FASTA file contains this charcter. Make sure this " . 
	     "separator character is not used in your data file or modify " .
	     "variable \$sep in this script to some other character.\n")
	    if (/$sep/);

    }
    close(INFILE);

    foreach my $i (0..$#seqName) {
	$result[$i] = $seqName[$i] . $sep . $seqDat[$i];
    }
    return (@result);
}

sub GetSeqDat {
    my @data = @_;
    my @line;
    my @result = ();

    foreach my $i (@data) {
	@line = split (/$sep/, $i);
	push @result, $line[1];
    }

    return (@result)
}

sub GetSeqName {
    my @data = @_;
    my @line;
    my @result = ();

    foreach my $i (@data) {
	@line = split (/$sep/, $i);
	push @result, $line[0];
    }
    return (@result)
}

sub SelectSites {
    my ($arrayRef, $indexRef) = @_;
    unless (@_ == 2 && ref($arrayRef) eq 'ARRAY' && ref($indexRef) eq 'ARRAY'){
	die "args to SelectSites() should be ARRAY REF, ARRAY REF\n";
    }

    my $maxIndex = @$arrayRef -1;
    my @result = ();
    foreach my $posi (@$indexRef) {
	if ($maxIndex < $posi) {
	    push @result, "?";
	} else {
	    push @result, $$arrayRef[$posi];
	}
    }
    return @result;
}

# 1st argument is a ref to an array with each element is a DNA sequence
# a ref to a vector of indices.
sub ReplaceOtherSitesWChar {
    my ($arrayRef, $indexRef, $repChar) = @_;
    unless (@_ == 3 && ref($arrayRef) eq 'ARRAY' && ref($indexRef) eq 'ARRAY'){
	die "args to ReplaceOtherSitesWChar() should be ARRAY REF, ARRAY REF\n";
    }

    my $maxIndex = @$arrayRef -1;

    my @allSites = 0..($maxIndex) ;
    my @index = InANotInB (\@allSites, $indexRef);  # making the complement set

    warn "WARN: some selected sites don't exists\n" 
	if (Max(@$indexRef) > $maxIndex);

    my @result = @$arrayRef;
    foreach my $posi (@index) {
	$result[$posi] = $repChar;
    }
    if ($debug) {
	print join "", "debug: ", @$arrayRef, "\n";
	print join "", "debug: ", @result, "\n\n";
    }
    return @result;
}

sub Sites {
    my ($datRef, $indexRef) = @_;
    my @seqDat = GetSeqDat(@$datRef);
    my @seqName = GetSeqName(@$datRef);
    my @result = ();

    # make 2 dimensional matrix
    foreach $seqNumber (0..$#seqDat) {
	my @tmpArray = split(//, $seqDat[$seqNumber]);
	my @thisSeq = (defined($opt_g) || defined($opt_n)) ? 
	    ReplaceOtherSitesWChar(\@tmpArray, $indexRef, $replaceChar) : 
		SelectSites(\@tmpArray, $indexRef);
	my $thisLine = $seqName[$seqNumber] . "\t" . (join("", @thisSeq));
	push @result, $thisLine;
    }
    return (@result);
}


sub PrintFASTA {
    my @seqName = GetSeqName(@_);
    my @seqDat = GetSeqDat(@_);
    for my $i (0..$#seqDat) {
	# print ">$seqName[$i]\n$seqDat[$i]\n";
        print ">$seqName[$i]\n";
        my $seq = $seqDat[$i];
        for (my $pos=0 ; $pos < length ($seq) ;  $pos += $lineWidth) {
            print substr($seq, $pos, $lineWidth), "\n";
        }
    }
}

sub MaxSeqLen {
    my @data = GetSeqDat(@_);
    my $maxLen = 0;
    foreach $i (@data) {
	my $len = CharLen($i);
	$maxLen = $len if ($len > $maxLen);
    }
    return ($maxLen);
}

# take std seq data (name\tseq), and attach "?" for the shorter sequences
sub AdjustSeqLength {
    my @data = @_;
    my @seqDat = GetSeqDat(@_);
    my @seqName = GetSeqName(@_);
    my $maxLen = MaxSeqLen(@_);
    
    foreach $i (0 .. $#seqDat) {
	my $thisLen = CharLen ($seqDat[$i]);
	if ($thisLen == $maxLen)  {
	    ; # do nothing
	} elsif ($thisLen < $maxLen) {
	    my $diff = $maxLen - $thisLen;
	    warn "WARN: $seqName[$i] shorter.  " .
		"$diff '?' (missing character) were added at the end\n";
	    for ($j=0; $j < $diff; $j++) {
		$data[$i] = $data[$i] . "?";
	    }
	} else {
	    die "ERROR: the length of sequence $seqName[$i] is $thisLen, " .
		"longer than \$maxLen = $maxLen.  Weird!!";
	}
    }
    return (@data);
}

sub RemoveGapOnlySites {
    my ($seqDatARef, $multipleOf) = @_;
    my @seqDat = GetSeqDat(@$seqDatARef);
    my @seqName = GetSeqName(@$seqDatARef);
    my $maxLen = MaxSeqLen(@$seqDatARef);
    my @gapSites = ();
    my @notGapSites = ();
    my ($posi, $seqNumber);
    my @seqMat = ();

    # make 2 dimensional matrix
    foreach $seqNumber (0..$#seqDat) {
	my @tmpArray = split(//, $seqDat[$seqNumber]);
	# Check the length
	if (@tmpArray != $maxLen)  {
	    die "ERROR: the sequence $seqName[$i] is not same length " .
		"as \$maxLen = $maxLen.  Weird!!";
	}
	push @seqMat, [ @tmpArray ];
    }

    # now identify the all gap sites
    for $posi (0 .. ($maxLen-1)) {
	my $gap = 1;
	for $seqNumber (0 .. $#seqMat){
	    if ($seqMat[$seqNumber][$posi] !~ /^[-\?]$/) {
		$gap = 0;
		last;
	    }
	}
	if ($gap == 1) {  # all sequences have a gap at these sites
	    push (@gapSites, $posi+1); # now unit-offset
	} else {          # there are some non-gap character at these sites
	    push (@notGapSites, $posi+1);
	}
    }

    my @rmSites = ();  # removing multiples of $multipleOf
    for(my $i = 0; $i < @gapSites - $multipleOf + 1; $i++) {
	my $rmFlag = 1;
	for(my $j = 1; $j < $multipleOf; $j++) {
	    if ($gapSites[$i] + $j != $gapSites[$i+$j]) {
		$rmFlag = 0;     # we don't want to remove this $i
		$j=$multipleOf;  # get out of inner loop
	    }
	}
	if ($rmFlag == 1) {
	    push @rmSites, @gapSites[$i..($i+$multipleOf-1)];
	    $i += $multipleOf - 1;
	}
    }
    
    my @allSites = 1..($maxLen) ;
    my @selIndex = InANotInB (\@allSites, \@rmSites);
    @selIndex = To0Offset(@selIndex);  # convert to 0-ffset

    # select sites and make results
    my @result = ();
    for $seqNumber (0 .. $#seqMat) {
	my @thisSeq = SelectSites($seqMat[$seqNumber], \@selIndex);
	my $line = $seqName[$seqNumber] . $sep . (join("", @thisSeq));
	push (@result, $line);
    }

#    if (@rmSites > 0) {
#	warn ("Following sites consist of all gaps, removed from analysis\n");
#	print STDERR join(" ", @rmSites);
#	print STDERR "\n";
#    }
    return (@result);
}

# convert 1-offset index array to 0-offset array
sub To0Offset {
    my @result = map {$_ - 1} @_;
    return @result;
}

# count the number of characters in a string
sub CharLen {
    my $string = shift;
    my @charString = split (//, $string);
    return scalar(@charString);
}

# this function take two scalars and return the larger value
sub larger {
    my ($a, $b) = @_;

    return (($a > $b) ? $a : $b);
}

sub InANotInB {
    my ($aRef, $bRef) =@_;
    my %seen = ();
    my @aonly =();

    foreach my $item (@$bRef) { $seen{$item} = 1};
    foreach my $item (@$aRef) {
	push (@aonly, $item) unless $seen{$item};
    }
    return (@aonly);
}

sub ExtractUnique {
    my %seen=();
    my @unique = ();

    foreach my $item (@_) {
        push (@unique, $item) unless $seen{$item}++;
    }
    return @unique;
}

sub Max {
    my $max = shift;
    foreach $item (@_) {
        if ($item > $max) {
            $max = $item;
        }
    }
    return $max;
}

sub MemberQ {
    my ($x, $arrRef) = @_;
    foreach my $item (@$arrRef) {
        if ($x eq $item) {
            return 1;
        }
    }
    return 0;
}

sub sortByColumn {
# numerical sort by a column, return an array
#    sortbyColumn ($col_num, $order, @record)
# @record is an array with each element representing a space delimited record
# example
#    ("473 p1 S     0:06 -bash", "541 p2 SW    0:00 ps-a", ....)
# $col_num -- the column by which the record is sorted by (left-most col is 0)
# $order can be "a" (ascending) or "d" (descending),
# sort column can be hyphnated numbers (e.g. 10-4-150)

    local $col_num = shift(@_);
    local $order = shift(@_);
    local @record = @_ ;
    local ($sortCol);
    
    ## test if the sort column is hyphnated or plain number
    local $sortMethod = "number";
    foreach $sortCol (@record) {
	if ( (split(/\s+/,$sortCol))[$col_num] =~ /\d+-\d+/ ) {
	    $sortMethod = "hyphnated";
	    last ;
	}
    }

    return sort $sortMethod @record;

## two sub-sub-routines
    sub number {
	# $col_num, $order are the given arguments
	# the left-most column is 0 
	local $first = (split(/\s+/, $a))[$col_num];
	local $second = (split(/\s+/, $b))[$col_num];
# argument errors not well trapped here
	($first,$second) = ($second, $first) if ($order eq "d");
	
	return ($first <=> $second);
    }

#probably I don't need the "sub number"
    sub hyphnated {
	# $col_num, $order are the given arguments
	local ($each_number, $cmp_result, @temp_swap);

	## separte the hyphnated numbers and put them in the following arrays
        local @first = split(/-/, ((split(/\s+/, $a))[$col_num]));
	local @second = split(/-/, ((split(/\s+/, $b))[$col_num]));

	## ascending (default) or descending order
	if ($order eq "d") {
	    @temp_swap = @first;
	    @first = @second;
	    @second = @temp_swap;
	}
	
	## comparison of array elements
	for ($each_number = 0; $each_number <=
	     (($#first < $#second) ? $#first : $#second) ; $each_number++) {
	    $cmp_result = ($first[$each_number] <=> $second[$each_number]);
	    last if ($cmp_result);
	}

	## if the size of two arrays differ
	if ( ($cmp_result == 0) && ($#first != $#second) ) {
	    return (($#first < $#second) ? -1 : 1);
	} else {
	    return $cmp_result;
	}
    }
}


#### not used
sub Bootstrap {
    my @data = @_;
    my @seqDat = GetSeqDat(@_);
    my @seqName = GetSeqName(@_);

    my $maxLen = MaxSeqLen(@data);
    my ($tmpOutFile, $tmpSeqFileName);

    # getting tmpfilenames
    do { $tmpSeqFileName = tmpnam() }
    until my $fh = IO::File->new($tmpSeqFileName, O_RDWR|O_CREAT|O_EXCL);
    close $fh;
    do { $tmpOutFile = tmpnam() }
    until $fh = IO::File->new($tmpOutFile, O_RDWR|O_CREAT|O_EXCL);
    close $fh;

    print "$tmpSeqFileName\n$tmpOutFile\n";

#    END { unlink($tmpSeqFileName) 
#	      or die "Couldn't unlink $tmpSeqFileName : $!" }
#    END { unlink($tmpOutFile) or die "Couldn't unlink $tmpOutFile : $!" }

    # prepare PAUP cmd
    if (defined($opt_p)) {
	$setting = $opt_p;
    } else {
	$setting = "set criterion=distance; dset distance=k2p";
    }
    my $paupCmd = "execute $tmpSeqFileName; $setting; " .
	"log start file=$tmpOutFile replace=yes ; showdist; " .
	    "log stop; quit WarnTSave=no;";
    warn "PAUP commands:\n$paupCmd\n";

    my @sampledDat = SampleSites($maxLen, @seqDat);
    WriteNEXUS ($tmpSeqFileName, \@seqName, \@sampledDat);
    
    open (PAUP, "|paup -n");
    print PAUP $paupCmd;
    close(PAUP);

    if (defined ($opt_s)) {
	open (GETDIST, "$EXTRACT_PAIR_DIST_EXE -s $opt_s $tmpOutFile|");
    } else {
	open (GETDIST, "$EXTRACT_PAIR_DIST_EXE $tmpOutFile|");
    }
    my @dist =();
    while(<GETDIST>) {
	my @line = split;
	if ($. == 1) {
	    if ($line[$#line] ne "dist") {
		warn "## WARN ## using the last column ($line[$#line]) of " .
		    "output from $EXTRACT_PAIR_DIST_EXE as the distance\n"; 
	    }
	}
	push @dist, $line[$#line];
    }

#    if (@dist != @seqName * (@seqName - 1) / 2) {
#	warn "## DANGER ## PAUP didn't out put correct number of " .
#	    "pairwise dists\n"
#    }

}

# set criterion=distance;dset distance=TamNei Rates=gamma  Shape=2.3333  Pinvar=0.1300
#echo "execute ../$(IN_BASENAME).nx;set criterion=distance;dset distance=TamNei Rates=gamma  Shape=2.3333  Pinvar=0.1300; log start file=$@.tmp; showdist; log stop;quit WarnTSave=no;" |paup
#        $(EXTRACT_PAIR_DIST) -s seqNames $@.tmp > $@

# note this function take only @seqDat 
sub SampleSites {
    my $maxLen = shift;
    my @seqDat = @_;

    my @randSites = RandIntArray($maxLen, $maxLen-1);

    for my $seqNumber (0 .. $#seqDat) {
	my @line = split (//, $seqDat[$seqNumber]);
	@line = SelectSites (\@line, \@randSites);
	my $randomized = join ("", @line);
	push @result, $randomized;
    }
    return (@result);
}

# rand integers between 0 and $max (both ends inclusive)
sub RandIntArray {
    my ($size, $max) = @_;
    my @result = ();

    for my $i (0 .. $size - 1) {
	push @result, int(rand ($max + 1));  # rand returns [0, $max + 1)
    }
    return (@result);
}

sub WriteNEXUS {
    my ($fileName, $nameArrayRef, $datArrayRef) = @_;

    my @nameArray = @$nameArrayRef;
    my @datArray = @$datArrayRef;
    die "Error in WriteNEXUS\n" if (@nameArray != @datArray);
    my $numSeq = @nameArray;
    my $seqLen = CharLen($datArray[0]);

    my $type = "nucleotide";
    if (defined ($opt_a)) {
	$type = "aminoacid";
    }

    open (FP, ">$fileName") || die "Can't open a tmpFile $fileName";

    print FP "#NEXUS\nBegin data;\n" .
	"    Dimensions ntax=$numSeq nchar=$seqLen;\n" .
	    "    Format datatype=$type gap=- missing=? matchchar=.;\n" .
		"    Matrix\n";

    for my $i (0 .. $numSeq - 1) {
	print FP "\'$nameArray[$i]\' $datArray[$i]\n";
    }
    print FP "    ;\nEnd;\n";

    close(FP);
    return (0);
}

### for splicing
sub Splice {
    my @dat = @_;
    my @seqDat = GetSeqDat(@dat);
    my @seqName = GetSeqName(@dat);
	
    open SPLICE, "<$opt_i" || die "Can't open $opt_i\n";
    my %splice = ReadSplicingData(\*SPLICE);
    close (SPLICE);

#    for $k (keys (%splice)) { print "debug: $k => $splice{$k}\n"; };

    my @result = ();
    for my $i (0..$#seqName) {
	my $name = $seqName[$i];
	if (exists ($splice{$name})) {
	    my $len = CharLen($seqDat[$i]);
	    if (defined($opt_c)) {
		$len = int (($len + 2) / 3);
	    }
	    my @index = MkSelIndex($len, $splice{$name});
	    if (defined($opt_d))  {  # delete the selected sites
		my @allSites = 0..($maxLen - 1) ;
		@index = InANotInB (\@allSites, \@index);
	    }
	    my @tmpDat = ($dat[$i]);
	    @tmpDat = Sites(\@tmpDat, \@index);
	    push @result, @tmpDat[0];
	} else {
	    if (! defined ($opt_e)) {
		push @result, $dat[$i];
	    }
	}
    }
    return(@result);
}

sub ReadSplicingData {
    my $fh = shift;
    my %splice = ();
    while(<$fh>) {
	chomp;
	s/^\s+//; s/\s+$//;
	s/#.*$//;
	next if (/^$/);
	my @line = split (/\t/);
	$splice{$line[0]} = $line[1];
    }

    foreach my $key  (keys(%splice)) {
	print STDERR "INFO: $key => $splice{$key}\n";
    }
    return(%splice);
}
