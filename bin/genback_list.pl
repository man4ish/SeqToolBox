#!/usr/bin/env perl
use strict;
use Bio::SeqIO;
use Bio::SeqFeature::Generic;

my $file = shift;

my $seqio = Bio::SeqIO->new( -file => $file );

while ( my $seq = $seqio->next_seq() ) {

	my $accession_full = $seq->accession();
	my $gi_full        = $seq->primary_id();
	my $data;
	my $location_start;
	my $location_end;
	my $locus_map;
	my $des;
	my $gi2acc;
	print "Accession\tGi\tGene\tLocus\tLocation\tProtein_GI\tProtein_Acc\tDes\n";

	foreach my $feat ( $seq->get_SeqFeatures() ) {
		my $primary_tag = $feat->primary_tag();
		next unless ( $primary_tag eq "gene" || $primary_tag eq "CDS" );
		if ( $primary_tag eq "gene" ) {
			my $gene;
			my $locus;
			my @temp = $feat->get_tag_values("locus_tag")
			  if ( $feat->has_tag("locus_tag") );
			$locus = $temp[0];
			for my $value ( $feat->get_tag_values("db_xref") ) {
				if ( $value =~ /GeneID/ ) {
					$gene = $value;
					last;
				}
			}
			next unless ( $gene && $locus );
			$location_start->{$gene} = $feat->location()->start() ;
			$location_end->{$gene}   =  $feat->location()->end() ;
			$locus_map->{$gene}      = $locus;

		}

		if ( $primary_tag eq "CDS" ) {
			my $gi;
			my $gene;
			my @temp = $feat->get_tag_values("product")
			  if ( $feat->has_tag("product") );
			my $product = $temp[0];
			@temp = $feat->get_tag_values("protein_id")
			  if ( $feat->has_tag("protein_id") );

			my $protein_id = $temp[0];
			for my $value ( $feat->get_tag_values("db_xref") ) {
				if ( $value =~ /GI\:/ ) {
					$gi = $value;
				} elsif ( $value =~ /GeneID\:/ ) {
					$gene = $value;
				}
			}
			next unless ( $gene && $gi );

			if ( exists $data->{$gene} ) {
				push @{ $data->{$gene} }, $gi;
			} else {
				my @list;
				push @list, $gi;
				$data->{$gene} = \@list;
			}

			$des->{$gi}    = $product;
			$gi2acc->{$gi} = $protein_id;

		}
	}

	foreach my $gene (
		sort {
			$location_start->{$a} <=> $location_start->{$b}
		}
		keys %{$location_start}
	  )
	{
		my @temp;
		push @temp, $accession_full, $gi_full;
		push @temp, $gene,           $locus_map->{$gene};
		my $loc = $location_start->{$gene}.'..'.$location_end->{$gene};
		push @temp, $loc;
		foreach my $cds ( @{ $data->{$gene} } ) {
			push @temp, $cds, $gi2acc->{$cds}, $des->{$cds};
		}
		print join( "\t", @temp ), "\n";
	}

}
