#!/usr/bin/perl
use Bio::SeqIO;
use strict;
#script to calculate min/max alignment length of all genes in orthogrop from 22 orthogroups

my @files = glob("*.fna");
foreach my $file (@files) {
	my @headers;
	my $count == 1;
	my $min;
	my $max;
	my $fasta = Bio::SeqIO->new(-format => 'fasta', -file => $file);
		while (my $io_obj = $fasta -> next_seq() ) {
		my $header = $io_obj->id();
		push (@headers, $header);
		my $seq = $io_obj->seq();
		my $length = $io_obj->length();
		if ($count == 1) {
			$max = $length;
			$min  = $length;
			}
		else {
			if ($length < $min) {
				$min = $length;
				}
			elsif ($length > $max) {
				$max = $length;
				}
			else {
				next;
				}
			}
		$count++;
		}
	print "$file\t$min\t$max\n";
	}
