fnc_saq_conta <- function(p_idContas=1,p_valor=10){
  
  library(lubridate)
  
  #funcao para gerar saque em uma conta ja criada
  #p_idContas <- 1
  #p_valor <- 10
  
  tryCatch({
    
    p_dthr <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    
    p_dt_ini <- format(Sys.time() - days(1), "%Y-%m-%d")
    p_dt_fim <- format(Sys.time() + days(1), "%Y-%m-%d")
    
    if (p_valor != 0){#valida valor minimo para saque
      
      if (p_valor > 0){
        p_valor <- p_valor*-1
      }
      
      env_cmd <- paste0("SELECT saldo + ",p_valor," saldo_new, saldo,limiteSaqueDiario,flagAtivo FROM dbcta.contas WHERE IdContas = ",p_idContas)
      ret_id_nw <- dbGetQuery(con,env_cmd)
      
      if (ret_id_nw$flagAtivo == 1){#valida se conta esta ativa
        
        if (length(ret_id_nw$saldo) > 0 ){#valida se a conta foi encontrada
          
          #consulta transacoes do dia para validar limite diario
          env_cmd <- paste0("SELECT sum(valor)*-1 saq_vlr_dia FROM dbcta.transacoes WHERE idConta = ",p_idContas," AND dataTransacao > '",p_dt_ini,"' AND dataTransacao < '",p_dt_fim,"' AND valor < 0")
          ret_lmt <- dbGetQuery(con,env_cmd)
          
          if ((ret_lmt$saq_vlr_dia+p_valor*-1) <= ret_id_nw$limiteSaqueDiario){#validacao de limite diario
            
            if (ret_id_nw$saldo_new >= 0){#valida saldo minimo
              
              #cria transacao de saida de valores
              env_cmd <- paste0("INSERT INTO `dbcta`.`transacoes` (`idConta`, `valor`, `dataTransacao`) VALUES ('",p_idContas,"', '",p_valor,"', '",p_dthr,"')")
              dbGetQuery(con,env_cmd)
              
              #atualiza novo saldo descontado valor do saque
              env_cmd <- paste0("UPDATE dbcta.contas SET saldo = saldo + ",p_valor," WHERE IdContas = ",p_idContas," AND saldo >= 0")
              dbGetQuery(con,env_cmd)
              
              env_cmd <- paste0("SELECT saldo FROM dbcta.contas WHERE IdContas = ",p_idContas)
              ret_id <- dbGetQuery(con,env_cmd)
              
              if (length(ret_id$saldo) > 0 ){
                ls_ret <- list(status = TRUE,
                               msg = paste0("Saque realizado com sucesso. Saldo: ",ret_id$saldo," Saldo Anterior: ",ret_id_nw$saldo),
                               code = 0,
                               saldo = ret_id$saldo,
                               limiteSaqueDiario = ret_id_nw$limiteSaqueDiario,
                               saqueNoDia = (ret_lmt$saq_vlr_dia+p_valor*-1))
              } else {
                ls_ret <- list(status = FALSE,
                               msg = paste0("Saque nao realizado. Conta nao encontrada."),
                               code = 1)
              }
              
              return(ls_ret)
              
            } else {
              ls_ret <- list(status = FALSE,
                             msg = paste0("Saldo (",ret_id_nw$saldo,") insuficiente para relaizar o saque."),
                             code = 2)
              return(ls_ret)
            }
            
          } else {
            ls_ret <- list(status = FALSE,
                           msg = paste0("Saque nao realizado. Limite de saque diario ultrapassado. Limite(",ret_id_nw$limiteSaqueDiario,") Saque efetuado(",ret_lmt$saq_vlr_dia,")"),
                           code = 3)
            return(ls_ret)        
          }
          
        } else {
          ls_ret <- list(status = FALSE,
                         msg = paste0("Saque nao realizado. Conta nao encontrada."),
                         code = 4)
          return(ls_ret)        
        }
        
      } else {
        ls_ret <- list(status = FALSE,
                       msg = paste0("Saque não realizado. Conta inativa."),
                       code = 5)
        return(ls_ret)        
      }
      
    } else {
      ls_ret <- list(status = FALSE,
                     msg = paste0("Para realizar um saque o valor deve ser maior que zero."),
                     code = 6)
      return(ls_ret)
    }
    
  }, error=function(err){
    
    #string para mapear o erro de constraint
    fnd_text <- "CONSTRAINT"
    
    if (length(regmatches(fnd_text,gregexpr(fnd_text,err))[[1]]) > 0){
      ls_ret <- list(status = FALSE,
                     msg = paste0("Conta ID (",p_idContas,") nao cadastrada."),
                     code = 7)
      return(ls_ret)      
    } else {
      ls_ret <- list(status = FALSE,
                     msg = paste0("Erro desconhecido no DB: ",err),
                     code = 8)
      return(ls_ret)      
    }            
    
  })
  
}