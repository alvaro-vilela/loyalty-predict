SELECT
    dtRef,
    descLifeCycle,
    count(*)

FROM life_cycle

WHERE descLifeCycle <> '05-ZUMBI'
GROUP BY dtRef, descLifeCycle
ORDER BY dtRef, descLifeCycle
