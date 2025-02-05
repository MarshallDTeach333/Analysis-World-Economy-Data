
/* KPI: 
A KPI (Key Performance Indicator) is a specific measurement that shows how well something is performing or progressing toward a goal. 
For example, if a company wants to track its sales growth, it might use “monthly sales” as a KPI. 
In other words, a KPI is a number or metric that helps you quickly see how successful a project, department, or country is in reaching its objectives.*/

/* INDICATOR:
An indicator is simply a piece of information—or a statistic—that helps you measure something in a consistent way. 
For example, “GDP” (Gross Domestic Product) is an indicator that shows the size of a country’s economy. 
Other indicators might measure things like a country’s population, life expectancy, or inflation rate. 
In short, an indicator tells you something specific you can measure and compare—across countries, regions, or over time.*/

SELECT *
FROM wereldeconomie;

SELECT *
FROM indicatoren;

SELECT *
FROM landen;


-- ------------------------1 STER ---------------------------------------
-- Selecteer alle landen die dezelfde inkomensgroep hebben als België.
-- MAIN
SELECT CountryName
FROM landen
WHERE IncomeGroup = 
		-- SUB1
        (SELECT IncomeGroup
        FROM landen
        WHERE CountryName LIKE '%belgium%');

-- Maak een lijst van alle landcodes uit de regio “Europe & Central Asia” 
	-- waarbij het energieverbruik in het jaar 2000 ontbreekt. 
-- Maak gebruik van een subquery.
-- Tip: missende waarden kunnen herkend worden met de ‘IS NULL’ filter.

-- MAIN (filteren op regio)
SELECT Country_Code
FROM landen
WHERE Region = 'Europe & Central Asia'
AND Country_Code IN 
    -- SUB (filteren op NULL en jaar)
    (SELECT Country_code
    FROM wereldeconomie
    WHERE Year = 2000
    AND KPI IS NULL);


-- ------------------2 STERREN ------------------------------------
-- Lijst alle landen (naam, regio en inkomensgroep) 
	-- die een bovengemiddeld GDP hebben boven het wereldwijde gemiddelde in het jaar 2020.

-- MAIN
SELECT CountryName,
	   Region,
       IncomeGroup
FROM landen
WHERE Country_Code IN 
	-- SUB1 (Country_Code landen bovengemiddeld)
    (SELECT Country_Code
    FROM wereldeconomie
    WHERE Year = 2020
    AND Indicator_Code LIKE '%GDP%'
    AND KPI > 
		-- SUB2 (wereldwijd gemiddelde GDP in 2020)
		(SELECT AVG(KPI) AS avg_kpi
		FROM wereldeconomie ));
    


-- Bereken voor elk jaar en voor elk land 
	-- het percentage van de wereldbevolking dat in dat land woont.

-- MAIN (percentage berekenen)
SELECT Country_Code,
	   sub_land.KPI AS bevolking_per_land_per_jaar,
	   ROUND((sub_land.KPI / sub_tot.totaal_wereldbevolking_per_jaar)*100, 6) AS percentage, -- (percentage wereldbevolking per land, per jaar) (afgerond op 6 na de komma)
       sub_tot.totaal_wereldbevolking_per_jaar,
       sub_land.Year
	  -- SUB_1 (totale bevolking per land, per jaar)
FROM (SELECT Year,
			 Country_Code,
			 KPI
	  FROM wereldeconomie
	  WHERE Indicator_Code LIKE '%POP%'
	  ORDER BY Year, Country_Code) AS sub_land
			-- SUB_1 (totale wereldbevolking berekenen per jaar)
LEFT JOIN (SELECT Year,
				  SUM(KPI) AS totaal_wereldbevolking_per_jaar
		   FROM wereldeconomie
		   WHERE Indicator_Code LIKE '%POP%'
		   GROUP BY Year) AS sub_tot
ON sub_land.Year = sub_tot.Year
ORDER BY sub_land.Year, Country_Code;


    
-- Maak de som van al het elektriciteitsverbruik in alle landen in de regio “Europe & Central Asia” 
	-- voor het jaar 2018.    !!! FOUT IN DATASET => antwoord : NULL !!!    => met andere jaren lukt dat wel (bvb. 1960)
    -- Nakijken welke waardes NULL zijn bij KPI (energieverbruik)
				SELECT Year, KPI AS totaal_electriciteit_verbruikt
				FROM wereldeconomie 
				WHERE Indicator_Code LIKE '%ELEC%' AND Y;
    
-- MAIN (totale el.verbruik in 2018)   
SELECT SUM(KPI) AS totaal_electriciteit_verbruikt
FROM wereldeconomie 
WHERE Indicator_Code LIKE '%ELEC%'
AND Year = 1960
AND Country_Code IN
					-- SUB (Country_code landen in regio “Europe & Central Asia”)
					(SELECT Country_Code
					FROM landen
					WHERE Region = 'Europe & Central Asia');
    
-- ----------------------3 STERREN ---------------------------------------
-- Welk land had de grootste bevolkingsgroei tussen 2019 en 2020?  !!! FOUT IN DATASET => Regions IN CountryName !!!

SELECT bevolking2019.Country_Code,
	   (inwoners2020 - inwoners2019) AS bevolkingsgroei
	  -- SUB_1 (bevoking_2019 per land) 
FROM (SELECT Country_Code,
			 KPI AS inwoners2019
	 FROM wereldeconomie
     WHERE Indicator_Code LIKE '%POP%'
     AND Year = 2019
     AND Country_Code IN (SELECT Country_Code      -- SUB_3 (Regions uit CountryName filteren)
								FROM landen
                                WHERE Region IS NOT NULL)) AS bevolking2019     -- => Dataset (CountryName) niet proper > Regions soms ook bij CountryName
		   -- SUB_2 (bevoking_2020 per land)
LEFT JOIN (SELECT Country_Code,
			 KPI AS inwoners2020
		   FROM wereldeconomie
		   WHERE Indicator_Code LIKE '%POP%'
		   AND Year = 2020
           AND Country_Code IN (SELECT Country_Code      -- SUB_3 (Regions uit CountryName filteren)
								FROM landen
                                WHERE Region IS NOT NULL)) AS bevolking2020      -- => Dataset (CountryName) niet proper > Regions soms ook bij CountryName
ON bevolking2019.Country_Code = bevolking2020.Country_Code
ORDER BY bevolkingsgroei DESC
LIMIT 10;

-- Heeft België, in vergelijking met alle landen uit dezelfde inkomensgroep, 
	-- een boven of onder gemiddeld energieverbruik? 
-- Bekijk deze trend over de jaren heen.