      SUBROUTINE HTGF
      use findage_mod, only: findag
      use htcal_mod
      use multcm_mod
      use pden_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use plot_mod
      use varcom_mod
      use prgprm_mod
      implicit none
!----------
!  **HTGF--EC    DATE OF LAST REVISION:  05/09/12
!----------
!  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
!  INCREMENT FOR EACH CYCLE AND LOADS IT INTO THE ARRAY HTG.
!  THIS ROUTINE IS CALLED FROM **TREGRO** DURING REGULAR CYCLING.
!  ENTRY **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE
!  DEPENDENT CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
!----------
!OMMONS
!----------
      LOGICAL DEBUG
      INTEGER I,ISPC,I1,I2,I3,ITFN
      REAL SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,D1,D2,BARK,BRATIO
      REAL RHR(MAXSP), RHYXS(MAXSP), RHM(MAXSP), RHB(MAXSP)
      REAL CRC,CRB,CRA,RHXS,RHK,HGUESS,SCALE,SINDX,XHT,BAL
      REAL H,POTHTG,RELHT,HGMDCR,RHX,FCTRKX,FCTRRB,FCTRXB,FCTRM
      REAL HGMDRH,WTCR,WTRH,HTGMOD,TEMPH,TEMHTG,AGP10
      REAL MISHGF,MAXGUESS,HGUESS1,HGUESS2,D,TEMPD
!----------
!  SPECIES LIST FOR EAST CASCADES VARIANT.
!
!   1 = WESTERN WHITE PINE      (WP)    PINUS MONTICOLA
!   2 = WESTERN LARCH           (WL)    LARIX OCCIDENTALIS
!   3 = DOUGLAS-FIR             (DF)    PSEUDOTSUGA MENZIESII
!   4 = PACIFIC SILVER FIR      (SF)    ABIES AMABILIS
!   5 = WESTERN REDCEDAR        (RC)    THUJA PLICATA
!   6 = GRAND FIR               (GF)    ABIES GRANDIS
!   7 = LODGEPOLE PINE          (LP)    PINUS CONTORTA
!   8 = ENGELMANN SPRUCE        (ES)    PICEA ENGELMANNII
!   9 = SUBALPINE FIR           (AF)    ABIES LASIOCARPA
!  10 = PONDEROSA PINE          (PP)    PINUS PONDEROSA
!  11 = WESTERN HEMLOCK         (WH)    TSUGA HETEROPHYLLA
!  12 = MOUNTAIN HEMLOCK        (MH)    TSUGA MERTENSIANA
!  13 = PACIFIC YEW             (PY)    TAXUS BREVIFOLIA
!  14 = WHITEBARK PINE          (WB)    PINUS ALBICAULIS
!  15 = NOBLE FIR               (NF)    ABIES PROCERA
!  16 = WHITE FIR               (WF)    ABIES CONCOLOR
!  17 = SUBALPINE LARCH         (LL)    LARIX LYALLII
!  18 = ALASKA CEDAR            (YC)    CALLITROPSIS NOOTKATENSIS
!  19 = WESTERN JUNIPER         (WJ)    JUNIPERUS OCCIDENTALIS
!  20 = BIGLEAF MAPLE           (BM)    ACER MACROPHYLLUM
!  21 = VINE MAPLE              (VN)    ACER CIRCINATUM
!  22 = RED ALDER               (RA)    ALNUS RUBRA
!  23 = PAPER BIRCH             (PB)    BETULA PAPYRIFERA
!  24 = GIANT CHINQUAPIN        (GC)    CHRYSOLEPIS CHRYSOPHYLLA
!  25 = PACIFIC DOGWOOD         (DG)    CORNUS NUTTALLII
!  26 = QUAKING ASPEN           (AS)    POPULUS TREMULOIDES
!  27 = BLACK COTTONWOOD        (CW)    POPULUS BALSAMIFERA var. TRICHOCARPA
!  28 = OREGON WHITE OAK        (WO)    QUERCUS GARRYANA
!  29 = CHERRY AND PLUM SPECIES (PL)    PRUNUS sp.
!  30 = WILLOW SPECIES          (WI)    SALIX sp.
!  31 = OTHER SOFTWOODS         (OS)
!  32 = OTHER HARDWOODS         (OH)
!
!  SURROGATE EQUATION ASSIGNMENT:
!
!  FROM THE EC VARIANT:
!      USE 6(GF) FOR 16(WF)
!      USE OLD 11(OT) FOR NEW 12(MH) AND 31(OS)
!
!  FROM THE WC VARIANT:
!      USE 19(WH) FOR 11(WH)
!      USE 33(PY) FOR 13(PY)
!      USE 31(WB) FOR 14(WB)
!      USE  7(NF) FOR 15(NF)
!      USE 30(LL) FOR 17(LL)
!      USE  8(YC) FOR 18(YC)
!      USE 29(WJ) FOR 19(WJ)
!      USE 21(BM) FOR 20(BM) AND 21(VN)
!      USE 22(RA) FOR 22(RA)
!      USE 24(PB) FOR 23(PB)
!      USE 25(GC) FOR 24(GC)
!      USE 34(DG) FOR 25(DG)
!      USE 26(AS) FOR 26(AS) AND 32(OH)
!      USE 27(CW) FOR 27(CW)
!      USE 28(WO) FOR 28(WO)
!      USE 36(CH) FOR 29(PL)
!      USE 37(WI) FOR 30(WI)
!----------
!  COEFFICIENTS--CROWN RATIO (CR) BASED HT. GRTH. MODIFIER
!----------
      CRA = 100.0
      CRB = 3.0
      CRC = -5.0
