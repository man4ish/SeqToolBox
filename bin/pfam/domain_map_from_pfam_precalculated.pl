#!/usr/bin/perl -w
use lib '/home/malay/code/SeqToolBox/lib';
use SeqToolBox;
use SeqToolBox::Interval::Range;
use SeqToolBox::Interval::Tree;
use SeqToolBox::File;
use File::Basename;
use Getopt::Long;
use strict;

my $result = "";

my %promis;
my %seen;
my $protein_index = 0;
my $domain_index  = 0;
my %domain_seen;
my %protein_seen;
my %domain_des;

#my $cutoff       = undef;
my $replace_clan = 1;

#GetOptions( "cutoff=s" => \$cutoff,
#			"clan"     => \$replace_clan );

my $filename = shift @ARGV;

#my $fullname = fileparse("$filename");
#my $basename;
#
#if ( $fullname =~ /^(\S+)\./ ) {
#	$basename = $1;
#} else {
#	die "Can't parse basename from $fullname\n";
#}
#print $basename, "\n";
my $filehandle = undef;

if ($filename) {
	my $file = SeqToolBox::File->new( -file => $filename );
	$filehandle = $file->get_fh();
}else {
	$filehandle = \*STDIN;
}


#if ( $filename =~ /\.gz$/ ) {
#	open( $filehandle, "gunzip -c $filename |" )
#	  || die "Can't open $filename";
#} elsif ( $filename =~ /\.bz2$/ ) {
#	open( $filehandle, "bunzip2 -c $filename |" )
#	  || die "Can't open $filename\n";
#} else {
#	open( $filehandle, $filename ) || die "Can't open $filename \n";
#}

#my $protein_index_file = $basename . '.protiens';
#open( PI, ">$protein_index_file" ) || die "Can't open $protein_index_file\n";
#my $domain_index_file = $basename . '.domains';
#open( DI, ">$domain_index_file" ) || die "Can't open $domain_index_file\n";

