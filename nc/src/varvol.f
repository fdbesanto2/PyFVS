        SUBROUTINE VARVOL
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use volstd_mod
      use prgprm_mod
      implicit none
C----------
C  **VARVOL--NC    DATE OF LAST REVISION:   10/12/12
C----------
C
C  THIS SUBROUTINE CALLS THE APPROPRIATE VOLUME CALCULATION ROUTINE
C  FROM THE NATIONAL CRUISE SYSTEM VOLUME LIBRARY FOR METHB OR METHC
C  EQUAL TO 6.  IT ALSO CONTAINS ANY OTHER SPECIAL VOLUME CALCULATION
C  METHOD SPECIFIC TO A VARIANT (METHB OR METHC = 8)
C----------
C
C----------
      REAL X01,X02,X03,X04,X05,X06,X07,X08,X09,X010,X011,X012
      REAL FC,DBTBH,TVOL1,TVOL4,X0,ALVN,VOLT,STUMP,DMRCH,HTMRCH,VOLM
      REAL S3,BV,TDIBB,TDIBC,ERRFLAG,BRATIO,BEHRE,XO,TOPDIB,DBT,VN,VM
      REAL BBFV,D,VMAX,BARK,H
      INTEGER IT,ITRNC,ISPC,INTFOR,IERR,IZERO,I01,I02,I03,I04,I05,I1
      INTEGER IREGN,IFC,LOGST,ITD,IFIASP,IR
      REAL NLOGMS,NLOGTW,NLOGS
      REAL LOGLEN(20),BOLHT(21),SCALEN(20),TVOL(15)
      LOGICAL DEBUG,TKILL,CTKFLG,BTKFLG,LCONE
      CHARACTER CTYPE*1,FORST*2,HTTYPE
      CHARACTER PROD*2
      CHARACTER*10 EQNC,EQNB
C
C SPECIES ORDER IN THE NC VARIANT:
C  1=OC  2=SP  3=DF  4=WF  5=M   6=IC  7=BO  8=TO  9=RF 10=PP  11=OH
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
C  FOR SIMPSON  AND HOOPA, USE R5 LOGIC.
C----------
      IF(IFOR.NE.4 .AND. IFOR.NE.7) GO TO 100
C----------
C  R6 VOLUME LOGIC
C
C----------
C  DROP INTO EITHER THE PROFILE EQN OR OLD R6 FORM CLASS EQN
C  ASSUME THAT IF THE CF EQ. IS FLEWELLING THAN THE BF
C  EQ. IS ALSO FLEWELLING
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
C
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
C  GET FORM CLASS FOR THIS TREE.
C----------
        CALL FORMCL(ISPC,IFOR,D,FC)
        IFC=IFIX(FC)
C----------
C  SET R6VOL PARAMETERS FOR CUBIC VOLUME
C----------
        NLOGS = 0.
        DBTBH = D-D*BARK
        IERR=0
        DO 113 IZERO=1,15
        TVOL(IZERO)=0.
  113   CONTINUE
        CTYPE=' '
        X0=0.
C----------
C  CALL R6VOL TO COMPUTE CUBIC VOLUME.
C----------
        IF((VEQNNC(ISPC)(1:3).EQ.'616').OR.
     &                    (VEQNNC(ISPC)(1:3).EQ.'632')) THEN
          CALL R6VOL(VEQNNC(ISPC),FORST,D,BARK*100.,IFC,TOPDIB,
     &               H,'F',TVOL,LOGVOL,NLOGS,LOGDIA,SCALEN,
     &               DBTBH,X0,CTYPE,IERR)
        ELSE
          CALL BLMVOL(VEQNNC(ISPC),TOPD(ISPC),H,X01,D,'F',IFC,TVOL,
     &         LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW,1,1,IERR)
        ENDIF
      ENDIF     ! END CF SECTION
C
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE AGAIN.
C----------
      IF((BFTOPD(ISPC).NE.TOPD(ISPC)) .OR.
     &   (BFSTMP(ISPC).NE.STMP(ISPC)).OR.
     &  (VEQNNB(ISPC).NE.VEQNNC(ISPC)))THEN
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
        IF(VEQNNB(ISPC)(4:4).EQ.'F')THEN
C
          IF(DEBUG)WRITE(JOSTND,*)' CALLING PROFILE BF ISPC,ARGS = ',
     &    ISPC,IREGN,FORST,VEQNNB(ISPC),BFTOPD(ISPC),BFSTMP(ISPC),D,H,
     &    DBT,BARK