!----------
!  COEFFICIENTS--RELATIVE HEIGHT (RH) BASED HT. GRTH. MODIFIER
!----------
      RHK = 1.0
      RHXS = 0.0
!----------
!  COEFFS BASED ON SPECIES SHADE TOLERANCE AS FOLLOWS:
!                                   RHR  RHYXS    RHM    RHB
!        VERY TOLERANT             20.0   0.20    1.1  -1.10
!        TOLERANT                  16.0   0.15    1.1  -1.20
!        INTERMEDIATE              15.0   0.10    1.1  -1.45
!        INTOLERANT                13.0   0.05    1.1  -1.60
!        VERY INTOLERANT           12.0   0.01    1.1  -1.60
!  IN THE EC VARIANT, SILVICS OF NORTH AMERICA (AG.HNDBK-654)
!  WAS USED TO GET SHADE TOLERANCE.
!  SEQ. NO.   CHAR. CODE    SHADE TOL.   SEQ. NO.  CHAR. CODE    SHADE TOL.
!      1      WP            INTM            17     LL            VINT
!      2      WL            VINT            18     YC            TOLN
!      3      DF            INTM            19     WJ            INTL
!      4      SF            VTOL            20     BM            VTOL
!      5      RC            VTOL            21     VN            VTOL
!      6      GF            TOLN            22     RA            INTL
!      7      LP            VINT            23     PB            INTL
!      8      ES            TOLN            24     GC            INTM
!      9      AF            TOLN            25     DG            VTOL
!     10      PP            INTL            26     AS            VINT
!     11      WH            VTOL            27     CW            VINT
!     12      MH            INTM            28     WO            INTM
!     13      PY            VTOL            29     PL            INTL
!     14      WB            INTM            30     WI            VINT
!     15      NF            INTM            31     OS            INTM
!     16      WF            TOLN            32     OH            VINT
!----------
      RHR = (/ &
        15.0,  12.0,  15.0,  20.0,  20.0, &
        16.0,  12.0,  16.0,  16.0,  13.0, &
        20.0,  15.0,  20.0,  15.0,  15.0, &
        16.0,  12.0,  16.0,  13.0,  20.0, &
        20.0,  13.0,  13.0,  15.0,  20.0, &
        12.0,  12.0,  15.0,  13.0,  12.0, &
        15.0,  12.0/)

      RHYXS = (/ &
        0.10,  0.01,  0.10,  0.20,  0.20, &
        0.15,  0.01,  0.15,  0.15,  0.05, &
        0.20,  0.10,  0.20,  0.10,  0.10, &
        0.15,  0.01,  0.15,  0.05,  0.20, &
        0.20,  0.05,  0.05,  0.10,  0.20, &
        0.01,  0.01,  0.10,  0.05,  0.01, &
        0.10,  0.01/)

      RHM = (/ &
        1.10,  1.10,  1.10,  1.10,  1.10, &
        1.10,  1.10,  1.10,  1.10,  1.10, &
        1.10,  1.10,  1.10,  1.10,  1.10, &
        1.10,  1.10,  1.10,  1.10,  1.10, &
        1.10,  1.10,  1.10,  1.10,  1.10, &
        1.10,  1.10,  1.10,  1.10,  1.10, &
        1.10,  1.10/)

      RHB = (/ &
       -1.45, -1.60, -1.45, -1.10, -1.10, &
       -1.20, -1.60, -1.20, -1.20, -1.60, &
       -1.10, -1.45, -1.10,  0.10, -1.45, &
       -1.20, -1.60, -1.20, -1.60, -1.10, &
       -1.10, -1.60, -1.60, -1.45, -1.10, &
       -1.60, -1.60, -1.45, -1.60, -1.60, &
       -1.45, -1.60/)
