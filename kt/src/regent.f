      SUBROUTINE REGENT(LESTB,ITRNIN)
      use prgprm_mod
      implicit none
C----------
C  **REGENT--KT   DATE OF LAST REVISION:   01/11/12
C----------
C  **REGENT** COMPUTES HEIGHT AND DIAMETER INCREMENTS FOR SMALL
C  TREES.  THE HEIGHT INCREMENT MODEL IS APPLIED TO TREES THAT ARE LESS
C  THAN 10 INCHES DBH (5 INCHES FOR LODGEPOLE PINE), AND THE DBH
C  INCREMENT MODEL IS APPLIED TO TREES THAT ARE LESS THAN 3 INCHES DBH.
C  FOR TREES THAT ARE GREATER THAN 2 INCHES DBH (1 INCH FOR LODGEPOLE
C  PINE), HEIGHT INCREMENT PREDICTIONS ARE AVERAGED WITH THE PREDICTIONS
C  FROM THE LARGE TREE MODEL. HEIGHT INCREMENT IS A FUNCTION OF HABITAT
C  TYPE, GEOGRAPHIC LOCATION, SLOPE, SLOPE SQUARED, ASPECT, TREE HEIGHT,
C  TREE HEIGHT SQUARED, TREE HEIGHT SQUARED MODIFICATION,
C  STAND BASAL AREA, BASAL AREA IN LARGER TREES,
C  CROWN RATIO, CROWN RATIO SQUARED, ELEVATION, ELEVATION
C  SQUARED, AND POINT CROWN COMPETITION FACTOR.  DIAMETER IS ASSIGNED
C  FROM A HEIGHT DIAMETER FUNCTION WITH ADJUSTMENTS FOR RELATIVE
C  SIZE AND STAND DENSITY.  INCREMENT IS COMPUTED BY SUBTRACTION.
C  WHEN THE TREE ATTAINS A DBH OF 3.0 INCHES IN A CYCLE, **DUBSCR**
C  IS CALLED TO ASSIGN A CROWN RATIO.  **REGENT IS CALLED FROM
C  **CRATET** DURING CALIBRATION AND FROM **GRINCR** DURING CYCLING.
C  ENTRY **REGCON** IS CALLED FROM **RCON** TO LOAD MODEL PARAMETERS
C  THAT NEED ONLY BE RESOLVED ONCE.
C
C  **REGENT** IS ALSO USED TO PREDICT HEIGHT INCREMENT, DBH AND CROWN
C  RATIO FOR TREES THAT ARE CREATED BY THE REGENERATION ESTABLISHMENT
C  MODEL.  5-YEAR OLD TREES ARE GENERATED BY **ESTAB** AND **REGENT**
C  COMPUTES INCREMENTS FROM AGE 5 TO THE END OF THE CYCLE.
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
      INCLUDE 'HTCAL.F77'
C
      INCLUDE 'MULTCM.F77'
C
      INCLUDE 'ESTCOR.F77'
C
      INCLUDE 'KOTCOM.F77'
C
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES:
C
C   BANEXT -- ESTIMATED STAND BASAL AREA AT START OF EACH HEIGHT INCREMENT
C             PREDICTION SUBCYCLE.
C   CORTEM -- A TEMPORARY ARRAY FOR PRINTING CORRECTION TERMS.
C     KPER -- NUMBER OF YEARS (MAX OF 5) IN EACH HEIGHT INCREMENT PREDICTION
C             SUBCYCLE.
C   NUMCAL -- A TEMPORARY ARRAY FOR PRINTING NUMBER OF HEIGHT
C             INCREMENT OBSERVATIONS BY SPECIES.
C   RDNEXT -- RELATIVE DENSITY (CCF) AT START OF EACH HEIGHT INCREMENT
C             PREDICTION SUBCYCLE.
C    RHCON -- CONSTANT, BY SPECIES, FOR THE HEIGHT INCREMENT MODEL.
C             INCLUDES EFFECTS OF HABITAT TYPE, LOCATION, SLOPE, ASPECT,
C             ELEVATION, CROWN RATIO, AND BRUSH AS LOADED IN RCON.
C     RHLH -- THE COEFFICIENTS FOR EACH SPECIES FOR THE LN(HEIGHT)
C             TERM IN THE HEIGHT INCREMENT MODEL.
C    RHBAL -- THE COEFFICIENTS FOR EACH SPECIES FOR THE BAL TERM
C             IN THE HEIGHT INCREMENT MODEL.
C     RHBA -- THE COEFFICIENTS FOR EACH SPECIES FOR THE BA TERM
C             IN THE HEIGHT INCREMENT MODEL.
C     HCON -- COEFFICIENT FOR THE HEIGHT TERM IN THE LINEAR DIAMETER
C             DUBBING FUNCTION.
C     DCON -- CONSTANT TERM FOR THE LINEAR DIAMETER DUBBING FUNCTION.
C     XMAX -- UPPER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM SMALL AND LARGE TREE MODELS
C             ARE AVERAGED.
C     XMIN -- LOWER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM THE SMALL AND LARGE TREE
C             ARE AVERAGED.
C   HT2MOD -- FACTOR ADJUSTING THE HEIGHT SQUARED TERM IN HEIGHT
C             INCREMENT EQUATION.
C----------
      EXTERNAL RANN
      LOGICAL DEBUG,LESTB,LSKIPH
      REAL CORTEM(MAXSP)
      INTEGER NUMCAL(MAXSP)
      REAL RHLH(MAXSP),RHSC(MAXSP)
      REAL XMAX(MAXSP),XMIN(MAXSP),HCON(MAXSP),RHBAL(MAXSP)
      REAL RHHAB(6,MAXSP)
      INTEGER MAPHAB(175,MAXSP)
      REAL HTFOR(5,MAXSP),DIAM(MAXSP)
      INTEGER MAPLOC(10,MAXSP)
      REAL RHBA(MAXSP),HTSLOP(MAXSP),HTCASP(MAXSP)
      REAL HTEL(MAXSP),HTSLSQ(MAXSP),HTCR(MAXSP),HTCR2(MAXSP)
      REAL HTH2(MAXSP),HTPCC1(MAXSP),HT2MOD(MAXSP),HTSASP(MAXSP)
      REAL BANEXT(10),RDNEXT(10)
      INTEGER KPER(10)
      REAL RHCCF(MAXSP),RHGL(3),DCON(MAXSP)
      REAL H1,BAL,BALMH,RELH,DADJ,PPSBAC,PPCCFC,PPBALC,PPCCF,PPBAL
      REAL XPPMLT,HTGRL,H2,DGJ,H,HK,HTGR1,ZZRAN,HTGR,XWT,DK,DGK,BARK
      REAL DDS,SCALE2,DDS2,DG2,DNEW,TEMCR,CRLN,CRMAX,SCALE3,CORNEW
      REAL CR,RAN,R,AH,DELMAX,BAJ,RDJ,ALBA,XRHGRO,XRDGRO,CON,BH
      REAL HTHS2,HTCRS,HTCRS2,BBA,BCCF,RHCONS,BBALMH,XMX,XMN,D
      REAL DUM1,HTPC1,PCCF1,TEMBA,TEMCCF,TEMAHT,SCALE,D1,P,D2,B1,B2
      REAL CW,C1,C2,BI,CI,PN,BAYR,CCFYR,BBAL,BACON,HSIGMA,REGYR
      REAL BRATIO,BACHLO,SNP,SNX,SNY,BHAB,BLH,EDH,TERM
      REAL RSAB2,RSAB1,RSAB0
      INTEGER ITRNIN,I,NTYR,IYR,NPER,ITOT,N,J,IS,K,NYR,IPCCF,KY,ISPC
      INTEGER I1,I2,I3,L,IREFI,KOUT,ISPEC,KK,IRHFOR
      CHARACTER SPEC*2
