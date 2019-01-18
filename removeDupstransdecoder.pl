#!/usr/bin/perl
use strict;

#removes duplicate cds strings by selecting only the longest one
#runs on the output of filterBy22Glength.pl

my $list = $ARGV[0]; #output of filterBy22Glength.pl
my %hash;

open IN, "<$list";
while (<IN>) {
	chomp;
	my ($fulltrans, $orthoid, $length) = split(/\t/, $_);
	my $divider = "|";
	my $pos = rindex($fulltrans, $divider);
	my $trinityid = substr($fulltrans, 0, $pos);
	$hash{$trinityid}{$length} = $orthoid;
	}
close IN;
	
foreach my $trinityid (sort {$a<=>$b} keys %hash){
	my $max = 0;
	foreach my $length (sort {$a<=>$b} keys %{$hash{$trinityid}}) {
		if ($length > $max) {
			$max = $length;
			}
		else {
			next;
			}
		}
	print "$trinityid\t$hash{$trinityid}{$max}\t$max\n";
	}
	