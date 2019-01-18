#!/usr/bin/perl
use strict;
use Bio::SeqIO;

#pulls out trinity fasta lines based on list of headers. Headers are from transdecoder so have been slightly modified - script un-modifies
#updated to work on the newer Trinity output files, 3/26/17

my $list = $ARGV[0];
my $fasta = $ARGV[1];

my $trueid;
my @ids;

open IN, "<$list";
while (<IN>) {
	chomp;
	my ($Trinity, $trans) = split(/\|/, $_);
	$trueid = $Trinity;
	#print "$trueid\t";
	push (@ids, $trueid);
	}
close IN;

my $seqfile = Bio::SeqIO -> new (-file => "$fasta", -format => "fasta");
while (my $io_obj = $seqfile -> next_seq() ) {
	my $header = $io_obj->id();
	my @idparts = split(" ", $header);
	my $idtokeep = @idparts[0];
	#print "$idtokeep";
	my $seq = $io_obj->seq;
	if ($idtokeep ~~ @ids) {
		print ">$header\n$seq\n";
		}
	else {
		next;
		}
	}

