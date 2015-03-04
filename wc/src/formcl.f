      SUBROUTINE FORMCL(ISPC,IFOR,D,FC)
      use prgprm_mod
      implicit none
C----------
C  **FORMCL--WC     DATE OF LAST REVISION:  05/19/08
C----------
C
C THIS PROGRAM CALCULATES FORM FACTORS FOR CALCULATING CUBIC AND
C BOARD FOOT VOLUMES.
C
      INCLUDE 'CONTRL.F77'
C
C----------
      REAL FC,D
      INTEGER IFOR,ISPC,IFCDBH
      REAL GIFPFC(MAXSP,5),MBSNFC(MAXSP,5),MTHDFC(MAXSP,5)
      REAL ROGRFC(MAXSP,5),UMPQFC(MAXSP,5),WILLFC(MAXSP,5)
      REAL BLM708(MAXSP),BLM709(MAXSP),BLM710(MAXSP),BLM711(MAXSP)
C----------
C  FOREST ORDER: (IFOR)
C  1=GIFFORD PINCHOT(603)  2=MT BAKER/SNOQ(605)  3=MT HOOD(606)
C  4=ROGUE RIVER(610)      5=UMPQUA(615)         6=WILLAMETTE(618)
C  7=BLM SALEM(708)        8=BLM EUGENE(709)     9=BLM ROSEBURG(710)
C 10=BLM MEDFORD/LAKEVIEW(711)
C
C  FOR VALUES NOT SUPPLIED BY BLM, USE THE FOLLOWING FOREST
C  FORM CLASS VALUES FOR THE MIDDLE (21.0"-30.9") DBH RANGE:
C  SALEM --- MT HOOD     EUGENE --- WILLAMETTE
C  ROSEBURG --- UMPQUA   MEDFORD/LAKEVIEW --- ROGUE RIVER
C
C  SPECIES ORDER: (ISPC)
C  1=SF  2=WF  3=GF  4=AF  5=RF  6=    7=NF  8=YC  9=IC 10=ES
C 11=LP 12=JP 13=SP 14=WP 15=PP 16=DF 17=RW 18=RC 19=WH 20=MH
C 21=BM 22=RA 23=WA 24=PB 25=GC 26=AS 27=CW 28=WO 29=J  30=LL
C 31=WB 32=KP 33=PY 34=DG 35=HT 36=CH 37=WI 38=   39=OT
C----------
C  GIFFORD PINCHOT FORM CLASS VALUES
C----------
      DATA GIFPFC/
     & 87., 86., 84., 80., 75., 80., 84., 76., 66., 80., 82.,
     & 75., 72., 84., 76., 82., 75., 70., 86., 82., 74., 74.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 60.,
     & 74., 70., 74., 75., 74., 74.,
C
     & 87., 86., 84., 80., 75., 80., 84., 76., 67., 80., 82.,
     & 75., 74., 84., 76., 82., 75., 70., 86., 82., 74., 74.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 60.,
     & 74., 70., 74., 75., 74., 74.,
C
     & 86., 84., 84., 80., 75., 80., 84., 74., 68., 80., 82.,
     & 75., 75., 84., 78., 80., 75., 68., 84., 82., 74., 74.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 60.,
     & 74., 70., 74., 75., 74., 74.,
C
     & 84., 84., 84., 80., 74., 80., 82., 72., 67., 78., 82.,
     & 74., 75., 82., 80., 79., 74., 68., 84., 80., 74., 74.,
     & 70., 70., 75., 75., 74., 70., 60., 74., 82., 82., 60.,
     & 74., 70., 74., 75., 74., 74.,
C
     & 84., 82., 84., 80., 74., 80., 82., 70., 66., 78., 82.,
     & 74., 78., 82., 82., 78., 74., 68., 82., 80., 74., 74.,
     & 70., 70., 75., 75., 74., 70., 60., 74., 82., 82., 60.,
     & 74., 70., 74., 75., 74., 74./
C----------
C  MOUNT BAKER / SNOQUALMIE FORM CLASS VALUES
C----------
      DATA MBSNFC/
     & 86., 86., 78., 86., 75., 80., 78., 75., 66., 80., 82.,
     & 75., 72., 86., 76., 75., 75., 75., 87., 87., 74., 74.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 56.,
     & 70., 70., 74., 75., 74., 74.,
C
     & 86., 86., 76., 86., 75., 80., 78., 75., 67., 82., 82.,
     & 75., 74., 86., 76., 75., 75., 75., 87., 87., 74., 74.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 60.,
     & 70., 70., 74., 75., 74., 74.,
C
     & 85., 85., 76., 85., 75., 80., 78., 73., 68., 84., 82.,
     & 75., 75., 82., 77., 76., 75., 73., 85., 85., 74., 75.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74.,
C
     & 81., 81., 74., 81., 74., 80., 78., 70., 67., 84., 83.,
     & 74., 75., 82., 77., 77., 74., 70., 85., 85., 74., 75.,
     & 70., 70., 75., 75., 74., 70., 60., 74., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74.,
