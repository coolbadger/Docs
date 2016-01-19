--view_N4_REP_SUMMARYBYVESSEL

select 
  to_date(to_char(max(atd),'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') as atd
  ,a.name
  ,a.vv_id
  ,IB_VYG
  ,OB_VYG
  ,to_char(sum(case when TYPE = 'IMPORT' and BASIC_LENGTH = 'BASIC20' and FREIGHT_KIND in ('MTY') then 1 else 0 end)) as IE20
  ,to_char(sum(case when TYPE = 'IMPORT' and BASIC_LENGTH = 'BASIC20' and FREIGHT_KIND in ('FCL','LCL') then 1 else 0 end)) as IF20
  ,to_char(sum(case when TYPE = 'IMPORT' and BASIC_LENGTH = 'BASIC40' and FREIGHT_KIND in ('MTY') then 1 else 0 end)) as IE40
  ,to_char(sum(case when TYPE = 'IMPORT' and BASIC_LENGTH = 'BASIC40' and FREIGHT_KIND in ('FCL','LCL') then 1 else 0 end)) as IF40
  
  ,to_char(sum(case when TYPE = 'EXPORT' and BASIC_LENGTH = 'BASIC20' and FREIGHT_KIND in ('MTY') then 1 else 0 end)) as OE20
  ,to_char(sum(case when TYPE = 'EXPORT' and BASIC_LENGTH = 'BASIC20' and FREIGHT_KIND in ('FCL','LCL') then 1 else 0 end)) as OF20
  ,to_char(sum(case when TYPE = 'EXPORT' and BASIC_LENGTH = 'BASIC40' and FREIGHT_KIND in ('MTY') then 1 else 0 end)) as OE40
  ,to_char(sum(case when TYPE = 'EXPORT' and BASIC_LENGTH = 'BASIC40' and FREIGHT_KIND in ('FCL','LCL') then 1 else 0 end)) as OF40
  
  ,to_char(sum(case when TYPE = 'IMPORT' and BASIC_LENGTH = 'BASIC20' then 1 when type = 'IMPORT' and BASIC_LENGTH = 'BASIC40' then 2 else 0 end)) ITEU
  ,to_char(sum(case when TYPE = 'EXPORT' and BASIC_LENGTH = 'BASIC20' then 1 when type = 'EXPORT' and BASIC_LENGTH = 'BASIC40' then 2 else 0 end)) ETEU
  ,to_char(sum(case when TYPE = 'IMPORT' then total/1000 else 0 end)) as IMP_ALL
  ,to_char(sum(case when TYPE = 'IMPORT' then goods/1000 else 0 end)) as IMP_CARGO
  ,to_char(sum(case when TYPE = 'EXPORT' then total/1000 else 0 end)) as EXP_ALL
  ,to_char(sum(case when TYPE = 'EXPORT' then goods/1000 else 0 end)) as EXP_CARGO
from 

(SELECT CV.CARRIER_MODE
  ,'IMPORT' AS TYPE
  ,UNIT.ID
  ,UNIT.GOODS_AND_CTR_WT_KG as total
  ,(UNIT.GOODS_AND_CTR_WT_KG-REQ.TARE_KG) as goods
  ,VS.NAME
  ,VVD.IB_VYG
  ,VVD.OB_VYG
  ,CV.CVCVD_GKEY AS CV_KEY
  ,CV.ID AS vv_id
  ,UNIT.CATEGORY
  ,UNIT.FREIGHT_KIND
  ,EQT.BASIC_LENGTH
  ,CV.ATA
  ,CV.ATD
  ,VVD.START_WORK
  ,VVD.END_WORK

FROM N4USER.INV_UNIT_FCY_VISIT UFV
  LEFT JOIN N4USER.INV_UNIT UNIT ON UFV.UNIT_GKEY = UNIT.GKEY
  LEFT JOIN N4USER.ARGO_CARRIER_VISIT CV ON UFV.ACTUAL_IB_CV = CV.GKEY
  LEFT JOIN N4USER.INV_UNIT_EQUIP EQ ON EQ.UNIT_GKEY = UNIT.GKEY
  LEFT JOIN N4USER.REF_EQUIPMENT REQ ON EQ.EQ_GKEY = REQ.GKEY
  LEFT JOIN N4USER.REF_EQUIP_TYPE EQT ON REQ.EQTYP_GKEY = EQT.GKEY
  LEFT JOIN N4USER.VSL_VESSEL_VISIT_DETAILS VVD ON CV.CVCVD_GKEY = VVD.VVD_GKEY
  LEFT JOIN N4USER.VSL_VESSELS VS ON VVD.VESSEL_GKEY = VS.GKEY
WHERE CV.CARRIER_MODE = 'VESSEL'

UNION

SELECT CV.CARRIER_MODE
  ,'EXPORT' AS TYPE
  ,UNIT.ID
  ,UNIT.GOODS_AND_CTR_WT_KG as total
  ,(UNIT.GOODS_AND_CTR_WT_KG-REQ.TARE_KG) as goods
  ,VS.NAME
  ,VVD.IB_VYG
  ,VVD.OB_VYG
  ,CV.CVCVD_GKEY AS CV_KEY
  ,CV.ID AS vv_id
  ,UNIT.CATEGORY
  ,UNIT.FREIGHT_KIND
  ,EQT.BASIC_LENGTH
  ,CV.ATA
  ,CV.ATD
  ,VVD.START_WORK
  ,VVD.END_WORK

FROM N4USER.INV_UNIT_FCY_VISIT UFV
  LEFT JOIN N4USER.INV_UNIT UNIT ON UFV.UNIT_GKEY = UNIT.GKEY
  LEFT JOIN N4USER.ARGO_CARRIER_VISIT CV ON UFV.ACTUAL_OB_CV = CV.GKEY
  LEFT JOIN N4USER.INV_UNIT_EQUIP EQ ON EQ.UNIT_GKEY = UNIT.GKEY
  LEFT JOIN N4USER.REF_EQUIPMENT REQ ON EQ.EQ_GKEY = REQ.GKEY
  LEFT JOIN N4USER.REF_EQUIP_TYPE EQT ON REQ.EQTYP_GKEY = EQT.GKEY
  LEFT JOIN N4USER.VSL_VESSEL_VISIT_DETAILS VVD ON CV.CVCVD_GKEY = VVD.VVD_GKEY
  LEFT JOIN N4USER.VSL_VESSELS VS ON VVD.VESSEL_GKEY = VS.GKEY
WHERE CV.CARRIER_MODE = 'VESSEL'
  
  ) a
where a.atd is not null
  group by a.name, a.vv_id, a.IB_VYG, a.OB_VYG, IB_VYG, OB_VYG
  order by atd desc