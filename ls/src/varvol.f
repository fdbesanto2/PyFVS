        SUBROUTINE VARVOL
      use prgprm_mod
      implicit none
C----------
C LS $ID$
C----------
C
C  THIS SUBROUTINE CALLS THE APPROPRIATE VOLUME CALCULATION ROUTINE
C  FROM THE NATIONAL CRUISE SYSTEM VOLUME LIBRARY FOR METHB OR METHC
C  EQUAL TO 6.  IT ALSO CONTAINS ANY OTHER SPECIAL VOLUME CALCULATION
C  METHOD SPECIFIC TO A VARIANT (METHB OR METHC = 5, 8)
C
C  FOR EASTERN VARIANTS:
C    VN = TOTAL MERCH CUBIC (PULPWOOD AND SAWLOG)
C    VM = MERCH SAWLOG CUBIC FOOT VOLUME
C    BBFV = MERCH SAWLOG BOARD FOOT VOLUME
C
C  THIS SUBROUTINE INCLUDES LOGIC FOR ALL REGION 9 VARIANTS, LS, CS,
C  & NE.
C
C  IF **NATCRS** IS CALLED, THIS SUBROUTINE CALLS **R9CLARK**
C  IF **OCFVOL** IS CALLED, THEN **TWIGCF** IS CALLED
C  IF **OBFVOL** IS CALLED, THEN **TWIGBF** IS CALLED
C
C  SCRIBNER BOARD FEET ARA CALCULATED FOR MN (CHIPPEWA AND SUPERIOR),
C  WI (CHEQUAMEGON-NICOLET), AND UPPER MI (OTTAWA AND HIAWATHA NFS),
C  AND INTERNATIONAL 1/4" IS USED EVERYWHERE ELSE
C----------
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'VOLSTD.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'ARRAYS.F77'
COMMONS
C----------
      REAL VOL(15),BOLTHT(21),LOGLEN(7,21),BBFV1,UPSHT1
      LOGICAL TKILL,CTKFLG,BTKFLG,DEBUG,DONE,LCONE
      CHARACTER CTYPE*1,EQN*10,HTTYP*1
      CHARACTER*2 FORST,PROD
      INTEGER FOREST,IHT1,IHT2
      INTEGER I1,I0,I02,I01,I,ISPC,IERR,IT,ITRNC
      REAL BRATIO,TDIBC,TDIBB,SAWBF,SAWCU,X01,TOTCU,BOLT1,BOLT2
      REAL SINDX,VM,VN,BBFV,H,D,BARK,VMAX,X02,X03
      CHARACTER*10 EQNC,EQNB
C----------
C  DEFINE VARIABLES
C        DONE    --LOGICAL OPERATOR TO SIGNIFY ALL VOLUMES HAVE
C                  BEEN COMPUTED
C----------
C  NATIONAL CRUISE SYSTEM ROUTINES (METHOD = 6)
C----------
      ENTRY NATCRS (VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,
     1              CTKFLG,BTKFLG,IT)
C----------
C  CHECK FOR DEBUG
C----------
      CALL DBCHK(DEBUG,'VARVOL',6,ICYC)
      IF(DEBUG)WRITE(JOSTND,*)'IN VARVOL, ICYC= ',ICYC
C----------
C  INITIALIZE VOLUME ARRAY TO ZERO
C----------
      DO  10 I=1,15
      VOL(I)= 0.
   10 CONTINUE
      DONE=.FALSE.
C----------
C  REAL CONSTANT ARGUMENTS
C----------
      UPSHT1=0.
      X01=0.
      X02=2.
      X03=0.
C----------
C  INTEGER CONSTANT ARGUMENTS
C----------
      IERR=0
      I01=0
      I1=1
C----------
C  CHARACTER CONSTANT ARGUMENTS
C----------
      CTYPE='F'
      HTTYP='L'
C
C----------
C  TREE DBH IS LESS THAN PULPWOOD MIN DBH, OR NO PULPWOOD HT
C----------
      IF(D.LT.DBHMIN(ISPC))THEN
C
C  CASE 1: TREE DOES NOT MEET PULPWOOD SPECS
C
        TOTCU=0.
        X02=0.
        X03=0.
C----------
C  TREE DBH IS >PULPWOOD MIN DBH BUT <SAWTIMBER MIN DBH, OR NO SAW HT
C----------
      ELSEIF(D.LT.BFMIND(ISPC))THEN
