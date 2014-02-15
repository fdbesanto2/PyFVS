      SUBROUTINE EXDBS
      IMPLICIT NONE
C----------
C  $Id: exdbs.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C  EXTERNAL REFERENCES FOR THE DATA BASE CONNECTION CODE.
C----------

      INTEGER IREAD,IRECNT,JOSTND,KEY,IWHO,NAGE
      INTEGER IYEAR,IAGE,IPRDLEN,IACC,IFORTP,IMORT,ITPA,IBA,ISDI,
     &     ICCF,ITOPHT,ITCUFT,IMCUFT,IBDFT,IRTPA,IRTCUFT,IRMCUFT,
     &     IRBDFT,ISZCL,ISTCL,IATBA,IATSDI,IATCCF,IATTOPHT,
     &     CNPYHT,SMORTBA,MMORTBA,SMORTVOL,MMORTVOL,BIOMASS,
     &     CONSUMED,REMOVED,ID,KODE,ITREE,IPLOT,HISTORY,
     &     CRWNR,DMG1,DMG2,DMG3,SVR1,SVR2,SVR3,TREEVAL,PRESCRIPT,
     &     SLOPE,ASPECT,HABITAT,TOPOCODE,SITEPREP,STANDGT3,STANDTOTAL,
     &     SVLH,SVLS,YRLAST,PERTRCR,RCODE,S1NHT,S2NHT,S3NHT,S1LHT,
     &     S2LHT,S3LHT,S1SHT,S2SHT,S3SHT,S1CB,S2CB,S3CB,S1CC,S2CC,S3CC,
     &     TOTCOV,NS,S1SC,S2SC,S3SC,NTREES,NSCL,ISDSP
      REAL SFLMSU,MFLMSU,TORCHI,CROWNI,CNPYDNST,SPSMOKE,MPSMOKE,
     &    FUELWT,SFUELWT,FQMD,FATQMD,FVALU,YMAI,LITTER,DUFF,SDEADLT3,
     &    SDEADGT3,SDEAD3TO6,SDEAD6TO12,SDEADGT12,HERB,SHRUB,
     &    SURFTOTAL,SNAGSLT3,SNAGSGT3,FOLIAGE,STANDLT3,
     &    DBH,DG,HT,HTG,HTTOPK,RCOUNT,SFLMTO,MFLMTO,SPTRCH,MPTRCH,
     &    HCL1,HCL2,HCL3,HCL4,HCL5,HCL6,SCL1,SCL2,SCL3,SCL4,SCL5,SCL6,
     &    ONEHR,TENHR,HUNDHR,THOUSHR,LIVEW,LIVEH,MFWIND,FLAME,SCORCH,
     &    KILLED,TOTAL,BAKILL,VOKILL,MSE,CLT3,CGT3,C3TO6,C6TO12,CGT12,
     &    CROWN,CTOTAL,PERCDUFF,PERCGT3,SM25,SM10,SDBH,SHTH,
     &    SHTS,SDH,SDS,S1DBH,S2DBH,S3DBH,TEM
      REAL PREDBKP,POSTDBKP,RV,STD_BA,BAH,BAK,TPA,TPAH,TPAK,
     &     VOL,VOLH,VOLKld,BA_SP,SPCL_TPA,IPSLSH,REMBKP,
     &     SANBAREM,SANTREM1,SANTREM2,VOLREMSAN,VOLREMSAL
      REAL aTPA(10),aTPAH(10),TPAKLL(10),SPCLTRE(10),
     &   SAN1,SAN2,SAN3,SAN4,SAN5,SAN6,SAN7,SAN8,SAN9,SAN10
      REAL OLDBKP,NEWBKP,SELFBKP,TO_LS,FRM_LS,BKPIN,BKPOUT,
     & BKPSV,STRPBKP,STRP_SC,DVRV1,DVRV2,DVRV3,DVRV4,DVRV5,
     & DVRV6,DVRV7,DVRV8,DVRV9,TPAFAST,BAFAST,VOLFAST,SDLO,SDHI
      REAL TVOL(10),HVOL(10),VOLK(10),NUMSC
      REAL    STDMR,STDMI,ABIRTH
      REAL    DCTPA(10),DCINF(10),DCMRT(10),DCDMR(10),DCDMI(10)
      REAL    SPDMR4(4),SPDMI4(4),SPINF4(4),SPMRT4(4)
      REAL    SPPIN4(4),SPPMR4(4),SPPOC4(4),WT(4),FILL(200)
      REAL SPVIAB,SPBA,SPTPA,SPMORT1,SPMORT2,SPGMULT,
     >     SPSITGM,MXDENMLT,POTESTAB
      INTEGER I,J,FM(4),I1,I2,I3,I4,CID
      INTEGER ISTTPAT,ISTVOL,ISTTPAI,ISTBAI,ISTVOLI,ISTTPAM,ISTBAM
      INTEGER ISTVOLM,ISTPIT,ISTPIV,ISTPMT,ISTPMV,SPECIESID
      INTEGER FUELMOD,SFUELMOD,VARDIM
      DIMENSION FUELMOD(*),FUELWT(*),SFUELMOD(*),SFUELWT(*),KILLED(*),
     &          TOTAL(*),BAKILL(*),VOKILL(*),SDBH(*),SHTH(*),SHTS(*),
     &          SDH(*),SDS(*),SVLH(*),SVLS(*)
      CHARACTER*(*) KEYWRD
      CHARACTER*3 SPECIES,S1MS1,S1MS2,S2MS1,S2MS2,S3MS1,S3MS2
      CHARACTER*4 SCLASS
      CHARACTER*2 CSP(*)
      CHARACTER*8 NODBS,PASKEY,SFTYPE,MFTYPE,FTYPE
      CHARACTER*26 NPLT
      CHARACTER*3 NLABS(5)
      REAL ARRAY(*),VAR(*)
      LOGICAL DEBUG,LACTV,LNOTBK(*),LCOUT,LCIN,LKECHO
      integer :: sumTableId, beginAnalYear, endTime
      real :: costUndisc, revUndisc, costDisc, revDisc, npv, irr,
     &      bcRatio, rrr, sev, forestValue, reprodValue
      logical :: sevCalculated, rrrCalculated,
     &      forestValueCalculated, reprodValueCalculated,
     &      irrCalculated, bcRatioCalculated
      character(len=*) :: pretend
      real :: minDia, maxDia, minDbh, maxDbh
      integer :: tpaCut, tpaValue, tonsPerAcre, ft3Volume, ft3Value,
     &      bfVolume, bfValue, totalValue
      integer :: status
      character(len=2000) :: SQLStmtStr
