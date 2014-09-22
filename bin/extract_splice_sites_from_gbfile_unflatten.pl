#!/usr/bin/env perl
$| = 1;
use lib "/home/mbasu/bin/projects/SeqToolBox/lib";
use lib "/home/malay/projects/SeqToolBox/lib";
use Bio::SeqIO;
use Bio::SeqFeature::Generic;
use Bio::SeqFeature::Tools::Unflattener;
use Getopt::Long qw (HelpMessage);
use SeqToolBox::Intron;
use SeqToolBox::Config;
use Bio::Root::Exception;
use Error qw (:try);

use strict;
my $file_stamp = SeqToolBox::Config->new()->get_file_stamp(@ARGV);

my $dir;
my $seq_start;
my $seq_end;
my $outfile;
my $logfile = "extract_splice_sites_from_gbfile.log";
my $log     = 0;

#my $ara_genome_dir = "/home/mbasu/genomes/ara";
GetOptions(
	"genome-dir|d=s" => \$dir,

	#"gff-file|f=s"   => \$gff_file,
	"start|s=i"   => \$seq_start,
	"end|e=i"     => \$seq_end,
	"outfile|o=s" => \$outfile,

	#"id|i=s"		=> \$id_regex,
	"help|h" => \&HelpMessage,
	"log|l"  => \$log

	  #	"reverse|r"      => \$reverse,
	  #	"gene=s"		=> \$gene_regex
);

unless ( $dir || $seq_start || $seq_end ) {
	HelpMessage();
	exit 1;
}

my %already_done;

my $outfilehandle;
if ($outfile) {
	if ( -s $outfile ) {
		open( FILE, $outfile ) || die "Can't open $outfile\n";
		while ( my $line = <FILE> ) {
			my @f = split( /\t/, $line );
			$already_done{ $f[0] } = 1;
		}    
		close(FILE);
		open( $outfilehandle, ">>$outfile" )
		  || die "Can't open $outfile\n";
	}
	else {
		open( $outfilehandle, ">$outfile" )
		  || die "Can't open $outfile\n";
		  print $outfilehandle $file_stamp;
		print $outfilehandle
"# Source\tProtein\tGene\tIntron\tStrand\tPhase\tStart\tEnd\tDonor\tAcceptor\n";
	}

}
else {

}

my $logfilehandle;

if ($log) {
	open( $logfilehandle, ">$logfile" ) || die "Can't open $logfile\n";
}

#if ($outfile) {
#	open ($outfilehandle, ">>$outfile") || die "Can't open $outfile\n";
#}

opendir( DIR, $dir ) || die "Can't open $dir\n";

