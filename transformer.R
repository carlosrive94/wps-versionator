
######################
# TRANSFORMER.R
######################


# ***************************************************************************

# *******************************************
# * Lectura Datos URLs WordPress del Crawler*
# *******************************************

# Cargando Libreria
library(jsonlite)
library(RCurl)
library(bitops)
library(stats)
library(base)
library(dplyr)
library(tidyr)
library(googleVis)
library(ggplot2)

# Creando objeto json
json_file <- fromJSON("./data/data.json", flatten = TRUE )
is.data.frame(json_file)
str(json_file)

# Creando un Dataframe que contiene todas las URLs de todos los paises
# con campo pais
#
df_json <-data.frame(do.call("cbind",json_file$urls[[1]]))
df_json_paises <-cbind(df_json,pais=names(json_file$urls[1]))

for(i in 2:length(json_file$urls)) {

  df_json <-data.frame(do.call("cbind",json_file$urls[[i]]))
  df_json_pais <-cbind(df_json,pais=names(json_file$urls[i]))
  df_json_paises <- rbind(df_json_paises,df_json_pais)
}   
    
# Miramos si hay URLs duplicadas
duplicated(df_json_paises)

# Eliminamos las duplicadas que llamaremos Deduplicado
df_json_dedup <- unique(df_json_paises)
print(df_json_dedup)

# Cambiamos las versiones -1 por NA
df_json_dedup$version[which(df_json_dedup$version==-1)]<-NA
#print(df_json_dedup)
#str(df_json_dedup)


###
# df_json_dedup - Contiene la tabla de (URL, version, pais)
###


# Sumamos Numero de URLs de cada version
TotalVersionesURLPaises <- count(df_json_dedup, pais, NumVersion = version)
#is.data.frame(TotalVersionesURLPaises)
TotalVersionesURLPaises$pais <- TotalVersionesURLPaises$pais %>% toupper

###
# TotalVersionesURLPaises - Contiene la tabla de (pais, NumVersion, n)
###

TotalVersionesURLPaises_sinna <- TotalVersionesURLPaises[complete.cases(TotalVersionesURLPaises),]

###
# TotalVersionesURLPaises_sinna - Contiene la tabla de (pais, NumVersion, n) todas las URLs con version
###

# ***************************************************************************



# ***************************************************************************

# *****************************
# * Carga de vulnerabilidades *
# *****************************


# Encontrar Lista de Versiones encontradas de URLs de paises para sacar vulns de cada version 
ListaVersiones <- TotalVersionesURLPaises$NumVersion
is.na(ListaVersiones)
ListaVersiones <- as.character(ListaVersiones[!is.na(ListaVersiones)])
ListaVersiones
ListaVersiones = sub("([[:punct:]])","",ListaVersiones)
ListaVersiones
ListaVersiones = sub("([[:punct:]])","",ListaVersiones)
ListaVersiones
duplicated(ListaVersiones)
ListaVersiones <- unique(ListaVersiones)
duplicated(ListaVersiones)
ListaVersiones
#ListaVersiones = sub("([[:punct:]])","",ListaVersiones)
#ListaVersiones


AllVulns <- list()
#ListaVersiones <- c('47','46','4410','4018','301','31','341','352','3919','41')
for(version in ListaVersiones){
  res <- getURL(url = paste("https://wpvulndb.com/api/v2/wordpresses/", version, sep=""))
  AllVulns <- tryCatch({
    append(AllVulns, fromJSON(res))
  }, error = function(err) {
    print(paste("ERROR in version", i,":",err))
  })
}


# Creacion Tabla de Versiones con Fecha de aparicion de la version y el total de vulns que tiene
df_resum <- data.frame()
df_vulns1version<-as.data.frame(AllVulns[[1]])
df_total <- cbind(ReleaseVersion=as.character.Date(df_vulns1version$release_date[1]),VulnsVersion=length(df_vulns1version$release_date))
df_total <- cbind(df_total,NumVersion=names(AllVulns[1]))
for(i in 2:length(ListaVersiones)) {
  df_vulns1version<-as.data.frame(AllVulns[[i]])
  df_resum <- cbind(ReleaseVersion=as.character.Date(df_vulns1version$release_date[1]),VulnsVersion=length(df_vulns1version$release_date),NumVersion=names(AllVulns[i]))
  df_total<-rbind(df_total,df_resum)
}

TotalVulnsVersion<-as.data.frame(df_total)
TotalVulnsVersion <- unique(TotalVulnsVersion)
# Valores que son Factors los cambiamos para poder tratar y ordenar
TotalVulnsVersion$VulnsVersion <- as.numeric(as.character(TotalVulnsVersion$VulnsVersion))
TotalVulnsVersion$NumVersion <- as.character(TotalVulnsVersion$NumVersion)

###
# TotalVulnsVersion - Contiene la tabla de (ReleaseVersion, VulnsVersion, NumVersion)
###

# ***************************************************************************


#####################
#TABLAS DE RESULTADOS
#####################

print(TotalVersionesURLPaises_sinna)
print(TotalVulnsVersion)

#Tabla con todos los Datos acumulados

TotalVersionesURLVulnsPaises<-merge(TotalVersionesURLPaises_sinna, TotalVulnsVersion, by = "NumVersion")
TotalVersionesURLVulnsPaises <- unique(TotalVersionesURLVulnsPaises)
df_temporal <- tidyr::separate(TotalVersionesURLVulnsPaises, ReleaseVersion, c("YearReleaseVersion","MonthReleaseVersion","DayReleaseVersion"), sep = "-")

