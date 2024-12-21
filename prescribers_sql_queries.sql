-- 1* Which Tennessee counties had a disproportionately high number of opioid prescriptions?

--MIKE'S QUERY:--
SELECT c.county, COUNT(*) as opioid_drug_flag
FROM drug AS d
JOIN prescription AS pre
  ON d.drug_name = pre.drug_name
JOIN prescriber AS scribe
  ON pre.npi = scribe.npi
JOIN zip_fips AS zip
  ON scribe.nppes_provider_zip5 = zip.zip
JOIN fips_county AS c
  ON zip.fipscounty = c.fipscounty
WHERE d.opioid_drug_flag = 'Y' AND c.state = 'TN'
GROUP BY c.county
ORDER BY opioid_drug_flag DESC;

--MY QUERY:--

WITH cte1 AS (
    SELECT 
    	COUNT(opioid_drug_flag) AS opioid_count
    ,	f.county
    FROM 
        prescription AS pres
    INNER JOIN 
        drug AS d 
    	ON pres.drug_name = d.drug_name
    INNER JOIN 
        prescriber AS pr 
    	ON pres.npi = pr.npi
    INNER JOIN 
        zip_fips AS z 
    	ON pr.nppes_provider_zip5 = z.zip
    INNER JOIN 
        fips_county AS f 
    	ON z.fipscounty = f.fipscounty
    WHERE 
        d.opioid_drug_flag = 'Y'
        AND f.state = 'TN'
    GROUP BY 
    	f.county
),

cte2 AS (
    SELECT 
    	COUNT(*) AS total_drugs
    ,	f.county
    FROM 
        prescription AS pres
    INNER JOIN 
        drug AS d 
    	ON pres.drug_name = d.drug_name
    INNER JOIN 
        prescriber AS pr 
    	ON pres.npi = pr.npi
    INNER JOIN 
        zip_fips AS z 
    	ON pr.nppes_provider_zip5 = z.zip
    INNER JOIN 
        fips_county AS f 
    	ON z.fipscounty = f.fipscounty
    WHERE 
        f.state = 'TN'
    GROUP BY 
    	f.county
)

SELECT 
    cte1.county AS county,
    cte1.opioid_count AS opioid_count,
    cte2.total_drugs AS total_drugs,
    cte1.opioid_count*100.0/cte2.total_drugs AS diff
FROM cte1
INNER JOIN cte2
ON cte1.county = cte2.county
ORDER BY
    diff DESC;



-------

---SCRATCHWORK:---
SELECT *
FROM prescription;

SELECT *
FROM drug;

select * from fips_county
where county = 'DAVIDSON'
and state = 'TN'

select distinct zip
from zip_fips
where fipscounty = '47037'

select distinct npi
from prescriber
where nppes_provider_zip5 in
(
select distinct zip
from zip_fips
where fipscounty = '47037'
)

select *--count(*)*1.0  drugs_opioid
			from prescription
			where npi in
			(
						select distinct npi
					from prescriber
					where nppes_provider_zip5 in
					(
					select distinct zip
					from zip_fips
					where fipscounty = '47127'
					)
		)
---END SCRATCHWORK:---


--prescription table for reference:
SELECT * 
FROM prescription;

--2* Who are the top opioid prescibers for the state of Tennessee?

--Michelle's Query:--
SELECT COUNT(opioid_drug_flag),pres.nppes_provider_last_org_name
FROM prescriber as pres
INNER JOIN prescription as p
ON pres.npi=p.npi
INNER JOIN drug as d
ON p.drug_name=d.drug_name
INNER JOIN
    zip_fips AS z
	ON pres.nppes_provider_zip5 = z.zip
INNER JOIN
    fips_county AS f
	ON z.fipscounty = f.fipscounty
WHERE
    d.opioid_drug_flag = 'Y'
    AND f.state = 'TN'
GROUP BY
pres.nppes_provider_last_org_name, d.opioid_drug_flag
ORDER BY COUNT(opioid_drug_flag) DESC

--Sabrina's Query:--
SELECT 
	COUNT(opioid_drug_flag) AS opioid_flag_count
,	CONCAT(pres.nppes_provider_first_name,' ',pres.nppes_provider_last_org_name) AS provider_name
FROM prescriber as pres
INNER JOIN prescription as p
ON pres.npi=p.npi
INNER JOIN drug as d
ON p.drug_name=d.drug_name
INNER JOIN
    zip_fips AS z
	ON pres.nppes_provider_zip5 = z.zip
INNER JOIN
    fips_county AS f
	ON z.fipscounty = f.fipscounty
WHERE
    d.opioid_drug_flag = 'Y'
    AND f.state = 'TN'
GROUP BY
	d.opioid_drug_flag
,	provider_name
ORDER BY 
	opioid_flag_count DESC
	
--Mike's Query:--
SELECT 
	CONCAT(nppes_provider_first_name, ' ', nppes_provider_last_org_name) as provider_name, 
	nppes_provider_zip5 as provider_zip,
	COUNT(d.opioid_drug_flag) as opioid_count
FROM prescriber scribe
JOIN prescription script
ON scribe.npi = script.npi
JOIN drug d
ON script.drug_name = d.drug_name
WHERE  d.opioid_drug_flag = 'Y' AND nppes_provider_state = 'TN'
GROUP BY provider_name, provider_zip
ORDER BY opioid_count DESC
---------------