C----------
C  DATA STATEMENTS.
C----------
      DATA DIAM/
     &   0.4, 3*0.3, 2*0.2, 0.4, 2*0.3, 0.5, 0.2/
      DATA DCON/
     &   -.145707,-.111929,-.127690,-.125198,-.178162,-.233566,
     &   -.010818,-.186874,-.158870,-.185011,0.0/
      DATA HCON/
     &   .125404,.098451,.115066,.128790,.129191,.143211,.090927,
     &   .131209,.128174,.141907,0.0/
      DATA RHBAL/
     &  -0.002569,.002745,.002367,.000683,6*0.0,-0.25349/
      DATA  RHLH/
     &  .233302,.187195,.185496,.192256,.126835,.083622,.175631,.160429,
     &  .169834,.387617,.2354  /
      DATA RHCCF/
     &  10*0.0,-.00391/
      DATA HTH2/
     &  -.007483,-.005570,-.005958,-.006796,-.004391,-.002450,-.004546,
     &  -.005592,-.005955,-.015505,.000000/
      DATA HT2MOD/
     &  0.5,0.4,0.5,0.5,0.6,0.6,0.7,0.5,0.5,0.5,1.0/
      DATA RHBA/
     &  -.225869,-.612994,-.580046,-.303384,-.310048,-.188838,-.523915,
     &  -.270415,-.337342,-.259310,.000000/
      DATA HTCR/
     &  -.037519,1.793489,.416130,1.384217,.802352,.708060,.771466,
     &  -.520312,-.274359,2.976688,.000000/
      DATA HTCR2/
     &  1.895808,1.713339,1.070272,.000000,.343107,.231768,2.223783,
     &  1.859532,1.212637,-.803694,.000000/
      DATA HTPCC1/
     &  .002726,.001935,.002364,.001374,.000325,.000516,.002926,
     &  .001409,.001964,.003596,.000000/
      DATA XMAX/6*10.0,5.0,4*10.0/,XMIN/6*2.0,1.0,4*2.0/
      DATA REGYR/5.0/,HSIGMA/0.59/,BACON/0.005454154/
C----------
C  CHECK FOR DEBUG.
C----------
      CALL DBCHK (DEBUG,'REGENT',6,ICYC)
C----------
C  THE SMALL TREE HEIGHT INCREMENT MODEL IS BASED ON 5-YEAR INCREMENT DATA.
C  TO AVOID BIAS, PREDICTIONS ARE MADE FOR SUBCYCLES THAT ARE LESS THAN OR
C  EQUAL TO 5 YEARS IN LENGTH.  THE FOLLOWING CODE DETERMINES THE NUMBER
C  AND LENGTH OF SUBCYCLES FROM CYCLE LENGTH.
C----------
      LSKIPH=.FALSE.
      DO 1 I=1,10
      KPER(I)=0
      BANEXT(I)=0.0
      RDNEXT(I)=0.0
    1 CONTINUE
      NTYR=FINT
      IF(LSTART) NTYR=IFINTH
      IF(LESTB) NTYR=NTYR-5
      IF(LESTB.AND.NTYR.LE.0) LSKIPH=.TRUE.
      IYR=REGYR
      NPER=NTYR/IYR
      IF(DEBUG) WRITE(JOSTND,*)'ENTERING REGENT','NPER=',NPER
      IF(MOD(NTYR,IYR).NE.0) NPER=NPER+1
      ITOT=NTYR
      N=NPER
      DO 2 I=1,NPER
      IF(N.EQ.1) GO TO 3
      KPER(I)=ITOT/N
      ITOT=ITOT-KPER(I)
      N=N-1
    2 CONTINUE
    3 CONTINUE
      IF(NPER.GT.0) KPER(NPER)=ITOT
C----------
C  LOAD TEMPORARY VARIABLES WITH AFTER THINNING BA, CCF, AND TOPHT.
C----------
      TEMBA  = ATBA
      IF(ATBA .LE. 0.)TEMBA=BA
      TEMCCF = ATCCF
      IF(ATCCF .LE. 0.)TEMCCF=RELDEN
      TEMAHT = ATAVH
C----------
C  IF THIS IS THE FIRST ENTRY, BRANCH TO THE CALIBRATION SECTION.
C----------
      IF(LSTART) GOTO 40
C----------
C  LOAD MULTIPLIERS.
C----------
      CALL MULTS (3,IY(ICYC),XRHMLT)
      CALL MULTS(6,IY(ICYC),XRDMLT)
      SCALE=YR/FINT
      IF(DEBUG) WRITE(JOSTND,8996) LESTB,LSKIPH,ITRN,ITRNIN,SCALE
 8996 FORMAT('IN REGENT, LESTB = ',L1,', LSKIPH = ',L1,
     &  ', ITRN = ',I4,', ITRNIN = ',I4,', SCALE = ',F6.3)
      IF (ITRN.LE.0) RETURN
C----------
C  ESTIMATE THE CONTRIBUTION TO STAND BASAL AREA AND CCF FOR LARGE TREES AT
C  THE START OF EACH PROJECTION SUBCYCLE.  IF CALLED FROM **ESTAB**, BRANCH
C  TO STATEMENT 9 AND INTERPOLATE FROM OLD AND NEW DENSITY VALUES.
C  OTHERWISE, 10-YEAR CHANGE IS COMPUTED FROM PREDICTED DBH INCREMENT AND
C  ANNUALIZED.  THEN, ANNUAL RATE IS MULTIPLIED BY SUBCYCLE LENGTH TO
C  DETERMINE CONTRIBUTION FOR EACH SUBCYCLE.  A ONE PERCENT ANNUAL RATE
C  OF MORTALITY IS ASSUMED.  CONTRIBUTIONS OF SMALL TREES ARE COMPUTED AS
C  INCREMENT PREDICTIONS ARE MADE FOR PRECEDING SUBCYCLE.
C----------
      IF(LESTB) GO TO 8
      DO 4 J=1,NPER
      BANEXT(J)=BA
      RDNEXT(J)=RELDEN
    4 CONTINUE
      IF(NPER.EQ.1) GO TO 11
      DO 6 I=1,ITRN
      D1=DBH(I)
      IF(D1.LT.3.0) GO TO 6
      IS=ISP(I)
      P=PROB(I)
      D2=D1+DG(I)/BRATIO(IS,D1,HT(I))
      B1=BACON*D1*D1
      B2=BACON*D2*D2
      CALL CCFCAL(IS,D1,HT(I),ICR(I),P,.FALSE.,C1,CW,1)
      CALL CCFCAL(IS,D2,HT(I),ICR(I),P,.FALSE.,C2,CW,1)
      BI=(B2-B1)/10.0
      CI=(C2-C1)/10.0
      K=0
      DO 5 J=2,NPER
      K=K+KPER(J-1)
      PN=P*0.985**K
      RDNEXT(J)=RDNEXT(J)+K*CI/P*PN
      BANEXT(J)=BANEXT(J)+K*BI*PN
    5 CONTINUE
    6 CONTINUE
      GO TO 11
