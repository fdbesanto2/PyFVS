      SUBROUTINE CROWN
      use prgprm_mod
      implicit none
C----------
C EM $Id:
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
C  ROUTINE IS CALLED FROM **CRATET** TO DUB MISSING VALUES, AND BY
C  **TREGRO** TO COMPUTE CHANGE DURING REGULAR CYCLING.  ENTRY
C  **CRCONS** IS CALLED BY **RCON** TO LOAD MODEL CONSTANTS THAT ARE
C  SITE DEPENDENT AND NEED ONLY BE RESOLVED ONCE.  A CALL TO **DUBSCR**
C  IS ISSUED TO DUB CROWN RATIO WHEN DBH IS LESS THAN 3 INCHES.
C  PROCESSING OF CROWN CHANGE FOR SMALL TREES IS CONTROLLED BY
C  **REGENT**.
C----------
C  WHITEBARK PINE (WB) USES COEFFICIENTS FROM WESTERN LARCH
C  OTHER SOFTWOODS (OS) ARE REALLY COEFFEICIENTS FOR MOUNTAIN HEMLOCK
C
C  SPECIES EXPANSION:
C  LIMBER PINE (LM) USES IE-LM COEFFICIENTS WHICH ARE ORIGINALLY FROM TT
C  SUBALPINE LARCH (LL) USES IE-AF COEFFICIENTS
C  ROCKY MTN JUNIPER (RM) USES IE-JU COEFFICIENTS WHICH ARE ORIGINALLY FROM CR
C  GREEN ASH (GA), BLACK COTTONWOOD (CW), BALSAM POPLAR (BA), PLAINS COTTONWOOD
C    (PW), NARROWLEAF COTTONWOOD (NC), AND OTHER HARDWOODS (OH) USE IE-CO
C    COEFFICIENTS WHICH ARE ORIGINALLY FROM CR
C  QUAKING ASPEN (AS) AND PAPER BIRCH (PB) USE IE-AS WHICH ARE ORIGINALLY FROM UT
C----------
COMMONS
      INCLUDE 'CALCOM.F77'
C
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
      INCLUDE 'GGCOM.F77'
C
C----------
      EXTERNAL RANN
      LOGICAL DEBUG,NIVAR,CRVAR,UTTVAR,LPIJU,EMVAR
      REAL PARM(14)
      INTEGER MAPHAB(30)
      REAL CRHAB(14)
      REAL CRNEW(MAXTRE),WEIBA(MAXSP),WEIBB0(MAXSP),
     & WEIBB1(MAXSP),WEIBC0(MAXSP),WEIBC1(MAXSP),C0(MAXSP),C1(MAXSP),
     & CRNMLT(MAXSP),DLOW(MAXSP),DHI(MAXSP),PRM(5)
      INTEGER ISORT(MAXTRE),MYACTS(1),ICFLG(MAXSP)
      REAL RDM,OBA,XCRCON,DCRCON,RELSDI
      REAL ACRNEW,A,B,C,D,H,BARK,HF,CL,CR,SCALE,X,RNUMB,CRHAT
      INTEGER ISPC,I1,I2,I3,IITRE,J,I,JJ,NTODO,NP,IACTK
      INTEGER IDATE,IDT,ISPCC,IGRP,IULIM,IG,IGSP,J1,ICRI
      REAL CRSD,X1,X2,RDM1,BRATIO,PCTHAT,DIFF,P,PCR,EXPPCR,EXPDCR
      REAL DCR,CHG,PDIFPY,XCR,BACHLO,CRLN,CRMAX,HN,HD,TPCCF,TPCT
C----------
C  SPECIES ORDER:
C   1=WB,  2=WL,  3=DF,  4=LM,  5=LL,  6=RM,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=GA, 12=AS, 13=CW, 14=BA, 15=PW, 16=NC,
C  17=PB, 18=OS, 19=OH
C
C  SPECIES EXPANSION
C  LM USES IE LM (ORIGINALLY FROM TT VARIANT)
C  LL USES IE AF (ORIGINALLY FROM NI VARIANT)
C  RM USES IE JU (ORIGINALLY FROM UT VARIANT)
C  AS,PB USE IE AS (ORIGINALLY FROM UT VARIANT)
C  GA,CW,BA,PW,NC,OH USE IE CO (ORIGINALLY FROM CR VARIANT)
C----------
      DATA MYACTS/81/
