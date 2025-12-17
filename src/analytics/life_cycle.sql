-- curiosa -> idade < 7
-- fiel -> recencia < 7 e recencia anterior < 15
-- turista -> recensa =< 15
-- desencantado -> recencia =< 28
-- zumbi -> recencia > 28
-- reconquistado -> recencia < 7 e 14 <= recencia anterior <= 28
-- reborn -> recencia < 7 e 28 < recencia anterior 

With tb_daily AS (
    SELECT
        DISTINCT
            IdCliente,
            substr(DtCriacao,0,11) as dtDia

    FROM transacoes
    WHERE DtCriacao < '{date}'
),

tb_idade AS (
    SELECT
        IdCliente,
        -- min(dtDia) as dtPrimTransacao,
        cast(max(julianday('{date}') - julianday(dtDia)) as int) AS qtdeDiasPrimTransacao,

        -- max(dtDia) as dtUltTransacao,
        cast(min(julianday('{date}') - julianday(dtDia)) as int) AS qtdeDiasUltTransacao
    FROM tb_daily

    GROUP BY idCliente
),

tb_rn AS (
    SELECT
        *,
        row_number() OVER (PARTITION BY IdCliente ORDER BY dtDia DESC) AS rnDia

    FROM tb_daily
),

tb_penultima_ativacao AS (
    SELECT 
        *,
        CAST(julianday('{date}') - julianday(dtDia) AS INT) AS qtdeDiasPenultimaTransacao
    FROM tb_rn
    WHERE rnDia = 2
),

tb_life_cycle AS (
    SELECT 
        t1.*,
        t2.qtdeDiasPenultimaTransacao,
        CASE
            WHEN qtdeDiasPrimTransacao <= 7 THEN '01-CURIOSO'
            WHEN qtdeDiasUltTransacao <= 7 AND 	qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao <= 14 THEN '02-FIEL'
            WHEN qtdeDiasUltTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
            WHEN qtdeDiasUltTransacao BETWEEN 15 AND 27 THEN '04-DESENCANTADA'
            WHEN qtdeDiasUltTransacao >= 28 THEN '05-ZUMBI'
            WHEN qtdeDiasUltTransacao <= 7 AND 	qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao BETWEEN 15 AND 27 THEN '02-RECONQUISTADO'
            WHEN qtdeDiasUltTransacao <= 7 AND 	qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao > 28 THEN '02-REBORN'

        END AS descLifeCycle

    FROM tb_idade AS t1

    LEFT JOIN tb_penultima_ativacao AS t2
    ON t1.idCliente = t2.idCliente
)

SELECT 
    date('{date}','-1 day') AS dtRef,
    *
FROM tb_life_cycle;