C----------
C  IF CALLED FROM **ESTAB**, DIAMETERS AND DENSITY STATISTICS HAVE
C  BEEN UPDATED AND DENSITIES CORRESPONDING TO BEGINNINGS OF SUBCYCLES
C  CAN BE INTERPOLATED FROM DIFFERENCE BETWEEN OLD AND NEW STATS.  THE
C  TREES ARE SENT TO REGENT WITH A HEIGHT CORRESPONDING TO 5 YEARS AFTER
C  THE START OF THE CYCLE.
C----------
    8 CONTINUE
      BAYR=0.0
      CCFYR=0.0
      IF(LSKIPH) GO TO 9
      BAYR=(BA-TEMBA)/ITOT
      CCFYR=(RELDEN-TEMCCF)/ITOT
    9 CONTINUE
      NYR=5
      DO 10 J=1,NPER
      RDNEXT(J)=TEMCCF+NYR*CCFYR
      BANEXT(J)=TEMBA+NYR*BAYR
      NYR=NYR+KPER(J)
   10 CONTINUE
   11 CONTINUE
C----------
C  STORE INITIAL HEIGHTS IN WK3; DUB CROWN RATIO FOR NEWLY ESTABLISHED
C  SEEDLINGS.
C----------
      DO 13 I=1,ITRN
      IF(LESTB.AND.I.GE.ITRNIN) THEN
        IPCCF=ITRE(I)
        CR = 0.89722 - 0.0000461*PCCF(IPCCF)
   12   CONTINUE
        RAN = BACHLO(0.0,1.0,RANN)
        IF(RAN .LT. -1.0 .OR. RAN .GT. 1.0) GO TO 12
        CR = CR + 0.07985 * RAN
        IF(CR .GT. .90) CR = .90
        IF(CR .LT. .20) CR = .20
        ICR(I)=(CR*100.0)+0.5
      ENDIF
      WK3(I)=HT(I)
   13 CONTINUE
C----------
C  DELMAX IS USED TO COMPUTE A DENSITY-DEPENDENT ADJUSTMENT FOR
C  THE HEIGHT-DIAMETER FUNCTION.  DELMAX IS BASED ON AVERAGE HEIGHT AND
C  CCF AT THE BEGINNING OF THE CYCLE AND DOES NOT VARY BY SUBCYCLE.
C----------
      IF(LESTB) THEN
        R=TEMCCF
        AH=TEMAHT
      ELSE
        R=RELDEN
        AH=AVH
      ENDIF
      DELMAX=(AH/36.0)*(0.01232*R-1.75)
      IF(DELMAX.GT.0.0) DELMAX=0.0
      KY=0
      IF(DEBUG) WRITE(JOSTND,8995) R,AH,DELMAX
 8995 FORMAT('R = ',F10.4,', AH = ',F10.4,', DELMAX = ',F10.4)
C----------
C  ENTER LOOP FOR NEXT SUBCYCLE.
C----------
      DO 17 J=1,NPER
      KY=KY+KPER(J)
      BAJ=BANEXT(J)
      RDJ=RDNEXT(J)
      ALBA=0.0
      IF(BAJ.GT. 0.0) ALBA=ALOG(BAJ)
C----------
C  PROCESS ALL TREES WITHIN THIS SUBCYCLE IN SPECIES ORDER.  LOAD
C  SPECIES DEPENDENT CONSTANTS.
C----------
      DO 16 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 16
      I2=ISCT(ISPC,2)
      XRHGRO=XRHMLT(ISPC)
      XRDGRO=XRDMLT(ISPC)
      CON=1.0
      IF (LRCOR2 .AND. RCOR2(ISPC) .GT. 0.0) CON=RCOR2(ISPC)
      CON=CON*EXP(HCOR(ISPC))
      BH=RHLH(ISPC)
      HTHS2=HTH2(ISPC)*HT2MOD(ISPC)
      HTCRS=HTCR(ISPC)
      HTCRS2=HTCR2(ISPC)
      BBA=RHBA(ISPC)
      BCCF=RHCCF(ISPC)
      BBAL=RHBAL(ISPC)
      RHCONS=RHCON(ISPC)
      IF(ISPC .EQ. 11) THEN
       BBALMH=BBAL
       BBAL=0.0
      ELSE
       BBALMH=0.0
      ENDIF
      XMX=XMAX(ISPC)
      XMN=XMIN(ISPC)
C----------
C  PROCESS NEXT TREE RECORD.  STORE INTERMEDIATE HEIGHTS IN WK3.
C----------
      DO 15 I3=I1,I2
C----------
C  BYPASS INCREMENT CALCULATION IF DBH IS GREATER THAN XMX OR IF
C  CALL IS FROM **ESTAB** AND TREE SUBSCRIPT IS LESS THAN ITRNIN.
C----------
      I=IND1(I3)
      D=DBH(I)
C----------
C  THE FOLLOWING CODE SEGMENT SETS DUM1 TO UNITY FOR A MANAGED STAND
C----------
      DUM1 = 0.0
      IF(MANAGD .EQ. 1) DUM1 = 1.0
      HTPC1=HTPCC1(ISPC)*DUM1
      IPCCF=ITRE(I)
      PCCF1=PCCF(IPCCF)
      CR=ICR(I)/100.
      IF(D.GE.XMX) GO TO 15
      IF(LESTB .AND. I.LT.ITRNIN) GO TO 15
      P=PROB(I)
      H1=WK3(I)
      BAL=BAJ*(100.0-PCT(I))*0.01
      BALMH=BAJ*(100.0-PCT(I))*0.0001
      CALL CCFCAL(ISPC,D,H1,ICR(I),P,.FALSE.,C1,CW,1)
      B1=BACON*D*D
C----------
C  COMPUTE ADJUSTMENT FOR BIAS, DENSITY, AND RELATIVE SIZE.
C----------
      RELH=(H1-4.5)/(AH-4.5)
      IF(RELH.GT.1.0) RELH=1.0
      IF(RELH.LT.0.0) RELH=0.0
      DADJ=DELMAX*RELH*RELH - 2.0*DELMAX*RELH + 0.65
      IF(DEBUG)WRITE(JOSTND,*)'CR=',CR,' BAJ=',BAJ,' BAL=',BAL,
     &   ' RHCONS=',RHCONS,' BH=',BH,' H1=',H1,' HTHS2=',HTHS2,
     &   ' BBAL=',BBAL,' BBA=',BBA,' BAJ=',BAJ,
     &   ' HTPC1=',HTPC1,' PCCF1=',PCCF1,' HTCRS=',HTCRS,
     &   ' HTCRS2=',HTCRS2,' ALBA=',ALBA
C----------
C     GET A MULTIPLIER FOR THIS TREE FROM PPREGT TO ACCOUNT FOR
C     THE DENSITY EFFECTS OF NEIGHBORING TREES.
C
      PPSBAC=BBA
      PPCCFC=HTPC1
      PPBALC=BBAL
      PPCCF=PCCF1
      PPBAL=BAL
      XPPMLT=0.
      IF(ISPC.EQ.11)THEN
        PPCCFC=BCCF
        PPBALC=BBALMH
        PPSBAC=0.
        PPCCF=RDJ
        PPBAL=BALMH
        XPPMLT=1.
      ENDIF
      CALL PPREGT (XPPMLT,PPCCF,PPBAL,ALBA,PPCCFC,PPBALC,PPSBAC,ISPC)
C----------
C----------
C  COMPUTE HEIGHT INCREMENT.  STORE UPDATED HEIGHT IN WK3.
C----------
      IF(ISPC .NE. 11) THEN
        HTGRL=RHCONS+BH*H1+HTHS2*H1*H1+BBAL*BAL+BBA*ALBA+HTPC1*PCCF1
     &    +  (HTCRS + HTCRS2*CR)*CR
      IF(HTGRL .LT. 0.0) HTGRL=0.0
        H2=H1+HTGRL*(FLOAT(KPER(J))/REGYR)*XRHGRO*CON+XPPMLT
      ELSE
        HTGRL=EXP(RHCONS+BH*ALOG(H1)+BCCF*RDJ+BBALMH*BALMH + HCOR(ISPC))
      IF(HTGRL .LT. 0.0) HTGRL=0.0
        H2=H1+HTGRL*(FLOAT(KPER(J))/REGYR)*XRHGRO*XPPMLT
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)'HTGRL=',HTGRL,' H2=',H2,' REGYR=',
     &    REGYR,' XRHGRO=',XRHGRO,' CON',CON,' XPPMLT=',XPPMLT
      WK3(I)=H2
