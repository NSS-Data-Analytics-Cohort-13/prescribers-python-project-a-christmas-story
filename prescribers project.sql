-- Q1) Which Tennessee counties had a disproportionately high number of opioid prescriptions?

SELECT COUNT(opioid_drug_flag) as opioid_count, c.county
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
ORDER BY opioid_count DESC;

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
        ON z.fipscounty = f.fipscounty
    WHERE 
        d.opioid_drug_flag = 'Y' AND f.state = 'TN'
    GROUP BY 
        f.county
),
cte2 AS (
    SELECT 
        COUNT(*) AS total_drugs,
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
        ON z.fipscounty = f.fipscounty
    WHERE 
        f.state = 'TN'
    GROUP BY 
        f.county
)
SELECT 
    cte1.county, 
    cte1.opioid_count, 
    cte2.total_drugs, 
    cte1.opioid_count * 100.0 / cte2.total_drugs AS diff
FROM 
    cte1
INNER JOIN 
    cte2
    ON cte1.county = cte2.county
ORDER BY diff DESC;

-- Q2) Who are the top opioid prescibers for the state of Tennessee?

SELECT
	SUM(total_claim_count),
	COUNT(opioid_drug_flag) as flag_count,
	CONCAT(nppes_provider_first_name, ' ', nppes_provider_last_org_name) as provider_name
FROM
    prescription AS pres
INNER JOIN
    drug AS d
	ON pres.drug_name = d.drug_name
INNER JOIN
    prescriber AS pr
	ON pres.npi = pr.npi
WHERE
    d.opioid_drug_flag = 'Y'
    AND nppes_provider_state = 'TN'
GROUP BY
	provider_name
ORDER BY
	SUM(total_claim_count) DESC

SELECT
	SUM(total_claim_count),
	CONCAT(nppes_provider_first_name, ' ', nppes_provider_last_org_name) as provider_name
FROM
    prescription AS pres
INNER JOIN
    drug AS d
	ON pres.drug_name = d.drug_name
INNER JOIN
    prescriber AS pr
	ON pres.npi = pr.npi
WHERE
    d.opioid_drug_flag = 'Y'
    AND nppes_provider_state = 'TN'
GROUP BY
	provider_name
ORDER BY
	SUM(total_claim_count) DESC

SELECT 
	CONCAT(nppes_provider_first_name, ' ', nppes_provider_last_org_name) as provider_name, 
	COUNT(d.opioid_drug_flag) as opioid_count
FROM prescriber scribe
JOIN prescription script
ON scribe.npi = script.npi
JOIN drug d
ON script.drug_name = d.drug_name
WHERE  d.opioid_drug_flag = 'Y' AND nppes_provider_state = 'TN'
GROUP BY provider_name
ORDER BY opioid_count DESC

-- Q3) What did the trend in overdose deaths due to opioids look like in Tennessee from 2015 to 2018?

SELECT SUM(od.overdose_deaths), od.year
FROM overdose_deaths od
JOIN fips_county fc
ON od.fipscounty = fc.fipscounty::integer
WHERE fc.state = 'TN' AND od.year BETWEEN 2015 AND 2019
GROUP BY od.year

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

SELECT SUM(od.overdose_deaths), od.year
	FROM overdose_deaths od
	JOIN fips_county fc
	ON od.fipscounty = fc.fipscounty::integer
	JOIN zip_fips zip
	ON fc.fipscounty = zip.fipscounty
WHERE fc.state = 'TN' AND od.year BETWEEN 2015 AND 2019
GROUP BY od.year

SELECT SUM(o.overdose_deaths) AS deaths, o.year
FROM prescription AS p
	JOIN drug AS d
	ON p.drug_name = d.drug_name
	JOIN prescriber AS pres
	ON pres.npi = p.npi
	JOIN zip_fips AS z
	ON pres.nppes_provider_zip5 = z.zip
	JOIN overdose_deaths AS o
	ON
    	CAST(z.fipscounty AS INTEGER) = CAST(o.fipscounty AS INTEGER)
	JOIN fips_county AS f
	ON
    	CAST(o.fipscounty AS INTEGER) = CAST(f.fipscounty AS INTEGER)
WHERE d.opioid_drug_flag = 'Y'AND f.state = 'TN'
    AND o.year BETWEEN 2015 AND 2018
GROUP BY o.year
ORDER BY o.year;

-- Q4) Is there an association between rates of opioid prescriptions and overdose deaths by county?

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

-- Q5) Is there any association between a particular type of opioid and number of overdose deaths?

SELECT
	COUNT(opioid_drug_flag) AS proportion,	
	f.county
FROM prescription AS pres
JOIN drug AS d
ON pres.drug_name = d.drug_name
JOIN prescriber AS pr
ON pres.npi = pr.npi
JOIN zip_fips AS z
ON pr.nppes_provider_zip5 = z.zip
JOIN fips_county AS f
ON z.fipscounty::integer = f.fipscounty::integer
JOIN population AS pop
ON f.fipscounty = pop.fipscounty
WHERE d.opioid_drug_flag = 'Y' AND f.state = 'TN'
GROUP BY f.county
ORDER BY proportion DESC

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
	ON fc.fipscounty::integer=o.fipscounty::integer
WHERE fc.state = 'TN' AND d.opioid_drug_flag = 'Y'
GROUP BY o.year, d.drug_name
ORDER BY d.drug_name

SELECT o.overdose_deaths, d.drug_name
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
	ON fc.fipscounty::integer=o.fipscounty::integer
WHERE fc.state = 'TN' AND d.opioid_drug_flag = 'Y'
GROUP BY o.overdose_deaths, d.drug_name
ORDER BY d.drug_name