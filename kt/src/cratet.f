      SUBROUTINE CRATET
      use prgprm_mod
      implicit none
C----------
C  **CRATET--KT   DATE OF LAST REVISION:  01/14/11
C----------
C  THIS SUBROUTINE IS CALLED PRIOR TO PROJECTION.  IT HAS THE
C  FOLLOWING FUNCTIONS:
C
C    1)  CALL **RCON** TO LOAD SITE DEPENDENT MODEL COEFFICIENTS.
C    2)  REGRESSION TO ESTIMATE COEFFICIENTS OF LOCAL HEIGHT-
C        DIAMETER RELATIONSHIP.
C    3)  DUB IN MISSING HEIGHTS.
C    4)  CALL **DENSE** TO COMPUTE STAND DENSITY.
C    5)  SCALE CROWN RATIOS AND CALL **CROWN** TO DUB IN ANY MISSING
C        VALUES.
C    6)  DEFINE DG BASED ON CALIBRATION CONTROL PARAMETERS AND
C        CALL **DGDRIV** TO CALIBRATE DIAMETER GROWTH EQUATIONS.
C    7)  DELETE DEAD TREES FROM INPUT TREE LIST AND REALIGN IND1
C        AND ISCT.
C    8)  PRINT A TABLE DESCRIBING CONTROL PARAMETERS AND INPUT
C        VARIABLES.
C----------
C
      INCLUDE 'ARRAYS.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'COEFFS.F77'
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'OUTCOM.F77'
C
      INCLUDE 'HTCAL.F77'
C
C----------
C  INTERNAL VARIABLES.
C
C      KNT2 -- USED TO STORE COUNTS FOR PRINTING IN CONTROL
C              SUMMARY TABLE.
C     SPCNT -- USED TO ACCUMULATE NUMBER OF TREES PER ACRE BY
C              SPECIES AND TREE CLASS FOR CALCULATION OF
C              INITIAL SPECIES-TREE CLASS COMPOSITION VECTOR.
C       SMA -- SPECIES SPECIFIC COEFFICIENTS FOR THE SMALL TREE
C              HEIGHT DUBBING EQUATION.
C     SMDBH -- SPECIES SPECIFIC DIAMETER TO CROSS FROM SMALL TO
C              LARGE TREE HEIGHT DUBBING EQUATION.
C----------
      LOGICAL DEBUG,MISSCR,TKILL
      CHARACTER*4 UNDER
      INTEGER I,J,II,ISPC,IPTR,I1,I2,I3,K1,K2,K3,K4,NH,JJ,IERRCK
      INTEGER IS,IM,KNT2(MAXSP),KNT(MAXSP),ISPFL(MAXSP)
      REAL RAD,SOLN,Q,AA,BB,COUNTER,SUMXX,SUMYY,SUMXY,SUMX2,H,D,XX
      REAL YY,XY,X2,XN,STEP1,HS,SPCNT(MAXSP,3),SMA(MAXSP),SMDBH(MAXSP)
      REAL HTKEEP(MAXTRE)
      REAL D2,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2
C----------
C     THE SPECIES ORDER IS VARIANT SPECIFIC, SEE BLKDATA FOR A LIST.
C----------
C  INITIALIZE INTERNAL VARIABLES:
C----------
      DATA UNDER/'----'/
      DATA SMA/4.43,7.49,5.71,5.00,5.32,4.69,7.49,4.98,4.74,3.83,3.92/
      DATA SMDBH/4.17,5.84,5.50,4.74,4.74,5.21,2.42,4.96,3.43,5.94,6.17/
      RAD= 0.
      SOLN= 0.
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CRATET',6,ICYC)
C-------
C  IF THERE ARE TREE RECORDS, BRANCH TO PREFORM CALIBRATION.
C-------
      IF (ITRN.GT.0) GOTO 1
