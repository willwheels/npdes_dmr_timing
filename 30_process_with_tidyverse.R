
if(!"here" %in% installed.packages()) {install.packages("here")}
library(dplyr)
library(tidyr)

# Start the clock!
ptm <- proc.time()

npdes_dmr_data <- readr::read_csv(here::here("data","csv_files", "NPDES_DMRS_FY2022.csv"))


icis_permits <- readr::read_csv(here::here("data", "csv_files", "ICIS_PERMITS.csv"))

# Stop the clock
proc.time() - ptm

## about 80 seconds

# Start the clock!
ptm <- proc.time()


icis_permits <- icis_permits %>%
  select(EXTERNAL_PERMIT_NMBR, VERSION_NMBR, FACILITY_TYPE_INDICATOR, PERMIT_TYPE_CODE,
          MAJOR_MINOR_STATUS_FLAG, PERMIT_STATUS_CODE)

npdes_dmr_data_most_violations <-  npdes_dmr_data %>%
  select(EXTERNAL_PERMIT_NMBR, VERSION_NMBR, PERM_FEATURE_TYPE_CODE, PERM_FEATURE_NMBR,
         STATISTICAL_BASE_CODE,MONITORING_LOCATION_CODE, LIMIT_VALUE_TYPE_CODE, LIMIT_SET_DESIGNATOR,
         PARAMETER_CODE, PARAMETER_DESC, LIMIT_TYPE_CODE,
         MONITORING_PERIOD_END_DATE, EXCEEDENCE_PCT, VIOLATION_CODE)  %>%
  filter(PERM_FEATURE_TYPE_CODE == "EXO",
         LIMIT_TYPE_CODE == "ENF") %>%
  mutate(violation = 1) %>%
  pivot_wider(names_from = VIOLATION_CODE, values_from = violation, values_fn = length) %>%
  mutate(monitoring_period_end_date2 = lubridate::mdy(MONITORING_PERIOD_END_DATE),
         EXCEEDENCE_PCT = replace_na(EXCEEDENCE_PCT, 1) ) %>%
  mutate(across(.cols = c(E90, D80, D90), ~replace_na(.x, 0))) %>%
  select(-MONITORING_PERIOD_END_DATE, -`NA`) %>%
  left_join(icis_permits,
             by = c("EXTERNAL_PERMIT_NMBR", "VERSION_NMBR")) %>%
  group_by(EXTERNAL_PERMIT_NMBR, MAJOR_MINOR_STATUS_FLAG) %>%
  summarise(across(.cols = c(E90, D80, D90), sum)) %>%
  arrange(desc(E90))

# Stop the clock
proc.time() - ptm

head(npdes_dmr_data_most_violations)

# 