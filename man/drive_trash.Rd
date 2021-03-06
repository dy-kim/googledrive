% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/drive_trash.R
\name{drive_trash}
\alias{drive_trash}
\alias{drive_untrash}
\title{Move files to or from trash.}
\usage{
drive_trash(file, verbose = TRUE)

drive_untrash(file, verbose = TRUE)
}
\arguments{
\item{file}{Something that identifies the file(s) of interest on your Google
Drive. Can be a character vector of names/paths, a character vector of file
ids marked with \code{\link{as_id}()}, or a \code{\link{dribble}}.}

\item{verbose}{Logical, indicating whether to print informative messages
(default \code{TRUE}).}
}
\value{
An object of class \code{\link{dribble}}, a tibble with one row per
  file.
}
\description{
Move files to or from trash.
}
\examples{
\dontrun{
## Create a file to trash.
file <- drive_upload(system.file("DESCRIPTION"), "DESC")
## Put a single file in the trash.
drive_trash("DESC")
drive_untrash("DESC")

## Put multiple files in trash.
file_a <- drive_upload(system.file("DESCRIPTION"), "file_a")
file_b <- drive_upload(system.file("DESCRIPTION"), "file_b")
drive_trash(c("file_a", "file_b"))
drive_untrash(c("file_a", "file_b"))
}
}
