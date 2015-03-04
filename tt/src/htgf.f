      SUBROUTINE HTGF
      use prgprm_mod
      implicit none
C----------
C  **HTGF--TT   DATE OF LAST REVISION:  07/08/11
C----------
C   THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
C   INCREMENT FOR EACH CYCLE AND LOADS IT INTO THE ARRAY HTG.
C  HEIGHT INCREMENT IS PREDICTED FROM SPECIES, HABITAT TYPE,
C  HEIGHT, DBH, AND PREDICTED DBH INCREMENT.  THIS ROUTINE
C  IS CALLED FROM **TREGRO** DURING REGULAR CYCLING.  ENTRY
C  **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE DEPENDENT
C  CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
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
      INCLUDE 'MULTCM.F77'
C
      INCLUDE 'HTCAL.F77'
C
      INCLUDE 'PDEN.F77'
C
      INCLUDE 'VARCOM.F77'
C
      INCLUDE 'GGCOM.F77'
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
C   H2COF -- COEFFICIENT FOR HEIGHT SQUARED TERMS.
C    IND2 -- ARRAY OF POINTERS TO SMALL TREES.
C
C   SCALE -- TIME FACTOR DERIVED BY DIVIDING FIXED POINT CYCLE
C            LENGTH BY GROWTH PERIOD LENGTH FOR DATA FROM
C            WHICH MODELS WERE DEVELOPED.
C
C------------
      EXTERNAL RANN
      LOGICAL DEBUG
      INTEGER ISPC,I1,I2,I3,I,IICR,KEYCR,K,IXAGE,ITFN,JSPC
      INTEGER LSIGRP,LSIMAP,L,ICLS
      REAL AZBIAS(MAXSP),BZBIAS(MAXSP),ZZRAN,HHU2,HHU1,HHE2,HHE1
      REAL D,D1,D2,H,SITHT,SITAGE,AGMAX,HTMAX,HTMAX2
      REAL PCCFI,DGI,AP,TSITE,AGETEM,RATIO,BAUTBA,BARK,HNOW,XWT
      REAL COF11,COF10,COF9,COF8,COF7,COF6,COF5,COF4,COF3,COF2,COF1,COF
      REAL XI1,XI2,SCALE,XSITE,Y1,Y2,FBY1,FBY2,Z,ZBIAS,ZTEST,ZADJ,BATEM
      REAL CLOSUR,DIA,BRATIO,PSI,TEMHTG,ADJUST,AGEFUT,DFUT,HGE,HGU
      REAL SINDX,BAL,POTHTG,AGP10,AG,HGUESS,RELHT,CRC,CRB,CRA
      REAL HGMDCR,RHX,RHK,FCTRKX,FCTRRB,RHB,RHXS,FCTRXB,FCTRM,HGMDRH
      REAL WTCR,WTRH,HTGMOD,HTNOW,TEMPH,BACHLO,RHM,RHYXS,RHR,HTI,CON
      REAL MISHGF
C----------
C PROGRAM TO CALCULATE HT GROWTH USING THE SBB DIST'N
C----------
      DIMENSION COF(9,33),COF1(9,3),COF2(9,3),COF3(9,3),
     1 COF4(9,3),COF5(9,3),COF6(9,3),COF7(9,3),
     2 COF8(9,3),COF9(9,3),COF10(9,3),COF11(9,3)
      EQUIVALENCE (COF(1,1),COF1(1,1)),(COF(1,4),COF2(1,1)),
     2 (COF(1,7),COF3(1,1)),(COF(1,10),COF4(1,1)),
     3  (COF(1,13),COF5(1,1)),(COF(1,16),COF6(1,1)),
     4 (COF(1,19),COF7(1,1)),(COF(1,22),COF8(1,1)),(COF(1,25),COF9(1,1))
     5 ,(COF(1,28),COF10(1,1)),(COF(1,31),COF11(1,1))
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
C    NINE COEFFICIENTS FOR JOHNSON'S SBB DISTRIBUTION FOR
C    11 SPECIES, AND 3 CROWN RATIO GROUPS.
C----------
C  DOUGLAS-FIR
C----------
       DATA COF3/
     +60.0,105.0,2.43099,0.20403,1.28447,0.99886,0.79629,
     +5.66171,1.02398,
     +70.0,120.0,1.85710,-0.10692,1.40067,1.16053,0.78576,
     +3.85554,0.94853,
     +70.0,130.0,1.51547,0.30923,1.30655,1.23707,0.86427,2.24521,
     +0.91281/
