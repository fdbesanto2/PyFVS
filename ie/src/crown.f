      SUBROUTINE CROWN
      IMPLICIT NONE
C----------
C  **CROWN--NI23   DATE OF LAST REVISION:  03/31/11
C----------
C  THIS SUBROUTINE IS USED TO DUB MISSING CROWN RATIOS AND COMPUTE CROWN
C  RATIO CHANGES FOR TREES THAT ARE GREATER THAN 3 INCHES DBH.  CROWN
C  RATIO IS PREDICTED FROM HABITAT TYPE, BASAL AREA, CROWN COMPETITION
C  FACTOR, DBH, TREE HEIGHT, AND PERCENTILE IN THE BASAL AREA
C  DISTRIBUTION.  WHEN THE EQUATION IS USED TO PREDICT CROWN RATIO
C  CHANGE, VALUES OF THE PREDICTOR VARIABLES FROM THE START OF THE CYCLE
C  ARE USED TO PREDICT OLD CROWN RATIO, VALUES FROM THE END OF THE CYCLE
C  ARE USED TO PREDICT NEW CROWN RATIO, AND THE CHANGE IS COMPUTED BY
C  SUBTRACTION.  THE CHANGE IS APPLIED TO ACTUAL CROWN RATIO.  THIS
C   ROUTINE IS CALLED FROM **CRATET** TO DUB MISSING VALUES, AND BY
C  **TREGRO** TO COMPUTE CHANGE DURING REGULAR CYCLING.  ENTRY
C  **CRCONS** IS CALLED BY **RCON** TO LOAD MODEL CONSTANTS THAT ARE
C  SITE DEPENDENT AND NEED ONLY BE RESOLVED ONCE.  A CALL TO **DUBSCR**
C  IS ISSUED TO DUB CROWN RATIO WHEN DBH IS LESS THAN 3 INCHES.
C  PROCESSING OF CROWN CHANGE FOR SMALL TREES IS CONTROLLED BY
C  **REGENT**.
C----------
C  SPECIES EXPANSION
C  WB USE COEFFICIENTS FOR L
C  LM AND PY USE COEFFICIENTS FROM TT FOR LM
C  LL USE COEFFICIENTS FOR AF
C  AS, MM, PB USE COEFFIECIENTS FOR AS FROM UT
C  CO, OH USE COEFFIECIENTS FOR OH FROM CR
C  OS USE COEFFEICIENTS FOR MH
C  PI, JU USE COEFFICIENTS FROM UT (WHICH ARE FROM CR SO,
C         USE CR LOGIC)
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CALCOM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'GGCOM.F77'
C
C
COMMONS
C----------
C  DECLARATIONS AND DIMENSIONS FOR INTERNAL VARIABLES:
C
C  DCRCON -- CONSTANT TERM FOR THE CROWN RATIO MODEL BASED ON
C            PAST TREE STAND ATTRIBUTES
C  XCRCON -- CONSTANT TERM FOR THE CROWN RATIO MODEL BASED ON
C            CURRENT TREE STAND ATTRIBUTES
C    PARM -- ARRAY OF COEFFICIENTS FOR TERMS INVOLVING TREE
C            AND STAND ATTRIBUTES
C----------
      EXTERNAL RANN
      LOGICAL DEBUG,NIVAR,CRVAR,UTTVAR,LPIJU
      REAL PARM(MAXSP,14)
      INTEGER MAPHAB(30,MAXSP),IERR
      REAL CRHAB(14,MAXSP),RMAIAS,RMAILM,TEMMAI,ADJMAI
      REAL CRNEW(MAXTRE),WEIBA(MAXSP),WEIBB0(MAXSP),
     & WEIBB1(MAXSP),WEIBC0(MAXSP),WEIBC1(MAXSP),C0(MAXSP),C1(MAXSP),
     & CRNMLT(MAXSP),DLOW(MAXSP),DHI(MAXSP),
     & PRM(5)
      INTEGER ISORT(MAXTRE),MYACTS(1),ICFLG(MAXSP)
      REAL RDM,OBA,XCRCON,DCRCON,B7,B8,B9,B10,B11,B12,B13,B14,RELSDI
      REAL ACRNEW,A,B,C,D,H,BARK,HF,CL,CR,SCALE,X,RNUMB,CRHAT
      INTEGER ISPC,I1,I2,I3,IITRE,J,I,JJ,NTODO,NP,IACTK
      INTEGER IDATE,IDT,ISPCC,IGRP,IULIM,IG,IGSP,J1,ICRI
      REAL CRSD,X1,X2,RDM1,BRATIO,PCTHAT,DIFF,P,PCR,EXPPCR,EXPDCR
      REAL DCR,CHG,PDIFPY,XCR,BACHLO,CRLN,CRMAX,HN,HD,TPCCF
C
      DATA MYACTS/81/
