      SUBROUTINE HTGF
      use htcal_mod
      use multcm_mod
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **HTGF--SN   DATE OF LAST REVISION:  03/05/13
C----------
C  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT INCREMENT FOR
C  EACH CYCLE AND LOADS IT INTO THE ARRAY HTG. HEIGHT INCREMENT IS
C  PREDICTED IN THE HTCALC ROUTINE USING NC128 SITE CURVES.  A
C  A RELATIVE HEIGHT MODIFIER EMPLOYS THE CHAPMAN-RICHARDS FUNCTION
C  AND A HOERL'S EQUATION IS USED TO MODEL THE CONTIBUTION OF
C  CROWN RATIO. THIS ROUTINE IS CALLED FROM **TREGRO** DURING REGULAR
C  CYCLING.  ENTRY **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE
C  DEPENDENT CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
      INCLUDE 'CALCOM.F77'
C
C----------
C
C   SCALE -- TIME FACTOR DERIVED BY DIVIDING FIXED POINT CYCLE
C            LENGTH  (10 YEARS) BY THE CYCLE LENGTH USED IN THE
C            CURRENT SIMULATION
C   SCALE2-- TIME LENGTH FACTOR DERIVED BY DIVIDING THE CURRENT
C            CYCLE LENGTH BY THE TIME INCREMENT USED TO DEVELOP
C            REGRESSION EQUATIONS (5 YRS FOR THE SN VARIANT)
C----------
      INTEGER MODE0,MODE9
      INTEGER ITFN,I,I3,I2,I1,ISPC
      REAL REGYR,CRC,CRB,CRA,SCALE,SCALE2,HTG11,HTG1,XHT,SI,HTI
      REAL HTMAX,AGET,RELHT,HGMDCR,RHX,FCTRKX,FCTRRB,FCTRXB
      REAL FCTRM,HGMDRH,WTCR,WTRH,HTGMOD,HTNEW,TEMHTG
      LOGICAL DEBUG
C
      DATA REGYR /5.0/
C----------
C  COEFFICIENTS--CROWN RATIO (CR) BASED HT. GRTH. MODIFIER
C----------
      DATA CRA /100.0/, CRB /3.0/, CRC /-5.0/
C----------
C  COEFFICIENTS--RELATIVE HEIGHT (RH) BASED HT. GRTH. MODIFIER
C----------
      REAL RHR(MAXSP), RHYXS(MAXSP), RHM(MAXSP), RHB(MAXSP),
     >      RHK(MAXSP), RHXS(MAXSP)
C----------
C  COEFFICIENTS--RELATIVE HEIGHT (RH) BASED HT. GRTH. MODIFIER
C  COEFFS BASED ON SPECIES SHADE TOLERANCE AS FOLLOWS:
C                          RHR  RHYXS    RHM    RHB  RHXS   RHK
C        VERY TOLERANT    20.0   0.20    1.1  -1.10  0.00  1.00
C        TOLERANT         16.0   0.15    1.1  -1.20  0.00  1.00
C        INTERMEDIATE     15.0   0.10    1.1  -1.45  0.00  1.00
C        INTOLERANT       13.0   0.05    1.1  -1.60  0.00  1.00
C        VERY INTOLERANT  12.0   0.01    1.1  -1.60  0.00  1.00
C----------
C  COEFF VALUES FOR REL.HT. MOD. VALUE(Y) AT REL.HT. START(X=0)
C  9 LINES OF 10 VALUES EACH LINE
C----------
      DATA RHYXS
     > /0.20,0.05,0.15,0.05,0.05,0.05,0.20,0.05,0.05,0.05,
     >  0.05,0.10,0.05,0.05,0.10,0.10,0.20,0.15,0.15,0.15,
     >  0.15,0.20,0.15,0.05,0.05,0.20,0.10,0.05,0.10,0.15,
     >  0.20,0.20,0.20,0.15,0.05,0.05,0.15,0.05,0.15,0.15,
     >  0.20,0.05,0.05,0.05,0.05,0.15,0.10,0.15,0.10,0.15,
     >  0.05,0.15,0.05,0.15,0.05,0.15,0.15,0.15,0.10,0.01,
     >  0.01,0.05,0.10,0.01,0.10,0.05,0.05,0.15,0.10,0.05,
     >  0.05,0.05,0.05,0.10,0.10,0.05,0.05,0.10,0.10,0.01,
     >  0.01,0.05,0.15,0.10,0.15,0.10,0.15,0.10,0.10,0.10/
