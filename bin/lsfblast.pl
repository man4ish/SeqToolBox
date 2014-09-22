#!/usr/bin/perl -w
#$Id:lsfblast.pl 22 2007-08-03 17:28:24Z malay $
# lsfblast.pl - a program to submit blast job to LSF queue.

# Usage: lsfblast.pl <number of processes>

#  This program takes each file in the current directory and submits a
#  blast job to LSF queue. It submits only the specified number of jobs
#  to the queue and waits, till it finds free slot to sumbit more. The
#  program creates an output directory containing the result files and
#  a log directory containing the LSF output logs.

use Cwd;
use Getopt::Std;
use strict;

our (%opt);

getopt( 'iodpb', \%opt );

#print $opt{i}, ',', $opt{o}, "\n";

my $composite_input  = $opt{i} || undef;
my $composite_output = $opt{o} || undef;
my $program          = $opt{p} || 'blastp';
my $database         = $opt{d} || die "Database is required option\n";
my $blastoptions     = $opt{b} || "";


#print $composite_input, ',', $composite_output, "\n";

# Blast options

my $BLAST   = "blastall";
my $OPTIONS = "-p $program -d $database $blastoptions";

# LSF commands

my $LSF = 'bsub';

#my $LSF_OPTIONS = '-q "unified" -R "linux" -m "lfarm008 lfarm005 lfarm118 lfarm025 lfarm059 lfarm040 lfarm116 others+2"';
my $LSF_OPTIONS = '-q "unified" -R "linux"';

# Number of jobs that the script will submit at a time

my $NP = 500;

#if ($ARGV[0]) {
##    $NP = $ARGV[0];
#}

# Output directories
#my $CURRENT_DIR = cwd();
my $CURRENT_DIR = $ENV{PWD};
my $TMP_DIR     = $CURRENT_DIR . '/tmp';

if ( !stat($TMP_DIR) ) {
	system("mkdir $TMP_DIR") == 0 or die "Can't create $TMP_DIR!\n";
}
my $INPUT_DIR = $CURRENT_DIR . '/tmp/input';

if ( !stat($INPUT_DIR) ) {
	system("mkdir $INPUT_DIR") == 0 or die "Can't create $INPUT_DIR!\n";
}
my $total_seq    = 0;
my $total_job    = 0;
my $total_result = 0;

if ($composite_input) {
	open( INFILE, $opt{i} ) || die "Can't open $opt{i}\n";
	my $lastseq = "";
	my $lastgi  = "";

	while ( my $line = <INFILE> ) {
		if ( $line =~ /^>/ ) {
			$total_seq++;

			if ($lastgi) {
				my $outfile = $INPUT_DIR . '/' . $lastgi . '.lsf';

				#	if (stat $outfile) {
				#		    die "Duplicate entry $outfile\n";
				#		}
				open( OUTFILE, ">$outfile" ) || die "Can't open $outfile\n";
				print OUTFILE $lastseq;
				close(OUTFILE);
				$lastseq = $line;
				$line =~ /^>(\S+)/;
				$lastgi = $1;
				$lastgi =~ s/[^0-9A-Za-z]/\_/g;

			}
			else {
				$lastseq = $line;
				$line =~ /^>(\S+)/;
				$lastgi = $1;
				$lastgi =~ s/[^0-9A-Za-z]/\_/g;

			}
		}
		else {
			$lastseq .= $line;
		}
	}

	if ($lastgi) {
		my $outfile = $INPUT_DIR . '/' . $lastgi . '.lsf';
		open( OUTFILE, ">$outfile" ) || die "Can't open $outfile\n";
		print OUTFILE $lastseq;
		close(OUTFILE);

		#	$lastseq = $line;
		#		$line =~ /^>(\S+)/;
		#		$lastgi = $1;
		#		$lastgi =~ s/[^0-9A-Za-z]/\_/g;
	}
}

my $OUTPUT_DIR = $CURRENT_DIR . '/tmp/output';
my $LOG_DIR    = $CURRENT_DIR . '/tmp/log';

if ( !stat($OUTPUT_DIR) ) {
	system("mkdir $OUTPUT_DIR") == 0 or die "Can't create output dir!\n";

}

if ( !stat($LOG_DIR) ) {
	system("mkdir $LOG_DIR") == 0 or die "Can't create log dir!\n";
}

# open the current dir and read one file at a time
opendir( DIR, $INPUT_DIR ) or die "Can't open $INPUT_DIR\n";