C----------
C  DATA STATEMENTS FROM NI VARIANT
C----------
      DATA PARM/
     & 0.0,-0.00204,0.0,-0.00183,3*0.0,-0.00203,-0.00190,-0.002165,
     & -0.00264,-.00204,0.0,-0.00190,8*0.0,-.00264,
     & 4*0.0,-0.000001902,6*0.0,12*0.0,
     & -0.34566,4*0.0,0.17479,5*0.0,12*0.0,
     & 5*0.0,-0.00183,5*0.0,12*0.0,
     & 10*0.0,0.000005116,11*0.0,0.000005116,
     & 2*0.0,-0.15334,3*0.0,-0.18555,4*0.0,12*0.0,
     & 0.03882,3*0.0,0.03027,-0.0056,5*0.0,12*0.0,
     & -0.0007,3*0.0,-0.00055,6*0.0,12*0.0,
     & .0,0.30066,0.33840,0.24293,2*0.0,0.53172,0.29699,0.23372,
     & 0.26558,0.0,0.30066,0.0,0.23372,9*0.0,
     & 6*0.0,-0.02989,4*0.0,12*0.0,
     & 6*0.0,0.00011,4*0.0,12*0.0,
     & -0.21217,-0.59302,-0.59685,-0.25601,-0.25776,2*0.0,-0.38334,
     & -0.28433,-0.31555,-0.25138,-0.59302,0.0,-0.28433,8*0.0,-0.25138,
     & 0.00301,5*0.0,0.0042,0.0,0.001903,4*0.0,0.001903,9*0.0,
     & 0.0,0.19558,0.16488,0.07260,0.06887,0.1105,0.0,0.09918,0.0,
     & 0.16072,0.05140,0.19558,10*0.0,0.05140/
      DATA ((MAPHAB(I,J),I=1,30), J=1,5)/
     & 12*2,3,3*4,3*5,6,6,1,6,1,7,1,4*6,
     & 7*2,3,2,4,4,5,6,3*7,8,8,4,1,10,9,10,1,11,4*1,2,
     & 3*2,3*4,6,7,4,8,8,5,9,3*10,2*11,8,1,2*12,13,1,3,1,3,3*1,
     & 9*2,1,1,2,3,3*4,5,5,6,1,3*7,1,8,1,7,3*1,
     & 30*1/
      DATA ((MAPHAB(I,J),I=1,30), J=6,MAXSP)/
     & 16*1,3*2,11*1,
     & 6*2,4,5,5,2,2,6,7,3*8,9,9,10,2*11,12,11,1,13,1,14,3,3,11,
     & 7*2,3,2,1,1,2,4,3*5,6,6,7,8,8,9,8,10,11,1,1,2*12,8,
     & 13*2,3,4*4,5,6,6,7,6,1,8,1,9,2*10,6,
     & 2,2,4,3*1,5,6,3*1,8,7,3*9,3*3,11*1,
     & 12*1,4*2,3,3,4,3*1,5,1,6,5*1,
     & 7*2,3,2,4,4,5,6,3*7,8,8,4,1,10,9,10,1,11,4*1,2,
     & 30*1,
     & 13*2,3,4*4,5,6,6,7,6,1,8,1,9,2*10,6,
     & 240*1,
     & 12*1,4*2,3,3,4,3*1,5,1,6,5*1/
      DATA CRHAB/
     & 0.8884, 0.7309, 0.9347, 0.9888, 0.9945, 1.1126, 1.0263, 7*0.0,
     & 0.06533, 0.03441, 0.2307, 0.1661, -0.1253, -0.05018, 0.11005,
     & 0.08113, 0.1782, 0.03919, 0.2107, 3*0.0,
     & 0.8643, 0.7271, 0.9840, 0.8127, 0.8874, 0.7055, 0.7708, 0.7849,
     & 0.8038, 0.8742, 0.8232, 0.8415, 0.9759, 0.0,
     &-0.2304,-0.5421,-0.4343,-0.3759,-0.4129,-0.4879,-0.2674,
     &-0.1941,6*0.0,
     & -0.2413,13*0.0,
     & -1.6053, -1.7128, 12*0.0,
     & -0.3785, -0.4142, -0.3985, -0.2987, -0.3810, -0.4087, -0.3577,
     & -0.2994, -0.2486,-0.2863,-0.1968,-0.4931,-0.2676,-0.5625,
     & 0.05351, -0.05031, 0.1075, -0.1872, 0.01729, 0.03667, 0.01885,
     & 0.09102, 0.1371, 0.08368, 0.1230, -0.02365, 2*0.0,
     & 0.09453, -0.07740, 0.07113, 0.2039, 0.06176, 0.1513, 0.09086,
     & 0.1580, 0.09229, 0.01551, 4*0.0,
     & -0.9436, -0.8654, -0.8849, -0.9067, -0.8783, -1.0103, -1.0268,
     & -1.0050, -1.0301, 5*0.0,
     & 0.4649, 0.3211, 0.1970, 0.2295, 0.3383, 0.3450, 8*0.0,
     & 0.06533, 0.03441, 0.2307, 0.1661, -0.1253, -0.05018, 0.11005,  !START SPEC EXPAND
     & 0.08113, 0.1782, 0.03919, 0.2107, 3*0.0,
     & 14*0.0,
     & 0.09453, -0.07740, 0.07113, 0.2039, 0.06176, 0.1513, 0.09086,
     & 0.1580, 0.09229, 0.01551, 4*0.0,
     & 112*0.0,
     & 0.4649, 0.3211, 0.1970, 0.2295, 0.3383, 0.3450, 8*0.0/