C----------
C  COEFF VALUES FOR REL.HT. GCRF R COEFF
C  10 LINES OF 9 VALUES EACH LINE.
C----------
      DATA RHR
     > /20.0,13.0,16.0,13.0,13.0,13.0,20.0,13.0,13.0,
     >  13.0,13.0,15.0,13.0,13.0,15.0,15.0,20.0,16.0,
     >  16.0,16.0,16.0,20.0,16.0,13.0,13.0,20.0,15.0,
     >  13.0,15.0,16.0,20.0,20.0,20.0,16.0,13.0,13.0,
     >  16.0,13.0,16.0,16.0,20.0,13.0,13.0,13.0,13.0,
     >  16.0,15.0,16.0,15.0,16.0,13.0,16.0,13.0,16.0,
     >  13.0,16.0,16.0,16.0,15.0,12.0,12.0,13.0,15.0,
     >  12.0,15.0,13.0,13.0,16.0,15.0,13.0,13.0,13.0,
     >  13.0,15.0,15.0,13.0,13.0,15.0,15.0,12.0,12.0,
     >  13.0,16.0,15.0,16.0,15.0,16.0,15.0,15.0,15.0/
C----------
C  COEFF VALUES FOR REL.HT. GCRF B COEFF
C  10 LINES OF 9 VALUES EACH LINE.
C---------
      DATA RHB
     > /-1.10,-1.60,-1.20,-1.60,-1.60,-1.60,-1.10,-1.60,-1.60,
     >  -1.60,-1.60,-1.45,-1.60,-1.60,-1.45,-1.45,-1.10,-1.20,
     >  -1.20,-1.20,-1.20,-1.10,-1.20,-1.60,-1.60,-1.10,-1.45,
     >  -1.60,-1.45,-1.20,-1.10,-1.10,-1.10,-1.20,-1.60,-1.60,
     >  -1.20,-1.60,-1.20,-1.20,-1.10,-1.60,-1.60,-1.60,-1.60,
     >  -1.20,-1.45,-1.20,-1.45,-1.20,-1.60,-1.20,-1.60,-1.20,
     >  -1.60,-1.20,-1.20,-1.20,-1.45,-1.60,-1.60,-1.60,-1.45,
     >  -1.60,-1.45,-1.60,-1.60,-1.20,-1.45,-1.60,-1.60,-1.60,
     >  -1.60,-1.45,-1.45,-1.60,-1.60,-1.45,-1.45,-1.60,-1.60,
     >  -1.60,-1.20,-1.45,-1.20,-1.45,-1.20,-1.45,-1.45,-1.45/
C----------
C  COEFF VALUES FOR REL.HT. MOD. GCRF M COEFF.
C  THESE 90 VALUES CAN BE DIVIDED BY SPECIES ATTRIB. IF NEEDED.
C----------
      DATA RHM  /90*1.10/
C----------
C  COEFF VALUES FOR REL.HT. MOD. GCRF X(REL.HT.) START (X=0).
C  THESE 90 VALUES CAN BE DIVIDED BY SPECIES ATTRIB. IF NEEDED.
C----------
      DATA RHXS /90*0.0/
C----------
C  COEFF VALUES FOR REL.HT. MOD. GCRF ASYMPTOTE COEFF.
C  THESE 90 VALUES CAN BE DIVIDED BY SPECIES ATTRIB. IF NEEDED.
C----------
      DATA RHK  /90*1.0/
C----------
C  CHECK FOR DEBUG.
C----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF (DEBUG) THEN
      WRITE(JOSTND,*) ' ENTERING HTGF, CYCLE= ', ICYC,' BA= ',BA
      ENDIF
C
      SCALE=FINT/YR
      SCALE2= FINT/REGYR
      HTG11= 0.
      HTG1= 0.