!----------
!  SEE IF WE NEED TO DO SOME DEBUG.
!-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTGF CYCLE =',I5)

      IF(DEBUG)WRITE(JOSTND,*) 'IN HTGF AT BEGINNING,HTCON=', &
      HTCON,'RMAI=',RMAI,'ELEV=',ELEV
      SCALE=FINT/YR
!----------
!  GET THE HEIGHT GROWTH MULTIPLIERS.
!----------
      CALL MULTS (2,IY(ICYC),XHMULT)
      IF(DEBUG)WRITE(JOSTND,*)'HTGF- ISPC,IY(ICYC),XHMULT= ',ISPC, &
       IY(ICYC), XHMULT
!----------
!   BEGIN SPECIES LOOP:
!----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      SINDX = SITEAR(ISPC)
      XHT=XHMULT(ISPC)
!-----------
!   BEGIN TREE LOOP WITHIN SPECIES LOOP
!-----------
      DO 30 I3=I1,I2
      I=IND1(I3)
      BAL=((100.0-PCT(I))/100.0)*BA
      H=HT(I)
      HTG(I)=0.

      SITAGE = 0.0
      SITHT = 0.0
      AGMAX = 0.0
      HTMAX = 0.0
      HTMAX2 = 0.0
      D1 = DBH(I)
      BARK=BRATIO(ISPC,D1,H)
      D2 = D1 + DG(I)/BARK
      IF (PROB(I).LE.0.0) GO TO 161
      IF(DEBUG)WRITE(JOSTND,*)' IN HTGF, CALLING FINDAG I= ',I
      CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,DEBUG)

      SELECT CASE (ISPC)

!  SPECIES USING EQUATIONS FROM THE WC VARIANT

      CASE(11,13:15,17:30,32)
!----------
!  CHECK TO SEE IF TREE HT/DBH RATIO IS ABOVE THE MAXIMUM RATIO AT
!  THE BEGINNING OF THE CYCLE. THIS COULD HAPPEN FOR TREES COMING
!  OUT OF THE ESTAB MODEL.  IF IT IS, THEN CHECK TO SEE IF THE
!  HT/NEWDBH RATIO IS ABOVE THE MAXIMUM.  IF THIS IS ALSO TRUE, LIMIT
!  HTG TO 0.1 FOOT OR HALF THE DG, WHICH EVER IS GREATER.
!  IF IT ISN'T, THEN LET HTG BE COMPUTED THE NORMAL
!  WAY AND THEN CHECK IT AGAIN AT THAT POINT.
!----------
        IF(H .GT.HTMAX) THEN
          IF(H .GE. HTMAX2) THEN
            HTG(I)=0.5 * DG(I)
            IF(HTG(I).LT.0.1)HTG(I)=0.1
            HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
          ENDIF
          GO TO 161
        ENDIF

!  SPECIES USING EQUATIONS FROM THE EC VARIANT

      CASE DEFAULT
        IF(H .GE. HTMAX)THEN
          HTG(I)=0.1
          HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
          GO TO 161
        END IF
      END SELECT
!----------
!  NORMAL HEIGHT INCREMENT CALCULATON BASED ON TREE AGE
!  FIRST CHECK FOR MAXIMUM TREE AGE
!----------
      IF (SITAGE .GE. AGMAX) THEN
        POTHTG= 0.10
!----------
! THE FOLLOWING 5 LINES ARE AN RJ FIX 7-28-88
!----------
        IF(ISPC .EQ. 10) THEN
          POTHTG = -1.31 + 0.05 * SINDX
          IF(POTHTG .LT. 0.1) POTHTG = 0.1
        ENDIF
        GO TO 1320
      ELSE
        AGP10 = SITAGE+10.
      ENDIF