C---------
C     DATA CRSD/12.69/
C  THIS IS A POPULATION ESTIMATE AND TOO LARGE FOR WITHIN STAND VARIATION.
C  CUT IT IN HALF UNTIL SOMETHING BETTER COMES ALONG.   DIXON  4/19/99
C----------
      DATA CRSD/6.35/
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CROWN',5,ICYC)
C----------
C  CALCULATE THE MAI VALUES FOR THE AS/MM/PB AND LM/PY SPECIES GROUPS.
C  THIS WILL BE USED LATER IN CROWN DUBBING FOR THESE SPECIES INSTEAD
C  OF THE RMAI VALUE COMPUTED IN CRATET. THESE ARE THE ONLY SPECIES
C  WHICH HAVE AN MAI TERM IN THE ESTIMATION OF CROWN RATIO.
C----------
      RMAIAS = ADJMAI(746,SITEAR(18),10.0,IERR)
      IF(RMAIAS .GT. 128.0)RMAIAS=128.0
      RMAILM = ADJMAI(101,SITEAR(13),10.0,IERR)
      IF(RMAILM .GT. 128.0)RMAI=128.0
      IF(DEBUG)WRITE(JOSTND,*)' SITEAS,RMAIAS,SITELM,RMAILM= ',
     &SITEAR(18),RMAIAS,SITEAR(13),RMAILM 
C----------
C  WRITE DEBUG INFO (STAND DENSITY TERMS) IF DESIRED
C----------
      IF(DEBUG) WRITE(JOSTND,9000) BA, RELDEN, RELDM1
 9000 FORMAT(' IN CROWN, BA=',F7.3,'  RELDEN=',F7.3,'  RELDM1=',F7.3)
C----------
C  DUB CROWNS ON DEAD TREES IF NO LIVE TREES IN INVENTORY
C----------
      IF((ITRN.LE.0).AND.(IREC2.LT.MAXTP1))GO TO 74
C---------
C  IF THERE ARE NO TREE RECORDS, THEN RETURN.
C---------
      IF(ITRN.EQ.0)THEN
        RETURN
      ELSEIF(TPROB.LE.0.0)THEN
        DO I=1,ITRN
        ICR(I)=ABS(ICR(I))
        ENDDO
        RETURN
      ENDIF
C---------
C  ADDED FOR SPECIES EXPANSION
C  INITIALIZE CROWN VARIABLES TO BEGINNING OF CYCLE
C---------
      IF(LSTART)THEN
        DO 10 JJ=1,MAXTRE
        CRNEW(JJ) = 0.0
        ISORT(JJ) = 0
   10   CONTINUE
      ENDIF
C-----------
C  PROCESS CRNMULT KEYWORD.
C-----------
      CALL OPFIND(1,MYACTS,NTODO)
      IF(NTODO .EQ. 0)GO TO 25
      DO 24 I=1,NTODO
      CALL OPGET(I,5,IDATE,IACTK,NP,PRM)
      IDT=IDATE
      CALL OPDONE(I,IDT)
      ISPCC=IFIX(PRM(1))
C----------
C  ISPCC<0 CHANGE FOR ALL SPECIES IN THE SPECIES GROUP
C  ISPCC=0 CHANGE FOR ALL SPEICES
C  ISPCC>0 CHANGE THE INDICATED SPECIES
C----------
      IF(ISPCC .LT. 0)THEN
        IGRP = -ISPCC
        IULIM = ISPGRP(IGRP,1)+1
        DO 21 IG=2,IULIM
        IGSP = ISPGRP(IGRP,IG)
        IF(PRM(2) .GE. 0.0)CRNMLT(IGSP)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(IGSP)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(IGSP)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(IGSP)=1
   21   CONTINUE
      ELSEIF(ISPCC .EQ. 0)THEN
        DO 22 ISPCC=1,MAXSP
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
   22   CONTINUE
      ELSE
        IF(PRM(2) .GE. 0.0)CRNMLT(ISPCC)=PRM(2)
        IF(PRM(3) .GT. 0.0)DLOW(ISPCC)=PRM(3)
        IF(PRM(4) .GT. 0.0)DHI(ISPCC)=PRM(4)
        IF(PRM(5) .GT. 0.0)ICFLG(ISPCC)=1
      ENDIF
   24 CONTINUE
   25 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9024)ICYC,CRNMLT
 9024 FORMAT(/' IN CROWN 9024 ICYC,CRNMLT= ',
     & I5/((1X,11F6.2)/))
