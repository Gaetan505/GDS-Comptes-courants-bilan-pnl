----------------------------------------------------------------------------
-----------  COMPTE COURANT
----------------------------------------------------------------------------


SELECT 
  b.BUKRS AS company_code,
  cs.CODE_FR AS company_code_fr,
  LPAD(RIGHT(g.VBUND, 4), 4, '0') AS VBUND,
  sp.Sl_partenaire AS VBUND_part, 
  g.ALTKT,
  g.HKONT,
  b.BELNR,
  b.BUDAT,
  g.BSCHL,
  g.SHKZG,
  b.USNAM,
  CASE
    WHEN g.SHKZG = 'H' THEN -1 * g.DMBTR
    WHEN g.SHKZG = 'S' THEN g.DMBTR
  END AS DMBTR,
  g.SGTXT
FROM `fr-finance-prd.datasharing_sap.bkpf` AS b
JOIN `fr-finance-prd.datasharing_sap.bseg` AS g
  ON b.BUKRS = g.BUKRS AND b.BELNR = g.BELNR AND b.GJAHR = g.GJAHR
JOIN `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.Code_Societe` AS cs
  ON b.BUKRS = LPAD(RIGHT(cs.code_SAP, 4), 4, '0')
LEFT JOIN `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.SL_partner` AS sp
  ON LPAD(RIGHT(g.VBUND, 4), 4, '0') = sp.Sl_part_valides
--  Autorisations
JOIN `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.User_perimetre` AS acl
  ON acl.code_societe = cs.CODE_FR
  AND acl.email_utilisateur = @DS_USER_EMAIL

WHERE g.ALTKT IN (
  SELECT COMPTE_GROUPE
  FROM `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.comptes_groupe`
  WHERE TYPE_COMPTE = 'COMPTES COURANTS'
)
AND b.BUDAT < CURRENT_DATE()
AND LPAD(RIGHT(g.VBUND, 4), 4, '0') IN (
  SELECT Sl_part_valides
  FROM `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.SL_partner`
);
