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

<<<<<<< HEAD


colnames(TotalVersiones) <- c("TotalURLs")
str(TotalVersiones)
TotalVersiones




# GRAFICAS
suppressPackageStartupMessages(library(googleVis))

#Convertimos a dataframe
=======
# ********************
# * Carrega de vulnerabilitats *
# ********************
all <- list()
versions <- c('20','41','42','43')
for(version in versions){
  res <- getURL(url = paste("https://wpvulndb.com/api/v2/wordpresses/", version, sep=""))
  all <- tryCatch({
    append(all, fromJSON(res))
  }, error = function(err) {
    print(paste("ERROR in version", i,":",err))
  })
}
>>>>>>> 44573b9e28bb2b9bc8dadc329a261df4e2cae3d3