C
          CALL PROFILE (IREGN,FORST,VEQNNB(ISPC),TOPDIB,X01,
     &    BFSTMP(ISPC),D,HTTYPE,H,I01,X02,X03,X04,X05,X06,X07,
     &    X08,X09,I02,DBT,BARK*100.,LOGDIA,BOLHT,LOGLEN,LOGVOL,
     *    TVOL,I03,X010,X011,I1,I1,I1,I04,I05,X012,CTYPE,I01,PROD,
     &    IERR)
C
          IF(D.GE.BFMIND(ISPC))THEN
            IF(IT.GT.0)HT2TD(IT,1)=X02
          ELSE
            IF(IT.GT.0)HT2TD(IT,1)=0.
          ENDIF
C
          IF(DEBUG)WRITE(JOSTND,*)' AFTER PROFILE BF TVOL= ',TVOL
          CTYPE=' '
          X0=0.
        ELSE
C----------
C  CALL R6VOL TO COMPUTE BOARD VOLUME.
C  GET FORM CLASS FOR THIS TREE.
C----------
          CALL FORMCL(ISPC,IFOR,D,FC)
          IFC=IFIX(FC)
C----------
C  SET R6VOL PARAMETERS FOR CUBIC VOLUME
C----------
          NLOGS = 0.
          DBTBH = D-D*BARK
          IERR=0
          XO=0.
C
          IF((VEQNNC(ISPC)(1:3).EQ.'616').OR.
     &                    (VEQNNC(ISPC)(1:3).EQ.'632')) THEN
            CALL R6VOL(VEQNNB(ISPC),FORST,D,BARK*100.,IFC,TOPDIB,
     &      H,'F',TVOL,LOGVOL,NLOGS,LOGDIA,SCALEN,DBTBH,X0,CTYPE,IERR)
          ELSE
            CALL BLMVOL(VEQNNB(ISPC),BFTOPD(ISPC),H,X0,D,'F',IFC,TVOL,
     &                LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW,
     &                1,1,IERR)
          ENDIF
          TVOL(1)=TVOL1
          TVOL(4)=TVOL4
        ENDIF
      ENDIF        ! END OF BF SECTION
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
      ELSEIF(VEQNNC(ISPC)(4:6) .EQ. 'DVE')THEN
        IF(DEBUG)WRITE(JOSTND,*)' CALLING R5HARV CF ISPC,VEQNNC(ISPC)',
     &  'D,H,TOPDIB,I1= ',ISPC,VEQNNC(ISPC),D,H,TOPDIB,I1
        CALL R5HARV(VEQNNC(ISPC),D,H,TOPDIB,TVOL,I1,I1,IERR)
        IF(DEBUG)WRITE(JOSTND,*)' AFTER R5HARV CF TVOL= ',TVOL
      ELSE
C----------
C  GET FORM CLASS FOR THIS TREE.
C----------
        CALL FORMCL(ISPC,IFOR,D,FC)
        IFC=IFIX(FC)
C
        IF(DEBUG)WRITE(JOSTND,*)
     &  VEQNNC(ISPC),TOPD(ISPC),H,D,IFC,TVOL,LOGDIA,LOGLEN,LOGVOL,
     &  LOGST,NLOGMS,NLOGTW

        CALL BLMVOL(VEQNNC(ISPC),TOPD(ISPC),H,X01,D,'F',IFC,TVOL,
     &       LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW,1,1,IERR)

        IF(DEBUG)WRITE(JOSTND,*)' AFTER BLMVOL CF TVOL= ',TVOL

      ENDIF
C----------
C  IF TOP DIAMETER IS DIFFERENT FOR BF CALCULATIONS, STORE APPROPRIATE
C  VOLUMES AND CALL PROFILE OR R5HARV AGAIN.
C----------
      IF(BFTOPD(ISPC).NE.TOPD(ISPC) .OR.
     &   BFSTMP(ISPC).NE.STMP(ISPC)) THEN
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
        ELSEIF(VEQNNB(ISPC)(4:6) .EQ. 'DVE')THEN
          IF(DEBUG)WRITE(JOSTND,*)' CALLING R5HARV BF ISPC,VEQNN(ISPC)',
     &    'D,H,TOP,DIB,I1= ',ISPC,VEQNNB(ISPC),D,H,TOPDIB,I1
          CALL R5HARV(VEQNNB(ISPC),D,H,TOPDIB,TVOL,I1,I1,IERR)
          IF(DEBUG)WRITE(JOSTND,*)' AFTER R5HARV CF TVOL= ',TVOL
        ELSE
