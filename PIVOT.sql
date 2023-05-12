﻿--PIVOT
SELECT * 
FROM DT_RESULT_FINAL2
ORDER BY PRODUCTGROUP, PRODUCT, ITEM, YEARWEEK, SALES, MEASURE;

-- 기준으로 잡은 것만 바뀐다.
-- MEASURE부분의 칼럼명은 일일이 쳐야한다.
SELECT * 
FROM (
      SELECT * 
      FROM DT_RESULT_FINAL2
)PIVOT(
      SUM(SALES)
      FOR MEASURE IN 
      ('REAL-QTY' AS REAL_QTY, 'PREDICTION-QTY' AS PREDICTION_QTY)
)
ORDER BY PRODUCTGROUP, PRODUCT, ITEM, YEARWEEK;
-- ITEM만 넣고 정렬하면, 원하는 값이 안나온다. 그래서 전부 넣어준다





SELECT * 
FROM ( 
        SELECT A.REGIONID, A.PRODUCT, B.QTY, LPAD(SUBSTR(B.YEARWEEK,5,2),3,'W')AS WEEK
        FROM KOPO_CHANNEL_SEASONALITY_NEW A
        RIGHT JOIN (
            SELECT ROUND(AVG(NVL(QTY,0)))AS QTY, YEARWEEK
            FROM KOPO_CHANNEL_SEASONALITY_NEW A
            GROUP BY YEARWEEK
        )B
        ON A.QTY = B.QTY 
)PIVOT(
       SUM(QTY)
       FOR WEEK IN 
       ('W01' AS W01,'W02' AS W02,'W03' AS W03,'W52' AS W52,'W53' AS W53)
)
ORDER BY REGIONID, PRODUCT;



SELECT * 
FROM (       
      SELECT A.REGIONID, A.PRODUCT, A.QTY, LPAD(SUBSTR(A.YEARWEEK,5,2),3,'W')AS WEEK
      FROM KOPO_CHANNEL_SEASONALITY_NEW A
)PIVOT(
       AVG(QTY)
       FOR WEEK IN 
       ('W01' AS W01,'W02' AS W02,'W03' AS W03,'W52' AS W52,'W53' AS W53)
)
ORDER BY REGIONID, PRODUCT;





-- 교수님
SELECT 
    REGIONID, PRODUCT, WEEK, ROUND(AVG(QTY)) AS QTY
FROM(
    SELECT REGIONID,
           PRODUCT,
           SUBSTR(YEARWEEK,0,4) AS YEAR,
           SUBSTR(YEARWEEK,5,2) AS WEEK,
           QTY
    FROM KOPO_CHANNEL_SEASONALITY_NEW
)
WHERE 1=1 
AND REGIONID = 'A00'
AND PRODUCT= 'PRODUCT34'
GROUP BY REGIONID, PRODUCT, WEEK;



SELECT * 
FROM ( 
        SELECT 
            REGIONID, PRODUCT, WEEK, ROUND(AVG(QTY)) AS QTY
        FROM(
            SELECT REGIONID,
                   PRODUCT,
                   SUBSTR(YEARWEEK,0,4) AS YEAR,
                   SUBSTR(YEARWEEK,5,2) AS WEEK,
                   QTY
            FROM KOPO_CHANNEL_SEASONALITY_NEW
        )
        GROUP BY REGIONID, PRODUCT, WEEK
)PIVOT(
       SUM(QTY)
       FOR WEEK IN 
       ('01' AS W01,'02' AS W02,'03' AS W03,'52' AS W52,'53' AS W53)
)
ORDER BY REGIONID, PRODUCT;




