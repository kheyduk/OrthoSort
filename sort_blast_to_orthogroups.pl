#!/bin/env perl


use strict;
use warnings;
use Getopt::Std;
use 5.014;

our($opt_b, $opt_o, $opt_s, $opt_l, $opt_i);

# -b -> Tabular blast results
# o -> File that contains the ortho group info
# s -> Output file to write the summary
# l -> Sequence length file, generated using get_seq_len_stats.pl script
# i -> The option i determines wether the seq from the 22 genome are included in the summary or not
# i = 0 does not include the seqs from 22g; i = 1 does include the seqs from the 22 genome in the summary

getopt('slobi');

our %ortho;
our %gene;
our %uni;

&get_ortho_tribes;
&read_unigene_files;
&create_unigene_summary;

exit;


sub create_unigene_summary {

    open UNI, "> $opt_s";
    my %sort;
    foreach my $uni_id (sort keys %uni){

	my $gene_id = $uni{$uni_id}{hit_id} || "";
	if ($gene_id eq ""){
	    next;
	}

	my $evalue = $uni{$uni_id}{evalue} || "";
	my $ortho_id = $gene{$gene_id}{ortho_id} || "";
	if ($ortho_id eq ""){
	    #Bad juju
	} else{

	    $uni{$uni_id}{ortho_id} = $ortho_id;
	    $ortho{$ortho_id}{tot}++;
	    $ortho{$ortho_id}{members}{$uni_id} = 1;
	    my $uni_db = $uni{$uni_id}{db};
	    if(!defined($ortho{$ortho_id}{db}{$uni_db})){
		$ortho{$ortho_id}{db}{$uni_db} = 1;
	    }else{
		$ortho{$ortho_id}{db}{$uni_db}++;
	    }
        }


    }
    foreach my $oid (sort {$a <=> $b} keys %ortho){
	if(defined($ortho{$oid}{members})){
	    print UNI "$oid:\t".join(" ",keys($ortho{$oid}{members}))."\n";
	    print "$oid:";
	    foreach my $db (keys $ortho{$oid}{db}){
		print "\t$db: $ortho{$oid}{db}{$db}";
	    }
	    print "\n";
	}
    }
    close UNI;


}



sub get_ortho_tribes {
        open IN, "< $opt_o";
        while (<IN>) {
                chomp;
                my ($ortho_id, $gene_id) = split(/\t/,$_);
                my ($db,$short_id) = ($1,$2) if ($gene_id =~ /gnl\|(\S+)\|(\S+)/);
            #    next if (exists $exclude{$db});
            #    next unless (exists $gene{$gene_id});
                $ortho{$ortho_id}{db}{$db}++ unless $opt_i == 0;   # need to change later code - 12/1/07
                $ortho{$ortho_id}{tot}++;
                $ortho{$ortho_id}{members}{$gene_id} = 1 unless $opt_i == 0;
                $gene{$gene_id}{ortho_id} = $ortho_id;
                #print LOG "$ortho_id\t$gene{$gene_id}{super_id}\t$gene{$gene_id}{tribe_id}\t$gene_id\n";
        }
        close IN;
}

sub read_unigene_files {

    # open uni length file
    open IN, "< $opt_l";
    while (<IN>){
	chomp;
	my ($uni_id,$len) = split(/\t/,$_);
	my $uni_db = "";
	$uni_db = $1 if $uni_id =~ /([a-zA-Z0-9]*)_\S*/;
	$uni{$uni_id} = { len=>$len, est_count=>0, hit_id=>"", evalue=>"", db=>$uni_db };
    }
    close IN;

    # open uni blast file
    open IN, "< $opt_b";
    while (<IN>){
	chomp;
	my $line = $_;
	my @a = split(/\t/,$line);
	my ($uni_id,$hit_id,$evalue) = ($a[0],$a[1],$a[10]);
	#next unless ($uni{$uni_id}{best_hit} eq "");
	$uni{$uni_id}{hit_id}=$hit_id;
	$uni{$uni_id}{evalue}=$evalue;
    }
        close IN;
}

sub get_db{
    my $name = shift;
    $name =~ /gnl\|([a-zA-Z0-9._\-]*)\|.*/;
    return $1;
}