LOOP:
while ( my $file = readdir(DIR) ) {
	next unless $file =~ /\.gbk$/;
	$file =~ /(\S+)\.gbk$/;
	my $base_name = $1;
	if ( exists $already_done{$base_name} ) {
		print STDERR "$base_name already read skipping\n";
		printlog("LOG: $base_name already read skipping");
		next;
	}
	print STDERR $base_name, "\n";
	printlog("LOG: $base_name\n");
	my $full_name = $dir . '/' . $file;
	my $so = Bio::SeqIO->new( -file => $full_name, -format => 'GenBank' );

	#my $so  = Bio::SeqIO->new( -file => $file );
	while ( my $seq = $so->next_seq ) {
		my $unf = Bio::SeqFeature::Tools::Unflattener->new();
		$unf->error_threshold(1);
		
		try {
			$unf->unflatten_seq( -seq => $seq, -use_magic => 1 );
		  }
		  catch Bio::Root::Exception with {
			my $err = shift;
			print STDERR "Error start: $file\n$err\nError end\n";
			printlog("Error start: $file\n$err\nError end\n");
			goto LOOP;
		  };

		foreach my $feat ( $seq->get_SeqFeatures ) {
			unless ( $feat->primary_tag eq 'gene' ) {
				next;
			}
			foreach my $sfeat ( $feat->get_SeqFeatures ) {
				unless ( $sfeat->primary_tag eq 'mRNA' ) {
					next;
				}
				my @tr_id     = $sfeat->get_tag_values("transcript_id");
				my $cds_count = 0;
				foreach my $ssfeat ( $sfeat->get_SeqFeatures ) {
					if ( $ssfeat->primary_tag eq 'CDS' ) {
						$cds_count++;

						if ( $cds_count > 1 ) {
							print STDERR "More than one CDS foudn under",
							  $tr_id[0], "\n";
							my $errstring
							  = "More thatn one CDS in $file " . $tr_id[0];
							printlog("Error: $errstring");
							last;
						}

						my $exons  = "";
						my $strand = '+';
						if (
							 $ssfeat->location->isa(
											  'Bio::Location::SplitLocationI')
						  )
						{
							my $str = $ssfeat->location->to_FTstring;

							if ( $str =~ /complement/ ) {
								$strand = '-';

							}

							my @start;
							my @end;

							foreach
							  my $location ( $ssfeat->location->sub_Location )
							{
								$start[@start] = $location->start;
								$end[@end]     = $location->end;

							}

							my @newstart;
							my @newend;
							my $end_value = $end[$#end];
							@newstart = @start;
							@newend   = @end;

							#	}
							my @temp;

							for ( my $i = 0 ; $i < @newstart ; $i++ ) {

						  #$exons .= $newstart[$i] . '..' . $newend[$i] . ',';
								my $s = $newstart[$i] . '..' . $newend[$i];
								push( @temp, $s );
							}
							$exons = join( ",", @temp );
							my @xref = $ssfeat->get_tag_values("db_xref");
							my $gi;

							#							my $gene_id;

							foreach my $xref (@xref) {
								if ( $xref =~ /GI\:(\d+)/ ) {
									$gi = $1;
									next;
								}

							}

							unless ($gi) { $gi = "NULL"; }

							#my @locus = $feat->get_tag_values("locus_tag");

							print_seq( $base_name, $tr_id[0], $gi, $exons,
									   $seq, $strand );
						}

					}

				}
			}
		}
	}
}

if ($log) {
	close($logfilehandle);
}

if ($outfile) {
	close($outfilehandle);
}

sub printlog {
	my $string = shift;
	print $logfilehandle $string, "\n";
}

sub get_gene_id {
	my $feat = shift;
	my @xref = $feat->get_tag_values("db_xref");
	foreach my $xref (@xref) {
		if ( $xref =~ /GeneID\:(\S+)/ ) {

			#$last_gene_id = $1;
			return $1;
			last;
		}
	}
}

sub print_seq {
	my ( $source, $locus, $gi, $cds, $seq, $strand ) = @_;
	my @intron_position = split( /\.\./, $cds );
	shift(@intron_position);
	pop(@intron_position);
	my @phases
	  = SeqToolBox::Intron->new( ftstring => $cds, strand => $strand )
	  ->get_intron_phases();

	#"Source\tCluster\tGi\tIntron_num\tdonor\tacceptor\n";
	#foreach my $i (@intron_position) {
	for ( my $i = 0 ; $i < @intron_position ; $i++ ) {
		my ( $d, $a ) = split( /\,/, $intron_position[$i] );
		my $d_s;
		my $a_s;
		my $intron_number;
		my $phase;

		#my $length = 0;
		if ( $strand eq '-' ) {
			eval {

				#				$d_s = $seq->subseq( $a - 8, $a + 2 );
				#				$a_s = $seq->subseq( $d - 2, $d + 22 );
				$d_s = $seq->subseq( ( $a - $seq_end ),
									 ( $a + $seq_start ) - 1 );
				$a_s = $seq->subseq( ( $d - $seq_end ) + 1, $d + $seq_start );
			};
			if ($@) {

				#				$ara_seq_in_obj  = undef;
				#				$ara_seq_obj     = undef;
				#				$rice_seq_in_obj = undef;
				#				$rice_seq_obj    = undef;
				#				$last_ara_chr    = undef;
				#				$last_rice_chr   = undef;
				return;

			}
			my $tmp1 = Bio::Seq->new( -seq => $d_s )->revcom()->seq();
			my $tmp2 = Bio::Seq->new( -seq => $a_s )->revcom()->seq();
			$a_s           = $tmp2;
			$d_s           = $tmp1;
			$intron_number = scalar(@intron_position) - $i;

		}
		else {
			eval {

				#
				#				$d_s = $seq->subseq( $d - 2,  $d + 8 );
				#				$a_s = $seq->subseq( $a - 22, $a + 2 );
				$d_s = $seq->subseq( ( $d - $seq_start ) + 1, $d + $seq_end );
				$a_s = $seq->subseq( ( $a - $seq_start ),
									 ( $a + $seq_end ) - 1 );

			};
			if ($@) {

				#				$ara_seq_in_obj  = undef;
				#				$ara_seq_obj     = undef;
				#				$rice_seq_in_obj = undef;
				#				$rice_seq_obj    = undef;
				#				$last_ara_chr    = undef;
				#				$last_rice_chr   = undef;
				return;

			}
			$intron_number = $i + 1;
		}
		if ($outfile) {
			print $outfilehandle join( "\t",
									   $source,
									   $gi,
									   $locus,
									   $intron_number,
									   $strand,
									   $phases[ $intron_number - 1 ],
									   $d,
									   $a,
									   $d_s,
									   $a_s ),
			  "\n";
		}
		else {
			print $outfilehandle join( "\t",
									   $source,
									   $gi,
									   $locus,
									   $intron_number,
									   $strand,
									   $phases[ $intron_number - 1 ],
									   $d,
									   $a,
									   $d_s,
									   $a_s ),
			  "\n";
		}

		#		print join( ",", $d_s, $a_s, $i + 1, ( ( $a - $d ) - 1 ) ), "\n";
	}
}