C
C  CASE 2: TREE ONLY HAS PULPWOOD (PROD='02')
C
        IF(DEBUG)WRITE(JOSTND,*)' IT,CASE 2 PWVOL VEQNNC,D,H= ',
     &  IT,VEQNNC(ISPC),D,H
C
        PROD='02'
        X02=0.
        CALL R9CLARK(VEQNNC(ISPC),X01,BFTOPD(ISPC),TOPD(ISPC),D,X02,X03,
     &  H,LOGDIA,BOLTHT,LOGLEN,LOGVOL,VOL,I01,I01,I1,I01,I01,PROD,IERR,
     &  CTYPE,UPSHT1)
C
        IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 2 PWVOL IERR,VOL=',IERR,VOL
C
        TOTCU=VOL(4)
        SAWCU=0.0
        SAWBF=0.0
        DONE=.TRUE.
C----------
C  TREE DBH IS >SAWTIMBER MIN DBH, POSITIVE SAW HT AND PULP HT
C----------
      ELSE

C  CASE 3: TREE HAS SAWTIMBER AND PULPWOOD (PROD='01' AND TOPWOOD)
C
C  IF THE VOLEQNUM KEYWORD WAS USED TO SET DIFFERENT EQ. NOS. FOR CF AND
C  FOR BF THEN 2 CALLS TO R9CLARK ARE REQUIRED OTHERWISE ONE CALL IS
C  ENOUGH. IF VEQNNC HAS NOT BEEN SET DON'T CALL R9CLARK
C
        IF(VEQNNC(ISPC).NE.'')THEN
          IF(DEBUG)WRITE(JOSTND,*)' IT,CASE 3 (CALL 1) R9VOL VEQNNC',
     &    '(ISPC),BFTOPD(ISPC),TOPD(ISPC),D,H= ',
     &    IT,VEQNNC(ISPC),BFTOPD(ISPC),TOPD(ISPC),D,H
C
          PROD='01'
          CALL R9CLARK(VEQNNC(ISPC),X01,BFTOPD(ISPC),TOPD(ISPC),
     &    D,X02,X03,H,LOGDIA,BOLTHT,LOGLEN,LOGVOL,VOL,I01,I1,I1,
     &    I01,I1,PROD,IERR,CTYPE,UPSHT1)
C
          IF((KODFOR.EQ.902).OR.(KODFOR.EQ.903).OR.(KODFOR.EQ.906).OR.
     &      (KODFOR.EQ.907).OR.(KODFOR.EQ.909).OR.(KODFOR.EQ.910).OR.
     &      (KODFOR.EQ.913))THEN
            SAWBF=VOL(2)
          ELSE
            SAWBF=VOL(10)
          ENDIF
          SAWCU=VOL(4)
          TOTCU=SAWCU+VOL(7)
          IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 3(CALL 1)TCVOL ',
     &    'IERR,VOL= ',IERR,VOL
        ENDIF
C
        IF(VEQNNB(ISPC).EQ.VEQNNC(ISPC))THEN
          DONE=.TRUE.
        ELSE
          IF(DEBUG)WRITE(JOSTND,*)' IT,CASE 3 (CALL 2) R9VOL VEQNNB',
     &    '(ISPC),BFTOPD(ISPC),TOPD(ISPC),D,H= ',
     &    IT,VEQNNB(ISPC),BFTOPD(ISPC),TOPD(ISPC),D,H
C
          PROD='01'
          CALL R9CLARK(VEQNNB(ISPC),X01,BFTOPD(ISPC),TOPD(ISPC),D,X02,
     &         X03,H,LOGDIA,BOLTHT,LOGLEN,LOGVOL,VOL,I01,I1,I1,I01,
     &         I1,PROD,IERR,CTYPE,UPSHT1)
          IF((KODFOR.EQ.902).OR.(KODFOR.EQ.903).OR.(KODFOR.EQ.906).OR.
     &      (KODFOR.EQ.907).OR.(KODFOR.EQ.909).OR.(KODFOR.EQ.910).OR.
     &      (KODFOR.EQ.913))THEN
            SAWBF=VOL(2)
          ELSE
            SAWBF=VOL(10)
          ENDIF
            DONE=.TRUE.
          IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 3 (CALL 2)TCVOL IERR,',
     &    'VOL= ',IERR,VOL
        ENDIF
        IF(DEBUG)WRITE(JOSTND,*)' IT,AFTER CASE 3 (ALL CALLS)',
     &  'TCVOL IERR,VOL= ', IERR,VOL
      ENDIF
      IF(D.GE.BFMIND(ISPC))THEN
        IF(IT.GT.0)HT2TD(IT,1)=X02
      ELSE
        IF(IT.GT.0)HT2TD(IT,1)=0.
      ENDIF
      IF(D.GE.DBHMIN(ISPC))THEN
        IF(IT.GT.0)HT2TD(IT,2)=X03
      ELSE
        IF(IT.GT.0)HT2TD(IT,2)=0.
      ENDIF
      IF (DONE)GOTO 50
