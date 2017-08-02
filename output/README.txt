This directory stores the output files, which are consisted of
featsel DAT format. A sample of this format is given below.

If we have 5 samples for a feature selection problem with 8
features and 4 classes, a corresponding featsel DAT file 
should be something like this:

1 0  2 0 0  0 0  1 0    1 0 4  0
2 1  0 0 4  2 1 11 0    1 0 7  6
0 0 12 4 0 22 1  1 4    1 1 0 10
1 0  2 4 3  2 1  1 7   30 0 9  6
7 0 10 0 1  3 10 9 8    0 1 4  0

Each line corresponds to a sample. The first 8 columns are
the ordered set of features, while the last 4 columns are the
ordered set of labels.

For each sample, we have a set of observed values of the features.
Finally, for each sample and for each set of observed values, there
is the number of times each label was observed.