C----------
C  WHITEBARK PINE
C----------
       DATA COF1/
     +37.0,85.0,1.77836,-0.51147,1.88795,1.20654,0.57697,
     +3.57635,0.90283,
     +45.0,100.0,1.66674,0.25626,1.45477,1.11251,0.67375,
     +2.17942,0.88103,
     +45.0,90.0,1.64770,0.30546,1.35015,0.94823,0.70453,
     +2.46480,1.00316/
C----------
C  LIMBER PINE
C----------
       DATA COF2/
     +37.0,85.0,1.77836,-0.51147,1.88795,1.20654,0.57697,
     +3.57635,0.90283,
     +45.0,100.0,1.66674,0.25626,1.45477,1.11251,0.67375,
     +2.17942,0.88103,
     +45.0,90.0,1.64770,0.30546,1.35015,0.94823,0.70453,
     +2.46480,1.00316/
C----------
C  NOT USED -- LOAD DOUGLAS-FIR COEFFICIENTS
C----------
       DATA COF4/
     +60.0,105.0,2.43099,0.20403,1.28447,0.99886,0.79629,
     +5.66171,1.02398,
     +70.0,120.0,1.85710,-0.10692,1.40067,1.16053,0.78576,
     +3.85554,0.94853,
     +70.0,130.0,1.51547,0.30923,1.30655,1.23707,0.86427,2.24521,
     +0.91281/
C----------
C  BLUE SPRUCE -- LOAD ENGELMANN SPRUCE COEFFICIENTS
C----------
       DATA COF5/
     +50.0,145.0,1.23692,0.30499,1.19486,1.09838,0.90058,
     +2.08863,0.97969,
     +50.0,145.0,1.23692,0.30499,1.19486,1.09838,0.90058,
     +2.08863,0.97969,
     +50.0,140.0,0.94647,0.31838,1.04318,0.95444,0.91934,
     +1.78262,1.00481/
C----------
C  QUAKING ASPEN
C----------
       DATA COF6/
     +30.0,85.0,2.00995,0.03288,1.81059,1.28612,0.72051,
     +3.00551,1.01433,
     +30.0,85.0,2.00995,0.03288,1.81059,1.28612,0.72051,
     +3.00551,1.01433,
     +35.0,85.0,1.80388,-0.07682,1.70032,1.29148,0.72343,
     +2.91519,0.95244/
C----------
C LODGEPOLE PINE
C----------
       DATA COF7/
     +30.0,105.0,2.00207,-0.25204,2.04453,1.62734,0.72514,
     +2.84910,0.91104,
     +45.0,110.0,2.50885,0.09740,1.85457,1.48205,0.77851,
     +3.49791,0.97420,
     +35.0,90.0,1.31478,0.21254,1.29774,1.09363,0.85692,
     +2.30681,1.01686/
C----------
C ENGELMANN SPRUCE
C----------
       DATA COF8/
     +50.0,145.0,1.23692,0.30499,1.19486,1.09838,0.90058,
     +2.08863,0.97969,
     +50.0,145.0,1.23692,0.30499,1.19486,1.09838,0.90058,
     +2.08863,0.97969,
     +50.0,140.0,0.94647,0.31838,1.04318,0.95444,0.91934,
     +1.78262,1.00481/
C----------
C  SUBALPINE FIR
C----------
       DATA COF9/
     +20.0,95.0,0.90779,0.33845,1.06402,0.81823,0.97688,
     +1.95458,1.27034,
     +35.0,110.0,1.36713,0.35062,1.25426,1.05571,0.90342,
     +2.31128,1.07333,
     +50.0,130.0,1.63172,0.60577,1.29877,1.16988,0.90860,
     +2.11592,1.00870/
C----------
C  NOT USED -- LOAD LIMBER PINE COEFFICIENTS
C----------
       DATA COF10/
     +37.0,85.0,1.77836,-0.51147,1.88795,1.20654,0.57697,
     +3.57635,0.90283,
     +45.0,100.0,1.66674,0.25626,1.45477,1.11251,0.67375,
     +2.17942,0.88103,
     +45.0,90.0,1.64770,0.30546,1.35015,0.94823,0.70453,
     +2.46480,1.00316/
