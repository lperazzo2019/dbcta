#verifica se os pacotes estao instalados, se nao, instala automaticamente
list.of.packages <- c("plumber","logger","glue","tictoc","statnet.common") 
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library("plumber")
library("logger")
library("glue")
library("tictoc")
library("statnet.common")

dir_proj <- "C:/Users/Administrator/Documents/dbcta/"

configp <- yaml::read_yaml(paste0(dir_proj,"config.yaml"))
setwd(paste0(configp$maindir,configp$apiname))

config <- list()
config$log_dir <- configp$logdir
if (!fs::dir_exists(config$log_dir)) fs::dir_create(config$log_dir)

v_port <- 7988
v_host <- "177.73.238.195"

convert_empty <- function(string) {
  if (string == "") {
    "-"
  } else {
    string
  }
}
setwd(dir_proj)
pr <- plumb("ApiTesteDock.R")

pr$registerHooks(
  list(
    preroute = function() {
      # Start timer for log info
      tictoc::tic()
    },
    postroute = function(req, res) {
      end <- tictoc::toc(quiet = TRUE)
      
      logFile <- paste0(config$log_dir,"api_prt","_",v_port,"_",format(Sys.time(), "%Y%m%d"),".log")
      log_appender(appender_tee(logFile))
      #NVL(req$HTTP_X_REAL_IP,req$REMOTE_ADDR)
      # Log details about the request and the response
      # TODO: Sanitize log details - perhaps in convert_empty
      log_info('{convert_empty(NVL(req$HTTP_X_REAL_IP,req$REMOTE_ADDR))} "{convert_empty(req$HTTP_USER_AGENT)}" {convert_empty(req$HTTP_HOST)} {convert_empty(req$REQUEST_METHOD)} {convert_empty(req$PATH_INFO)} {convert_empty(res$status)} {round(end$toc - end$tic, digits = getOption("digits", 5))}')
    }
  )
)

pr$run(port=v_port,host = v_host, swagger=TRUE)
