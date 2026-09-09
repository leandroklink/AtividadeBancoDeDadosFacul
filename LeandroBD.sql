CREATE DATABASE gerenciamento_projetos;
USE gerenciamento_projetos;

CREATE TABLE professor (
    id_professor   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome_professor VARCHAR(60) NOT NULL,
    area_atuacao   VARCHAR(30) DEFAULT 'Tecnologia',
    PRIMARY KEY (id_professor),
    UNIQUE (nome_professor)
);

CREATE TABLE recurso (
    id_recurso INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    tipo ENUM('equipamento', 'material') NOT NULL,
    PRIMARY KEY (id_recurso),
    INDEX idx_tipo_recurso (tipo)
);

CREATE TABLE equipamento (
    id_equipamento INT UNSIGNED NOT NULL,
    numero_serie   VARCHAR(40) NOT NULL,
    garantia_anos  INT DEFAULT 1,
    PRIMARY KEY (id_equipamento),
    UNIQUE (numero_serie),
    INDEX idx_numero_serie (numero_serie),
    CHECK (garantia_anos >= 0),
    FOREIGN KEY (id_equipamento) REFERENCES recurso (id_recurso)
);

CREATE TABLE material (
    id_material INT UNSIGNED NOT NULL,
    unidade     VARCHAR(20) DEFAULT 'Unidade',
    quantidade  INT DEFAULT 1,
    PRIMARY KEY (id_material),
    CHECK (quantidade > 0),
    FOREIGN KEY (id_material) REFERENCES recurso (id_recurso)
);

CREATE TABLE projeto (
    id_projeto    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_professor  INT UNSIGNED NOT NULL,
    id_recurso    INT UNSIGNED NOT NULL,
    titulo        VARCHAR(38) NOT NULL,
    descricao     TEXT,
    data_inicio   DATE NOT NULL,
    data_fim      DATE NOT NULL,
    PRIMARY KEY (id_projeto),
    INDEX idx_titulo_projeto (titulo),
    INDEX idx_projeto_professor (id_professor),
    INDEX idx_projeto_recurso (id_recurso),
    FOREIGN KEY (id_professor) REFERENCES professor (id_professor),
    FOREIGN KEY (id_recurso)   REFERENCES recurso (id_recurso),
    CHECK (data_fim > data_inicio)
);

CREATE TABLE atividade (
    id_atividade   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_projeto     INT UNSIGNED NOT NULL,
    nome_atividade VARCHAR(60) NOT NULL,
    data_inicio    DATE NOT NULL,
    data_fim       DATE NOT NULL,
    PRIMARY KEY (id_atividade),
    INDEX idx_nome_atividade (nome_atividade),
    INDEX idx_atividade_projeto (id_projeto),
    FOREIGN KEY (id_projeto) REFERENCES projeto (id_projeto),
    CHECK (data_fim >= data_inicio)
);

CREATE TABLE aluno_voluntario (
    id_aluno   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome_aluno VARCHAR(60) NOT NULL,
    curso      VARCHAR(30) DEFAULT 'Informática',
    PRIMARY KEY (id_aluno),
    UNIQUE (nome_aluno),
    INDEX idx_curso_aluno (curso)
);

CREATE TABLE atividade_aluno (
    id_atividade INT UNSIGNED NOT NULL,
    id_aluno     INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_atividade, id_aluno),
    INDEX idx_atividade_aluno (id_aluno),
    FOREIGN KEY (id_atividade) REFERENCES atividade (id_atividade),
    FOREIGN KEY (id_aluno)     REFERENCES aluno_voluntario (id_aluno)
);




/* a) Adicionar a coluna e-mail na tabela professor do tipo string de tamanho 40 */
ALTER TABLE professor ADD email varchar(45);

/*b) Alterar o atributo área de atuação para especialidade da tabela professor mudar o tipo para VARCHAR(50).*/
ALTER TABLE professor CHANGE  area_atuacao especialidade VARCHAR(50);

/*c) Alterar apenas o tipo de dados da coluna numero_serie do tipo string de tamanho (40) para string de tamanho (60) na tabela equipamento.*/
ALTER TABLE equipamento MODIFY numero_serie VARCHAR(60);

