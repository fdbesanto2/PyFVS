        SUBROUTINE VARVOL
      use prgprm_mod
      implicit none
C----------
C  **VARVOL--TT    DATE OF LAST REVISION:   08/05/11
C----------
C
C  THIS SUBROUTINE CALLS THE APPROPRIATE VOLUME CALCULATION ROUTINE
C  FROM THE NATIONAL CRUISE SYSTEM VOLUME LIBRARY FOR METHB OR METHC
C  EQUAL TO 6.  IT ALSO CONTAINS ANY OTHER SPECIAL VOLUME CALCULATION
C  METHOD SPECIFIC TO A VARIANT (METHB OR METHC = 8)
C----------
C
      INCLUDE 'ARRAYS.F77'
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'VOLSTD.F77'
C
      INCLUDE 'PLOT.F77'
C
C----------
      CHARACTER CTYPE*1,FORST*2,HTTYPE,PROD*2,LIVE*1
      LOGICAL DEBUG,TKILL,CTKFLG,BTKFLG,LCONE
      INTEGER IT,ITRNC,INTFOR,ISPC,IERR,IZERO,I0,I01,I02,I03,I04,I05
      INTEGER I1,IREGN,IFC,IFIASP
      REAL LOGLEN(20),BOLHT(21),TVOL(15)
      REAL NLOGS,NLOGSS
      REAL BBFV,VM,VN,DBT,TOPDIB,X01,X02,X03,X04,X05,X06,X07,X08,X09
      REAL X010,X011,X012,DRC,FC,TVOL1,TVOL4,NLOGSSI1,TDIBB,TDIBC
      REAL VMAX,BARK,H,D,ERRFLAG,BRATIO
      CHARACTER*10 EQNC,EQNB
C----------
C SPECIES ORDER FOR TETONS VARIANT:
C
C  1=WB,  2=LM,  3=DF,  4=PM,  5=BS,  6=AS,  7=LP,  8=ES,  9=AF, 10=PP,
C 11=UJ, 12=RM, 13=BI, 14=MM, 15=NC, 16=MC, 17=OS, 18=OH
C
C VARIANT EXPANSION:
C BS USES ES EQUATIONS FROM TT
C PM USES PI (COMMON PINYON) EQUATIONS FROM UT
C PP USES PP EQUATIONS FROM CI
C UJ AND RM USE WJ (WESTERN JUNIPER) EQUATIONS FROM UT
C BI USES BM (BIGLEAF MAPLE) EQUATIONS FROM SO
C MM USES MM EQUATIONS FROM IE
C NC AND OH USE NC (NARROWLEAF COTTONWOOD) EQUATIONS FROM CR
C MC USES MC (CURL-LEAF MTN-MAHOGANY) EQUATIONS FROM SO
C OS USES OT (OTHER SP.) EQUATIONS FROM TT
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
C  BRANCH TO THE APPROPRIATE EQUATION ROUTINE
C----------
      DO 103 IZERO=1,15
      TVOL(IZERO)=0.
  103 CONTINUE
      TOPDIB=TOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
      I0=0
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
C  CONSTANT INTEGER ARGUMENTS - CUBIC FOOT SECTION
C----------
      I1= 1
      IREGN= 4
      IF(VEQNNC(ISPC)(4:6).EQ.'FW2')THEN
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
C
      ELSEIF(VEQNNC(ISPC)(4:6).EQ.'MAT')THEN
C----------
C  OTHER R4 VOLUME SECTION
C  SET R4VOL PARAMETERS FOR CUBIC VOLUME
C----------
        NLOGS = 0.
        NLOGSS = 0.
C----------
C  CALL R4VOL TO COMPUTE CUBIC VOLUME.
C----------
        CALL R4VOL(IREGN,VEQNNC(ISPC),TOPDIB,H,D,X01,TVOL,NLOGS,NLOGSS,
     &             I1,I1,I1,I0,I0,IERR)
      ELSE
C----------
C  DIRECT VOLUME ESTIMATOR EQ.
C----------
        DRC=0.
        PROD='02'
        CALL FORMCL(ISPC,INTFOR,D,FC)
        IFC=IFIX(FC)
        IF(DEBUG)WRITE(JOSTND,*)' CALLING DVEST BF ISPC,ARGS = ',
     &  ISPC,VEQNNC(ISPC),D,H,TOPDIB,IFC,FORST,BARK,HTTYPE
C
        CALL DVEST(VEQNNC(ISPC),D,DRC,H,TOPDIB,IFC,I01,X01,X02,
     &  FORST,BARK*100.,TVOL,I1,I1,I1,I02,I03,
     &  PROD,HTTYPE,I04,X09,LIVE,NINT(BA),NINT(SITEAR(ISPC)),
     &  CTYPE,IERR)
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER DVEST BF TVOL= ',TVOL
      ENDIF
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE AGAIN.
C----------
      IF((BFTOPD(ISPC).NE.TOPD(ISPC)).OR.
     &   (BFSTMP(ISPC).NE.STMP(ISPC)).OR.
     &   (VEQNNB(ISPC).NE.VEQNNC(ISPC)))THEN
        TVOL1=TVOL(1)
        TVOL4=TVOL(4)
        DO 101 IZERO=1,15
        TVOL(IZERO)=0.
  101   CONTINUE
        TOPDIB=BFTOPD(ISPC)*BARK
C----------
C  CALL TO VOLUME INTERFACE - PROFILE
C  CONSTANT INTEGER ZERO ARGUMENTS
C----------
        I0=0
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
C  CONSTANT INTEGER ARGUMENTS - BOARD FOOT SECTION
C----------
        I1= 1
        IREGN= 4
C
        IF(VEQNNB(ISPC)(4:6).EQ.'FW2')THEN
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
        ELSEIF(VEQNNB(ISPC)(4:6).EQ.'MAT')THEN
C----------
C  OTHER R4 VOLUME SECTION
C  SET R4VOL PARAMETERS FOR CUBIC VOLUME
C----------
          NLOGS = 0.
          NLOGSS = 0.
C----------
C  CALL R4VOL TO COMPUTE CUBIC VOLUME.
C----------
          CALL R4VOL(IREGN,VEQNNB(ISPC),TOPDIB,H,D,X01,TVOL,NLOGS,NLOGSS,
     &             I1,I1,I1,I0,I0,IERR)
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
        ELSE
C----------
C  DIRECT VOLUME ESTIMATOR EQ.
C----------
          DRC=0.
          CALL FORMCL(ISPC,INTFOR,D,FC)
          IFC=IFIX(FC)
          IF(DEBUG)WRITE(JOSTND,*)' CALLING DVEST BF ISPC,ARGS = ',
     &    ISPC,VEQNNB(ISPC),D,H,TOPDIB,IFC,FORST,BARK,HTTYPE
C
          CALL DVEST(VEQNNB(ISPC),D,DRC,H,TOPDIB,IFC,I01,X01,X02,
     &    FORST,BARK*100.,TVOL,I1,I1,I1,I02,I03,
     &    PROD,HTTYPE,I04,X09,LIVE,NINT(BA),NINT(SITEAR(ISPC)),
     &    CTYPE,IERR)
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER DVEST BF TVOL= ',TVOL
          IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
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
