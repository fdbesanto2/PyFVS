      SUBROUTINE CROWN
      use prgprm_mod
      implicit none
C----------
C  **CROWN--AK   DATE OF LAST REVISION:  03/31/11
C----------
C  THIS ROUTINE IS CALLED FROM **CRATET** TO DUB
C  MISSING VALUES, AND BY **TREGRO** TO COMPUTE CHANGE DURING
C  REGULAR CYCLING.  ENTRY **CRCONS** IS CALLED BY **RCON** TO
C  LOAD MODEL CONSTANTS THAT ARE SITE DEPENDENT AND NEED ONLY
C  BE RESOLVED ONCE.  A CALL TO **DUBSCR** IS ISSUED TO DUB
C  CROWN RATIO FOR DEAD TREES.
C----------
COMMONS
      INCLUDE 'ARRAYS.F77'
C
      INCLUDE 'COEFFS.F77'
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'OUTCOM.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'PDEN.F77'
C
      INCLUDE 'VARCOM.F77'
C
C----------
      INTEGER ICFLG(MAXSP),MYACTS(1),JJ,NTODO,I,NP,IACTK,IDATE,IDT
      INTEGER ISPCC,IGRP,IULIM,IG,IGSP,J1,ISPC,I1,I2,I3,IITRE
      INTEGER ICRI,ISORT(MAXTRE)
      REAL DHI(MAXSP),DLOW(MAXSP),CRNMLT(MAXSP),PRM(5),RELSDI,ACRNEW,A
      REAL B,C,D,H,SCALE,X,RNUMB,CRHAT,PCTHAT,DIFF,CHG,CRLN,CRMAX,HN,HD
      REAL CL,TPCT,TPCCF,CR,C1(MAXSP),C0(MAXSP),WEIBC1(MAXSP)
      REAL WEIBC0(MAXSP),WEIBB1(MAXSP),WEIBB0(MAXSP),WEIBA(MAXSP)
      REAL CRNEW(MAXTRE),PDIFPY
      DATA MYACTS/81/
C----------
C  SPECIES ORDER 1=WS, 2=WRC, 3=PSF, 4=MH, 5=WH, 6=AYC, 7=LP, 8=SS,
C                9=SAF, 10=RA, 11=CW, 12=OH, 13=OS
C----------
      LOGICAL DEBUG
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'CROWN',5,ICYC)
C
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE CROWN  CYCLE =',I5)
C----------
C INITIALIZE CROWN VARIABLES TO BEGINNING OF CYCLE VALUES.
C----------
      IF(LSTART)THEN
        DO 10 JJ=1,MAXTRE
        CRNEW(JJ)=0.0
        ISORT(JJ)=0
   10   CONTINUE
      ENDIF
C----------
C  GO TO DUB CROWNS ON DEAD TREES IF NO LIVE TREES IN INVENTORY
C----------
      IF((ITRN.LE.0).AND.(IREC2.LT.MAXTP1))GO TO 74
C----------
C IF THERE ARE NO TREE RECORDS, THEN RETURN
C----------
      IF(ITRN.EQ.0)THEN
        RETURN
      ELSEIF(TPROB.LE.0.0)THEN
        DO I=1,ITRN
        ICR(I)=ABS(ICR(I))
        ENDDO
        RETURN
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
C----------
C LOAD ISORT ARRAY WITH DIAMETER DISTRIBUTION RANKS.  IF
C ISORT(K) = 10 THEN TREE NUMBER K IS THE 10TH TREE FROM
C THE BOTTOM IN THE DIAMETER RANKING  (1=SMALL, ITRN=LARGE)
C----------
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
C  ENTER THE LOOP FOR SPECIES DEPENDENT VARIABLES
C----------
      DO 70 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF(I1 .EQ. 0) GO TO 70
      I2 = ISCT(ISPC,2)
