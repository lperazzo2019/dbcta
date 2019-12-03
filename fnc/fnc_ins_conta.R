fnc_ins_conta <- function(p_idPessoa,p_saldo=0,p_limiteSaqueDiario=100,p_flagAtivo=1,p_tipoConta=1,p_dataCriacao=format(Sys.time(), "%Y-%m-%d %H:%M:%S")){
  #funcao para inserir dados na tabela conta e realiza tratamento de erros com o db, funcao retorna uma lista de elementos como resposta

  tryCatch({
    env_cmd <- paste0("INSERT INTO `dbcta`.`contas` (`idPessoa`, `saldo`, `limiteSaqueDiario`, `flagAtivo`, `tipoConta`, `dataCriacao`) VALUES ('",p_idPessoa,"', '",p_saldo,"', '",p_limiteSaqueDiario,"', '",p_flagAtivo,"', '",p_tipoConta,"', '",p_dataCriacao,"')")
    dbGetQuery(con,env_cmd)
    
    env_cmd <- paste0("SELECT max(idContas) idContas FROM dbcta.contas WHERE idPessoa = ",p_idPessoa)
    ret_id <- dbGetQuery(con,env_cmd)
    
    ls_ret <- list(status = TRUE,
                   msg = "Cadastro de conta efetivado com sucesso.",
                   code = 0,
                   idContas = ret_id$idContas)
    return(ls_ret)
    
  }, error=function(err){
    
    #string para mapear o erro de constraint
    fnd_text <- "CONSTRAINT"
    
    if (length(regmatches(fnd_text,gregexpr(fnd_text,err))[[1]]) > 0){
      ls_ret <- list(status = FALSE,
                     msg = paste0("Pessoa ID (",p_idPessoa,") nao cadastrado."),
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