C----------
C   CALL MAICAL TO CALCULATE MAI
C----------
      CALL MAICAL
      CALL RCON
      ONTREM(7)=0.
      CALL DENSE
      CALL DGDRIV
      CALL REGENT(.FALSE.,1)
    1 CONTINUE
      DO 5 I=1,MAXSP
      ISPFL(I)=0
      SPCNT(I,1)=0.0
      SPCNT(I,2)=0.0
      SPCNT(I,3)=0.0
      IF (ISCT(I,1).EQ.0) GOTO 5
      J=IREF(I)
      IUSED(J)=NSP(I,1)
    5 CONTINUE
      IF((ITRN.LE.0).AND.(IREC2.GE.MAXTP1))GO TO 245
C----------
C  PRINT SPECIES LABELS AND NUMBER OF OBSERVATIONS IN CONTROL
C  TABLE.  THEN, RESET COUNTERS TO ZERO.
C----------
      WRITE(JOSTND,'(//''CALIBRATION STATISTICS:''//)')
      WRITE(JOSTND,9000) (IUSED(I), I=1,NUMSP)
 9000 FORMAT ((T49,11(1X,A2,3X)/))
      IF(NUMSP .LE. 11) THEN
        WRITE(JOSTND,9001) (UNDER, I=1,NUMSP)
      ELSE
        WRITE(JOSTND,9001) (UNDER, I=1,11)
      ENDIF
 9001 FORMAT (T47,11(A4,2X))
      WRITE(JOSTND,9002) (KOUNT(I), I=1,NUMSP)
 9002 FORMAT(/,'NUMBER OF RECORDS PER SPECIES',
     &        ((T49,11(I4,2X)/)))
      DO 10 I=1,MAXSP
      KNT(I)=0
      KNT2(I)=0
   10 CONTINUE
C----------
C   CALL MBACAL TO IDENTIFY SITE SPECIES
C----------
      CALL MBACAL
C----------
C   CALL MAICAL TO CALCULATE MAI
C----------
      CALL MAICAL
C----------
C  CALL **RCON** TO INITIALIZE SITE DEPENDENT MODEL COEFFICIENTS.
C----------
      CALL RCON
C----------
C  CALL **RDPSRT** AND **DENSE** TO COMPUTE INITIAL STAND DENSITY
C  STATISTICS.  ONTREM(7) IS SET TO ZERO HERE TO ASSURE THAT RELDM1
C  WILL BE ASSIGNED IN **DENSE** IN THE FIRST CYCLE.
C----------
      DO 15 I=1,ITRN
      IND(I)=IND1(I)
   15 CONTINUE
      CALL RDPSRT(ITRN,DBH,IND,.FALSE.)
      ONTREM(7)=0.0
      DO 20 I=1,MAXTRE
      HTKEEP(I)=0.
   20 CONTINUE
      CALL SMHTRG(ISPFL,DEBUG,HTKEEP)
C----------
C  PREPARE INPUT DATA FOR DIAMETER GROWTH MODEL CALIBRATION.  IF
C  IDG IS 1, CONVERT THE PAST DIAMETER MEASUREMENT CARRIED IN DG TO
C  DIAMETER GROWTH.  IF IDG IS 3, CONVERT THE CURRENT DIAMETER
C  MEASUREMENT CARRIED IN DG TO DIAMETER GROWTH.  ACTUAL DIAMETER
C  INCREMENT MEASUREMENTS WILL BE CORRECTED FOR BARK GROWTH IN
C  THE CALIBRATION ROUTINE. (THIS CODE WAS MOVED HERE SO THAT THE
C  BACKDATING ALGORITHM IN **DENSE**, INVOKED DURING CALIBRATION,
C  IS CORRECT.)
C----------
      Q=1.0
      IF(IDG.EQ.3) Q=-1.0
      DO 230 II=1,ITRN
      I=IND1(II)
      IF(I.GE.IREC2) GO TO 230
      IF(DG(I).LE.0.0) GO TO 220
      IF(IDG.EQ.0.OR.IDG.EQ.2) GO TO 230
      DG(I)=Q*(DBH(I)-DG(I))
      GO TO 230
  220 CONTINUE
      DG(I)=-1.0
  230 CONTINUE