C----------
C ESTIMATE MEAN CROWN RATIO FROM SDI, AND ESTIMATE WEIBULL PARAMETERS
C
C CHANGING SDI AFFECTS CROWN DUBBING, AND MODEL IS EXTREMELY SENSITIVE
C TO CROWN. SCALE FACTORS CHANGE. THE FOLLOWING LINE IS INTENDED TO
C FIX THIS PROBLEM.  G.DIXON 8-2-90
C----------
      IF(ISPC.EQ.10 .OR. ISPC.EQ.11) THEN
        IF(SDIDEF(ISPC) .GT. 0.)THEN
          RELSDI = SDIAC / SDIDEF(ISPC)
        ELSE
          RELSDI = 1.0
        ENDIF
        IF(RELSDI .GT. 1.5)RELSDI = 1.5
      ELSE
        RELSDI = SDIAC / 600.
        IF(RELSDI .GT. 1.0) RELSDI = 1.0
      ENDIF
      ACRNEW = C0(ISPC) + C1(ISPC) * RELSDI*100.0
      A = WEIBA(ISPC)
      B = WEIBB0(ISPC) + WEIBB1(ISPC) * ACRNEW
      C = WEIBC0(ISPC) + WEIBC1(ISPC)*ACRNEW
      IF(ISPC.EQ.10 .OR. ISPC.EQ.11) THEN
        IF(B .LT. 3.0) B=3.0
        IF(C .LT. 2.0) C=2.0
      ELSE
        IF(B .LT. 1.0) B=1.0
        IF(C .LT. 2.0) C=2.0
      ENDIF
      IF(DEBUG) WRITE(JOSTND,9001) ISPC,SDIAC,ORMSQD,RELSDI,
     & ACRNEW,A,B,C,SDIDEF(ISPC)
 9001 FORMAT(' IN CROWN 9001 WRITE ISPC,SDIAC,ORMSQD,RELSDI,ACRNEW,A,B,
     &C,SDIDEF = ',/1X,I5,F8.2,F8.4,F8.2,F8.2,4F10.4)
C
      DO 60 I3=I1,I2
      I = IND1(I3)
      IITRE=ITRE(I)
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
      IF (ICR(I).GE.0) GO TO 40
      ICR(I)=-ICR(I)
      IF (DEBUG) WRITE (JOSTND,35) I,ICR(I)
   35 FORMAT (' ICR(',I4,') WAS CALCULATED ELSEWHERE AND IS ',I4)
      GOTO 60
   40 CONTINUE
      D=DBH(I)
      H=HT(I)
C----------
C  BRANCH TO STATEMENT 58 TO HANDLE TREES WITH DBH LESS THAN 1 IN.
C  ONLY FOR RED ALDER AND COTTONWOOD
C----------
      IF(D.LT.1.0 .AND. LSTART .AND. (ISPC.EQ.10 .OR. ISPC.EQ.11))
     & GO TO 58
C----------
C  CALCULATE THE PREDICTED CURRENT CROWN RATIO
C----------
      IF(ISPC.EQ.10 .OR. ISPC.EQ.11) THEN
        SCALE = (1.0 - .00167 * (RELDEN-100.0))
      ELSE
        SCALE = 1.5-RELSDI
      ENDIF
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
   50 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9002) I,X,CRNEW(I),ICR(I)
 9002 FORMAT(' IN CROWN 9002 WRITE I,X,CRNEW,ICR = ',I5,2F10.5,I5)
      CRNEW(I) = CRNEW(I)*10.0
