---
layout: page
title: "Software - Daniel Marcelino"
---

## R Packages ##

Here are a few of the R packages I've been developing on my own.

**SciencesPo: A Tool Set for Analyzing Political Behavior Data**<br/>
The [SciencesPo project](http://cran.r-project.org/web/packages/SciencesPo/index.html) is an effort to put some of the most common analysis involving political behavior data in to R. The first functions were bundled and uploaded to [CRAN](https://cran.r-project.org) in 2013. Although it's far from completed, several algorithms are quite mature. See the [SciencesPo development repository](https://github.com/danielmarcelino/SciencesPo) for more details.

**SoundexBR: Phonetic-Coding for Portuguese**<br/>
The aim of rio is to make data file I/O in R as easy as possible by implementing data import and export for R that relies on file extensions to make a (reasonable) assumption about how to read a file into a data.frame or, conversely, save a data.frame to disk. It greatly simplifies data import and export and offers a function for easily converting between file formats (possibly from the command line). <br/> [GitHub](https://github.com/leeper/rio)

The SoundexBR package provides an algorithm for decoding names into phonetic codes, as pronounced in Portuguese. The goal is for homophones to be encoded to the same representation so that they can be matched despite minor differences in spelling. The algorithm mainly encodes consonants; a vowel will not be encoded unless it is the first letter. The soundex code resultant consists of a four digits long string composed by one letter followed by three numerical digits: the letter is the first letter of the name, and the digits encode the remaining consonants.

**Genderize: **<br/>
The [Genderize]() package implements Bayesian classifier to help decision on the gender of a name. The probability is based on a huge amount of first names data. The user can set language and country parameter to refine calculations. <br/> [GitHub](https://github.com/danielmarcelino/Genderize)

 masculinity and femininity. "intersex"


**FPTP2AV: Simulate Election Outcomes for AV Given FPTP Votes.**<br/>

As the name indicates, the aim of this package is to simulate election outcomes for the Alternative Voting System (AV) given FPTP votes. The package only resides in the [GitHub](https://github.com/danielmarcelino/FPTP2AV) platform. A related paper discussing the two systems and some results can be found [here]().

---
## Some other assorted materials ##

* R: [Identify gender of first names, by country, using the Gender API](https://gist.github.com/leeper/9021068)