C---------
C LOAD ISORT ARRAY WITH DIAMETER DISTRIBUTION RANKS.  IF
C ISORT(K) = 10 THEN TREE NUMBER K IS THE 10TH TREE FROM
C THE BOTTOM IN THE DIAMETER RANKING  (1=SMALL, ITRN=LARGE)
C---------
      DO 11 JJ=1,ITRN
      J1 = ITRN - JJ + 1
      ISORT(IND(JJ)) = J1
   11 CONTINUE
      IF(DEBUG)THEN
        WRITE(JOSTND,7900)ITRN,(IND(JJ),JJ=1,ITRN)
 7900   FORMAT(' IN CROWN 7900 ITRN,IND =',I6,/,86(1H ,32I4,/))
        WRITE(JOSTND,7901)ITRN,(ISORT(JJ),JJ=1,ITRN)
 7901   FORMAT(' IN CROWN 7900 ITRN,ISORT =',I6,/,86(1H ,32I4,/))
      ENDIF
C----------
C  IF CCF LAST CYCLE WAS LESS THAN 100.0, THERE IS ASSUMED TO BE
C  NO DENSITY IMPACT ON CROWN RATIOS.
C----------
      X1=0.
      X2=0.
      RDM1=RELDM1
      OBA=OLDBA
      IF(RELDM1.GE.100.0) GO TO 20
      OBA=BA
      RDM1=RELDEN
   20 CONTINUE
      IF(LSTART) GOTO 26
      IF(OBA.GT.0.)X1=ALOG(OBA)
      IF(RDM1.GT.0.)X2=ALOG(RDM1)
   26 CONTINUE
C----------
C  ENTER THE LOOP FOR SPECIES DEPENDENT VARIABLES
C----------
      DO 70 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF(I1 .EQ. 0)GOTO 70
      I2 = ISCT(ISPC,2)
C---------
C  SET UP LOGICAL VARIABLES DEPENDING UPON VARIANT SPECIES CAME FROM
C---------
      NIVAR = .FALSE.
      CRVAR = .FALSE.
      UTTVAR= .FALSE.
      LPIJU = .FALSE.
      IF(ISPC.LE.12 .OR. ISPC.EQ.14 .OR. ISPC.EQ.23)THEN
        NIVAR=.TRUE.
      ELSEIF(ISPC.EQ.19 .OR. ISPC.EQ.22)THEN
        CRVAR=.TRUE.
      ELSEIF(ISPC.EQ.15 .OR. ISPC.EQ.16)THEN
        LPIJU=.TRUE.
      ELSE
        UTTVAR=.TRUE.
      ENDIF
      IF(NIVAR)THEN
        XCRCON = CRCON(ISPC) + PARM(ISPC,1)*BA + PARM(ISPC,2)*BA*BA +
     &  PARM(ISPC,3)*ALOG(BA) + PARM(ISPC,4)*RELDEN + PARM(ISPC,5)
     &  *RELDEN*RELDEN + PARM(ISPC,6)*ALOG(RELDEN)
        DCRCON=0.0
      ENDIF
C----------
C  IF DUBBING MISSING CROWN RATIOS, BYPASS ASSIGNMENT OF DCRCON.
C----------
      IF(LSTART) GO TO 30
      IF(NIVAR)THEN
        DCRCON = CRCON(ISPC) + PARM(ISPC,1)*OBA + PARM(ISPC,2)*OBA*OBA +
     &  PARM(ISPC,3)*X1 + PARM(ISPC,4)*RDM1 + PARM(ISPC,5)*RDM1
     &  *RDM1 + PARM(ISPC,6)*X2
      ENDIF
C----------
C  WRITE DEBUG INFO (CONSTANT TERMS) IF DESIRED
C----------
   30 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9001) ISPC, XCRCON, DCRCON
 9001 FORMAT(' SPECIES: ',I2,' - XCRCON = ',F10.3,', DCRCON = ',F10.3)
C----------
C  VARIABLES B7, B8, ..., B14 ARE SET UP TO ELIMINATE THE
C  2-DIMENSIONAL ARRAY ACCESSES WHEN PROCESSING RECORDS OF THE SAME
C  SPECIES.
C----------
      B7 = PARM(ISPC,7)
      B8 = PARM(ISPC,8)
      B9 = PARM(ISPC,9)
      B10 = PARM(ISPC,10)
      B11 = PARM(ISPC,11)
      B12 = PARM(ISPC,12)
      B13 = PARM(ISPC,13)
      B14 = PARM(ISPC,14)
