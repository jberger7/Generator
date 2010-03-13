#!/usr/bin/perl

#----------------------------------------------------------------------
# Submit jobs for calculating GENIE cross section splines for all the 
# nuclear targets in the T2K detector geometries.
#
# For use at the RAL/PPD Tier2 PBS batch farm.
#
# Syntax:
#   shell% perl submit-xsec_t2k.pl <options>
#
# Options:
#    --version       : GENIE version number
#   [--arch]         : <SL4_32bit, SL5_64bit>, default: SL5_64bit
#   [--production]   : default: t2kxspl_<version>
#   [--cycle]        : default: 01
#   [--use-valgrind] : default: off
#   [--queue]        : default: prod
#   [--softw-topdir] : default: /opt/ppd/t2k/GENIE
#
# Notes:
#   * Use GENIE gspladd utility to merge the job outputs
#
# Costas Andreopoulos <costas.andreopoulos \at stfc.ac.uk>
# STFC, Rutherford Appleton Lab
#----------------------------------------------------------------------

use File::Path;

# inputs
#  
$iarg=0;
foreach (@ARGV) {
  if($_ eq '--version')       { $genie_version = $ARGV[$iarg+1]; }
  if($_ eq '--arch')          { $arch          = $ARGV[$iarg+1]; }
  if($_ eq '--production')    { $production    = $ARGV[$iarg+1]; }
  if($_ eq '--cycle')         { $cycle         = $ARGV[$iarg+1]; }
  if($_ eq '--use-valgrind')  { $use_valgrind  = $ARGV[$iarg+1]; }
  if($_ eq '--queue')         { $queue         = $ARGV[$iarg+1]; }
  if($_ eq '--softw-topdir')  { $softw_topdir  = $ARGV[$iarg+1]; }
  $iarg++;
}
die("** Aborting [Undefined GENIE version. Use the --version option]")
unless defined $genie_version;

$use_valgrind   = 0                         unless defined $use_valgrind;
$arch           = "SL5_64bit"               unless defined $arch;
$production     = "t2kxspl\_$genie_version" unless defined $production;
$cycle          = "01"                      unless defined $cycle;
$queue          = "prod"                    unless defined $queue;
$softw_topdir   = "/opt/ppd/t2k/GENIE"      unless defined $softw_topdir;
$genie_setup    = "$softw_topdir/builds/$arch/$genie_version-setup";
$jobs_dir       = "$softw_topdir/scratch/xsect2k-$genie_version-$production\_$cycle/";
$freenucsplines = "$softw_topdir/data/job_inputs/xspl/gxspl-freenuc-$genie_version.xml";

$nkots     = 200;
$emax      =  35;
$neutrinos = "12,-12,14,-14";
%targets = (
	'H2'    =>  '1000010020',
	'B10'   =>  '1000050100',
	'B11'   =>  '1000050110',
	'C12'   =>  '1000060120',
	'C13'   =>  '1000060130', 
	'N14'   =>  '1000070140', 
	'N15'   =>  '1000070150', 
	'O16'   =>  '1000080160', 
	'O17'   =>  '1000080170', 
	'O18'   =>  '1000080180',
	'F19'   =>  '1000090190',
	'Na23'  =>  '1000110230',
	'Al27'  =>  '1000130270', 
	'Si28'  =>  '1000140280',
	'Si29'  =>  '1000140290',
	'Si30'  =>  '1000140300',
	'Cl35'  =>  '1000170350',
	'Cl37'  =>  '1000170370',
	'Ar36'  =>  '1000180360',
	'Ar38'  =>  '1000180380',
	'Ar40'  =>  '1000180400',
	'Ti46'  =>  '1000220460',
	'Ti47'  =>  '1000220470',
	'Ti48'  =>  '1000220480',
	'Ti49'  =>  '1000220490',
	'Ti50'  =>  '1000220500',
	'Fe54'  =>  '1000260540',
	'Fe56'  =>  '1000260560',
	'Fe57'  =>  '1000260570',
	'Fe58'  =>  '1000260580',
	'Co59'  =>  '1000270590',   
	'Cu63'  =>  '1000290630',
	'Cu65'  =>  '1000290650',
	'Zn64'  =>  '1000300640',
	'Zn66'  =>  '1000300660',
	'Zn67'  =>  '1000300670',
	'Zn68'  =>  '1000300680',
	'Zn70'  =>  '1000300700',
	'Pb204' =>  '1000822040',
	'Pb206' =>  '1000822060',
	'Pb207' =>  '1000822070',
	'Pb208' =>  '1000822080'  );


# make the jobs directory
#
mkpath ($jobs_dir, {verbose => 1, mode=>0777});

#
# loop over nuclear targets & submit jobs
#
while( my ($tgt_name, $tgt_code) = each %targets ) {

	$BATCH_SCRIPT = "$jobs_dir/job_$tgt_name.pbs";
	open(PBS, ">$BATCH_SCRIPT") 
	or die("Can not create the PBS batch script");

	$cmd = "gmkspl -p $neutrinos -t $tgt_code -n $nkots -e $emax -o gxspl_$tgt_name.xml &> job_$tgt_name.log";

	print PBS "#!/bin/bash \n";
        print PBS "#PBS -N $tgt_name \n";
        print PBS "#PBS -o $jobs_dir/job-$tgt_name.pbs_o \n";
        print PBS "#PBS -e $jobs_dir/job-$tgt_name.pbs_e \n";
	print PBS "source $genie_setup \n";
	print PBS "cd $jobs_dir \n";
	print PBS "export GSPLOAD=$freenucsplines\n";
	print PBS "$cmd \n";

	print "EXEC: $cmd \n";

	# submit job
	`qsub -q $queue $BATCH_SCRIPT`;
}

