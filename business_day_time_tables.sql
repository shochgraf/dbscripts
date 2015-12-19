
DROP TABLE IF EXISTS PDW.BW_TIME_WEEK_T;
CREATE TABLE IF NOT EXISTS PDW.BW_TIME_WEEK_T(
	WEEK_ID varchar(6) PRIMARY KEY,
	WEEK_STARTDATE DATE, 
	WEEK_ENDDATE DATE
);

CREATE INDEX bw_startenddate_idx ON PDW.BW_TIME_WEEK_T (WEEK_STARTDATE, WEEK_ENDDATE);


INSERT INTO PDW.BW_TIME_WEEK_T
SELECT DISTINCT WEEK_ID,
	FIRST_VALUE(PERIOD_ID) OVER(PARTITION BY WEEK_ID
				ORDER BY PERIOD_ID
				ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) WEEK_STARTDATE,
	LAST_VALUE(PERIOD_ID) OVER(PARTITION BY WEEK_ID
				ORDER BY PERIOD_ID
				ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) WEEK_ENDDATE	
FROM(
	SELECT YEAR_ID, 
		YEAR_ID||MONTH_OF_YEAR MONTH_ID, 
		ISO_YEAR_ID||WEEK WEEK_ID,
		YEAR_ID||QUARTER QUARTER_ID,
		TO_DATE(TO_CHAR(TS, 'MM/DD/YYYY'),'MM/DD/YYYY') PERIOD_ID,
		DAY_OF_MONTH,
		DAY_OF_WEEK, 
		DAY_OF_YEAR
	FROM(
		SELECT TS, 
			TRIM(TO_CHAR(EXTRACT(YEAR FROM TS), '9999')) YEAR_ID,
			TRIM(TO_CHAR(EXTRACT(ISOYEAR FROM TS), '9999')) ISO_YEAR_ID,
			TRIM(TO_CHAR(EXTRACT(MONTH FROM TS), '00')) MONTH_OF_YEAR,
			TRIM(TO_CHAR(EXTRACT(DAY FROM TS), '00')) DAY_OF_MONTH,
			TRIM(TO_CHAR(EXTRACT(QUARTER FROM TS),'00')) QUARTER,
			TRIM(TO_CHAR(EXTRACT(ISODOW FROM TS),'0')) DAY_OF_WEEK,
			TRIM(TO_CHAR(EXTRACT(DOY FROM TS),'000')) DAY_OF_YEAR,
			TRIM(TO_CHAR(EXTRACT(WEEK FROM TS),'00')) WEEK
		 FROM GENERATE_SERIES('1920-01-01'::TIMESTAMP, '2038-01-01', '1DAY'::INTERVAL) AS T(TS)
	) SUB
	WHERE DAY_OF_WEEK in ('1', '2', '3', '4', '5')
) SUB2;