C----------
C  OTHER SOFTWOODS -- USE WHITEBARK/LIMBER PINE
C----------
       DATA COF11/
     +37.0,85.0,1.77836,-0.51147,1.88795,1.20654,0.57697,
     +3.57635,0.90283,
     +45.0,100.0,1.66674,0.25626,1.45477,1.11251,0.67375,
     +2.17942,0.88103,
     +45.0,90.0,1.64770,0.30546,1.35015,0.94823,0.70453,
     +2.46480,1.00316/
C
      DATA AZBIAS/
     &      0.0,     0.0, -.86001,     0.0, -.84735,
     &      0.0,  .40153, -.84735,  .89035,     0.0,
     &      0.0,     0.0,     0.0,     0.0,     0.0,
     &      0.0,     0.0,     0.0/
      DATA BZBIAS/
     &      0.0,     0.0,  .01051,     0.0,  .01102,
     &      0.0,  -.0078,  .01102, -.01331,     0.0,
     &      0.0,     0.0,     0.0,      0.,     0.0,
     &      0.0,     0.0,     0.0/
C----------
C  COEFFICIENTS--CROWN RATIO (CR) BASED HT. GRTH. MODIFIER
C----------
      DATA CRA /100.0/, CRB /3.0/, CRC /-5.0/
C----------
C  COEFFICIENTS--RELATIVE HEIGHT (RH) BASED HT. GRTH. MODIFIER
C----------
      DATA RHK /1.0/, RHXS /0.0/
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF(DEBUG)WRITE(JOSTND,*) 'IN HTGF AT BEGINNING, HTCON=',
     *HTCON,' RMAI=',RMAI,' ELEV=',ELEV
C
      XI2=4.5
      XI1=0.1
      SCALE=FINT/YR
      ISMALL=0
C----------
C  GET THE HEIGHT GROWTH MULTIPLIERS.
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
      IF(DEBUG)WRITE(JOSTND,*)' HTGF MULT= ',XHMULT,'  SCALE= ',SCALE
C----------
C  PUT SITE INDEX FOR THE SITE SPECIES INTO A SITE GROUP
C----------
      XSITE = SITEAR(ISISP)
      LSIGRP=XSITE/10.0 - .5
      IF(LSIGRP .LT. 2) LSIGRP=2
      IF(LSIGRP .GT. 6) LSIGRP = 6
      LSIMAP=LSIGRP-1
C----------
C   BEGIN SPECIES LOOP:
C----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      DO 30 I3 = I1,I2
      I=IND1(I3)
      HTG(I)=0.
      BARK=BRATIO(ISPC,DBH(I),HT(I))
      IF (PROB(I) .LE. 0.0 ) GO TO 201
C----------
C   BYPASS CALCULATION IF DIAMETER IS LESS THAN LOWER LIMIT
C   SAVE POINTERS TO SMALL TREES
C----------
      SELECT CASE (ISPC)
      CASE (14)
        IF (DBH(I).LT.1.0)THEN
          ISMALL=ISMALL + 1
          IND2(ISMALL) = I
          GO TO 201
        ENDIF
      CASE(15,18)
        IF (DBH(I).LT.0.5 .OR. HT(I).LE.4.5)THEN
          ISMALL=ISMALL + 1
          IND2(ISMALL) = I
          GO TO 201
        ENDIF
      CASE DEFAULT
        IF (DBH(I).LT.1.5)THEN
          ISMALL=ISMALL + 1
          IND2(ISMALL) = I
          GO TO 201
        ENDIF
      END SELECT
C
      SELECT CASE (ISPC)
C----------
C  PP FROM THE CI VARIANT
C----------
      CASE(10)
        HTI=HT(I)
        D = DBH(I)
        CON = 2.03035 + 0.7316 - 0.00013358*HTI*HTI - 0.5657*ALOG(D) +
     &    0.23315*ALOG(HTI)
        HTG(I)=EXP(CON + 0.62144*ALOG(DG(I))) + 0.4809
        IF(HTG(I).LT.0.1)HTG(I)=0.1
C----------
C  PM, UJ, AND RM
C  WILL GET HEIGHT ESTIMATE IN **REGENT**
C----------
      CASE(4,11,12)
        HTG(I)=0.