!----------
!   CALL HTCALC FOR NORMAL CYCLING
!----------
      HGUESS = 0.0
      CALL HTCALC(SINDX,ISPC,AGP10,HGUESS,JOSTND,DEBUG)
      POTHTG= HGUESS-SITHT
!----------
!  PATCH FOR OREGON WHITE OAK - WORK BY GOULD AND HARRINGTON, PNW
!  USES A HT-DBH EQUATION MODIFIED BY SI AND BA, FIRST PREDICTS
!  HEIGHT GUESS BASED ON PREVIOUS DIAMETER AND THEN PREDICT THE
!  HEIGHT GUESS BASED ON PRESENT DIAMETER, SUBTRACT GUESSES
!  TO CALCULATE HEIGHT GROWTH.
!----------
      IF (ISPC .EQ. 28) THEN
!----------
!  CALCULATE MAX HEIGHT BASED ON SI, THEN MODIFY BASED ON BA
!----------
        MAXGUESS = SINDX - 18.6024/ALOG(2.7 + BA)
!----------
!  DUB HEIGHT BASED ON PRESENT DBH
!----------
        D2 = DBH(I) + DG(I)
        IF (D2 .LT. 0.) D2 = 0.1
        HGUESS2 = 4.5 + MAXGUESS*(1-EXP(-0.137428*D2))**1.38994
!----------
!  DUB HEIGHT BASED ON PAST DBH
!----------
        HGUESS1 = 4.5 + MAXGUESS*(1-EXP(-0.137428*D1))**1.38994
!----------
!  DIFFERENCE OF TWO DUBBED HEIGHTS IS POTENTIAL HEIGHT GROWTH
!----------
        POTHTG = HGUESS2 - HGUESS1
      ENDIF
!--End OWO PATCH

      IF(DEBUG)WRITE(JOSTND,*)' I,ISPC,AGP10,SITHT,HGUESS,POTHTG= ', &
       I,ISPC,AGP10,SITHT,HGUESS,POTHTG
!----------
!  HEIGHT GROWTH MUST BE POSITIVE
!----------
      IF(POTHTG .LT. 0.1)POTHTG= 0.1
!----------
! ASSIGN A POTENTIAL HTG FOR THE ASYMPTOTIC AGE
!----------
 1320 CONTINUE
!----------
!  HEIGHT GROWTH MODIFIERS
!----------
      RELHT = 0.0
      IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
      IF(RELHT .GT. 1.5)RELHT=1.5
!----------
!     REVISED HEIGHT GROWTH MODIFIER APPROACH.
!----------
!     CROWN RATIO CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
!     GROWTH PEAKS IN MID-RANGE OF CR, DECREASES SOMEWHAT FOR LARGE
!     CROWN RATIOS DUE TO PHOTOSYNTHETIC ENERGY PUT INTO CROWN SUPPORT
!     RATHER THAN HT. GROWTH.  CROWN RATIO FOR THIS COMPUTATION NEEDS
!     TO BE IN (0-1) RANGE; DIVIDE BY 100.  FUNCTION IS HOERL'S
!     SPECIAL FUNCTION (REF. P.23, CUTHBERT&WOOD, FITTING EQNS. TO DATA
!     WILEY, 1971).  FUNCTION OUTPUT CONSTRAINED TO BE 1.0 OR LESS.
!----------
      HGMDCR = (CRA * (ICR(I)/100.0)**CRB) * EXP(CRC*(ICR(I)/100.0))
      IF (HGMDCR .GT. 1.0) HGMDCR = 1.0