/*d) Excluir o atributo e-mail da tabela professor.*/
ALTER TABLE professor DROP email;

/*e) Criar um índice chamado idx_nome_professor na tabela professor para o atributo nome do professor.*/
CREATE INDEX idx_nome_professor ON professor (nome_professor);

/*f) Adicionar o atributo status com valor padrão 'Ativo' na tabela professor*/
ALTER TABLE professor ADD status VARCHAR(15) DEFAULT 'ativo';

/*g) Excluir o atributo status da tabela professor*/
ALTER TABLE professor DROP status;

/* Atividade dia 01/09 */
DELETE FROM professor WHERE id_professor = 1;

INSERT INTO professor values
(1, "Ana", "Biologia"), 
(2, "Carlos Souza", "Fisica"),
(3, "Marina Torres", "Quimica"),
(4,"Patrícia Gomes", "Computação");

select * from professor;

/* Inserção de dados de recursos */

insert INTO recurso (id_recurso, nome, tipo) VALUES (1, "Microscópio", "Equipamento");
insert INTO recurso (id_recurso, nome, tipo) VALUES (2, "Projetor", "Equipamento");
insert INTO recurso (id_recurso, nome, tipo) VALUES (3, "Papel A4", "Material");
insert INTO recurso (id_recurso, nome, tipo) VALUES (4, "Caneta", "Material");
insert INTO recurso (id_recurso, nome, tipo) VALUES (5, "Notebook", "Equipamento");

select * from recurso;

/* Inserção de dados de equipamentos */

INSERT INTO equipamento(id_equipamento, numero_serie, garantia_anos) values (1, "MIC12345", 2), (2, "PROJ6789", 3), (3, "NOTE98765",1);
select * from equipamento;

/* Inserção de dados de equipamentos */

INSERT INTO material (id_material, unidade, quantidade) VALUES (1, "Resma", 20), (2, "Unidade", 100);
select * from  material;

/* Inserção de dados na tabela projeto */

INSERT INTO projeto(id_projeto, id_professor, id_recurso, titulo, descricao, data_inicio, data_fim) VALUES
(1,1, 1, "Projeto Bioluz", "Estudo sobre fotossíntese", "2026-01-10", "2026-08-10"),
(2,2, 2, "Física Aplicada", "Reações com papel indicador", "2025-03-01", "2025-08-10"),
(4,4, 4, "Matemática Visual", "Geometria com recursos", "2025-04-01", "2025-09-01"),
(5,5, 5, "Computação Móvel", "Uso de notebooks em aulas", "2025-05-15", "2025-10-15");

select * from projeto;


/* 1. Ajuste/Complemento da inserção de Professores */
/* Garante a presença do professor com ID 5 citado no material */
INSERT INTO professor (id_professor, nome_professor, especialidade) VALUES 
(5, 'Patrícia Gomes', 'Computação')
ON DUPLICATE KEY UPDATE nome_professor = VALUES(nome_professor);
SELECT * FROM professor;

/* 2. Inserção de Projetos que faltam (ID 3) */
INSERT INTO projeto (id_projeto, id_professor, id_recurso, titulo, descricao, data_inicio, data_fim) VALUES
(3, 3, 3, 'Laboratório Química', 'Reações com papel indicador', '2025-03-01', '2025-08-10')
ON DUPLICATE KEY UPDATE titulo = VALUES(titulo);
SELECT * FROM projeto;

/* 3. Inserção de Atividades */
INSERT INTO atividade (id_atividade, id_projeto, nome_atividade, data_inicio, data_fim) VALUES
(1, 1, 'Coleta de Dados', '2026-06-15', '2026-07-15'),
(2, 2, 'Experimento 1', '2026-05-10', '2026-08-10'),
(3, 3, 'Teste de Reações', '2026-05-20', '2026-08-20'),
(4, 4, 'Aula Prática', '2026-04-10', '2026-09-10'),
(5, 5, 'Montagem de Ambiente', '2026-05-20', '2026-10-20');
SELECT * FROM atividade;

/* 4. Inserção de Alunos Voluntários */
INSERT INTO aluno_voluntario (id_aluno, nome_aluno, curso) VALUES
(1, 'Beatriz Ramos', 'Biologia'),
(2, 'Eduardo Costa', 'Física'),
(3, 'Fernanda Melo', 'Química'),
(4, 'Lucas Rocha', 'Matemática'),
(5, 'Rafaela Dias', 'Computação');

