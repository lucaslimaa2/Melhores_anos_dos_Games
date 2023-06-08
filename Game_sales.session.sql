SELECT * FROM game_sales_data;

-- Jogos mais vendidos de todos os tempos
SELECT 
    *
FROM game_sales_data
ORDER BY Total_Shipped DESC
LIMIT 10; 

-- Aparentemente, os jogos mais vendidos foram entre os anos 1985 e 2017
-- Para entender melhor a base de dados, será investigado quantos filmes não possuem nenhum review (da crítica e dos usuários)
SELECT COUNT(name)
FROM game_sales_data AS g
WHERE critic_score IS NULL AND user_score IS NULL;

-- #9317 (48%) dos jogos não possuem review nenhum. 
-- Anos com as melhores notas segundo os críticos.
SELECT 
    year,
    ROUND(AVG(critic_score),1) AS avg_critic_score
FROM game_sales_data AS g
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Segundo os críticos, os melhores anos foram entre 1982 e 2020
-- Mas alguns anos podem ter notas altas porque foram poucos lançados no ano.

-- Contagem e avaliação crítica média por ano.
CREATE TEMPORARY TABLE top_critics_years AS (
    SELECT 
        year,
        COUNT(name) AS num_games,
        ROUND(AVG(critic_score),2) AS avg_critic_score
    FROM game_sales_data
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 10); 

-- Mesma query acima, mas selecionando anos onde foram lançados acima de 20 jogos. 

CREATE TEMPORARY TABLE top_critics_year_more_than_twenty AS (
    SELECT 
        year,
        COUNT(name) AS num_games,
        ROUND(AVG(critic_score),2) AS avg_critic_score
    FROM game_sales_data
    GROUP BY 1
    HAVING COUNT(name) > 20
    ORDER BY 3 DESC
    LIMIT 10);

-- Selecionando os anos que foram excluídos após o filtro de 20 jogos ser adicionado,
-- Esses anos podem ser armazenados para posteriormente, caso novos dados de reviews saiam, a analise repita.
SELECT year, avg_critic_score 
FROM top_critics_years
EXCEPT
SELECT year, avg_critic_score
FROM top_critics_year_more_than_twenty
ORDER BY avg_critic_score DESC; 


-- Anos em que os Gamers mais gostaram (de acordo com user_review)

CREATE TEMPORARY TABLE top_user_year_more_than_twenty AS (
SELECT
    year,
    ROUND(AVG(user_score), 2) AS avg_user_score,
    COUNT(name) AS num_games
FROM game_sales_data
GROUP BY 1
HAVING COUNT(name) > 20
ORDER BY 2 DESC
LIMIT 10);

-- Agora que encontramos tanto quais anos os críticos e os usuários mais gostaram,
-- podemos ver quais são os anos em comum, esses certamente serão os melhores.
-- Como temos a informação em duas tabelas, basta juntá-las 

SELECT
    top_critics.year
FROM top_critics_year_more_than_twenty AS top_critics
JOIN top_user_year_more_than_twenty AS top_user
    ON top_critics.year = top_user.year;

-- Os anos 1990, 1991, 1993 e 1994 foram os melhores anos da indústria dos Games,
-- segundo as variáveis que escolhemos (anos com mais de 20 jogos lançados e com as maiores notas)

-- Vendas para cada um dos melhores anos

SELECT 
    year,
    SUM(total_shipped) AS total_games_sold
FROM game_sales_data
WHERE year IN(
        SELECT
            top_critics.year
        FROM top_critics_year_more_than_twenty AS top_critics
        JOIN top_user_year_more_than_twenty AS top_user
            ON top_critics.year = top_user.year)
GROUP BY year
ORDER BY 2 DESC;




