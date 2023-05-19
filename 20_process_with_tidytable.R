
if(!"here" %in% installed.packages()) {install.packages("here")}
if(!"tidytable" %in% installed.packages()) {install.packages("tidytable")}
library(tidytable) 

# Start the clock!
ptm <- proc.time()

npdes_dmr_data <- data.table::fread(here::here("data","csv_files", "NPDES_DMRS_FY2022.csv"),
                                    fill = TRUE)

icis_permits <- data.table::fread(here::here("data", "csv_files", "ICIS_PERMITS.csv"))
                    
## about 41 second   

# Start the clock!
ptm <- proc.time()

icis_permits <- icis_permits %>%
  select.(EXTERNAL_PERMIT_NMBR, VERSION_NMBR, FACILITY_TYPE_INDICATOR, PERMIT_TYPE_CODE,
          MAJOR_MINOR_STATUS_FLAG, PERMIT_STATUS_CODE)

npdes_dmr_data_most_violations <- npdes_dmr_data %>%
  select.(EXTERNAL_PERMIT_NMBR, VERSION_NMBR, PERM_FEATURE_TYPE_CODE, PERM_FEATURE_NMBR,
          STATISTICAL_BASE_CODE,MONITORING_LOCATION_CODE, LIMIT_VALUE_TYPE_CODE, LIMIT_SET_DESIGNATOR,
          PARAMETER_CODE, PARAMETER_DESC, LIMIT_TYPE_CODE,
          MONITORING_PERIOD_END_DATE, EXCEEDENCE_PCT, VIOLATION_CODE) %>%
  filter.(PERM_FEATURE_TYPE_CODE == "EXO",
          LIMIT_TYPE_CODE == "ENF") %>%
  mutate.(violation = 1) %>%
  pivot_wider.(names_from = VIOLATION_CODE, values_from = violation, values_fn = sum) %>%
  mutate.(monitoring_period_end_date2 = lubridate::mdy(MONITORING_PERIOD_END_DATE),
          EXCEEDENCE_PCT = replace_na.(EXCEEDENCE_PCT, 1)) %>%
  select.(-V1, -MONITORING_PERIOD_END_DATE) %>%
  left_join.(icis_permits,
             by = c("EXTERNAL_PERMIT_NMBR", "VERSION_NMBR")) %>%
  summarise_across.(.cols = c(E90, D80, D90), sum, 
                    .by = c(EXTERNAL_PERMIT_NMBR, MAJOR_MINOR_STATUS_FLAG)) %>%
  arrange.(desc.(E90))


# Stop the clock
proc.time() - ptm

head(npdes_dmr_data_most_violations)
  
# about 68 seconds