C
C----------
C  SPECIES WITH SURROGATE EQUATIONS FROM THE CR VARIANT, VIA UT
C  USES SPRUCE-FIR MODEL TYPE RELATIONSHIPS
C  ADJUST FOR NC WAS 1.05 IN CR VARIANT, BUT IS A FUNCTION
C  OF SITE INDEX IN THIS VARIANT SO OPEN GROWN TREES HIT THE SITE
C  HEIGHT
C  NC, OH
C----------
      CASE(15,18)
        ADJUST = 0.78 + 0.0023*SITEAR(ISPC)
        D=DBH(I)
        ICLS = IFIX(D + 1.0)
        IF(ICLS .GT. 41) ICLS = 41
        BARK=BRATIO(ISPC,D,HT(I))
        BAUTBA= BAU(ICLS)/BA
        HNOW=HT(I)
        HHE1 = 0.0
        HHE2 = 0.0
        HHU1 = 0.0
        HHU2 = 0.0
        XWT  = 0.0
        PCCFI=PCCF(ITRE(I))
        DGI=DG(I)
        AP=ABIRTH(I)
C----------
C  ADJUST AP FOR BREAST HIGH AGE CURVES IF NECESSARY
C----------
        TSITE=SITEAR(ISPC)
        IF(TSITE.LT.20.)TSITE=20.
        AP=AP-(4.5/(-0.22+0.0155*TSITE))
        IF(AP.LT.1.)AP=1.
C----------
C  USE SITE INDEX CURVES AS BASIS FOR HEIGHT IN EVEN-AGED STANDS
C  SITE CURVE BREAST HEIGHT AGE, BASE AGE 100 ENG SPRUCE/SALPINE FIR
C  ALEXANDER 1967.  RES PAPER RM32
C----------
        TSITE=SITEAR(ISPC)
        AGETEM = AP
        IF(AGETEM .LT. 30.0) AGETEM = 30.0
        HHE1 = (2.75780*TSITE**0.83312) * ((1.0 - EXP(-0.015701*AGETEM))
     1      **(22.71944*TSITE**(-0.63557))) + 4.5
        IF(AP .LT. AGETEM) HHE1 = ((HHE1 - 4.5) / AGETEM) * AP+4.5
        RATIO = 1.0 - BAUTBA
        IF(RATIO .LT. 0.728) RATIO = 0.728
        HHE1 = HHE1 * RATIO
C
        BATEM=BA
        IF(BATEM .LT. 10.) BATEM=10.
        HHU1 = (-2.04+1.4534*TSITE) * ((1.0-EXP(-0.058112*D))
     &        ** (1.894400 * BATEM ** (-0.192979))) + 4.5
C
        IF(DEBUG)WRITE(JOSTND,*)' IN HTGF 1ST CALL TO GEMHT= ',
     &  HHE1,HHU1,TSITE,D,AP,AGETEM,BAUTBA,RATIO
C
        AGEFUT = AP + 10.0
        AGETEM = AGEFUT
        IF(AGETEM .LT. 30.0) AGETEM = 30.0
        DFUT=D + DGI/BARK
        HHE2 = (2.75780*TSITE**0.83312) * ((1.0 - EXP(-0.015701*AGETEM))
     1      **(22.71944*TSITE**(-0.63557))) + 4.5
        IF(AGEFUT .LT. AGETEM) HHE2=((HHE2 - 4.5) / AGETEM) * AGEFUT+4.5
        RATIO = 1.0 - BAUTBA
        IF(RATIO .LT. 0.728) RATIO = 0.728
        HHE2 = HHE2 * RATIO
C
        BATEM=BA
        IF(BATEM .LT. 10.) BATEM=10.
        HHU2 = (-2.04+1.4534*TSITE) * ((1.0-EXP(-0.058112*DFUT))
     &        ** (1.894400 * BATEM ** (-0.192979))) + 4.5
C
        IF(DEBUG)WRITE(JOSTND,*)' IN HTGF 2ND CALL TO GEMHT= ',
     &  HHE2,HHU2,TSITE,DFUT,AGEFUT,AGETEM,BAUTBA,RATIO
C
C----------
C IF EVEN-AGED,UNEVEN-AGED AND BA .LT. 70, OR UNEVEN-AGED AND PCT(I)
C IS .GE.40 (OVERSTORY) THEN HTG(I) IS EVEN-AGED HT GROWTH ESTIMATE.
C----------
        HTG(I) = (HHE2 - HHE1)*ADJUST
