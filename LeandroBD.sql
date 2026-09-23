/* ============================================================
   BANCO DE DADOS: gerenciamento_projetos
   Script corrigido + exercícios em sala + exercícios extra-classe
   ============================================================ */

CREATE DATABASE IF NOT EXISTS gerenciamento_projetos;
USE gerenciamento_projetos;

/* ============================================================
   1. CRIAÇÃO DAS TABELAS
   ============================================================ */

CREATE TABLE professor (
    id_professor   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome_professor VARCHAR(60) NOT NULL,
    area_atuacao   VARCHAR(30) DEFAULT 'Tecnologia',
    PRIMARY KEY (id_professor),
    UNIQUE (nome_professor)
);

CREATE TABLE recurso (
    id_recurso INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome       VARCHAR(50) NOT NULL,
    tipo       ENUM('equipamento', 'material') NOT NULL,
    PRIMARY KEY (id_recurso),
    INDEX idx_tipo_recurso (tipo)
);

-- CORREÇÃO: removido o INDEX idx_numero_serie, pois o UNIQUE já cria um índice
-- (ficava um índice duplicado).
CREATE TABLE equipamento (
    id_equipamento INT UNSIGNED NOT NULL,
    numero_serie   VARCHAR(40) NOT NULL,
    garantia_anos  INT DEFAULT 1,
    PRIMARY KEY (id_equipamento),
    UNIQUE (numero_serie),
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


/* ============================================================
   2. ALTER TABLE (para 22/08)
   ============================================================ */

-- a) Adicionar a coluna e-mail na tabela professor (string de tamanho 40).
-- CORREÇÃO: criada já com VARCHAR(40); não precisa mais do MODIFY ("errei").
ALTER TABLE professor ADD email VARCHAR(40);

-- b) Alterar area_atuacao para especialidade, tipo VARCHAR(50).
-- CORREÇÃO: mantido o DEFAULT 'Tecnologia' (o CHANGE sem ele apagava o padrão).
ALTER TABLE professor CHANGE area_atuacao especialidade VARCHAR(50) DEFAULT 'Tecnologia';

-- c) Alterar numero_serie de VARCHAR(40) para VARCHAR(60) na tabela equipamento.
-- CORREÇÃO: mantido o NOT NULL (o MODIFY sem ele removia a restrição).
ALTER TABLE equipamento MODIFY numero_serie VARCHAR(60) NOT NULL;

-- d) Excluir o atributo e-mail da tabela professor.
ALTER TABLE professor DROP email;

-- e) Criar o índice idx_nome_professor para o nome do professor.
CREATE INDEX idx_nome_professor ON professor (nome_professor);

-- f) Adicionar o atributo status com valor padrão 'Ativo' na tabela professor.
ALTER TABLE professor ADD status VARCHAR(15) DEFAULT 'Ativo';

-- g) Excluir o atributo status da tabela professor.
ALTER TABLE professor DROP status;


/* ============================================================
   3. INSERÇÃO DE DADOS
   (CORREÇÃO: ponto e vírgula em todos os comandos, aspas simples
    e lista de colunas explícita nos INSERTs)
   ============================================================ */

INSERT INTO professor (id_professor, nome_professor, especialidade) VALUES
(1, 'Ana Lima',       'Biologia'),
(2, 'Carlos Souza',   'Física'),
(3, 'Marina Torres',  'Química'),
(4, 'João Silva',     'Matemática'),
(5, 'Patrícia Gomes', 'Computação');
SELECT * FROM professor;

INSERT INTO recurso (id_recurso, nome, tipo) VALUES
(1, 'Microscópio', 'equipamento'),
(2, 'Projetor',    'equipamento'),
(3, 'Papel A4',    'material'),
(4, 'Caneta',      'material'),
(5, 'Notebook',    'equipamento');
SELECT * FROM recurso;

INSERT INTO equipamento (id_equipamento, numero_serie, garantia_anos) VALUES
(1, 'MIC12345', 2),
(2, 'PRO67934', 3),
(5, 'NOTE0937', 1);
SELECT * FROM equipamento;

-- CORREÇÃO: os materiais eram cadastrados com id 1 e 2 (Microscópio e Projetor,
-- que são equipamentos). Os materiais são Papel A4 (3) e Caneta (4).
INSERT INTO material (id_material, unidade, quantidade) VALUES
(3, 'Resma',   20),
(4, 'Unidade', 100);
SELECT * FROM material;