C---------
C  FOLLOWING ADDED FOR SPECIES EXPANSION FROM TT,UT
C  ESTIMATE MEAN CROWN RATIO FROM SDI, AND ESTIMATE WEIBULL PARAMETERS
C---------
      IF(SDIDEF(ISPC) .GT. 0.)THEN
        RELSDI = SDIAC / SDIDEF(ISPC)
      ELSE
        RELSDI = 1.0
      ENDIF
      IF(RELSDI .GT. 1.5) RELSDI = 1.5
      ACRNEW = C0(ISPC) + C1(ISPC) * RELSDI*100.0
      A = WEIBA(ISPC)
      B = WEIBB0(ISPC) + WEIBB1(ISPC) * ACRNEW
      C = WEIBC0(ISPC) + WEIBC1(ISPC)*ACRNEW
      IF(B .LT. 1.0) B=1.0
      IF(C .LT. 2.0) C=2.0
      IF(DEBUG) WRITE(JOSTND,9801) ISPC,SDIAC,ORMSQD,RELSDI,
     & ACRNEW,A,B,C,SDIDEF(ISPC)
 9801 FORMAT(/' IN CROWN 9001 WRITE ISPC,SDIAC,ORMSQD,RELSDI,ACRNEW,A,B
     &C,SDIDEF = ',/,1H ,I5,F8.2,F8.4,F8.2,F8.2,4F10.4)
C----------
C  ENTER LOOP FOR TREE DEPENDENT VARIABLES
C----------
      DO 60 I3=I1,I2
      I = IND1(I3)
      IITRE = ITRE(I)
C----------
C  IF THIS IS THE INITIAL ENTRY TO 'CROWN' AND THE TREE IN QUESTION
C  HAS A CROWN RATIO ASCRIBED TO IT, THE WHOLE PROCESS IS BYPASSED.
C----------
      IF(LSTART .AND. ICR(I).GT.0)GOTO 60
C----------
C  IF ICR(I) IS NEGATIVE, CROWN RATIO CHANGE WAS COMPUTED IN A
C  PEST DYNAMICS EXTENSION.  SWITCH THE SIGN ON ICR(I) AND BYPASS
C  CHANGE CALCULATIONS.
C----------
      IF (LSTART) GOTO 40
      IF (ICR(I).GT.0) GO TO 40
      ICR(I)=-ICR(I)
      IF (DEBUG) WRITE (JOSTND,35) I,ICR(I)
   35 FORMAT (' ICR(',I4,') WAS CALCULATED ELSEWHERE AND IS ',I4)
      GOTO 60
   40 CONTINUE
      D=DBH(I)
      H=HT(I)
      BARK=BRATIO(ISPC,D,H)
C--------
C  FOLLOWING ADDED FOR SPECIES EXPANSION FROM CR
C--------
      IF(CRVAR .OR. LPIJU)THEN
        HF=H+HTG(I)
        IF(CRVAR)THEN
          CL = 5.17281 + 0.32552 * HF - 0.01675 * BA
        ELSEIF(LPIJU)THEN
          CL = -0.59373 + 0.67703 * HF
        ENDIF
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. HF) CL = HF
        CR = CL / HF
        CRNEW(I) = CR*100.
        GOTO 53
      ENDIF
C----------
C  BRANCH TO STATEMENT 58 TO HANDLE TREES WITH DBH LT SOME THRESHOLD
C  FOR TT AND UT SPECIES EXPANSION TREES, BRANCH TO 58 IF D < 1 IN.
C  "ELSE" PORTION APPLIES IF NIVAR IS .TRUE., BRANCH IF D < 3 IN.
C  CASE WHERE CRVAR OR LPIJU IS TRUE BRANCH TO STMT 53 ABOVE.
C----------
      IF(UTTVAR)THEN
         IF(D.LT.1.0.AND.LSTART) GO TO 58
      ELSE
         IF(D.LT.3.0) GO TO 58
      ENDIF
C----------
C  THE FOLLOWING LINES UNTIL STATEMENT 51 HAS BEEN ADDED
C  FOR UT AND TT SPECIES (EXCEPT PINYON & JUNIPER)
C----------
      IF(UTTVAR)THEN
C----------
C  CALCULATE THE PREDICTED CURRENT CROWN RATIO
C----------
        SCALE = (1.0 - .00167 * (RELDEN-100.0))
        IF(SCALE .GT. 1.0) SCALE = 1.0
        IF(SCALE .LT. 0.30) SCALE = 0.30
        IF(DBH(I) .GT. 0.0) THEN
          X = (FLOAT(ISORT(I)) / FLOAT(ITRN)) * SCALE
        ELSE
          CALL RANN(RNUMB)
          X = RNUMB * SCALE
        ENDIF
        IF(X .LT. .05) X=.05
        IF(X .GT. .95) X=.95
        CRNEW(I) = A + B*((-1.0*ALOG(1-X))**(1.0/C))
C----------
C  WRITE DEBUG INFO IF DESIRED
C----------
        IF(DEBUG)WRITE(JOSTND,9002) I,X,CRNEW(I),ICR(I)
 9002   FORMAT(/' IN CROWN 9002 WRITE I,X,CRNEW,ICR = ',
     &  I5,2F10.5,I5)
        CRNEW(I) = CRNEW(I)*10.0
C---------
C  END OF LOOP FOR UT, TT SPECIES
C---------
      ENDIF
C---------
C  THE FOLLOWING LOGIC IS USED ONLY BY ORIGINAL NI SPECIES
C  ALL OTHER SPECIES SKIP TO LINE
C---------
      IF(NIVAR)THEN
