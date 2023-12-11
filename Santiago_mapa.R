
# LIBRERIAS ---------------------------------------------------------------
install.packages("htmlwidgets")
library(htmlwidgets)
library(leaflet)
library(sp)
library(sf)
library(RColorBrewer)

# Preprocesamiento --------------------------------------------------------


comunas_stgo <- "D:/RStudio/MAPA/Mapa_Chile/Comunas/comunas.shp"
datos_sf <- st_read(dsn = comunas_stgo)
datos_sf <- st_transform(datos_sf, crs = "+proj=longlat +datum=WGS84")

comunas_santiago <- datos_sf[datos_sf$Region == "Región Metropolitana de Santiago", ]
colnames(comunas_santiago)

# DATOS DELITOS -----------------------------------------------------------


delitos_comunas <- read_xlsx("D:/RStudio/MAPA/Mapa_Chile/delitos_comunas2023.xlsx")


# JUNTANDO DF ------------------------------------------------------

delitos_mapa <- merge(comunas_santiago,
                      delitos_comunas, by = "Comuna", all.x = TRUE)

colnames(delitos_mapa)


# MERGE DE DFS --------------------------------------------------------

delitos_varios <- read_xlsx("D:/RStudio/MAPA/Mapa_Chile/data_delitos_2023.xlsx")
delitos_varios

comunas_stgo <- "D:/RStudio/MAPA/Mapa_Chile/Comunas/comunas.shp"
datos_sf <- st_read(dsn = comunas_stgo)
datos_sf <- st_transform(datos_sf, crs = "+proj=longlat +datum=WGS84")

comunas_santiago <- datos_sf[datos_sf$Region == "Región Metropolitana de Santiago", ]

mapa_delitos <- merge(comunas_santiago, 
                      delitos_varios, by = "Comuna", all.x = TRUE)

colnames(mapa_delitos)



# MAPA 3 ------------------------------------------------------------------


# Paleta de colores -------------------------------------------------------


pal_abusos <- colorNumeric(palette = "Purples", domain = mapa_delitos$Abusos_Sexuales)
pal_homicidios <- colorNumeric(palette = "Reds", domain = mapa_delitos$Homicidios)
pal_hurtos <- colorNumeric(palette = "Blues", domain = mapa_delitos$Hurtos)
pal_robo <- colorNumeric(palette = "Greens", domain = mapa_delitos$Robo_cviolencia)

mapa <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = mapa_delitos,
              fillColor = ~pal_abusos(Abusos_Sexuales),
              fillOpacity = 0.7,
              weight = 1,
              popup = ~paste("<strong>Comuna:</strong> ", Comuna, "<br>",
                             "<strong>Abusos Sexuales:</strong> ", Abusos_Sexuales),
              group = "Abusos Sexuales") %>% 
  addPolygons(data = mapa_delitos,
              fillColor = ~pal_homicidios(Homicidios),
              fillOpacity = 0.7,
              weight = 1,
              popup = ~paste("<strong>Comuna:</strong> ", Comuna, "<br>",
                             "<strong>Homicidios:</strong> ", Homicidios),
              group = "Homicidios") %>% 
  addPolygons(data = mapa_delitos,
              fillColor = ~pal_hurtos(Hurtos),
              fillOpacity = 0.7,
              weight = 1,
              popup = ~paste("<strong>Comuna:</strong> ", Comuna, "<br>",
                             "<strong>Hurtos:</strong> ", Hurtos),
              group = "Hurtos") %>% 
  addPolygons(data = mapa_delitos,
              fillColor = ~pal_robo(Robo_cviolencia),
              fillOpacity = 0.7,
              weight = 1,
              popup = ~paste("<strong>Comuna:</strong> ", Comuna, "<br>",
                             "<strong>Robo con Violencia:</strong> ", Robo_cviolencia),
              group = "Robo con Violencia") %>% 
  addLayersControl(overlayGroups = c("Abusos Sexuales", "Homicidios", "Hurtos", "Robo con Violencia"),
                   position = ("topleft"),
                   options = layersControlOptions(autoZIndex = TRUE, startActive = c(FALSE, FALSE, FALSE, TRUE), collapsed = TRUE)
  ) %>%
  addScaleBar(position = "topright")

# Añadir capa de leyenda para Abusos Sexuales
mapa <- mapa %>%
  addLegend(pal = pal_abusos,
            values = mapa_delitos$Abusos_Sexuales,
            position = "bottomright",
            title = "Abusos Sexuales",
            group = "Abusos Sexuales") # Aquí está la clave: group = "Abusos Sexuales"

# Añadir capa de leyenda para Homicidios
mapa <- mapa %>%
  addLegend(pal = pal_homicidios,
            values = mapa_delitos$Homicidios,
            position = "bottomright",
            title = "Homicidios",
            group = "Homicidios") # Aquí está la clave: group = "Homicidios"

# Añadir capa de leyenda para Hurtos
mapa <- mapa %>%
  addLegend(pal = pal_hurtos,
            values = mapa_delitos$Hurtos,
            position = "bottomright",
            title = "Hurtos",
            group = "Hurtos") # Aquí está la clave: group = "Hurtos"

# Añadir capa de leyenda para Robo con Violencia
mapa <- mapa %>%
  addLegend(pal = pal_robo,
            values = mapa_delitos$Robo_cviolencia,
            position = "bottomright",
            title = "Robo con Violencia",
            group = "Robo con Violencia") # Aquí está la clave: group = "Robo con Violencia"

mapa

saveWidget(mapa, file = "mapa_interactivo.html")