-- CORREÇÃO: datas inválidas '2025-03-0' e '2025-09-0' -> '2025-03-01' e '2025-09-01'.
INSERT INTO projeto (id_projeto, id_professor, id_recurso, titulo, descricao, data_inicio, data_fim) VALUES
(1, 1, 1, 'Projeto Bioluz',        'Estudo sobre fotossíntese',   '2026-01-10', '2026-08-10'),
(2, 2, 2, 'Física Aplicada',       'Experimentos com luz',        '2026-02-01', '2026-09-01'),
(3, 3, 3, 'Laboratório Química',   'Reações com papel indicador', '2025-03-01', '2025-08-10'),
(4, 4, 4, 'Matemática Visual',     'Geometria com recursos',      '2025-04-01', '2025-09-01'),
(5, 5, 5, 'Computação Móvel',      'Uso de notebooks em aulas',   '2025-05-15', '2025-10-15');
SELECT * FROM projeto;

INSERT INTO atividade (id_atividade, id_projeto, nome_atividade, data_inicio, data_fim) VALUES
(1, 1, 'Coleta de Dados',       '2026-06-15', '2026-07-15'),
(2, 2, 'Experimento 1',         '2026-05-10', '2026-08-10'),
(3, 3, 'Teste de Reações',      '2026-05-20', '2026-08-20'),
(4, 4, 'Aula Prática',          '2026-04-10', '2026-09-10'),
(5, 5, 'Montagem de Ambiente',  '2026-05-20', '2026-10-20');
SELECT * FROM atividade;

INSERT INTO aluno_voluntario (id_aluno, nome_aluno, curso) VALUES
(1, 'Beatriz Ramos', 'Biologia'),
(2, 'Eduardo Costa', 'Física'),
(3, 'Fernanda Melo', 'Química'),
(4, 'Lucas Rocha',   'Matemática'),
(5, 'Rafaela Dias',  'Computação');
SELECT * FROM aluno_voluntario;


/* ============================================================
   4. TABELA ORIENTADOR
   ============================================================ */

-- CORREÇÃO: havia vírgula sobrando antes do ")" e faltava a chave primária.
CREATE TABLE orientador (
    id_orientador        INT UNSIGNED NOT NULL,
    nome_orientador      VARCHAR(40) NOT NULL,
    atividade_orientador VARCHAR(80) NOT NULL,
    PRIMARY KEY (id_orientador)
);

-- CORREÇÃO: havia vírgula no fim do último registro (e faltava o ";").
INSERT INTO orientador (id_orientador, nome_orientador, atividade_orientador) VALUES
(1, 'Ricardo Almeida',   'Engenharia'),
(2, 'Juliana Martins',   'Robótica'),
(3, 'Fernando Oliveira', 'Estatística'),
(4, 'Camila Rodrigues',  'Educação'),
(5, 'Rafael Mendes',     'Inteligência Artificial'),
(6, 'Luciana Ferreira',  'Astronomia'),
(7, 'Gustavo Pereira',   'Tecnologia');
SELECT * FROM orientador;

-- CORREÇÃO: a tabela atividade não tinha a coluna id_orientador, então os UPDATEs
-- abaixo davam erro. Coluna e chave estrangeira criadas aqui.
ALTER TABLE atividade
    ADD COLUMN id_orientador INT UNSIGNED NULL,
    ADD INDEX idx_atividade_orientador (id_orientador),
    ADD CONSTRAINT fk_atividade_orientador
        FOREIGN KEY (id_orientador) REFERENCES orientador (id_orientador);

UPDATE atividade SET id_orientador = 5 WHERE id_atividade = 1;
UPDATE atividade SET id_orientador = 2 WHERE id_atividade = 2;
UPDATE atividade SET id_orientador = 7 WHERE id_atividade = 3;
UPDATE atividade SET id_orientador = 1 WHERE id_atividade = 4;
UPDATE atividade SET id_orientador = 4 WHERE id_atividade = 5;
SELECT * FROM atividade;


/* ============================================================
   5. CONSULTAS (A a K)
   ============================================================ */

/* A) Atividades com data de término posterior a 20 de abril de 2025.
   CORREÇÃO: a data estava '09-02-2000' (formato inválido e valor diferente
   do enunciado). O formato do MySQL é AAAA-MM-DD. */
SELECT * FROM atividade
WHERE data_fim > '2025-04-20';

