#!/usr/bin/perl -w

#------------------------------------------------------------------------------#
#
# Program to convert a set of Multiple Pattern Feature (MPF) files, a format
# used in the Chinese handwriting database, into a file in featsel DAT format. 
# 
# This program requires the "filter_Chinese_handwriting_sample" binary.
#
# The MPF description can be found at the following link:
#
# http:#www.nlpr.ia.ac.cn/databases/download/feature_data/FileFormat-mpf.pdf
#  
#    Copyright (C) 2017 Marcelo S. Reis
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http:www.gnu.org/licenses/>.
#
#------------------------------------------------------------------------------#


use strict;


# The total number of features.
#
my $DIMENSIONALITY = 512;

# A matrix to store the pairs <label, pixel set> observed in the samples.
#
my @observation;

# A matrix to store the order statistics of each feature.
#
my @order_statistics;

# A hash to build a histogram as a function of the observations.
#
my %histogram;

# A hash to have a global register of all labels (Chinese characters).
#
my %label;

# Input, output and exec files.
#
my $INPUT_DIR = "input/";
my $OUTPUT_DIR = "output/";
my $FILTER_BINARY = "bin/filter_Chinese_handwriting_sample";

# Processing the arguments.
#
@ARGV == 1 or die "Syntax: $0 database\n";

my $DATABASE = $ARGV[0];

my ($first_file, $last_file);

if ($DATABASE eq "HWDB1.0")
{
  $first_file = 1;
  $last_file  = 420;
}
elsif ($DATABASE eq "HWDB1.1")
{
  $first_file = 1001;
  $last_file  = 1240;
}
elsif ($DATABASE eq "OLHWDB1.0")
{
  $first_file = 1;
  $last_file  = 420;
}
elsif ($DATABASE eq "OLHWDB1.1")
{
  $first_file = 1001;
  $last_file  = 1240;
}
else
{
  die "Error: unknown database $DATABASE!\n";
}

my $tmp_file    = $OUTPUT_DIR . "/tmp.txt";

my $number_of_samples = 0;

foreach my $i ($first_file..$last_file)
{
  my $file_index = sprintf "%03d", $i;

  my $input_file  = $INPUT_DIR  . $DATABASE . "/" . $file_index . ".mpf";

  # Run the C program coded to filter each of the mpf files.
  #
  system "./$FILTER_BINARY $input_file > $tmp_file";

  open INPUT, $tmp_file or die "ERROR: Could not open tmp file!\n";

  $_ = <INPUT>;  # Size of file header.
  $_ = <INPUT>;  # Format code.
  $_ = <INPUT>;  # Illustration.
  $_ = <INPUT>;  # Code type.
  $_ = <INPUT>;  # Code length.
  $_ = <INPUT>;  # Data type.

  # Now we have one pair <label, pixel set> per line, in the following format:
  #
  # b6f3  7  11   0   3   8   1   0   0  ... 
  #
  # That is, a code ("b6f3") which corresponds to the observed Chinese ideogram
  # and 512 grayscale pixels (features) that were observed, each one ranging
  # from 0 to 255.
  #
  while (<INPUT>)
  {
    chomp $_;
    my @line = split /\s+/, $_;

    # If the current label was not stored, we do it now.
    #    
    if (! defined ($label{$line[0]})) 
    { 
      $label{$line[0]} = 1;
    }

    foreach my $index (0..$DIMENSIONALITY) # we also store the label at index 0.
    {
      $observation[$number_of_samples]->[$index] = $line[$index];
      push @{$order_statistics[$index]}, $line[$index];
    } 
    $number_of_samples++;
  }
  close (INPUT);
}

# Now we compute the order statistics for each feature.
#
foreach my $index (1..$DIMENSIONALITY)
{
  @{$order_statistics[$index]} = sort @{$order_statistics[$index]};
}

# With the computed order statistics, one quartile is $number_of_samples / 4,
# two quartiles is $number_of_samples / 2, and so forth.
#
my $quartile_1 = int ((1 * $number_of_samples) / 4);
my $quartile_2 = int ((2 * $number_of_samples) / 4);
my $quartile_3 = int ((3 * $number_of_samples) / 4);

# Now we compute the final histogram of frequencies.
#
foreach my $k (0..($number_of_samples - 1))
{
  my $realization = "";

  foreach my $index (1..$DIMENSIONALITY)
  {
    if ($observation[$k]->[$index] <= $order_statistics[$index]->[$quartile_1])
    {
      $realization .= " 0";
    }
    elsif($observation[$k]->[$index] <=$order_statistics[$index]->[$quartile_2])
    {
      $realization .= " 1";
    }
    elsif($observation[$k]->[$index] <=$order_statistics[$index]->[$quartile_3])
    {
      $realization .= " 2";
    }
    else
    {
      $realization .= " 3";
    }
  }
  $histogram{$realization}->{$observation[$k]->[0]}++;
}

# Write the histogram into the output DAT file.
#
my $output_file = $OUTPUT_DIR . $DATABASE . ".dat";
open OUTPUT, ">$output_file" or die "ERROR: Could not open output file!\n";

my $label_index = 0;

foreach my $realization (sort keys %histogram)
{
  print OUTPUT $realization . "   ";

  foreach my $label (sort keys %label)
  {
    defined $histogram{$realization}->{$label}
      and print OUTPUT $histogram{$realization}->{$label} . " "
       or print OUTPUT "0 ";
  }

  print OUTPUT "\n";
}
close OUTPUT;

system "rm $tmp_file";

# End of program.
#
exit 0;


