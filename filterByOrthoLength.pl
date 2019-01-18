#!/usr/bin/perl

use strict;
#prints list of Trinity contigs that are within the min/max of the assigned orthogroup sequence length
#can work with either na or aa alignments, but both 22g and assembly must be the same
my $ortho = $ARGV[0]; #length min max of orthogroups
my $length = $ARGV[1]; #length of every transcript in your assembly
my $clusters = $ARGV[2]; #list of clusters that contain your contigs (output of 22g pipeline, filtered for presence of your taxa)

my %orthomin;
my %orthomax;
my %trinitylen;

#input length min max of each orthogroup (read in lengths.txt)
open IN, "<$ortho";
while (<IN>) {
	chomp;
	my ($orthoid, $min, $max) = split(/\t/, $_);
	$orthomin{$orthoid}= $min;
#	print "$orthoid\t$min\t$max\n";
	$orthomax{$orthoid} = $max;
	}
close IN;

#input lengths of CDS sequences for your assembly (contig\tlength\n)
open IN2, "<$length";
while (<IN2>) {
	chomp;
	my ($trinity, $trinlen) = split(/\t/, $_);
	$trinitylen{$trinity} = $trinlen;
#	print "$trinity\t$trinlen\n";
	}
close IN2;

#parse orthogroup files - split by space
open IN3, "<$clusters";
while (<IN3>) {
	chomp;
	my ($orthofull, $othershit) = split(/\t/, $_);
	my ($orthoid, $nothing) = split(":", $orthofull);
#	print "$orthoid\n";
	my @garbage = split(' ', $othershit);
	foreach my $taxa (@garbage) {
	#print "$taxa\n";
		if ($taxa =~ /TR/) {
		#print "$taxa\n";
			my $trinlen = $trinitylen{$taxa};
			#print "$trinlen\n";
			#print "$orthomin{$orthoid}\t$orthomax{$orthoid}\n";
			if ($trinlen >= $orthomin{$orthoid}) {
				print "$taxa\t$orthoid\t$trinlen\t$orthomin{$orthoid}\n";
				}
			else {
				print "sequence is not long enough\n";
				}
			}
		else {
			next;
			}
		}
	}
close IN3;