/* 5. Inserção do relacionamento Atividade-Aluno */
INSERT INTO atividade_aluno (id_atividade, id_aluno) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

/* 6. Criação da Tabela Orientador e Relacionamento com Atividade */
CREATE TABLE orientador (
    id_orientador INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome_orientador VARCHAR(60) NOT NULL,
    area VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_orientador)
);

/* Inserção de dados dos Orientadores */
INSERT INTO orientador (id_orientador, nome_orientador, area) VALUES
(1, 'Ricardo Almeida', 'Engenharia'),
(2, 'Juliana Martins', 'Robótica'),
(3, 'Fernando Oliveira', 'Estatística'),
(4, 'Camila Rodrigues', 'Educação'),
(5, 'Rafael Mendes', 'Inteligência Artificial'),
(6, 'Luciana Ferreira', 'Astronomia'),
(7, 'Gustavo Pereira', 'Tecnologia');

/* Adicionando a chave estrangeira do Orientador na tabela Atividade */
ALTER TABLE atividade ADD id_orientador INT UNSIGNED NULL;
ALTER TABLE atividade ADD CONSTRAINT fk_atividade_orientador 
    FOREIGN KEY (id_orientador) REFERENCES orientador (id_orientador);

/* Atualização das Atividades com seus respectivos Orientadores */
UPDATE atividade SET id_orientador = 5 WHERE id_atividade = 1; -- Rafael Mendes -> Coleta de Dados
UPDATE atividade SET id_orientador = 2 WHERE id_atividade = 2; -- Juliana Martins -> Experimento 1
UPDATE atividade SET id_orientador = 7 WHERE id_atividade = 3; -- Gustavo Pereira -> Teste de Reações
UPDATE atividade SET id_orientador = 1 WHERE id_atividade = 4; -- Ricardo Almeida -> Aula Prática
UPDATE atividade SET id_orientador = 4 WHERE id_atividade = 5; -- Camila Rodrigues -> Montagem de Ambiente

-- atividades dia 08/09/2026
-- A) Consulta de atividades com data de término a partir de uma data específica:
-- Esta consulta retorna todas as atividades que têm uma data de término posterior a 20 de abril de 2025.

select * from atividade where data_fim > '2025-04-20';

-- B) Retorne a unidade e quantidade em estoque de todos os materiais na tabela
-- Material, cuja quantidade seja superior a 100.

select unidade, quantidade from material
where quantidade > 100;

-- C) Consulta para exibir o nome de professores e área de atuação na tabela
-- Professor, que não são da área de atuação Física.

select nome_professor, especialidade from professor where especialidade <> 'Física';

-- D) Localizar todos os projetos que estão atualmente em andamento. Um projeto é
-- considerado "em andamento" se a data atual estiver entre sua data de início e de fim.

select * from projeto where current_date() > data_inicio and current_date() < data_fim;

-- E) Listar o nome e a área de atuação de todos os professores que são da área de
-- 'Biologia' OU 'Química’

select * from professor where especialidade = 'Biologia' or especialidade = 'Quimica';

-- F) Consultar o nome e o tipo de todos os recursos que NÃO são do tipo 'Equipamento’.

select nome, tipo from recurso where tipo <> "Equipamento";

-- G) O projeto 'Computação Móvel' precisa de mais tempo e sua data final
-- será estendida para 30 de novembro de 2025.

update projeto set data_fim = "2025-11-30" where id_projeto = 5;

-- H) O nome da atividade com id_atividade igual a 2, "Experimento 1", é muito genérico.
-- É necessário atualizá-lo para "Experimento de Refração da Luz" para refletir melhor o seu propósito


update atividade set nome_atividade = "Experimento de Refração de Luz" where id_atividade = 2;

-- I) Listar os orientadores da área de Tecnologia

select * from orientador where area = 'Tecnologia';

-- J) Listar orientadores cujo ID seja maior que 3

select * from orientador where id_orientador > 3;

-- K) Listar orientadores que não são da área de Educação

select * from orientador where area <> "Educacao";