C----------
C IF STAND IS UNEVEN-AGED AND BA IS .GE. TO 70 THEN USE A BLEND.
C TREES WITH PCT() .LE. 10 (OVERTOPPED TREES) GET UNEVEN-AGED
C HEIGHT GROWTH; TREES WITH PCT() .GT. 10 AND .LT. 40 GET A
C WEIGHTED AVERAGE OF EVEN/UNEVEN-AGED HEIGHT GROWTH.
C----------
        IF(AGERNG .GT. 40.0 .AND. BA .GE. 70.0) THEN
          IF(PCT(I) .LE. 10.)HTG(I) = HHU2 - HHU1
          IF((PCT(I) .GT. 10.0) .AND. (PCT(I) .LT. 40.0)) THEN
            HGE = (HHE2 - HHE1)*ADJUST
            HGU = HHU2 - HHU1
            XWT = ((PCT(I)-10.)*(10./3.))/100.
            HTG(I) = XWT*HGE + (1.0-XWT)*HGU
          ENDIF
        ENDIF
C----------
C     ADD RANDOM INCREMENT TO HTG.  GETS AWAY FROM ALL TREES HAVING
C     THE SAME INCREMENT (ESP UNDER EDMINSTERS EVEN-AGED LOGIC).
C----------
  189   CONTINUE
        ZZRAN = 0.0
        IF(DGSD .GT. 0.0) THEN
          ZZRAN=BACHLO(0.0,1.0,RANN)
          IF(ZZRAN .GT. DGSD .OR. ZZRAN .LT. (-DGSD)) GO TO 189
          IF(DEBUG)WRITE(JOSTND,9984) I,HTG(I),ZZRAN,SCALE
 9984     FORMAT(1H ,'IN HTGF 9984 FORMAT',I5,2X,3(F10.4,2X))
        ENDIF
        HTG(I) = HTG(I) + ZZRAN*0.1
C----------
C  IF STAGNATION EFFECT IS ON FOR THIS SPECIES,
C  ONLY REDUCE HT GROWTH BY HALF OF DSTAG, NOT DSTAG. DIXON 3-9-93
C----------
        IF(ISTAGF(ISPC).NE.0)HTG(I)=HTG(I)*(DSTAG+1.0)*.5
        IF(HTG(I) .LT. 0.1) HTG(I) = 0.1
        IF(DEBUG)
     &  WRITE(JOSTND,*)' HTGF I,ISPC,XWT,HHE1,HHE2,HHU1,HHU2,HT,HTG = ',
     &                I,ISPC,XWT,HHE1,HHE2,HHU1,HHU2,HT(I),HTG(I)
C
C----------
C  SPECIES WITH SURROGATE EQUATIONS FROM THE SO VARIANT
C  MC, BI
C  THESE SPECIES GET THEIR HEIGHT GROWTH FROM **REGENT**. CODE HERE
C  IS FROM THE SOURCE VARIANT, BUT ESTIMATE IS NOT USED.
C----------
      CASE(13,16)
        SITAGE = 0.0
        SITHT = 0.0
        AGMAX = 0.0
        HTMAX = 0.0
        HTMAX2 = 0.0
        D1 = DBH(I)
        D2 = 0.0
        IF(DEBUG)WRITE(JOSTND,*)' IN HTGF, CALLING FINDAG I= ',I
        CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,
     &              DEBUG)
C
        SINDX = SITEAR(ISPC)
        BAL=((100.0-PCT(I))/100.0)*BA
        H=HT(I)
        D=DBH(I)
        IF(H .GE. HTMAX)THEN
          HTG(I)=0.1
          HTG(I)=SCALE*HTG(I)*XHMULT(ISPC)*EXP(HTCON(ISPC))
          GO TO 161
        ENDIF
        IF (SITAGE .GT. AGMAX) THEN
          POTHTG= 0.10
          GO TO 1320
        ELSE
          AGP10= SITAGE+10.0
        ENDIF
        HGUESS = (SINDX - 4.5) / ( 0.6192 - 5.3394/(SINDX - 4.5)
     &   + 240.29 * AGP10**(-1.4) +(3368.9/(SINDX - 4.5))*AGP10**(-1.4))
        HGUESS = HGUESS + 4.5
        IF(DEBUG)WRITE(JOSTND,*)' SINDX,ISPC,AGP10,I,HGUESS= '
        IF(DEBUG)WRITE(JOSTND,*) SINDX,ISPC,AGP10,I,HGUESS
C
        POTHTG= HGUESS-SITHT
C
        IF(DEBUG)WRITE(JOSTND,*)' I, ISPC, AGP10, SITHT,HGUESS= ',
     &  I, ISPC, AGP10, SITHT,HGUESS
C
 1320   CONTINUE