C----------
C  BYPASS CROWN CHANGE CALCULATION IF CROWN RATIO WAS ASSIGNED
C  THIS CYCLE IN REGENT.
C----------
        IF(.NOT.LSTART .AND. D-DG(I)/BARK .LT.3.0) GO TO 60
        P=PCT(I)
        IF(P.LT.0.01)P=0.01
C----------
C  CALCULATE THE PREDICTED CURRENT CROWN RATIO
C----------
        PCR = XCRCON + B7*D + B8*D*D + B9*ALOG(D) + B10*H + B11*H*H +
     &  B12*ALOG(H) + B13*P + B14*ALOG(P)
        EXPPCR= EXP(PCR)
C----------
C  SET DIFFERENTIAL TO 0.0 AND BRANCH TO 50 IF DUBBING
C----------
        EXPDCR=0.0
        IF(LSTART) GO TO 50
C----------
C  BACKDATE TREE ATTRIBUTES SO THAT CROWN RATIO AT THE BEGINNING
C  OF THE CYCLE CAN BE PREDICTED.
C----------
        D=D-(DG(I)/BARK)
        IF(D.LE.0.0) D=DBH(I)
        H=H-HTG(I)
        IF(H.LE.0.0) H=HT(I)
        IF((OLDPCT(I).GT.PCT(I).AND.ONTREM(7).GT.0.0).OR.
     &  OLDPCT(I).LE.0.0) OLDPCT(I)=PCT(I)
        P=OLDPCT(I)
        IF(P.LT.0.01)P=0.01
C----------
C  CALCULATE THE PREDICTED CROWN RATIO AT THE START OF THE CYCLE.
C----------
        DCR = DCRCON + B7*D + B8*D*D + B9*ALOG(D) + B10*H + B11*H*H +
     &  B12*ALOG(H) + B13*P + B14*ALOG(P)
        EXPDCR=EXP(DCR)
C----------
C  WRITE DEBUG INFO IF DESIRED
C----------
   50   CONTINUE
        IF(DEBUG)WRITE(JOSTND,*)' ISPC,NIVAR= ',ISPC,NIVAR
        IF(DEBUG) WRITE(JOSTND,9802) I,ICR(I),EXPPCR,EXPDCR,D,H,PCT(I),
     &  OLDPCT(I)
 9802   FORMAT(' ICR(',I4,')=',I3,'  EXPPCR=',F10.3,' EXPDCR=',F10.3,
     &  ' D=',F7.3,' H=',F7.3,' P=',F7.3,' OLDP=',F7.3)
C----------
C  COMPUTE THE PREDICTED CROWN RATIO AND
C  BOUND CROWN CHANGE TO 1% PER YEAR
C----------
        CHG=EXPPCR-EXPDCR
        IF(.NOT.LSTART.OR.(ICR(I).GT.0))THEN
          PDIFPY=CHG/ICR(I)/FINT*100.
          IF(PDIFPY.GT.0.01)CHG=ICR(I)*(0.01)*FINT/100.
          IF(PDIFPY.LT.-0.01)CHG=ICR(I)*(-0.01)*FINT/100.
        ENDIF
C----------
C  APPLY CRNMULT KEYWORD ADJUSTMENTS
C----------
        IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LT.DHI(ISPC))THEN
          ICRI=ICR(I)+CRNMLT(ISPC)*CHG*100.0+0.5
        ELSE
          ICRI=ICR(I)+CHG*100.0+0.5
        ENDIF
        IF ((DGSD.LT.1.0).OR.(.NOT.LSTART)) GO TO 51
        XCR=ICRI
        ICRI=BACHLO(XCR,CRSD,RANN)
   51   CONTINUE
C---------
C  END OF NI BLOCK
C---------
        GO TO 55
      ENDIF
C----------
C  COMPUTE THE CHANGE IN CROWN RATIO
C  CALC THE DIFFERENCE BETWEEN THE MODEL AND THE OLD(OBS)
C  THIS SECTION ADDED FOR SPECIES EXPANSION
C  BOUND CROWN CHANGE TO 1% PER YEAR
C----------
  53  CONTINUE
      CHG=CRNEW(I)-ICR(I)
      IF(.NOT.LSTART.OR.(ICR(I).GT.0))THEN
        PDIFPY=CHG/ICR(I)/FINT
        IF(PDIFPY.GT.0.01)CHG=ICR(I)*(0.01)*FINT
        IF(PDIFPY.LT.-0.01)CHG=ICR(I)*(-0.01)*FINT
        IF(DEBUG)WRITE(JOSTND,9020)I,CRNEW(I),ICR(I),PDIFPY,CHG
 9020   FORMAT(/'  IN CROWN 9020 I,CRNEW,ICR,PDIFPY,CHG =',
     &  I5,F10.3,I5,3F10.3)
        IF(DBH(I).GE.DLOW(ISPC).AND.DBH(I).LT.DHI(ISPC))THEN
          CRNEW(I) = ICR(I) + CHG * CRNMLT(ISPC)
        ELSE
          CRNEW(I) = ICR(I) + CHG
        ENDIF
      ICRI=CRNEW(I)+0.5
      ELSE
