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
---------


--prescription table for reference:
SELECT * 
FROM prescription;

--3* Who are the top opioid prescibers for the state of Tennessee?

--Michelle's Query:
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

--Readjusted Query:
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


---Reverse Engineer:
SELECT 
FROM  

-- 3* What did the trend in overdose deaths due to opioids look like in Tennessee from 2015 to 2018?

SELECT zip --54181 records
FROM zip_fips; 

SELECT nppes_provider_zip5 --25050 records
FROM prescriber;

SELECT drug_name
FROM prescription;

SELECT drug_name
FROM drug;

--Michelle's Query:
SELECT 
	COUNT(overdose_deaths)
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
-- * Is there an association between rates of opioid prescriptions and overdose deaths by county?


-- * Is there any association between a particular type of opioid and number of overdose deaths?