C
     & 81., 81., 74., 81., 74., 80., 78., 70., 66., 84., 82.,
     & 74., 78., 82., 78., 78., 74., 70., 84., 84., 74., 75.,
     & 70., 70., 75., 75., 74., 70., 60., 74., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74./
C----------
C  MOUNT HOOD FORM CLASS VALUES
C----------
      DATA MTHDFC/
     & 87., 88., 76., 84., 75., 80., 78., 75., 75., 77., 76.,
     & 75., 72., 84., 79., 76., 75., 75., 78., 72., 74., 74.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 60.,
     & 70., 70., 74., 75., 74., 74.,
C
     & 87., 88., 72., 84., 75., 80., 78., 75., 75., 77., 68.,
     & 75., 74., 76., 79., 82., 75., 82., 74., 72., 74., 74.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 60.,
     & 70., 70., 74., 75., 74., 74.,
C
     & 86., 86., 72., 82., 75., 80., 78., 73., 73., 77., 68.,
     & 75., 75., 76., 82., 82., 75., 82., 74., 72., 74., 75.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74.,
C
     & 84., 85., 72., 80., 74., 80., 78., 70., 70., 77., 68.,
     & 74., 75., 76., 83., 82., 74., 82., 74., 72., 74., 75.,
     & 70., 70., 75., 75., 74., 70., 60., 74., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74.,
C
     & 80., 80., 72., 75., 74., 80., 78., 70., 70., 77., 68.,
     & 74., 78., 76., 82., 82., 74., 82., 74., 72., 74., 75.,
     & 70., 70., 75., 75., 74., 70., 60., 74., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74./
C----------
C  ROGUE RIVER FORM CLASS VALUES
C----------
      DATA ROGRFC/
     & 76., 78., 78., 77., 77., 70., 77., 69., 69., 76., 70.,
     & 76., 77., 77., 76., 77., 70., 70., 74., 71., 72., 72.,
     & 72., 70., 72., 72., 72., 66., 70., 70., 75., 70., 72.,
     & 69., 70., 68., 72., 70., 70.,
C
     & 76., 78., 78., 77., 77., 70., 77., 69., 69., 76., 70.,
     & 72., 77., 77., 76., 77., 70., 70., 74., 71., 72., 72.,
     & 72., 70., 72., 72., 72., 66., 70., 70., 75., 70., 72.,
     & 69., 70., 68., 72., 70., 70.,
C
     & 74., 77., 77., 75., 75., 70., 75., 67., 67., 74., 68.,
     & 70., 75., 75., 74., 75., 70., 70., 72., 70., 72., 72.,
     & 72., 70., 72., 72., 72., 66., 70., 70., 73., 68., 72.,
     & 69., 70., 68., 72., 70., 70.,
C
     & 73., 75., 75., 73., 73., 70., 73., 65., 65., 73., 66.,
     & 68., 73., 73., 71., 74., 70., 70., 70., 68., 72., 72.,
     & 72., 70., 72., 72., 72., 66., 70., 70., 72., 66., 72.,
     & 69., 70., 68., 72., 70., 70.,
C
     & 71., 71., 71., 71., 71., 70., 71., 63., 63., 72., 66.,
     & 66., 70., 72., 69., 71., 70., 70., 69., 66., 72., 72.,
     & 72., 70., 72., 72., 72., 66., 70., 70., 71., 66., 72.,
     & 69., 70., 68., 72., 70., 70./
C----------
C  UMPQUA FORM CLASS VALUES
C----------
      DATA UMPQFC/
     & 83., 83., 83., 86., 83., 70., 83., 62., 62., 86., 82.,
     & 77., 75., 78., 77., 77., 75., 70., 87., 77., 75., 75.,
     & 70., 70., 75., 75., 75., 70., 75., 75., 82., 82., 70.,
     & 75., 70., 75., 75., 70., 70.,
C
     & 83., 83., 83., 83., 83., 70., 83., 62., 62., 86., 82.,
     & 77., 75., 78., 77., 77., 75., 70., 87., 77., 75., 75.,
     & 70., 70., 75., 75., 75., 70., 75., 75., 82., 82., 70.,
     & 75., 70., 75., 75., 70., 70.,
C
     & 81., 81., 81., 81., 83., 70., 81., 65., 65., 86., 82.,
     & 78., 78., 78., 78., 76., 75., 68., 87., 76., 75., 75.,
     & 70., 70., 75., 75., 75., 70., 75., 75., 82., 82., 70.,
     & 75., 70., 75., 75., 70., 70.,
C
     & 81., 81., 81., 81., 82., 70., 81., 67., 67., 84., 82.,
     & 80., 76., 78., 80., 74., 74., 68., 87., 74., 75., 75.,
     & 70., 70., 75., 75., 75., 70., 74., 74., 82., 82., 70.,
     & 75., 70., 75., 75., 70., 70.,
