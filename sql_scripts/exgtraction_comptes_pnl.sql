
-------------------------------
--COMPTE PNL
-------------------------------


CREATE OR REPLACE PROCEDURE `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.update_t_o2c_pnl_sap`(
  date_debut DATE,
  date_fin DATE
)
BEGIN

--  création de la table de destination si elle n'existe pas
CREATE TABLE IF NOT EXISTS `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.t_o2c_pnl_sap` (
  date_reference_start DATE,
  date_reference_end DATE,
  company_code STRING,
  company_code_fr STRING,
  VBUND STRING,
  Sl_partenaire STRING,
  ALTKT STRING,
  HKONT STRING,
  BELNR STRING,
  BUDAT DATE,
  BSCHL STRING,
  SHKZG STRING,
  DMBTR FLOAT64,
  SGTXT STRING,
  XBLNR STRING
)
PARTITION BY date_reference_start;

-- Suppression  des données déjà présentes pour cette plage
DELETE FROM `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.t_o2c_pnl_sap`
WHERE date_reference_start = date_debut AND date_reference_end = date_fin;

-- Insertion des écritures PNL sur la période
INSERT INTO `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.t_o2c_pnl_sap`
SELECT 
  date_debut AS date_reference_start,
  date_fin AS date_reference_end,
  b.BUKRS AS company_code,
  cs.CODE_FR AS company_code_fr,
  LPAD(RIGHT(g.VBUND, 4), 4, '0') AS VBUND,
  sp.Sl_partenaire,
  g.ALTKT,
  g.HKONT,
  b.BELNR,
  b.BUDAT,
  g.BSCHL,
  g.SHKZG,
  CASE
    WHEN g.SHKZG = 'H' THEN  -1*g.DMBTR
    WHEN g.SHKZG = 'S' THEN g.DMBTR
  END AS DMBTR,

  g.SGTXT,
  b.XBLNR
FROM `fr-finance-prd.datasharing_sap.bkpf` AS b
JOIN `fr-finance-prd.datasharing_sap.bseg` AS g
  ON b.BUKRS = g.BUKRS AND b.BELNR = g.BELNR AND b.GJAHR = g.GJAHR
JOIN `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.Code_Societe` AS cs
  ON b.BUKRS = LPAD(RIGHT(cs.code_SAP, 4), 4, '0')  -- Jointure pour récupérer le FRxxx

LEFT JOIN `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.SL_partner` AS sp
  ON LPAD(RIGHT(g.VBUND, 4), 4, '0') = sp.Sl_part_valides 

WHERE g.ALTKT IN (
    SELECT COMPTE_GROUPE
    FROM `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.comptes_groupe`
    WHERE TYPE_COMPTE = 'RESULTAT'
)
AND b.BUDAT BETWEEN date_debut AND date_fin
AND LPAD(RIGHT(g.VBUND, 4), 4, '0') IN (
  SELECT Sl_part_valides
  FROM `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.SL_partner`
);


END;

