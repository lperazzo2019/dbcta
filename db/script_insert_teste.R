INSERT INTO `dbcta`.`pessoas` (`nome`, `cpf`, `dataNascimento`) VALUES ('LUCAS PERAZZO', '82960410068', '1986-10-31');

INSERT INTO `dbcta`.`pessoas` (`nome`, `cpf`, `dataNascimento`) VALUES ('ERICA PERAZZO', '30502247894', '1982-05-30');

INSERT INTO `dbcta`.`contas` (`idPessoa`, `saldo`, `limiteSaqueDiario`, `flagAtivo`, `tipoConta`, `dataCriacao`) VALUES ('5', '300', '500', '1', '1', '2019-11-27');

INSERT INTO `dbcta`.`contas` (`idPessoa`, `saldo`, `limiteSaqueDiario`, `flagAtivo`, `tipoConta`, `dataCriacao`) VALUES ('6', '1000', '300', '1', '1', '2019-11-27');

INSERT INTO `dbcta`.`transacoes` (`idConta`, `valor`, `dataTransacao`) VALUES ('1', '10', '2019-11-27 19:11:30');

