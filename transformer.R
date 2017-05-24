# ********************
# * Transformaciones *
# ********************

# Cargando Libreria
library(jsonlite)
library(RCurl)
library(bitops)

# Creando objeto json
json_file <- fromJSON("./data/data.json", flatten = TRUE )
is.data.frame(json_file)
str(json_file)

# Creando un Dataframe que contiene todas las URLs de todos los paises con campo pais
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
print(df_json_dedup)



###
# df_json_dedup - Contiene la tabla de (URL, version, pais)
###


# Sumamos Numero de URLs de cada version
table(df_json_dedup)
TotalVersiones <- as.data.frame(colSums(table(df_json_dedup)))
is.data.frame(TotalVersiones)
TotalVersiones

# GRAFICAS
#Carga Librerias
suppressPackageStartupMessages(library(googleVis))
library(MASS)

#Primeras exploraciones graficas
hist(TotalVersiones$be, col = "green", breaks = 50)
barplot(table(TotalVersiones$be), col="wheat", main = "Observaciones por Pais BE")
pie(table(TotalVersiones$be))



# ********************
# * Carrega de vulnerabilitats *
# ********************
AllVulns <- list()
ListaVersiones <- c('47','46','4410','4018','301','31','341','352','3919','41')
for(version in ListaVersiones){
  res <- getURL(url = paste("https://wpvulndb.com/api/v2/wordpresses/", version, sep=""))
  AllVulns <- tryCatch({
    append(AllVulns, fromJSON(res))
  }, error = function(err) {
    print(paste("ERROR in version", i,":",err))
  })
}
#>>>>>>> 44573b9e28bb2b9bc8dadc329a261df4e2cae3d3


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

print(df_total)

###
# df_total - Contiene la tabla de (ReleaseVersion, VulnsVersion, NumVersion)
###
