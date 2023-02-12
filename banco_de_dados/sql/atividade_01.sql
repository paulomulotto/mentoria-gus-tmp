/*

Qdo finalizar subir no git

Sua missão é criar um banco de dados para salvar informações de uma escola de idiomas.

Essa escola tem de inglês e espanhol.
Cada idioma tem 3 niveis, iniciante, intermediário e avançado
Para cada classe, é necessário salvar os alunos participantes, o professor responsável, o idioma e o nível
EXTRA: Como você faria para salvar as informações de presença por aula por aluno?
*/

-- Quando começar a projetar seu banco de dados, pense que a escola pode crescer e ter mais cursos de idiomas.
-- Busque fazer as implementações pensando em evitar alterações futuras nas estruturas de dados
-- Os campos estão no melhor estado possível? As tabelas estão responsáveis por somente uma entidade (objeto).

CREATE DATABASE escola_v2;
USE escola_v2;

CREATE TABLE Idioma(
	id INT NOT NULL AUTO_INCREMENT, 
    idioma char(30) CHARACTER SET utf8mb4 NOT NULL,
    -- pq se eu coloco NOT NULL antes do character set ele da erro?
    nivel CHAR(13) CHARACTER SET utf8mb4 NOT NULL, 
    PRIMARY KEY(id),
    -- já que toda Turma vai ter um idioma E um NÍVEL, nível precisa também ser uma primary key?
    CONSTRAINT chk_nivel CHECK (nivel IN ('iniciante', 'intermediario', 'avancado'))
    -- isso pode dar problema se por exemplo o usuário inserir INICIANTE ou intermediÁrio
);
DROP TABLE Idioma;

CREATE TABLE Professor(
	id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255) CHARACTER SET utf8mb4 not null,
    idioma_id INT NOT NULL, 
    valor_aula DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (idioma_id) REFERENCES Idioma(id)
);
DROP TABLE Professor;

CREATE TABLE Turma(
	id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255) CHARACTER SET utf8mb4 not null,
    qtde_aulas_semanais INT UNSIGNED NOT NULL, 
	dia_da_semana CHAR(15) CHARACTER SET utf8mb4 not null,
    hora_da_aula INT UNSIGNED NOT NULL,
    professor_id INT NOT NULL,
    -- aluno_id INT NOT NULL, 
    PRIMARY KEY (id),
    FOREIGN KEY (professor_id) REFERENCES Professor(id),
    -- FOREIGN KEY (aluno_id) REFERENCES Aluno(id)
    -- num banco não relacional, seria possivel ter uma chave/valor unica para o professor e ir 
    -- adicionando/removendo alunos dentro de um outro conjunto de chave/valor?
    -- aqui no SQL 
    CONSTRAINT chk_dia_da_semana CHECK (dia_da_semana IN ('segunda', 'terca', 'quarta','quinta','sexta')),
    CONSTRAINT chk_hora_da_aula CHECK (hora_da_aula IN (8, 9, 10, 11, 16, 17, 18, 19, 20))
    -- procurei mas não achei, daria para turma, calcular o calor da mensalidade multiplicando
    -- Turma.qtde_aulas_semanais * Professor.valor_aula
	-- Ou isso deveria ficar para o "código" calcular? Tipo o exemplo da Náthaly?
);   
DROP TABLE Turma;

CREATE TABLE Aluno(
	id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255) CHARACTER SET utf8mb4 not null,
    -- idioma_id INT NOT NULL, 
    dia_de_vencimento INT UNSIGNED NOT NULL DEFAULT 10,
    desconto_porcentagem INT UNSIGNED NOT NULL DEFAULT 0, 
    turma_id INT NOT NULL,
    PRIMARY KEY (id),
    -- FOREIGN KEY (idioma_id) REFERENCES Idioma(id)
    FOREIGN KEY (turma_id) REFERENCES Turma(id),
    -- tenho que relacionar aluno com a turma, mas turma ainda n foi criada
    -- tenho que relacionar turma com o aluno, que tbm precisa ser criara
    -- tbm relacionamento preica ser N:N pq Aluno pode estar em várias turmas 
    CONSTRAINT chk_dia_de_vencimento CHECK (dia_de_vencimento <= 31),
    CONSTRAINT desconto_porcentagem CHECK (dia_de_vencimento <= 100)
);
DROP TABLE Aluno;
    
