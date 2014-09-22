#!/usr/bin/perl -w
#!/usr/bin/perl -w
$| = 1;
use lib "/home/mbasu/bin/projects/SeqToolBox/lib";
use Bio::SeqIO;
use Bio::SeqFeature::Generic;
use strict;
use Getopt::Long qw (HelpMessage);
use SeqToolBox::Intron;
use SeqToolBox::Config;

print SeqToolBox::Config->new()->get_file_stamp(@ARGV);
print
"# Source\tProtein\tGene\tIntron\tStrand\tPhase\tStart\tEnd\tDonor\tAcceptor\n";
my $dir;
my $gff_file;
my $seq_start;
my $seq_end;
my $reverse = 0;
my $id_regex;
my $gene_regex;

GetOptions(
			"genome-dir|d=s" => \$dir,
			"gff-file|f=s"   => \$gff_file,
			"start|s=i"      => \$seq_start,
			"end|e=i"        => \$seq_end,
			"id|i=s"         => \$id_regex,
			"help|h"         => \&HelpMessage,
			"reverse|r"      => \$reverse,
			"gene=s"         => \$gene_regex
);

unless ( $dir || $gff_file || $seq_start || $seq_end || $id_regex ) {
	HelpMessage();
	exit 1;
}

#my $ara_genome_dir = "/home/mbasu/genomes/ara";
open( FILE, $gff_file ) || die "Can't open $gff_file\n";

my @last_cdna;
my $last_mrna_start;
my $last_mrna_end;
my $last_id    = "";
my $last_locus = "";
my $last_strand;
my $last_source = "";
my $last_att    = "";

while ( my $line = <FILE> ) {
	next if $line =~ /^\#/;
	chomp $line;
	if ( !defined($line) || $line eq "" ) {
		next;
	}
	print STDERR "Line $line\n";
	my @f       = split( /\t/, $line );
	my $source  = $f[0];
	my $feature = $f[2];
	my $start   = $f[3];
	my $end     = $f[4];
	my $strand  = $f[6];
	my $att     = $f[8];
	next unless $feature eq "CDS";
	$att =~ /$id_regex/;
	my $id = $1 if $1;
	my $add_id;

	#$att =~ /locus_id\s+\"(\S+)\"/;
	#my $locus_id = $1;
	next unless $id;
	print STDERR $id, "\n";
	if ($gene_regex) {
		if ( $att =~ /$gene_regex/ ) {
			$add_id = $1;
		} else {
			$add_id = "-";
		}

	} else {
		$add_id = "-";
	}
	if ( $feature eq 'CDS' && $id ne $last_id ) {
		if ($last_id) {
			print STDERR "$last_id\n";
			if ( @last_cdna > 1 ) {
				extract_seq( $last_id, $last_att, $last_strand, $last_source,
							 join( ",", @last_cdna ) );
			} else {
				print STDERR "$last_id does not have introns skipping\n";
			}

			#			if ( $last_strand eq '+' ) {
			#				print $last_source, "\t", $last_id, "\t", $last_strand, "\t",
			#				  join( ",", @last_cdna ), "\n";
			#
			#				#print $last_cdna, "\n";
			#			}
			#			else {
			#				print $last_source, "\t", $last_id, "\t", $last_strand, "\t",
			#				  join( ",", @last_cdna ), "\n";
			#
			#				#print reverse_cds($last_cdna), "\n";
			#			}
		}
		$last_mrna_start = $start;
		$last_mrna_end   = $end;
		$last_strand     = $strand;
		@last_cdna       = ();
		$last_id         = $id;
		$last_source     = $source;
		$last_att        = $add_id;

		#$last_locus      = $locus_id;
	}
	if ( $feature eq 'CDS' && $id eq $last_id ) {

		#if ( $strand eq '+' && $id eq $last_id ) {
		my $temp .= $start . '..' . $end;

		#push @last_cdna,
		push @last_cdna, $temp;

		#		} elsif ( $strand eq '-' && $id eq $last_id ) {
		#			my $new_start = ( $last_mrna_end - $end ) + 1;
		#			my $new_end   = ( $last_mrna_end - $start ) + 1;
		#			$last_cdna .= $new_start . '..' . $new_end . ',';
		#		}
	}
}
if ($last_id) {
	print STDERR "$last_id\n";
	if ( @last_cdna > 1 ) {
		extract_seq( $last_id, $last_att, $last_strand, $last_source,
					 join( ",", @last_cdna ) );
	} else {
		print STDERR "$last_id does not have introns skipping\n";
	}

#print $last_source,"\t",$last_id,"\t","", "\t", $last_locus, "\t", $last_strand, "\t";
#print $last_id, "\t", $last_locus, "\t", $last_strand, "\t";
#	if ( $last_strand eq '+' ) {
#		print $last_source, "\t", $last_id, "\t", $last_strand, "\t",
#		  join( ",", @last_cdna ), "\n";
#
#	 #print " ",$last_id,",",scalar(@last_cdna),",",join(",",@last_cdna),"\n";
#	 #print $last_cdna, "\n";
#	}
#	else {
#		print $last_source, "\t", $last_id, "\t", $last_strand, "\t",
#		  join( ",", @last_cdna ), "\n";

	#print "c",$last_id,",",scalar(@last_cdna),",",join(",",@last_cdna),"\n";
	#print reverse_cds($last_cdna), "\n";
	#	}
}
close FILE;

