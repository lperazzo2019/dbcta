fnc_trs_extrato <- function(p_idContas,p_dataIni=NULL,p_dataFim=NULL,p_limit=100){
  #funcao para buscar saldo de uma conta

  tryCatch({
    
    if (is.null(p_dataIni)){
      p_dataIni <- format(Sys.time() - days(7), "%Y-%m-%d")
    }

    if (is.null(p_dataFim)){
      p_dataFim <- format(Sys.time() + days(1), "%Y-%m-%d")
    }
    
    #consulta transacoes do dia para validar limite diario
    env_cmd <- paste0("SELECT * FROM dbcta.transacoes WHERE idConta = ",p_idContas," AND dataTransacao > '",p_dataIni,"' AND dataTransacao < '",p_dataFim,"' order by dataTransacao desc limit ",p_limit,"")
    ret_trs <- dbGetQuery(con,env_cmd)
    
    if (length(ret_trs$idTransacao) > 0 ){
      ls_ret <- list(status = TRUE,
                     msg = paste0("Consulta realizada com sucesso. ",length(ret_trs$idTransacao)," registros recuperados"),
                     code = 0,
                     qtdTrs = length(ret_trs$idTransacao),
                     extrato = ret_trs)
    } else {
      ls_ret <- list(status = FALSE,
                     msg = paste0("Transacoes nao encontrada para este periodo ou conta"),
                     code = 1)
    }
    
    return(ls_ret)
    
  }, error=function(err){
    
    ls_ret <- list(status = FALSE,
                   msg = paste0("Erro desconhecido no DB: ",err),
                   code = 2)
    return(ls_ret)      
    
  })
  
}