C----------
C  DATA STATEMENTS FROM IE/NI VARIANT SPECIES 9
C----------
      DATA PARM/
     & -0.00190, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.23372, 0.0, 0.0,
     & -0.28433, 0.001903, 0.0/
C
      DATA MAPHAB/13*2,3,4*4,5,6,6,7,6,1,8,1,9,2*10,6/
C
      DATA CRHAB/
     & 0.09453, -0.07740, 0.07113, 0.2039, 0.06176, 0.1513, 0.09086,
     & 0.1580, 0.09229, 0.01551, 4*0.0/
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
C
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE CROWN  CYCLE =',I5)
      IF(DEBUG) WRITE(JOSTND,9000) BA, RELDEN, RELDM1
 9000 FORMAT(' IN CROWN, BA=',F7.3,'  RELDEN=',F7.3,'  RELDM1=',F7.3)
C
C INITIALIZE CROWN VARIABLES TO BEGINNING OF CYCLE VALUES.
C
      IF(LSTART)THEN
        DO 10 JJ=1,MAXTRE
        CRNEW(JJ)=0.0
        ISORT(JJ)=0
   10   CONTINUE
      ENDIF
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
      EMVAR = .FALSE.
      NIVAR = .FALSE.
      CRVAR = .FALSE.
      UTTVAR= .FALSE.
      LPIJU = .FALSE.
      IF(ISPC.EQ.5)THEN
        NIVAR=.TRUE.
      ELSEIF(ISPC.EQ.11 .OR. (ISPC.GE.13 .AND. ISPC.LE.16) .OR.
     &  ISPC.EQ.19)THEN
        CRVAR=.TRUE.
      ELSEIF(ISPC.EQ.6)THEN
        LPIJU=.TRUE.
      ELSEIF(ISPC.EQ.4 .OR. ISPC.EQ.12 .OR. ISPC.EQ.17)THEN
        UTTVAR=.TRUE.
      ELSE
        EMVAR=.TRUE.
      ENDIF
C
      XCRCON=0.
      DCRCON=0.
      IF(NIVAR)THEN
        XCRCON = CRCON(ISPC) + PARM(1)*BA + PARM(2)*BA*BA +
     &  PARM(3)*ALOG(BA) + PARM(4)*RELDEN + PARM(5)
     &  *RELDEN*RELDEN + PARM(6)*ALOG(RELDEN)
      ENDIF
C----------
C  IF DUBBING MISSING CROWN RATIOS, BYPASS ASSIGNMENT OF DCRCON.
C----------
      IF(LSTART) GO TO 30
      IF(NIVAR)THEN
        DCRCON = CRCON(ISPC) + PARM(1)*OBA + PARM(2)*OBA*OBA +
     &  PARM(3)*X1 + PARM(4)*RDM1 + PARM(5)*RDM1
     &  *RDM1 + PARM(6)*X2
      ENDIF
C----------
C  WRITE DEBUG INFO (CONSTANT TERMS) IF DESIRED
C----------
   30 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9001) ISPC, XCRCON, DCRCON
 9001 FORMAT(' SPECIES: ',I2,' - XCRCON = ',F10.3,', DCRCON = ',F10.3)
C----------
C ESTIMATE MEAN CROWN RATIO FROM SDI, AND ESTIMATE WEIBULL PARAMETERS
C----------
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
C  FOR EM, AND TT AND UT SPECIES, BRANCH TO 58 IF D < 1 IN.
C  "ELSE" PORTION APPLIES IF NIVAR IS .TRUE., BRANCH IF D < 3 IN.
C  CASE WHERE CRVAR OR LPIJU IS TRUE BRANCH TO STMT 53 ABOVE.
C----------
      IF(EMVAR .OR. UTTVAR)THEN
         IF(D.LT.1.0.AND.LSTART) GO TO 58
      ELSE
         IF(D.LT.3.0) GO TO 58
      ENDIF
