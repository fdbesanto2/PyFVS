      SUBROUTINE ESSUBH (I,HHT,EMSQR,DILATE,DELAY,ELEV,ISER,GENTIM,
     &  TRAGE)
      IMPLICIT NONE
C----------
C NC $Id: essubh.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C
C     ASSIGNS HEIGHTS TO SUBSEQUENT AND PLANTED TREE RECORDS
C     CREATED BY THE ESTABLISHMENT MODEL.
C
C
C     COMING INTO ESSUBH, TRAGE IS THE AGE OF THE TREE AS SPECIFIED ON
C     THE PLANT OR NATURAL KEYWORD.  LEAVING ESSUBH, TRAGE IS THE NUMBER
C     BETWEEN PLANTING (OR NATURAL REGENERATION) AND THE END OF THE
C     CYCLE.  AGE IS TREE AGE UP TO THE TIME REGENT WILL BEGIN GROWING
C     THE TREE.
C----------
C  COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ESPARM.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C----------
C  DECLARATIONS
C----------
      INTEGER I,ISER,N,ITIME
      REAL    HHT,DELAY,DILATE,ELEV,EMSQR,GENTIM,TRAGE,AGE
      REAL DANUW
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      DANUW = DILATE
      DANUW = ELEV
      DANUW = EMSQR
      DANUW = REAL(ISER)
C----------
      N=INT(DELAY+0.5)
      IF(N.LT.-3) N=-3
      DELAY=FLOAT(N)
      ITIME=INT(TIME+0.5)
      IF(N.GT.ITIME) DELAY=TIME
      AGE=TIME-DELAY-GENTIM+TRAGE
      IF(AGE.LT.1.0) AGE=1.0
      TRAGE=TIME-DELAY
      SELECT CASE (I)
C
C     HEIGHT OF TALLEST SUBSEQUENT SPECIES 1 (OC)
C
      CASE (1)
      HHT = 1.0
C
C     HEIGHT OF TALLEST SUBS. SPECIES 2 (SP)
C
      CASE (2)
      HHT = 1.0
C
C     HT OF TALLEST SUBS. SPECIES 3 (DF)
C
      CASE (3)
      HHT = 1.0
C
C     HT OF TALLEST SUBS. SPECIES 4 (WF)
C
      CASE (4)
      HHT = 1.0
C
C     HT OF TALLEST SUBS. SPECIES 5 ( M)
C
      CASE (5)
      HHT = 7.0
C
C     HT OF TALLEST SUBS. SPECIES 6 (IC)
C
      CASE (6)
      HHT = 1.0
C
C     HT OF TALLEST SUBS. SPECIES 7 (BO)
C
      CASE (7)
      HHT = 7.0
C
C     HT OF TALLEST SUBS. SPECIES 8 (TO)
C
      CASE (8)
      HHT = 7.0
C
C     HT OF TALLEST SUBS. SPECIES 9 (RF)
C
      CASE (9)
      HHT = 1.0
C
C     HEIGHT OF TALLEST SUBS. SPECIES 10 (PP)
C
      CASE (10)
      HHT = 0.8
C
C     HT OF TALLEST SUBS. SPECIES 11 (OH)
C
      CASE (11)
      HHT = 7.0
C
      END SELECT
      RETURN
      END
C**END OF CODE SEGMENT