C----------
C  UPDATE DENSITY FOR NEXT SUBCYCLE.  IF ONLY ONE SUBCYCLE OR
C  IF INITIAL DBH IS GREATER THAN 3 INCHES, BYPASS DENSITY UPDATE.
C  DIAMETER IS ADJUSTED FOR DENSITY AND USER-SUPPLIED MULTIPLIER.
C  INCREMENT IS DETERMINED FROM THE DIFFERENCE BETWEEN COMPUTED
C  DIAMETERS AND IS BOUNDED TO BE GREATER THAN OR EQUAL TO ZERO.
C----------
      D2=D
      IF(J.EQ.NPER.OR.D.GE.3.0) GO TO 14
      IF(H2.LE.4.5) GO TO 14
      D1=DIAM(ISPC) + DADJ
C----------
C  DUB DIAMETERS BY LINEAR FUNCTION OF HEIGHT
C  EXCEPT WHEN SPECIES IS MOUNTAIN HEMLOCK, THEN USE ORIGINAL NI
C  EQUATION.
C----------
      IF (ISPC .EQ. 11) THEN
        IF(H1.GT.4.5) D1=.0729*(H1-4.5)**1.1988 + DADJ
        D2=.0729*(H2-4.5)**1.1988 + DADJ
      ELSE
        IF(H1.GT.4.5) D1=HCON(ISPC)*H1+DCON(ISPC)+DADJ
        D2=HCON(ISPC)*H2+DCON(ISPC)+DADJ
      ENDIF
      DGJ=(D2-D1)*XRDGRO
      IF(DGJ.LT.0.0) DGJ=0.0
      D2=D+DGJ
      IF(DEBUG)WRITE(JOSTND,*)'ISPC=',ISPC,' H1=',H1,
     &   ' D1=',D1,' H2=',H2,' D2=',D2,' DGJ',DGJ,' DADJ=',DADJ,
     &   ' D=',D,' XRDGRO=',XRDGRO
C----------
C  COMPUTE ADJUSTMENT TO STAND BASAL AREA AND CCF FOR NEXT SUBCYCLE.
C  ASSUME A 1.5 PERCENT ANNUAL MORTALITY RATE.
C----------
      CALL CCFCAL(ISPC,D2,H2,ICR(I),P,.FALSE.,C2,CW,1)
      RDNEXT(J+1)=RDNEXT(J+1)+KY*(C2-C1)/10.*0.985**KY
      BANEXT(J+1)=BANEXT(J+1)+(BACON*D2*D2-B1)*P*0.985**KY
      IF(DEBUG) WRITE(JOSTND,8997) I,D2,BANEXT(J+1),RDNEXT(J+1)
 8997 FORMAT(' PDATE DENSITY: TREE = ',I4,', D2 = ',F8.4,
     & ', BANEXT(J+1) = ',F8.2,', RDNEXT(J+1) = ',F8.2)
C----------
C  END OF TREE LOOP WITHIN SPECIES. PRINT DEBUG IF REQUESTED.
C----------
   14 CONTINUE
      IF(.NOT.DEBUG) GO TO 15
      WRITE(JOSTND,8999) J,KPER(J),ISPC,I,H1,H2,RDJ,BBAL,BAL,
     &                   BAJ,PCT(I)
 8999 FORMAT('IN REGENT L1: SUBC=',I2,', KPER=',I2,', SP=',I2,
     &  ', I=',I4,', H1=',F8.4,', H2=',F8.4,/T4,'RDJ=',
     &  F8.4,', BBAL=',F8.4,', BAL=',F8.4,', BAJ=',F8.4,', PCT=',F8.4)
   15 CONTINUE
C----------
C  END OF SPECIES LOOP WITHIN SUBCYCLE
C----------
   16 CONTINUE
C----------
C  END OF SUBCYCLE LOOP.  END OF PERIOD HEIGHT IS STORED IN WK3.
C----------
   17 CONTINUE
C----------
C  AFTER LAST SUBCYCLE, COMPUTE ACTUAL HEIGHT INCREMENT FOR FULL CYCLE BY
C  SUBTRACTION; CONVERT BACK TO LOG SCALE TO ADD IN RANDOM ERROR.
C----------
      DO 30 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 30
      I2=ISCT(ISPC,2)
      XRDGRO=XRDMLT(ISPC)
      XMX=XMAX(ISPC)
      XMN=XMIN(ISPC)
      DO 25 I3=I1,I2
      I=IND1(I3)
      D=DBH(I)
      IF(D.GE.XMX) GO TO 25
      IF(LESTB .AND. I.LT.ITRNIN) GO TO 25
      K=I
      L=0
      H=HT(I)
      CR=FLOAT(ICR(I))/100.
      HK=WK3(I)
C----------
C  IF CALLED FROM **ESTAB** AND TOTAL CYCLE LENGTH IS LESS THAN OR EQUAL
C  TO 5 YEARS, SKIP HEIGHT INCREMENT CALCULATION BUT ASSIGN CR AND DBH.
C----------
      IF(LSKIPH) THEN
         HTG(K)=0
         GO TO 20
      ENDIF
      HTGR1=HK-H
      IF (HTGR1.LT.0.0) HTGR1=0.0
C----------
C  DRAW RANDOM INCREMENT GIVEN EXPECTED VALUE, HTGR, AND STD. DEV.,
C  HSIGMA.  BOUND DRAW TO (-1.5*SD < ZZRAN < 1.0*SD); IF TRIPLING,
C  EACH TRIPLE GETS A NEW RANDOM NUMBER.  DO NOT TRIPLE IF CALLING
C  FROM **ESTAB**.  DO NOT APPLY HEIGHT GROWTH MULTIPLIER; MULTIPLIER
C  WAS USED DURING SUBCYCLING.
C----------
   18 CONTINUE
      ZZRAN=0.0
      IF (DGSD.GE.1.0) ZZRAN = BACHLO(0.0,1.0,RANN)
      IF((ZZRAN .GT. 1.0) .OR. (ZZRAN .LT. -1.5)) GO TO 18
      HTGR = HTGR1+(ZZRAN*HSIGMA)
      IF(HTGR .LT. .15)HTGR=.15
C----------
C  COMPUTE WEIGHTS FOR THE LARGE AND SMALL TREE HEIGHT INCREMENT
C  ESTIMATES.  IF DBH IS LESS THAN OR EQUAL TO XMN OR IF CALLED
C  FROM **ESTAB**, THE LARGE TREE PREDICTION IS IGNORED (XWT=0.0).
C----------
      XWT=0.0
      IF(D.LE.XMN.OR.LESTB) GO TO 19
      XWT=(D-XMN)/(XMX-XMN)
   19 CONTINUE
      HTG(K)=HTGR*(1.0-XWT) + XWT*HTG(K)
      IF(DEBUG)WRITE(JOSTND,*)'XMN=',XMN,' K=',K,' XMX=',XMX,
     &     ' HTGR=',HTGR,' XWT=',XWT,' HTG=',HTG(K)
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((H+HTG(K)).GT.SIZCAP(ISPC,4))THEN
        HTG(K)=SIZCAP(ISPC,4)-H
        IF(HTG(K) .LT. 0.1) HTG(K)=0.1
      ENDIF
C
   20 CONTINUE