C----------
C  HEIGHT GROWTH MODIFIERS
C----------
        IF(DEBUG)WRITE(JOSTND,*) ' AT 1320 CONTINUE FOR TREE',I,' HT= ',
     &  HT(I),' AVH= ',AVH
        RELHT = 0.0
        IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
        IF(RELHT .GT. 1.5)RELHT=1.5
C-----------
C     REVISED HEIGHT GROWTH MODIFIER APPROACH.
C-----------
C     CROWN RATIO CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
C     GROWTH PEAKS IN MID-RANGE OF CR, DECREASES SOMEWHAT FOR LARGE
C     CROWN RATIOS DUE TO PHOTOSYNTHETIC ENERGY PUT INTO CROWN SUPPORT
C     RATHER THAN HT. GROWTH.  CROWN RATIO FOR THIS COMPUTATION NEEDS
C     TO BE IN (0-1) RANGE; DIVIDE BY 100.  FUNCTION IS HOERL'S
C     SPECIAL FUNCTION (REF. P.23, CUTHBERT&WOOD, FITTING EQNS. TO DATA
C     WILEY, 1971).  FUNCTION OUTPUT CONSTRAINED TO BE 1.0 OR LESS.
C-----------
        HGMDCR = (CRA * (ICR(I)/100.0)**CRB) * EXP(CRC*(ICR(I)/100.0))
        IF (HGMDCR .GT. 1.0) HGMDCR = 1.0
C-----------
C     RELATIVE HEIGHT CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
C     GROWTH IS ENHANCED BY STRONG TOP LIGHT AND HINDERED BY HIGH
C     SHADE EVEN IF SOME LIGHT FILTERS THROUGH.  ALSO RESPONSE IS
C     GREATER FOR GIVEN LIGHT AS SHADE TOLERANCE INCREASES.  FUNCTION
C     IS GENERALIZED CHAPMAN-RICHARDS (REF. P.2 DONNELLY ET AL. 1992.
C     THINNING EVEN-AGED FOREST STANDS...OPTIMAL CONTROL ANALYSES.
C     USDA FOR. SERV. RES. PAPER RM-307).
C     PARTS OF THE GENERALIZED CHAPMAN-RICHARDS FUNCTION USED TO
C     COMPUTE HGMDRH BELOW ARE SEGMENTED INTO FACTORS
C     FOR PROGRAMMING CONVENIENCE.
C-----------
        SELECT CASE (ISPC)
        CASE(16)
          RHB = (-1.45)
          RHR = 15.0
          RHM = 1.10
          RHYXS = 0.10
        CASE(13)
          RHB = (-1.10)
          RHR = 20.0
          RHM = 1.10
          RHYXS = 0.20
        END SELECT
        RHX = RELHT
        FCTRKX = ( (RHK/RHYXS)**(RHM-1.0) ) - 1.0
        FCTRRB = -1.0*( RHR/(1.0-RHB) )
        FCTRXB = RHX**(1.0-RHB) - RHXS**(1.0-RHB)
        FCTRM  = -1.0/(RHM-1.0)
C
        IF (DEBUG)
     &  WRITE(JOSTND,*) ' HTGF-HGMDRH FACTORS = ',
     &  ISPC, RHX, FCTRKX, FCTRRB, FCTRXB, FCTRM
C
        HGMDRH = RHK * ( 1.0 + FCTRKX*EXP(FCTRRB*FCTRXB) ) ** FCTRM
C-----------
C     APPLY WEIGHTED MODIFIER VALUES.
C-----------
        WTCR = .25
        WTRH = 1.0 - WTCR
        HTGMOD = WTCR*HGMDCR + WTRH*HGMDRH
C----------
C    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C    MULTIPLIED BY XHMULT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C----------
        IF(DEBUG) THEN
          WRITE(JOSTND,*)' IN HTGF, I= ',I,' ISPC= ',ISPC,'HTGMOD= ',
     &    HTGMOD,' ICR= ',ICR(I),' HGMDCR= ',HGMDCR
          WRITE(JOSTND,*)' HT(I)= ',HT(I),' AVH= ',AVH,' RELHT= ',RELHT,
     &   ' HGMDRH= ',HGMDRH
        ENDIF
C
        IF (HTGMOD .GE. 2.0) HTGMOD= 2.0
        IF (HTGMOD .LE. 0.0) HTGMOD= 0.1
C
 1322   HTG(I) = POTHTG * HTGMOD
C
        HTNOW=HT(I)+POTHTG
        IF(DEBUG)WRITE(JOSTND,901)ICR(I),PCT(I),BA,DG(I),HT(I),
     &  POTHTG,BAL,AVH,HTG(I),DBH(I),RMAI,HGUESS
  901   FORMAT(' HTGF',I5,13F9.2)
