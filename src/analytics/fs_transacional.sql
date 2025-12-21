WITH tb_transacao AS (

    SELECT
        *,
        substr(DtCriacao, 0, 11) AS dtDia,
        cast(substr(DtCriacao, 12, 2) AS int) AS dtHora
    FROM transacoes

    WHERE DtCriacao < '2025-10-01'

),

tb_agg_transacao AS (
    SELECT 
        idCliente,
        count(DISTINCT dtDia) AS qtdeAtivacaoVida,
        count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN dtDia END) AS qtdeAtivacaoD7,
        count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN dtDia END) AS qtdeAtivacaoD14,
        count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN dtDia END) AS qtdeAtivacaoD28,
        count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN dtDia END) AS qtdeAtivacaoD56,

        count(DISTINCT IdTransacao) AS qtdeTransacaoVida,
        count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN IdTransacao END) AS qtdeTransacaoD7,
        count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN IdTransacao END) AS qtdeTransacaoD14,
        count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN IdTransacao END) AS qtdeTransacaoD28,
        count(DISTINCT CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN IdTransacao END) AS qtdeTransacaoD56,

        sum(qtdePontos) AS saldoVida,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN qtdePontos ELSE 0 END) AS saldoD7,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN qtdePontos ELSE 0 END) AS saldoD14,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN qtdePontos ELSE 0 END) AS saldoD28,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN qtdePontos ELSE 0 END) AS saldoD56,

        sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-7 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD7,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-14 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD14,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-28 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD28,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-56 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD56,

        sum(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-7 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD7,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-14 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD14,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-28 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD28,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD56,

        count(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) AS qtdeTransacaoManha,
        count(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) AS qtdeTransacaoTarde,
        count(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) AS qtdeTransacaoNoiteb,

        1. * count(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoManha,
        1. * count(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoTarde,
        1. * count(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoNoiteb

    FROM tb_transacao

    GROUP BY idCliente
),

tb_agg_calc AS (

    SELECT 
        *,
        COALESCE(1. * qtdeTransacaoVida / qtdeAtivacaoVida, 0) AS qtdeTransacaoDia,
        COALESCE(1. * qtdeTransacaoD7 / qtdeAtivacaoD7, 0) AS qtdeTransacaoDiaD7,
        COALESCE(1. * qtdeTransacaoD14 / qtdeAtivacaoD14, 0) AS qtdeTransacaoDiaD14,
        COALESCE(1. * qtdeTransacaoD28 / qtdeAtivacaoD28, 0) AS qtdeTransacaoDiaD28,
        COALESCE(1. * qtdeTransacaoD56 / qtdeAtivacaoD56, 0) AS qtdeTransacaoDiaD56,

        COALESCE(1. * qtdeAtivacaoD28 / 28, 0) AS pctAtivcaoMAU

    FROM tb_agg_transacao
),
tb_horas_dia AS (

    SELECT
        idCliente,
        dtDia,
        24 *  (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracao

    FROM tb_transacao

    GROUP BY idCliente, dtDia
),

tb_hora_cliente AS (
    SELECT 
        idCliente,
        sum(duracao) AS qtdeHorasVida,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-7 day') THEN duracao ELSE 0 END) AS qtdeHorasD7,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
        sum(CASE WHEN dtDia >= date('2025-10-01', '-56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56

    FROM tb_horas_dia

    GROUP BY IdCliente
),

tb_lag_dia AS (
    SELECT
        IdCliente,
        dtDia,
        LAG(dtDia) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS lagDia
    FROM tb_horas_dia
),

tb_intervalo_dias AS (
    SELECT
        IdCliente,
        avg(julianday(dtDia) - julianday(lagDia)) as avgIntervaloDiasVida,
        avg(CASE WHEN dtDia >= date('2025-10-01', '-28 day') THEN julianday(dtDia) - julianday(lagDia) END) as avgIntervaloDiasD28
    FROM tb_lag_dia

    GROUP BY IdCliente
),

tb_join AS (
    SELECT
        t1.*,
        t2.qtdeHorasVida,
        t2.qtdeHorasD7,
        t2.qtdeHorasD14,
        t2.qtdeHorasD28,
        t2.qtdeHorasD56,
        t3.avgIntervaloDiasVida,
        t3.avgIntervaloDiasD28

    FROM tb_agg_calc t1
    LEFT JOIN tb_hora_cliente AS t2
    ON t1.idCliente = t2.idCliente

    LEFT JOIN tb_intervalo_dias AS t3
    ON t1.idCliente = t3.idCliente
)

SELECT
    COUNT CASE WHEN DescNomeProduto = 'ChatMessage' THEN IdTransacao END) AS qtdeChatMessage,
    COUNT CASE WHEN DescNomeProduto = 'Airflow Lover' THEN IdTransacao END) AS qtdeAirflowLover,
    COUNT CASE WHEN DescNomeProduto = 'R Lover' THEN IdTransacao END) AS qtdeRLover,
    COUNT CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN IdTransacao END) AS qtdeResgatarPonei,
    COUNT CASE WHEN DescNomeProduto = 'Lista de presença' THEN IdTransacao END) AS qtdeListadepresença,
    COUNT CASE WHEN DescNomeProduto = 'Presença Streak' THEN IdTransacao END) AS qtdePresençaStreak,
    COUNT CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElements' THEN IdTransacao END) AS qtdeStreamElements,
    COUNT CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN IdTransacao END) AS qtdeReembolsoStreamElements
    
FROM tb_transacao AS t1

LEFT JOIN transacao_produto AS t2
ON t1.IdTransacao = t2.IdTransacao

LEFT JOIN produtos AS t3
ON t2.IdProduto = t3.IdProduto

GROUP BY idCliente