C----------
C  ASSIGN DBH AND COMPUTE DBH INCREMENT FOR TREES WITH DBH LESS
C  THAN 3 INCHES.  COMPUTE 10-YEAR DBH INCREMENT REGARDLESS OF
C  PROJECTION PERIOD LENGTH.  BYPASS INCREMENT CALCULATION IF
C  D GE 3.0 INCHES.
C----------
      IF(D.GE.3.0) GO TO 23
C----------
C  COMPUTE ADJUSTMENT FOR BIAS, DENSITY, AND RELATIVE SIZE.
C----------
      RELH=(H-4.5)/(AH-4.5)
      IF(RELH.GT.1.0) RELH=1.0
      IF(RELH.LT.0.0) RELH=0.0
      DADJ=DELMAX*RELH*RELH - 2.0*DELMAX*RELH + 0.65
      D1=DIAM(ISPC) + DADJ
C----------
C  DUB DIAMETERS BY LINEAR FUNCTION OF HEIGHT
C  EXCEPT WHEN SPECIES IS MOUNTAIN HEMLOCK, THEN USE ORIGINAL
C  EQUATION.
C----------
      IF (ISPC .EQ. 11) THEN
        IF (H .GT. 4.5) D1=.0729*(H-4.5)**1.1988 + DADJ
      ELSE
        IF(H .GT. 4.5) D1=HCON(ISPC)*H+DCON(ISPC)+DADJ
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)'ISPC=',ISPC,' I=',I,' D1=',D1
      HK=H+HTG(K)
      IF(HK .LT. 4.5) THEN
        DBH(K)=0.1 + DIAM(ISPC)*.01 + HK*0.001
        DG(K)=0.0
      ELSE
C-----------
C  DUB IN DIAMETERS WITH LINEAR FUNCTION OF HEIGHT.
C  USE ORIGINAL NI EQUATION FOR MOUNTAIN HEMLOCK.
C----------
        IF (ISPC .EQ. 11) THEN
          DK=.0729*(HK-4.5)**1.1988+DADJ
        ELSE
          DK=HCON(ISPC)*HK+DCON(ISPC)+DADJ
        ENDIF
        IF(DK.LT.DIAM(ISPC)) DK=DIAM(ISPC)
        DK=DK+HK*0.001
        IF(DEBUG)WRITE(JOSTND,*)'ISPC=',ISPC,' HK=',HK,
     &   ' DK=',DK
C----------
C       IF CALLING FROM **ESTAB** ASSIGN DIAMETER AND DIAMETER
C       INCREMENT.
C----------
        IF(LESTB) THEN
          DBH(K)=DK
          DG(K)=DK
        ELSE
C----------
C         DIAMETER INCREMENT IS THE DIFFERENCE BETWEEN COMPUTED
C         DIAMETERS.  MULTIPLIER IS APPLIED TO DIAMETER INCREMENT
C         AT THIS POINT.
C----------
          DGK=(DK-D1)*XRDGRO
          IF(DGK.LT.0.0) DGK=0.0
C----------
C         SCALE DIAMETER INCREMENT FOR BARK AND PERIOD LENGTH.
C         IN ORDER TO MAINTAIN CONSISTENCY WITH **GRADD**,
C         ADJUSTMENTS ARE MADE ON THE DDS SCALE.
C----------
          BARK=BRATIO(ISPC,DBH(K),HT(K))
          DG(K)=DGK*BARK
          DDS = DG(K)*(2.0*BARK*D+DG(K))*SCALE
          DG(K)=SQRT((D*BARK)**2.0+DDS)-BARK*D
        ENDIF
        IF((DBH(K)+DG(K)).LT.DIAM(ISPC))THEN
          DG(K)=DIAM(ISPC)-DBH(K)
        ENDIF
      ENDIF
C----------
C  CHECK FOR TREE SIZE CAP COMPLIANCE
C----------
      CALL DGBND(ISPC,DBH(K),DG(K))
C
C----------
C  IF THE TREE WILL ATTAIN A DBH OF 3 OR MORE INCHES THIS CYCLE
C  CALL **DUBSCR** TO ESTIMATE A NEW CROWN RATIO.
C  DIAMETER GROWTH SCALED TO CYCLE LENGTH FOR THIS CALCULATION.
C  MAKE SURE NEW CROWN DOES NOT EXCEED MAX POSSIBLE GIVEN HTG.
C----------
      IF(.NOT.LESTB) THEN
        SCALE2=FINT/YR
        D=DBH(K)
        BARK=BRATIO(ISPC,D,HT(K))
        DDS2=(DG(K)*(2.0*BARK*D+DG(K)))*SCALE2
        DG2=SQRT((D*BARK)**2+DDS2)-BARK*D
        IF (DG2.LT.0.0) DG2=0.0
        DNEW=D+DG2
        IF(DNEW.GE.3.0) THEN
          CALL DUBSCR(ISPC,DNEW,HK,BA,CR)
          TEMCR=CR*100.0+0.5
C
C CALC CROWN LENGTH NOW
C
          IF(ICR(K).EQ.0)GO TO 53
          CRLN=HT(K)*ICR(K)/100.
C
C CALC CROWN LENGTH MAX POSSIBLE IF ALL HTG GOES TO NEW CROWN
C
          CRMAX=(CRLN+HTG(K))/(HT(K)+HTG(K))*100.0
          IF(DEBUG)WRITE(JOSTND,*)'K,HT,HTG,ICR,CRLN,CRMAX= ',
     &    K,HT(K),HTG(K),ICR(K),CRLN,CRMAX
C
C IF NEW CROWN EXCEEDS MAX POSSIBLE LIMIT IT TO MAX POSSIBLE
C
          IF(TEMCR.GT.CRMAX) TEMCR=CRMAX
C
   53     CONTINUE
          ICR(K)= TEMCR
          IF(DEBUG)WRITE(JOSTND,*)'AFTER DUBSCR K,ISPC,DNEW,HK,BA,CR,IC
     &    R= ',K,ISPC,DNEW,HK,BA,CR,ICR(K)
        ENDIF
      ENDIF
   23 CONTINUE
C----------
C  PRINT DEBUG AND RETURN TO PROCESS NEXT TRIPLE OR NEXT TREE.
C----------
      IF(.NOT.DEBUG) GO TO 24
      WRITE(JOSTND,9000) I,K,ISPC,H,HTG(K),HK,DBH(K),DG(K)
 9000 FORMAT('IN REGENT LOOP 2, I=',I4,', K=',I4,', ISPC=',I3,
     &       ', CUR HT=',F7.2,', HT INC=',F7.4/T19,'NEW HT=',F7.2,
     &       ', CUR DBH=',F7.2,', 10-YR DBH INC=',F7.4)
   24 CONTINUE
      IF(LESTB .OR. .NOT.LTRIP .OR. L.GE.2) GO TO 25
      L=L+1
      K=ITRN+2*I-2+L
      GO TO 18
C----------
C  END OF GROWTH PREDICTION LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
   25 CONTINUE
   30 CONTINUE
      RETURN
C----------
C  SMALL TREE HEIGHT CALIBRATION SECTION.
C----------
   40 CONTINUE
      DO 45 ISPC=1,MAXSP
      HCOR(ISPC)=0.0
      CORTEM(ISPC)=1.0
      NUMCAL(ISPC)=0
   45 CONTINUE
      IF (ITRN.LE.0) RETURN
      IF(IFINTH .EQ. 0)  GOTO 100
      IF(DEBUG)WRITE(JOSTND,*)'FINTH=',FINTH
      SCALE3 = REGYR/FINTH