C
  999   CONTINUE
C-----------
C    HEIGHT GROWTH EQUATION, EVALUATED FOR EACH TREE EACH CYCLE
C    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C    MULTIPLIED BY XHMULT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C    CHECK FOR HT GT MAX HT FOR THE SITE AND SPECIES
C----------
        TEMPH=H + HTG(I)
        IF(TEMPH .GT. HTMAX)THEN
          HTG(I)=HTMAX - H
        ENDIF
        IF(HTG(I).LT.0.1)HTG(I)=0.1
C
  161   CONTINUE
        IF(DEBUG)WRITE(JOSTND,*)
     &  ' I,SCALE,HTG,HTMAX, H= ',I,SCALE,HTG(I),HTMAX, H
C
C----------
C  ORIGINAL TETONS SPECIES (1-3,6-9,17)
C  BLUE SPRUCE (5) AND ROCKY MTN MAPLE (14)
C----------
      CASE DEFAULT
C----------
C    CHANGE THE CROWN RATIO TO AN INTEGER BETWEEN 0 AND 10
C----------
      IICR= ICR(I)/10.0 + 0.5
C
C    PLACE THE CROWN RATIO INTO ONE OF THREE GROUPS
C
      IF(IICR .GT. 9) IICR=9
      GO TO(101,101,102,102,102,102,102,103,103),IICR
  101 KEYCR=1
      GO TO 110
  102 KEYCR=2
      GO TO 110
  103 KEYCR=3
  110 CONTINUE
C
C CALCULATE ROW IDENT FOR SBB COEF LOOKUP
C
  160 CONTINUE
      IF(ISPC .LE. 10)THEN
        JSPC=ISPC
      ELSEIF(ISPC .EQ. 14)THEN
        JSPC=6
      ELSE
        JSPC=11
      ENDIF
      K=(JSPC- 1)*3  + KEYCR
      IF(DEBUG)WRITE(JOSTND,9101)(COF(L,K),L=1,9)
 9101 FORMAT(' COFS= ',9F10.4)
C
C  CHECK IF HEIGHT OR DBH EXCEED PARAMETERS
C
  170 CONTINUE
      IF (HT(I).LE. 4.5) GOTO 180
      IF((XI1 + COF(1,K)) .LE. DBH(I)) GO TO 180
      IF((XI2 + COF(2,K)) .LE. HT(I)) GO TO 180
C----------
C  TRAP TO AVOID LOG(0) ERRORS WITH XI1 AND XI2; HTG WILL COME FROM
C  REGENT FOR THESE SMALL OF TREES ANYWAY.  GED 05/07/09
C
      IF(DBH(I) .LE. 0.1 .OR. HT(I).LE. 4.5)GO TO 180
C----------
      GO TO 190
  180 CONTINUE
C
C    THE SBB IS UNDEFINED IF CERTAIN INPUT VALUES EXCEED PARAMETERS IN
C    THE FITTED DISTRIBUTION.  IN INPUT VALUES ARE EXCESSIVE THE HEIGHT
C    GROWTH IS TAKEN TO BE 0.1 FOOT.
C
      HTG(I) = 0.1
      GO TO 200
  190 CONTINUE
C
C CALCULATE ALPHA FOR THE TREE USING SCHREUDER + HAFLEY
C
      Y1=(DBH(I) - XI1)/COF(1,K)
      Y2=(HT(I) - XI2)/COF(2,K)
      FBY1=ALOG(Y1/(1.0 - Y1))
      FBY2= ALOG(Y2/(1.0 - Y2))
      Z=( COF(4,K) + COF(6,K)*FBY2 - COF(7,K)*( COF(3,K) +
     +   COF(5,K)*FBY1))*(1.0 - COF(7,K)**2)**(-0.5)
C
C THE HT DIA MODEL NEEDS MODIFICATION TO CORRECT KNOWN BIAS
C
      ZBIAS=AZBIAS(ISPC)+BZBIAS(ISPC)*ELEV
      IF(ISPC.EQ.6 .OR. ISPC.EQ.14)
     &  ZBIAS=AZBIAS(ISPC)+BZBIAS(ISPC)*(ELEV-20.)
      IF(ELEV .LT. 55. .OR. ELEV .GT. 80.0)ZBIAS=0.0
      ZTEST=Z-ZBIAS
      IF(ZTEST .GE. 2.0 .AND. ZBIAS .LT. 0.0)ZBIAS=0.0
      Z=Z-ZBIAS
      IF(ISPC.EQ.6 .OR. ISPC.EQ.14)THEN
        ZADJ = .1 - .10273*Z + .00273*Z*Z
        IF(ZADJ .LT. 0.0)ZADJ=0.0
        Z=Z+ZADJ
      ENDIF