C
      DATA NODBS/'*NO DBAS'/
C
      ENTRY DBSIN (KEYWRD,ARRAY,ISDSP,SDLO,SDHI,LNOTBK,LKECHO)
      CALL ERRGRO (.TRUE.,11)
      RETURN
      ENTRY DBSINIT
      RETURN
      ENTRY DBSACTV(LACTV)
      LACTV = .FALSE.
      RETURN
      ENTRY DBSKEY (KEY,PASKEY)
      PASKEY=NODBS
      RETURN
      ENTRY DBSCMPU
      RETURN
      ENTRY DBSCLOSE(LCOUT,LCIN)
      RETURN
      ENTRY  DBSSUMRY(IYEAR,IAGE,NPLT,ITPA,IBA,ISDI,ICCF,
     &  ITOPHT,FQMD,ITCUFT,IMCUFT,IBDFT,IRTPA,IRTCUFT,IRMCUFT,IRBDFT,
     &  IATBA,IATSDI,IATCCF,IATTOPHT,FATQMD,IPRDLEN,IACC,IMORT,YMAI,
     &  IFORTP,ISZCL,ISTCL)
      RETURN
      ENTRY DBSATRTLS(IWHO,KODE,TEM)
      RETURN
      ENTRY DBSTRLS(IWHO,KODE,TEM)
      RETURN
      ENTRY DBSCLSUM(NPLT,IYEAR,CSP,SPVIAB,
     >          SPBA,SPTPA,SPMORT1,SPMORT2,SPGMULT,
     >          SPSITGM,MXDENMLT,POTESTAB)
      RETURN
      ENTRY DBSCUTS(IWHO,KODE)
      RETURN
      ENTRY DBSFMPF(IYEAR,NPLT,SFLMSU,MFLMSU,SFLMTO,MFLMTO,SFTYPE,
     &  MFTYPE,SPTRCH,MPTRCH,TORCHI,CROWNI,CNPYHT,
     &  CNPYDNST,SMORTBA,MMORTBA,SMORTVOL,MMORTVOL,
     &  SPSMOKE,MPSMOKE,SFUELMOD,SFUELWT,FUELMOD,FUELWT,KODE)
      RETURN
      ENTRY DBSFUELS(IYEAR,NPLT,LITTER,DUFF,SDEADLT3,SDEADGT3,SDEAD3TO6,
     &  SDEAD6TO12,SDEADGT12,HERB,SHRUB,SURFTOTAL,SNAGSLT3,SNAGSGT3,
     &  FOLIAGE,STANDLT3,STANDGT3,STANDTOTAL,BIOMASS,CONSUMED,REMOVED,
     &  KODE)
      RETURN
      ENTRY DBSFMCRPT(IYEAR,NPLT,VAR,VARDIM,KODE)
      RETURN
      ENTRY DBSFMHRPT(IYEAR,NPLT,VAR,VARDIM,KODE)
      RETURN
      ENTRY DBSFMDWVOL(IYEAR,NPLT,VAR,VARDIM,KODE)
      RETURN
      ENTRY DBSFMDWCOV(IYEAR,NPLT,VAR,VARDIM,KODE)
      RETURN
      ENTRY DBSFMSSNAG(IYEAR,NPLT,HCL1,HCL2,HCL3,HCL4,HCL5,HCL6,
     &  SCL1,SCL2,SCL3,SCL4,SCL5,SCL6,KODE)
      RETURN      
      ENTRY DBSFMDSNAG(IYEAR,SDBH,SHTH,SHTS,SVLH,SVLS,
     &  SDH,SDS,YRLAST,KODE)
      RETURN
      ENTRY DBSFMFUEL(IYEAR,NPLT,MSE,LITTER,DUFF,CLT3,CGT3,
     &  C3TO6,C6TO12,CGT12,HERB,CROWN,CTOTAL,PERCDUFF,PERCGT3,
     &  PERTRCR,SM25,SM10,KODE)
      RETURN
      ENTRY DBSFMMORT(IYEAR,KILLED,TOTAL,BAKILL,
     &  VOKILL,KODE)                
      RETURN
      ENTRY DBSFMBURN(IYEAR,NPLT,ONEHR,TENHR,HUNDHR,THOUSHR,DUFF,
     &  LIVEW,LIVEH,MFWIND,SLOPE,FLAME,SCORCH,FTYPE,FM,WT,KODE)      
      RETURN    
      ENTRY DBSFMCANPR(IYEAR,FILL,NPLT)      
      RETURN
      ENTRY DBSFMLINK(I)      
      RETURN   
      ENTRY DBSTREESIN(IPLOT,ITREE,RCOUNT,HISTORY,SPECIES,DBH,DG,
     &    HT,HTTOPK,HTG,CRWNR,DMG1,SVR1,DMG2,SVR2,DMG3,SVR3,TREEVAL,
     &    PRESCRIPT,SLOPE,ASPECT,HABITAT,TOPOCODE,SITEPREP,KODE,
     &    DEBUG,JOSTND,LKECHO,ABIRTH)
      KODE=0
      RETURN
      ENTRY DBSMIS1(IYEAR,NPLT,CSP,
     &  SPDMR4,SPDMI4,SPINF4,SPMRT4,SPPIN4,SPPMR4,SPPOC4,
     &  KODE)
      RETURN
      ENTRY DBSMIS2(IYEAR,NPLT,NAGE,
     &  ISTTPAT,IBA,ISTVOL,ISTTPAI,ISTBAI,ISTVOLI,ISTTPAM,ISTBAM,
     &  ISTVOLM,ISTPIT,ISTPIV,ISTPMT,ISTPMV,STDMR,STDMI,KODE)
      RETURN
      ENTRY DBSMIS3(IYEAR,NPLT,NLABS,
     &  DCTPA,DCINF,DCMRT,DCDMR,DCDMI,KODE)
      RETURN
      ENTRY DBSEVM (I,J,KODE,JOSTND)
      RETURN
      ENTRY DBSPPPUT (ARRAY,I,J)
      RETURN
      ENTRY DBSPPGET (ARRAY,I,J)
      RETURN
      ENTRY DBSPUSPUT (KEYWRD,I,J)
      RETURN
      ENTRY DBSPUSGET (KEYWRD,I,J)
      RETURN
      ENTRY DBSCASE (I)
      RETURN
      ENTRY DBSVKFN (KEYWRD)
      RETURN
      ENTRY DBSSTRCLASS(IYEAR,NPLT,RCODE,S1DBH,S1NHT,S1LHT,S1SHT,
     &  S1CB,S1CC,S1MS1,S1MS2,S1SC,S2DBH,S2NHT,S2LHT,S2SHT,S2CB,S2CC,
     &  S2MS1,S2MS2,S2SC,S3DBH,S3NHT,S3LHT,S3SHT,S3CB,S3CC,S3MS1,S3MS2,
     &  S3SC,NS,TOTCOV,SCLASS,KODE,NTREES)
      RETURN

      ENTRY DBSBMMAIN(NPLT,IYEAR,PREDBKP,POSTDBKP,RV,STD_BA,BAH,
     &         BAK,TPA,TPAH,TPAK,VOL,VOLH,VOLKld,BA_SP,SPCL_TPA,IPSLSH,
     &         SANBAREM,SANTREM1,SANTREM2,VOLREMSAN,VOLREMSAL,
     &         REMBKP,CID)
      RETURN

      ENTRY DBSBMTREE(NSCL,NPLT,IYEAR,aTPA,aTPAH,TPAKLL,SPCLTRE,
     &   SAN1,SAN2,SAN3,SAN4,SAN5,SAN6,SAN7,SAN8,SAN9,SAN10,CID)
      RETURN

      ENTRY DBSBMBKP(NPLT,IYEAR,OLDBKP,NEWBKP,SELFBKP,
     &           TO_LS,FRM_LS,BKPIN,BKPOUT,BKPSV,STRPBKP,
     &           STRP_SC,REMBKP,RV,DVRV1,DVRV2,DVRV3,DVRV4,DVRV5,
     &           DVRV6,DVRV7,DVRV8,DVRV9,TPAFAST,BAFAST,VOLFAST,CID)
      RETURN

      ENTRY DBSBMVOL(NPLT,IYEAR,TVOL,HVOL,VOLK,NUMSC,CID)
      RETURN

      ENTRY DBSWW (I1,I2,I3,I4)
      RETURN
      ENTRY DBSWW2 (CID)
      RETURN
      ENTRY DBSECSUM(beginAnalYear,endTime,pretend,
     &          costUndisc,revUndisc,costDisc,revDisc,
     &          npv,irr,irrCalculated,bcRatio,bcRatioCalculated,
     &          rrr,rrrCalculated,sev,sevCalculated,
     &          forestValue,forestValueCalculated,
     &          reprodValue,reprodValueCalculated)
      RETURN
      ENTRY DBSECHARV_open()
      RETURN
      ENTRY DBSECHARV_insert(beginAnalYear,speciesID,minDia,maxDia,
     &          minDbh,maxDbh,tpaCut,tpaValue,tonsPerAcre,ft3Volume,
     &          ft3Value,bfVolume,bfValue,totalValue)
      RETURN
      ENTRY DBSECHARV_close()
      RETURN
      ENTRY getDbsEconStatus(status)
        status = 0
      RETURN
      
      ENTRY DBSCHPUT (KEYWRD,I1,I2)
      RETURN
      ENTRY DBSCHGET (KEYWRD,I1,I2)
      RETURN
      END

