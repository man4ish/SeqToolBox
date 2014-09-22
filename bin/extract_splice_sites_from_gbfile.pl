#!/usr/bin/env perl
$| =1;
use lib "/home/mbasu/bin/projects/SeqToolBox/lib";
use Bio::SeqIO;
use Bio::SeqFeature::Generic;
use Getopt::Long qw (HelpMessage);
use SeqToolBox::Intron;
use SeqToolBox::Config;

use strict;

print SeqToolBox::Config->new()->get_file_stamp(@ARGV);
print "# Source\tProtein\tGene\tIntron\tStrand\tPhase\tStart\tEnd\tDonor\tAcceptor\n";
 
my $dir;
my $seq_start;
my $seq_end;

#my $ara_genome_dir = "/home/mbasu/genomes/ara";
GetOptions(
	"genome-dir|d=s" => \$dir,

	#"gff-file|f=s"   => \$gff_file,
	"start|s=i" => \$seq_start,
	"end|e=i"   => \$seq_end,

	#"id|i=s"		=> \$id_regex,
	"help|h" => \&HelpMessage,

	#	"reverse|r"      => \$reverse,
	#	"gene=s"		=> \$gene_regex
);

unless ( $dir || $seq_start || $seq_end ) {
	HelpMessage();
	exit 1;
}


opendir( DIR, $dir ) || die "Can't open $dir\n";

while ( my $file = readdir(DIR) ) {
	next unless $file =~ /\.gbk$/;
	$file =~ /(\S+)\.gbk$/;
	my $base_name = $1;
	print STDERR $base_name, "\n";
	my $full_name = $dir . '/' . $file;
	my $so        = Bio::SeqIO->new( -file => $full_name );

	#my $so  = Bio::SeqIO->new( -file => $file );
	while ( my $seq = $so->next_seq ) {

		# my $gp = Bio::DB::GenPept->new();
		# my $gb = Bio::DB::GenBank->new();
		#my $gi = '78183424';
		# my $prot_obj = $gp->get_Seq_by_id('78183424');

		foreach my $feat ( $seq->top_SeqFeatures ) {
			if ( $feat->primary_tag eq 'CDS' ) {
				my $exons  = "";
				my $strand = '+';
				if ( $feat->location->isa('Bio::Location::SplitLocationI') ) {
					my $str = $feat->location->to_FTstring;

					if ( $str =~ /complement/ ) {
						$strand = '-';

					}

					my @start;
					my @end;

					foreach my $location ( $feat->location->sub_Location ) {

					   #print STDERR $location->to_FTstring,"\n";
					   #print STDERR "Max end:", $location->max_end,"\n";
					   # print STDERR "min start:", $location->min_start,"\n";
						$start[@start] = $location->start;
						$end[@end]     = $location->end;

					}

					my @newstart;
					my @newend;
					my $end_value = $end[$#end];

					#	if ( $strand eq '-' ) {

					#					foreach my $s ( sort { $b <=> $a } @start ) {
					#						$newend[@newend] = ( $end_value - $s ) + 1;
					#
					#					}
					#					foreach my $e ( sort { $b <=> $a } @end ) {
					#						$newstart[@newstart] = ( $end_value - $e ) + 1;
					#
					#					}
					#	}
					#	else {
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
					my @xref = $feat->get_tag_values("db_xref");
					my $gi;
					foreach my $xref (@xref) {
						if ( $xref =~ /GI\:(\d+)/ ) {
							$gi = $1;
							last;
						}
					}    
					
					my @locus = $feat->get_tag_values("locus_tag");
					
					
					print_seq($base_name,$locus[0],$gi, $exons, $seq, $strand );
				}

			   #				else {
			   #					my $str = $feat->location->to_FTstring;
			   #					if ( $str =~ /complement/ ) {
			   #						$strand = '-';
			   #					}
			   #					$exons
			   #					  = $feat->location->start . '..' . $feat->location->end;
			   #
			   #				}
			   #
			   #				my @ids = $feat->get_tag_values("protein_id");
			   #
			   #				#my @start = $feat->get_tag_values ("codon_start");
			   #				my @xref = $feat->get_tag_values("db_xref");
			   #				my $gi;
			   #				foreach my $xref (@xref) {
			   #					if ( $xref =~ /GI\:(\d+)/ ) {
			   #						$gi = $1;
			   #						last;
			   #					}
			   #				}
			   #
			   #				next unless $gi;
			   #				print $file, "\t";
			   #
			   #				#print join( ",", @ids ), "\t";
			   #				print STDERR $base_name, "\t";
			   #				print STDERR join( ",", @ids ),  "\t";
			   #				print STDERR join( ",", @xref ), "\t";
			   #
			   #				#print join( ",",        @xref ), "\t";
			   #				print $gi, "\t";
			   #
			   #				#print join (",", @start), "\t";
			   #				#print STDERR join(",", @start),"\t";
			   #				print $strand, "\t";
			   #				print STDERR $strand, "\t";
			   #				print STDERR $exons;
			   #				print $exons;
			   #				print "\n";
			   #				print STDERR "\n";
			   #
			   #
			}

		}
	}
}

sub print_seq {
	my ( $source,$locus,$gi,$cds, $seq, $strand ) = @_;
	my @intron_position = split( /\.\./, $cds );
	shift(@intron_position);
	pop(@intron_position);
	my @phases;
	eval {
	 @phases= SeqToolBox::Intron->new (ftstring=>$cds,strand => $strand)->get_intron_phases();
	};
	if ($@) {
		print STDERR "$gi in $source has problem in parsing phase\n";
		return;	
		}
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
				$d_s = $seq->subseq( ($a - $seq_end), ($a + $seq_start) - 1 );
				$a_s = $seq->subseq( ($d - $seq_end) + 1, $d + $seq_start );
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
			$a_s = $tmp2;
			$d_s = $tmp1;
			$intron_number = scalar(@intron_position) - $i;

		}
		else {
			eval {
#
#				$d_s = $seq->subseq( $d - 2,  $d + 8 );
#				$a_s = $seq->subseq( $a - 22, $a + 2 );
				$d_s = $seq->subseq( ($d - $seq_start) + 1,  $d + $seq_end );
				$a_s = $seq->subseq( ($a - $seq_start), ($a + $seq_end) -1  );
				
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
			$intron_number = $i + 1
		}
		print join( "\t", $source,$gi,$locus,$intron_number,$strand,$phases[$intron_number -1 ],$d,$a,$d_s, $a_s), "\n";
#		print join( ",", $d_s, $a_s, $i + 1, ( ( $a - $d ) - 1 ) ), "\n";
	}
}