SELECT * 
FROM ( 
        SELECT 
            REGIONID, PRODUCT, LPAD(WEEK,3,'W') AS WEEK, ROUND(AVG(QTY)) AS QTY
        FROM(
            SELECT REGIONID,
                   PRODUCT,
                   SUBSTR(YEARWEEK,0,4) AS YEAR,
                   SUBSTR(YEARWEEK,5,2) AS WEEK,
                   QTY
            FROM KOPO_CHANNEL_SEASONALITY_NEW
        )
        GROUP BY REGIONID, PRODUCT, WEEK
)PIVOT(
       AVG(QTY)
       FOR WEEK IN 
       ('W01' AS W01,'W02' AS W02,'W03' AS W03,'W52' AS W52,'W53' AS W53)
)
ORDER BY REGIONID, PRODUCT;


---------------------------------------------------------------------

--UNPIVOT
WITH T AS(
    SELECT * FROM DT_RESULT_FINAL3
)
SELECT * FROM T 
UNPIVOT(
    QTY FOR MEASURE IN(REAL_QTY,PREDICTION_QTY)
);


WITH T AS (
    SELECT * 
    FROM ( 
            SELECT 
                REGIONID, PRODUCT, LPAD(WEEK,3,'W') AS WEEK, ROUND(AVG(QTY)) AS QTY
            FROM(
                SELECT REGIONID,
                       PRODUCT,
                       SUBSTR(YEARWEEK,0,4) AS YEAR,
                       SUBSTR(YEARWEEK,5,2) AS WEEK,
                       QTY
                FROM KOPO_CHANNEL_SEASONALITY_NEW
            )
            GROUP BY REGIONID, PRODUCT, WEEK
    )PIVOT(
           AVG(QTY)
           FOR WEEK IN 
           ('W01' AS W01,'W02' AS W02,'W03' AS W03,'W52' AS W52,'W53' AS W53)
    )
    ORDER BY REGIONID, PRODUCT
)SELECT * FROM T
UNPIVOT(
    QTY FOR WEEK IN (W01, W02, W03, W52, W53)
)
ORDER BY REGIONID, PRODUCT, WEEK, QTY;


--------------------------------------------------------

--ROWNUM
--20개만 보여준다
SELECT * FROM KOPO_CHANNEL_SEASONALITY_NEW 
WHERE 1=1
AND ROWNUM <= 20;


--PARTITION BY
SELECT A.*,
       --PARTITION BY EQUAL
       -- ROW_NUMBER() OVER (ORDER BUY QTY DESC)
       AVG(QTY) OVER(PARTITION BY REGIONID) AS AVG_REGIONID_QTY,
       AVG(QTY) OVER(PARTITION BY REGIONID, PRODUCT) AS AVG_REGIONID_PRODUCT_QTY
FROM KOPO_CHANNEL_SEASONALITY_NEW A;
-- PARTITION BY가 GROUP BY 역할

--특정 칼럼에 대해 정렬 후 내림차순으로 만들고, 순서를 매긴다.
SELECT A.*, ROW_NUMBER() OVER(PARTITION BY PRODUCTGROUP ORDER BY A.VOLUME DESC) AS RANK2
FROM KOPO_PRODUCT_VOLUME A;


---------------------------------------

--ROW_NUMBER, RANK, DENSE_RANK의 차이 
SELECT A.*,
       ROW_NUMBER() OVER(ORDER BY SUM_QTY DESC) AS REGION_PRODUCT_ROW,
       RANK() OVER(ORDER BY SUM_QTY DESC) AS REGION_PRODUCT_RANK,
       DENSE_RANK() OVER(ORDER BY SUM_QTY DESC) AS REGION_PRODUCT_DRANK       
FROM(
      SELECT REGIONID, PRODUCT, SUM(QTY) AS SUM_QTY
      FROM KOPO_CHANNEL_SEASONALITY_NEW
      GROUP BY REGIONID, PRODUCT
      ORDER BY REGIONID, SUM_QTY
)A
ORDER BY SUM_QTY DESC;

--ROW_NUMBER : 순번
--RANK : 1,2,2,4
--DENSE_RANK의 : 1,2,2,3