C----------
C  SEE IF USER PROVIDED HEIGHT GROWTH ADJUSTMENT MULTIPLIERS
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
C----------
C   BEGIN SPECIES LOOP:
C----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      XHT=1.0
      XHT=XHMULT(ISPC)
C----------
C   SET SITE INDEX
C----------
      SI= SITEAR(ISPC)
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      DO 30 I3 = I1,I2
      I=IND1(I3)
      HTG(I)=0.
      IF (PROB(I).LE.0.0) GO TO 4
      HTI=HT(I)
C----------
C  CALCULATE
C  HTMAX=(B1*SI**B2)
C----------
      MODE0= 0
      AGET=0.
      CALL HTCALC (MODE0,ISPC,AGET,HTI,HTMAX,HTG1,JOSTND,DEBUG)
C
      IF(HTMAX-HTI.LE.1.) THEN
C----------
C  IF INITIAL TREE HEIGHT IS >= MAX HEIGHT FOR SITE (HTMAX).
C  THEN SET HTG= 0.1 FT.
C----------
        IF(DEBUG) WRITE(JOSTND,*) ' HTI>=HTMAX , ABIRTH= ',ABIRTH(I),
     &  ' XHT=',XHT,' HTCON=',HTCON(ISPC)
C
        HTG(I)= 0.10
        HTG(I)=HTG(I)*XHT*SCALE*EXP(HTCON(ISPC))
        GO TO 4
      ENDIF
C-----------
C    HEIGHT GROWTH EQUATION, USING NC128 TREE HEIGHT COEFFS.
C    EVALUATED FOR EACH TREE EACH CYCLE, 5.0 YEAR CYCLE
C----------
      MODE9= 9
      HTG1=0.
      CALL HTCALC (MODE9,ISPC,AGET,HTI,HTMAX,HTG1,JOSTND,DEBUG)
C
      IF (DEBUG) WRITE(JOSTND,*)' HTGF,MAIN HT CALC, AGET,HTMAX,HTG1= ',
     &AGET,HTMAX,HTG1
C----------
C  HEIGHT GROWTH MODIFIERS
C----------
      RELHT = 0.0
      IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
      IF(RELHT .GT. 1.5)RELHT=1.5
C----------
C     REVISED HEIGHT GROWTH MODIFIER APPROACH.
C----------
C     CROWN RATIO CONTRIBUTION(HGMDCR).DATA AND READINGS INDICATE HEIGHT
C     GROWTH PEAKS IN MID-RANGE OF CR, DECREASES SOMEWHAT FOR LARGE
C     CROWN RATIOS DUE TO PHOTOSYNTHETIC ENERGY PUT INTO CROWN SUPPORT
C     RATHER THAN HT. GROWTH.  CROWN RATIO FOR THIS COMPUTATION NEEDS
C     TO BE IN (0-1) RANGE; DIVIDE BY 100.  FUNCTION IS HOERL'S
C     SPECIAL FUNCTION (REF. P.23, CUTHBERT&WOOD, FITTING EQNS. TO DATA
C     WILEY, 1971).
C----------
      HGMDCR = (CRA * (ICR(I)/100.0)**CRB) * EXP(CRC*(ICR(I)/100.0))
      IF (HGMDCR .GT. 1.0) HGMDCR = 1.0
C----------
C     RELATIVE HEIGHT CONTRIBUTION(HGMDRH). DATA AND READINGS INDICATE
C     HEIGHT GROWTH IS ENHANCED BY STRONG TOP LIGHT AND HINDERED BY HIGH
C     SHADE EVEN IF SOME LIGHT FILTERS THROUGH.  ALSO RESPONSE IS
C     GREATER FOR GIVEN LIGHT AS SHADE TOLERANCE INCREASES.  FUNCTION
C     IS GENERALIZED CHAPMAN-RICHARDS (REF. P.2 DONNELLY ET AL. 1992.
C     THINNING EVEN-AGED FOREST STANDS...OPTIMAL CONTROL ANALYSES.
C     USDA FOR. SERV. RES. PAPER RM-307).
C----------
      RHX = RELHT
      FCTRKX = ( (RHK(ISPC)/RHYXS(ISPC))**(RHM(ISPC)-1.0) ) - 1.0
      FCTRRB = -1.0*( RHR(ISPC)/(1.0-RHB(ISPC)) )
      FCTRXB = RHX**(1.0-RHB(ISPC)) - RHXS(ISPC)**(1.0-RHB(ISPC))
      FCTRM  = -1.0/(RHM(ISPC)-1.0)
      IF (DEBUG)
     & WRITE(JOSTND,*) ' HTGF-HGMDRH FACTORS = ',
     &        ISPC, RHX, FCTRKX, FCTRRB, FCTRXB, FCTRM
      HGMDRH = RHK(ISPC) * ( 1.0 + FCTRKX*EXP(FCTRRB*FCTRXB) ) ** FCTRM