C----------
C--TREE DID NOT MEET PULPWOOD SPECS
C----------
      IF(D .LT. BFMIND(ISPC))THEN
C
C  CASE 4: TREE DOES NOT MEET SAWTIMBER OR PULPWOOD SPECS
C
        SAWCU=0.0
        SAWBF=0.0
      ELSE
C
C  CASE 5: STRANGE CASE SPECS MET AND TREE ONLY HAS SAWTIMBER(PROD='01')
C  IF THE VOLEQNUM KEYWORD WAS USED TO SET DIFFERENT EQ. NOS. FOR CF AND
C  FOR BF THEN 2 CALLS TO R9CLARK ARE REQUIRED OTHERWISE ONE CALL IS
C  ENOUGH. IF VEQNNC HAS NOT BEEN SET THEN DON'T CALL R9CLARK
C
        IF(VEQNNC(ISPC).NE.'')THEN
          IF(DEBUG)WRITE(JOSTND,*)' IT,CASE 5 (CALL 1) R9VOL VEQNNC',
     &    '(ISPC),BFTOPD(ISPC),TOPD(ISPC),VEQNNC(ISPC),D,H= ',
     &     VEQNNC(ISPC),BFTOPD(ISPC),TOPD(ISPC),VEQNNC(ISPC),D,H
C
          PROD='01'
          CALL R9CLARK(VEQNNC(ISPC),X01,BFTOPD(ISPC),TOPD(ISPC),D,X02,
     &    X03,H,LOGDIA,BOLTHT,LOGLEN,LOGVOL,VOL,I01,I1,I1,I01,I01,
     &    PROD,IERR,CTYPE,UPSHT1)
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 5 (CALL 1)R9VOL',
     &    ' IERR,VOL= ',IERR,VOL
C
          SAWCU=VOL(4)
          IF((KODFOR.EQ.902).OR.(KODFOR.EQ.903).OR.(KODFOR.EQ.906).OR.
     &      (KODFOR.EQ.907).OR.(KODFOR.EQ.909).OR.(KODFOR.EQ.910).OR.
     &      (KODFOR.EQ.913))THEN
            SAWBF=VOL(2)
          ELSE
            SAWBF=VOL(10)
          ENDIF
        ENDIF
C
        IF(VEQNNB(ISPC).NE.VEQNNC(ISPC))THEN
          IF(DEBUG)WRITE(JOSTND,*)' IT,CASE 5 (CALL 2)-R9VOL ',
     &    'VEQNNB(ISPC),BFTOPD(ISPC),TOPD(ISPC),VEQNNB(ISPC),D,H,',
     &    '= ',VEQNNC(ISPC),BFTOPD(ISPC),TOPD(ISPC),VEQNNB(ISPC),
     &             D,H
C
          PROD='01'
          CALL R9CLARK(VEQNNB(ISPC),X01,BFTOPD(ISPC),TOPD(ISPC),D,X02,
     &    X03,H,LOGDIA,BOLTHT,LOGLEN,LOGVOL,VOL,I01,I1,I1,I01,I01,PROD,
     &    IERR,CTYPE,UPSHT1)
          IF((KODFOR.EQ.902).OR.(KODFOR.EQ.903).OR.(KODFOR.EQ.906).OR.
     &      (KODFOR.EQ.907).OR.(KODFOR.EQ.909).OR.(KODFOR.EQ.910).OR.
     &      (KODFOR.EQ.913))THEN
            SAWBF=VOL(2)
          ELSE
            SAWBF=VOL(10)
          ENDIF
            IF(DEBUG)WRITE(JOSTND,*)' AFTER CASE 5 (CALL 2)R9VOL ',
     &    'IERR,VOL= ',IERR,VOL
        ENDIF
        IF(D.GE.BFMIND(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,1)=X02
        ELSE
          IF(IT.GT.0)HT2TD(IT,1)=0.
        ENDIF
        IF(D.GE.DBHMIN(ISPC))THEN
          IF(IT.GT.0)HT2TD(IT,2)=X03
        ELSE
          IF(IT.GT.0)HT2TD(IT,2)=0.
        ENDIF
      ENDIF
C----------
C  SET RETURN VALUES.
C----------
   50 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)' TOTCU=',TOTCU,' SAWCU=',SAWCU,
     &   ' SAWBF=',SAWBF
      VN=TOTCU
      VMAX=VN
      VM=SAWCU
      BBFV=SAWBF
      CTKFLG = .TRUE.
      BTKFLG = .TRUE.
      IF(VN.LE.0.)THEN
        VN=0.
        CTKFLG = .FALSE.
      ENDIF
      IF(VM.LE.0.)THEN
        VM=0.
        BTKFLG = .FALSE.
      ENDIF
      IF(BBFV.LE.0.)THEN
        BBFV=0.
        BTKFLG = .FALSE.
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)' RETURNING VN,VMAX,VM,BBFV,IERR= ',
     &VN,VMAX,VM,BBFV,IERR
