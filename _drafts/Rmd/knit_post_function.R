# ================================================================
# Functions to convert an 'Rmd' file into a blog post 'md' file
# ================================================================
# change extension Rmd to md
md_file <- function(input) {
  sub('Rmd$', 'md', input)
}

# file path to export it to '_posts'
outfile_name <- function(input) {
  output <- substr(input, 6, nchar(input))
  output <- md_file(output)
  paste0('_posts/', output)
}

# knit Rmd into dirty md
knit_post <- function(input, base.url = "/") {
  require(knitr)
  opts_knit$set(base.url = base.url)
  fig.path <- paste0("img/", sub(".Rmd$", "", basename(input)), "/")
  opts_chunk$set(fig.path = fig.path)
  opts_chunk$set(fig.cap = "center")
  render_jekyll()
  # output file
  #  output <- outfile_name(input)
  # make md file and figs
  output <- paste0('_drafts/Rmd/', md_file(input))
  input <- paste0('_drafts/Rmd/', input)
  knit(input, output, envir = parent.frame())
}

# extract dirty yaml header and clean it
parse_yaml_header <- function(infile = '') {
  num_line <- 0
  yaml <- c()
  repeat {
    scanned <- scan(infile, what = "", sep = "\n",
                    nlines = 1, skip = num_line, quiet = TRUE,
                    blank.lines.skip = FALSE)
    if (scanned == '') break
    yaml <- c(yaml, scanned)
    num_line = num_line + 1
  }
  # removing hashes '#'
  sub('#', '', yaml)
}

# clean a dirty post
clean_post <- function(infile) {
  print(infile)
  outfile <- outfile_name(infile)
  print(outfile)
  infile <- paste0('_drafts/Rmd/', infile)
  print(infile)
  header <- parse_yaml_header(infile)
  skip_lines <- length(header)
  rmd_post <- readLines(infile)
  post <- c(header, rmd_post[-(1:skip_lines)])
  writeLines(post, con = outfile)
}

# the whole enchilada
blog_post <- function(infile) {
  knit_post(infile)
  mdfile <- md_file(infile)
  clean_post(mdfile)
  file.remove(paste0('_drafts/Rmd/', mdfile))
}


setwd("~/danielmarcelino.github.io")

blog_post("code-2015-12-06-venezuelan-parliamentary-elections.Rmd")

#blog_post("code-2015-11-10-retrieving-data-from-google-books-with-ngramr.Rmd")
# blog_post("code-2015-10-19-crocodile-problem.Rmd")



# remember to include yaml header lines in the produced md files
# (they are commented out in the Rmd files to avoid jekyll crash)


