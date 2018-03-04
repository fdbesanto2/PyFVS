      SUBROUTINE CVBCAL(HTINDX)
      IMPLICIT NONE
C----------
C COVR $Id: cvbcal.f 0000 2018-02-14 00:00:00Z gary.dixon24@gmail.com $
C----------
C  THIS SUBROUTINE IS CALLED BY **CVBROW** TO COMPUTE CORRECTION
C  FACTORS FOR THE UNDERSTORY SHRUB PREDICTIONS. IT IS ONLY CALLED
C  ONCE DURING THE SIMULATION AT THE START OF THE PROJECTION.
C
C  VARIABLE DEFINITIONS:
C----------
C       ** COMPUTED CORRECTION FACTORS **
C
C-- BHTCF(31) -- SHRUB HEIGHT CORRECTION FACTORS
C-- BPCCF(31) -- SHRUB COVER CORRECTION FACTORS
C-- XCV(31), XPB(31), XSH(31) -- COVER, PROB., AND HEIGHT
C             PREDICTIONS FOR CYCLE # 0, BEFORE CALIBRATION
C----------
C       ** CALIBRATION BY LAYER **
C
C-- AVGBHT(3), AVGBPC(3) -- OBSERVED AVERAGE HEIGHT AND COVER VALUES
C             OF UP TO 3 SHRUB LAYERS INPUT ON THE SHRBLAYR KEYWORD
C             RECORD.  SORTED BY HEIGHT IN **CVIN**:
C             AVGBHT(1) = AVERAGE HEIGHT OF TALLEST SHRUB LAYER,
C             AVGBHT(3) = AVERAGE HEIGHT OF LOWEST SHRUB LAYER
C-- HTAVG(3), CVAVG(3) -- PREDICTED AVERAGE HEIGHT AND COVER
C             VALUES FOR SHRUB LAYERS COMPUTED BY **CVBCAL**
C-- HTFRAC(3), CVFRAC(3) -- RATIO OF OBSERVED/PREDICTED (AVGBHT/HTAVG)
C             HEIGHT OR COVER VALUES BY LAYERS, OR, CORRECTION
C             FACTORS BY LAYER
C-- HTINDX(31) -- SPECIES SUBSCRIPTS SORTED BY DECREASING HEIGHT
C-- IHT(3,2) -- INDEXES HTINDX(31) BY SHRUB LAYER
C-- ILAYR(31) -- LAYER NUMBER WHICH EACH SHRUB SPECIES IS ASSIGNED TO
C-- LCAL1 --  .TRUE. IF CALIBRATION METHOD #1 IS BEING USED
C             (CALIBRATION BY SHRUB LAYER: SHRBLAYR CARD)
C-- NKLASS -- NUMBER OF OBSERVED SHRUB LAYERS (UP TO THREE),
C             IDENTIFIED ON SHRBLAYR KEYWORD CARD
C-- SUMCVR -- TOTAL OBSERVED COVER, EQUAL TO THE SUM OF THE COVER
C             VALUES FOR SHRUB LAYERS INPUT ON THE SHRBLAYR CARD
C-- TOTLCV(MAXCY1,2) -- TOTAL PREDICTED COVER BEFORE CALIBRATION,
C             WEIGHTED BY PB(I), COMPUTED BY **CVBROW** IN CYCLE # 0
C-- RELPC(3) -- RATIO OF OBSERVED COVER VALUES BY LAYER TO TOTAL
C               (AVGBPC(I)/SUMCVR)
C-- SUMHT(3), SUMCV(3), NEXTSP, LASTSP, CUMULI, RCUMPC, DIFF1, DIFF2 --
C             VARIABLES USED TO FIND HEIGHT CLASSES
C----------
C       ** CALIBRATION BY SPECIES **
C
C-- SHRBHT(31), SHRBPC(31) -- OBSERVED HEIGHT AND COVER VALUES
C             FOR SPECIES READ FROM THE SHRUBHT KEYWORD CARD
C-- LCAL2 --  .TRUE. IF CALIBRATION METHOD #2 IS BEING USED
C             (CALIBRATION BY SPECIES: SHRUBHT & SHRUBPC CARDS)
C
C-----------------------------------------------------------------------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'CVCOM.F77'
C
COMMONS
C
      LOGICAL DEBUG
      INTEGER HTINDX(31)
      REAL RELPC(3)
      REAL SUMCV(3),SUMHT(3)
      INTEGER IHT(3,2)
      INTEGER ISPI,I,NEXTSP,J,K,I1,I2,LASTSP
      REAL CUMULI,RCUMPC,DIFF1,DIFF2
