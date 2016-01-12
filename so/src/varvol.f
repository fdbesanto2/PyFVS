        SUBROUTINE VARVOL
      use contrl_mod
      use volstd_mod
      use plot_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **VARVOL--SO    DATE OF LAST REVISION:   09/27/12
C----------
C
C  THIS SUBROUTINE CALLS THE APPROPRIATE VOLUME CALCULATION ROUTINE
C  FROM THE NATIONAL CRUISE SYSTEM VOLUME LIBRARY FOR METHB OR METHC
C  EQUAL TO 6.  IT ALSO CONTAINS ANY OTHER SPECIAL VOLUME CALCULATION
C  METHOD SPECIFIC TO A VARIANT (METHB OR METHC = 8)
C----------
C
C----------
      REAL LOGLEN(20),BOLHT(21),SCALEN(20),TVOL(15)
      REAL NLOGS
      LOGICAL DEBUG,TKILL,CTKFLG,BTKFLG,LCONE
      CHARACTER CTYPE*1,FORST*2,HTTYPE,PROD*2
      INTEGER IT,ITRNC,INTFOR,IERR,IZERO,I01,I02,I03,I04,I05,I1,IREGN
      INTEGER ISPC,IFC,IFIASP,IR,LOGST
      REAL VMAX,BARK,H,D,BBFV,VM,VN,DBT,TOPDIB,X01,X02,X03,X04,X05,X06
      REAL X07,X08,X09,X010,X011,X012,FC,DBTBH,X0,TVOL1,TVOL4,TDIB
      REAL TDIBB,TDIBC,ERRFLAG,BRATIO
      REAL NLOGMS,NLOGTW
      CHARACTER*10 EQNC,EQNB
C----------
C SPECIES ORDER IN THE SO VARIANT:
C  1=WP  2=SP  3=DF  4=WF  5=MH  6=IC  7=LP  8=ES  9=RF 10=PP  11=OT
C  SPECIES ORDER:
C  1=WP,  2=SP,  3=DF,  4=WF,  5=MH,  6=IC,  7=LP,  8=ES,  9=SH,  10=PP,
C 11=JU, 12=GF, 13=AF, 14=SF, 15=NF, 16=WB, 17=WL, 18=RC, 19=WH,  20=PY,
C 21=WA, 22=RA, 23=BM, 24=AS, 25=CW, 26=CH, 27=WO, 28=WI, 29=GC,  30=MC,
C 31=MB, 32=OS, 33=OH
C----------
C  NATIONAL CRUISE SYSTEM ROUTINES (METHOD = 0)
C----------
      ENTRY NATCRS (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,
     1              CTKFLG,BTKFLG,IT)
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'VARVOL',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE VARVOL CYCLE =',I5)
C
C----------
C  SET PARAMETERS
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      HTTYPE='F'
      IERR=0
      DBT = D*(1-BARK)
C----------
C  FOR REGION 5 FORESTS, BRANCH TO R5 LOGIC.
C  FOR INDUSTRY, USE R5 LOGIC.
C----------
      IF(IFOR.GT.3) GO TO 100
C----------
C  R6 VOLUME LOGIC
C----------
C  BRANCH TO EITHER THE PROFILE EQN OR OLD R6 FORM CLASS EQN
C----------
      DO 103 IZERO=1,15
      TVOL(IZERO)=0.
  103 CONTINUE
      TOPDIB=TOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
      I01=0
      I02=0
      I03=0
      I04=0
      I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
      X01=0.
      X02=0.
      X03=0.
      X04=0.
      X05=0.
      X06=0.
      X07=0.
      X08=0.
      X09=0.
      X010=0.
      X011=0.
      X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
      CTYPE=' '
      PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
      I1= 1
      IREGN= 6
      IF(VEQNNC(ISPC)(4:4).EQ.'F')THEN
C
        IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE CF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNC(ISPC),TOPD(ISPC),STMP(ISPC),D,H,
     &    DBT,BARK
C
        CALL PROFILE (IREGN,FORST,VEQNNC(ISPC),TOPDIB,X01,STMP(ISPC),D,
     &  HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,BARK*100.,
     &  LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,I1,I1,I1,I04,
     &  I05,X012,CTYPE,I01,PROD,IERR)
C
        IF(D.GE.BFMIND(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,1)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,1)=0.
        ENDIF
        IF(D.GE.DBHMIN(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,2)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,2)=0.
        ENDIF
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE CF TVOL= ',TVOL
      ELSE