!----------
!     RELATIVE HEIGHT CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
!     GROWTH IS ENHANCED BY STRONG TOP LIGHT AND HINDERED BY HIGH
!     SHADE EVEN IF SOME LIGHT FILTERS THROUGH.  ALSO RESPONSE IS
!     GREATER FOR GIVEN LIGHT AS SHADE TOLERANCE INCREASES.  FUNCTION
!     IS GENERALIZED CHAPMAN-RICHARDS (REF. P.2 DONNELLY ET AL. 1992.
!     THINNING EVEN-AGED FOREST STANDS...OPTIMAL CONTROL ANALYSES.
!     USDA FOR. SERV. RES. PAPER RM-307).
!     PARTS OF THE GENERALIZED CHAPMAN-RICHARDS FUNCTION USED TO
!     COMPUTE HGMDRH BELOW ARE SEGMENTED INTO FACTORS
!     FOR PROGRAMMING CONVENIENCE.
!----------
      RHX = RELHT
      FCTRKX = ( (RHK/RHYXS(ISPC))**(RHM(ISPC)-1.0) ) - 1.0
      FCTRRB = -1.0*( RHR(ISPC)/(1.0-RHB(ISPC)) )
      FCTRXB = RHX**(1.0-RHB(ISPC)) - RHXS**(1.0-RHB(ISPC))
      FCTRM  = -1.0/(RHM(ISPC)-1.0)

      IF (DEBUG) &
      WRITE(JOSTND,*) ' HTGF-HGMDRH FACTORS = ', &
      ISPC, RHX, FCTRKX, FCTRRB, FCTRXB, FCTRM

      HGMDRH = RHK * ( 1.0 + FCTRKX*EXP(FCTRRB*FCTRXB) ) ** FCTRM
!----------
!     APPLY WEIGHTED MODIFIER VALUES.
!----------
      WTCR = .25
      WTRH = 1.0 - WTCR
      HTGMOD = WTCR*HGMDCR + WTRH*HGMDRH
!----------
!    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
!    MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
!----------

      IF(DEBUG) THEN
        WRITE(JOSTND,*)' IN HTGF, I= ',I,' ISPC= ',ISPC,'HTGMOD= ', &
        HTGMOD,' ICR= ',ICR(I),' HGMDCR= ',HGMDCR
        WRITE(JOSTND,*)' HT(I)= ',HT(I),' AVH= ',AVH,' RELHT= ',RELHT, &
       ' HGMDRH= ',HGMDRH
      ENDIF

      IF (HTGMOD .GE. 2.0) HTGMOD= 2.0
      IF (HTGMOD .LE. 0.0) HTGMOD= 0.1

      HTG(I) = POTHTG * HTGMOD

      IF(DEBUG)    WRITE(JOSTND,901)ICR(I),PCT(I),BA,DG(I),HT(I), &
       POTHTG,BAL,AVH,HTG(I),DBH(I),RMAI,HGUESS
  901 FORMAT(' HTGF',I5,14F9.2)
!----------
!  HEIGHT GROWTH EQUATION, EVALUATED FOR EACH TREE EACH CYCLE
!  MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
!  MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
!----------
! CHECK FOR HT GT MAX HT FOR THE SITE AND SPECIES

      TEMPH=H + HTG(I)
      SELECT CASE (ISPC)
      CASE(11,13:15,17:30,32)
        IF(TEMPH .GT. HTMAX2) HTG(I)=HTMAX2-H
      CASE DEFAULT
        IF(TEMPH .GT. HTMAX) HTG(I)=HTMAX-H
      END SELECT
      IF(HTG(I).LT.0.1)HTG(I)=0.1
      HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
      IF(DEBUG) WRITE(JOSTND,*)' I=',I,' TEMPH=',TEMPH,' TEMPD=', &
          TEMPD,' D=',DBH(I),' DG=',DG(I),' H=',H,' HTG=',HTG(I), &
          ' HTMAX2=',HTMAX2
  161 CONTINUE
!----------
!    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
!    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
!----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
      TEMHTG=HTG(I)
!----------
! CHECK FOR SIZE CAP COMPLIANCE.
!----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF

      IF(.NOT.LTRIP) GO TO 30
      ITFN=ITRN+2*I-1
      HTG(ITFN)=TEMHTG
!----------
! CHECK FOR SIZE CAP COMPLIANCE.
!----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF

      HTG(ITFN+1)=TEMHTG
!----------
! CHECK FOR SIZE CAP COMPLIANCE.
!----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF

      IF(DEBUG) WRITE(JOSTND,9001) HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)
!----------
!   END OF TREE LOOP
!----------
   30 CONTINUE
!----------
!   END OF SPECIES LOOP
!----------
   40 CONTINUE
      IF(DEBUG)WRITE(JOSTND,60)ICYC
   60 FORMAT(' LEAVING SUBROUTINE HTGF   CYCLE =',I5)
      RETURN

      ENTRY HTCONS
!----------
!  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
!  ARE SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.
!  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
!----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)= &
          HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE

      RETURN
      END