C
C YOUNG SMALL LODGEPOLE HTG ACCELLERATOR BASED ON TARGHEE HTG
C TEMP BYPASS
C
      IF((ICYC .GT. 1) .OR. (IAGE .LE. 0))GO TO 184
      IXAGE=IAGE + IY(ICYC) -IY(1)
C
      IF(DEBUG)
     &WRITE(JOSTND,*)' I, ISPC, IXAGE= ',I, ISPC, IXAGE
C
      IF(IXAGE .LT. 40. .AND. IXAGE .GT. 10. .AND. DBH(I)
     &     .LT. 9.0)THEN
          IF(Z .GT. 2.0) GO TO 184
         ZADJ=.3564*DG(I)*FINT/YR
          CLOSUR=PCT(I)/100.0
          IF(RELDEN .LT. 100.0)CLOSUR=1.0
      IF(DEBUG)WRITE(JOSTND,9650)ZBIAS,ELEV,IXAGE,ZADJ,FINT,YR,
     &     DG(I),CLOSUR
 9650 FORMAT(' ZBIAS',F8.0,'ELEV',F6.1,'AGE',F5.0,'ZADJ',
     &   F10.4,'FINT',F6.0,'YR',F6.0,'DG',F10.3,'CLOSUR',F10.1)
          ZADJ=ZADJ*CLOSUR
C
C ADJUSTMENT IS HIGHER FOR LONG CROWNED TREES
C
      IF(IICR .EQ. 9 .OR. IICR .EQ. 8)ZADJ=ZADJ*1.1
        Z=Z + ZADJ
        IF(Z .GT. 2.0)Z=2.0
      END IF
  184 CONTINUE
C
C CALCULATE DIAMETER AFTER 10 YEARS
C
      DIA= DBH(I) + DG(I)/BARK
      IF((XI1 + COF(1,K)) .GT. DIA) GO TO 185
      HTG(I)=0.1
      GO TO 200
  185 CONTINUE
C
C  CALCULATE HEIGHT AFTER 10 YEARS
C
      PSI= COF(8,K)*((DIA-XI1)/(XI1 + COF(1,K) - DIA))**COF(9,K)
     +     * (EXP(Z*((1.0 - COF(7,K)**2  ))**0.5/COF(6,K)))
C
      H= ((PSI/(1.0 + PSI))* COF(2,K)) + XI2
C
      IF(.NOT. DEBUG)GO TO 191
      WRITE(JOSTND,9631)DBH(I),DIA,HT(I),DG(I),Z ,H
 9631 FORMAT(1X,'IN HTGF DIA=',F7.3,'DIA+10=',F7.3,'H=',F7.1,
     & 'DIA GR=',F8.3,'Z=',E15.8,'NEW H=',F8.1)
  191 CONTINUE
C
C  CALCULATE HEIGHT GROWTH
C   NEGATIVE HEIGHT GROWTH IS NOT ALLOWED
C
      IF(H .LT. HT(I)) H=HT(I)
      HTG(I)= H - HT(I)
      IF(HTG(I).LT.0.1)HTG(I)=0.1
C
  200 CONTINUE
C
      END SELECT
C
  201 CONTINUE
      HTG(I)=HTG(I)*SCALE*XHMULT(ISPC)*EXP(HTCON(ISPC))
C----------
C    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
C    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
C----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
      TEMHTG=HTG(I)
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF
C
      IF(.NOT.LTRIP)GO TO 30
      ITFN=ITRN + 2*I - 1
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
      IF(DEBUG)WRITE(JOSTND,9001)HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT('  LOWER HTG = ',F8.4,'  UPPER HTG = ',F8.4)
C--------------
C   END OF TREE LOOP
C--------------
   30 CONTINUE
C--------------
C   END OF SPECIES LOOP
C--------------
   40 CONTINUE
      RETURN
C
      ENTRY HTCONS
C----------
C  LOAD HTCON.  IF CORRECTION TERMS ARE TO BE USED, MODIFY ACCORDINGLY
C----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
      RETURN
      END
