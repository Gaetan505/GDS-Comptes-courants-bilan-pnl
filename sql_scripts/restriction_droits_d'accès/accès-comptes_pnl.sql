SELECT
  pnl.date_reference_start,
  pnl.date_reference_end,
  pnl.company_code,
  pnl.company_code_fr,
  pnl.VBUND,
  pnl.Sl_partenaire,
  pnl.ALTKT,
  pnl.HKONT,
  pnl.BELNR,
  pnl.BUDAT,
  pnl.BSCHL,
  pnl.SHKZG,
  pnl.DMBTR,
  pnl.SGTXT,
  pnl.XBLNR
FROM `vg1p-apps-dacdata-prd1-b9.o2c_data_recovery_sapps.t_o2c_pnl_sap` AS pnl

JOIN (
  SELECT email_utilisateur, TRIM(code) AS code_societe
  FROM (
    SELECT email_utilisateur, code_societe AS code_clean
    FROM `vg1p-apps-dacdata-prd1-b9.o2c_tables_google_sheets.User_perimetre`
  ), UNNEST(SPLIT(code_clean, ',')) AS code
) AS acl
  ON acl.code_societe = pnl.company_code_fr
  AND acl.email_utilisateur = @DS_USER_EMAIL
