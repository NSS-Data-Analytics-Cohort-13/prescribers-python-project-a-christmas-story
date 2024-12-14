-- * Which Tennessee counties had a disproportionately high number of opioid prescriptions?

--MIKE'S QUERY:--
select 
	fc.county as county
,	d.opioid_drug_flag
from drug as d
cross join fips_county as fc
where d.opioid_drug_flag = 'Y' and fc.state = 'TN'
group by d.opioid_drug_flag, fc.county

--MY QUERY:--
SELECT 
	COUNT(opioid_drug_flag) as flag_count
,	f.county
,	f.fipscounty
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
	f.fipscounty
,	f.county
ORDER BY 
	flag_count DESC

--prescription table for reference:--
SELECT * 
FROM prescription;

-- * Who are the top opioid prescibers for the state of Tennessee?
-- * What did the trend in overdose deaths due to opioids look like in Tennessee from 2015 to 2018?
-- * Is there an association between rates of opioid prescriptions and overdose deaths by county?
-- * Is there any association between a particular type of opioid and number of overdose deaths?
