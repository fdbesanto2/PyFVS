      SUBROUTINE HTGF
      use htcal_mod
      use multcm_mod
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use prgprm_mod
      implicit none
C----------
C  **HTGF--NI   DATE OF LAST REVISION:  07/08/11
C----------
C  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT INCREMENT FOR
C  EACH CYCLE AND LOADS IT INTO THE ARRAY HTG. HEIGHT INCREMENT IS
C  PREDICTED FROM SPECIES, HABITAT TYPE, HEIGHT, DBH, AND PREDICTED DBH
C  INCREMENT.  THIS ROUTINE IS CALLED FROM **TREGRO** DURING REGULAR
C  CYCLING.  ENTRY **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE
C  DEPENDENT CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
      INCLUDE 'CALCOM.F77'
C
C----------
C   MODEL COEFFICIENTS AND CONSTANTS:
C
C    BIAS -- THE AVERAGE RESIDUAL.
C
C   HTCON -- AN ARRAY CONTAINING HABITAT TYPE CONSTANTS FOR
C            HEIGHT GROWTH MODEL (SUBSCRIPTED BY SPECIES)
C
C  HDGCOF -- COEFFICIENT FOR DIAMETER GROWTH TERMS.
C
C    HGLD -- AN ARRAY, SUBSCRIPTED BY SPECIES, OF THE
C             COEFFICIENTS FOR THE DIAMETER TERM IN THE HEIGHT
C             GROWTH MODEL.
C
C   H2COF -- COEFFICIENT FOR HEIGHT SQUARED TERMS.
C    IND2 -- ARRAY OF POINTERS TO SMALL TREES.
C
C   SCALE -- TIME FACTOR DERIVED BY DIVIDING FIXED POINT CYCLE
C            LENGTH BY GROWTH PERIOD LENGTH FOR DATA FROM
C            WHICH MODELS WERE DEVELOPED.
C
C------------
      LOGICAL DEBUG
      REAL HGLD(MAXSP),HGHC(8),HGLDD(8),HGSC(MAXSP),HGH2(8)
      INTEGER MAPHAB(30)
      REAL HGLH,BIAS,SCALE,XHT,HTI,D,CON,HTNEW
      REAL MISHGF
      INTEGER ISPC,I1,I2,I3,I,ITFN,IHT
      DATA HGLD/-.04935,-.3899,-.4574,-.09775,-.1555,-.1219,
     &       -.2454,-.5720,-.1997,-.5657,-.1219/
      DATA BIAS/ .4809 /, HGLH/ 0.23315 /
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      SCALE=FINT/YR
      ISMALL=0
C----------
C  GET THE HEIGHT GROWTH MULTIPLIERS.
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
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      DO 30 I3 = I1,I2
      I=IND1(I3)
      HTG(I)=0.
      IF (PROB(I).LE.0.0)THEN
        IF(LTRIP)THEN
          ITFN=ITRN+2*I-1
          HTG(ITFN)=0.
          HTG(ITFN+1)=0.
        ENDIF
        GO TO 30
      ENDIF
      HTI=HT(I)
      D = DBH(I)
      CON=HTCON(ISPC)+H2COF*HTI*HTI+HGLD(ISPC)*ALOG(D)+
     &    HGLH*ALOG(HTI)
C-----------
C   HEIGHT GROWTH EQUATION, EVALUATED FOR EACH TREE EACH CYCLE
C    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C    MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C----------
      HTG(I)=EXP(CON+HDGCOF*ALOG(DG(I)))+BIAS
      IF(HTG(I).LT.0.1)HTG(I)=0.1
      HTG(I)=HTG(I)*SCALE*XHT
C----------
C    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
C    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
C----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
C
      IF(DEBUG)THEN
        HTNEW=HT(I)+HTG(I)
        WRITE (JOSTND,9000) HTG(I),CON,HTCON(ISPC),H2COF,D,
     &  WK1(I),HGLH,HTNEW,HDGCOF,I,ISPC
 9000   FORMAT(' 9000 HTGF, HTG=',F8.4,' CON=',F8.4,' HTCON=',F8.4,
     &  ' H2COF=',F12.8,' D =',F8.4/' WK1=',F8.4,' HGLH=',F8.4,
     &  ' HTNEW=',F8.4,' HDGCOF=',F8.4,' I=',I4,' ISPC=',I2)
      ENDIF
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
      HTG(ITFN)=EXP(CON+HDGCOF*ALOG(DG(ITFN)))+BIAS
      IF(HTG(ITFN).LT.0.1)HTG(ITFN)=0.1
      HTG(ITFN)=HTG(ITFN)*SCALE*XHT
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
C
      HTG(ITFN+1)=EXP(CON+HDGCOF*ALOG(DG(ITFN+1)))+BIAS
      HTG(ITFN+1)=HTG(ITFN+1)*SCALE*XHT
      IF(HTG(ITFN+1).LT.0.1)HTG(ITFN+1)=0.1
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
C
      IF(DEBUG) WRITE(JOSTND,9001) HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)
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
C  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT ARE
C  SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.  HGHC CONTAINS
C  HABITAT TYPE INTERCEPTS, HGLDD CONTAINS HABITAT DEPENDENT
C  COEFFICIENTS FOR THE DIAMETER INCREMENT TERM, HGH2 CONTAINS HABITAT
C  DEPENDENT COEFFICIENTS FOR THE HEIGHT-SQUARED TERM, AND HGHC CONTAINS
C  SPECIES DEPENDENT INTERCEPTS.  HABITAT TYPE IS INDEXED BY ITYPE (SEE
C  /PLOT/ COMMON AREA).
C----------
      DATA MAPHAB/
     & 1,1, 7*2, 3,3,4,5,6, 4*7, 4,4,1,4,4, 3*8, 4*1/
      DATA  HGHC /
     & 2.03035, 1.72222, 1.19728, 1.81759, 2.14781, 1.76998, 2.21104,
     & 1.74090/
      DATA  HGLDD /
     & 0.62144, 1.02372, 0.85493, 0.75756, 0.46238, 0.49643, 0.37042,
     & 0.34003/
      DATA  HGH2 /
     & -13.358E-05, -3.809E-05, -3.715E-05, -2.607E-05, -5.200E-05,
     & -1.605E-05, -3.631E-05, -4.460E-05/
      DATA  HGSC /
     &  -.5342,.1433,.1641,-.6458,-.6959,-.9941,-.6004,.2089,
     &  -.5478,.7316, -.9941 /
C----------
C  ASSIGN HABITAT DEPENDENT COEFFICIENTS.
C----------
      IHT=MAPHAB(ITYPE)
      HGHCH=HGHC(IHT)
      H2COF=HGH2(IHT)
      HDGCOF=HGLDD(IHT)
C----------
C  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
C----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=HGHCH+HGSC(ISPC)
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
C
      RETURN
      END