C----------
C  DETERMINE BASAL AREA IN LARGE TREES AT START OF EACH PREDICTION SUBCYCLE.
C----------
      DO 46 J=1,NPER
      BANEXT(J)=TEMBA
      RDNEXT(J)=TEMCCF
   46 CONTINUE
      IF(NPER.EQ.1) GO TO 50
C----------
C  IF THERE IS MORE THAN 1 SUBCYCLE FOR HEIGHT INCREMENT PREDICTION,
C  (IFINTH > 5) ESTIMATE VALUES OF BA AND RELATIVE DENSITY (CCF) AT
C  START OF EACH SUBCYCLE.  10-YEAR CHANGE IS COMPUTED FROM BACKDATED
C  DIAMETER (WK3) AND 10-YEAR DIAMETER INCREMENT COMPUTED DURING CALIBRATION.
C  LINEAR INTERPOLATION IS USED TO ASSIGN VALUES FOR SUBCYCLES.
C----------
      DO 49 I=1,ITRN
      D1=WK3(I)
      IS=ISP(I)
      P=PROB(I)
      D2=WK3(I)+DG(I)/BRATIO(IS,D1,HT(I))
      B1=BACON*D1*D1
      B2=BACON*D2*D2
      CALL CCFCAL(IS,D1,HT(I),ICR(I),P,.FALSE.,C1,CW,1)
      CALL CCFCAL(IS,D2,HT(I),ICR(I),P,.FALSE.,C2,CW,1)
      BI=(B2-B1)/10.0
      CI=(C2-C1)/10.0
      K=0
      DO 48 J=2,NPER
      K=K+KPER(J-1)
      PN=P*0.985**K
      RDNEXT(J)=RDNEXT(J)+K*CI/P*PN
      BANEXT(J)=BANEXT(J)+K*BI*PN
   48 CONTINUE
   49 CONTINUE
   50 CONTINUE
      DO 90 ISPC=1,MAXSP
C----------
C  BEGIN PROCESSING TREE LIST IN SPECIES ORDER.  DO NOT CALCULATE
C  CORRECTION TERMS IF THERE ARE NO TREES FOR THIS SPECIES.
C----------
      ALBA = 0.0
      CORNEW=1.0
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0 .OR. .NOT. LHTCAL(ISPC)) GO TO 90
      I2=ISCT(ISPC,2)
      IREFI=IREF(ISPC)
      N=0
      SNP=0.0
      SNX=0.0
      SNY=0.0
      BHAB=RHCON(ISPC)
      BLH=RHLH(ISPC)
      BCCF=RHCCF(ISPC)
      HTHS2=HTH2(ISPC)*HT2MOD(ISPC)
      BBA=RHBA(ISPC)
      HTCRS=HTCR(ISPC)
      HTCRS2=HTCR2(ISPC)
      BBAL=RHBAL(ISPC)
      IF(ISPC .EQ. 11) THEN
        BBALMH=BBAL
        BBAL=0.0
      ELSE
        BBALMH=0.0
      ENDIF
      CON=1.0
      IF(LRCOR2 .AND. RCOR2(ISPC) .GT. 0.0) CON=RCOR2(ISPC)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES.  IF MEASURED HEIGHT INCREMENT IS
C  LESS THAN OR EQUAL TO ZERO, OR DBH IS GREATER THAN 5.0, THE RECORD
C  WILL BE EXCLUDED FROM THE CALIBRATION.
C----------
      DO 60 I3=I1,I2
      I=IND1(I3)
      H=HT(I)
C----------
C  THE FOLLOWING TWO LINES SETS DUM1 TO UNITY FOR A MANAGED STAND.
C----------
      DUM1 = 0.0
      IF(MANAGD .EQ. 1) DUM1=1.0
      HTPC1=HTPCC1(ISPC)*DUM1
      IPCCF=ITRE(I)
      PCCF1=PCCF(IPCCF)
      CR=ICR(I)/100.
      IF(IHTG.LT.2) H=H-HTG(I)
      IF(DBH(I).GE.5.0.OR.H.LT.0.01) GO TO 60
      IF(HTG(I).LT.0.001) GO TO 60
      HK=H
      DO 55 J=1,NPER
      BAJ=BANEXT(J)
      RDJ=RDNEXT(J)
      IF(BAJ .GT. 0.0) ALBA=ALOG(BAJ)
      BAL=BAJ*(100.0-PCT(I))*0.01
      BALMH=BAJ*(100.0-PCT(I))*0.0001
      IF(ISPC .NE. 11) THEN
         EDH=BHAB + BLH*HK + HTHS2*HK*HK + BBA*ALBA + BBAL*BAL
     &      + HTPC1*PCCF1+(HTCRS+HTCRS2*CR)*CR
      IF(EDH .LT. 0.0) EDH=0.0
         HK=HK+EDH*CON
      ELSE
         EDH=EXP(BHAB+BLH*ALOG(HK)+BCCF*RDJ+BBALMH*BALMH)
         IF(DEBUG)WRITE(JOSTND,*)'BALMH=',BALMH,' RDJ=',RDJ
      IF(EDH .LT. 0.0) EDH=0.0
      HK=HK+EDH
      ENDIF
      IF(DEBUG)WRITE(JOSTND,*)'BHAB=',BHAB,' BLH=',BLH,' HTHS2=',
     &  HTHS2,' PCCF1=',PCCF1,' BBA=',BBA,' BBAL=',BBAL,' HTPC1=',
     &  HTPC1,' HTCRS=',HTCRS,' HTCRS2',HTCRS2,' BCCF',BCCF,' EDH=',
     &  EDH,' HK=',HK,' BAJ=',BAJ,' ht=',HT(I),' BAJ=',BAJ,' BAL=',
     &  BAL,' PCT(I)=',PCT(I)
   55 CONTINUE
      EDH=HK-H
      P=PROB(I)
      TERM=HTG(I)*SCALE3
      SNP=SNP+P
      SNX=SNX+EDH*P
      SNY=SNY+TERM*P
      N=N+1
C----------
C  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG) WRITE(JOSTND,9001) NPLT,I,ISPC,H,DBH(I),ICR(I),
     & PCT(I),TEMCCF,RHCON(ISPC),EDH,TERM
 9001 FORMAT('NPLT=',A26,',  I=',I5,',  ISPC=',I3,',  H=',F6.1,
     & ',  DBH=',F5.1,',  ICR',I5,',  PCT=',F6.1,',  RELDEN=',
     & F6.1 / 12X,'RHCON=',F10.3,',  EDH=',F10.3,', TERM=',F10.3)
C----------
C  END OF TREE LOOP WITHIN SPECIES.
C----------
   60 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9010) ISPC,SNP,SNX,SNY
 9010 FORMAT(/'SUMS FOR SPECIES ',I2,':  SNP=',F10.2,
     & ';   SNX=',F10.2,';   SNY=',F10.2)
C----------
C  COMPUTE CALIBRATION TERMS.  CALIBRATION TERMS ARE NOT COMPUTED
C  IF THERE WERE FEWER THAN NCALHT (DEFAULT=5) HEIGHT INCREMENT
C  OBSERVATIONS FOR A SPECIES.
C----------
      IF(N.LT.NCALHT) GO TO 80
C----------
C  CALCULATE MEANS FOR THE FOR THE GROWTH SAMPLE ON THE
C  NATURAL SCALE.
C----------
      SNX=SNX/SNP
      SNY=SNY/SNP
C----------
C  THE CORRECTION TERM IS THE MEAN OF OBSERVED INCREMENTS
C  DIVIDED BY THE MEAN OF PREDICTED INCREMENTS (NOT THE REGRESSION
C  ESTIMATE USED FOR DIAMETER INCREMENT CALIBRATION).
C----------
      CORNEW=SNY/SNX
      IF(CORNEW.LE.0.0) CORNEW=1.0E-4
      HCOR(ISPC)=ALOG(CORNEW)
