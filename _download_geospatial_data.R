#' ----
#' title: script download cap15
#' author: mauricio vancine
#' data: 11/11/2021
#' ---- 

# pacotes
library(here)
library(tidyverse)
library(sf)
library(geobr)
library(rnaturalearth)

## Aumentar o tempo de download
options(timeout = 1e3)

## Criar diretório
dir.create(here::here("dados"))
dir.create(here::here("dados", "vetor"))

## Download
for(i in c(".dbf", ".prj", ".shp", ".shx")){
    
    # Pontos de nascentes
    download.file(
        url = paste0("http://geo.fbds.org.br/SP/RIO_CLARO/HIDROGRAFIA/SP_3543907_NASCENTES", i),
        destfile = here::here("dados", "vetor", paste0("SP_3543907_NASCENTES", i)), mode = "wb")
    
    # Linhas de hidrografia
    download.file(
        url = paste0("http://geo.fbds.org.br/SP/RIO_CLARO/HIDROGRAFIA/SP_3543907_RIOS_SIMPLES", i),
        destfile = here::here("dados", "vetor", paste0("SP_3543907_RIOS_SIMPLES", i)), mode = "wb")
    
    # Polígonos de cobertura da terra
    download.file(
        url = paste0("http://geo.fbds.org.br/SP/RIO_CLARO/USO/SP_3543907_USO", i),
        destfile = here::here("dados", "vetor", paste0("SP_3543907_USO", i)), mode = "wb")
}

## Importar nascentes
geo_vetor_nascentes <- sf::st_read(
    here::here("dados", "vetor", "SP_3543907_NASCENTES.shp"), quiet = TRUE)

## Importar hidrografia
geo_vetor_hidrografia <- sf::st_read(
    here::here("dados", "vetor", "SP_3543907_RIOS_SIMPLES.shp"), quiet = TRUE)

## Importar cobertura da terra
geo_vetor_cobertura <- sf::st_read(
    here::here("dados", "vetor", "SP_3543907_USO.shp"), quiet = TRUE)

## Polígono do limite do município de Rio Claro
geo_vetor_rio_claro <- geobr::read_municipality(code_muni = 3543907, 
                                                year = 2020, showProgress = FALSE)

## Polígono do limite do Brasil
geo_vetor_brasil <- rnaturalearth::ne_countries(scale = "large", 
                                                country = "Brazil", returnclass = "sf")

## Criar diretório
dir.create(here::here("dados", "tabelas"))

## Download
download.file(url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.2392&file=ecy2392-sup-0001-DataS1.zip",
              destfile = here::here("dados", "tabelas", "atlantic_amphibians.zip"), mode = "wb")

## Unzip
unzip(zipfile = here::here("dados", "tabelas", "atlantic_amphibians.zip"),
      exdir = here::here("dados", "tabelas"))

## Importar tabela de locais
geo_anfibios_locais <- readr::read_csv(
    here::here("dados", "tabelas", "ATLANTIC_AMPHIBIANS_sites.csv"),
    locale = locale(encoding = "Latin1"))
geo_anfibios_locais

## Aumentar o tempo de download
options(timeout = 1e3)

## Download
download.file(url = "https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_27_17.zip",
              destfile = here::here("dados", "raster", "srtm_27_17.zip"), mode = "wb")

## Unzip
unzip(zipfile = here::here("dados", "raster", "srtm_27_17.zip"),
      exdir = here::here("dados", "raster"))

## Importar raster de altitude
geo_raster_srtm <- raster::raster(here::here("dados", "raster", "srtm_27_17.tif"))
geo_raster_srtm

## Aumentar o tempo de download
options(timeout = 1e3)

## Download
download.file(url = "https://biogeo.ucdavis.edu/data/worldclim/v2.1/base/wc2.1_10m_bio.zip",
              destfile = here::here("dados", "raster", "wc2.0_10m_bio.zip"), mode = "wb")

## Unzip
unzip(zipfile = here::here("dados", "raster", "wc2.0_10m_bio.zip"),
      exdir = here::here("dados", "raster"))

## Listar arquivos
arquivos_raster <- dir(path = here::here("dados", "raster"), pattern = "wc") %>% 
    grep(".tif", ., value = TRUE)
arquivos_raster

## Importar vários rasters como stack
geo_raster_bioclim <- raster::stack(here::here("dados", "raster", arquivos_raster))
geo_raster_bioclim