C----------
C  OLD R6 FORM CLASS SECTION
C
C  GET FORM CLASS FOR THIS TREE.
C----------
        CALL FORMCL(ISPC,IFOR,D,FC)
        IFC=IFIX(FC)
C----------
C  SET R6VOL PARAMETERS FOR CUBIC VOLUME
C----------
        NLOGS = 0.
        NLOGMS = 0.
        NLOGTW = 0.
        DBTBH = D-D*BARK
        IERR=0
        X0=0.
C----------
C  CALL R6VOL/BLMVOL TO COMPUTE CUBIC VOLUME.
C----------
        IF((VEQNNC(ISPC)(1:3).EQ.'616').OR.
     &     (VEQNNC(ISPC)(1:3).EQ.'632')) THEN
          IF(DEBUG)WRITE(JOSTND,*)' CALLING CF R6VOL ARGS= ',
     &    VEQNNC(ISPC),D,BARK*100.,IFC,TOPDIB,H,DBTBH
          CALL R6VOL(VEQNNC(ISPC),FORST,D,BARK*100.,IFC,TOPDIB,H,'F',
     &             TVOL,LOGVOL,NLOGS,LOGDIA,SCALEN,DBTBH,X0,CTYPE,IERR)
        ELSE
          IF(DEBUG)WRITE(16,*)' before BLMVOL-TOPD(ISPC),BARK= ',
     &                          TOPD(ISPC),BARK
          CALL BLMVOL(VEQNNC(ISPC),TOPD(ISPC),H,X0,D,'F',IFC,TVOL,
     &           LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW,1,1,IERR)
C
          IF(DEBUG)WRITE(16,*)' AFTER BLMVOL-VEQNNC(ISPC),TOPD(ISPC),
     &    H,X0,D,','F,IFC,TVOL,LOGDIA, LOGLEN,LOGVOL,LOGST,NLOGMS,
     &    NLOGTW= ',VEQNNB(ISPC),TOPD(ISPC),H,X0,D,'F',IFC,TVOL,
     &               LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW

        ENDIF
C
      ENDIF       ! END OF CF SECTION
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE AGAIN.
C----------
      IF((BFTOPD(ISPC).NE.TOPD(ISPC)) .OR.
     &   (BFSTMP(ISPC).NE.STMP(ISPC)).OR.
     &   (VEQNNB(ISPC).NE.VEQNNC(ISPC)))THEN
        TVOL1=TVOL(1)
        TVOL4=TVOL(4)
        DO 101 IZERO=1,15
        TVOL(IZERO)=0.
  101   CONTINUE
        TOPDIB=BFTOPD(ISPC)*BARK
C----------
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
        I01=0
        I02=0
        I03=0
        I04=0
        I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
        X01=0.
        X02=0.
        X03=0.
        X04=0.
        X05=0.
        X06=0.
        X07=0.
        X08=0.
        X09=0.
        X010=0.
        X011=0.
        X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
        CTYPE=' '
        PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
        I1= 1
        IREGN= 6
C----------
C  USE PROFILE EQUATIONS OR BRANCH TO R6VOLE EQS.
C----------
        IF(VEQNNB(ISPC)(4:4).EQ.'F')THEN
C
          IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE BF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNB(ISPC),BFTOPD(ISPC),BFSTMP(ISPC),D,H,
     &    DBT,BARK
C
          CALL PROFILE (IREGN,FORST,VEQNNB(ISPC),TOPDIB,X01,
     &    BFSTMP(ISPC),D,HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,
     &    X08,X09,I02,DBT,BARK*100.,LOGDIA,BOLHT,LOGLEN,LOGVOL,
     &    TVOL,I03,X010,X011,I1,I1,I1,I04,I05,X012,CTYPE,I01,PROD,
     &    IERR)
C
          IF(D.GE.BFMIND(ISPC))THEN
            IF(IT.GT.0)HT2TD(IT,1)=X02
          ELSE
            IF(IT.GT.0)HT2TD(IT,1)=0.
          ENDIF
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
          TVOL(1)=TVOL1
          TVOL(4)=TVOL4
        ELSE
