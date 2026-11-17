-- ========================================================
-- PROYECTO: Consultas Analíticas Avanzadas y Segmentación RFM
-- AUTOR: Stiven Escobar Carabalí
-- ========================================================

-- 1. Cálculo de métricas RFM (Recencia, Frecuencia, Valor Monetario) usando CTEs
WITH Metricas_RFM AS (
    SELECT 
        c.cliente_id,
        c.nombre,
        c.tipo_cliente,
        c.ciudad,
        DATEDIFF(DAY, MAX(v.fecha_venta), GETDATE()) AS Recencia_Dias,
        COUNT(v.venta_id) AS Frecuencia_Compras,
        SUM(v.monto_total) AS Valor_Monetario_Total
    FROM Clientes c
    INNER JOIN Ventas v ON c.cliente_id = v.cliente_id
    GROUP BY c.cliente_id, c.nombre, c.tipo_cliente, c.ciudad
),
-- 2. Clasificación por cuartiles usando NTILE (Window Function)
Scores_RFM AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY Recencia_Dias DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frecuencia_Compras ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Valor_Monetario_Total ASC) AS M_Score
    FROM Metricas_RFM
)
SELECT 
    cliente_id,
    nombre,
    tipo_cliente,
    ciudad,
    Recencia_Dias,
    Frecuencia_Compras,
    Valor_Monetario_Total,
    CASE 
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Cliente Campeón (VIP)'
        WHEN R_Score >= 3 AND F_Score >= 2 THEN 'Cliente Leal'
        WHEN R_Score <= 2 AND M_Score >= 3 THEN 'En Riesgo de Abandono (Alto Valor)'
        ELSE 'Cliente Regular / Ocasional'
    END AS Segmento_Comercial
FROM Scores_RFM
ORDER BY Valor_Monetario_Total DESC;

-- 3. Crecimiento Mensual y Acumulado de Ventas por Ciudad (Window Functions: LAG & SUM OVER)
WITH Ventas_Mensuales AS (
    SELECT 
        c.ciudad,
        FORMAT(v.fecha_venta, 'yyyy-MM') AS Mes,
        SUM(v.monto_total) AS Ventas_Mes
    FROM Ventas v
    INNER JOIN Clientes c ON v.cliente_id = c.cliente_id
    GROUP BY c.ciudad, FORMAT(v.fecha_venta, 'yyyy-MM')
)
SELECT 
    ciudad,
    Mes,
    Ventas_Mes,
    LAG(Ventas_Mes) OVER (PARTITION BY ciudad ORDER BY Mes) AS Ventas_Mes_Anterior,
    ROUND(((Ventas_Mes - LAG(Ventas_Mes) OVER (PARTITION BY ciudad ORDER BY Mes)) / 
           NULLIF(LAG(Ventas_Mes) OVER (PARTITION BY ciudad ORDER BY Mes), 0)) * 100, 2) AS Crecimiento_Pct,
    SUM(Ventas_Mes) OVER (PARTITION BY ciudad ORDER BY Mes) AS Acumulado_Anual_Ciudad
FROM Ventas_Mensuales
ORDER BY ciudad, Mes;
