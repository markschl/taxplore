

#' Generates a HTML chart from a character string containing the Krona XML.
#'
#' With `method = 'internal'` (the default), R implementation in this package is used,
#' which by default embeds the unmodified Krona JavaScript source code delivered with
#' this package, or a minified version of it with `minify = TRUE`.
#' (see [generate_krona_html_internal()]).
#'
#' Alternatively, `method = 'kronatools'` uses the official Krona software
#' (see [kt_import_xml()]).
#' The resulting HTML should be the same, although the 'internal' method provides
#' additional options that are useful when embedding charts in documents.
#' Therefore, this is the default method.
#' @export
generate_krona_html <- function(xml,
                                method = c('internal', 'kronatools'),
                                ...) {
  switch(
    match.arg(method),
    internal = generate_krona_html_internal(xml, ...),
    kronatools = kt_import_xml(xml, ...),
  )
}

get_kt_import_script <- function(kronatools_dir = NULL) {
  if (is.null(kronatools_dir)) {
    bin <- 'ktImportXML'
    r <- suppressWarnings(try(system2(
      bin,
      stdout = F,
      stderr = F,
      wait = T
    ), silent = T)
    )
    if (r != 0)
    {
      stop(
        sprintf(
          paste(
            "'%s' not found in path. Are the KronaTools installed?",
            "If not installed system-wide, you may provide the 'kronatools_dir' path",
            "instead, which contains the required '%s' script."
          ),
          bin,
          bin
        ))
    }
  } else {
    stopifnot(is.character(kronatools_dir) &&
                length(kronatools_dir) == 1)
    bin <- file.path(kronatools_dir, 'scripts', 'ImportXML.pl')
    if (!file.exists(bin)) {
      stop(sprintf("Import script '%s' not found", bin))
    }
  }
  bin
}

#' Generate a HTML chart using the official Krona tools
#'
#' The `ktImportXML` script from the Krona tools  (<https://github.com/marbl/Krona>)
#' must be available in *$PATH*.
#' Alternatively, the path to the extracted *KronaTools* directory can be
#' specified with `kronatools_dir`.
#'
#' @param xml Krona XML string
#' @param outfile Write the string to file instead of returning the HTML character
#'   string.
#' @param kronatools_dir,resources_url see [ChartOpts]
#' @param ... Additional arguments are ignored
#'
#' @returns The generated HTML, or NULL if `outfile` was specified
#'
#' @export
kt_import_xml <- function(xml,
                          outfile = NULL,
                          kronatools_dir = NULL,
                          resources_url = NULL,
                          ...) {
  script <- get_kt_import_script(kronatools_dir)
  if (is.null(outfile)) {
    outfile <- '-'
  }
  stopifnot(length(outfile) == 1)
  args <- c(
    '-o',
    shQuote(outfile),
    if (!is.null(resources_url))
      c('-u', resources_url)
    else
      NULL,
    '-'
    # shQuote(xml_file)
  )
  # print(paste(c(bin, args, '-o', outfile, xml_file), collapse=' '))
  ret <- system2(script, args, stdout = TRUE, input = xml)
  status <- attr(ret, 'status')
  if (!is.null(status) && status != 0) {
    stop(ret)
  }
  if (outfile != '-') {
    paste(ret, collapse = '\n')
  }
}

# snapshot script is incorporated in the HTML file if snapshot = TRUE
# or directly injected in the JS script in non-interactive contexts or if interactive = FALSE
snapshot_script <- readChar(system.file('_snapshot.js', package = 'taxplore'), 1e6)

