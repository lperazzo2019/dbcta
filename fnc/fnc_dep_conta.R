fnc_dep_conta <- function(p_idContas,p_valor=0){
  #funcao para gerar deposito em uma conta ja criada
  
  tryCatch({
    
    p_dthr <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    
    if (p_valor > 0){
      env_cmd <- paste0("INSERT INTO `dbcta`.`transacoes` (`idConta`, `valor`, `dataTransacao`) VALUES ('",p_idContas,"', '",p_valor,"', '",p_dthr,"')")
      dbGetQuery(con,env_cmd)
      
      env_cmd <- paste0("UPDATE dbcta.contas SET saldo = saldo + ",p_valor," WHERE IdContas = ",p_idContas," AND saldo >= 0")
      dbGetQuery(con,env_cmd)
      
      env_cmd <- paste0("SELECT saldo FROM dbcta.contas WHERE IdContas = ",p_idContas)
      ret_id <- dbGetQuery(con,env_cmd)
      
      if (length(ret_id$saldo) > 0 ){
        ls_ret <- list(status = TRUE,
                       msg = paste0("Deposito realizado com sucesso. Saldo: ",ret_id$saldo),
                       code = 0,
                       saldo = ret_id$saldo)
      } else {
        ls_ret <- list(status = FALSE,
                       msg = paste0("Deposito não realizado. Conta nao encontrada."),
                       code = 1)
      }
      
      return(ls_ret)
    } else {
      ls_ret <- list(status = FALSE,
                     msg = paste0("Para realizar um deposito o valor deve ser maior que zero."),
                     code = 2)
      return(ls_ret)
    }

  }, error=function(err){
    
    #string para mapear o erro de constraint
    fnd_text <- "CONSTRAINT"
    
    if (length(regmatches(fnd_text,gregexpr(fnd_text,err))[[1]]) > 0){
      ls_ret <- list(status = FALSE,
                     msg = paste0("Conta ID (",p_idContas,") nao cadastrada."),
                     code = 3)
      return(ls_ret)      
    } else {
      ls_ret <- list(status = FALSE,
                     msg = paste0("Erro desconhecido no DB: ",err),
                     code = 4)
      return(ls_ret)      
    }            
    
  })
  
}