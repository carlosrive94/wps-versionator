# ********************
# * Transformaciones *
# ********************

# Cargando Libreria
library(jsonlite)

# Creando objeto json
json_file <- fromJSON("./data/data.json", flatten = TRUE )
is.data.frame(json_file)

# Convertimos el json en DataFrame
df_json <- data.frame(do.call("rbind", json_file))
is.data.frame(df_json)
print(df_json)

# Miramos si hay URLs duplicadas
duplicated(df_json)

# Eliminamos las duplicadas
df_json_dd <- unique(df_json)
print(df_json_dd)

# Cambiamos las versiones -1 por NA
df_json_dd$version[which(df_json_dd$version==-1)]<-NA
#df_json_dd$version[which(df_json_dd$version==-1)]<-"NSNC"
print(df_json_dd)

# Sumamos Numero de URLs de cada version
table(df_json_dd)
TotalVersiones <- as.data.frame(colSums(table(df_json_dd)))
is.data.frame(TotalVersiones)
TotalVersiones



colnames(TotalVersiones) <- c("TotalURLs")
str(TotalVersiones)
TotalVersiones




# GRAFICAS
suppressPackageStartupMessages(library(googleVis))

#Convertimos a dataframe
