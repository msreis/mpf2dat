# mpf2dat
A program to read a [Multiple Pattern Feature (MPF)](http://www.nlpr.ia.ac.cn/databases/download/feature_data/FileFormat-mpf.pdf) file, discretize it, and save the results into a featsel DAT format file.

MPF file format is used to store feature selection data in the [CASIA Online and Offline Chinese Handwriting Databases](http://www.nlpr.ia.ac.cn/databases/handwriting/Home.html).

featsel DAT is the native feature selection data format in [featsel](https://github.com/msreis/featsel), a framework for benchmarking of feature selection algorithms and cost functions.

## Requirements

* C compiler (e.g. gcc);
* Perl interpreter.

## Syntax

First, compile the filter program, which is coded in C:

```
> gcc -ansi -pedantic -Wall -o bin/filter_Chinese_handwriting_sample src/filter_Chinese_handwriting_sample.c 
```

Then you can call the main program through the Perl interpreter:

```
> perl bin/mpf2dat.pl database
```
where `database' is [one of the four databases](http://www.nlpr.ia.ac.cn/databases/handwriting/Download.html) listed in the CASIA databases web site (as of this date, HWDB1.0, HWDB1.1, OLHWDB1.0, and OLHWDB1.1).