INSERT INTO Idioma (idioma, nivel) VALUES ('Ingles', 'iniciante');
INSERT INTO Idioma (idioma, nivel) VALUES ('Ingles', 'avancado');
INSERT INTO Idioma (idioma, nivel) VALUES ('Ingles', 'teste');
SELECT * FROM Idioma;

INSERT INTO Professor (nome, idioma_id, valor_aula) VALUES ('Paulo', 1, 100);
INSERT INTO Professor (nome, idioma_id, valor_aula) VALUES ('Gustavo', 2, 50);
INSERT INTO Professor (nome, idioma_id, valor_aula) VALUES ('Teste', 3); 
-- como não criei o id=3 em idioma, por isso ele n deixa criar o professor?
SELECT * FROM Professor;

SELECT 
	Professor.nome,
    Professor.valor_aula,
    Idioma.idioma,
    Idioma.nivel
FROM 
	Professor
INNER JOIN
	Idioma
ON	
	Professor.idioma_id=Idioma.id;
    
    
INSERT INTO Turma (nome, qtde_aulas_semanais, dia_da_semana, hora_da_aula, professor_id) VALUES ('Turma 01', 1, 'terca', 19, 1);
INSERT INTO Turma (nome, qtde_aulas_semanais, dia_da_semana, hora_da_aula, professor_id) VALUES ('Turma 02', 1, 'quarta', 8, 1);
INSERT INTO Turma (nome, qtde_aulas_semanais, dia_da_semana, hora_da_aula, professor_id) VALUES ('Turma 03', 1, 'sexta', 8, 2);
INSERT INTO Turma (nome, qtde_aulas_semanais, dia_da_semana, hora_da_aula, professor_id) VALUES ('Turma 04', 1, 'sabado', 8, 2);
-- lascou! como que eu poderia fazer aulas 2 vezes na semana?
SELECT * FROM Turma;

SELECT 
	Turma.nome, Turma.qtde_aulas_semanais, Turma.dia_da_semana, Turma.hora_da_aula,
    t2.nome, t2.valor_aula, t2.idioma, t2.nivel,
    4*Turma.qtde_aulas_semanais*t2.valor_aula as mensalidade
FROM
	Turma
INNER JOIN (
	SELECT 
		Professor.id, Professor.nome, Professor.valor_aula,
        Idioma.idioma, Idioma.nivel
	FROM 
		Professor
	INNER JOIN Idioma ON Professor.idioma_id=Idioma.id
) as t2
ON Turma.professor_id=t2.id
ORDER BY Turma.nome;

INSERT INTO Aluno (nome, turma_id) VALUES ('João', 1);
INSERT INTO Aluno (nome, dia_de_vencimento, desconto_porcentagem, turma_id) VALUES ('José', 11, 50, 1);
SELECT * FROM Aluno;	

WITH resumo AS (
	SELECT 
		Turma.id, Turma.nome as nome_turma, Turma.qtde_aulas_semanais, Turma.dia_da_semana, Turma.hora_da_aula,
		t2.nome as nome_aluno, t2.valor_aula, t2.idioma, t2.nivel,
		4*Turma.qtde_aulas_semanais*t2.valor_aula as mensalidade
	FROM
		Turma
	INNER JOIN (
		SELECT 
			Professor.id, Professor.nome, Professor.valor_aula,
			Idioma.idioma, Idioma.nivel
		FROM 
			Professor
		INNER JOIN Idioma ON Professor.idioma_id=Idioma.id
	) as t2
	ON Turma.professor_id=t2.id
	ORDER BY Turma.nome
)
SELECT 
	Aluno.nome, Aluno.dia_de_vencimento, Aluno.desconto_porcentagem,
    resumo.nome_turma, resumo.qtde_aulas_semanais, resumo.dia_da_semana, resumo.hora_da_aula,
    resumo.nome_aluno, resumo.idioma, resumo.nivel,
    resumo.mensalidade as mensalidade_antes_desconto,
    resumo.mensalidade*(100-Aluno.desconto_porcentagem)/100 as mensalidade_final
FROM 
	Aluno
INNER JOIN resumo ON resumo.id=Aluno.turma_id