C----------
C  COMPUTE THE CHANGE IN CROWN RATIO
C  CALC THE DIFFERENCE BETWEEN THE MODEL AND THE OLD(OBS)
C  LIMIT CHANGE TO 1% PER YEAR DECREASE AND 3% PER YEAR INCREASE
C  (3% BECAUSE OF HIGH GROWTH RATES IN THE AK VARIANT)
C----------
      IF(LSTART .OR. ICR(I).EQ.0) GO TO 9052
      CHG=CRNEW(I) - ICR(I)
      PDIFPY=CHG/ICR(I)/FINT
      IF(PDIFPY.GT.0.03)CHG=ICR(I)*(0.03)*FINT
      IF(PDIFPY.LT.-0.01)CHG=ICR(I)*(-0.01)*FINT
      IF(DEBUG)WRITE(JOSTND,9020)I,CRNEW(I),ICR(I),PDIFPY,CHG
 9020 FORMAT(/'  IN CROWN 9020 I,CRNEW,ICR,PDIFPY,CHG =',
     &I5,F10.3,I5,3F10.3)
      IF(DBH(I) .GE. DLOW(ISPC) .AND. DBH(I) .LE. DHI(ISPC))THEN
        CRNEW(I) = ICR(I) + CHG * CRNMLT(ISPC)
      ELSE
        CRNEW(I) = ICR(I) + CHG
      ENDIF
 9052 ICRI = CRNEW(I)+0.5
      IF(LSTART .OR. ICR(I) .EQ. 0)THEN
        IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))THEN
          ICRI = ICRI * CRNMLT(ISPC)
        ENDIF
      ENDIF
C----------
C CALC CROWN LENGTH NOW
C----------
      IF(LSTART .OR. ICR(I) .EQ. 0)GO TO 55
      CRLN=HT(I)*ICR(I)/100.
C----------
C CALC CROWN LENGTH MAX POSSIBLE IF ALL HTG GOES TO NEW CROWN
C----------
      CRMAX=(CRLN+HTG(I))/(HT(I)+HTG(I))*100.0
      IF(DEBUG)WRITE(JOSTND,9004)CRMAX,CRLN,ICRI,I,CRNEW(I),
     & CHG
 9004 FORMAT('  CRMAX=',F10.2,' CRLN=',F10.2,
     &' ICRI=',I10,' I=',I5,' CRNEW=',F10.2,' CHG=',F10.3)
C----------
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C----------
      IF(ICRI.GT.CRMAX) ICRI=CRMAX+0.5
      IF(ICRI.LT.10 .AND. CRNMLT(ISPC).EQ.1.0)ICRI=CRMAX+0.5
C----------
C  REDUCE CROWNS OF TREES  FLAGGED AS TOP-KILLED ON INVENTORY
C----------
   55 IF (.NOT.LSTART .OR. ITRUNC(I).EQ.0) GO TO 59
      HN=NORMHT(I)/100.0
      HD=HN-ITRUNC(I)/100.0
      CL=(FLOAT(ICRI)/100.)*HN-HD
      ICRI=IFIX((CL*100./HN)+.5)
      IF(DEBUG)WRITE(JOSTND,9030)I,ITRUNC(I),NORMHT(I),HN,HD,
     & ICRI,CL
 9030 FORMAT('  IN CROWN 9030 I,ITRUNC,NORMHT,HN,HD,ICRI,CL = ',
     & 3I5,2F10.3,I5,F10.3)
      GO TO 59
C----------
C  CROWNS FOR TREES WITH DBH LT 1 INCH ARE DUBBED HERE.  NO CHANGE
C  IS CALCULATED UNTIL THE TREE ATTAINS A DBH OF 1 INCH.
C  RED ALDER AND COTTONWOOD ONLY
C----------
   58 CONTINUE
      IF(ICR(I) .NE. 0) GO TO 60
      TPCT = PCT(I)
      TPCCF = PCCF(IITRE)
      CALL DUBSCR(ISPC,D,H,CR,TPCT,TPCCF)
      IF(DEBUG) WRITE(JOSTND,*) 'RETURN FORM DUBSCR IN CROWN'
      ICRI=CR*100.0+0.5
      IF(DBH(I).GE.DLOW(ISPC) .AND. DBH(I).LE.DHI(ISPC))
     &ICRI = ICRI * CRNMLT(ISPC)
