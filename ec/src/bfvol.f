      SUBROUTINE BFVOL(ISPC,D,H,D2H,BBFV,TKILL,LCONE,BARK,VMAX,ITHT,
     1                 BTKFLG)
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use volstd_mod
      use prgprm_mod
      implicit none
C----------
C  **BFVOL--EC   DATE OF LAST REVISION:   05/09/12
C----------
C
C----------
C  ************** BOARD FOOT MERCHANTABILITY SPECIFICATIONS ********
C
C  BFVOL CALCULATES BOARD FOOT VOLUME OF ANY TREE LARGER THAN A MINIMUM
C  DBH SPECIFIED BY THE USER.  MINIMUM DBH CAN VARY BY SPECIES,
C  BUT CANNOT BE LESS THAN 2 INCHES.  MINIMUM MERCHANTABLE DBH IS
C  SET WITH THE BFVOLUME KEYWORD.  FOR METHB = 1-4 MERCHANTABLE
C  TOP DIAMETER CAN BE SET TO ANY VALUE BETWEEN 2 IN. AND MINIMUM DBH.
C  MINIMUM DBH AND TOP DIAMETER ARE ASSUMED TO BE MEASURED OUTSIDE
C  BARK--IF DIB IS DESIRED, ALLOW FOR DOUBLE BARK THICKNESS IN
C  SPECIFICATIONS.
C
C  VOLUME CAN BE COMPUTED BY FORMULA (METHB=1 OR 2) OR BY APPLYING THE
C  REGION 6 LOG RULES (METHB=3 OR 4).
C
C  FOR METHB=1 KEMP'S EQUATIONS ARE USED.  KEMP'S EQUATIONS IMPLY
C  SPECIFIC MERCHANTABILITY STANDARDS WHICH ARE:
C  STANDARDS (9" MINIMUM DBH, 8" MINIMUM TOP DIAMETER, AND 1' STUMP).
C  VOLUME ABOVE THE 8" TOP IS IGNORED.
C
C  ALL PARAMETERS IN THE KEMP EQUATION FORM CAN BE REPLACED BY THE
C  USER WITH THE BFVOLEQU KEYWORD.  IF A USER ENTERS THEIR OWN EQUATION
C  IT IS ASSUMED TO APPLY FROM THE STUMP TO THE MERCH TOP.
C
C  DEFAULT COEFFICIENTS FOR THE KEMP EQUATIONS ARE LOADED IN BLKDAT.
C  VARIANTS OTHER THAN NORTH IDAHO MAY HAVE DEFAULT COEFFICIENTS FOR
C  THE KEMP EQUATION FORM, BUT THEY AREN'T KEMP'S EQUATIONS. IN THIS
C  CASE THE KEMP MERCHANTABILITY STANDARDS STATED ABOVE DO NOT APPLY.
C
C  VOLUME LOSS DUE TO TOP DAMAGE (TKILL=.TRUE.) IS ESTIMATED WITH A
C  BEHRE HYPERBOLA TAPER MODEL, WITH PARAMETERS ESTIMATED FROM TOTAL
C  CUBIC FOOT VOLUME, HEIGHT AND DIAMETER.
C
C  FOR METHB=3 OR 4, BOTH TOTAL VOLUME AND VOLUME LOSS DUE TO TOP
C  DAMAGE ARE COMPUTED WITH THE LOG RULE.
C----------
      LOGICAL LOGOK,LCONE,TKILL,BTKFLG
      CHARACTER VVER*7
      INTEGER ITHT,ISPC,ID,ITD,IVTD,NUMLOG,I,INC,LAST
      REAL SMDIA(20),GLOGLN(20)
      REAL COFBVS(MAXSP),HDRATM(100),D2HBRK(MAXSP)
      REAL VMAX,BARK,BBFV,D2H,H,D,TSIZE,VT,HDRATA,DTOPK,HTRUNC,TD,DIB
      REAL FC,SMDOLD,TLOG,XLOG,SMD,PLEFT,D1SQ,FACTOR
C----------
C  SPECIES LIST FOR EAST CASCADES VARIANT.
C
C   1 = WESTERN WHITE PINE      (WP)    PINUS MONTICOLA
C   2 = WESTERN LARCH           (WL)    LARIX OCCIDENTALIS
C   3 = DOUGLAS-FIR             (DF)    PSEUDOTSUGA MENZIESII
C   4 = PACIFIC SILVER FIR      (SF)    ABIES AMABILIS
C   5 = WESTERN REDCEDAR        (RC)    THUJA PLICATA
C   6 = GRAND FIR               (GF)    ABIES GRANDIS
C   7 = LODGEPOLE PINE          (LP)    PINUS CONTORTA
C   8 = ENGELMANN SPRUCE        (ES)    PICEA ENGELMANNII
C   9 = SUBALPINE FIR           (AF)    ABIES LASIOCARPA
C  10 = PONDEROSA PINE          (PP)    PINUS PONDEROSA
C  11 = WESTERN HEMLOCK         (WH)    TSUGA HETEROPHYLLA
C  12 = MOUNTAIN HEMLOCK        (MH)    TSUGA MERTENSIANA
C  13 = PACIFIC YEW             (PY)    TAXUS BREVIFOLIA
C  14 = WHITEBARK PINE          (WB)    PINUS ALBICAULIS
C  15 = NOBLE FIR               (NF)    ABIES PROCERA
C  16 = WHITE FIR               (WF)    ABIES CONCOLOR
C  17 = SUBALPINE LARCH         (LL)    LARIX LYALLII
C  18 = ALASKA CEDAR            (YC)    CALLITROPSIS NOOTKATENSIS
C  19 = WESTERN JUNIPER         (WJ)    JUNIPERUS OCCIDENTALIS
C  20 = BIGLEAF MAPLE           (BM)    ACER MACROPHYLLUM
C  21 = VINE MAPLE              (VN)    ACER CIRCINATUM
C  22 = RED ALDER               (RA)    ALNUS RUBRA
C  23 = PAPER BIRCH             (PB)    BETULA PAPYRIFERA
C  24 = GIANT CHINQUAPIN        (GC)    CHRYSOLEPIS CHRYSOPHYLLA
C  25 = PACIFIC DOGWOOD         (DG)    CORNUS NUTTALLII
C  26 = QUAKING ASPEN           (AS)    POPULUS TREMULOIDES
C  27 = BLACK COTTONWOOD        (CW)    POPULUS BALSAMIFERA var. TRICHOCARPA
C  28 = OREGON WHITE OAK        (WO)    QUERCUS GARRYANA
C  29 = CHERRY AND PLUM SPECIES (PL)    PRUNUS sp.
C  30 = WILLOW SPECIES          (WI)    SALIX sp.
C  31 = OTHER SOFTWOODS         (OS)
C  32 = OTHER HARDWOODS         (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE EC VARIANT:
C      USE 6(GF) FOR 16(WF)
C      USE OLD 11(OT) FOR NEW 12(MH) AND 31(OS)
C
C  FROM THE WC VARIANT:
C      USE 19(WH) FOR 11(WH)
C      USE 33(PY) FOR 13(PY)
C      USE 31(WB) FOR 14(WB)
C      USE  7(NF) FOR 15(NF)
C      USE 30(LL) FOR 17(LL)
C      USE  8(YC) FOR 18(YC)
C      USE 29(WJ) FOR 19(WJ)
C      USE 21(BM) FOR 20(BM) AND 21(VN)
C      USE 22(RA) FOR 22(RA)
C      USE 24(PB) FOR 23(PB)
C      USE 25(GC) FOR 24(GC)
C      USE 34(DG) FOR 25(DG)
C      USE 26(AS) FOR 26(AS) AND 32(OH)
C      USE 27(CW) FOR 27(CW)
C      USE 28(WO) FOR 28(WO)
C      USE 36(CH) FOR 29(PL)
C      USE 37(WI) FOR 30(WI)
C----------
      DATA D2HBRK/
     &  16917.1, 19231.8, 15763.5, 10016.7, 14883.9,
     &  29922.0,  4567.8,  6024.9, 19425.9, 14034.0,
     &      0.0, 14883.9,     0.0,     0.0,     0.0,
     &  29922.0,     0.0,     0.0,     0.0,     0.0,
     &      0.0,     0.0,     0.0,     0.0,     0.0,
     &      0.0,     0.0,     0.0,     0.0,     0.0,
     &  14883.9,     0.0/
C
      DATA HDRATM/
     &  10.0, 10.0, 9.0, 8.0, 7.8, 7.65, 7.5, 7.25, 7.0, 6.75,
     &   6.5, 6.25, 18*6.0, 10*5.5, 10*5.0, 10*4.5, 10*4.0,
     &  10*3.5, 10*3.0, 10*2.5/
C
      DATA COFBVS/
     &  0.01031, 0.008423, 0.008423, 0.009523, 0.009523,
     & 0.008421,  0.01031, 0.009523, 0.009523, 0.008423,
     &      0.0, 0.009523,      0.0,      0.0,      0.0,
     & 0.008421,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     &      0.0,      0.0,      0.0,      0.0,      0.0,
     & 0.009523,      0.0/
C----------
C  INITIALIZE VOLUME ESTIMATE.
C----------
      BBFV=0.0
C----------
C  TRANSFER TO STATEMENT 300 TO PROCESS WESTERN SIERRA LOG RULES.
C  (METHB=5)
C----------
      IF(METHB(ISPC).EQ.5) GO TO 300
C----------
C  TRANSFER TO STATEMENT 100 TO PROCESS REGION 6 LOG RULES.
C  (METHB= 3 OR 4).
C----------
      IF(METHB(ISPC).EQ.3 .OR. METHB(ISPC).EQ.4) GO TO 100
C----------
C  ASSIGN TRANSITION SIZE.
C----------
      TSIZE=D
      IF(IBTRAN(ISPC).GT.0) TSIZE=D2H
C
      VT=0.0
C
C  BYPASS ALLEN EQUATIONS FOR METHB = 2 OR 7 (USER DEFINED).
C
      IF(METHB(ISPC).EQ.2 .OR. METHB(ISPC).EQ.7) GO TO 15
      HDRATA=H/D
      ID=D-0.5
      IF(ID.GT.100) ID = 100
      ITD=BFTOPD(ISPC)-0.5
      IF(ITD.GT.100) ITD = 100
      IF(D2H.GT.D2HBRK(ISPC)) GO TO 10
C
C  D2H LESS THAN D2H BREAKPOINT: COMPUTE TOP AND STEM VOLUME WITH
C  ALLEN-ADAMS-PRAUSA EQUATIONS.
C
      VT=-COFBVS(ISPC)*(BFTOPD(ISPC)**3*HDRATM(ITD)-80.0)*
     &      SQRT(HDRATA/HDRATM(ID))-
     &      (BFTOPD(ISPC)**2-4.0)*0.12153
      BBFV=COFBVS(ISPC)*D2H+VT
      GO TO 30
C
C  D2H GREATER THAN D2H BREAKPOINT:  COMPUTE TOP VOLUME WITH ALLEN-
C  ADAMS-PRAUSA EQUATIONS AND STEM VOLUME WITH KEMP EQUATIONS.
C
   10 DTOPK=0.4*D
      IF(DTOPK.LT.4.0) DTOPK=4.0
      IF(DTOPK.GT.8.0) DTOPK=8.0
      IVTD=DTOPK-0.5
      VT=COFBVS(ISPC)*SQRT(HDRATA/HDRATM(ID))*(DTOPK**3*HDRATM(IVTD)
     &     -BFTOPD(ISPC)**3*HDRATM(ITD)) -
     &     (DTOPK**2-BFTOPD(ISPC)**2)*0.12153
   15 CONTINUE
C
C--------------------------------------------------
C
      IF(TSIZE.GE.BTRAN(ISPC)) GO TO 20
C
      BBFV = VT + BFVEQS(1,ISPC)
     &     + BFVEQS(2,ISPC)*D
     &     + BFVEQS(3,ISPC)*D*H
     &     + BFVEQS(4,ISPC)*D2H
     &     + BFVEQS(5,ISPC)*D**BFVEQS(6,ISPC)*H**BFVEQS(7,ISPC)
      GO TO 30
   20 CONTINUE
      BBFV = VT + BFVEQL(1,ISPC)
     &     + BFVEQL(2,ISPC)*D
     &     + BFVEQL(3,ISPC)*D*H
     &     + BFVEQL(4,ISPC)*D2H
     &     + BFVEQL(5,ISPC)*D**BFVEQL(6,ISPC)*H**BFVEQL(7,ISPC)
C----------
C  THE FOLLOWING PIECE OF FOOLISHNESS (J.E.B.) IS REQUIRED
C  BY NATIONAL FOREST SCALING AND CRUISING RULES.  BE CAREFUL IF
C  YOU BUY A CORRAL POLE SALE BASED ON A SCRIBNER CRUISE VOLUME.
C----------
   30 CONTINUE
      IF(BBFV.LT.10.0) BBFV=10.0
C----------
C  SET TOPKILL FLAG AND RETURN.
C----------
      BTKFLG = .TRUE.
      RETURN
C
C----------
C  METHB = 3 OR 4:  VOLUME COMPUTED USING ONE OF THE REGION 6 LOG
C  RULES.  MINIMUM DBH FOR LOG RULE IS 4 INCHES.
C----------
  100 CONTINUE
      IF (D.LT. BFMIND(ISPC)) RETURN
C----------
C  LOAD HTRUNC AND H FOR TOP DAMAGED TREES.
C----------
      HTRUNC=0.0
      IF(TKILL) HTRUNC=ITHT/100.0
C----------
C  CALL **FORMCL** TO DETERMINE FORM CLASS
C----------
      TD=BFTOPD(ISPC)*BARK
      DIB=D*BARK
      CALL FORMCL(ISPC,IFOR,D,FC)
C----------
C  CALL **RXDIBS** TO COMPUTE NUMBER OF 16FT LOGS AND EACH SMALL-
C  END DIB
C----------
      CALL RXDIBS(D,FC,H,TD,SMDIA,GLOGLN,NUMLOG,JOSTND)
C----------
C  INITIALIZE:
C     TLOG=CUMULATIVE LENGTH OF LOGS ALREADY PROCESSED.
C     LOGOK=SET TO FALSE WHEN LOG CONTAINING BROKEN TOP IS PROCESSED.
C----------
      SMDOLD=DIB
      TLOG=0.0
      LOGOK=.TRUE.
      IF(METHB(ISPC).EQ.4) GO TO 200
C----------
C  REGION 6 EAST SIDE VOLUME (16 FOOT LOGS).  BRANCH TO STATEMENT 200
C  FOR WESTSIDE CALCULATIONS (32 FOOT LOGS).
C----------
      DO 110 I = 1,NUMLOG
C----------
C  EXIT LOOP IF LAST LOG INCLUDED A BROKEN TOP.
C----------
      IF(.NOT.LOGOK) GO TO 120
      XLOG=GLOGLN(I)
      SMD=SMDIA(I)
C----------
C  SET FLAG AND ADJUST THE TOP DIAMETER AND LOG LENGTH IF THIS LOG
C  CONTAINS A DEAD TOP.
C----------
      IF(TKILL .AND. (TLOG+XLOG).GT.HTRUNC) THEN
        PLEFT=(HTRUNC-TLOG)/XLOG
        IF(PLEFT.LE.0.0) GO TO 120
        XLOG=HTRUNC-TLOG
        D1SQ=SMDOLD*SMDOLD
        SMD=SQRT(D1SQ-PLEFT*(D1SQ-SMD*SMD))
        LOGOK=.FALSE.
      ENDIF
      CALL SCALEF(SMD,XLOG,FACTOR,JOSTND)
      TLOG=TLOG+XLOG
      BBFV=BBFV+XLOG*FACTOR
      SMDOLD=SMD
  110 CONTINUE
  120 CONTINUE
      RETURN
C
C----------
C  REGION 6 WESTSIDE VOLUME.  32 FOOT LOGS; PROCESS EVERY OTHER LOG.
C----------
  200 CONTINUE
      I=0
      INC=2
  205 CONTINUE
      I=I+INC
C----------
C  EXIT LOOP IF LAST LOG INCLUDED A BROKEN TOP.
C----------
      IF(.NOT.LOGOK) GO TO 220
      IF(INC .EQ. 2) THEN
        XLOG=GLOGLN(I)+GLOGLN(I-1)
      ELSE
        XLOG=GLOGLN(I)
      ENDIF
      SMD=SMDIA(I)
C----------
C  SET FLAG AND ADJUST THE TOP DIAMETER AND LOG LENGTH IF THIS LOG
C  CONTAINS A DEAD TOP.
C----------
      IF(TKILL .AND. (TLOG+XLOG).GT.HTRUNC) THEN
        PLEFT=(HTRUNC-TLOG)/XLOG
        IF(PLEFT.LE.0.0) GO TO 220
        XLOG=HTRUNC-TLOG
        D1SQ=SMDOLD*SMDOLD
        SMD=SQRT(D1SQ-PLEFT*(D1SQ-SMD*SMD))
        LOGOK=.FALSE.
      ENDIF
      CALL SCALEF(SMD,XLOG,FACTOR,JOSTND)
      TLOG=TLOG+XLOG
      BBFV=BBFV+XLOG*FACTOR
      SMDOLD=SMD
      IF(I .LT. NUMLOG) THEN
        LAST = NUMLOG - I
        IF(LAST .EQ. 1) INC=1
        GO TO 205
      ENDIF
  220 CONTINUE
      RETURN
C----------
C  WESTERN SIERRA LOG RULES.
C----------
  300 CONTINUE
      ITD=BFTOPD(ISPC)+0.5
      IF(ITD.GT.100) ITD=100
      CALL LOGS(D,H,ITD,BFMIND(ISPC),ISPC,BFSTMP(ISPC),BBFV)
      BTKFLG = .TRUE.
      RETURN
C
      END