/* B) Unidade e quantidade em estoque dos materiais com quantidade superior a 100. */
SELECT unidade, quantidade
FROM material
WHERE quantidade > 100;

/* C) Nome e especialidade dos professores que NÃO são da área de Física.
   CORREÇÃO: 'fisica' -> 'Física' (com acento, igual ao dado gravado). */
SELECT nome_professor, especialidade
FROM professor
WHERE especialidade <> 'Física';

/* D) Projetos em andamento (data atual entre data de início e de fim).
   CORREÇÃO: 'Projeto' -> 'projeto' (nomes de tabela diferenciam maiúsculas
   de minúsculas em servidores Linux). */
SELECT * FROM projeto
WHERE CURRENT_DATE BETWEEN data_inicio AND data_fim;

/* E) Nome e área de atuação dos professores de 'Biologia' OU 'Química'.
   CORREÇÃO: as colunas se chamam nome_professor e especialidade (após o
   ALTER) e a condição usava <> com OR, que é sempre verdadeira. */
SELECT nome_professor, especialidade
FROM professor
WHERE especialidade = 'Biologia' OR especialidade = 'Química';

/* F) Nome e tipo dos recursos que NÃO são do tipo 'Equipamento'.
   CORREÇÃO: comparava com a coluna "material" (sem aspas) e o valor
   estava invertido em relação ao enunciado. */
SELECT nome, tipo
FROM recurso
WHERE tipo <> 'equipamento';

/* G) O projeto 'Computação Móvel' tem a data final estendida para 30/11/2025.
   CORREÇÃO: o UPDATE atuava na tabela atividade, buscava por nome_atividade
   e usava a data '2026-12-10'. Deve atualizar a tabela projeto pelo título. */
UPDATE projeto
SET data_fim = '2025-11-30'
WHERE titulo = 'Computação Móvel';

/* H) Renomear a atividade 2 para "Experimento de Refração da Luz". */
UPDATE atividade
SET nome_atividade = 'Experimento de Refração da Luz'
WHERE id_atividade = 2;

/* I) Orientadores da área de Tecnologia.
   CORREÇÃO: a tabela é "orientador" (não "orientadores") e a coluna é
   atividade_orientador (não area_atuacao). */
SELECT * FROM orientador
WHERE atividade_orientador = 'Tecnologia';

/* J) Orientadores cujo ID seja maior que 3. */
SELECT * FROM orientador
WHERE id_orientador > 3;

/* K) Orientadores que não são da área de Educação. */
SELECT * FROM orientador
WHERE atividade_orientador <> 'Educação';


/* ============================================================
   6. EXERCÍCIOS
   ============================================================ */

-- 1. Quantidade total de atividades cadastradas.
SELECT COUNT(*) AS total_atividades
FROM atividade;

-- 2. Média de duração (data_fim - data_inicio) das atividades, em dias.
SELECT AVG(DATEDIFF(data_fim, data_inicio)) AS media_duracao_dias
FROM atividade;

-- 3. Maior data de término das atividades cadastradas.
SELECT MAX(data_fim) AS maior_data_termino
FROM atividade;

-- 4. Soma total de dias de todas as atividades.
SELECT SUM(DATEDIFF(data_fim, data_inicio)) AS total_dias
FROM atividade;

-- 5. Áreas de atuação distintas dos professores.
SELECT DISTINCT especialidade
FROM professor;

-- 6. Alunos e curso do curso Biologia, em ordem alfabética crescente.
SELECT nome_aluno, curso
FROM aluno_voluntario
WHERE curso = 'Biologia'
ORDER BY nome_aluno ASC;

-- 7. Projetos, pulando os 2 primeiros registros.
--    (No MySQL o OFFSET exige o LIMIT; usa-se um valor bem grande.)
SELECT *
FROM projeto
ORDER BY id_projeto
LIMIT 18446744073709551615 OFFSET 2;

-- 8. Cursos e quantidade de alunos voluntários de cada curso.
SELECT curso, COUNT(*) AS qtd_alunos
FROM aluno_voluntario
GROUP BY curso;

-- 9. Cursos com quantidade de alunos voluntários maior ou igual a 1.
SELECT curso, COUNT(*) AS qtd_alunos
FROM aluno_voluntario
GROUP BY curso
HAVING COUNT(*) >= 1;

-- 10. Alunos cuja identificação esteja entre 5 e 10.
SELECT *
FROM aluno_voluntario
WHERE id_aluno BETWEEN 5 AND 10;

