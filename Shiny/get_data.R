library(tidyverse)
library(sparklyr)
library(arrow)
library(raster)

setwd("C:/Users/Tucac/OneDrive/Escritorio/Shiny_assignment")

#First of all just unziped the .tar.gz file, unsing the untar() function.
untar('biodiversity-data.tar.gz')


#Trying to read the big dataset using sparklyr.
spark_available_versions()
#I just compile this command once
spark_install(version = "2.4")

#Setting the JAMA_HOME path.
Sys.setenv(JAVA_HOME = "C:\\Program Files\\Java\\jre1.8.0_351")
#Start a spark connection locally
sc <- spark_connect(master = "local", version = '2.4')

#Start to reading the .csv file, tt took a little bit of time
data <- sparklyr::spark_read_csv(sc, name = 'data', path = 'biodiversity-data/occurence.csv')


# After that i can subset the dataset filtering only the Poland, and after that writing as .Rds file.
data %>%
  sparklyr::filter(country == 'Poland') %>% 
  as_tibble() %>% 
  write_rds('df_poland.Rds')

# Using Arrow library

# I read the multimedia.csv file just to get the images informations about the species.
data <- arrow::read_csv_arrow("biodiversity-data/multimedia.csv", as_data_frame = FALSE)

#Wrting as a .parquet and getting only multimidia file of the Poland.
write_parquet(data, "biodiversity-data/multimedia.parquet")

data_poland <- arrow::read_parquet('biodiversity-data/multimedia.parquet') %>% 
  filter(CoreId %in% pull(read_rds('df_poland.Rds'), id)) %>% 
  collect()

write_parquet(data_poland, "biodiversity-data/multimedia_poland.parquet")

# Finally, i started to do the final dataset that we need to start the dashboard

df_poland <- read_rds('df_poland.Rds') %>%
  mutate_at(vars(!starts_with(c('latitude', 'longitude', 'geodetic', 'occurrenceID', 'references', 'eventDate'))), str_to_upper) %>%
  mutate(vernacularName = if_else(is.na(vernacularName), scientificName, vernacularName),
         eventDate = lubridate::as_date(eventDate))

# I collect the multimedia file of the country poland and removed the duplicates CoreId, just to have one image per specie.
df_multimida_poland <- arrow::read_parquet('biodiversity-data/multimedia_poland.parquet', as_data_frame = FALSE) %>%
  collect() %>%
  filter(!duplicated(CoreId, fromLast = F))

# After that, i combine the occurance file to multimedia file of poland country.
df_poland %>%
  left_join(df_multimida_poland %>% select(CoreId, accessURI), by = c('id' = 'CoreId')) %>%
  write_rds('Shiny/df_poland_final.Rds')

#Transform in .fst
df_poland <- read_rds('df_poland_final.Rds')

fst::write_fst(df_poland, 'df_poland.fst')

#This section it's just to get the Poland polygons usin raster package.

adm <- getData('GADM', country='POL', level = 0, path = 'Shiny/')



#testing
library(leaflet)
leaflet() %>% 
  addTiles() %>% 
  addPolygons(data=adm, weight = 2, fillColor = "yellow", popup= paste0("<strong>Name: </strong>", 
                                                                       adm$NAME_0))

