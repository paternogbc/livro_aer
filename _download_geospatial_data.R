#' ----
#' title: script download cap15
#' author: mauricio vancine
#' data: 11/11/2021
#' ----

# pacotes
library(tidyverse)
library(sf)
library(raster)
library(geobr)
library(rnaturalearth)

## Aumentar o tempo de download
options(timeout = 1e3)

## Criar diretório
setwd("~/Downloads")
dir.create("dados")
dir.create("dados/vetor")

## Download
for (i in c(".dbf", ".prj", ".shp", ".shx")) {
    
    # Pontos de nascentes
    download.file(url = paste0("http://geo.fbds.org.br/SP/RIO_CLARO/HIDROGRAFIA/SP_3543907_NASCENTES", i),
        destfile = paste0("dados/vetor/SP_3543907_NASCENTES", i),  mode = "wb")
    
    # Linhas de hidrografia
    download.file(url = paste0("http://geo.fbds.org.br/SP/RIO_CLARO/HIDROGRAFIA/SP_3543907_RIOS_SIMPLES", i),
        destfile = paste0("dados/vetor/SP_3543907_RIOS_SIMPLES", i), mode = "wb")
    
    # Polígonos de cobertura da terra
    download.file(url = paste0("http://geo.fbds.org.br/SP/RIO_CLARO/USO/SP_3543907_USO", i),
        destfile = paste0("dados/vetor/SP_3543907_USO", i), mode = "wb")
}

## Importar nascentes
geo_vetor_nascentes <- sf::st_read("dados/vetor/SP_3543907_NASCENTES.shp", quiet = TRUE)

## Importar hidrografia
geo_vetor_hidrografia <- sf::st_read("dados/vetor/SP_3543907_RIOS_SIMPLES.shp", quiet = TRUE)

## Importar cobertura da terra
geo_vetor_cobertura <- sf::st_read("dados/vetor/SP_3543907_USO.shp", quiet = TRUE)

## Polígono do limite do município de Rio Claro
geo_vetor_rio_claro <- geobr::read_municipality(code_muni = 3543907, year = 2020, showProgress = FALSE)

## Polígono do limite do Brasil
geo_vetor_brasil <- rnaturalearth::ne_countries(scale = "large", country = "Brazil", returnclass = "sf")

## Criar diretório
dir.create("dados/tabelas")

## Download
download.file(url = "https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.2392&file=ecy2392-sup-0001-DataS1.zip",
              destfile = "dados/tabelas/atlantic_amphibians.zip",
              mode = "wb")

## Unzip
unzip(zipfile = "dados/tabelas/atlantic_amphibians.zip", exdir = "dados/tabelas")

## Importar tabela de locais
geo_anfibios_locais <- readr::read_csv("dados/tabelas/ATLANTIC_AMPHIBIANS_sites.csv", locale = locale(encoding = "Latin1"))
geo_anfibios_locais

## Criar diretório
dir.create("dados/raster")

## Download
download.file(url = "https://srtm.csi.cgiar.org/wp-content/uploads/files/srtm_5x5/TIFF/srtm_27_17.zip",
              destfile = "dados/raster/srtm_27_17.zip", mode = "wb")

## Unzip
unzip(zipfile = "dados/raster/srtm_27_17.zip", exdir = "dados/raster")

## Importar raster de altitude
geo_raster_srtm <- raster::raster("dados/raster/srtm_27_17.tif")
geo_raster_srtm

## Download
download.file(url = "https://biogeo.ucdavis.edu/data/worldclim/v2.1/base/wc2.1_10m_bio.zip",
              destfile = "dados/raster/wc2.0_10m_bio.zip", mode = "wb")

## Unzip
unzip(zipfile = "dados/raster/wc2.0_10m_bio.zip", exdir = "dados/raster")

## Listar arquivos
arquivos_raster <- dir(path = "dados/raster", pattern = "wc", full.names = TRUE) %>%
    grep(".tif", ., value = TRUE)
arquivos_raster

## Importar vários rasters como stack
geo_raster_bioclim <- raster::stack(arquivos_raster)
geo_raster_bioclim

## Download de polígonos dos geo_vetor_biomas Brasileiros
geo_vetor_biomas <- geobr::read_biomes(showProgress = FALSE) %>%
    dplyr::filter(name_biome != "Sistema Costeiro")

## Dados
geo_vetor_am_sul <- rnaturalearth::ne_countries(continent = "South America")
geo_vetor_brasil <- rnaturalearth::ne_countries(country = "Brazil")

## Dados
geo_vetor_brasil_anos <- NULL
for (i in c(1872, 1900, 1911, 1920, 1933, 1940, 1950, 1960, 1970, 1980, 1991, 2001, 2010, 2019, 2020)) {
    
    geo_vetor_brasil_anos <- geobr::read_state(code_state = "all", year = i, showProgress = FALSE) %>%
        sf::st_geometry() %>%
        sf::st_as_sf() %>%
        dplyr::mutate(year = i) %>%
        dplyr::bind_rows(geo_vetor_brasil_anos, .)
}