C----------
C  BALANCING ACT BETWEEN TWO CROWN MODELS OCCURS HERE
C  END OF CROWN RATIO CALCULATION LOOP.  BOUND CR ESTIMATE AND FILL
C  THE ICR VECTOR.
C----------
   59 CONTINUE
      IF(ICRI.GT.95) ICRI=95
      IF (ICRI .LT. 10 .AND. CRNMLT(ISPC).EQ.1) ICRI=10
      IF(ICRI.LT.1)ICRI=1
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
      IF(IREC2 .GT. MAXTRE) GO TO 80
      DO 79 I=IREC2,MAXTRE
      IF(ICR(I) .GT. 0) GO TO 79
      ISPC=ISP(I)
      D=DBH(I)
      H=HT(I)
      TPCT=PCT(I)
      IITRE=ITRE(I)
      TPCCF=PCCF(IITRE)
      CALL DUBSCR (ISPC,D,H,CR,TPCT,TPCCF)
      ICRI=CR*100.0 + 0.5
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
   80 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9010)ITRN,(ICR(JJ),JJ=1,ITRN)
 9010 FORMAT(' LEAVING CROWN 9010 FORMAT ITRN,ICR= ',I10,/,
     & 43(1H ,32I4,/))
      IF(DEBUG)WRITE(JOSTND,90)ICYC
   90 FORMAT(' LEAVING SUBROUTINE CROWN  CYCLE =',I5)
      RETURN
      ENTRY CRCONS
C----------
C  ENTRY POINT FOR LOADING CROWN RATIO MODEL COEFFICIENTS
C
C SPECIES ORDER
C  1=WS,  2=WRC,  3=PSF,  4=MH,  5=WH,  6=AYC,  7=LP,
C  8=SS,  9=SAF, 10=RA, 11=CW, 12=OH, 13=OS
C
C LOAD WEIBULL 'A' PARAMETER BY SPECIES
C----------
      DATA WEIBA/MAXSP*0.0/
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBB0/  0.15716,  0.09466,  0.15716, -0.01540,  0.51379,
     &    0.25890,  0.09499,  0.15716,  0.15716,  0.035786, -0.238295,
     &    0.25890,  0.15716/
C----------
C LOAD WEIBULL 'B' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBB1/  1.08293,  1.09576,  1.08293,  1.12736,  1.00490,
     &     1.06314,  1.10021,  1.08293,  1.08293, 1.121389, 1.180163,
     &     1.06314, 1.08293/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION CONSTANT COEFFICIENT
C----------
      DATA WEIBC0/  0.82252,    3.042,  0.82252,    2.737, -3.13907,
     &   -0.01906,    2.477,  0.82252,  0.82252,   2.0408,  3.044134,
     &   -0.01906,  0.82252/
C----------
C LOAD WEIBULL 'C' PARAMETER EQUATION SLOPE COEFFICIENT
C----------
      DATA WEIBC1/  0.51383,      0.0,  0.51383,      0.0,  1.36446,
     &    0.58428,      0.0,  0.51383,  0.51383,      0.0,  0.0,
     &    0.58428,  0.51383/
C----------
C LOAD CR=F(SDI) EQUATION CONSTANT COEFFICIENT
C----------
      DATA C0/     5.75349,     4.54,  5.75349,  5.13162,  6.09225,
     &   5.66144,  5.92905,  5.75349,  5.75349,  4.656659, 4.625125,
     &   5.66144,  5.75349/
C----------
C LOAD CR=F(SDI) EQUATION SLOPE COEFFICIENT
C----------
      DATA C1/   -0.02508,      0.0, -0.02508, -0.01422, -0.02772,
     & -0.02779, -0.05757, -0.02508, -0.02508, -0.022612,-0.016042,
     & -0.02779, -0.02508/
C
      DATA CRNMLT/MAXSP*1.0/
      DATA ICFLG/MAXSP*0/
      DATA DLOW/MAXSP*0.0/
      DATA DHI/MAXSP*99.0/
      RETURN
      END