TotalVersionesURLVulnsPaises <- cbind(TotalVersionesURLVulnsPaises,AñoPubVersion=as.numeric(df_temporal$YearReleaseVersion))
#str(TotalVersionesURLVulnsPaises)
#TotalVersionesURLVulnsPaises$AñoPubVersion <- as.numeric(TotalVersionesURLVulnsPaises$AñoPubVersion)
#str(TotalVersionesURLVulnsPaises)

# *****************************************
# Tratamos los datos agrupando por Version

ResulVersionesMundo <- summarise(group_by(TotalVersionesURLVulnsPaises,NumVersion), TotalVerMundo = sum(VulnsVersion))
ResulVersionesMundo <- ResulVersionesMundo[order(-ResulVersionesMundo$TotalVerMundo),] 
# *****************************************



# **************************************
# Tratamos los datos agrupando por Pais
# **************************************
ResulPaises <- summarise(group_by(TotalVersionesURLVulnsPaises,pais), TotalVulnsPais = sum(VulnsVersion))
ResulPaises <- ResulPaises[order(-ResulPaises$TotalVulnsPais),] 

# ***************************************************
# Tratamos los datos agrupando por Pais y año version
# ***************************************************
ResulPaisesAño <- summarise(group_by(TotalVersionesURLVulnsPaises,pais,AñoPubVersion), TotalVulnsPais = sum(VulnsVersion))
ResulPaisesAño <- ResulPaisesAño[order(-ResulPaisesAño$TotalVulnsPais),] 
# **********************

# ***************************************************
# Tratamos los datos agrupando por Pais y año riesgo calculando mayor riesgo si version mas antigua
# ***************************************************
ResulPaisesRiesgoAño <- mutate(ResulPaisesAño,Riesgo=(2017-AñoPubVersion)*TotalVulnsPais)

ResulPaisesRiesgoTotal <- summarise(group_by(ResulPaisesRiesgoAño,pais), TotalRiesgo=sum(Riesgo))
ResulPaisesRiesgoTotal <- ResulPaisesRiesgoTotal[order(-ResulPaisesRiesgoTotal$TotalRiesgo),]


##########
# GRAFICAS
##########
#Carga Librerias
suppressPackageStartupMessages(library(googleVis))
library(MASS)
library(ggplot2)

# --------------
# Tarta de Total de Versiones de Todos los paises
# --------------
#png(filename = "Tarta_Versiones_Global.png") 

Pie <- gvisPieChart(ResulVersionesMundo,options=list(width="1500px", height="1000px"))
plot(Pie)

#dev.off()


# --------------
# Grafica de Barras ordenado por Paises con mas Vulns
# --------------

#png(filename = "Barras_Paises_Mas_Vulnerables.png")

Column <- gvisColumnChart(ResulPaises)
plot(Column)

#dev.off()

# --------------
# Tabla ordenada por Paises con mas Vulns
# --------------
PopTable <- gvisTable(ResulPaises,
                      options=list(page='enable',height='automatic',width='automatic'))
plot(PopTable)


# --------------
# Top 8 paises mas riesgo
# --------------

#png(filename = "Velocimetro_Top_Paises_Mas_Riesgo.png") 
Media_Riesgo <- as.integer(mean(ResulPaisesRiesgoTotal$TotalRiesgo))
Max_Riesgo <- max(ResulPaisesRiesgoTotal$TotalRiesgo)
Naranja <- ((Max_Riesgo - Media_Riesgo)/2)+ Media_Riesgo
Top <- 8
Gauge <-  gvisGauge(head(ResulPaisesRiesgoTotal,n=Top), 
                    options=list(min=0, max=Max_Riesgo, greenFrom=0,
                                 greenTo=Media_Riesgo, yellowFrom=Media_Riesgo, yellowTo=Naranja,
                                 redFrom=Naranja, redTo=Max_Riesgo, width=800, height=600))
plot(Gauge)
#dev.off()
# --------------



# --------------
# Mapa de Riesgo
# --------------

MapaRiesgo <- gvisGeoChart(ResulPaisesRiesgoTotal, locationvar = "pais", colorvar = "TotalRiesgo", options=list(width="1200px", height="800px", region='150', colorAxis="{colors:['yellow', 'red']}",backgroundColor="lightblue"))
plot(MapaRiesgo)


# ----FIN-----


# PRUEBAS GRAFICAS

qplot(x = pais, data = ResulPaisesAño, geom = "TotalVulnsPais", color = AñoPubVersion)

qplot(x = NumVersion, y = VulnsVersion, data = TotalVersionesURLVulnsPaises,facets = .~AñoPubVersion )
qplot(x = NumVersion, y = n, data = TotalVersionesURLVulnsPaises,facets = .~pais )
qplot(x = pais, data = TotalVersionesURLVulnsPaises, fill = NumVersion)

qplot(x = NumVersion, data = TotalVersionesURLVulnsPaises, fill = NumVersion)
qplot(x = AñoPubVersion, data = TotalVersionesURLVulnsPaises, fill = NumVersion, facets = .~pais)




Bubble <- gvisBubbleChart(TotalVersionesURLVulnsPaises, idvar="NumVersion", 
                          xvar="n", yvar="VulnsVersion",
                          colorvar="pais", sizevar="n",
                          options=list(
                            hAxis='{minValue:5, maxValue:40}'))
plot(Bubble)