C----------
C  CHECK FOR DEBUG.
C----------
      CALL DBCHK(DEBUG,'CVBCAL',6,ICYC)
      IF (DEBUG) WRITE (JOSTND,9000) ICYC
 9000 FORMAT ('**CALLING CVBCAL, CYCLE = ', I3)
C----------
C  SAVE THE UNCALIBRATED PREDICTIONS FOR CYCLE # 0 IN THE ARRAYS XCV,
C  XPB, AND XSH.
C----------
      DO 10 ISPI=1,31
      XCV(ISPI) = PBCV(ISPI)
      XPB(ISPI) = PB(ISPI)
      XSH(ISPI) = SH(ISPI)
   10 CONTINUE
C----------
C  BRANCH TO DESIRED CALIBRATION TECHNIQUE:
C ---------
      IF (LCAL2) GO TO 200
C===============  CALIBRATION METHOD # 1: BY SHRUB LAYER ===============
C  COMPUTE THE RATIO OF OBSERVED PERCENT COVER BY HEIGHT LAYER
C  TO THE TOTAL.
C
C  BECAUSE OF NUMERICAL PROBLEMS IN COMPARING RCUMPC WITH
C  RELPC(I), ADD A LITTLE TO RELPC(I).
C----------
      DO 30 I=1,NKLASS
      RELPC(I) = 0.00001 + AVGBPC(I)/SUMCVR
   30 CONTINUE