my $persist;
my $source_string;

sub extract_seq {
	my ( $id, $att, $strand, $source, $ftstring ) = @_;
	opendir( DIR, $dir ) || die "Can't open $dir\n";
	my $so;

	if ( $persist && $source_string eq $source ) {
		$so = $persist;
	} else {
		my $full_name;
		while ( my $file = readdir(DIR) ) {
			next
			  unless $file =~ /\.$source\.fas$/
				  || $file =~ /\.$source\.fa$/
				  || $file =~ /$source\.fas$/;

			#$file =~ /(\S+)\.gbk$/;
			#my $base_name = $1;
			#print STDERR $base_name,"\n";
			$full_name = $dir . '/' . $file;
			last;
		}
		close DIR;
		if ($full_name) {
			print STDERR $full_name, "\n";
		} else {
			print STDERR "Error: $source not found\n";
			return;
		}
		
		my $seqio = Bio::SeqIO->new( -file => $full_name );
		$so            = $seqio->next_seq;
		$source_string = $source;
		$persist       = $so;
	}

	#my $so  = Bio::SeqIO->new( -file => $file );
	my $cds = $ftstring;
	print STDERR "FT: $ftstring\n strand: $strand\n";
	if ( $strand eq '-' && $reverse ) {
		$cds = get_reverse_cds($ftstring);
	}
	print STDERR "cds: $cds\n";

	print_seq( $id, $att, $source, $cds, $so, $strand );
}

sub get_reverse_cds {
	my $ft_string = shift;

	#	my @start;
	#	my @end;
	my @ft = split( /\,/, $ft_string );

	#
	#	#my $number = scalar(@ft);
	#	my $last_s = 0;
	#	my $last_e = 0;
	#	foreach my $f (@ft) {
	#		my ( $s, $e ) = split( /\.\./, $f );
	#		if ( $s > $e ) { die "Something wrong $ft_string\n"; }
	#
	#		#		if ( $last_s > $s ) { die "Ordering problem in start\n"; }
	#		#		if ( $last_e > $e ) { die "Ordering problem in end\n"; }
	#		#		$last_s = $s;
	#		#		$last_e = $e;
	#		push @start, $s;
	#		push @end,   $e;
	#	}
	#	if ( scalar(@start) != scalar(@end) ) {
	#		die "Start and end should be equal in number\n";
	#	}
	#	my @reverse_start = reverse(@start);
	#	my @reverse_end   = reverse(@end);
	#
	#	#my $end_point     = $end[$#end];
	#	my @s;
	#	for ( my $i = 0 ; $i < @reverse_start ; $i++ ) {
	#
	#		#my $temp = ( $end_point - $reverse_end[$i]) + 1;
	#		my $temp = $reverse_start[$i];
	#		$temp .= '..';
	#
	#		#$temp .= ( $end_point - $reverse_start[$i] ) + 1;
	#		$temp .= $reverse_end[$i];
	#		push @s, $temp;
	#
	#	}

	#print STDERR join( ",", $number, @s ),"\n";
	return join( ",", reverse(@ft) );

}

sub print_seq {
	my ( $id, $att, $source, $cds, $seq, $strand ) = @_;
	my @intron_position = split( /\.\./, $cds );
	shift(@intron_position);
	pop(@intron_position);

	my @phases
	  = SeqToolBox::Intron->new( ftstring => $cds, strand => $strand )
	  ->get_intron_phases();

	#	my @test_cds = split (/\,/, $cds);
	#	foreach my $t_c (@test_cds) {
	#		my ($td, $ta) = split (/\.\./, $t_c);
	#
	#		my $t_s = $seq->subseq($td, $ta);
	#		print STDERR Bio::Seq->new(-seq=>$t_s)->revcom()->seq,"\n";
	#	}

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

			#my $cds_seq = $seq->subseq($d, $a);
			#print Bio::Seq->new(-seq => $cds_seq)->revcom()->seq(),"\n";
			eval {
				$d_s
				  = $seq->subseq( ( $a - $seq_end ),
								  ( $a + $seq_start ) - 1 );
				$a_s = $seq->subseq( ( $d - $seq_end ) + 1, $d + $seq_start );
			};
			if ($@) {
				return;

			}
			my $tmp1 = Bio::Seq->new( -seq => $d_s )->revcom()->seq();
			my $tmp2 = Bio::Seq->new( -seq => $a_s )->revcom()->seq();
			$a_s           = $tmp2;
			$d_s           = $tmp1;
			$intron_number = scalar(@intron_position) - $i;

			#$phase = $phases[$intron_number - 1];
		} else {
			eval {

				$d_s = $seq->subseq( ( $d - $seq_start ) + 1, $d + $seq_end );
				$a_s = $seq->subseq( ( $a - $seq_start ),
									 ( $a + $seq_end ) - 1 );
			};
			if ($@) {
				return;

			}
			$intron_number = $i + 1;
		}

		print join( "\t",
					$source, $id, $att, $intron_number, $strand,
					$phases[ $intron_number - 1 ],
					$d, $a, $d_s, $a_s ),
		  "\n";
	}
}

__END__


=head1 NAME

=head1 SYNOPSIS




=cut


