C---------
C  SET LBKDEN TRUE IF DIAMETERS ARE TO BE BACKDATED FOR DENSITY
C  CALCULATIONS.  AFTER THIS CALL TO DENSE, INSURE LBKDEN=FALSE.
C---------
      LBKDEN= IDG.LT.2
      CALL DENSE
      LBKDEN= .FALSE.
C----------
C  DELETE NON-PROJECTABLE RECORDS, AND REALIGN POINTERS TO THE
C  SPECIES ORDERED SORT.
C----------
      IF(IREC2.EQ.MAXTP1) GO TO 60
      DO 50 I=IREC2,MAXTRE
      ISPC=ISP(I)
      IPTR=IREF(ISPC)
      IF(IMC(I).EQ.7)KNT(IPTR)=KNT(IPTR)+1
      IF (DEBUG) WRITE(JOSTND,9003) I,IMC(I),ISPC
 9003 FORMAT('IN CRATET: DEAD TREE RECORD:  I=',I4,',  IMC=',I2,
     &       ',  SPECIES=',I2,' (9003 CRATET)')
      IF(ITRN.GT.0)THEN
        I1=ISCT(ISPC,1)
        I2=ISCT(ISPC,2)
        DO 30 I3=I1,I2
        IF(IND1(I3).EQ.I) GO TO 40
   30   CONTINUE
   40   IND1(I3)=IND1(I2)
        ISCT(ISPC,2)=I2-1
        IF(ISCT(ISPC,2).GE.ISCT(ISPC,1)) GO TO 50
        ISCT(ISPC,1)=0
        ISCT(ISPC,2)=0
      ENDIF
   50 CONTINUE
C----------
C  WRITE CALIBRATION TABLE ENTRY FOR NON-PROJECTABLE RECORDS AND RESET
C  KNT ARRAY TO ZERO.
C----------
      WRITE(JOSTND,9004) (KNT(I),I=1,NUMSP)
 9004 FORMAT(/,'NUMBER OF RECORDS CODED AS RECENT MORTALITY',
     &        ((T49,11(I4,2X)/)))
C---------
C  RESET TREE RECORD COUNTERS AND SAVE THE NUMBER OF SPECIES.
C----------
      ITRN=IREC1
      IF((ITRN.LE.0).AND.(IREC2.GE.MAXTP1))GOTO 245
      IF(ITRN.LE.0)GOTO 60
      ISPC=NUMSP
C---------
C  MAKE SURE THAT ALL THE SPECIES ORDER SORTS AND THE IND2 ARRAY
C  ARE IN THE PROPER ORDER. FIRST, SAVE THE SPECIES REFERENCES.
C---------
      DO 51 I=1,MAXSP
      KNT(I)=IREF(I)
   51 CONTINUE
      CALL SPESRT
C---------
C  IF THE NUMBER OF SPECIES HAS CHANGED, WE MUST REWRITE THE
C  COLUMN HEADINGS.
C---------
      IF (ISPC.NE.NUMSP) THEN
         WRITE(JOSTND,52)
   52    FORMAT (/'***** NOTE:  SPECIES HAVE BEEN DROPPED.')
         DO 55 I=1,MAXSP
         IF (ISCT(I,1).EQ.0) GOTO 55
         J=IREF(I)
         IUSED(J)=NSP(I,1)
   55    CONTINUE
         WRITE(JOSTND,9000) (IUSED(I), I=1, NUMSP)
         WRITE(JOSTND,9001) (UNDER, I=1, NUMSP)
      ELSE
C
C        RESET THE REFERENCES.
C
         DO 57 I=1,MAXSP
         IREF(I)=KNT(I)
   57    CONTINUE
      ENDIF
C----------
C  SORT REMAINING TREE RECORDS IN ORDER OF DESCENDING DIAMETER.
C  STORE POINTERS TO SORTED ORDER IN IND.
C----------
      CALL RDPSRT(ITRN,DBH,IND,.TRUE.)
   60 CONTINUE
      DO 65 I=1,MAXSP
      KNT(I)=0
   65 CONTINUE