C
      IF (DEBUG) WRITE (JOSTND,7000) (AVGBPC(I),I=1,NKLASS),SUMCVR,
     &                 (RELPC(I),I=1,NKLASS)
 7000 FORMAT (7F10.5//)
C----------
C  PROGRESS DOWN THROUGH THE SHRUB SPECIES FROM TALLEST TO SHORTEST
C  (BASED ON FIRST CYCLE HEIGHT PREDICTIONS), AND ACCUMULATE THE
C  INDIVIDUAL SHRUB COVER VALUES (WEIGHTED BY PROBABILITY OF
C  OCCURRENCE). WHEN THIS VALUE ACCOUNTS FOR THE SAME PROPORTION
C  OF TOTAL PREDICTED SHRUB COVER AS INPUT SHRUB LAYER ONE
C  DOES OF THE TOTAL INPUT SHRUB COVER -- STOP; GROUP THOSE
C  SPECIES DOWN TO THE CURRENT SPECIES INTO HEIGHT CLASS ONE.
C  ZERO OUT THE SHRUB COVER CUMULATOR AND CONTINUE ON DOWN THE SPECIES
C  LIST UNTIL "NKLASS" GROUPS HAVE BEEN IDENTIFIED IN THE SAME MANNER.
C  ALL SPECIES MUST BE PLACED INTO A GROUP.
C----------
      NEXTSP = 1
      DO 100 I=1,NKLASS
      IF (NEXTSP .GT. 31) GO TO 130
      IHT(I,1) = NEXTSP
      CUMULI = 0.0
      RCUMPC = 0.0
C----------
C  IF THIS IS THE LAST GROUP: THROW ALL THE REMAINING SPECIES INTO IT.
C----------
      IF ( I .EQ. NKLASS ) GO TO 110
      DO 70 J=NEXTSP,31
      K = HTINDX(J)
      DIFF1 = ABS( RCUMPC - RELPC(I) )
      CUMULI = CUMULI + PBCV(K)
      RCUMPC = CUMULI/TOTLCV(1,1)
      DIFF2 = ABS( RCUMPC - RELPC(I) )
C
      IF (DEBUG) WRITE (JOSTND,7009) I,J,K,PBCV(K),
     &                 CUMULI,RCUMPC,TOTLCV(1,1),RELPC(I),DIFF1,DIFF2
 7009 FORMAT ('70 CONTINUE : I, J, K',3I5,9F10.5)
C
      IF (RELPC(I) .EQ. 0.0) GO TO 80
      IF ( RCUMPC .LE. RELPC(I) ) GO TO 70
C----------
C  PREDICTED COVER RATIO (RCUMPC) HAS JUST EXCEEDED THE OBSERVED
C  COVER RATIO FOR THE CURRENT ILAYER. CHOOSE WHETHER TO KEEP THE LAST
C  SPECIES COVER VALUE IN THE CUMULATED TOTAL DEPENDING ON IF THE
C  MATCH WAS CLOSER PRIOR TO ADDING IN THE LAST SPECIES:
C           IF ( DIFF1 .LE. DIFF2 ) DROP THE LAST SPECIES
C----------
      IF ( DIFF1 .LE. DIFF2 ) GO TO 80
      GO TO 90
   70 CONTINUE
   80 CONTINUE
C----------
C  DROP THE LAST SPECIES
C----------
      CUMULI = CUMULI - PBCV(K)
      IF (DEBUG) WRITE (JOSTND,7010) I,J,K,PBCV(K),
     &                 CUMULI,RCUMPC, TOTLCV(1,1),RELPC(I),DIFF1,DIFF2
 7010 FORMAT ('80 DROP     : I, J, K',3I5,9F10.5)
      LASTSP = J-1
      NEXTSP = J
      IHT(I,2) = LASTSP
      GO TO 100
   90 CONTINUE
C----------
C  KEEP THE LAST SPECIES
C----------
      IF (DEBUG) WRITE (JOSTND,7011) I,J,K,PBCV(K),
     &                  CUMULI,RCUMPC,TOTLCV(1,1),RELPC(I),DIFF1,DIFF2
 7011 FORMAT ('90 KEEP     : I, J, K',3I5,9F10.5)
      LASTSP = J
      NEXTSP = J + 1
      IHT(I,2) = LASTSP
  100 CONTINUE
  110 CONTINUE
      DO 120 J=NEXTSP,31
      K = HTINDX(J)
      CUMULI = CUMULI + PBCV(K)
      IF (DEBUG) WRITE (JOSTND,7012) I,J,K,PBCV(K),
     &                CUMULI
 7012 FORMAT ('120 THE REST: I, J, K',3I5,4F10.5)
  120 CONTINUE
      IHT(NKLASS,2) = 31
  130 CONTINUE
      IF (DEBUG) WRITE (JOSTND,7013) I,NEXTSP,LASTSP
 7013 FORMAT ('130 CONTINUE : I,NEXTSP,LASTSP',3I5)
C----------
C  USING THE CLASS POINTERS DEFINED ABOVE, COMPUTE THE AVERAGE
C  PREDICTED SHRUB HEIGHT AND PERCENT COVER IN EACH HEIGHT CLASS.
C----------
      DO 150 I=1,NKLASS
      IF (AVGBPC(I) .LE. 0.0) GO TO 150
      SUMCV(I) = 0.0
      SUMHT(I) = 0.0
      CVAVG(I) = 0.0
      HTAVG(I) = 0.0
      CVFRAC(I) = 0.0
      HTFRAC(I) = 0.0
      I1 = IHT(I,1)
      I2 = IHT(I,2)
      IF (DEBUG) WRITE (JOSTND,7014) I1,I2
 7014 FORMAT ('150 CONTINUE : I1,I2',2I5)
         IF (I2.LT.I1) GO TO 150
      DO 140 J=I1,I2
         K = HTINDX(J)
         ILAYR(K) = I
         SUMCV(I) = SUMCV(I) + PBCV(K)
         SUMHT(I) = SUMHT(I) + SH(K)
  140 CONTINUE
         CVAVG(I) = SUMCV(I)
         HTAVG(I) = SUMHT(I)/((I2-I1)+1)
  150 CONTINUE
      IF (DEBUG) WRITE (JOSTND,7000) (CVAVG(I),I=1,NKLASS),
     &                 (HTAVG(I),I=1,NKLASS)
C----------
C  COMPUTE THE RATIO OF OBSERVED VALUES TO PREDICTED VALUES FOR AVERAGE
C  SHRUB HEIGHT AND AVERAGE PERCENT COVER IN EACH OF THE HEIGHT LAYERS.
C  ASSIGN CORRECTION FACTORS BASED ON THE RATIOS ABOVE.
C----------
      DO 180 I=1,NKLASS
      IF (AVGBPC(I) .LE. 0.0) GO TO 180
      IF (CVAVG(I).GT.0.0) CVFRAC(I) = AVGBPC(I)/CVAVG(I)
      IF (HTAVG(I).GT.0.0) HTFRAC(I) = AVGBHT(I)/HTAVG(I)
      I1 = IHT(I,1)
      I2 = IHT(I,2)
      IF (I2.LT.I1) GO TO 180
      DO 170 J=I1,I2
      K = HTINDX(J)
      BHTCF(K) = HTFRAC(I)
      BPCCF(K) = CVFRAC(I)
  170 CONTINUE
  180 CONTINUE
      RETURN
  200 CONTINUE
C
C============ CALIBRATION METHOD #2: BY INDIVIDUAL SPECIES ============
C  COMPUTE RATIOS FOR (MEASURED HEIGHT/PREDICTED HEIGHT), AND
C  (MEASURED % COVER/PREDICTED % COVER).
C----------
C       OBSERVED          PROB      CORRECTION FACTORS
C  --------------------------------------------------------------
C  SHRBHT(I)  SHRBPC(I)   PB(I)     BHTCF(I)  BPCCF(I)
C  ---------  ---------   -----     --------  --------
C     < 0.      < 0.      SAME         1.0       1.0
C     < 0.        0.      0.0          0.0       0.0
C     < 0.      > 0.      1.0          1.0    INPUT/PRED
C
C       0.      < 0.      SAME         0.0       0.0
C       0.        0.      0.0          0.0       0.0
C       0.      > 0.      1.0          0.0    INPUT/PRED
C
C     > 0.      < 0.      SAME     INPUT/PRED    1.0
C     > 0.        0.      0.0          0.0       0.0
C     > 0.      > 0.      1.0      INPUT/PRED INPUT/PRED
C
C  IF OBSERVED SHRBPC(I) > 0, THEN PB(I) IS RESET TO 1.0
C  IF OBSERVED SHRBPC(I) = 0, THEN PB(I) IS RESET TO 0.0
C
C----------
      DO 300 ISPI = 1,31
      IF (SHRBPC(ISPI) .GE. 0.0) GO TO 230
      IF (SHRBHT(ISPI) .LT. 0.0) GO TO 300
      IF (SHRBHT(ISPI) .GT. 0.0) GO TO 210
      BPCCF(ISPI) = 0.0
      BHTCF(ISPI) = 0.0
      GO TO 300
C
  210 CONTINUE
      BHTCF(ISPI) = SHRBHT(ISPI)/SH(ISPI)
      GO TO 300
C
  230 CONTINUE
      IF (SHRBPC(ISPI) .GT. 0.0) GO TO 240
      BPCCF(ISPI) = 0.0
      BHTCF(ISPI) = 0.0
      GO TO 300
C
  240 CONTINUE
      BPCCF(ISPI) = SHRBPC(ISPI)/PBCV(ISPI)
C
      IF (SHRBHT(ISPI) .LT. 0.0) GO TO 300
      IF (SHRBHT(ISPI) .GT. 0.0) GO TO 270
      BHTCF(ISPI) = 0.0
      GO TO 300
C
  270 CONTINUE
      BHTCF(ISPI) = SHRBHT(ISPI)/SH(ISPI)
  300 CONTINUE
C
      RETURN
      END
