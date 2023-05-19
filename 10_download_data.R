
if(!"here" %in% installed.packages()) {install.packages("here")}

if(!dir.exists(here::here("data"))) {dir.create(here::here("data"))}
if(!dir.exists(here::here("data", "csv_files"))) {dir.create(here::here("data", "csv_files"))}

if(!file.exists(here::here("data", "csv_files", "npdes_dmrs_fy2022.zip"))) {
  download.file("https://echo.epa.gov/files/echodownloads/npdes_dmrs_fy2022.zip",
                destfile = here::here("data", "csv_files", "npdes_dmrs_fy2022.zip"))
  unzip(here::here("data","csv_files", "npdes_dmrs_fy2022.zip"), 
        exdir = here::here("data", "csv_files"))
}




if(!file.exists(here::here("data", "csv_files", "npdes_downloads.zip"))) {
  download.file("https://echo.epa.gov/files/echodownloads/npdes_downloads.zip",
                destfile = here::here("data", "csv_files", "npdes_downloads.zip"))
  unzip(here::here("data","csv_files", "npdes_downloads.zip"), 
        exdir = here::here("data", "csv_files"))
}