## Importar locais
geo_anfibios_locais <- readr::read_csv("dados/tabelas/ATLANTIC_AMPHIBIANS_sites.csv", col_types = cols()) %>%
    dplyr::select(id, longitude, latitude, species_number)

## Importar espécies
geo_anfibios_especies <- readr::read_csv("dados/tabelas/ATLANTIC_AMPHIBIANS_species.csv",
col_types = cols()) %>%
    tidyr::drop_na(valid_name) %>%
    dplyr::select(id, valid_name, individuals) %>%
    dplyr::distinct(id, valid_name, .keep_all = TRUE) %>%
    dplyr::mutate(
        individuals = tidyr::replace_na(individuals, 1),
        individuals = ifelse(individuals > 0, 1, 1)
    )

## Download do Bioma da Mata Atlântica
geo_vetor_mata_atlantica <-
    geobr::read_biomes(year = 2019, showProgress = FALSE) %>%
    dplyr::filter(name_biome == "Mata Atlântica") %>%
    sf::st_transform(crs = 4326) %>%
    sf::st_crop(xmin = -55, ymin = -30, xmax = -34, ymax = -5)

## Importar raster do GlobCover
geo_raster_globcover_mata_atlantica <- raster::raster("dados/raster/geo_raster_globcover_mata_atlantica.tif")

# save rds
saveRDS(geo_anfibios_locais, "dados/geo_anfibios_locais.rds")
saveRDS(geo_anfibios_especies, "dados/geo_anfibios_especies.rds")
saveRDS(geo_raster_bioclim, "dados/geo_raster_bioclim.rds")
saveRDS(geo_raster_globcover_mata_atlantica, "dados/geo_raster_globcover_mata_atlantica.rds")
saveRDS(geo_raster_srtm, "dados/geo_raster_srtm.rds")
saveRDS(geo_vetor_am_sul, "dados/geo_vetor_am_sul.rds")
saveRDS(geo_vetor_biomas, "dados/geo_vetor_biomas.rds")
saveRDS(geo_vetor_brasil_anos, "dados/geo_vetor_brasil_anos.rds")
saveRDS(geo_vetor_brasil, "dados/geo_vetor_brasil.rds")
saveRDS(geo_vetor_cobertura, "dados/geo_vetor_cobertura.rds")
saveRDS(geo_vetor_hidrografia, "dados/geo_vetor_hidrografia.rds")
saveRDS(geo_vetor_mata_atlantica, "dados/geo_vetor_mata_atlantica.rds")
saveRDS(geo_vetor_nascentes, "dados/geo_vetor_nascentes.rds")
saveRDS(geo_vetor_rio_claro, "dados/geo_vetor_rio_claro.rds")

# read rds
geo_anfibios_locais <- readRDS("dados/geo_anfibios_locais.rds")
geo_anfibios_locais

geo_anfibios_especies <- readRDS("dados/geo_anfibios_especies.rds")
geo_anfibios_especies

geo_raster_bioclim <- readRDS("dados/geo_raster_bioclim.rds")
geo_raster_bioclim
plot(geo_raster_bioclim)

geo_raster_globcover_mata_atlantica <- readRDS("dados/geo_raster_globcover_mata_atlantica.rds")
geo_raster_globcover_mata_atlantica
plot(geo_raster_globcover_mata_atlantica)

geo_raster_srtm <- readRDS("dados/geo_raster_srtm.rds")
geo_raster_srtm
plot(geo_raster_srtm)

geo_vetor_am_sul <- readRDS("dados/geo_vetor_am_sul.rds")
geo_vetor_am_sul
plot(geo_vetor_am_sul)

geo_vetor_biomas <- readRDS("dados/geo_vetor_biomas.rds")
geo_vetor_biomas
plot(geo_vetor_biomas$geom)

geo_vetor_brasil_anos <- readRDS("dados/geo_vetor_brasil_anos.rds")
geo_vetor_brasil_anos
plot(geo_vetor_brasil_anos)

geo_vetor_brasil <- readRDS("dados/geo_vetor_brasil.rds")
geo_vetor_brasil
plot(geo_vetor_brasil)

geo_vetor_mata_atlantica <- readRDS("dados/geo_vetor_mata_atlantica.rds")
geo_vetor_mata_atlantica
plot(geo_vetor_mata_atlantica$geom)

geo_vetor_cobertura <- readRDS("dados/geo_vetor_cobertura.rds")
plot(geo_vetor_cobertura$geometry)

geo_vetor_hidrografia <- readRDS("dados/geo_vetor_hidrografia.rds")
plot(geo_vetor_hidrografia$geometry)

geo_vetor_nascentes <- readRDS("dados/geo_vetor_nascentes.rds")
plot(geo_vetor_nascentes$geometry)

geo_vetor_rio_claro <- readRDS("dados/geo_vetor_rio_claro.rds")
geo_vetor_rio_claro
plot(geo_vetor_rio_claro$geom)
