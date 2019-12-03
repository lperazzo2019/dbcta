fnc_qry_saldo <- function(p_idContas){
  #funcao para buscar saldo de uma conta
  
  tryCatch({
    
    env_cmd <- paste0("SELECT saldo FROM dbcta.contas WHERE IdContas = ",p_idContas)
    ret_id <- dbGetQuery(con,env_cmd)
    
    if (length(ret_id$saldo) > 0 ){
      ls_ret <- list(status = TRUE,
                     msg = paste0("Saldo: ",ret_id$saldo),
                     code = 0,
                     saldo = ret_id$saldo)
    } else {
      ls_ret <- list(status = FALSE,
                     msg = paste0("Conta nao encontrada."),
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