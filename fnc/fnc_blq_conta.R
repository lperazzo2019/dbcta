fnc_blq_conta <- function(p_idContas,p_blq=1){
  #funcao para bloquear/desbloquear conta
  
  tryCatch({
    
    if (p_blq %in% c(0,1)){
      
      env_cmd <- paste0("SELECT flagAtivo FROM dbcta.contas WHERE IdContas = ",p_idContas)
      ret_id <- dbGetQuery(con,env_cmd)
      
      if (length(ret_id$flagAtivo) > 0 ){
        
        if (ret_id$flagAtivo == 1 && p_blq == 1){
          ls_ret <- list(status = FALSE,
                         msg = paste0("Conta ja desbloqueada"),
                         code = 1)
        } else if (ret_id$flagAtivo == 0 && p_blq == 0) {
          ls_ret <- list(status = FALSE,
                         msg = paste0("Conta ja bloqueada"),
                         code = 2)
        } else {
          
          env_cmd <- paste0("UPDATE dbcta.contas SET flagAtivo = ",p_blq," WHERE IdContas = ",p_idContas)
          dbGetQuery(con,env_cmd)
          
          ls_ret <- list(status = TRUE,
                         msg = paste0("Conta: ",ifelse(p_blq == 0,"bloqueada","desbloqueada")),
                         code = 0)
          
        }

      } else {
        ls_ret <- list(status = FALSE,
                       msg = paste0("Conta nao encontrada."),
                       code = 3)
      }
      
    } else {
      ls_ret <- list(status = FALSE,
                     msg = paste0("Parametro invalido, so permite 1(desbloquear) ou 0(bloquear)."),
                     code = 4)
    }
    
    return(ls_ret)
    
  }, error=function(err){
    
    ls_ret <- list(status = FALSE,
                   msg = paste0("Erro desconhecido no DB: ",err),
                   code = 5)
    return(ls_ret)      
    
  })
  
}