#' Get paths to Drive files.
#'
#' @description Even though you know a Drive file's name or id, you don't
#'   necessarily know its path(s). This function takes Drive files, specified
#'   via a [`dribble`] or a vector of file ids or URLs, and returns a dribble
#'   that includes a `path` variable. Note that Google Drive does NOT behave
#'   like your local file system:
#'   * A single Drive file can potentially be represented by multiple paths,
#'     since a file or folder can have multiple direct parents. So `n` inputs
#'     could result in more than `n` outputs.
#'   * Multiple Drive files could be associated with the same path, because
#'     file and folder names need not be unique, even at a given level of the
#'     hierarchy. So `n` inputs could result in fewer than `n` unique values in
#'     the `path` variable.
#'
#' @param file A [`dribble`] or vector of file ids or URLs.
#'
#' @return dribble-return
#' @export
#'
#' @examples
#' \dontrun{
#' ## 'root' is a special file id that always represents your root folder
#' drive_get(id = "root") %>% drive_add_path()
#' }
drive_add_path <- function(file) {
  ## refresh file metadata
  if (is_dribble(file)) {
    file <- as_id(file$id)
  }
  stopifnot(inherits(file, "drive_id"))
  file <- as_dribble(file)
  if (no_file(file)) return(dribble_with_path())

  nodes <- rbind(
    file,
    drive_find(type = "folder"),
    make.row.names = FALSE
  ) %>% promote("parents")
  nodes <- nodes[!duplicated(nodes$id), ]

  ROOT_ID <- root_id()
  x <- purrr::map(file$id, ~ pathify_one_id(.x, nodes, ROOT_ID))

  ## TO DO: if (verbose), message if a dribble doesn't have exactly 1 row?
  do.call(rbind, x)
}

pathify_one_id <- function(id, nodes, root_id) {
  if (id == "root") return(dribble_with_path_for_root())
  leaf <- nodes$id == id
  if (!any(leaf)) return(dribble_with_path())
  pathify_prune_unnest(nodes, root_id = root_id, leaf = leaf)
}



## basically does the same as above, but for files specified via path
## does the actual work for drive_get(path = ...)
dribble_from_path <- function(path = NULL) {
  if (length(path) == 0) return(dribble_with_path())
  stopifnot(is_path(path))
  path <- rootize_path(path)

  nodes <- get_nodes(path)
  if (nrow(nodes) == 0) return(dribble_with_path())

  ROOT_ID <- root_id()
  x <- purrr::map(path, ~ pathify_one_path(.x, nodes, ROOT_ID))

  ## TO DO: if (verbose), message if a dribble doesn't have exactly 1 row?
  do.call(rbind, x)
}

pathify_one_path <- function(op, nodes, root_id) {
  if (is_rootpath(op)) return(dribble_with_path_for_root())

  name <- last(split_path(op))
  leaf <- nodes$name == name
  if (grepl("/$", op)) {
    leaf <- leaf & is_folder(nodes)
  }
  if (!any(leaf)) return(dribble_with_path())
  out <- pathify_prune_unnest(nodes, root_id = root_id, leaf = leaf)

  target <- paste0(strip_slash(op), "/?$")
  if (is_rooted(op)) {
    target <- paste0("^", target)
  }
  out <- out[grepl(target, out$path), ]
  out
}


## given a vector of paths,
## retrieves metadata for all files that could be needed to resolve paths
get_nodes <- function(path) {
  path_parts <- purrr::map(path, partition_path, maybe_name = TRUE)
  name <- purrr::map_chr(path_parts, "name", .default = NA)
  names <- unique(name)
  names <- names[!is.na(names)]
  names <- glue("name = {sq(names)}")
  folders <- "mimeType = 'application/vnd.google-apps.folder'"
  q_clauses <- collapse(c(folders, names), sep = " or ")

  nodes <- dribble()
  if (length(q_clauses)) {
    nodes <- rbind(
      nodes,
      drive_find(
        fields = "*",
        q = q_clauses,
        verbose = FALSE
      )
    )
  }
  if (any(is_rootpath(path))) {
    nodes <- rbind(nodes, root_folder())
  }

  nodes %>% promote("parents")
}
