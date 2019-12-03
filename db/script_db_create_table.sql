CREATE TABLE `dbcta`.`contas` (
  `idContas` INT NOT NULL,
  `idPessoa` INT NULL,
  `saldo` FLOAT NULL,
  `limiteSaqueDiario` FLOAT NULL,
  `flagAtivo` TINYINT(1) NULL,
  `tipoConta` INT NULL,
  `dataCriacao` DATETIME NULL,
  PRIMARY KEY (`idContas`));

ALTER TABLE `dbcta`.`contas` 
CHANGE COLUMN `idContas` `idContas` INT(11) NOT NULL AUTO_INCREMENT ;

CREATE TABLE `dbcta`.`transacoes` (
  `idTransacao` INT NOT NULL AUTO_INCREMENT,
  `idConta` INT NULL,
  `valor` FLOAT NULL,
  `dataTransacao` DATETIME NULL,
  PRIMARY KEY (`idTransacao`));

CREATE TABLE `dbcta`.`pessoas` (
  `idPessoa` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NULL,
  `cpf` VARCHAR(45) NULL,
  `dataNascimento` DATETIME NULL,
  PRIMARY KEY (`idPessoa`),
  UNIQUE INDEX `cpf_UNIQUE` (`cpf` ASC));


ALTER TABLE `dbcta`.`contas` 
ADD INDEX `idPessoaFK_idx` (`idPessoa` ASC);
ALTER TABLE `dbcta`.`contas` 
ADD CONSTRAINT `idPessoaFK`
FOREIGN KEY (`idPessoa`)
REFERENCES `dbcta`.`pessoas` (`idPessoa`)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE `dbcta`.`transacoes` 
ADD INDEX `idContaFK_idx` (`idConta` ASC);
ALTER TABLE `dbcta`.`transacoes` 
ADD CONSTRAINT `idContaFK`
FOREIGN KEY (`idConta`)
REFERENCES `dbcta`.`contas` (`idContas`)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
