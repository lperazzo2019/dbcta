fnc_ins_pessoas <- function(p_nome,p_cpf,p_dt_nascimento){
  #funcao para inserir dados na tabela pessoas e realiza tratamento de erros com o db, funcao retorna uma lista com elementos como resposta

  tryCatch({
    env_cmd <- paste0("INSERT INTO `dbcta`.`pessoas` (`nome`, `cpf`, `dataNascimento`) VALUES ('",p_nome,"','",p_cpf,"','",p_dt_nascimento,"')")
    dbGetQuery(con,env_cmd)
    
    env_cmd <- paste0("SELECT idPessoa FROM dbcta.pessoas WHERE cpf = '",p_cpf,"'")
    ret_id <- dbGetQuery(con,env_cmd)
    
    ls_ret <- list(status = TRUE,
                   msg = "Cadastro de pessoa efetivado com sucesso.",
                   code = 0,
                   idPessoa = ret_id$idPessoa)
    return(ls_ret)
    
  }, error=function(err){
    #string para mapear o erro de cpf duplicado
    fnd_text <- "cpf_UNIQUE"
    
    if (length(regmatches(fnd_text,gregexpr(fnd_text,err))[[1]]) > 0){
      ls_ret <- list(status = FALSE,
                     msg = paste0("CPF (",p_cpf,") duplicado."),
                     code = 1)
      return(ls_ret)      
    } else {
      ls_ret <- list(status = FALSE,
                     msg = paste0("Erro desconhecido no DB: ",err),
                     code = 2)
      return(ls_ret)      
    }
  })
  
}