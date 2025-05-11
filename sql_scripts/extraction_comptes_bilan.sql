

------------------------------
-- COMPTE BILAN
--------------------------------

CREATE OR REPLACE PROCEDURE `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.update_t_o2c_PNS_sap`(REPLAY_SINCE DATE)
BEGIN

--  Définition de  la date de traitement (par défaut hier)
DECLARE PROCESS_DT DATE DEFAULT DATE_SUB(CURRENT_DATE("Europe/Paris"), INTERVAL 1 DAY);

--  liste de dates à traiter
DECLARE HISTORIC_DATE_ARRAY ARRAY<DATE>;
IF REPLAY_SINCE IS NOT NULL THEN
  SET HISTORIC_DATE_ARRAY = GENERATE_DATE_ARRAY(REPLAY_SINCE, PROCESS_DT);
ELSE
  SET HISTORIC_DATE_ARRAY = [PROCESS_DT];
END IF;


--  table de destination si elle n'existe pas
CREATE TABLE IF NOT EXISTS `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.t_o2c_pns_sap_bilan` (
  date_reference DATE,
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
  AUGBL STRING,
  SGTXT STRING,
  XBLNR STRING
)
PARTITION BY date_reference;

--  On Boucle sur chaque date pour rejouer l'historique
FOR I IN (SELECT * FROM UNNEST(HISTORIC_DATE_ARRAY)) DO

  -- Suppression des  données précédentes pour cette date
  DELETE FROM `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.t_o2c_pns_sap_bilan`
  WHERE date_reference = I.f0_;

  -- Insertion des pièces non soldées à cette date
  INSERT INTO `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.t_o2c_pns_sap_bilan`
  SELECT
    I.f0_ AS date_reference,
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
    g.AUGBL,
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
      WHERE TYPE_COMPTE = 'BILAN'
  )
  AND b.BUDAT <= I.f0_
  AND (g.AUGDT IS NULL OR g.AUGDT > I.f0_)
  AND LPAD(RIGHT(g.VBUND, 4), 4, '0') IN (
    SELECT Sl_part_valides
    FROM `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.SL_partner`
);

END FOR;

END;


