--Q1 : Which Tennessee counties had a disproportionately high number of opioid prescriptions?
--Credit to Sabrina
WITH cte1 AS(
SELECT
	COUNT(opioid_drug_flag) AS proportion
,	f.county
--,	f.fipscounty
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
INNER JOIN
    population AS pop
	ON f.fipscounty = pop.fipscounty
WHERE
    d.opioid_drug_flag = 'Y'
    AND f.state = 'TN'
GROUP BY
--	f.fipscounty
	f.county
ORDER BY
	proportion DESC
	)
,
cte2 AS (
---------
SELECT
	COUNT(*) AS total_drugs
,	f.county
--,	f.fipscounty
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
--INNER JOIN
 --   population AS pop
	--ON f.fipscounty = pop.fipscounty
WHERE
    f.state = 'TN'
GROUP BY
--	f.fipscounty
	f.county
ORDER BY
	COUNT(*) DESC
)
SELECT * ,cte1.proportion*100.0/cte2.total_drugs
FROM cte1
INNER JOIN cte2
	USING(county)

--Q2 : Who are the top opioid prescibers for the state of Tennessee?
-- prescibers, filter for TN, total day supply and/or 30 day supply
--Michelle's Query
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

--Sabrina's Query
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

--Mike's Query/Group's Official Answer: 

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

--Group Answer:


--Q3 : What did the trend in overdose deaths due to opioids look like in Tennessee from 2015 to 2018?
-- deaths, filter TN, filter 2015 to 2018

-- if overdose_deaths includes deaths from other drug types
SELECT SUM(od.overdose_deaths), od.year
	FROM overdose_deaths od
	JOIN fips_county fc
	ON od.fipscounty = fc.fipscounty::integer
	JOIN zip_fips zip
	ON fc.fipscounty = zip.fipscounty
	JOIN prescriber scribe
	ON scribe.nppes_provider_zip5 = zip.zip
	JOIN prescription script
	ON scribe.npi = script.npi
	JOIN drug d
	ON script.drug_name = d.drug_name
WHERE d.opioid_drug_flag = 'Y' AND fc.state = 'TN' AND od.year BETWEEN 2015 AND 2019
GROUP BY od.year

--Q3 overdose_deaths only pertains to opioid ods
SELECT SUM(od.overdose_deaths), od.year
	FROM overdose_deaths od
	JOIN fips_county fc
	ON od.fipscounty = fc.fipscounty::integer
	JOIN zip_fips zip
	ON fc.fipscounty = zip.fipscounty
WHERE fc.state = 'TN' AND od.year BETWEEN 2015 AND 2019
GROUP BY od.year

--Q4 : Is there an association between rates of opioid prescriptions and overdose deaths by county?
-- prescriptions, deaths, filter by county, compare

--Plot as two different variables in Python 

--Q5 : Is there any association between a particular type of opioid and number of overdose deaths?
-- opioid type, deaths, compare

SELECT SUM(o.overdose_deaths) AS sum_od, o.year, d.drug_name
	FROM prescription AS rx
	JOIN drug AS d
	ON rx.drug_name=d.drug_name
	JOIN prescriber AS p
	ON rx.npi=p.npi
	JOIN zip_fips AS zip
	ON p.nppes_provider_zip5=zip.zip
	JOIN fips_county AS fc
	ON zip.fipscounty::integer=fc.fipscounty::integer
	JOIN overdose_deaths AS o
	ON fc.fipscounty::Integer=o.fipscounty::integer
WHERE fc.state = 'TN' AND d.opioid_drug_flag = 'Y'
GROUP BY o.year, d.drug_name
ORDER BY o.year
