#' Generate a Google Sheets API request
#'
#' @description Generate a request, using knowledge of the [Sheets
#'   API](https://developers.google.com/sheets/api/) from its [Discovery
#'   Document](https://www.googleapis.com/discovery/v1/apis/sheets/v4/rest). Use
#'   [request_make()] to execute the request. Most users should, instead, use
#'   higher-level wrappers that facilitate common tasks, such as reading or
#'   writing worksheets or cell ranges. The functions here are intended for
#'   internal use and for programming around the Sheets API.
#'
#' @description `request_generate()` lets you provide the bare minimum of input.
#'   It takes a nickname for an endpoint and:
#'   * Uses the API spec to look up the `method`, `path`, and `base_url`.
#'   * Checks `params` for validity and completeness with respect to the
#'   endpoint. Uses `params` for URL endpoint subsitution and separates
#'   remaining parameters into those destined for the body versus the query.
#'   * Adds an API key to the query if and only if `token = NULL`.
#'
#' @param endpoint Character. Nickname for one of the selected Sheets API v4
#'   endpoints built into googlesheets4. Learn more in [sheets_endpoints()].
#' @param params Named list. Parameters destined for endpoint URL substitution,
#'   the query, or the body.
#' @param key API key. Needed for requests that don't contain a token. The need
#'   for an API key in the absence of a token is explained in Google's document
#'   [Credentials, access, security, and
#'   identity](https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279).
#'   In order of precedence, these sources are consulted: the formal `key`
#'   argument, a `key` parameter in `params`, a pre-configured API key fetched
#'   via `sheets_api_key()` (nope, not set up yet). googlesheets4 ships with a
#'   built-in key or users can override with their own via
#'   `sheets_auth_config()` (nope, not set up yet).
#' @param token Set this to `NULL` to suppress the inclusion of a token. Note
#'   that, if auth has been de-activated via `sheets_auth_config()`,
#'   `sheets_token()` will actually return `NULL`. (none of that is implemented
#'   yet)
#'
#' @return `list()`\cr Components are `method`, `url`, `body`, and `token`,
#'   suitable as input for [request_make()].
#' @export
#' @family low-level API functions
#' @seealso [gargle::request_develop()], [gargle::request_build()],
#'   [gargle::request_make()]
#' @examples
#' \dontrun{
#' req <- request_generate(
#'   "spreadsheets.get",
#'   list(spreadsheetId = "1xTUxWGcFLtDIHoYJ1WsjQuLmpUtBf--8Bcu5lQ302SU"),
#'   token = NULL
#' )
#' req
#' }
request_generate <- function(endpoint = character(),
                             params = list(),
                             key = NULL,
                             token = sheets_token()) {
  ept <- .endpoints[[endpoint]]
  if (is.null(ept)) {
    stop_glue("\nEndpoint not recognized:\n  * {endpoint}")
  }

  ## modifications specific to googlesheets4 package
  params$key <- key %||% params$key %||% sheets_api_key()

  req <- gargle::request_develop(
    endpoint = ept,
    params = params,
    base_url = attr(.endpoints, which = "base_url", exact = TRUE)
  )
  gargle::request_build(
    path = req$path,
    method = req$method,
    params = req$params,
    body = req$body,
    token = token,
    base_url = req$base_url
  )
}