C----------
C  CALCULATE THE PREDICTED CURRENT CROWN RATIO
C----------
      IF(EMVAR .OR. UTTVAR)THEN
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
      ENDIF
C---------
C  THE FOLLOWING LOGIC IS USED ONLY BY ORIGINAL NI SPECIES
C  BYPASS CROWN CHANGE CALCULATION IF CROWN RATIO WAS ASSIGNED
C  THIS CYCLE IN REGENT.
C----------
      IF(NIVAR)THEN
        IF(.NOT.LSTART .AND. D-DG(I)/BARK .LT.3.0) GO TO 60
        P=PCT(I)
        IF(P.LT.0.01)P=0.01
C----------
C  CALCULATE THE PREDICTED CURRENT CROWN RATIO
C----------
        PCR = XCRCON + PARM(7)*D + PARM(8)*D*D + PARM(9)*ALOG(D) +
     &  PARM(10)*H + PARM(11)*H*H + PARM(12)*ALOG(H) +
     &  PARM(13)*P + PARM(14)*ALOG(P)
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
        DCR = DCRCON + PARM(7)*D + PARM(8)*D*D + PARM(9)*ALOG(D) +
     &  PARM(10)*H + PARM(11)*H*H + PARM(12)*ALOG(H) +
     &  PARM(13)*P + PARM(14)*ALOG(P)
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
          ICRI=ICR(I)+CRNMLT(ISPC)*CHG*100.0+0.50005
        ELSE
          ICRI=ICR(I)+CHG*100.0+0.50005
        ENDIF
        IF ((DGSD.LT.1.0).OR.(.NOT.LSTART)) GO TO 51
        XCR=ICRI
        ICRI=BACHLO(XCR,CRSD,RANN)
   51   CONTINUE
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
C CALC CROWN LENGTH NOW
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
      IF((EMVAR .OR. UTTVAR) .AND. ICR(I).NE.0)GOTO 60
      TPCT = PCT(I)
      TPCCF = PCCF(IITRE)
      CALL DUBSCR(ISPC,D,H,CR,TPCT,TPCCF)
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
      IF(NIVAR)THEN
        IF((ICRI.LT.5).AND.(CRNMLT(ISPC).EQ.1)) ICRI=5
      ELSE
        IF (ICRI .LT. 10.AND.CRNMLT(ISPC).EQ.1.0) ICRI=10
        IF(ICRI .LT. 1)ICRI = 1
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
      TPCT=PCT(I)
      IITRE=ITRE(I)
      TPCCF=PCCF(IITRE)
C---------
C  SET UP LOGICAL VARIABLES DEPENDING UPON VARIANT SPECIES CAME FROM
C---------
      EMVAR = .FALSE.
      NIVAR = .FALSE.
      CRVAR = .FALSE.
      UTTVAR= .FALSE.
      LPIJU = .FALSE.
      IF(ISPC.EQ.5)THEN
        NIVAR=.TRUE.
      ELSEIF(ISPC.EQ.11 .OR. (ISPC.GE.13 .AND. ISPC.LE.16) .OR.
     &  ISPC.EQ.19)THEN
        CRVAR=.TRUE.
      ELSEIF(ISPC.EQ.6)THEN
        LPIJU=.TRUE.
      ELSEIF(ISPC.EQ.4 .OR. ISPC.EQ.12 .OR. ISPC.EQ.17)THEN
        UTTVAR=.TRUE.
      ELSE
        EMVAR=.TRUE.
      ENDIF
C
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
        CALL DUBSCR(ISPC,D,H,CR,TPCT,TPCCF)
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

      ENTRY CRCONS