C----------
C  ENTER LOOP TO ADJUST HEIGHT-DBH MODEL FOR LOCAL CONDITIONS.  IF
C  THERE ARE 3 OR MORE TREES WITH MEASURED HEIGHTS FOR A GIVEN
C  SPECIES, ADJUST THE INTERCEPT (ASYMPTOTE) IN THE MODEL SO THAT
C  THE MEAN RESIDUAL FOR THE MEASURED TREES IS ZERO.
C  IF LHTDRG IS FALSE FOR A GIVEN SPECIES THEN ALL DUBBING IS DONE WITH
C  DEFAULT VALUES.
C----------
      DO 150 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.LE.0) THEN
        AA=HT1(ISPC)
        BB=HT2(ISPC)
        GO TO 141
      ENDIF
      I2=ISCT(ISPC,2)
      IPTR=IREF(ISPC)
C----------
C  INITIALIZE SUMS FOR THIS SPECIES.
C----------
      COUNTER=0.0
      K1=0
      K2=0
      K3=0
      K4=0
      SUMXX=0.0
      SUMYY=0.0
      SUMXY=0.0
      SUMX2=0.0
C----------
C  ENTER TREE LOOP WITHIN SPECIES.
C----------
      DO 80 I3=I1,I2
      I=IND1(I3)
      H=HT(I)
      NH=NORMHT(I)
      D=DBH(I)
C----------
C  BYPASS SUMS FOR TREES WITH MISSING HEIGHT OR TRUNCATED TOPS.
C----------
      IF(H.LE.4.5 .OR. NH.LT.0 .OR. D.LT.3.0) GO TO 70
      K1=K1+1
      XX = SQRT(D)
      YY = H
      XY = XX*YY
      X2 = D
      SUMYY = SUMYY + YY
      SUMXX = SUMXX + XX
      SUMXY = SUMXY + XY
      SUMX2 = SUMX2 + X2
      IF(DEBUG)WRITE(JOSTND,*)'I=',I,' ISPC=',ISPC,' D=',D,' H=',H,
     &     ' SQRTD=',SQRT(D),' SUMYY=',SUMYY,' SUMXX=',SUMXX,' SUMXY='
     &      ,SUMXY,' SUMX2=',SUMX2
      GO TO 80
   70 CONTINUE
C----------
C  COUNT NUMBER OF MISSING HEIGHTS AND BROKEN OR DEAD TOPS.  LOAD THE
C  ARRAY IND2 WITH SUBSCRIPTS TO THE RECORDS WITH MISSING HEIGHTS.
C----------
      IF(NH.LT.0) K3=K3+1
      IF(H.GT.0.0 .AND. NH.EQ.0) GO TO 80
      K2=K2+1
      IND2(K2)=I
C----------
C  END OF SUMMATION LOOP FOR THIS SPECIES.
C----------
   80 CONTINUE
C----------
C  IF THERE ARE LESS THAN THREE OBSERVATIONS OR LHTDRG IS FALSE THEN
C  DUB HEIGHTS USING DEFAULT COEFFICIENTS FOR THIS SPECIES
C----------
      KNT(IPTR)=K3
      IF(K1.LT.3 .OR. .NOT. LHTDRG(ISPC)) GO TO 100
      XN=FLOAT(K1)
      BB=(XN*SUMXY-SUMXX*SUMYY)/(XN*SUMX2-SUMXX*SUMXX)
      AA=(SUMX2*SUMYY-SUMXX*SUMXY)/(XN*SUMX2-SUMXX*SUMXX)
C----------
C  IF THE INTERCEPT IS NEGATIVE. USE THE DEFAULT VALUES.
C----------
      IF(BB.GE.0.0) GO TO 110
C----------
C  LOAD DEFAULT COEFFICIENTS
C----------
  100 CONTINUE
      AA=HT1(ISPC)
      BB=HT2(ISPC)
      COUNTER = 1.0