C-----------
C     APPLY WEIGHTED MODIFIER VALUES.
C-----------
      WTCR = .25
      WTRH = 1.0 - WTCR
      HTGMOD = WTCR*HGMDCR + WTRH*HGMDRH
C----------
C    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C    MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C----------
      IF(DEBUG) WRITE(JOSTND,*)' IN HTGF, HTGMOD= ',HTGMOD,'ICR=',ICR(I)
     &,' ABIRTH= ',ABIRTH(I)
C
      IF (HTGMOD .GE. 2.0) HTGMOD= 2.0
      IF (HTGMOD .LE. 0.1) HTGMOD= 0.1
      HTG(I)= HTG1 * (HTGMOD)
      IF(HTG(I).LT.0.1)HTG(I)=0.1
      HTG(I)=HTG(I)*XHT*SCALE*EXP(HTCON(ISPC))
C
      IF(DEBUG)THEN
        WRITE(JOSTND,*)' I,ISPC,XHT,HTCON,SCALE,HTG= ',
     &  I,ISPC,XHT,HTCON(ISPC),SCALE,HTG(I)
        HTNEW=HT(I)+HTG(I)
        WRITE(JOSTND,*) 'ISPC5= ',ISPC,' I5= ',I,' ICYC= ',ICYC,
     &  ' FINT= ',FINT
        WRITE (JOSTND,9000)HTG(I),DBH(I),XHT,ABIRTH(I),SI,HT(I),WK1(I),
     >  HTNEW, HTGMOD,RELHT,AVH,HTMAX,SCALE,
     >  SCALE2,HGMDCR,HGMDRH,RHB(ISPC)
 9000   FORMAT(' 9000HTGF,HTG=',F8.4,'D=',F8.4,' XHT=',F8.4,
     &  ' AGET=',F8.4/' SI =',F8.4,' HT(I)= ',F8.4,' WK1= ',f8.4,
     &  'HTNEW= ',F8.4,' HTGMOD= ',F8.4/
     &  ' RELHT= ',F8.4,' AVH= ',F8.4/
     &  ' HTMAX= ',F10.3,' SCALE= ',F5.1,'SCALE2= ',F5.1,
     &  ' HGMDCR=',F9.3,' HGMDRH=',F9.3,' RHB(ISPC)=',F6.2)
      ENDIF
C----------
C  BRANCH FROM MAX HEIGHT TEST. TREE > MAX HEIGHT
C----------
    4 CONTINUE
      TEMHTG=HTG(I)
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF
C
      IF(.NOT.LTRIP) GO TO 30
      ITFN=ITRN+2*I-1
      HTG(ITFN)=TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
C
      HTG(ITFN+1)=TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
C
      IF(DEBUG) WRITE(JOSTND,8010) HTG(ITFN),HTG(ITFN+1)
 8010 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)
C----------
C   END OF TREE LOOP
C----------
   30 CONTINUE
C----------
C   END OF SPECIES LOOP
C----------
   40 CONTINUE
      RETURN
C
      ENTRY HTCONS
C----------
C  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
C  REQUIRE A A ONE-TIME RESOLUTION.
C  FIRSTLY TREE AGE IS CALCULATED BASED ON TREELIST OR DUBBED HEIGHT
C  VALUES.
C----------
      DO 60 ISPC= 1,MAXSP
      HTCON(ISPC)= 0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
  60  CONTINUE
C
      RETURN
      END