my $filename;    # stores the filename in the loop
my @jobs;        # a global array contains running job pids;
my $ext = "";

# main loop
if ($composite_input) {
	$ext = '.lsf';
}
else {
	$ext = '.fas';
}

while ( defined( $filename = readdir(DIR) ) ) {
	next if ( -d $filename );    # skip if it is a directory

	if ($composite_input) {
	}
	next
		if ( $filename !~ /$ext$/ )
		;                        # skip if the file extension is not ".fas"

	if ( @jobs > $NP ) {         # Process limit has reached

		gotosleep();
	}
	my $basename = get_base_name($filename);
	my $logfile  = $LOG_DIR . '/' . $basename . '.log';
	my $outfile  = $OUTPUT_DIR . '/' . $basename . '.bla';
	my $infile   = $INPUT_DIR . '/' . $filename;

	open( LSF,
		"$LSF $LSF_OPTIONS -o $logfile $BLAST $OPTIONS -i $infile -o $outfile|"
	);
	$total_job++;

	while ( my $line = <LSF> ) {
		if ( $line =~ /\<(\S+)\>/ ) {
			$jobs[@jobs] = $1;
		}
		else {
			close LSF;
			die "Can't schedule job\n";
		}
	}
	print STDERR
		"[lsfblast ($total_job/$total_seq)] Scheduling jobs for $filename...";
	print STDERR "done\n";
	close(LSF);
}

close(DIR);
print STDERR "Sucessfully completed scheduling.\n";

while (1) {
	print STDERR "[lsfblast] Waiting for jobs to finish...\n";
	my %status;
	open( PIPE, "bjobs -a |" );

	while ( my $line = <PIPE> ) {
		chomp $line;

		if ( $line =~ /^JOBID/ ) {
			next;
		}
		my @fields = split( /\s+/, $line );
		$status{ $fields[0] } = $fields[2];
	}

	close(PIPE);

	for ( my $i = 0; $i < @jobs; $i++ ) {
		my $pid = shift @jobs;

		if (    !defined( $status{$pid} )
			 || $status{$pid} eq "DONE"
			 || $status{$pid} eq "EXIT" )
		{

		}
		else {
			push @jobs, $pid;
		}

	}

	if (@jobs) {

	}
	else {

		last;

		#sleep 10;
	}
}

#while (1) {
#    my $alljobs = `bjobs`;
#    my $string = "No unfinished job found";
#    if ($alljobs =~ /^$string/) {
#	last;
#    }
#}

if ($composite_input) {
	system("rm -rf $INPUT_DIR");
	print STDERR "[lsfblast] Total sequence: $total_seq\n";

}

if ($composite_output) {
	print STDERR "[lsfblast] Collating output ...";
	opendir( DIR, $OUTPUT_DIR ) or die "Can't open $OUTPUT_DIR\n";
	open( OUTFILE, ">$opt{o}" ) || die "Can't open $opt{o}\n";

	while ( defined( $filename = readdir(DIR) ) ) {

		my $infile = $OUTPUT_DIR . '/' . $filename;
		next if ( -d $infile );
		$total_result++;
		open( INFILE, "$infile" ) || die "Can't open $infile\n";

		while ( my $line = <INFILE> ) {
			print OUTFILE $line;
		}
		close(INFILE);
	}
	close(OUTFILE);
	close(DIR);
	system("rm -rf $OUTPUT_DIR");

	print STDERR "done.\n";
	print STDERR "[lsfblast] Total result: $total_result\n";

}

print STDERR "Total jobs: $total_job\n";

sub gotosleep {

	while (1) {
		print STDERR "[lsfblast] Process limit has reached...waiting\n";
		my %status;
		open( PIPE, "bjobs -a |" );

		while ( my $line = <PIPE> ) {
			chomp $line;

			if ( $line =~ /^JOBID/ ) {
				next;
			}
			my @fields = split( /\s+/, $line );
			$status{ $fields[0] } = $fields[2];
		}

		close(PIPE);

		for ( my $i = 0; $i <= $NP; $i++ ) {
			my $pid = shift @jobs;

			if (    !defined( $status{$pid} )
				 || $status{$pid} eq "DONE"
				 || $status{$pid} eq "EXIT" )
			{

			}
			else {
				push @jobs, $pid;
			}

		}

		if ( @jobs < $NP ) {
			return 0;
		}
		else {

			#sleep 10;
		}
	}
}

sub get_base_name {
	my $filename = shift;
	$filename =~ /^(\S+)\.[.]*?/;
	return $1;

}
