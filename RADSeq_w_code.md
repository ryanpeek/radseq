RADSeq\_w\_code
================
Updated: 2017-08-31

-   [*BACKGROUND*](#background)
    -   [UNIX/BASH Commands refresher](#unixbash-commands-refresher)
        -   [Server runs](#server-runs)
        -   [Word count/file counts](#word-countfile-counts)
        -   [Check File Sizes](#check-file-sizes)
        -   [Get First Column of sorted multicolumn file:](#get-first-column-of-sorted-multicolumn-file)
        -   [List Files by Datetime Stamp](#list-files-by-datetime-stamp)
        -   [Screens](#screens)
        -   [Text Editors (*VIM*)](#text-editors-vim)
    -   [Using `sftp`](#using-sftp)
    -   [Bioinformatic setup](#bioinformatic-setup)
        -   [Folder Organization](#folder-organization)
    -   [General Genomic Information](#general-genomic-information)
        -   [Cutters](#cutters)
-   [*DOWNLOADING ORIGINAL ILLUMINA FILES*](#downloading-original-illumina-files)
    -   [Split by Plate](#split-by-plate)
    -   [Split by Well Barcodes](#split-by-well-barcodes)
    -   [Add Metadata/SiteNames (Optional)](#add-metadatasitenames-optional)
-   [*DE NOVO ASSEMBLY*](#de-novo-assembly)
    -   [Choosing Individuals](#choosing-individuals)
    -   [Option 1 (Clean up reads in a single script)](#option-1-clean-up-reads-in-a-single-script)
    -   [Option 2 (Clean up reads one script/Indiv at a time)](#option-2-clean-up-reads-one-scriptindiv-at-a-time)
    -   [Alignment](#alignment)
        -   [Index](#index)
        -   [Align](#align)
    -   [ID loci](#id-loci)
    -   [Price (Extension)](#price-extension)
        -   [Adjust Scripts](#adjust-scripts)
-   [*ALIGN INDIVIDUALS TO LOCI*](#align-individuals-to-loci)
    -   [Node Failures and Missing Bams](#node-failures-and-missing-bams)
-   [*SUBSAMPLING WITH SAMTOOLS*](#subsampling-with-samtools)
    -   [Filter out files that are not sufficient](#filter-out-files-that-are-not-sufficient)
-   [*PCA*](#pca)
-   [*ANGSD*](#angsd)
-   [*ADMIXTURE*](#admixture)
-   [*F<sub>ST</sub>*](#fst)
-   [*FST*](#fst)
-   [*Uploading to NCBI for final data availability*](#uploading-to-ncbi-for-final-data-availability)
    -   [Create your SRA data submission](#create-your-sra-data-submission)
    -   [Uploading your files to NCBI](#uploading-your-files-to-ncbi)

*BACKGROUND*
============

There's plenty of useful information on using the cluster or *SLURM* [here](https://wiki.cse.ucdavis.edu/support/hpc/software/slurm#slurma_highly_scalable_resource_manage), but we try to add some tidbits below that might be pertinent. Take all with a grain of salt.

UNIX/BASH Commands refresher
----------------------------

### Server runs

Logging in to the server requires your username and access: - `ssh -p 2022 USERNAME@agri.cse.ucdavis.edu`

To run a program or task on the server (*Never on the head node!*), you use `sbatch ____`. - Must use **`-t`** for time needed to run program so `sbatch -t 24:00:00 __` would be for 24 hrs
- Use **`-p`** for imporance (low, med, high) so `sbatch -t time -p high ___` - Added memory is also possible `sbatch --mem=16G -t time - p high ___`, for memory intensive jobs (16, 32, 64, etc.) - To cancel server tasks `scancel [JOBNUMBER]`

**Although not always shown below, in our cluster, all `sbatch` must have a time (`-t`) flag or they will fail to run.**

To check whether sbatch is running, type `smap -c | grep USERNAME`, or to see everything that is running on the server right now, type `top`.

The output of most all server tasks is a "slurm" file. It has helpful information on the job, status, etc. The first place to check when troubleshooting is usually a `slurm-____` file. They are numbered by job number, so the most recent file/job will have the highest number.

### Word count/file counts

-   `wc -l` the fastq files
-   `ls -l *.hash | wc -l` count files in a dir

### Check File Sizes

-   `du -hs * | sort -hs`

### Get First Column of sorted multicolumn file:

-   `wc -l rabo_all*mafs | sort -h | awk '{print $1}'`

### List Files by Datetime Stamp

-   `ls -lt *FILE*`

### Screens

-   Screen is a full-screen window manager that multiplexes a physical terminal between several processes, typically shells. They provide a method to run multiple windows (usually programs) at one time, helpful if you are doing `srun` or viewing other tasks while working in a different screen.
-   To open a new screen:
    -   `screen`
-   To temporarily close a screen (hold down `ctrl`)
    -   `ctrl + a + d`
-   To Re-Open a Screen
    -   `screen -r`
-   To Detach a screen use
    -   `screen -d`
-   To Exit a screen:
    -   type `exit` in current screen
-   To List Screens or see screen numbers & return to a screen:
    -   `screen -ls`
    -   `screen -r` \[number\]
-   Command keys (`Ctrl a + ?`) or Key Binding

### Text Editors (*VIM*)

While there are many available, we prefer to use **VIM**. A few tips regarding **VIM**:

-   To exit without saving use `:q!`
-   To exit and save use: `:wq`
-   Find and replace many/every line: `:%s:`
-   Replace something specific: `:%s:AMER:../AMER:`
-   Alternatively you can say `:7,12:` for lines 7 through 12
-   To use a `sed` command within vim to find and replace, can use:
    -   `shift + :`, then `1, $s/TGCAGG$/TGCAGG.sort.flt.bam/g` (search for line ending with `TGCAGG`)

For column-wise editing:

-   Press `Ctrl+v`, then mark across the column you want to edit.
-   `Shift+i` to insert text at the beginning of the column,
-   `Shift+a` to append text,
-   `r` to replace highlighted text, `d` to delete, `c` to change... etc.

Using `sftp`
------------

To connect to the Cluster to get/put files from your local directory (your computer):

-   Open a new shell window using `ctrl t`
    -   `sftp __@agri.cse.ucdavis.edu` where \_\_ is your username for the server
    -   `cd _/_` change directory to whichever location on CLUSTER that has these files
    -   `ls *pdf` can list the files of interest to make sure it's what you want/exists
    -   `lcd _/_` change directory locally (your computer)
    -   `lls` local list the files in current local directory
-   **`get` files from CLUSTER to local directory (your computer)**
    -   `get *pdf` download all pdf files from Cluster to your computer
-   **`put` files from local directory to CLUSTER**
    -   `put *bamlist` copy files from local directory to CLUSTER

Bioinformatic setup
-------------------

There are two ways of approaching all the scripts and programs necessary. Keep them in your `/bin ($PATH)`, in a separate directory (like `/scripts`) or copy and paste them in the directory you are working in. The last way allows for project specific changes without changing the original script.

### Folder Organization

With the large number of files that exist within these pipelines, it's easy to get lazy, and then get confused about where what files are. Following the same folder structure across sequencing runs and projects will be really helpful, and pick something that works. One possibility is as follows, but it's by no means "*the way*."

Create a project folder for your organism or project. When naming files/folders don't use spaces, and separate words using `_` or **C**amel**C**ase. Inside your project folder, you'll want another folder named for the sequencing run (i.e., `SOMMXXX`). Then create these subfolders inside:

-   **`/raw`** (where raw sequencing files are linked/copied)
-   **`/split`** (where the unzipped and then split by barcode fastq live)
    -   **`/split_out`** (split by plate barcode)
-   **`/fastq`** (where the processed fastq/bams and analyses live)
    -   **`/align`** (the aligned bams)
    -   **`/slurm_outs`** (for all slurms)

i.e., mine looks something like this: `/home/projects/rapture/SOMM163/raw`

General Genomic Information
---------------------------

### Cutters

-   Six cutter `(5' -  CTGCA_G - 3')` *Pst1*
-   Eight cutter `(5' - CCTGCA_GG - 3')` *Sbf1*

Each sample/file will end up labeled with a Biotin Platebarcode, and an individual well barcode. These will look something like (for Sbf1): *PlateBarcode*-CC\_CCTGCA\_GG\_*FRAGMENT*

#### Q Phred Quality scores

Initial files are `.fastq` because they contain Q quality scores.

-   there are 4 lines per each individuals sequence
-   score is series of characters-&gt;numbers-&gt;CAPletters-&gt;lowercaseletters lowest-&gt;highest
-   Q represents the quality score of nucleotides generated by automated DNA seq
    -   `Q = -10log10 P` where P = base calling error probability
    -   50 would be 99.999%; 20 would be 99%; 10 would be 90%
    -   Most common is +33

*DOWNLOADING ORIGINAL ILLUMINA FILES*
=====================================

<sub>**All files come as zipped .fastq files**</sub> \#\# Download/Symlink

1.  Make a new directory inside your project folder: `mkdir SOMMXXX`

2.  Files are always downloaded here: `~millermr/UCDavis/SOMM_/*index_*`
    -   to learn plate barcode, open info.txt in SOMM folder `SOMM____ INDEX___`
    -   you can either copy the files over using `cp ~millermr/UCDavis/SOMM_/* ./`
    -   OR, you can make a symbolic link, e.g., : `ln -s /home/millermr/UCDavis/SOMM163/*.gz /home/rapeek/projects/rana_rapture/SOMM163b/raw` (*it does require full path*)
3.  To unzip files use: `srun` and `gunzip -c` and re-direct the output to a file of the same name (minus `.gz`):
    -   `srun -t 8:00:00 -p high gunzip -c SOMM163_S1_L001_R1_001.fastq.gz > SOMM163_S1_L001_R1_001.fastq`
4.  Once completed, move the unzipped files into your "split" folder. If you `cp` the entire `fastq.gz` files, you can remove them.

Split by Plate
--------------

1.  This takes the R2 reads, which is the plate codes, and matches to the different reads. Once done, we can delete the R2 reads and use the R1/R3 reads for the Split by Well Barcodes. This requires the following scripts:
    -   `run_split.sh`
    -   `BarcodeSplitList3Files.pl`
2.  Run script using something like:
    -   `sbatch -t 8:00:00 run_split.sh SOMM163_S1_L001_R1_001.fastq SOMM163_S1_L001_R2_001.fastq SOMM163_S1_L001_R3_001.fastq SOMM163`
3.  If other plates with no data, or not your data, need to sort/filter. One option is to sort by size `du -hs *fastq | sort -hs`, get just the plates that have data...*(should see a size jump between plates w data and those without)*.
    -   This lists all files of interest, but may need to pipe to head or tail to filter:

-   `du -hs *fastq | sort -hs | cut -f2`

1.  Move them to a folder of interest, here, the `split_out` folder in the `split` folder.

-   `du -hs *fastq | sort -hs | tail -n37 | head -n-3 | cut -f2 | sed "s/^/mv /g" | sed "s/$/ split_out\//g"`

Split by Well Barcodes
----------------------

1.  Now we have each plate barcode, but we need to split samples by well. This requires the following scripts:
    -   `BarcodeSplitListBestRadPairedEnd.pl`
    -   `run_wellsplit.sh` (*make sure executable: `chmod u+x script`*)
    -   `run_BestRadSplit_.sh` (underscore is either a 6 or an 8 - depending on enzyme used)
2.  Make a list of the files we want to split out (need the R1/R3's):
    -   `ls *R1*.fastq > listR1`
    -   `ls *R3*.fastq > listR3`
3.  Then cut and pipe with `sed` to add the third column (the individual plate codes for the script):
    -   `ls S*R1* | sed "s/_R1//g" | sed "s/\.fastq//g" | paste listR1 listR3 - > flist`
4.  Then we can use a *`screen`* to run the script to split out wells.
    -   `srun -t 12:00:00 -p high run_wellsplit.sh flist`
    -   `smap -c | grep USERNAME`
    -   This runs the perl script `BarcodeSplitListBestRadPairedEnd.pl` and looks at R1 and R2 to find which has the Indiv. barcode (because the probe sits down randomly on either), then puts all the fragments with barcodes as RA and those without as RB. This should give you the same \# of lines for RA and RB.
    -   Script bases matches on location in file (as sorted) but a numeric value is available
    -   RA will be slightly smaller (use `du -hs`) because the barcode is cleaved (but still in the name of the file)
    -   this takes a good 30 minutes or more with lots of samples/plates
    -   cp the files over to the `fastq` folder in your dir

Add Metadata/SiteNames (Optional)
---------------------------------

If you want to add metadata to your filenames, you can do that here, but it is optional. A metadata file should contains the name of each individual, its location on the plate, etc. *<span style="color:red"> This part can be done now or later. But be absolutely sure that your indiv names, their plate location (A1, B1, etc.), and the appropriate barcode are all in sync. For example, the barcodes might be A1 A2 A3 (Across the plate row) while your sample names are A1 B1 C1 (Down the plate column)</span>*

1.  Replace barcode with name of Indiv using Metadata file and script `Barcode_to_Name`
    -   `sbatch -t 2880 -p high Barcode_to_Name metadatafile` 2880 is the number of minutes
2.  Concatenate each individual's files into one RA, RB per indiv (if multiple).
    -   `sbatch -t 2880 -p high Concatenate.sh` You might need to hardcode the metadata file into this script.
3.  Keep concatenated files, remove all others. They should be something like `NAME1_RA.fastq` and `NAME1_RB.fastq`

------------------------------------------------------------------------

***The de novo step is not necessary if a model genome or previous alignment is available (skip to Align individuals to loci)***

*DE NOVO ASSEMBLY*
==================

Choosing Individuals
--------------------

1.  Pick your best 5 - 10 individuals (using `du -hs` or `wc -l`)

2.  Copy these individuals (just RA) into a new directory

Option 1 (Clean up reads in a single script)
--------------------------------------------

1.  Make an indiv file list (for however many files you chose). Start by making a list of files using sed:
    -   `ls fastq | sed "s:.fastq::g" > list`

2.  Modify and run the script `Hash_reads.sh`, which will run all three perl scripts (see Option 2)

Option 2 (Clean up reads one script/Indiv at a time)
----------------------------------------------------

1.  Modify file for quality control by throwing out seqs which do not meet threshold
    -   Example `perl QualityFilter.pl Dpup_007_RA.fastq > Dpupt_oo7_RA_QF.fastq`
    -   Do for all individuals you chose

2.  Find and shrink seqs to only unique ones while culling down file from 4 lines to 2 lines
    -   `perl HashSeqs.pl Dpup_007_RA_QF.fastq Dpup_007 > Dpup_007_RA_QF.hash`
    -   Do for all indivduals you chose

3.  Depending on coverage, you can look at the distribution and see the \# of occurrences vs. \# of sequences, expect a peak a some point followed by a dip and a recovery, with a spike early on (usually errors).
    -   `perl PrintHashHisto.pl Dpup_007_RA_QF.hash`
    -   Do for all individuals you chose

4.  May need more samples because don't have many sequences within the distribution (low coverage)

Alignment
---------

Before aligning, need to know parameters for alignment script. To count files in a dir:

``` bash
ls -l *.hash | wc -l
```

Concatenate all the hash files `cat *.hash > _.fasta` where the underscore can be anything you want (like a name) - Make sure **novoalign** (a program) is in your bin or PATH or copied to this directory

### Index

Create the novoindex index file (can run with 32G if need more memory): - `screen` See notes at start of this pipeline in case you are unfamiliar - `srun --mem=16G novoindex _.fa.idx _.fasta` This is what you want it called and whatever your fasta file was named - Use smap to view task `smap -c | grep your_user_name`

### Align

Now align index to itself, with following:
- `screen` See notes at start of this pipeline in case you are unfamiliar - `srun --mem=16G novoalign -r E 48 -t 180 -d _.fa.idx -f _.fasta > _.novo` - Output is a **"*.novo"*** file - Check size of file with `du -hs * | sort -hr`

ID loci
-------

1.  Now identify loci:
    -   `screen` See notes at start of this pipeline in case you are unfamiliar
    -   `srun --mem=16G IdentifyLoci3.pl _.novo > _IDloci.fasta`

2.  Once done counting loci, divide by 2 to get idea of how many loci we are dealing with, perl can only handle 8000 lines and 4000 loci chunks (\*We will need to split \_IDloci.fasta into 8000 line chunks\*)
    -   See how many polymorphic loci exist `perl SimplifyLoci2.pl _IDloci.fasta | grep "_2" | wc -l`

Price (Extension)
-----------------

1.  Now create PRICE directory and extendLoci directories inside PRICE
    -   `mkdir PRICE [in denovo folder]`
    -   `mkdir extendLoci_1` (if 104,000 or less (aa:az)) *4000 loci x 26 letters (a-z) equals 104,000*
    -   `mkdir extendLoci_2` (if &gt;104,000 loci) *add another directory for each 104000 you will need.*
    -   This is common when a six cutter is used because more loci will be generated.

2.  Make sure you have scripts required in the PRICE directory:
    -   `cp ~PATH/RecoverLocusSpecificReads.pl ./` (*This must be in the PRICE directory*)
    -   `getLoci.py`
    -   `RecoverLocusSpecificReads.sh`
    -   `extendLoci.sh`
    -   `format_contigs.sh`
    -   `cat.sh`
    -   `select_loci.py` (*This must be in the PRICE directory*)

3.  Cat all your R1 & R2 files into one file each (one R1 and one R2) and copy to PRICE:
    *Depending on the size and number of seq, may be best to sbatch*
    -   `cat *_RA.fastq > RABO_R1.fastq` For example RABO is the species name and its all individuals sequenced
    -   `cat *_RB.fastq > RABO_R2.fastq`
    -   `cp RABO* ./PRICE`

4.  wc -l the ID Loci file and divide by 2 to see how many loci
    -   `????? / 2 =` **?????? LOCI** using `IDLoci2`

5.  Strip names off of files to make a simplified version:
    -   `perl ~/scripts/SimplifyLoci2.pl _IDloci.fasta | grep --no-group-separator -A 1 "_1" > _IDloci_s.fasta`
    -   Then remove the \_1 and make a `simplified final` version
    -   `sed 's/_1//' _IDloci_s.fasta > _IDloci_sf.fasta`

6.  Split files into 8000 line chunks in the PRICE folder
    -   `split -l 8000 _IDloci_sf.fasta _IDloci_sf.fasta'_'` This should give you the same file name plus aa,ab,ac,etc at the end of the file name
    -   Double check with tail and wc -l to make sure each chunk is 8000 (except last one)

7.  Make a list of all the output files you just made (e.g., `_IDloci_sf.fasta_aa`, `_IDloci_sf.fasta_ab`)
    -   `ls *.fasta_a* > data_list`

8.  To get an idea of how many loci you have, open the last file created by splitting and `tail _IDloci_sf.fasta_a?` and the last number is the number of loci you have (R??????) OR you can use the number of loci you found in \#4 (good to check both really)

9.  In PRICE create a `Loci_aa` file which is a list of R000001 to whatever locus number you have from \#8 (up to R104000) and (*if necessary*) a `Loci_bb` which is R104001 to whatever locus number you have. You can use the Rscript (`makelist.R`) or use a text editor.
    -   Make a list of each line number (i.e., R000001 &gt;&gt; ?), use Rscript `makelist.R` `numbs<-seq(1:108279)` Again this is assuming you have 108279 loci `rabo<-sprintf("R%06d", numbs)` `write.table(rabo, quote=FALSE, col.names = FALSE, row.names = F)`
    -   `Rscript makelist.R` Should provide Loci\_aa and Loci\_bb files

### Adjust Scripts

1.  Copy the following scripts into each `extendLoci_*` directory you created
    -   `RecoverLocusSpecificReads.sh`
    -   `extendLoci.sh`
    -   `format_contigs.sh`
    -   `cat.sh`
    -   `getLoci.py`

2.  VIM (or another text editor) `RecoverLocusSpecificReads.sh` to reflect your ../data\_list and two fastq files (../\_R1.fastq and ../\_R2.fastq). Also adjust `$x -le ?` to reflect the number of files in your data\_list (so if you have aa-&gt;ag, ? = 7).
    -   This builds shell scripts in the PRICE directory for each aa -&gt; whatever that you have

3.  VIM `extendLoci.sh` and adjust as needed:
    -   Change the number(?) in $x -le ? to whatever your total loci number is from \#8 (*max 104000*) which covers the aa up to a? files in `extendLoci_1.sh`

4.  VIM `format_contigs.sh` and adjust as needed:
    -   Change the number(?) in $x -le ? to whatever your total loci number is from \#8 (*max 104000*) which covers the aa up to a? files in `format_contigs.sh`

**Run scripts in each extendLoci directory IN ORDER from within that directory:**

1.  Now run `RecoverLocusSpecificReads.sh` in `extend_Loci_?` directory
    -   `sbatch RecoverLocusSpecificReads.sh with Loci list (data_list)`to create sh files in PRICE

2.  Then run these from the extendLoci\_\* directories, one at a time, in order.
    -   `sbatch extendLoci.sh ../Loci_aa`
    -   `sbatch format_contigs.sh ../Loci_aa`
    -   `sbatch cat.sh aa`
    -   Do the same for Loci\_bb (which would be R104000-&gt;whatever) in extendLoci\_2 **if necessary**

3.  To obtain the file you need (aa\_contigs.fasta) which was output from cat.sh, and needs to be in PRICE, `mv aa_contigs.fasta ../`

<span style="color:red">*Be careful not to "ls" the `extendLoci_*` directories as they are very full and may stall your command line*</span>

1.  Cat Loci\_aa and Loci\_bb together, if necessary: `cat Loci_??_contigs.fasta > final_contigs.fasta`

2.  Then select loci with 300 bp or more: `python select_loci.py final_contigs.fasta 300`
    -   word count to see total loci `wc -l final_contigs`
    -   The number of total loci is **??????/2** \#4 or \#8 above
    -   The number of total loci with minimum length 300 is **??????/2** \#18

------------------------------------------------------------------------

*ALIGN INDIVIDUALS TO LOCI*
===========================

1.  Build index of contigs: `bwa index final_contigs_300.fasta` OR `A_model_genome.fasta`
    -   Files will now end in `.amb`, `.ann`, etc.
2.  Using all `fastq` build a list of the fastq RA and RB files into different columns:
    -   `ls *RA* | sed "s/\.fastq//g" > bamlistA`
    -   `ls *RB* | sed "s/\.fastq//g" > bamlistB`
    -   `paste bamlist? > bamlist`
3.  Obtain the `run_align.sh` script For example copy `cp ~millermr/common/run_align.sh ./`
    -   `sh run_align.sh bamlist final_contigs_300.fasta`
    -   It's taking all fastq files (RA and RB) and aligning to the \_300.fasta file (or model genome file)
4.  This should create your final bam files

#### Node Failures and Missing Bams

Sometimes the nodes fail, and you need to find/re-run scripts for certain files. Best option is to find/sort the files that did work, and then grep against the files that didn't to make a new list, then re-run `run_align.sh` script with new list.

-   `ls *.flt.bam | sed "s/\.sort\.flt\.bam//g" | grep -f - -v bamlist > bamlist_rerun`

*SUBSAMPLING WITH SAMTOOLS*
===========================

-   Look at Individual Alignments with **[samtools](http://samtools.sourceforge.net/)**, can be done on bams (`_.sort.bam`), etc.
    -   `samtools flagstat ALAME_AH_2_R1.sort.flt.bam`
-   Example output:

<!-- -->

    94696 + 0 in total (QC-passed reads + QC-failed reads)
    0 + 0 duplicates
    94696 + 0 mapped (100.00%:-nan%)
    94696 + 0 paired in sequencing
    47492 + 0 read1
    47204 + 0 read2
    94696 + 0 properly paired (100.00%:-nan%)
    94696 + 0 with itself and mate mapped
    0 + 0 singletons (0.00%:-nan%)
    1458 + 0 with mate mapped to a different chr
    655 + 0 with mate mapped to a different chr (mapQ>=5)

-   Look at sizes of alignments
    -   `du -hs *.sort.flt.bam | sort -h`
    -   Note that these are sorted filtered bam files
-   Need to pick a threshold for sizes, we generally like alignments over 100,000, as it's conservative but robust.

-   Example output (notice first few samples didn't have very many reads)

<!-- -->

    332K    *NFAME_IH_3_R1.sort.flt.bam*
    468K    *NFAME_IH_2_R1.sort.flt.bam*
    8.0M    ALAME_AH_2_R1.sort.flt.bam
    25M NFMFA_SC_3_R1.sort.flt.bam
    31M NFAME_IH_1_R1.sort.flt.bam
    33M MFAME_GC_1_R1.sort.flt.bam
    34M NFAME_RR_1_R1.sort.flt.bam
    34M RUBIC_PH_1_R1.sort.flt.bam
    35M ALAME_AC_1_R1.sort.flt.bam
    36M ALAME_AC_3_R1.sort.flt.bam
    36M ALAME_AH_1_R1.sort.flt.bam
    37M RUBIC_PH_2_R1.sort.flt.bam
    38M ALAME_AC_2_R1.sort.flt.bam
    38M ALAME_AH_3_R1.sort.flt.bam
    38M MFAME_GC_2_R1.sort.flt.bam
    38M NFMFA_SC_2_R1.sort.flt.bam
    39M NFAME_RR_2_R1.sort.flt.bam
    40M NFAME_RR_3_R1.sort.flt.bam
    41M MFAME_TC_1_R1.sort.flt.bam
    41M MFAME_TC_2_R1.sort.flt.bam
    41M NFMFA_SC_1_R1.sort.flt.bam
    44M MFAME_SG_1_R1.sort.flt.bam
    44M MFAME_SG_2_R1.sort.flt.bam
    44M RUBIC_PH_3_R1.sort.flt.bam

**Copy script** - `cp ~jbaumste/Roach_Hitch/Roach/sub_sample.sh ./` Could be obtained from anywhere; this is just an example

### Filter out files that are not sufficient

**Make a bam sublist**
- Need to make a bamlist of samples that only have the proper number of alignments (select a threshold of preference, typically 120k for salmon).

**Check each individual to find where alignments get too low, then remove those individuals**
- To check where alignments get too low, run a quick pca with different subsamples (e.g. 90k, 80k, etc. till structure falls apart). - Make a list of the bam files (and remove bam) - `ls *flt.bam | sed 's/\.bam//g' > sublist`

**Subset to a certain number**
- `sbatch sub_sample.sh sublist 100000`

**Create a new subsampled bamlist**
- `ls *_100000.bam > _subbamlist`

*PCA*
=====

**This is a general way to generate a principal component analysis from your subsampled bam files**

1.  Obtain and copy scripts: `pca_calc.sh` and `plotPCA_2.R` and `pca_plot.sh`

2.  Run `pca_calc.sh`
    -   `sbatch pca_calc.sh subbamlist out` (out can be any name for your outputted file)

3.  Make a clst file for plotting: `sed 's/_RA\.sort\.flt_100000\.bam/ 1 1/g' subbamlist > out.clst`

4.  VIM (or other text editor) out.clst and insert a header **`FID IID CLUSTER`**:
    -   (IID changes symbol; CLUSTER changes color)
    -   Feel free to modify this file according to symbol or color as you see fit for the final PCA plot

5.  `sh pca_plot.sh` This should create 3 pdfs (but can be modified by modifying the script)

*ANGSD*
=======

**This is the primary program for analyzing the data from a population genetics standpoint. Be wary of what version you have (on the server or in your local) as scripts may/may not work with different versions. Be sure to update**

This program has too many options to put here, but future renditions/updates may provide more explanation.

-   For the best guidance/understanding, see the help pages: <http://www.popgen.dk/angsd/index.php/ANGSD>

*ADMIXTURE*
===========

1.  Obtain the scripts
    -   `Beagleinput.sh`
    -   `NGSAdmixture.sh`
    -   `Multi_K_NGSadmixture.sh`
    -   `Admix_plot.R`
2.  Using your bamlist, generate a Beagle input file, with the proportion of individuals to keep and the outfile name:
    -   `sbatch -t 12:00:00 -p high beagleinput.sh bamlist __out__ 0.8` (out can be any name you want)
3.  To make 1 version of multiple Ks (where K can be adjusted in the script):
    -   `sbatch -t 24:00:00 -p high NGS_admixture.sh ___.beagle.gz admix_out K` OR
    -   To make multiple versions of multiple Ks: `sh Multi_K_NGSadmix.sh __  K` which makes 3 version per K but can be modified in the script
4.  The results should be various outputs `out__.qopt` where \_\_ is a number (e.g. 2, 3, 4, 21, 22 and so on)

5.  You can run an R script `Rscript Admix_plot.R __.qopt bamlist.input K out.pdf` which will plot the admixture graph

6.  For Evanno `grep -h "^best" --no-group-separator NAME.log | cut -c11 - 24 > FILE`

7.  An easier method may be to put all `___.qopt` files on your local computer and use the simple online gui to make all of your admixture graphs (see [pophelper](http://pophelper.com/))

*F<sub>ST</sub>*
================

1.  Obtain scripts: `SAF.sh` & `pwfst.sh`

2.  Create a bamlist with individuals from only the "population" you want to test

3.  Generate a simple allele frequencies file (`.saf`) for every "population" bamlist you want to compare, requires bamlist, outfile name, and your ancestral/alignment file (i.e., *`___300.fasta`*)
    -   `sbatch -t 24:00:00 - p high SAF.sh bamlist outfile_name ancestral_file`
4.  For pairwise comparisons between "populations", use two `____.saf.index` files you just generated:
    -   `sbatch -t 24:00:00 -p high pwfst.sh pop1 pop2` where `pop1` is the filename (no extension) of the 1st `___.saf.index` and `pop2` is the 2nd
    -   find the output files: `ls *finalfstout` to view. The adjusted **F<sub>ST</sub>** is the second value.