C----------
C  GET FORM CLASS FOR THIS TREE.
C----------
          CALL FORMCL(ISPC,IFOR,D,FC)
          IFC=IFIX(FC)
C
          CALL BLMVOL(VEQNNB(ISPC),TOPD(ISPC),H,X01,D,'F',IFC,TVOL,
     &         LOGDIA,LOGLEN,LOGVOL,LOGST,NLOGMS,NLOGTW,1,1,IERR)
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
C
      GO TO (801,802,803,804,805,806,807,808,809,810,811),ISPC
C----------
C  OTHER CONIFER
C----------
  801 ALVN=-6.5819 + 2.0022*ALOG(D) + 1.0598*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  SUGAR PINE
C----------
  802 ALVN=-6.0657 + 2.1126*ALOG(D) + 0.8635*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  DOUGLAS-FIR
C----------
  803 ALVN=-6.5807 + 1.8332*ALOG(D) + 1.1602*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  WHITE FIR
C----------
  804 ALVN=-6.3998 + 1.9203*ALOG(D) + 1.0802*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  MADRONE
C----------
  805 CONTINUE
      VN=0.006732  *(D**1.96628)*(H**0.83458)
      GO TO 820
C----------
C  INCENSE CEDAR
C----------
  806 ALVN=-5.8157 + 1.9023*ALOG(D) + 0.9114*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  BLACK OAK
C----------
  807 VN = 0.00705381*(D**1.97437)*(H**0.85034)
      GO TO 820
C----------
C TANOAK
C----------
  808 CONTINUE
      VN=0.00588700*(D**1.94165)*(H**0.86562)
      GO TO 820
C----------
C RED FIR
C----------
  809 ALVN=-6.4929 + 1.9271*ALOG(D) + 1.0884*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C  PONDEROSA PINE.
C----------
  810 ALVN=-6.5819 + 2.0022*ALOG(D) + 1.0598*ALOG(H)
      VN=EXP(ALVN)
      GO TO 820
C----------
C TANOAK
C----------
  811 VN=0.00588700*(D**1.94165)*(H**0.86562)
C----------
C  NEGATIVE VOLUMES ARE RESET TO ZERO.
C----------
  820 CONTINUE
      IF(VN .LT. 0.) VN = 0.0
C----------
C SET VMAX.
C----------
      VMAX=VN
C----------
C COMPUTE MERCHANTABLE CUBIC FOOT VOLUME.
C----------
      CTKFLG = .TRUE.
      IF(VN .EQ. 0.)THEN
        VM = 0.
        CTKFLG = .FALSE.
        GO TO 850
      ENDIF
      CALL BEHPRM (VMAX,D,H,BARK,LCONE)
      VOLT=BEHRE(0.0,1.0)
C----------
C  COMPUTE MERCHANTABLE CUBIC VOLUME USING TOP DIAMETER, MINIMUM
C  DBH, AND STUMP HEIGHT SPECIFIED BY THE USER.
C----------
      STUMP = 1. - (STMP(ISPC)/H)
      IF(D.LT.DBHMIN(ISPC).OR.D.LT.TOPD(ISPC)) THEN
        VM=0.0
      ELSE
        DMRCH=TOPD(ISPC)/D
        HTMRCH=((BHAT*DMRCH)/(1.0-(AHAT*DMRCH)))
        IF(.NOT.LCONE) THEN
          VOLM=BEHRE(HTMRCH,STUMP)
          VM=VMAX*VOLM/VOLT
        ELSE
C----------
C       PROCESS CONES.
C----------
          S3=STUMP**3
          VOLM=S3-HTMRCH**3
          VM=VMAX*VOLM
        ENDIF
      ENDIF
  850 CONTINUE
      RETURN
C
C----------
C  ENTER ANY OTHER BOARD HERE.
C----------
      ENTRY OBFVOL (BBFV,ISPC,D,H,TKILL,BARK,ITRNC,VMAX,LCONE,
     1              BTKFLG,IT)
      ITD=BFTOPD(ISPC)+0.5
      IF(ITD.GT.100) ITD = 100
      CALL LOGS(D,H,ITD,ITD,DBHMIN(ISPC),BFMIND(ISPC),ISPC,
     &          BFSTMP(ISPC),BV,JOSTND)
      BBFV=BV
      BTKFLG=.TRUE.
      IF(BBFV .LE. 0.) THEN
        BBFV=0.
        BTKFLG=.FALSE.
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
      RETURN
C
      END