C----------
C  TRAP CALIBRATION VALUES OUTSIDE 2.5 STANDARD DEVIATIONS FROM THE
C  MEAN. IF C IS THE CALIBRATION TERM, WITH A DEFAULT OF 1.0, THEN
C  LN(C) HAS A MEAN OF 0.  -2.5 < LN(C) < 2.5 IMPLIES
C  0.0821 < C < 12.1825
C----------
      IF(CORNEW.LT.0.0821 .OR. CORNEW.GT.12.1825) THEN
        CALL ERRGRO(.TRUE.,27)
        WRITE(JOSTND,9194)ISPC,JSP(ISPC),CORNEW
 9194   FORMAT(T28,'SMALL TREE HTG: SPECIES = ',I2,' (',A3,
     &  ') CALCULATED CALIBRATION VALUE = ',F8.2)
        CORNEW=1.0
        HCOR(ISPC)=0.0
      ENDIF
   80 CONTINUE
      CORTEM(IREFI) = CORNEW
      NUMCAL(IREFI) = N
   90 CONTINUE
C----------
C  END OF CALIBRATION LOOP.  PRINT CALIBRATION STATISTICS AND RETURN
C----------
      WRITE(JOSTND,9002) (NUMCAL(I),I=1,NUMSP)
 9002 FORMAT(/'NUMBER OF RECORDS AVAILABLE FOR SCALING'/
     >       'THE SMALL TREE HEIGHT INCREMENT MODEL',
     >        ((T48,11(I4,2X)/)))
  100 CONTINUE
      WRITE(JOSTND,9003) (CORTEM(I),I=1,NUMSP)
 9003 FORMAT(/'INITIAL SCALE FACTORS FOR THE SMALL TREE'/
     >      'HEIGHT INCREMENT MODEL',
     >       ((T48,11(F5.2,1X)/)))
C----------
C OUTPUT CALIBRATION TERMS IF CALBSTAT KEYWORD WAS PRESENT.
C----------
      IF(JOCALB .GT. 0) THEN
        KOUT=0
        DO 207 K=1,MAXSP
        IF(CORTEM(K).NE.1.0 .OR. NUMCAL(K).GE.NCALHT) THEN
          SPEC=NSP(MAXSP,1)(1:2)
          ISPEC=MAXSP
          DO 203 KK=1,MAXSP
          IF(K .NE. IREF(KK)) GO TO 203
          ISPEC=KK
          SPEC=NSP(KK,1)(1:2)
          GO TO 2031
  203     CONTINUE
 2031     WRITE(JOCALB,204)ISPEC,SPEC,NUMCAL(K),CORTEM(K)
  204     FORMAT(' CAL: SH',1X,I2,1X,A2,1X,I4,1X,F6.3)
          KOUT = KOUT + 1
        ENDIF
  207   CONTINUE
        IF(KOUT .EQ. 0)WRITE(JOCALB,209)
  209   FORMAT(' NO SH VALUES COMPUTED')
        WRITE(JOCALB,210)
  210   FORMAT(' CALBSTAT END')
      ENDIF
      RETURN
      ENTRY REGCON
C----------
C  ENTRY POINT FOR LOADING OF REGENERATION GROWTH MODEL
C  CONSTANTS  THAT REQUIRE ONE-TIME RESOLUTION.
C  IDTYPE IS A HABITAT INDEX THAT IS COMPUTED IN **RCON**.
C  RHSC IS AN ARRAY FOR SPECIES CONSTANTS, RHGL IS AN ARRAY FOR
C  LOCATION CONSTANTS, RHHAB IS AN ARRAY FOR HABITAT DEPENDENT
C  CONSTANTS, AND, HTSLOP, HTCASP, AND HTSASP ARE COEFFICIENTS FOR
C  THE SLOPE AND ASPECT TRANSFORMATION.
C----------
      DATA RHHAB/
     &  0.0,-0.288729, .222331,     0.0,     0.0,     0.0,
     &  0.0, 0.095681,     0.0,     0.0,     0.0,     0.0,
     &  0.0, 0.259585, .143218, .107012,-.136078,     0.0,
     &  0.0, 0.111443, .182470,     0.0,     0.0,     0.0,
     &  0.0, 0.128458,-.115672, .271298,     0.0,     0.0,
     &  0.0,-0.107416,     0.0,     0.0,     0.0,     0.0,
     &  0.0,-0.637727,-.808173,-.396110, .666094,     0.0,
     &  0.0, 0.245211, .726173, .341746, .553888, .427478,
     &  0.0, 0.252628, .326399, .401200, .568246, .785996,
     &  0.0,-0.121653,-.374652,     0.0,     0.0,      0.0,
     &  -0.2146, -0.0941, -0.3738,     0.0,     0.0,  0.0/
      DATA MAPHAB/
     &  23*1,2,3*1,4*2,1,2*2,1,2,1,4*2,1,2*2,1,2,1,3*2,3*1,2,41*1,
     &     2*3,13*1,3,2*1,3*3,3*1,3,9*1,3,2*1,3*3,4*1,3,1,3,2*1,3,
     &     1,3,1,2*3,2*1,2*3,6*1,2,14*1,
     &  11*1,2,1,2,2*1,2,6*1,2*2,1,18*2,1,10*2,1,2,2*1,5*2,1,2,1,
     &     2*2,2*1,2*2,1,30*2,1,12*2,1,3*2,2*1,2*2,1,2*2,1,6*2,1,
     &     6*2,2*1,2,1,9*2,5*1,2,1,2,2*1,3*2,5*1,2,1,
     &  11*1,2,1,2,2*1,2,2*1,2,3*1,2,3,1,2*2,3,5,4,3,2*4,3,4,2*3,
     &     2*4,2*3,4,5,1,4,3,2*4,2,3,4,3,4,2,4*1,4,3*3,2*1,3,1,2*3,
     &     1,2*3,2,3,2,2*3,2,2*3,2*4,2*3,4,2,4,2,2*4,2,2*3,4,2*2,
     &     3,4*2,1,2*2,1,3,4,3,4,2*3,4,3,4,3*3,1,3,1,3,3*1,3,6*1,
     &     3,1,3,2*1,3,1,3*3,2*4,1,3,1,2*3,4,3*1,3,13*1,3,8*1,
     &  23*1,2,2*1,8*2,1,6*2,1,2,2*1,5*2,20*1,3,1,2,1,10*3,1,3,1,
     &     3*3,4*1,7*2,1,2*2,2*1,2*3,2*1,6*3,4*1,3,8*1,5*3,4*1,4*3,
     &     2*1,3,1,3*3,3*1,3,7*1,3,14*1,
     &  71*1,4,2,3*1,4,2*1,2*4,2*1,4,1,5*2,4,2,1,4,7*2,1,3*2,4*1,3,
     &     2*1,3,1,3,1,3,1,2*3,3*1,3,7*1,3*3,41*1,
     &  137*1,2,1,3*2,2*1,2,2*1,3*2,2*1,2*2,6*1,2,14*1,
     &  13*1,2,2*1,2,6*1,3,2,1,2*2,4,2*3,6*2,3,4*2,2*3,1,4,3*2,4,3,1,
     &     3,2*2,1,2,2*1,5,4,2*3,2,1,4*2,4,1,3*4,1,4,2,4,1,3*4,2,4,1,
     &     3*4,2,2*4,2,1,4,2,4,2,2*4,2*2,1,2*2,2*1,2*4,2,2*5,3,2*2,3,
     &     4,5,2*1,5,3,2*1,2,3,2,3,2,1,4,3*3,2,3*1,2*4,3,2*2,3,1,4,5,
     &     2,2*3,2*1,2*2,4,2,5*1,2,2*1,2,3,9*1,5,
     &  11*1,2,15*1,14*2,1,2*2,1,4*2,10*1,5,4*2,1,2,1,2,5,2*1,4,3,3*1,
     &     3,2*1,3,4,3,2*4,1,5*4,5*3,4,2,3,2,4,3,2,2*4,2*1,2*3,4,3,3*4,
     &     2*6,5,4,1,3,2*4,2*1,3,2*1,3,4,1,6,4,6,4,6,3*4,3,6,2*5,6,5,1,
     &     4,3,2*4,6,2*4,1,2*5,6*1,4,1,6,2*1,5,2*6,7*1,
     &  27*1,4*2,4,9*2,1,2*2,1,6*2,3*1,2,1,2,2*1,4*2,2*1,2,1,2*2,2*1,4,
     &     3,3*1,4,2*1,2*4,6,4,2*1,4*4,3*5,1,5,4,3,4,3,4,3,4,3*3,2*1,
     &     3*2,6,5,4,5,2*3,2*5,1,6,3,5,2*1,6,2,2*1,3,1,2,2*3,2,2*3,5,
     &     7*3,1,6,1,2*2,3,2*2,1,2*3,6*1,2,3*1,6,5,6,3,5*1,3,1,
     &  13*1,2,1,2*2,2*1,2,2*1,2,2*3,1,3,2,1,2*3,5*2,2*1,6*2,2*1,3,2,1,
     &     3,2,2*1,2*2,15*1,2*3,2,3,1,3*3,1,5*2,1,3*3,5*1,3,1,4*2,3*1,2,
     &     72*1,
     &  79*3,6*1,8*2,17*4,10*1,13*3,5*2,37*3/
      DATA  RHSC/
     &  10*0.0,.8953/