C----------
C  ENTRY POINT FOR LOADING CROWN RATIO MODEL COEFFICIENTS THAT ARE
C  SITE DEPENDENT AND REQUIRE ONE TIME RESOLUTION.  ITYPE INDEXES
C  HABITAT TYPE (CARRIED IN /PLOT/ COMMON AREA), CRHAB CONTAINS HABITAT
C  INTERCEPTS BY HABITAT TYPE BY SPECIES, AND MAPCR MAPS HABITAT TYPE
C  ONTO HABITAT CLASS FOR EACH SPECIES.
C
C SPECIES ORDER
C   1=WB,  2=WL,  3=DF,  4=LM,  5=LL,  6=RM,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=GA, 12=AS, 13=CW, 14=BA, 15=PW, 16=NC,
C  17=PB, 18=OS, 19=OH
C----------
C
C LOAD WEIBULL 'A' PARAMETER BY SPECIES
C
      DATA WEIBA/3*0.0, 1.0, 15*0.0/
C
C LOAD WEIBULL 'B' PARAMETER EQUATION CONSTANT COEFFICIENT
C
      DATA WEIBB0/  0.11035,  0.11035,  0.14652, -0.82631,      0.0,
     &        0.0, -0.00359,  0.67059,  0.73693,  0.02663,      0.0,
     &   -0.08414,      0.0,      0.0,      0.0,      0.0, -0.08414,
     &    0.11035,      0.0/
C
C LOAD WEIBULL 'B' PARAMETER EQUATION SLOPE COEFFICIENT
C
      DATA WEIBB1/  1.10085,  1.10085,  1.09052,  1.06217,      0.0,
     &        0.0,  1.12728,  0.99349,  0.98414,  1.11477,      0.0,
     &    1.14765,      0.0,      0.0,      0.0,      0.0,  1.14765,
     &    1.10085,      0.0/
C
C LOAD WEIBULL 'C' PARAMETER EQUATION CONSTANT COEFFICIENT
C
      DATA WEIBC0/  0.02774,  0.02774,  1.04746,  3.31429,      0.0,
     &        0.0,  2.60377, -4.25938, -4.16681,  2.95048,      0.0,
     &    2.77500,      0.0,      0.0,      0.0,      0.0,  2.77500,
     &    0.02774,      0.0/
C
C LOAD WEIBULL 'C' PARAMETER EQUATION SLOPE COEFFICIENT
C
      DATA WEIBC1/  0.35524,  0.35524,  0.39752,      0.0,      0.0,
     &        0.0,      0.0,  1.35687,  1.33779,      0.0,      0.0,
     &        0.0,      0.0,      0.0,      0.0,      0.0,      0.0,
     &    0.35524,      0.0/
C
C LOAD CR=F(SDI) EQUATION CONSTANT COEFFICIENT
C
      DATA C0/      5.68625,  5.68625,  5.92714,  6.19911,      0.0,
     &        0.0,  5.05870,  7.41093,  7.36476,  5.61047,      0.0,
     &    4.01678,      0.0,      0.0,      0.0,      0.0,  4.01678,
     &    5.68625,      0.0/
C
C LOAD CR=F(SDI) EQUATION SLOPE COEFFICIENT
C
      DATA C1/     -0.04470, -0.04470, -0.03346, -0.02216,      0.0,
     &        0.0, -0.03307, -0.03467, -0.03761, -0.03557,      0.0,
     &   -0.01516,      0.0,      0.0,      0.0,      0.0, -0.01516,
     &   -0.04470,      0.0/
C
C LOAD OTHER MISCELLANEOUS CONSTANTS
C
      DATA CRNMLT/MAXSP*1.0/
      DATA ICFLG/MAXSP*0/
      DATA DLOW/MAXSP*0.0/
      DATA DHI/MAXSP*99.0/
C
      ICRHAB=MAPHAB(ITYPE)
      DO 80 ISPC=1,MAXSP
      IF(ISPC .EQ. 5)THEN
        CRCON(ISPC)=CRHAB(ICRHAB)
      ELSE
        CRCON(ISPC)=0.
      ENDIF
   80 CONTINUE
C
      RETURN
      END
