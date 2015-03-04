      SUBROUTINE DUNN (SS)
      use prgprm_mod
      implicit none
C----------
C  **DUNN--WS    DATE OF LAST REVISION:  05/09/12
C----------
C THIS SUBROUTINE PROCESSES THE DUNNING CODE INFORMATION THAT WAS
C ENTERED BY KEYWORD.
C
C WHEN A DUNNING CODE IS ENTERED (IE ANY OF THE SITEAR VALUES BETWEEN
C 0 AND 7)  THEN SITE VALUES FOR ALL SPECIES ARE AUTOMATICALLY SET.  IF
C ANY SITEAR VALUES ARE BETWEEN 8 AND 10 THIS IS AN ERROR AND THE
C DEFAULT VALUE SPECIFIED IN GRINIT IS MAINTAINED. THIS ROUTINE IS
C CALLED FROM INITRE.
C----------
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'CONTRL.F77'
C
C----------
      INTEGER IST,ISPC,I
      REAL ADJFAC(MAXSP),DUNN50(8),XST2(8),SS,DU50,DUNN99(8),DU99
C----------
C     SPECIES LIST FOR WESTERN SIERRAS VARIANT.
C
C     1 = SUGAR PINE (SP)                   PINUS LAMBERTIANA
C     2 = DOUGLAS-FIR (DF)                  PSEUDOTSUGA MENZIESII
C     3 = WHITE FIR (WF)                    ABIES CONCOLOR
C     4 = GIANT SEQUOIA (GS)                SEQUOIADENDRON GIGANTEAUM
C     5 = INCENSE CEDAR (IC)                LIBOCEDRUS DECURRENS
C     6 = JEFFREY PINE (JP)                 PINUS JEFFREYI
C     7 = CALIFORNIA RED FIR (RF)           ABIES MAGNIFICA
C     8 = PONDEROSA PINE (PP)               PINUS PONDEROSA
C     9 = LODGEPOLE PINE (LP)               PINUS CONTORTA
C    10 = WHITEBARK PINE (WB)               PINUS ALBICAULIS
C    11 = WESTERN WHITE PINE (WP)           PINUS MONTICOLA
C    12 = SINGLELEAF PINYON (PM)            PINUS MONOPHYLLA
C    13 = PACIFIC SILVER FIR (SF)           ABIES AMABILIS
C    14 = KNOBCONE PINE (KP)                PINUS ATTENUATA
C    15 = FOXTAIL PINE (FP)                 PINUS BALFOURIANA
C    16 = COULTER PINE (CP)                 PINUS COULTERI
C    17 = LIMBER PINE (LM)                  PINUS FLEXILIS
C    18 = MONTEREY PINE (MP)                PINUS RADIATA
C    19 = GRAY PINE (GP)                    PINUS SABINIANA
C         (OR CALIFORNIA FOOTHILL PINE)
C    20 = WASHOE PINE (WE)                  PINUS WASHOENSIS
C    21 = GREAT BASIN BRISTLECONE PINE (GB) PINUS LONGAEVA
C    22 = BIGCONE DOUGLAS-FIR (BD)          PSEUDOTSUGA MACROCARPA
C    23 = REDWOOD (RW)                      SEQUOIA SEMPERVIRENS
C    24 = MOUNTAIN HEMLOCK (MH)             TSUGA MERTENSIANA
C    25 = WESTERN JUNIPER (WJ)              JUNIPERUS OCIDENTALIS
C    26 = UTAH JUNIPER (UJ)                 JUNIPERUS OSTEOSPERMA
C    27 = CALIFORNIA JUNIPER (CJ)           JUNIPERUS CALIFORNICA
C    28 = CALIFORNIA LIVE OAK (LO)          QUERCUS AGRIFOLIA
C    29 = CANYON LIVE OAK (CY)              QUERCUS CHRYSOLEPSIS
C    30 = BLUE OAK (BL)                     QUERCUS DOUGLASII
C    31 = CALIFORNIA BLACK OAK (BO)         QUERQUS KELLOGGII
C    32 = VALLEY OAK (VO)                   QUERCUS LOBATA
C         (OR CALIFORNIA WHITE OAK)
C    33 = INTERIOR LIVE OAK (IO)            QUERCUS WISLIZENI
C    34 = TANOAK (TO)                       LITHOCARPUS DENSIFLORUS
C    35 = GIANT CHINQUAPIN (GC)             CHRYSOLEPIS CHRYSOPHYLLA
C    36 = QUAKING ASPEN (AS)                POPULUS TREMULOIDES
C    37 = CALIFORNIA-LAUREL (CL)            UMBELLULARIA CALIFORNICA
C    38 = PACIFIC MADRONE (MA)              ARBUTUS MENZIESII
C    39 = PACIFIC DOGWOOD (DG)              CORNUS NUTTALLII
C    40 = BIGLEAF MAPLE (BM)                ACER MACROPHYLLUM
C    41 = CURLLEAF MOUNTAIN-MAHOGANY (MC)   CERCOCARPUS LEDIFOLIUS
C    42 = OTHER SOFTWOODS (OS)
C    43 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C    FROM EXISTING WS EQUATIONS --
C      USE 1(SP) FOR 11(WP) AND 24(MH)
C      USE 2(DF) FOR 22(BD)
C      USE 3(WF) FOR 13(SF)
C      USE 4(GS) FOR 23(RW)
C      USE 8(PP) FOR 18(MP)
C      USE 34(TO) FOR 35(GC), 36(AS), 37(CL), 38(MA), AND 39(DG)
C      USE 31(BO) FOR 28(LO), 29(CY), 30(BL), 32(VO), 33(IO), 40(BM), AND
C                     43(OH)
C
C    FROM CA VARIANT --
C      USE CA11(KP) FOR 12(PM), 14(KP), 15(FP), 16(CP), 17(LM), 19(GP), 20(WE),
C                       25(WJ), 26(WJ), AND 27(CJ)
C      USE CA12(LP) FOR 9(LP) AND 10(WB)
C
C    FROM SO VARIANT --
C      USE SO30(MC) FOR 41(MC)
C
C    FROM UT VARIANT --
C      USE UT17(GB) FOR 21(GB)
C----------
C  DATA STATEMENTS
C----------
      DATA ADJFAC/
     & 0.90, 1.00, 1.00, 1.00, 0.76, 1.00, 1.00, 1.00, 0.90, 0.90,
     & 0.90, 1.00, 1.00, 0.90, 0.90, 0.90, 0.90, 1.00, 0.90, 0.90,
     & 0.00, 1.00, 1.00, 0.90, 0.90, 0.90, 0.90, 0.60, 0.45, 0.45,
     & 1.00, 0.60, 0.50, 0.60, 0.50, 0.75, 0.55, 0.60, 0.50, 0.50,
     & 1.00, 0.90, 0.57/
