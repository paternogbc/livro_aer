library(sf)
library(raster)
library(fasterize)

setwd("/home/mude/data/github/livro_aer/img/cap15")

nas <- sf::st_read("nascentes.shp") %>% 
    sf::as_Spatial()
nas

rios <- sf::st_read("rios.shp") %>% 
    sf::st_transform(crs = 4326) %>% 
    sf::as_Spatial()
rios

flo <- sf::st_read("floresta.shp") %>% 
    sf::as_Spatial()
flo

ra <- fasterize::raster(flo, res = .001)
ra[] <- 1
plot(ra)

nas_ras <- fasterRaster::fasterRasterize(vect = nas, rast = ra, use = "val", 
                                         value = 1, grassDir = "/usr/lib/grass78")
nas_ras
plot(nas_ras)

rios_ras <- fasterRaster::fasterRasterize(vect = rios, rast = ra, use = "val", 
                                          value = 1, grassDir = "/usr/lib/grass78")
rios_ras
plot(rios_ras)

flo_ras <- fasterRaster::fasterRasterize(vect = flo, rast = ra, use = "val", 
                                         value = 1, grassDir = "/usr/lib/grass78")
flo_ras
plot(flo_ras)

writeRaster(nas_ras, "nascentes.tif", overwrite = TRUE)
writeRaster(rios_ras, "rios.tif", overwrite = TRUE)
writeRaster(flo_ras, "floresta.tif", overwrite = TRUE)
