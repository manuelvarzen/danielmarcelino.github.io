---
layout: post
title: "Installing CRAN Archived Packages"
date: 2016-05-18
author: "Daniel Marcelino"
category: how-to
tags: [R]
output:
 html_document: 
   keep_md: yes
   toc: yes
published: true
header-img: "img/website/spaghetti.png"
---


While the number of packages is rising at a fast speed, orphaned and archived package does so. CRAN packages with no active maintainer are very often archived due to important QC problems that prevent them to operate with new R releases. Indeed, such a decision may be fatal for many other CRAN and BioC packages being dependent on them, which will eventually need to archived alongside.


|type                 | N (June/2015) | N (May/2016) |
|:--------------------|:-----------:|:----------:|
|source               |    6760     |    8393    |
|win.binary           |    6712     |    8340    |
|mac.binary.mavericks |    4820     |    8263    |
|mac.binary           |    4639     |    8011    |


Whenever I need to install an archived package, I like installing it right away using R's interface, instead of manually download  and install from local files later on. For instance, since *lgtdl* was removed from CRAN repositories, I'll show the process of installing this library in two basic steps. First, download the package tarball from CRAN archive. Second, install it and clear the package bundle.

**1) First step: download the package**


{% highlight text %}
download.file(url = "http://cran.r-project.org/src/contrib/Archive/lgtdl/lgtdl_1.1.1.tar.gz", 
destfile = "lgtdl_1.1.1.tar.gz")
{% endhighlight %}

**2) Second step: proceed the installation**


{% highlight text %}
install.packages(pkgs="lgtdl_1.1.1.tar.gz", type="source", repos=NULL)

unlink("lgtdl_1.1.1.tar.gz")
{% endhighlight %}

<hr/>


