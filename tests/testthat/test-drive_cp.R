context("Copy files")

nm_ <- nm_fun("-TEST-drive-cp")

## clean
if (FALSE) {
  del <- drive_rm(c(
    nm_("i-am-a-folder"),
    nm_("i-am-a-file")
  ), verbose = FALSE)
}

## setup
if (FALSE) {
  drive_mkdir(nm_("i-am-a-folder"))
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("i-am-a-file"),
    verbose = FALSE
  )
}

test_that("drive_cp() can copy file in place", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  on.exit(drive_rm(paste("Copy of", nm_("i-am-a-file"))))

  file <- drive_get(nm_("i-am-a-file"))
  expect_message(
    file_cp <- drive_cp(file),
    "File copied"
  )
  expect_identical(file_cp$name, paste("Copy of", nm_("i-am-a-file")))

  ## should have the same parent
  expect_identical(file$files_resource[[1]]$parents,
                   file_cp$files_resource[[1]]$parents)
})

test_that("drive_cp() can copy a file into a different folder", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  on.exit(drive_rm(paste("Copy of", nm_("i-am-a-file"))))

  file <- drive_get(nm_("i-am-a-file"))
  folder <- drive_get(nm_("i-am-a-folder"))
  expect_message(
    file_cp <- drive_cp(file, folder),
    "File copied"
  )
  expect_identical(file_cp$name, paste("Copy of", nm_("i-am-a-file")))

  ## should have folder as parent
  expect_identical(file_cp$files_resource[[1]]$parents[[1]], folder$id)
})

test_that("drive_cp() elects to copy into a folder vs onto file of same name", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  on.exit(drive_rm(paste("Copy of", nm_("i-am-a-file"))))

  file <- drive_get(nm_("i-am-a-file"))
  ## does drive_cp() detect that path is a folder, despite lack of trailing
  ## slash?
  expect_message(
    file_cp <- drive_cp(file, nm_("i-am-a-folder")),
    "File copied"
  )
  expect_identical(file_cp$name, paste("Copy of", nm_("i-am-a-file")))

  ## should have folder as parent
  folder <- drive_get(nm_("i-am-a-folder"))
  expect_identical(file_cp$files_resource[[1]]$parents[[1]], folder$id)
})

test_that("drive_cp() errors if asked to copy a folder", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  expect_error(
    drive_cp(nm_("i-am-a-folder")),
    "The Drive API does not copy folders"
  )
})
