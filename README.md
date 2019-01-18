OrthoSort
---------
This is a pipeline to sort genes (from transcriptome, genome, etc) into orthogroups ("gene families"). The scripts used are written by either Karolina Heyduk (UGA), Saravanaraj Ayyampalayam (UGA), or Eric Wafula (PSU). If you use this, please cite this github repo!

Update 7/7/2017 - currently working on uploading files, please contact heyduk@uga.edu if you need something urgently!

Requirements
------------
* A set of circumscribed orthogroup - there are 2 sets to be had, see below for details 
* coding sequences of interest - for a transcriptome, you would need to run something akin to transdecoder. Multiple ORFs are allowed at this step, they will be removed later. 
* Perl

Orthogroup sets
---------------
1. Green plant: contains gene families circumscribed from 31 plant genomes. Included species are
1. Monocot: contains gene families circumscribed from 14 taxa. Included are genomes from *Brachypodium distachyon, Phalaenopsis equestris, Oryza sativa, Musa acuminata, Asparagus officinalis, Ananas comusus, Elaeis guiensis, Acorus americanus, Sorghum bicolor, Vitis vinifera, Arabidopsis thaliana, Carica papaya, Solanum lycopersicum, and Amborella tricopoda*. 

Instructions for Use
--------------------

1. BLAST your CDS file to your orthogroup set (green plant or monocot, please change -db flag accordingly):

		blastx -query cds.file -db greenplant.ortho.faa -num_threads 4 -evalue 1e-10 -max_target_seqs 1 -outfmt 6 > 
         	blastout.txt        
         	
  * note that you can use either a nucleotide or protein version of the orthogroups file

2. Sort your BLAST results into orthogroups using the sort__blast_to_orthogroups.pl script:

	    perl sort_blast_to_orthogroup.pl -s output.ortho -l transdecoder.length -b blastout.txt -o greenplant.ortho.txt -i 0
	
	* -s is the name of the output file
	* -l is a lengths file, in the format transcript id and length in two columbs, tab delimited
	* -b is the blast output from step 1
	* -o is an orthogroup file that lists what genome sequences belong to each orthogroup
	* -i designates whether to print just the output of your sequences (0) or all (1) - please note that using -i 1 creates a giant text file

3. To reduce assembly artifacts or error in homology matching via BLAST, you might want to filter your sequences of interest so that they are equal in length or greater to the minimum length found in each orthogroup. To do this you need to calculate the maximum length per orthogroup. This can be done with the run_getLengths.pl script, which must be run in the orthogroup folder that contains thousands of orthogroup files. It is currently set to find ".fna" file endings, please change to ".aa" if using protein orthogroup sequences. 

	    perl getLengths.pl > orthogroupLengths.txt

4. Run filterByOrthoLength.pl to remove sequences that are too short:
	
	    perl filterByOrthoLength.pl orthogroupLengths.txt transdecoder.length output.ortho
	
	* The first argument refers to the min and max lengths of each orthogroup file generated in step 3. The second argument is the length of each of your sequences (for example, output of transdecoder). The third argument is the output of step 2. 

5. Run removeDepstransdecoder.pl  - takes a single argument, the output of filterByOrthoLength.pl. Use this only to remove multiple ORFs from transdecoder, keeping the longest. After running, use "cut -f 1 outfile > headers.txt" to pull out the headers that you are now keeping, post filtering and sorting. 

6. Finally, run pullTrinityOrthoFilt.pl, which takes two arguments: the headers.txt file you created in step 5, and the original Trinity fasta assembly (or a filtered one - whatever you ran through transdecoder). 

The result should be that you now have transcripts that 1) belong to a bonafide plant gene family and 2) are within the right size range for that family. 