C----------
C  DUB IN MISSING HEIGHTS.
C  A VALUE LESS THAN ZERO STORED IN NORMHT => THAT TREE WAS TOP KILLED.
C  CONSEQUENTLY, A VALUE OF 80% OF THE PREDICTED HEIGHT IS STORED AS
C  THE TRUNCATED HEIGHT.
C----------
  110 CONTINUE
      IF(K2.EQ.0) GO TO 140
      DO 130 JJ=1,K2
      II=IND2(JJ)
      D=DBH(II)
      TKILL = NORMHT(II) .LT. 0.
      IF(D .LE. 0.1)THEN
        H=1.01
        GO TO 117
      ENDIF
C----------
C  IF THERE ARE LESS THAN THREE OBSERVATIONS FOR A SPECIES OR LHTDRG
C  IS FALSE OR REGRESSED COEFFICIENTS DO NOT FORMULATE A GOOD EQUATION
C  THEN DUB HEIGHTS USING DEFAULT COEFFICIENTS FOR THIS SPECIES.
C----------
      IF(DEBUG)WRITE(JOSTND,*)'K1=',K1,' D=',D,' SMDBH=',SMDBH(ISPC)
      IF(K1.LT.3 .OR. .NOT. LHTDRG(ISPC) .OR. COUNTER .EQ. 1.0) THEN
        IF (D .GE. SMDBH(ISPC))THEN
          H=EXP(AA+BB/(D+1.0))+4.5
        ELSE
          H=SMA(ISPC)*D+4.5
        ENDIF
C----------
C  IF THERE ARE ENOUGH SAMPLE TREES, REGRESS STAND DATA USING THE
C  SQUARE ROOT OF D EQUATION.  FIND THE COMMON SOLUTION BETWEEN THE
C  SMALL AND LARGE TREE HEIGHT DUBBING EQUATIONS AND PREDICT HEIGHTS
C  FOR ALL TREES BELOW THAT DIAMETER WITH THE LINEAR EQUATION.
C----------
      ELSE
        H=AA + BB*SQRT(D)
        IF(DEBUG)WRITE(JOSTND,*)'I=',II,' AA=',AA,' BB=',BB,
     &      'SMA(ISPC)=',SMA(ISPC)
        STEP1=((BB*BB)-4*SMA(ISPC)*(4.5-AA))
        IF(STEP1 .LE. 0.0) THEN
          IERRCK=1
          GO TO 115
        ENDIF
        RAD=SQRT(STEP1)
        SOLN=((BB-RAD)/(2*SMA(ISPC)))**2
        IF (SOLN .LE. 0.0) SOLN=((BB+RAD)/(2*SMA(ISPC)))**2
  115   CONTINUE
        IF(D .LT. SOLN .OR.(IERRCK .EQ. 1 .AND. D .LT. SMDBH(ISPC)))
     &      H=SMA(ISPC)*D+4.5
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)'d=',D,
     &   ' XN=',XN,' AA=',AA,' H=',H,' SMA=',SMA(ISPC),' RAD=',
     &    RAD,' SOLN=',SOLN,' ISPC=',ISPC
      IF(H .LT. 4.5) H=4.5
      IF(HTKEEP(II) .LT. 4.5)HTKEEP(II)=4.5
  117 CONTINUE
      IF(TKILL) GO TO 120
      IF(ISPFL(ISPC) .EQ. 1)THEN
         HT(II)=HTKEEP(II)
      ELSE
         HT(II)=H
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)'ISPC=',ISPC,' II=',II,' ISPFL=',
     &    ISPFL(ISPC),' HT(II)=',HT(II),' HTKEEP(II)=',HTKEEP(II),
     &    ' H=',H
      K4=K4+1
      GO TO 125
  120 CONTINUE
      NORMHT(II)=H*100.0+0.5
      IF(ITRUNC(II).EQ.0) THEN
         IF(HT(II).GT.0.0) THEN
            ITRUNC(II)=80.0*HT(II)+0.5
         ELSE
            ITRUNC(II)=80.0*H+0.5
            HT(II)=H
         ENDIF
      ELSE
         IF(HT(II).GT.0.0) THEN
            IF(HT(II).LT.(ITRUNC(II)*0.01)) HT(II)=ITRUNC(II)*0.01
         ELSE
            HT(II)=ITRUNC(II)*0.01
         ENDIF
      ENDIF
      IF(NORMHT(II)*0.01.LT.HT(II)) NORMHT(II)=HT(II)*100.0
  125 CONTINUE
  130 CONTINUE
      KNT2(IPTR)=K4