## Download de polígonos dos geo_vetor_biomas Brasileiros
geo_vetor_biomas <- geobr::read_biomes(showProgress = FALSE) %>%
    dplyr::filter(name_biome != "Sistema Costeiro")

## Dados
geo_vetor_am_sul <- rnaturalearth::ne_countries(continent = "South America")
geo_vetor_brasil <- rnaturalearth::ne_countries(country = "Brazil")
geo_vetor_biomas <- geobr::read_biomes(showProgress = FALSE) %>%
    dplyr::filter(name_biome != "Sistema Costeiro")

## Dados
geo_vetor_brasil_anos <- NULL
for(i in c(1872, 1900, 1911, 1920, 1933, 1940, 1950, 1960, 1970,
           1980, 1991, 2001, 2010, 2019, 2020)){
    geo_vetor_brasil_anos <- geobr::read_state(code_state = "all",
                                               year = i, showProgress = FALSE) %>% 
        sf::st_geometry() %>% 
        sf::st_as_sf() %>%
        dplyr::mutate(year = i) %>% 
        dplyr::bind_rows(geo_vetor_brasil_anos, .)
}

## Importar locais
geo_anfibios_locais <- readr::read_csv(
    here::here("dados", "tabelas", "ATLANTIC_AMPHIBIANS_sites.csv"),
    col_types = cols()) %>%
    dplyr::select(id, longitude, latitude, species_number)

## Importar espécies
geo_anfibios_especies <- readr::read_csv(
    here::here("dados", "tabelas", "ATLANTIC_AMPHIBIANS_species.csv"), 
    col_types = cols()) %>%
    tidyr::drop_na(valid_name) %>% 
    dplyr::select(id, valid_name, individuals) %>% 
    dplyr::distinct(id, valid_name, .keep_all = TRUE) %>% 
    dplyr::mutate(individuals = tidyr::replace_na(individuals, 1),
                  individuals = ifelse(individuals > 0, 1, 1))

## Download do Bioma da Mata Atlântica
geo_vetor_mata_atlantica <- geobr::read_biomes(year = 2019, showProgress = FALSE) %>% 
    dplyr::filter(name_biome == "Mata Atlântica") %>% 
    sf::st_transform(crs = 4326) %>% 
    sf::st_crop(xmin = -55, ymin = -30, xmax = -34, ymax = -5)

## Aumentar o tempo de download
options(timeout = 1e5)

## Importar raster do GlobCover
geo_raster_globcover_mata_atlantica <- raster::raster(
    here::here("dados", "raster", "geo_raster_globcover_mata_atlantica.tif"))

saveRDS(geo_anfibios_locais, "geo_anfibios_locais.rds")                
saveRDS(geo_raster_bioclim, "geo_raster_bioclim.rds")                  
saveRDS(geo_raster_globcover_mata_atlantica, "geo_raster_globcover_mata_atlantica.rds")
saveRDS(geo_raster_srtm, "geo_raster_srtm.rds")         
saveRDS(geo_vetor_am_sul, "geo_vetor_am_sul.rds")                   
saveRDS(geo_vetor_biomas, "geo_vetor_biomas.rds")                 
saveRDS(geo_vetor_brasil_anos, "geo_vetor_brasil_anos.rds")           
saveRDS(geo_vetor_brasil, "geo_vetor_brasil.rds")                
saveRDS(geo_vetor_cobertura, "geo_vetor_cobertura.rds")                
saveRDS(geo_vetor_hidrografia, "geo_vetor_hidrografia.rds")          
saveRDS(geo_vetor_mata_atlantica, "geo_vetor_mata_atlantica.rds")           
saveRDS(geo_vetor_nascentes, "geo_vetor_nascentes.rds")           
saveRDS(geo_vetor_rio_claro, "geo_vetor_rio_claro.rds")

readRDS("geo_anfibios_locais.rds")                
readRDS("geo_raster_bioclim.rds")                  
readRDS("geo_raster_globcover_mata_atlantica.rds")
readRDS("geo_raster_srtm.rds")         
readRDS("geo_vetor_am_sul.rds")                   
readRDS("geo_vetor_biomas.rds")                 
readRDS("geo_vetor_brasil_anos.rds")           
readRDS("geo_vetor_brasil.rds")                
readRDS("geo_vetor_cobertura.rds")                
readRDS("geo_vetor_hidrografia.rds")          
readRDS("geo_vetor_mata_atlantica.rds")           
readRDS("geo_vetor_nascentes.rds")           
readRDS("geo_vetor_rio_claro.rds")