C  DUB CROWN
        ICRI = CRNEW(I)+0.5
        IF(DBH(I).GE.DLOW(ISPC).AND.DBH(I).LT.DHI(ISPC))
     &  ICRI = ICRI*CRNMLT(ISPC)
      ENDIF
C---------
C CALC CROWN LENGTH NOW FOR CR, UT, TT VARIANTS
C---------
      IF(LSTART .OR. ICR(I).EQ.0)GO TO 55
      CRLN=HT(I)*ICR(I)/100.
C---------
C CALC CROWN LENGTH MAX POSSIBLE IF ALL HTG GOES TO NEW CROWN
C---------
      CRMAX=(CRLN+HTG(I))/(HT(I)+HTG(I))*100.0
      IF(DEBUG)WRITE(JOSTND,9004)CRMAX,CRLN,ICRI,I,CRNEW(I),CHG
 9004 FORMAT(/' CRMAX=',F10.2,' CRLN=',F10.2,
     &' ICRI=',I10,' I=',I5,' CRNEW=',F10.2,' CHG=',F10.3)
C---------
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C---------
      IF(ICRI.LT.10.AND.CRNMLT(ISPC).EQ.1.0)ICRI=CRMAX+0.5
      IF(ICRI.GT.CRMAX) ICRI=CRMAX+0.5
C----------
C  REDUCE CROWNS OF TREES  FLAGGED AS TOP-KILLED ON INVENTORY
C----------
   55 CONTINUE
      IF (.NOT.LSTART .OR. ITRUNC(I).EQ.0) GO TO 59
      HN=NORMHT(I)/100.0
      HD=HN-ITRUNC(I)/100.0
      CL=(FLOAT(ICRI)/100.)*HN-HD
      ICRI=IFIX((CL*100./HN)+.5)
      IF(DEBUG)WRITE(JOSTND,9030)I,ITRUNC(I),NORMHT(I),HN,HD,
     & ICRI,CL
 9030 FORMAT(/'  IN CROWN 9030 I,ITRUNC,NORMHT,HN,HD,ICRI,CL = ',
     & 3I5,2F10.3,I5,F10.3)
      GO TO 59
C----------
C  CROWNS FOR TREES WITH DBH LT 3.0 (NI), 1.0 (UT & TT) ARE DUBBED HERE.
C  NO CHANGE IS CALCULATED UNTIL THE TREE ATTAINS THESE LIMITS.
C  NOT USED BY CR SPECIES
C----------
   58 CONTINUE
      IF(CRVAR)GOTO 59
      IF(.NOT.LSTART.AND. NIVAR) GO TO 60
      IF(UTTVAR .AND. ICR(I).NE.0)GOTO 60
      TPCCF = PCCF(IITRE)
      SELECT CASE (ISPC)
        CASE(13,17)
          TEMMAI = RMAILM
        CASE(18,20,21)
          TEMMAI = RMAIAS
        CASE DEFAULT
          TEMMAI = RMAI
      END SELECT
      CALL DUBSCR(ISPC,D,H,BA,CR,TPCCF,AVH,TEMMAI)
      ICRI=CR*100.0+0.5
      IF(DEBUG)WRITE(JOSTND,*)' AFTER DUBSCR I,ISPC,D,H,BA,CR,ICRI= ',
     &I,ISPC,D,H,BA,CR,ICRI
C---------
C  ADDED FOR CRNMULT
C---------
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LT.DHI(ISPC))
     &   ICRI = ICRI * CRNMLT(ISPC)
C----------
C  END OF CROWN RATIO CALCULATION LOOP.  BOUND CR ESTIMATE AND FILL
C  THE ICR VECTOR.
C----------
   59 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF(.NOT.NIVAR)THEN
        IF (ICRI .LT. 10.AND.CRNMLT(ISPC).EQ.1.0) ICRI=10
        IF(ICRI .LT. 1)ICRI = 1
      ELSE
        IF (ICRI .LT. 5.AND.(CRNMLT(ISPC).EQ.1)) ICRI=5
      ENDIF
      ICR(I)= ICRI
   60 CONTINUE
      IF(LSTART .AND. ICFLG(ISPC).EQ.1)THEN
        CRNMLT(ISPC)=1.0
        ICFLG(ISPC)=0
      ENDIF
   70 CONTINUE
   74 CONTINUE
C----------
C  DUB MISSING CROWNS ON CYCLE 0 DEAD TREES.
C----------
      IF(IREC2 .GT. MAXTRE) GO TO 75
      DO 79 I=IREC2,MAXTRE
      IF(ICR(I) .GT. 0) GO TO 79
      ISPC=ISP(I)
      D=DBH(I)
      H=HT(I)
C---------
C  SET UP LOGICAL VARIABLES DEPENDING UPON VARIANT SPECIES CAME FROM
C---------
      NIVAR = .FALSE.
      CRVAR = .FALSE.
      UTTVAR= .FALSE.
      LPIJU = .FALSE.
      IF(ISPC.LE.12 .OR. ISPC.EQ.14 .OR. ISPC.EQ.23)THEN
        NIVAR=.TRUE.
      ELSEIF(ISPC.EQ.19 .OR. ISPC.EQ.22)THEN
        CRVAR=.TRUE.
      ELSEIF(ISPC.EQ.15 .OR. ISPC.EQ.16)THEN
        LPIJU=.TRUE.
      ELSE
        UTTVAR=.TRUE.
      ENDIF
