% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/drive_share.R
\name{drive_share}
\alias{drive_share}
\title{Update Google Drive file share permissions.}
\usage{
drive_share(file, role = NULL, type = NULL, ..., verbose = TRUE)
}
\arguments{
\item{file}{Something that identifies the file(s) of interest on your Google
Drive. Can be a character vector of names/paths, a character vector of file
ids marked with \code{\link{as_id}()}, or a \code{\link{dribble}}.}

\item{role}{The role granted by this permission. Valid values are:
\itemize{
\item organizer
\item owner
\item writer
\item commenter
\item reader
}}

\item{type}{The type of the grantee. Valid values are:
\itemize{
\item user
\item group
\item domain
\item anyone
}}

\item{...}{Name-value pairs to add to the API request body.}

\item{verbose}{Logical, indicating whether to print informative messages
(default \code{TRUE}).}
}
\value{
An object of class \code{\link{dribble}}, a tibble with one row per
  file.
}
\description{
Update Google Drive file share permissions.
}
