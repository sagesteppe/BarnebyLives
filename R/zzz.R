utils::globalVariables(c(
  # spatial / geometry columns
  "geometry", "crs",

  # general site / sampling info
  "X", "Y", "ID", "Site", "Distance", "Azimuth",
  "Collection_number", "Primary_Collector", "Collector_n_Number",
  "UNIQUEID", "Unit_Nm", "TRS", "TWNSHPLAB", "FRSTDIVLAB",

  # location / political info
  "Country", "State", "State_Nm", "County", "STUSPS", "STATEFP",
  "Mang_Name", "MapName", "Feature", "p2geo",

  # vegetation / associates
  "Vegetation", "Vegetation_Associates", "Associates",

  # taxonomy / species
  "NAME", "taxon_rank", "taxon_name", "genus", "infraspecies",
  "Family", "SPELLING", "gGRP",

  # coordinates / autofill
  "longitude_dd", "latitude_dd", "long_degrees", "lat_degrees",
  "long_decimel", "lat_decimel", "long_dec_last", "lat_dec_last",
  "Long_AutoFill_Flag", "Lat_AutoFill_Flag", "last_col",

  # geology / physical environment
  "GENERALIZED_LITH", "UNIT_NAME", "physical_environ",
  "elevation_m", "elevation_ft", "Allotment", "unit",

  # PLSS / mapping
  "TRS", "TWNSHPLAB", "PLSSID", "FRSTDIVLAB",

  # directions / Google
  "SoS_gkey", "Directions_BL", "google_towns",

  # additional columns
  "x", "y", ".", ".data", "SuggestedOrder", "feature_name", "fetr_nm",
  "database_templates",

  # other variables
  "Date_digital", "Gen", "NAMELSAD", "transferred_tag", "trs"
))
