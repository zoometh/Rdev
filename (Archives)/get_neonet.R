#' @rdname db_getter_backend
#' @export
get_neonet <- function(db_url = get_db_url("euroevol")) {

  db_url1 <- db_url[1]

  check_connection_to_url(db_url1)

  # read dates data
  dates <- db_url1 %>%
    data.table::fread(
      colClasses = c(
        C14ID = "character",
        Period = "character",
        C14Age = "character",
        C14SD = "character",
        LabCode = "character",
        PhaseCode = "character",
        SiteID = "character",
        Material = "character",
        MaterialSpecies = "character"
      ),
      showProgress = FALSE
    )

  # merge and prepare
  neonet <- dates %>%
    # merge
    dplyr::left_join(sites, by = "SiteID") %>%
    dplyr::left_join(phases, by = "PhaseCode") %>%
    base::replace(., . == "NULL", NA) %>%
    base::replace(., . == "", NA) %>%
    dplyr::transmute(
      labnr = .data[["LabCode"]],
      c14age = .data[["C14Age"]],
      c14std = .data[["C14SD"]],
      material = .data[["Material"]],
      species = .data[["MaterialSpecies"]],
      country = .data[["Country"]],
      lat = .data[["Latitude"]],
      lon = .data[["Longitude"]],
      site = .data[["SiteName"]],
      period = .data[["Period"]],
      culture = .data[["Culture"]],
      sitetype = .data[["Type"]]
    ) %>% dplyr::mutate(
      sourcedb = "neonet",
      sourcedb_version = get_db_version("neonet")
    ) %>%
    as.c14_date_list()

  return(neonet)
}
