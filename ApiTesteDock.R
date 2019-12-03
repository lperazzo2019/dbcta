#verifica se os pacotes estao instalados, se nao, instala automaticamente
list.of.packages <- c("RMySQL", "dplyr","lubridate","httr","RCurl","jsonlite") 
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
#carrega pacotes
library("jsonlite")
library("RCurl")
library("httr")
library("RMySQL")
library("dplyr")
library("lubridate")
#carrega funcoes
source("fnc/fnc_ins_pessoas.R")
source("fnc/fnc_ins_conta.R")
source("fnc/fnc_dep_conta.R")
source("fnc/fnc_saq_conta.R")
source("fnc/fnc_qry_saldo.R")
source("fnc/fnc_trs_extrato.R")
source("fnc/fnc_blq_conta.R")

#https://github.com/lperazzo2019/dbcta.git

#arquivo de configuracao
config <- yaml::read_yaml("config.yaml")

print(paste0("Iniciando - ",config$apiname," - ",Sys.time()))

fnc_con_db <- function(){
  drv <- dbDriver("MySQL")
  con <<- dbConnect(drv,
                   dbname = config$dbname,
                   host = config$host, 
                   port = config$port, 
                   user = config$user, 
                   password = config$password)
}

############################################################################################
#' @apiTitle ApiTesteDock - Recursos em API Rest que realizam operacoes bancarias basicas
#' @apiDescription Esta API tem como objetivo utilizar operacoes bancarias basicas 

#* Log some information about the incoming request
#* @filter logger
function(req,res){
  saveRDS(req,"req.rds")
  saveRDS(res,"res.rds")
  plumber::forward()
}

#' Default GET route.
#' @get /
function() {
  list(status = "OK")
}

#' Saldo em conta
#* @param idConta ID da conta 
#* @get /saldo
path_saq_conta <- function(req,res,idConta){
  
  tryCatch({
    
    fnc_con_db()
    ret <- fnc_qry_saldo(idConta)
    dbDisconnect(con)
    
    return(ret)
    
  }, error=function(err){
    res$status <- 500
    res$body <- paste0("ERRO. Favor verificar. ",err)
    lsRes <- list(status = "ERRO",
                  msgerr = paste0("Favor verificar. ",err))
    return(lsRes)  
  })
  
}

#' Extrato de conta
#* @param idConta ID da conta 
#* @param dataIni Data inicial de consulta. Default hoje -7 dias.
#* @param dataFim Data final de consulta. Default hoje
#* @param limit Limite de registros maximos para retornar
#* @get /extrato
path_trs_extrato <- function(req,res,idConta,dataIni,dataFim,limit){
  
  tryCatch({
    
    fnc_con_db()
    ret <- fnc_trs_extrato(idConta,dataIni,dataFim,limit)
    dbDisconnect(con)
    
    return(ret)
    
  }, error=function(err){
    res$status <- 500
    res$body <- paste0("ERRO. Favor verificar. ",err)
    lsRes <- list(status = "ERRO",
                  msgerr = paste0("Favor verificar. ",err))
    return(lsRes)  
  })
  
}

#' Cadastro de Pessoa
#* @param nome Nome da pessoa (Body)
#* @param cpf Cpf da pessoa (Body)
#* @param dtNascimento Data de Nascimento - Formato (1900-12-01) (Body)
#* @post /cadastrarPessoa
path_ins_pessoas <- function(req,res,nome,cpf,dtNascimento){

  tryCatch({

    fnc_con_db()
    ret <- fnc_ins_pessoas(nome,cpf,dtNascimento)
    dbDisconnect(con)
    
    return(ret)
    
  }, error=function(err){
    res$status <- 500
    res$body <- paste0("ERRO. Favor verificar. ",err)
    lsRes <- list(status = "ERRO",
                  msgerr = paste0("Favor verificar. ",err))
    return(lsRes)  
  })
  
}

#' Cadastro de Conta
#* @param idPessoa Id da pessoa (Body)
#* @param saldo Saldo inicial da conta. Default 0 (Body)
#* @param limiteSaqueDiario Limite de saque diario permitido pela conta. Default 100 (Body)
#* @param flagAtivo Flag de status da conta 1 - ativo(desbloqueda), 0 - inativo(bloqueada) (Body)
#* @param tipoConta Tipo da conta (Body)
#* @param dataCriacao Data de criação da conta. Default sysdate - Formato (1900-12-01) (Body)
#* @post /cadastrarConta
path_ins_conta <- function(req,res,idPessoa,saldo,limiteSaqueDiario,flagAtivo,tipoConta,dataCriacao){
  
  tryCatch({

    fnc_con_db()
    ret <- fnc_ins_conta(idPessoa,saldo,limiteSaqueDiario,flagAtivo,tipoConta,dataCriacao)
    dbDisconnect(con)
    
    return(ret)
    
  }, error=function(err){
    res$status <- 500
    res$body <- paste0("ERRO. Favor verificar. ",err)
    lsRes <- list(status = "ERRO",
                  msgerr = paste0("Favor verificar. ",err))
    return(lsRes)  
  })
  
}

#' Deposito em conta
#* @param idConta ID da conta (Body)
#* @param valor Valor para deposito (Body)
#* @post /depostoConta
path_dep_conta <- function(req,res,idConta,valor){
  
  tryCatch({

    fnc_con_db()
    ret <- fnc_dep_conta(idConta,valor)
    dbDisconnect(con)
    
    return(ret)
    
  }, error=function(err){
    res$status <- 500
    res$body <- paste0("ERRO. Favor verificar. ",err)
    lsRes <- list(status = "ERRO",
                  msgerr = paste0("Favor verificar. ",err))
    return(lsRes)  
  })
  
}

#' Saque em conta
#* @param idConta ID da conta (Body)
#* @param valor Valor para deposito (Body)
#* @post /saqueConta
path_saq_conta <- function(req,res,idConta,valor){
  
  tryCatch({
    
    fnc_con_db()
    ret <- fnc_saq_conta(idConta,valor)
    dbDisconnect(con)
    
    return(ret)
    
  }, error=function(err){
    res$status <- 500
    res$body <- paste0("ERRO. Favor verificar. ",err)
    lsRes <- list(status = "ERRO",
                  msgerr = paste0("Favor verificar. ",err))
    return(lsRes)  
  })
  
}

#' Bloquear/Desbloquear conta
#* @param idConta ID da conta (Body)
#* @param blq 1 - desbloquear, 0 - bloquear (Body)
#* @put /bloquearConta
path_blq_conta <- function(req,res,idConta,blq){
  
  tryCatch({
    
    fnc_con_db()
    ret <- fnc_blq_conta(idConta,blq)
    dbDisconnect(con)
    
    return(ret)
    
  }, error=function(err){
    res$status <- 500
    res$body <- paste0("ERRO. Favor verificar. ",err)
    lsRes <- list(status = "ERRO",
                  msgerr = paste0("Favor verificar. ",err))
    return(lsRes)  
  })
  
}