c    &  1.5772381,2.3031712,2.3698511,1.3920336,1.7477264,1.0443697,
c    &  3.5429926,.87052488,1.0984526,1.5626745,.8953  /
      DATA RHGL/
     &  -.2785,-.0480,0.0/
      DATA RSAB0,RSAB1,RSAB2/
     &     -.010987,0.22157,-0.12432/
C----------
C  HTFOR CONTAINS LOCATION CLASS CONSTANTS FOR EACH SPECIES.  MAPLOC
C  IS AN ARRAY WHICH MAPS GEOGRAPHIC AREA ONTO A LOCATION CLASS.
C----------
      DATA MAPLOC/
     &  1,2,1,2,2,2,1,3,3,3,
     &  1,1,2,1,2,2,3,1,3,4,
     &  1,2,2,2,2,1,3,3,3,3,
     &  1,2,1,2,1,1,1,3,2,3,
     &  1,2,2,1,1,2,1,1,2,1,
     &  1,1,2,1,1,2,1,3,1,2,
     &  1,1,2,3,1,1,1,2,2,3,
     &  1,2,2,2,5,4,3,1,5,1,
     &  1,2,2,2,4,3,4,4,4,4,
     &  1,2,1,3,2,1,1,3,2,2,
     &  1,1,1,1,1,1,1,1,1,1/
      DATA HTFOR/
     &  2.269835,2.106430,2.643390,     0.0,     0.0,
     &  2.887315,2.138032,2.577398,3.316322,     0.0,
     &  2.776090,2.731853,2.898513,     0.0,     0.0,
     &  1.508043,1.336607,1.653463,     0.0,     0.0,
     &  1.856635,1.882195,     0.0,     0.0,     0.0,
     &  1.102706,1.227212,1.508519,     0.0,     0.0,
     &  3.900741,3.814237,4.274753,     0.0,     0.0,
     &  1.605062,1.395650,2.304788,2.051997,1.297702,
     &  1.401828,1.625757,1.993350,1.668620,     0.0,
     &  1.370572,1.604815,1.083899,     0.0,     0.0,
     &       0.0,     0.0,     0.0,     0.0,     0.0/
C----------
C  HTEL CONTAINS THE COEFFICIENTS FOR THE ELEVATION TERM IN THE
C  HEIGHT GROWTH EQUATION.
C  HTSASP CONTAINS THE COEFFICIENTS FOR THE SIN(ASPECT)*SLOPE TERM
C  IN THE HEIGHT GROWTH EQUATION.  HTCASP CONTAINS THE COEFFICIENTS
C  FOR THE COS(ASPECT)*SLOPE TERM IN THE HEIGHT GROWTH EQUATION.
C  HTSLOP CONTAINS THE COEFFICIENTS FOR THE SLOPE TERM IN THE
C  HEIGHT GROWTH EQUATION. HTSLSQ CONTAINS THE COEFFICIENTS FOR THE
C  (SLOPE)**2 TERM IN THE HEIGHT GROWTH MODEL.  ALL OF THESE ARRAYS
C  ARE SUBSCRIPTED BY SPECIES.
C----------
      DATA HTSLOP/
     &  -.739841,-1.150486,-.749560,-.730825,.047743,-.034439,
     &  -.171346,-.140742,.459091,-1.923583,.000000/
      DATA HTSLSQ/
     &  -.347447,.000000,.726317,.755344,.000000,.000000,-1.705130,
     &   .000000,-1.015800,.000000,.000000/
      DATA HTEL/
     &  -.017447,-.001659,-.009145,-.009281,-.008651,.001325,-.007956,
     &  -.006651,-.005558,.005946,.000000/
      DATA HTCASP/
     &  -.319768,.506689,.025470,-.019985,-.200859,-.148969,
     &   .238473,-.174545,.047339,-.562835,.00000/
      DATA HTSASP/
     &  -.226560,-.019319,-.061316,-.002931,.035112,-.086932,.171464,
     &  -.083216,-.016025,.567420,-.00000/
C----------
C  LOAD SPECIES DEPENDENT VARIABLES AND OVERALL SITE CONSTANTS INTO
C  RHCON BY SPECIES.  IF SCALE FACTORS HAVE BEEN INPUT WITH THE
C  READCORR KEYWORD, INCORPERATE THEM INTO THE OVERALL CONSTANTS.
C---------
      DO 110 ISPC=1,MAXSP
      IRHHAB=MAPHAB(KKTYPE,ISPC)
      IRHFOR=MAPLOC(KOTFOR,ISPC)
C----------
C  FOR MOUNTAIN HEMLOCK, SPECIES 11, COMBINE SITE EFFECTS THAT ARE
C  INDEPENDENT OF SPECIES.
C----------
      IF(ISPC .EQ. 11) THEN
         REGCH = RHGL(IGL)+(RSAB0+RSAB1*COS(ASPECT)+RSAB2*SIN(ASPECT))
     &          *SLOPE
        RHCON(ISPC)=REGCH + RHSC(ISPC) +RHHAB(IRHHAB,ISPC)
        IF(LRCOR2.AND.RCOR2(ISPC).GT.0.0)RHCON(ISPC)=RHCON(ISPC) +
     &         ALOG(RCOR2(ISPC))
      ELSE
         REGCH = 0.0
        RHCON(ISPC)=HTFOR(IRHFOR,ISPC)
     &  + (HTSLOP(ISPC) + HTSLSQ(ISPC)*SLOPE + HTCASP(ISPC)*COS(ASPECT)
     &                  + HTSASP(ISPC)*SIN(ASPECT))*SLOPE
     &           + HTEL(ISPC)*ELEV
        RHCON(ISPC)=RHCON(ISPC) + RHSC(ISPC) + RHHAB(IRHHAB,ISPC)
      ENDIF
  110 CONTINUE
      RETURN
      END