#' Generate a HTML chart in R
#'
#' This does not rely on the external KronaTools software (see [kt_import_xml]).
#'
#' @param xml Krona XML string
#' @param outfile Write the string to file instead of returning the HTML character
#'   string.
#' @param resources_url,interactive,minify,snapshot See [ChartOpts]
#' @param ... Additional arguments are currently ignored
#'
#' @returns The generated HTML, or NULL if `outfile` was specified
#'
#' @export
generate_krona_html_internal <- function(xml,
                                         outfile = NULL,
                                         kronatools_dir = NULL,
                                         resources_url = NULL,
                                         minify = FALSE,
                                         snapshot = FALSE,
                                         ...) {
  if (is.null(resources_url)) {
    if (is.null(kronatools_dir)) {
      kronatools_dir <- system.file('KronaTools', package = 'taxplore')
    }
    include_resource <- function(...) {
      path <- do.call(file.path, c(list(kronatools_dir), list(...)))
      readChar(path, 1e6)
    }
    js_file <- if (isTRUE(minify)) 'krona-2.0.min.js' else 'krona-2.0.js'
    script <- paste(
      '  <script language="javascript" type="text/javascript">',
      include_resource('src', js_file),
      '  </script>',
      sep = '\n'
    )
    hidden_image <- include_resource('img', 'hidden.uri')
    loading_image <- include_resource('img', 'loading.uri')
    favicon <- include_resource('img', 'favicon.uri')
    logo <- include_resource('img', 'logo-med.uri')
    not_found_msg <- NULL
  } else {
    resources_url <- gsub('/$', '', resources_url)
    script <- sprintf(
      '  <script src="%s/src/krona-2.0.js" type="text/javascript"></script>',
      resources_url
    )
    favicon <- paste0(resources_url, '/img/favicon.ico')
    hidden_image <- paste0(resources_url, '/img/hidden.png')
    loading_image <- paste0(resources_url, '/img/loading.gif')
    logo <- paste0(resources_url, '/img/logo-med.png')
    not_found_msg <- paste('Could not get resources from', resources_url)
  }
  out <- paste(
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
    '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">',
    ' <head>',
    '  <meta charset=\"utf-8\"/>',
    sprintf('  <link rel="shortcut icon" href="%s"/>', favicon),
    sprintf(
      '  <script id="notfound" type="text/javascript">window.onload=function(){document.body.innerHTML="%s"}</script>',
      not_found_msg
    ),
    script,
    if (isTRUE(snapshot)) {
      script <- sprintf(
        '  <script type="text/javascript">\n%s\n</script>',
        snapshot_script
      )
    },
    ' </head>',
    ' <body>',
    sprintf(
      '  <img id="hiddenImage\" src="%s" style="display:none" alt="Hidden Image"/>',
      hidden_image
    ),
    sprintf(
      '   <img id="loadingImage" src="%s" style="display:none" alt="Loading Indicator"/>',
      loading_image
    ),
    sprintf(
      '  <img id="logo" src="%s" style="display:none" alt="Logo of Krona"/>',
      logo
    ),
    '  <noscript>Javascript must be enabled to view this page.</noscript>',
    '  <div style="display:none">',
    xml,
    '  </div>',
    ' </body>',
    '</html>',
    '',
    sep = '\n'
  )
  if (!is.null(outfile)) {
    cat(out, file = outfile)
  } else {
    out
  }
}

#' Copy chart resources to a specified directory
#'
#' The images and JavasScript files are unmodified snapshots of the original files
#' from the [Krona](https://github.com/marbl/Krona) repository
#' (master branch, commit d1479b3).
#'
#' @param dest_dir Target directory, which can be linked by multiple charts
#' (see `resources_url` in [ChartOpts()])
#'
#' @export
copy_krona_resources <- function(dest_dir) {
  for (d in c('src', 'img')) {
    dir.create(file.path(dest_dir, d), FALSE, TRUE)
  }
  file.copy(system.file('KronaTools', 'src', 'krona-2.0.js', package = 'taxplore'),
            file.path(dest_dir, 'src', 'krona-2.0.js'),
            overwrite = TRUE)
  images <- c('favicon.ico', 'hidden.png', 'loading.gif', 'logo-med.png')
  for (f in images) {
    file.copy(system.file('KronaTools', 'img', f, package = 'taxplore'),
              file.path(dest_dir, 'img', f),
              overwrite = TRUE)
  }
}
