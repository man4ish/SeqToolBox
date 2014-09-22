#!/usr/bin/perl -w
use strict;
#my $phylip_font = '/netopt/usr2/local/phylip-3.6a3/bin/font1'; 

#my $clustal = 'clustalw';
#my $phylip_dir = '/netopt/usr2/local/bin';
#my $fitch = $phylip_dir.'/fitch';
my $protdist = 'protdist';
#my $retree = $phylip_dir.'/retree';
#my $protml = '/netopt/usr2/local/bin/protml';
#my $int2mol = "~\/bin\/int2mol";
my $neighbour = 'neighbor';
#my $drawgram  = 'drawgram';

my $wd = shift;
my $dir;
if ($wd) {
	$dir = $wd;
}else {
	$dir = '.';
}

#$ARGV[1] = '.' unless $ARGV[1];
#$ARGV[1] =~ s/\/$//;
#print STDERR "***$ARGV[1]";
#
#if ($ARGV[1] ne '.'){
#system ("cd $ARGV[1]");
#}

#my $phy_dir = $ARGV[1];
#my $aln_dir = $dir.'/aln';
#my $dnd_dir = $ARGV[1].'/dnd';
my $dis_dir = './dis';
#my $ml_dir  = $ARGV[1].'/ml';
my $tre_dir = './tre';
#my $ps_dir = $ARGV[1].'/ps';
#my $tpl_dir = $ARGV[1].'/tpl';
my $log_dir = './log';
#my $mph_dir = $ARGV[1].'/mph';

opendir (DIR, $dir) or die "Can't find dir: $dir\n";


#my $filename;

create_dir();


while ( my $filename = readdir (DIR)){
	next unless $filename =~ /(\S+)\.phy/;
	my $basename = $1;	
#if ($filename =~ /\.input$/ || $filename =~ /\./ || $filename =~ /\.\./
#     ){
#    next;
#  }
# 
 
# run_clustal($filename);
 run_protdist($basename);
 run_neighbour($basename);
# run_drawgram($filename);
 # run_fitch($filename);
 # run_retree($filename);
 # run_int2mol($filename);
 # run_protml($filename);
  
}
close (DIR);
#cleanup();

sub create_dir {


#stat ($aln_dir) or system ("mkdir $aln_dir");
#stat ($dnd_dir) or system ("mkdir $dnd_dir");
stat ($dis_dir) or system ("mkdir $dis_dir");
#stat ($ml_dir) or system ("mkdir $ml_dir");
stat ($tre_dir) or system ("mkdir $tre_dir");
#stat ($ps_dir) or system ("mkdir $ps_dir");
#stat ($tpl_dir) or system ("mkdir $tpl_dir");
stat ($log_dir) or system ("mkdir $log_dir");
#stat ($phy_dir) or system ("mkdir $phy_dir");

#stat ($mph_dir) or system ("mkdir $mph_dir");
}

#sub run_clustal{
#  my $filename = shift;
#  print STDERR "Running clustal on $filename...";
#  my $log = "$filename".'.log';
#  open (LOG, ">$log_dir\/$log") || die "Can't open logfile: $log\n";
#  print LOG "Running clustal... \n\n";
#  close (LOG);
#  my $outputfile = "$filename".'.aln';
#  my $treefile = "$filename".'.dnd';
#  my $phylipfile ="$filename".'.phy';
#  `$clustal << END
#1
#$filename
#2
#8
#9
#4
#
#1
#
#
#
#
#x
#END`;
# # system ("$clustal -align -infile=$filename -output=phylip -outfile=output -newtree=treefile >> $log_dir\/$log");
#  #system ("mv output $outputfile");
#  #system ("mv treefile $treefile");
#  system ("mv $treefile $dnd_dir");
#  system ("mv $outputfile $aln_dir");
#  system ("mv $phylipfile $phy_dir");
#  open (LOG, ">>$log_dir\/$log") || die "Can't open logfile: $log\n";
#  print LOG "\n\nClustal ran successfully\n\n";
#  close (LOG);
#  print STDERR "done.\n";
#}


sub run_protdist {
  my $file = shift;
  #print "**before protdist calling $file ..\n";
 my $alignment = $file.'.phy';
 # my $alignment = $file;
  system ("cp $dir\/$alignment infile");
  print STDERR "Running protdist on $file...";
  #print STDERR "$protdist\n";
  my $log = "$file".'.log';
  open (LOG, ">>$log_dir\/$log") || die "Can't open logfile: $log\n";
  print LOG "Running prodist...\n";
  `$protdist << ENDOFINPUT
i
y
ENDOFINPUT`;
  my $out = $file.'.dis';
  system ("mv outfile $out");
  system ("rm infile");
  system ("mv $out $dis_dir");
  print LOG "done.\n\n";
  close (LOG);
  print STDERR "done.\n";
}

sub run_neighbour{

  my $file = shift;
  my $file_name = $file.'.dis';
  my $log = $file.'.log';
  print STDERR "Running neighbor on $file...";
  open (LOG, ">>$log_dir\/$log") || die "Can't open logfile: $log\n";
  print LOG "Running neighbor...\n";
  system ("cp $dis_dir\/$file_name infile");
 # print "***** copied\n";
  `$neighbour <<END
y
END`;
#`$neighbour <<END
#o
#1
#y
#END`;


  my $out = $file . '.tre';
  system ("mv outtree $out");
 # print "*** renameed treefile";
  system ("rm outfile");
 # system ("mv treefile $out");
  system ("rm infile");
  system ("mv $out $tre_dir");
  print LOG "done.\n\n";
  close (LOG);
  print STDERR "done.\n";
}

#sub run_drawgram {
#  my $base_name = shift;
#  my $log = $base_name.'.log';
#  print STDERR "Running drawgram on $base_name...";
#  open (LOG, ">>$log_dir\/$log") || die "Can't open logfile: $log\n";
#  print LOG "Running drawgram...\n";
#  my $treefile = $base_name.'.tre';
#  system ("cp $tre_dir\/$treefile treefile");
#  `$drawgram << END
#$phylip_font
#l
#n
#1
#2
#p
#4
#90
#y
#END`;
#  my $out = $base_name .'.ps';
#  #system ("echo 1 > $out");
#  #system ("cat outtree >> $out");
#  system ("mv plotfile $out");
#  system ("rm treefile");
#  #system ("rm outtree");
#  system ("mv $out $ps_dir");
#  print LOG "done.\n\n";
#  close (LOG);
#  print STDERR "done.\n";
#
#
#}