my $last_query = undef;    # a buffer to accumulate results
my @domains;
my @domain_start;
my @domain_end;
my @domain_type;
while ( my $line = <$filehandle> ) {
	
	chomp $line;
	next unless $line;
	#print STDERR "$line\n";
	next if ( $line =~ /^\#/ );
	my @flds = split( /\t/, $line );

	#next unless ($flds[8]=~ /domain/i || $flds[8] =~ /family/i);

	# skip if the the e-value is higher than the cutoff
	#	if ( defined($cutoff) && $cutoff < $flds[13] ) {
	#		next;
	#	}

	#	if ( defined( $flds[2] ) ) {    # If there is domain hits

	#We are only looking for smart and PFAM
	#		if (    $flds[2] =~ /^cog/i
	#			 || $flds[2] =~ /^cd/i
	#			 || $flds[2] =~ /^prk/i )
	#		{
	#			next;
	#		}

	#		$domain_des{ $flds[2] } = $flds[10];

	# First line no previous record
	

	if ( !$last_query ) {
		$last_query = $flds[0];
		if ( $replace_clan && $flds[13] ne 'No_clan' ) {
			$domains[@domains] = $flds[13];
		} else {
			$domains[@domains] = $flds[5];
		}

		$domain_start[@domain_start] = $flds[1];
		$domain_end[@domain_end]     = $flds[2];
		$domain_type[@domain_type] = $flds[7];
		next;
	}

	# Gone to a new gene
	if ( $flds[0] ne $last_query ) {
		print STDERR "New protein: $last_query\n";
		find_promisquity( \@domains,   \@domain_start, \@domain_end,
						  $last_query, \@domain_type );

		$last_query   = $flds[0];
		@domains      = ();
		@domain_start = ();
		@domain_end   = ();
		@domain_type  = ();
		if ( $replace_clan && $flds[13] ne 'No_clan' ) {
			$domains[@domains] = $flds[13];
		} else {
			$domains[@domains] = $flds[5];
		}

		#		$domains[@domains]           = $flds[2];
		$domain_start[@domain_start] = $flds[1];
		$domain_end[@domain_end]     = $flds[2];
		$domain_type[@domain_type] = $flds[7];

	} else {    # Same gene: read domains keep the gene id same
		if ( $replace_clan && $flds[13] ne 'No_clan' ) {
			$domains[@domains] = $flds[13];
		} else {
			$domains[@domains] = $flds[5];
		}

		#		$domains[@domains]           = $flds[2];
		$domain_start[@domain_start] = $flds[1];
		$domain_end[@domain_end]     = $flds[2];
		$domain_type[@domain_type] = $flds[7];
	}
}

#else {          # No domain hits.
#	$result .= $flds[0] . "\n";
#
#	#print PI $protein_index,"\t",$flds[0],"\n";
#}
#}

# Outside the loop but still have one gene in buffer
find_promisquity( \@domains,   \@domain_start, \@domain_end,
				  $last_query, \@domain_type );

my $total_domains = 0;
foreach my $element (
					  sort { $domain_seen{$a} <=> $domain_seen{$b} }
					  keys %domain_seen
  )
{

	#print DI "$element\t$domain_seen{$element}\t$domain_des{$element}\n";
	$total_domains++;
}

#print $result;
print "\# Total domain: $total_domains\n";
print $result;

#close(DI);
#close(PI);
#close($filehandle);
#$file->close();
exit 0;

sub find_promisquity {

	#print STDERR "Function called\n";
	my @args = @_;

	my @domains = @{ $args[0] };    # domain name list
	my @start   = @{ $args[1] };    # start of each domain
	my @end     = @{ $args[2] };    # end of each domain
	my $index   = $args[3];         # Gene name?
	my @types   = @{ $args[4] };

	#    if ( @domains != @start != @end ) {
	#        die "Some error in parsing\n";
	#    }
	my @rest_domains;
	my @rest_start;
	my @rest_end;
	my @priorities =
	  ( "Family", "Domain", "Motif", "Repeat", "Coiled-coil", "Disordered" );
	 print STDERR "Protein: $index domain found: @types", "\n";
	
	my $tree = SeqToolBox::Interval::Tree->new();
	
	foreach my $t (@priorities) {
		
		for ( my $i = 0 ; $i < @domains ; $i++ ) {
			
			#Insert SMART domain first
			if ( $types[$i] =~ /$t/i ) {
				print STDERR  $t, "\t", $domains[$i], "\n";
				my $range =
				  SeqToolBox::Interval::Range->new( $domains[$i], $start[$i],
													$end[$i] );
				$tree->insert($range);
			} 
			
#			else {    #Keep the rest of the domains in a buffer
#				$rest_domains[@rest_domains] = $domains[$i];
#				$rest_start[@rest_start]     = $start[$i];
#				$rest_end[@rest_end]         = $end[$i];
#			}
		}
	}

#	#Now insert rest of the domains
#	for ( my $i = 0 ; $i < @rest_domains ; $i++ ) {
#		my $range =
#		  SeqToolBox::Interval::Range->new( $rest_domains[$i], $rest_start[$i],
#											$rest_end[$i] );
#		$tree->insert($range);
#	}

	my $s = $tree->get_tree();
	$result .= "$index\t$s\n";

	my @d = $tree->get_names();

	#print STDERR "Domains: @d\n";
	my @index_d;

	foreach my $domain (@d) {
		if ( exists( $domain_seen{$domain} ) ) {
			$index_d[@index_d] = $domain_seen{$domain};

		} else {
			$domain_seen{$domain} = ++$domain_index;
			$index_d[@index_d] = $domain_seen{$domain};
		}

	}

	#   $s = "$index\t";
	#    $s .= join( "\t", @index_d );
	#    $s .= "\n";

	# print $s;
	# $result .= $s;

	#    if (@d == 1) {
	#	return;
	#    }

	# for (my $i = 0; $i <@d; $i++) {

	#	if ($d[$i] !~ /^smart/i) {  #ignore anything except smart
	#	    next;
	#	}

   #	if ($i == 0 && ($d[$i] ne $d[$i+1]) ) {          #if it is the first domain
   #	   my  $key1 = $d[$i].'+'.$d[$i+1];
   #	   my  $key2 = $d[$i+1].'+'.$d[$i];
   #	    if (!exists $seen{$key1} && !exists $seen{$key2} ) {
   #		$promis{$d[$i]}++;
   #		$seen{$key1} = 1;
   #		$seen{$key2} = 1;
   #	    }
   #	   next;
   #       }

	#	if ($i == $#d && ($d[$i] ne $d[$i-1]) ) {
	#	    my $key1 = $d[$i].'+'.$d[$i-1];
	#	    my $key2 = $d[$i-1].'+'.$d[$i];
	#	    if (!exists $seen{$key1} && !exists $seen{$key2} ) {
	#		$promis{$d[$i]}++;
	#		$seen{$key1} = 1;
	#		$seen{$key2} = 1;
	#	    }
	#	    next;
	#	}

	#	if ( ($d[$i] eq  $d[$i-1]) && ($d[$i] ne $d[$i+1])) {
	#	    my $key1 = $d[$i].'+'.$d[$i+1];
	#	    my $key2 = $d[$i+1].'+'.$d[$i];
	#	    if (!exists $seen{$key1} && !exists $seen{$key2}) {
	#		$promis{$d[$i]}++;
	#		$seen{$key1} = 1;
	#		$seen{$key2} = 1;
	#	    }
	#	    next;
	#	}

	#	if ( ($d[$i] eq  $d[$i+1]) && ($d[$i] ne $d[$i-1])) {
	#	    my $key1 = $d[$i].'+'.$d[$i-1];
	#	    my $key2 = $d[$i-1].'+'.$d[$i];
	#	    if (!exists $seen{$key1} && !exists $seen{$key2}) {
	#		$promis{$d[$i]}++;
	#		$seen{$key1} = 1;
	#		$seen{$key2} = 1;
	#	    }
	#	    next;
	#	}

	#    }

}

