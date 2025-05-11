SELECT
  bilan.date_reference,
  bilan.company_code,
  bilan.company_code_fr,
  bilan.VBUND,
  bilan.Sl_partenaire,
  bilan.ALTKT,
  bilan.HKONT,
  bilan.BELNR,
  bilan.BUDAT,
  bilan.BSCHL,
  bilan.SHKZG,
  bilan.DMBTR,
  bilan.AUGBL,
  bilan.SGTXT,
  bilan.XBLNR
FROM `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.t_o2c_pns_sap_bilan` AS bilan

JOIN (
  SELECT email_utilisateur, TRIM(code) AS code_societe
  FROM (
    SELECT email_utilisateur, code_societe AS code_clean
    FROM `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.User_perimetre`
  ), UNNEST(SPLIT(code_clean, ',')) AS code
) AS acl
  ON acl.code_societe = bilan.company_code_fr
  AND acl.email_utilisateur = @DS_USER_EMAIL