-- 11. Professores cujo nome termina com 's'.
SELECT *
FROM professor
WHERE nome_professor LIKE '%s';

-- 12. Visão vw_projetos_andamento: projetos atualmente em andamento.
CREATE OR REPLACE VIEW vw_projetos_andamento AS
SELECT titulo, data_inicio, data_fim
FROM projeto
WHERE CURRENT_DATE BETWEEN data_inicio AND data_fim;

SELECT * FROM vw_projetos_andamento;

-- 13. Visão vw_alunos_curso: total de alunos voluntários agrupados por curso.
CREATE OR REPLACE VIEW vw_alunos_curso AS
SELECT curso, COUNT(*) AS total_alunos
FROM aluno_voluntario
GROUP BY curso;

SELECT * FROM vw_alunos_curso;


/* ============================================================
   7. EXERCÍCIOS EXTRA-CLASSE
   ============================================================ */

-- 1. Todos os nomes distintos de professores cadastrados.
SELECT DISTINCT nome_professor
FROM professor;

-- 2. Cursos distintos dos alunos voluntários.
SELECT DISTINCT curso
FROM aluno_voluntario;

-- 3. Tipos distintos de recurso cadastrados.
SELECT DISTINCT tipo
FROM recurso;

-- 4. Alunos em ordem decrescente do nome.
SELECT *
FROM aluno_voluntario
ORDER BY nome_aluno DESC;

-- 5. Alunos ordenados primeiro pelo curso e depois pelo nome.
SELECT *
FROM aluno_voluntario
ORDER BY curso, nome_aluno;

-- 6. Professores em ordem de área de atuação.
SELECT *
FROM professor
ORDER BY especialidade;

-- 7. Os 2 primeiros projetos cadastrados.
SELECT *
FROM projeto
ORDER BY id_projeto
LIMIT 2;

-- 8. Os 3 primeiros títulos de projetos.
SELECT titulo
FROM projeto
ORDER BY id_projeto
LIMIT 3;

-- 9. Apenas 1 projeto, pulando os 3 primeiros.
SELECT *
FROM projeto
ORDER BY id_projeto
LIMIT 1 OFFSET 3;

-- 10. Quantos recursos existem de cada tipo.
SELECT tipo, COUNT(*) AS qtd_recursos
FROM recurso
GROUP BY tipo;

-- 11. Quantidade de projetos por professor.
SELECT p.id_professor, p.nome_professor, COUNT(pr.id_projeto) AS qtd_projetos
FROM professor p
LEFT JOIN projeto pr ON pr.id_professor = p.id_professor
GROUP BY p.id_professor, p.nome_professor;

-- 12. Projetos iniciados entre 2025-01-01 e 2025-12-31.
SELECT *
FROM projeto
WHERE data_inicio BETWEEN '2025-01-01' AND '2025-12-31';

-- 13. Atividades que terminaram entre 2025-01-01 e 2025-06-30.
SELECT *
FROM atividade
WHERE data_fim BETWEEN '2025-01-01' AND '2025-06-30';

-- 14. Professores cujo nome começa com 'A'.
SELECT *
FROM professor
WHERE nome_professor LIKE 'A%';

-- 15. Alunos cujo curso começa com 'Eng'.
SELECT *
FROM aluno_voluntario
WHERE curso LIKE 'Eng%';

-- 16. Visão com os projetos já concluídos (data de término anterior à data atual).
CREATE OR REPLACE VIEW vw_projetos_concluidos AS
SELECT id_projeto, titulo, data_inicio, data_fim
FROM projeto
WHERE data_fim < CURRENT_DATE;

SELECT * FROM vw_projetos_concluidos;

-- 17. Visão com o nome de cada professor e sua área de atuação.
CREATE OR REPLACE VIEW vw_professores_area AS
SELECT nome_professor, especialidade
FROM professor;

SELECT * FROM vw_professores_area;

-- 18. Visão com todos os recursos cadastrados (nome e tipo).
CREATE OR REPLACE VIEW vw_recursos_tipos AS
SELECT nome, tipo
FROM recurso;

SELECT * FROM vw_recursos_tipos;

-- 19. Professores cujo id esteja entre 2 e 4.
SELECT *
FROM professor
WHERE id_professor BETWEEN 2 AND 4;

-- 20. Professores cujo nome contém 'ana'.
SELECT *
FROM professor
WHERE nome_professor LIKE '%ana%';
