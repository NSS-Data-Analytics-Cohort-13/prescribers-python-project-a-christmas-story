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

--Q3 : What did the trend in overdose deaths due to opioids look like in Tennessee from 2015 to 2018?
-- deaths, filter TN, filter 2015 to 2018
SELECT COUNT(o.overdose_deaths) AS deaths
FROM
    prescription AS p
INNER JOIN
    drug AS d
ON
    p.drug_name = d.drug_name
INNER JOIN
    prescriber AS pres
ON
    pres.npi = p.npi
INNER JOIN
    zip_fips AS z
ON
    pres.nppes_provider_zip5 = z.zip
INNER JOIN
    overdose_deaths AS o
ON
    CAST(z.fipscounty AS INTEGER) = CAST(o.fipscounty AS INTEGER)
INNER JOIN
    fips_county AS f
ON
    CAST(o.fipscounty AS INTEGER) = CAST(f.fipscounty AS INTEGER)
WHERE
    d.opioid_drug_flag = 'Y'
    AND f.state = 'TN'
    AND o.year BETWEEN 2015 AND 2018;

--Q4 : Is there an association between rates of opioid prescriptions and overdose deaths by county?
-- prescriptions, deaths, filter by county, compare


--Q5 : Is there any association between a particular type of opioid and number of overdose deaths?
-- opioid type, deaths, compare