C----------
C  END OF SPECIES LOOP.  PRINT HEIGHT-DIAMETER COEFFICIENTS ON
C  DEBUG UNIT IF DESIRED.
C----------
  140 CONTINUE
      IF(.NOT.DEBUG) GO TO 141
      WRITE(JOSTND,9005) ISPC,AA,BB,HT1(ISPC),HT2(ISPC)
 9005 FORMAT('HEIGHT-DIAMETER COEFFICIENTS FOR SPECIES ',I2,
     &      ':  INTERCEPT=',F10.6,'  SLOPE=',F10.6,/
     &      'DEFAULT COEFFICIENTS FOR THIS SPECIES',7X,
     &      ':  INTERCEPT=',F10.6,'  SLOPE=',F10.6,' (9005 CRATET)')
C----------
C  LOOP THROUGH DEAD TREES AND DUB MISSING HEIGHTS FOR THIS SPECIES.
C----------
  141 CONTINUE
      IF(IREC2 .GT. MAXTRE) GO TO 150
      DO 145 II=IREC2,MAXTRE
      IF(ISP(II).NE.ISPC) GO TO 145
      D=DBH(II)
      TKILL = NORMHT(II) .LT. 0.
      IF(HT(II).GT.0. .AND. TKILL) GO TO 142
      IF(HT(II).GT.0.) GO TO 146
      IF(D .LE. 0.1) THEN
        H=1.01
        GO TO 144
      ENDIF
C----------
C  IF THERE ARE LESS THAN THREE OBSERVATIONS FOR A SPECIES OR LHTDRG
C  IS FALSE OR REGRESSED COEFFICIENTS DO NOT FORMULATE A GOOD EQUATION
C  THEN DUB HEIGHTS USING DEFAULT COEFFICIENTS FOR THIS SPECIES.
C----------
      IF(K1.LT.3 .OR. .NOT. LHTDRG(ISPC) .OR. COUNTER .EQ. 1.0) THEN
        IF (D .GE. SMDBH(ISPC))THEN
          H=EXP(AA+BB/(D+1.0))+4.5
        ELSE
          H=SMA(ISPC)*D+4.5
        ENDIF
C----------
C  IF THERE ARE ENOUGH SAMPLE TREES, REGRESS STAND DATA USING THE
C  SQUARE ROOT OF D EQUATION.  FIND THE COMMON SOLUTION BETWEEN THE
C  SMALL AND LARGE TREE HEIGHT DUBBING EQUATIONS AND PREDICT HEIGHTS
C  FOR ALL TREES BELOW THAT DIAMETER WITH THE LINEAR EQUATION.
C----------
      ELSE
        H=AA + BB*SQRT(D)
        STEP1=((BB*BB)-4*SMA(ISPC)*(4.5-AA))
        IF(STEP1 .LE. 0.0) THEN
          IERRCK=1
          GO TO 143
        ENDIF
        RAD=SQRT(STEP1)
        SOLN=((BB-RAD)/(2*SMA(ISPC)))**2
        IF (SOLN .LE. 0.0) SOLN=((BB+RAD)/(2*SMA(ISPC)))**2
  143   CONTINUE
        IF(D .LT. SOLN .OR.(IERRCK .EQ. 1 .AND. D .LT. SMDBH(ISPC)))
     &      H=SMA(ISPC)*D+4.5
      ENDIF
      IF(H .LT. 4.5)H=4.5
      IF(HTKEEP(II).LT.4.5)HTKEEP(II)=4.5
  144 CONTINUE
      IF(TKILL) GO TO 142
      IF(ISPFL(ISPC) .EQ. 1)THEN
         HT(II)=HTKEEP(II)
      ELSE
         HT(II)=H
      ENDIF
      GO TO 146
  142 CONTINUE
      IF(HT(II) .GT. 0.) THEN
        NORMHT(II)=HT(II)*100.0+0.5
      ELSE
        NORMHT(II)=H*100.0+0.5
      ENDIF
      IF(ITRUNC(II).EQ.0) THEN
         IF(HT(II).GT.0.0) THEN
            ITRUNC(II)=80.0*HT(II)+0.5
         ELSE
            ITRUNC(II)=80.0*H+0.5
            HT(II)=H
         ENDIF
      ELSE
         IF(HT(II).GT.0.0) THEN
            IF(HT(II).LT.(ITRUNC(II)*0.01)) HT(II)=ITRUNC(II)*0.01
         ELSE
            HT(II)=ITRUNC(II)*0.01
         ENDIF
      ENDIF
      IF(NORMHT(II)*0.01.LT.HT(II)) NORMHT(II)=HT(II)*100.0