C
      DATA DUNN50/ 106.,  90.,  75.,  56.,  49.,  39.,  31.,  23./
      DATA DUNN99/ 140., 121., 102.,  81.,  67.,  54.,  44.,  36./
C----------
C
      IST=SS+1.0
      DU50=DUNN50(IST)
      DU99=DUNN99(IST)
C----------
C   SET SITE INDEX VALUES BASED ON DUNNING VALUES ENTERED.
C----------
      DO 20 ISPC=1,MAXSP
C
      SELECT CASE (ISPC)
C----------
C  SPECIES FROM UTAH VARIANT 21=GB
C  EQUATION DERIVED FROM TAKING THE GB SITE RANGE 20-60 AND EQUATING
C  THOSE ENDPOINTS TO THE DUNNING 100-YEAR 36 AND 140, RESPECTIVELY.
C  THEN DERIVING A STRAIGHT LINE ADJUSTMENT RELATIONSHIP BETWEEN THOSE
C  TWO POINTS WITH GB SITE RANGE ON THE Y-AXIS AND DUNNING SITE RANGE
C  ON THE X-AXIS.
C----------
      CASE (21)
        SITEAR(ISPC) = 20.0 + 0.3846*(DU99-36.0)
C----------
C  SPECIES FROM SO VARIANT 41=MC
C----------
      CASE (41)
        SITEAR(ISPC) = DU99 * ADJFAC(ISPC)
C----------
C  ALL OTHER SPECIES
C----------
      CASE DEFAULT
        SITEAR(ISPC) = DU50 * ADJFAC(ISPC)
C
      END SELECT
C
   20 CONTINUE
C
      RETURN
C
C----------
C   WS FIRE MODEL NEEDS SITE INDICES FOR DUNNING CODES.
C----------
      ENTRY GETDUNN(XST2)
      DO I=1,8
      XST2(I) = DUNN50(I)
      ENDDO
      RETURN
C
      END