C
     & 80., 80., 80., 81., 80., 70., 80., 67., 67., 84., 82.,
     & 80., 74., 76., 80., 74., 74., 68., 87., 74., 75., 75.,
     & 70., 70., 75., 75., 75., 70., 74., 74., 82., 82., 70.,
     & 75., 70., 75., 75., 70., 70./
C----------
C  WILLAMETTE FORM CLASS VALUES
C----------
      DATA WILLFC/
     & 69., 86., 69., 66., 75., 80., 69., 56., 56., 70., 70.,
     & 75., 70., 70., 70., 65., 75., 56., 68., 66., 66., 68.,
     & 70., 70., 75., 75., 68., 70., 60., 75., 82., 82., 56.,
     & 70., 70., 74., 75., 74., 74.,
C
     & 78., 86., 78., 72., 75., 80., 78., 66., 64., 83., 83.,
     & 75., 75., 82., 73., 75., 75., 66., 78., 72., 70., 75.,
     & 70., 70., 75., 75., 84., 70., 60., 75., 82., 82., 60.,
     & 70., 70., 74., 75., 74., 74.,
C
     & 78., 84., 78., 74., 75., 80., 78., 68., 66., 83., 83.,
     & 75., 78., 81., 74., 72., 75., 68., 76., 74., 70., 75.,
     & 70., 70., 75., 75., 82., 70., 60., 75., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74.,
C
     & 80., 84., 78., 74., 74., 80., 80., 68., 66., 82., 80.,
     & 74., 79., 81., 75., 72., 74., 68., 76., 74., 70., 75.,
     & 70., 70., 75., 75., 82., 70., 60., 74., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74.,
C
     & 80., 82., 78., 74., 74., 80., 80., 68., 66., 82., 80.,
     & 74., 80., 80., 75., 72., 74., 68., 76., 74., 74., 75.,
     & 70., 70., 75., 75., 82., 70., 60., 74., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74./
C
      DATA BLM708/
     & 84., 86., 84., 82., 75., 80., 84., 73., 73., 77., 68.,
     & 75., 75., 76., 82., 80., 75., 76., 88., 72., 84., 88.,
     & 70., 70., 75., 75., 74., 70., 60., 75., 82., 82., 60.,
     & 70., 70., 75., 75., 74., 74./
C
      DATA BLM709/
     & 82., 78., 82., 78., 78., 78., 78., 78., 70., 78., 78.,
     & 78., 72., 78., 70., 78., 78., 72., 80., 78., 78., 80.,
     & 78., 78., 80., 78., 82., 78., 78., 78., 78., 78., 78.,
     & 78., 78., 78., 78., 78., 78./
C
      DATA BLM710/
     & 82., 76., 80., 82., 76., 76., 76., 70., 66., 76., 80.,
     & 80., 80., 80., 80., 72., 76., 72., 82., 76., 82., 82.,
     & 76., 76., 76., 76., 76., 76., 76., 76., 80., 80., 76.,
     & 76., 76., 76., 76., 76., 76./
C
      DATA BLM711/
     & 74., 78., 77., 75., 78., 70., 75., 67., 66., 74., 68.,
     & 70., 76., 76., 80., 76., 70., 70., 78., 70., 72., 72.,
     & 72., 70., 72., 72., 72., 66., 70., 70., 73., 68., 72.,
     & 69., 70., 68., 72., 70., 70./
C----------
C  FOR REGION 6 FORESTS, LOAD THE FORM CLASS USING TABLE VALUES.
C  IF A FORM CLASS HAS BEEN ENTERED VIA KEYWORD, USE IT INSTEAD.
C----------
      IF(FRMCLS(ISPC).LE.0.) THEN
        IFCDBH = (D - 1.0) / 10.0 + 1.0
        IF(IFCDBH .LT. 1) IFCDBH=1
        IF(D.GT.40.9) IFCDBH=5
        IF(IFOR.EQ.1) THEN
          FC = GIFPFC(ISPC,IFCDBH)
        ELSEIF(IFOR.EQ.2) THEN
          FC = MBSNFC(ISPC,IFCDBH)
        ELSEIF(IFOR.EQ.3) THEN
          FC = MTHDFC(ISPC,IFCDBH)
        ELSEIF(IFOR.EQ.4) THEN
          FC = ROGRFC(ISPC,IFCDBH)
        ELSEIF(IFOR.EQ.5) THEN
          FC = UMPQFC(ISPC,IFCDBH)
        ELSEIF(IFOR.EQ.6) THEN
          FC = WILLFC(ISPC,IFCDBH)
        ELSEIF(IFOR.EQ.7) THEN
          FC = BLM708(ISPC)
        ELSEIF(IFOR.EQ.8) THEN
          FC = BLM709(ISPC)
        ELSEIF(IFOR.EQ.9) THEN
          FC = BLM710(ISPC)
        ELSE
          FC = BLM711(ISPC)
        ENDIF
      ELSE
        FC=FRMCLS(ISPC)
      ENDIF
C
      RETURN
      END
