-- 1) Complete a base de dados fazendo as seguintes inserções:
-- a) Insira novos clientes na base de dados.
insert into cliente values
(3,'Paulo',12345678910,'M','1990-05-10',34999998888,'paulo@gmail.com'),
(4,'Bruno',12345678910,'M','2000-01-09',34888889999,'bruno@gmail.com');

-- b) Crie novas contas com data de criação em janeiro e fevereiro do ano de 2023.
insert into conta_corrente values 
(3, '2023-01-23',110,'Ativa',3),
(4, '2023-02-15',90,'Ativa',4),
(5, '2023-01-14',130,'Ativa',1),
(6, '2020-01-11',130,'Ativa',2);

-- c) Insira novos registros de saques e depósitos para os meses de janeiro e fevereiro do ano 
-- de 2023. Os registros devem ser para as contas antigas e as novas contas.
insert into registro_saque values
(3,1,'2023-01-24', 30),
(4,2,'2023-02-16', 40),
(5,3,'2023-01-25', 50),
(6,4,'2023-02-17', 20),
(7,5,'2023-02-14', 440);

insert into registro_deposito values
(3,1,'2023-01-25', 330),
(4,2,'2023-02-17', 210),
(5,3,'2023-01-26', 350),
(6,4,'2023-02-18', 420),
(7,5,'2023-02-14', 1740);

-- 2) Utilizando o operador UNION escreva o comando SQL que irá gerar o relatório
-- contendo o nome do cliente, o código da conta e total de depósitos e saques efetuados.
-- Obs.: Utilizar a função concat para concatenar “Depositos:” e o total de depositos, e
-- “Saques:” com o total de saques. Utilize a função cast para converter o valor decimal
-- para char.
select c.nome, cc.cod_conta, concat('Depositos:', cast((select sum(valor_deposito) 
from registro_deposito where cod_conta = cc.cod_conta) as char(10)),
 ' Saques:', cast((select sum(valor_saque) from registro_saque 
where cod_conta = cc.cod_conta) as char(10))) as total_operacoes
from cliente c join conta_corrente cc on c.cod_cliente = cc.cod_cliente
union
select c.nome, cc.cod_conta, concat('Depositos:', cast((select sum(valor_deposito) 
from registro_deposito where cod_conta = cc.cod_conta) as char(10)), ' Saques:', 
cast((select sum(valor_saque) from registro_saque where cod_conta = cc.cod_conta) as char(10))) 
as total_operacoes from cliente c
join conta_corrente cc on c.cod_cliente = cc.cod_cliente
order by cod_conta;

-- 3) Utilizando operadores de junção de tabelas responda as questões abaixo:
-- a) Listar o número da conta, nome, telefone e email dos clientes que são titulares de contas
-- que não foram movimentadas nos últimos 6 meses. Considere como operação de movimentação saques
-- e depósitos. (Utilize operadores de Junção e Subconsultas para fazer o relatório).
select c.cod_cliente, c.nome, c.telefone, c.email
from cliente c
inner join conta_corrente cc ON c.cod_cliente = cc.cod_cliente
left join (
  select cod_conta
  from Registro_Saque
  where dt_saque >= date_sub(now(), interval 6 month)
  union
  select cod_conta
  from Registro_Deposito
  where dt_deposito >= date_sub(NOW(), interval 6 month)
) m on cc.cod_conta = m.cod_conta
where m.cod_conta is null;

-- b) Listar o código da conta, ano, mês, o valor total de saques e o valor total de depositos. Para
-- as contas onde não houveram saques imprimir a mensagem “Sem registro de saque”. Para as
-- contas onde não houveram depositos imprimir a mensagem “Sem registro de depositos”.
-- (Utilizar a função if, operadores de junção e operador UNION ALL).
select c.nome, cc.cod_conta, concat('Depositos:', cast((select sum(valor_deposito) 
from registro_deposito where cod_conta = cc.cod_conta) as char(10)), ' Saques:', 
cast((select sum(valor_saque) from registro_saque where cod_conta = cc.cod_conta) as char(10))) 
as total_operacoes
from cliente c
join conta_corrente cc on c.cod_cliente = cc.cod_cliente
union
select c.nome, cc.cod_conta, concat('Depositos:', cast((select sum(valor_deposito) 
from registro_deposito where cod_conta = cc.cod_conta) as char(10)), ' Saques:', 
cast((select sum(valor_saque) from registro_saque where cod_conta = cc.cod_conta) as char(10))) 
as total_operacoes
from cliente c
join conta_corrente cc on c.cod_cliente = cc.cod_cliente
order by cod_conta;

-- c) Para o mês atual, listar o número da conta, nome do cliente e a quantidade de saques
-- efetuados na conta. Para as contas onde não houveram saques a quantidade retornada deve ser
-- zero. Utilizar os operadores de junção.
select cc.cod_conta, c.nome, count(rs.cod_saque) as qtde_saques
from conta_corrente cc
inner join cliente c on cc.cod_cliente = c.cod_cliente
left join registro_saque rs on cc.cod_conta = rs.cod_conta and month(rs.dt_saque) = month(current_date())
group by cc.cod_conta, c.nome;

-- d) Listar o nome do cliente, cpf e número da conta de todos os clientes que são titulares de
-- contas com saldo superior a R$ 100.000,00
select c.nome, c.CPF, cc.cod_conta
from cliente c
inner join conta_corrente cc on c.cod_cliente = cc.cod_cliente
where cc.saldo > 100000.00;

-- 3) Dê o código SQL correspondente às consultas solicitadas. Utilize subconsultas.
-- a) Liste os dados dos clientes que realizaram o maior valor de depósito no mês corrente.
-- Obs.: Eliminar possíveis repetições.
select distinct c.*
from cliente c
inner join conta_corrente cc on c.cod_cliente = cc.cod_cliente
inner join (
select cod_conta, max(valor_deposito) as maior_deposito
from registro_deposito rd
where month(dt_deposito) = month(current_date())
group by cod_conta
) as dep on cc.cod_conta = dep.cod_conta
inner join registro_deposito rd on dep.cod_conta = rd.cod_conta and dep.maior_deposito = rd.valor_deposito;

-- b) Listar o cpf, nome, telefone, email e número da conta dos clientes que realizaram saques
-- com valores acima da média durante o ano de 2023.
select c.CPF, c.nome, c.telefone, c.email, cc.cod_conta
from cliente c
inner join conta_corrente cc on c.cod_cliente = cc.cod_cliente
inner join (
select cod_conta, avg(valor_saque) as media_saque
from Registro_Saque
where dt_saque <= current_date()
group by cod_conta
) as med on cc.cod_conta = med.cod_conta
inner join Registro_Saque rs on med.cod_conta = rs.cod_conta and rs.valor_saque > med.media_saque;

-- c) Listar as informações dos clientes que efetuaram abertura de contas no mês de janeiro ou
-- fevereiro.
select * 
from cliente
where cod_cliente in (
select cod_cliente
from conta_corrente
where month(dt_hora_abertura) IN (1, 2)
);

-- d) Listar o número da conta, saldo e data de abertura de todas as contas criadas no ano de
-- 2023 por clientes do sexo feminino.
select cc.cod_conta, cc.saldo, cc.dt_hora_abertura
from conta_corrente cc
inner join cliente c on cc.cod_cliente = c.cod_cliente
where year(cc.dt_hora_abertura) = 2023
  and c.sexo = 'F';










