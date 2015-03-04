      SUBROUTINE SITSET
      use prgprm_mod
      implicit none
C----------
C  **SITSET--WS   DATE OF LAST REVISION:  05/09/12
C----------
C THIS SUBROUTINE LOADS THE SITEAR ARRAY WITH A SITE INDEX FOR EACH
C SPECIES WHICH WAS NOT ASSIGNED A SITE INDEX BY KEYWORD.
C----------
COMMONS
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'VOLSTD.F77'
C
C----------
      LOGICAL DEBUG
      CHARACTER FORST*2,DIST*2,PROD*2,VAR*2,VOLEQ*10
      INTEGER ISPC,I,INTFOR,IREGN,J,JJ,K,IFIASP, ERRFLAG
      REAL SIAGE(MAXSP),SI(MAXSP),SDICON(MAXSP),AG,SINDX,TEMSI
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
      DATA SDICON/
     & 647., 547., 759., 588., 706., 571., 800., 571., 622., 675.,
     & 297., 358., 889., 430., 430., 430., 493., 571., 259., 430.,
     & 470., 547.,1120., 817., 290., 498., 430., 382., 382., 382.,
     & 382., 382., 382., 759., 759., 759., 759., 759., 759., 382.,
     & 353., 624., 382./
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'SITSET',6,ICYC)
C
      IF(ISISP .LE. 0) ISISP=8
      IF(SITEAR(ISISP) .LE. 0.0) SITEAR(ISISP)=100.
C----------
C TRANSLATE THE SITES AND KEEP
C----------
      CALL SICHG(ISISP,SITEAR(ISISP),SIAGE)
C----------
C SI IS A VECTOR X MAXSP GIVING EQUIVALENT SITES FOR EACH SPECIES
C----------
      IF (DEBUG) WRITE(JOSTND,9003)ISISP,SITEAR(ISISP),SIAGE
 9003 FORMAT('SITE SPECIES ',I5,' SITE INDEX ',F10.1,
     &  (/,4X,10F6.1))
C
      DO 25 ISPC=1,MAXSP
      AG=SIAGE(ISPC)
      SINDX=SITEAR(ISISP)
C
      CALL HTCALC(IFOR,SINDX,ISISP,AG,SI(ISPC),JOSTND,DEBUG)
C
   25 CONTINUE
      IF (DEBUG) WRITE(JOSTND,9025) SINDX,ISISP,SI
 9025 FORMAT('SINDX ',F10.2,'SITE SP ',I5/' TRANSLATED SITES ',
     &(/,10F6.1))
C----------
C IF SITEAR() HAS NOT BEEN SET WITH SITECODE KEYWORD, LOAD
C IT WITH SITE VALUES TRANSLATED FROM SITE INDEX OF SITE SPECIES.
C
C FOR GB USE SITE RANGE OF 20-60; FROM TOM MARTIN R4
C FOR MC USE SITE RANGE OF 5-23; FROM JEPSON MANUAL
C THEN TAKE THE SAME PROPORTION OF THE RANGE AS THE RED FIR SITE INDEX IS TO
C THE RANGE 10-134 (WHICH IS THE DOLPH RED FIR RANGE IN THE SO VARIANT).
C----------
      DO 30 I=1,MAXSP
      IF(SITEAR(I) .EQ. 0.0) THEN
        SELECT CASE (I)
        CASE(21)
          TEMSI=SI(7)
          IF(TEMSI .LT. 10.0)TEMSI=10.0
          IF(TEMSI .GT. 134.0)TEMSI=134.0
          SITEAR(I)=20.0+(TEMSI-10.0)/(134.0-10.0)
     &    *(60.0-20.0)
        CASE(41)
          TEMSI=SI(7)
          IF(TEMSI .LT. 10.0)TEMSI=10.0
          IF(TEMSI .GT. 134.0)TEMSI=134.0
          SITEAR(I)=5.0+(TEMSI-10.0)/(134.0-10.0)
     &    *(23.0-5.0)
        CASE DEFAULT
          SITEAR(I)=SI(I)
        END SELECT
      ENDIF
   30 CONTINUE
C----------
C LOAD THE SDIDEF ARRAY
C----------
      DO 40 I=1,MAXSP
        IF(SDIDEF(I) .GT. 0.0) GO TO 40
        IF(BAMAX .GT. 0.) THEN
          SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.))
        ELSE
          SDIDEF(I) = SDICON(I)
        ENDIF
   40 CONTINUE
C
      DO 92 I=1,15
      J=(I-1)*10 + 1
      JJ=J+9
      IF(JJ.GT.MAXSP)JJ=MAXSP
      WRITE(JOSTND,90)(NSP(K,1)(1:2),K=J,JJ)
   90 FORMAT(/'SPECIES ',5X,10(A2,6X))
      WRITE(JOSTND,91)(SDIDEF(K),K=J,JJ )
   91 FORMAT('SDI MAX ',   10F8.0)
      IF(JJ .EQ. MAXSP)GO TO 93
   92 CONTINUE
   93 CONTINUE
C----------
C  LOAD VOLUME EQUATION ARRAYS FOR ALL SPECIES
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      IREGN = KODFOR/100
      DIST='  '
      PROD='  '
      VAR='WS'
C
      DO ISPC=1,MAXSP
      READ(FIAJSP(ISPC),'(I4)')IFIASP
      IF(((METHC(ISPC).EQ.6).OR.(METHC(ISPC).EQ.9)).AND.
     &     (VEQNNC(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNC(ISPC)=VOLEQ
      ENDIF
      IF(((METHB(ISPC).EQ.6).OR.(METHB(ISPC).EQ.9)).AND.
     &     (VEQNNB(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNB(ISPC)=VOLEQ
      ENDIF
      ENDDO
C----------
C  IF FIA CODES WERE IN INPUT DATA, WRITE TRANSLATION TABLE
C---------
      IF(LFIA) THEN
        CALL FIAHEAD(JOSTND)
        WRITE(JOSTND,211) (NSP(I,1)(1:2),FIAJSP(I),I=1,MAXSP)
 211    FORMAT ((T12,8(A3,'=',A6,:,'; '),A,'=',A6))
      ENDIF
C----------
C  WRITE VOLUME EQUATION NUMBER TABLE
C----------
      CALL VOLEQHEAD(JOSTND)
      WRITE(JOSTND,230)(NSP(J,1)(1:2),VEQNNC(J),VEQNNB(J),J=1,MAXSP)
 230  FORMAT(4(2X,A2,4X,A10,1X,A10,1X))
C
      RETURN
      END