C----------
C  R6VOL TO COMPUTE BOARD VOLUME.
C----------
          NLOGS = 0.
          NLOGMS = 0.
          NLOGTW = 0.
          DBTBH = D-D*BARK
          IERR=0
          X0=0.
          IF((VEQNNB(ISPC)(1:3).EQ.'616').OR.
     &       (VEQNNB(ISPC)(1:3).EQ.'632')) THEN
            IF(DEBUG)WRITE(JOSTND,*)' CALLING BF R6VOL ARGS= ',
     &      IFOR,FORST,VEQNNB(ISPC),D,BARK*100.,IFC,TOPDIB,H,DBTBH
          CALL R6VOL(VEQNNB(ISPC),FORST,D,BARK*100.,IFC,TDIB,H,'F',TVOL,
     &               LOGVOL,NLOGS,LOGDIA,SCALEN,DBTBH,X0,CTYPE,IERR)
            IF(DEBUG)WRITE(JOSTND,*)' AFTER BF R6VOL TVOL= ',TVOL
          ELSE
            IF(DEBUG)WRITE(16,*)' before BLMVOL-BFTOPD(ISPC),BARK= ',
     &      BFTOPD(ISPC),BARK
C
            CALL BLMVOL(VEQNNB(ISPC),BFTOPD(ISPC),H,X01,D,'F',IFC,TVOL,
     &                  LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW,
     &                  1,1,IERR)
            IF(DEBUG)WRITE(16,*)' AFTER BLMVOL-VEQNNB(ISPC),',
     &      'BFTOPD(ISPC),H,X01,D,IFC,TVOL,LOGDIA,LOGLEN,LOGVOL,',
     &      'LOGST,NLOGMS,NLOGTW= ',VEQNNB(ISPC),BFTOPD(ISPC),H,
     &      X01,D,IFC,TVOL,LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW
          TVOL(1)=TVOL1
          TVOL(4)=TVOL4
          ENDIF
        ENDIF
      ENDIF    ! END OF BF SECTION
C----------
C  SET RETURN VALUES.
C----------
        VN=TVOL(1)
        IF(VN.LT.0.)VN=0.
        VMAX=VN
        IF(D .LT. DBHMIN(ISPC))THEN
          VM = 0.
        ELSE
          VM=TVOL(4)
          IF(VM.LT.0.)VM=0.
        ENDIF
        IF(D.LT.BFMIND(ISPC))THEN
          BBFV=0.
        ELSE
          IF(METHB(ISPC).EQ.9) THEN
            BBFV=TVOL(10)
          ELSE
            BBFV=TVOL(2)
          ENDIF
          IF(BBFV.LT.0.)BBFV=0.
        ENDIF
        CTKFLG = .TRUE.
        BTKFLG = .TRUE.
C
      RETURN
C
  100 CONTINUE
C----------
C  SET PARAMETERS & CALL PROFILE OR R5HARV TO COMPUTE R5 VOLUMES.
C----------
      DO 105 IZERO=1,15
      TVOL(IZERO)=0.
  105 CONTINUE
      TOPDIB=TOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
      I01=0
      I02=0
      I03=0
      I04=0
      I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
      X01=0.
      X02=0.
      X03=0.
      X04=0.
      X05=0.
      X06=0.
      X07=0.
      X08=0.
      X09=0.
      X010=0.
      X011=0.
      X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
      CTYPE=' '
      PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
      I1= 1
      IREGN= 5
C
      IF(VEQNNC(ISPC)(4:6) .EQ. 'WO2')THEN
        IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE CF ISPC,ARGS = ',
     &  ISPC,IREGN,FORST,VEQNNC(ISPC),TOPD(ISPC),STMP(ISPC),D,H,
     &  DBT,BARK
C
        CALL PROFILE (IREGN,FORST,VEQNNC(ISPC),TOPDIB,X01,STMP(ISPC),D,
     &  HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,BARK*100.,
     &  LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,I1,I1,I1,I04,
     &  I05,X012,CTYPE,I01,PROD,IERR)
C
        IF(D.GE.BFMIND(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,1)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,1)=0.
        ENDIF
        IF(D.GE.DBHMIN(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,2)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,2)=0.
        ENDIF
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE CF TVOL= ',TVOL
      ELSE
        IF(DEBUG)WRITE(JOSTND,*)' CALLING R5HARV CF ISPC,VEQNNC(ISPC),',
     &  ',D,H,TOPDIB,I1= ',ISPC,VEQNNC(ISPC),D,H,TOPDIB,I1