C
C  ADDED FROM UT, TT FOR SPECIES EXPANSION
C
      IITRE=ITRE(I)
      TPCCF=PCCF(IITRE)
      IF(CRVAR .OR. LPIJU)THEN
        IF(CRVAR)THEN
          CL = 5.17281 + 0.32552 * H - 0.01675 * BA
        ELSEIF(LPIJU)THEN
          CL = -0.59373 + 0.67703 * H
        ENDIF
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. H) CL = H
        CR = CL / H
        ICRI = CR*100.
      ELSE
        SELECT CASE (ISPC)
          CASE(13,17)
            TEMMAI = RMAILM
          CASE(18,20,21)
            TEMMAI = RMAIAS
          CASE DEFAULT
            TEMMAI = RMAI
        END SELECT
        CALL DUBSCR (ISPC,D,H,BA,CR,TPCCF,AVH,TEMMAI)
        ICRI=CR*100.0 + 0.5
      ENDIF
C
      IF(ITRUNC(I).EQ.0) GO TO 78
      HN=NORMHT(I)/100.0
      HD=HN-ITRUNC(I)/100.0
      CL=(FLOAT(ICRI)/100.)*HN-HD
      ICRI=IFIX((CL*100./HN)+.5)
   78 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10) ICRI=10
      ICR(I)= ICRI
   79 CONTINUE
C
   75 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9010)ITRN,(ICR(JJ),JJ=1,ITRN)
 9010 FORMAT(/' LEAVING CROWN 9010 FORMAT ITRN,ICR= ',I10,/,
     & 43(1H ,32I4,/))
      IF(DEBUG)WRITE(JOSTND,90)ICYC
   90 FORMAT(' LEAVING SUBROUTINE CROWN  CYCLE =',I5)
      RETURN
C
C

      ENTRY CRCONS
C----------
C  ENTRY POINT FOR LOADING CROWN RATIO MODEL COEFFICIENTS THAT ARE
C  SITE DEPENDENT AND REQUIRE ONE TIME RESOLUTION.  ITYPE INDEXES
C  HABITAT TYPE (CARRIED IN /PLOT/ COMMON AREA), CRHAB CONTAINS HABITAT
C  INTERCEPTS BY HABITAT TYPE BY SPECIES, AND MAPCR MAPS HABITAT TYPE
C  ONTO HABITAT CLASS FOR EACH SPECIES.
C
C  DATA STATEMENTS FOR WEIBULL PAREMETERS ADDED FOR SPECIES EXPANSION
C----------
C
C LOAD WEIBULL 'A' PARAMETER BY SPECIES
C
      DATA WEIBA/12*0.0,1.0,3*0.0,1.0,6*0.0/
C
C LOAD WEIBULL 'B' PARAMETER EQUATION CONSTANT COEFFICIENT
C
      DATA WEIBB0/12*0.0,-0.82631,3*0.0,-0.82631,-0.08414,0.0,
     &            -0.08414,-0.08414,0.0,0.0/
C
C LOAD WEIBULL 'B' PARAMETER EQUATION SLOPE COEFFICIENT
C
      DATA WEIBB1/12*0.0,1.06217,3*0.0,1.06217,1.14765,0.0,
     &            2*1.14765,0.0,0.0/
C
C LOAD WEIBULL 'C' PARAMETER EQUATION CONSTANT COEFFICIENT
C
      DATA WEIBC0/12*0.0,3.31429,3*0.0,3.31429,2.77500,0.0,
     &            2*2.77500,0.0,0.0/
C
C LOAD WEIBULL 'C' PARAMETER EQUATION SLOPE COEFFICIENT
C
      DATA WEIBC1/23*0.0/
C
C LOAD CR=F(SDI) EQUATION CONSTANT COEFFICIENT
C
      DATA C0/12*0.0,6.19911,3*0.0,6.19911,4.01678,0.0,4.01678,
     &        4.01678,0.0,0.0/
C
C LOAD CR=F(SDI) EQUATION SLOPE COEFFICIENT
C
      DATA C1/12*0.0,-.02216,0.0,0.0,0.0,-.02216,-.01516,0.0,
     &        -.01516,-.01516,0.0,0.0/
C
C LOAD OTHER MISCELLANEOUS CONSTANTS
C
      DATA CRNMLT/MAXSP*1.0/
      DATA ICFLG/MAXSP*0/
      DATA DLOW/MAXSP*0.0/
      DATA DHI/MAXSP*99.0/
C
      DO 80 ISPC=1,MAXSP
      ICRHAB=MAPHAB(ITYPE,ISPC)
      CRCON(ISPC)=CRHAB(ICRHAB,ISPC)
   80 CONTINUE
      RETURN
      END
