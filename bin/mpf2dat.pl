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
(@ARGV == 1) or die "Syntax: $0 database\n";

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
  system ("./$FILTER_BINARY $input_file > $tmp_file");

  open (INPUT, $tmp_file) or die "ERROR: Could not open tmp file!\n";

  $_ = <INPUT>;  # Size of file header.
  $_ = <INPUT>;  # Format code.
  $_ = <INPUT>;  # Illustration.
  $_ = <INPUT>;  # Code type.
  $_ = <INPUT>;  # Code length.
  $_ = <INPUT>;  # Data type.

  # Now we have one pair <label, pixel set> per line, in the following format:
  #
  # b6f3  11  11   0   3   8   1   0   0  16   4   0  14  14   1   0   0  34  22   3  37  11  22  10   8  26  17   9  43  15  34  25  12  11   4  15  33  16  27   7  15  39  11  25  26  27  22   1  18  35   6 31  16  41  16   0   3  18   2  11   4  27   8   0   0  25  17   1   4  26  26  20   5  22   4   1  18  19  10  12   2   1   1   1  19   7  20  11   4  25   8   3   9   3   7  16   8  44   4   6  13   4   8  11  22  14   2   8   9   6   6   4  36  22   2  11   6   3   4  19  29   2   0   1   0   0   3   8   2  19  17  10   1  14  37  38  15  13   5   2   0   3   8  30  16   0   2   3   0   0   7  15   5   4   5   8   0   0   1   3   1   9   1   0   0   0   5  10   3   3   0   0   0   0   0   1   1   6   0   0   0   0   8  27  10   0   0   0   0   0  11  16   2   0  20  39   4   0   0   1   8   0   1   6   1   1   0   2  15   0   4   3   0   0   2   2   8   0   9   8   0   0   8   6   1   0   2   0   1   0   5   4   4   1   2   0   0   0   1   0   1   5   2   0   0   1   9   1   0   1   2   0   0   1   7  1   0   0   3   9   3   1   0   1   7   0   7  13   5  23   4   0   5   0  32  14   7  43   9   8  36   0  20  10  18  34  24  26  36   2  37   8  29  22   8  13  32   3  49   9  40  12  29   8  25   4  51  13  38   6  35   6  17   2  36   9  10   1   5   1   2   0   1   3   1   1   7  21  21   2  13  31   3  12  16  11   4   1   8   8   2  14   6  14   5   0  14  19   5  10   3   6  14   7  19   9   9  7   3  17  19  10   7   2  14   5  10  12  10   1   2   3  21   2   8   2  26   1  13   5  14   1   6  15  29   0   0   1   0   2  16  25   7  16   6  11   1   7  27  18   3  15   2   1   0   0   4  25   5   0   0   0   0   0   1   2   0   7   1   0   0   0   4  11   1  16   1   0   0   0   7  21   1   1   0   1   1   0   0   1   3   4   8   6   8   4  25  34  22   0   1   0   0   1   1   0   0  11   4   0   0   1 
  #
  # That is, a code ("b6f3") which corresponds to the observed Chinese ideogram
  # and 512 grayscale pixels (features) that were observed.
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
open (OUTPUT, ">$output_file") or die "ERROR: Could not open output file!\n";

my $label_index = 0;

foreach my $realization (sort keys (%histogram))
{
  print OUTPUT $realization . "   ";

  foreach my $label (sort keys (%label))
  {
    if (defined ($histogram{$realization}->{$label}))
    {
      print OUTPUT $histogram{$realization}->{$label} . " ";
    }
    else
    {
      print OUTPUT "0 ";
    }
  }

  print OUTPUT "\n";
}

close (OUTPUT);

system ("rm $tmp_file");

# End of program.
#
exit 0;