C----------
C   CALL FIRE SNAG MODEL TO ADD THE DEAD TREES TO THE
C   SNAG LIST; DEFLATE PROB(II), WHICH WAS TEMPORARILY
C   ADJUSTED TO ALLOW BACKDATING FOR CALIBRATION PURPOSES,
C   IN **NOTRE**
C----------
  146 CONTINUE
      IF (TKILL) THEN
        HS = ITRUNC(II) * 0.01
      ELSE
        HS = HT(II)
      ENDIF
      CALL FMSSEE (II,ISPC,D,HS,
     >  (PROB(II)/(FINT/FINTM)),3,.FALSE.,JOSTND)
C
  145 CONTINUE
C----------
  150 CONTINUE
C----------
C  END OF HEIGHT DUBBING SEGMENT.  PRINT CONTROL TABLE ENTRIES FOR
C  USEABLE HEIGHTS AND MISSING HEIGHTS, AND REINITIALIZE COUNTERS.
C----------
      WRITE(JOSTND,9006) (KNT2(I),I=1,NUMSP)
 9006 FORMAT(/,'NUMBER OF RECORDS WITH MISSING HEIGHTS',
     &       ((T49,11(I4,2X)/)))
      WRITE(JOSTND,9007) (KNT(I),I=1,NUMSP)
 9007 FORMAT(/,'NUMBER OF RECORDS WITH BROKEN OR DEAD TOPS',
     &       ((T49,11(I4,2X)/)))
      DO 160 I=1,MAXSP
      KNT(I)=0
      KNT2(I)=0
  160 CONTINUE
C----------
C  CHECK FOR MISSING CROWNS ON LIVE TREES.
C  SAVE PCT IN OLDPCT TO RETAIN AN OLD PCTILE VALUE.
C----------
      MISSCR = .FALSE.
      DO 190 I=1,ITRN
      OLDPCT(I)= PCT(I)
      IF(ICR(I).LE.0)THEN
        MISSCR = .TRUE.
        ISPC=ISP(I)
        IPTR=IREF(ISPC)
        KNT2(IPTR)=KNT2(IPTR)+1
      ENDIF
      IF(ITRE(I).LE.0) ITRE(I) = 9999
  190 CONTINUE
C----------
C  CHECK FOR MISSING CROWNS ON CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 192
      DO 191 I=IREC2,MAXTRE
      IF(ICR(I).LE.0)MISSCR=.TRUE.
  191 CONTINUE
  192 CONTINUE
C----------
C  CALL **CROWN** IF ANY CROWN RATIOS ARE MISSING.
C----------
      IF(MISSCR)CALL CROWN
