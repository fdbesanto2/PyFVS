      FUNCTION BRATIO(IS,D,H)
      use prgprm_mod
      implicit none
C----------
C  **BRATIO--CI  DATE OF LAST REVISION:  08/27/13
C----------
C FUNCTION TO COMPUTE BARK RATIOS AS A FUNCTION OF DIAMETER AND SPECIES.
C REPLACES ARRAY BKRAT IN BASE MODEL.
C----------
COMMONS
C----------
C     SPECIES LIST FOR CENTRAL IDAHO VARIANT.
C
C     1 = WESTERN WHITE PINE (WP)          PINUS MONTICOLA
C     2 = WESTERN LARCH (WL)               LARIX OCCIDENTALIS
C     3 = DOUGLAS-FIR (DF)                 PSEUDOTSUGA MENZIESII
C     4 = GRAND FIR (GF)                   ABIES GRANDIS
C     5 = WESTERN HEMLOCK (WH)             TSUGA HETEROPHYLLA
C     6 = WESTERN REDCEDAR (RC)            THUJA PLICATA
C     7 = LODGEPOLE PINE (LP)              PINUS CONTORTA
C     8 = ENGLEMANN SPRUCE (ES)            PICEA ENGELMANNII
C     9 = SUBALPINE FIR (AF)               ABIES LASIOCARPA
C    10 = PONDEROSA PINE (PP)              PINUS PONDEROSA
C    11 = WHITEBARK PINE (WB)              PINUS ALBICAULIS
C    12 = PACIFIC YEW (PY)                 TAXUS BREVIFOLIA
C    13 = QUAKING ASPEN (AS)               POPULUS TREMULOIDES
C    14 = WESTERN JUNIPER (WJ)             JUNIPERUS OCCIDENTALIS
C    15 = CURLLEAF MOUNTAIN-MAHOGANY (MC)  CERCOCARPUS LEDIFOLIUS
C    16 = LIMBER PINE (LM)                 PINUS FLEXILIS
C    17 = BLACK COTTONWOOD (CW)            POPULUS BALSAMIFERA VAR. TRICHOCARPA
C    18 = OTHER SOFTWOODS (OS)
C    19 = OTHER HARDWOODS (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE IE VARIANT:
C      USE 17(PY) FOR 12(PY)             (IE17 IS REALLY TT2=LM)
C      USE 18(AS) FOR 13(AS)             (IE18 IS REALLY UT6=AS)
C      USE 13(LM) FOR 11(WB) AND 16(LM)  (IE13 IS REALLY TT2=LM)
C      USE 19(CO) FOR 17(CW) AND 19(OH)  (IE19 IS REALLY CR38=OH)
C
C  FROM THE UT VARIANT:
C      USE 12(WJ) FOR 14(WJ)
C      USE 20(MC) FOR 15(MC)             (UT20 = SO30=MC, WHICH IS
C                                                  REALLY WC39=OT)
C----------
      REAL BARK1(MAXSP),BARK2(MAXSP),H,D,BRATIO,DIB,TEMD
      INTEGER IS
C----------
C  DATA STATEMENTS
C----------
      DATA BARK1/
     &   .859045, .900000, .903563, .904973, .903563,
     &   .837291, .900000, .900000, .903563, .809427,
     &     0.969,   0.969,   0.950,     0.0,     0.9,
     &     0.969,   0.892, .900000,   0.892/
      DATA BARK2/
     &       0.0,     0.0, .989388,     0.0, .989388,
     &       0.0,     0.0,     0.0, .989388,1.016866,
     &       0.0,     0.0,     0.0,     0.0,     0.0,
     &       0.0,  -0.086,     0.0,  -0.086/
C
      SELECT CASE (IS)
C
      CASE(3,5,9,10)
      	DIB=BARK1(IS)*D**BARK2(IS)
        IF (D .GT. 0.) THEN
      	  BRATIO=DIB/D
      	ELSE
       	  BRATIO=0.97
      	ENDIF
      	IF (BRATIO .GT. 0.97) BRATIO=0.97
C
      CASE(14)
        TEMD=D
        IF(TEMD.LT.1.)TEMD=1.
        IF(TEMD.GT.19.)TEMD=19.
        BRATIO = 0.9002 - 0.3089*(1/TEMD)
        IF(BRATIO .GT. 0.99) BRATIO=0.99
        IF(BRATIO .LT. 0.80) BRATIO=0.80
C
      CASE(17,19)
        TEMD=D
        IF(TEMD.LT.1.)TEMD=1.
        BRATIO=BARK1(IS)+BARK2(IS)*(1.0/TEMD)
        IF(BRATIO .GT. 0.99) BRATIO=0.99
        IF(BRATIO .LT. 0.80) BRATIO=0.80
C
      CASE DEFAULT
        BRATIO=BARK1(IS)
C
      END SELECT
C
      RETURN
      END
