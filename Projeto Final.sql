CREATE DATABASE IF NOT EXISTS Oficina;
USE Oficina;

CREATE TABLE IF NOT EXISTS Cliente (
    idCliente INT PRIMARY KEY,
    Nome VARCHAR(100),
    Endereco VARCHAR(200),
    Telefone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS Bicicleta (
    idBicicleta INT PRIMARY KEY,
    Chassi VARCHAR(50),
    Cor VARCHAR(20),
    Modelo VARCHAR(50),
    Marca VARCHAR(50),
    Cliente_idCliente INT,
    FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente)
);

CREATE TABLE IF NOT EXISTS Premium (
    idPremium INT PRIMARY KEY,
    Nivel ENUM('Gold', 'Silver', 'Cobber'),
    Cliente_idCliente INT,
    Beneficios VARCHAR(200),
    Desconto DECIMAL(5,2),
    Inicio_Beneficio DATE,
    Fim_Beneficio DATE,
    FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente)
);

CREATE TABLE IF NOT EXISTS Ordem_Servico (
    idOrdem INT PRIMARY KEY,
    Data_Emissao DATE,
    Valor_Total DECIMAL(10,2),
    Status ENUM('Concluída', 'Em execução', 'Aguardando Peças', 'Entregue'),
    Data_Conclusao DATE,
    Bicicleta_idBicicleta INT,
    Cliente_idCliente INT,
    FOREIGN KEY (Bicicleta_idBicicleta) REFERENCES Bicicleta(idBicicleta),
    FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente)
);

CREATE TABLE IF NOT EXISTS Pecas (
    idPecas INT PRIMARY KEY,
    Descricao VARCHAR(100),
    Valor DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS Pecas_Ordem_Servico (
    Ordem_Servico_idOrdem INT,
    Pecas_idPecas INT,
    PRIMARY KEY (Ordem_Servico_idOrdem, Pecas_idPecas),
    FOREIGN KEY (Ordem_Servico_idOrdem) REFERENCES Ordem_Servico(idOrdem),
    FOREIGN KEY (Pecas_idPecas) REFERENCES Pecas(idPecas)
);

CREATE TABLE IF NOT EXISTS Servico (
    idServico INT PRIMARY KEY,
    Descricao VARCHAR(100),
    Valor_Mao_de_Obra DECIMAL(10,2),
    Ordem_Servico_idOrdem INT,
    FOREIGN KEY (Ordem_Servico_idOrdem) REFERENCES Ordem_Servico(idOrdem)
);

CREATE TABLE IF NOT EXISTS Fornecedores (
    idFornecedores INT PRIMARY KEY,
    Razao_Social VARCHAR(100),
    CNPJ VARCHAR(20),
    Contato VARCHAR(20),
    Endereco VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS Fornece_Pecas (
    Fornecedores_idFornecedores INT,
    Pecas_idPecas INT,
    PRIMARY KEY (Fornecedores_idFornecedores, Pecas_idPecas),
    FOREIGN KEY (Fornecedores_idFornecedores) REFERENCES Fornecedores(idFornecedores),
    FOREIGN KEY (Pecas_idPecas) REFERENCES Pecas(idPecas)
);

CREATE TABLE IF NOT EXISTS Mecanico (
    idMecanico INT PRIMARY KEY,
    Nome VARCHAR(100),
    Endereco VARCHAR(200),
    Especialidade VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Motorista (
    idMotorista INT PRIMARY KEY,
    Nome VARCHAR(100),
    CNH VARCHAR(20),
    Veiculo VARCHAR(50)
);
CREATE TABLE IF NOT EXISTS Rota_Entrega (
    idRota INT PRIMARY KEY,
    Tipo ENUM('Busca', 'Entrega'),
    Status ENUM('Entregue', 'Ausente', 'Busca Concluída'),
    Motorista_idMotorista INT,
    FOREIGN KEY (Motorista_idMotorista) REFERENCES Motorista(idMotorista)
);


CREATE TABLE IF NOT EXISTS Servico_Busca_Entrega (
    idServico_Busca_Entrega INT PRIMARY KEY,
    Cliente_idCliente INT,
    Bicicleta_idBicicleta INT,
    Motorista_idMotorista INT,
    Rota_idRota INT,
    FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente),
    FOREIGN KEY (Bicicleta_idBicicleta) REFERENCES Bicicleta(idBicicleta),
    FOREIGN KEY (Motorista_idMotorista) REFERENCES Motorista(idMotorista),
    FOREIGN KEY (Rota_idRota) REFERENCES Rota_Entrega(idRota)
);
SHOW TABLES;

-- Listar todos os clientes
SELECT * FROM Cliente;

-- Listar todas as bicicletas
SELECT * FROM Bicicleta;

-- Listar clientes que são premium
SELECT * FROM Cliente WHERE idCliente IN (SELECT Cliente_idCliente FROM Premium);

-- Listar ordens de serviço com status 'Em execução'
SELECT * FROM Ordem_Servico WHERE Status = 'Em execução';

-- Calcular o valor total das ordens de serviço, incluindo uma taxa de 10% de imposto
SELECT idOrdem, Valor_Total, (Valor_Total * 0.10) AS Imposto, (Valor_Total + (Valor_Total * 0.10)) AS Valor_Total_Com_Imposto FROM Ordem_Servico;

-- Contar quantas bicicletas cada cliente possui
SELECT Cliente_idCliente, COUNT(*) AS Total_Bicicletas
FROM Bicicleta
GROUP BY Cliente_idCliente;

-- Listar clientes em ordem alfabética
SELECT * FROM Cliente ORDER BY Nome ASC;

-- Listar ordens de serviço pela data de emissão, da mais recente para a mais antiga
SELECT * FROM Ordem_Servico ORDER BY Data_Emissao DESC;

-- Contar quantas bicicletas cada cliente possui, apenas para clientes com mais de 1 bicicleta
SELECT Cliente_idCliente, COUNT(*) AS Total_Bicicletas
FROM Bicicleta
GROUP BY Cliente_idCliente
HAVING COUNT(*) > 1;

-- Listar todas as ordens de serviço com detalhes do cliente e da bicicleta
SELECT o.idOrdem, c.Nome AS Nome_Cliente, b.Modelo AS Modelo_Bicicleta, o.Status
FROM Ordem_Servico o
JOIN Cliente c ON o.Cliente_idCliente = c.idCliente
JOIN Bicicleta b ON o.Bicicleta_idBicicleta = b.idBicicleta;

-- Listar os serviços de busca/entrega com informações do cliente e motorista
SELECT sbe.idServico_Busca_Entrega, c.Nome AS Nome_Cliente, m.Nome AS Nome_Motorista, r.Tipo
FROM Servico_Busca_Entrega sbe
JOIN Cliente c ON sbe.Cliente_idCliente = c.idCliente
JOIN Motorista m ON sbe.Motorista_idMotorista = m.idMotorista
JOIN Rota_Entrega r ON sbe.Rota_idRota = r.idRota;