C
C  VOLUME PROCESSING ERRORS ARE PROCESSED HERE
C
      IF(IERR.EQ.12)CALL ERRGRO(.TRUE.,36)
C
      RETURN
C
C----------
C  ENTER ANY OTHER CUBIC HERE
C----------
      ENTRY OCFVOL (VN,VM,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              CTKFLG,IT)
C----------
C  CHECK FOR DEBUG
C----------
      CALL DBCHK(DEBUG,'VARVOL',6,ICYC)
      IF(DEBUG)WRITE(JOSTND,*)'IN VARVOL, OCFVOL'
C
      IF(METHC(ISPC).EQ.5)THEN
C----------
C  IF METHC =5 USE GEVORKIANTZ METHOD
C----------
         CALL GVRVOL (VN,VM,BBFV1,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,
     1              CTKFLG,BTKFLG,IT)
      ELSE
C----------
C SET INITIAL VALUES.  IF DIAMETER LIMITS OR TREE VALUE CLASS NOT MET
C THEN RETURN.
C----------
      VN=0.
      VM=0.
      VMAX=0.
      IF (IMC(IT) .GE. 3 .OR. D .LT. DBHMIN(ISPC))GOTO 100
C----------
C  CALCULATE NET CUBIC FOOT VOLUME USING TWIGS EQUATIONS (VN)
C----------
         CALL TWIGCF(ISPC,H,D,VN,VM,IT)
         IF(DEBUG)WRITE(JOSTND,*) 'SPEC=',ISPC,' IT=',IT,' VN=',VN,
     &      ' IMC=',IMC(IT),' D=',D,' SI=',SITEAR(ISPC),' VM=',VM
      ENDIF
C----------
C  SET RETURN VALUES HERE
C----------
  100 CONTINUE
      CTKFLG = .TRUE.
      IF(VN.LE.0.)THEN
        VN=0.
        CTKFLG = .FALSE.
      ENDIF
      IF(VM.LE.0.)THEN
        VM=0.
      ENDIF
      VMAX=VN

      RETURN
C----------
      ENTRY OBFVOL (BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              BTKFLG,IT)
C----------
C  CHECK FOR DEBUG
C----------
      CALL DBCHK(DEBUG,'VARVOL',6,ICYC)
      BBFV=0.0
      IF(DEBUG)THEN
        WRITE(JOSTND,*)'IN OBFVOL ISPC,SI,D,TOPD =', ISPC,SITEAR(ISPC),
     &            D,TOPD(ISPC)
      ENDIF
C
      IF(METHB(ISPC).EQ.5)THEN
C----------
C  GEVORKIANTZ METHOD (METHB=5)
C----------
        CALL GVRVOL(VN,VM,BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,
     1              CTKFLG,BTKFLG,IT)
      ELSE
      IF(D .LT. BFMIND(ISPC) .OR. IMC(IT) .GT. 1)GOTO 200
C
C----------
C  COMPUTE MERCHANTABLE BOARD FOOT VOLUME (BBFV)
C----------
        CALL TWIGBF(ISPC,H,D,VMAX,BBFV)
        IF(DEBUG)WRITE(JOSTND,*)'IN OBFVOL BBFV =',BBFV,' SI=',
     &   SITEAR(ISPC),' D=',D,' IT=',IT,' ISPC=',ISPC
      ENDIF
C----------
C  SET RETURN VALUES.
C----------
  200 CONTINUE
      BTKFLG=.TRUE.
      IF(BBFV .LE. 0.)THEN
        BBFV=0.
        BTKFLG = .FALSE.
      ENDIF
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
      TDIBC=TOPD(ISPC)*BRATIO(ISPC,D,H)
      TDIBB=BFTOPD(ISPC)*BRATIO(ISPC,D,H)
      RETURN
C
      END