--Filter by 'Coffey'--
SELECT 
	COUNT(opioid_drug_flag) AS flag_count
	-- CONCAT(nppes_provider_first_name, ' ', nppes_provider_last_org_name) as provider_name
-- ,	opioid_drug_flag
-- ,	SUM(total_claim_count)
FROM prescriber AS pres
INNER JOIN prescription AS rx
	ON pres.npi=rx.npi
INNER JOIN drug AS d
	ON rx.drug_name=d.drug_name
WHERE
	nppes_provider_last_org_name ILIKE 'COFFEY'
	AND opioid_drug_flag = 'Y'
ORDER BY flag_count
	

-- 3* What did the trend in overdose deaths due to opioids look like in Tennessee from 2015 to 2018?
/*NOTES: overdose_deaths and fips_county tables*/


SELECT fipscounty
FROM fips_county

SELECT fipscounty
FROM overdose_deaths

----------

--Michelle's Query:
SELECT 
	COUNT(overdose_deaths)
,	year
,	MAX(tot_ratio)	
FROM
	prescription as p
INNER JOIN
	drug as d
ON
	p.drug_name=d.drug_name
INNER JOIN
	prescriber as pres
ON
	pres.npi=p.npi
INNER JOIN
	zip_fips as z
ON
	z.zip=pres.nppes_provider_zip5 
INNER JOIN
	overdose_deaths as o
ON
	z.fipscounty::INTEGER=o.fipscounty::INTEGER
INNER JOIN
	fips_county as f
ON
	o.fipscounty::INTEGER=f.fipscounty::INTEGER
WHERE
    d.opioid_drug_flag = 'Y'
    AND f.state = 'TN'
	AND year BETWEEN  2015 AND 2018

---Mike's Query:---
SELECT SUM(od.overdose_deaths), od.year
	FROM overdose_deaths od
	JOIN fips_county fc
	ON od.fipscounty = fc.fipscounty::integer
	JOIN zip_fips zip
	ON fc.fipscounty = zip.fipscounty
WHERE fc.state = 'TN' AND od.year BETWEEN 2015 AND 2019
GROUP BY od.year 

-- 4* Is there an association between rates of opioid prescriptions and overdose deaths by county?
--NOTE: maybe plot as two diff variables in Python?

WITH cte1 AS (
    SELECT 
        COUNT(d.opioid_drug_flag) AS opioid_count,
        f.county
    FROM 
        prescription AS pres
    INNER JOIN 
        drug AS d 
        ON pres.drug_name = d.drug_name
    INNER JOIN 
        prescriber AS pr 
        ON pres.npi = pr.npi
    INNER JOIN 
        zip_fips AS z 
        ON pr.nppes_provider_zip5 = z.zip
    INNER JOIN 
        fips_county AS f 
        ON z.fipscounty::INTEGER = f.fipscounty::INTEGER
    WHERE 
        d.opioid_drug_flag = 'Y' AND f.state = 'TN'
    GROUP BY 
        f.county
),
od_data AS (
    SELECT 
        f.county,
        SUM(od.overdose_deaths) AS total_deaths
    FROM 
        overdose_deaths AS od
    INNER JOIN 
        fips_county AS f 
        ON od.fipscounty::INTEGER = f.fipscounty::INTEGER
    WHERE 
        f.state = 'TN'
    GROUP BY 
        f.county
)
SELECT 
    cte1.county,
    cte1.opioid_count,
	od_data.total_deaths,
    od_data.total_deaths*100.0/cte1.opioid_count AS rate
FROM 
    cte1
INNER JOIN 
    od_data 
    ON cte1.county = od_data.county
ORDER BY rate DESC;

-- 5* Is there any association between a particular type of opioid and number of overdose deaths?

-- WITH cte1 AS
-- (
SELECT 
	-- DISTINCT(o.year),
	o.year,
	COUNT(o.overdose_deaths) AS count_od,
	-- SUM(o.overdose_deaths) AS sum_od,
	d.drug_name, 
	fc.county
	FROM prescription AS rx
	INNER JOIN drug AS d
	ON rx.drug_name=d.drug_name
	INNER JOIN prescriber AS p
	ON rx.npi=p.npi
	INNER JOIN zip_fips AS zip
	ON p.nppes_provider_zip5=zip.zip
	JOIN fips_county AS fc
	ON zip.fipscounty::integer=fc.fipscounty::integer
	INNER JOIN overdose_deaths AS o
	ON fc.fipscounty::Integer=o.fipscounty::integer
WHERE fc.state = 'TN' AND d.opioid_drug_flag = 'Y' 
GROUP BY d.drug_name, o.year, fc.county
ORDER BY o.year ASC, count_od DESC

-----


SELECT DISTINCT year --2015-2018
FROM overdose_deaths;

----

SELECT 
	fipscounty,
	year,
	overdose_deaths
FROM overdose_deaths
WHERE fipscounty = '47037'
GROUP BY
	fipscounty,
	year,
	overdose_deaths
ORDER BY fipscounty,overdose_deaths DESC;

-- cte2 AS
-- (
-- SELECT drug_name
-- 	FROM drug
-- WHERE opioid_drug_flag = 'Y'
-- ORDER BY drug_name
-- )

-- SELECT drug_name
-- FROM cte1
-- INNER JOIN cte2
-- 	USING