C----------
C  PRINT CONTROL TABLE ENTRY FOR MISSING CROWN RATIOS; RESET COUNTERS.
C----------
      WRITE(JOSTND,9008) (KNT2(I),I=1,NUMSP)
 9008 FORMAT(/,'NUMBER OF RECORDS WITH MISSING CROWN RATIOS',
     &       ((T49,11(I4,2X)/)))
      DO 200 I=1,MAXSP
      KNT2(I)=0
  200 CONTINUE
C----------
C  CALL DGDRIV TO CALIBRATE DIAMETER GROWTH EQUATIONS.
C----------
      CALL DGDRIV
C----------
C  PREPARE INPUT DATA FOR HEIGHT GROWTH MODEL CALIBRATION; IT'S DONE
C  THE SAME AS THE DIAMETER GROWTH MODEL SEEN ABOVE.
C----------
      IF(IHTG.EQ.0 .OR. IHTG.EQ.2) GOTO 236
      Q = 1.
      IF(IHTG.EQ.3) Q = -1.
      DO 233 I=1,ITRN
      IF(HTG(I).LE.0.) GOTO 233
      HTG(I) = Q * (HT(I)-HTG(I))
      IF (HT(I).LE.0.0) HTG(I)=0.0
  233 CONTINUE
  236 CONTINUE
C----------
C  ESTIMATE MISSING TOTAL TREE AGES
C----------
      IF(DEBUG)WRITE(JOSTND,*)'IN CRATET, CALLING FINDAG'
      DO I=1,ITRN
      IF(ABIRTH(I) .LE. 0.)THEN
        SITAGE = 0.0
        SITHT = 0.0
        AGMAX = 0.0
        HTMAX = 0.0
        HTMAX2 = 0.0
        ISPC = ISP(I)
        D = DBH(I)
        H = HT(I)
        D2 = 0.0
        CALL FINDAG(I,ISPC,D,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,
     &              DEBUG)
        IF(SITAGE .GT. 0.)ABIRTH(I)=SITAGE
      ENDIF
      ENDDO
C----------
C  CALL REGENT TO CALIBRATE THE SMALL TREE HEIGHT INCREMENT MODEL.
C----------
      CALL REGENT(.FALSE.,1)
C----------
C  LOAD SPCNT WITH NUMBER OF TREES PER ACRE BY SPECIES AND TREE
C  CLASS.
C----------
      DO 240 I=1,ITRN
      IS=ISP(I)
      IM=IMC(I)
      SPCNT(IS,IM)=SPCNT(IS,IM)+PROB(I)
  240 CONTINUE
C----------
C  COMPUTE DISTRIBUTION OF TREES PER ACRE AND SPECIES-TREE CLASS
C  COMPOSITION BY TREES PER ACRE.
C----------
  245 CONTINUE
      CALL PCTILE(ITRN,IND,PROB,WK3,ONTCUR(7))
      CALL DIST(ITRN,ONTCUR,WK3)
      CALL COMP(OSPCT,IOSPCT,SPCNT)
      IF (ITRN.LE.0) GO TO 500
C----------
C  CALL **DENSE** TO CALCULATE STAND DENSITY STATISTICS FOR
C  INITIAL INVENTORY.
C----------
      IF(DEBUG) WRITE(JOSTND,9013) ICYC
 9013 FORMAT('CALLING DENSE, CYCLE=',I2)
      CALL DENSE
C----------
C  COUNT AND PRINT NUMBER OF RECORDS WITH MISTLETOE.
C----------
      CALL MISCNT(KNT)
      WRITE(JOSTND,248) (KNT(I),I=1,NUMSP)
  248 FORMAT(/,'NUMBER OF RECORDS WITH MISTLETOE',T49,11(I4,2X))
C----------
C  CALL **SDICHK** TO SEE IF INITIAL STAND SDI IS ABOVE THE SPECIFIED
C  MAXIMUM SDI.  RESET MAXIMUM SDI IF THIS IS THE CASE.
C----------
      CALL SDICHK
C
  500 CONTINUE
      IF(DEBUG)WRITE(JOSTND,510)ICYC
  510 FORMAT('LEAVING SUBROUTINE CRATET  CYCLE =',I5)
C
      RETURN
      END