C
        CALL R5HARV(VEQNNC(ISPC),D,H,TOPDIB,TVOL,I1,I1,IERR)
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER R5HARV CF TVOL= ',TVOL
      ENDIF
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE OR R5HARV AGAIN.
C----------
      IF((BFTOPD(ISPC).NE.TOPD(ISPC)) .OR.
     &   (BFSTMP(ISPC).NE.STMP(ISPC)).OR.
     &  (VEQNNB(ISPC).NE.VEQNNC(ISPC)))THEN
        TVOL1=TVOL(1)
        TVOL4=TVOL(4)
        DO 104 IZERO=1,15
        TVOL(IZERO)=0.
  104   CONTINUE
        TOPDIB=BFTOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
        I01=0
        I02=0
        I03=0
        I04=0
        I05=0
C----------
C  CONSTANT REAL ZERO ARGUMENTS
C----------
        X01=0.
        X02=0.
        X03=0.
        X04=0.
        X05=0.
        X06=0.
        X07=0.
        X08=0.
        X09=0.
        X010=0.
        X011=0.
        X012=0.
C----------
C  CONSTANT CHARACTER ARGUMENTS
C----------
        CTYPE=' '
        PROD='  '
C----------
C  CONSTANT INTEGER ARGUMENTS
C----------
        I1= 1
        IREGN= 5
C
        IF(VEQNNB(ISPC)(4:6) .EQ. 'WO2')THEN
          IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE BF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNB(ISPC),BFTOPD(ISPC),BFSTMP(ISPC),D,H,
     &    DBT,BARK
C
          CALL PROFILE (IREGN,FORST,VEQNNB(ISPC),TOPDIB,X01,BFSTMP(ISPC)
     &    ,D,HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,X08,X09,I02,DBT,
     &    BARK*100.,LOGDIA,BOLHT,LOGLEN,LOGVOL,TVOL,I03,X010,X011,
     &    I1,I1,I1,I04,I05,X012,CTYPE,I01,PROD,IERR)
C
          IF(D.GE.BFMIND(ISPC))THEN
            IF(IT.GT.0)HT2TD(IT,1)=X02
          ELSE
            IF(IT.GT.0)HT2TD(IT,1)=0.
          ENDIF
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
        ELSE
          IF(DEBUG)WRITE(JOSTND,*)' CALL R5HARV BF ISPC,VEQNNB(ISPC),',
     &    'D,H,TOPDIB,I1= ',ISPC,VEQNNB(ISPC),D,H,TOPDIB,I1
C
          CALL R5HARV(VEQNNB(ISPC),D,H,TOPDIB,TVOL,I1,I1,IERR)
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER R5HARV CF TVOL= ',TVOL
        ENDIF
        TVOL(1)=TVOL1
        TVOL(4)=TVOL4
      ENDIF
C----------
C  SET RETURN VALUES.
C----------
      VN=TVOL(1)
      IF(VN.LT.0.)VN=0.
      VMAX=VN
      IF(D .LT. DBHMIN(ISPC))THEN
        VM = 0.
      ELSE
        VM=TVOL(4)
        IF(VM.LT.0.)VM=0.
      ENDIF
      IF(D.LT.BFMIND(ISPC))THEN
        BBFV=0.
      ELSE
        IF(METHB(ISPC).EQ.9) THEN
          BBFV=TVOL(10)
        ELSE
          BBFV=TVOL(2)
        ENDIF
        IF(BBFV.LT.0.)BBFV=0.
      ENDIF
      CTKFLG = .TRUE.
      BTKFLG = .TRUE.
C
      RETURN
C
C----------
C  ENTER ANY OTHER CUBIC HERE
C----------
      ENTRY OCFVOL (VN,VM,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              CTKFLG,IT)
      VN=0.
      VMAX=0.
      VM=0.
      CTKFLG = .FALSE.
      RETURN
C
C----------
C  ENTER ANY OTHER BOARD HERE.
C----------
      ENTRY OBFVOL (BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              BTKFLG,IT)
      BBFV=0.
      BTKFLG = .FALSE.
      RETURN
C
C----------
C  ENTRY POINT FOR SENDING VOLUME EQN NUMBER TO THE FVS-TO-NATCRZ ROUTINE
C----------
      ENTRY GETEQN(ISPC,D,H,EQNC,EQNB,TDIBC,TDIBB)
      EQNC=VEQNNC(ISPC)
      EQNB=VEQNNB(ISPC)
      TDIBC=TOPD(ISPC)*BRATIO(ISPC,D,H)
      TDIBB=BFTOPD(ISPC)*BRATIO(ISPC,D,H)
      RETURN
C
      END
