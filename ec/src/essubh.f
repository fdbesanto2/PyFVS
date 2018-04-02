      SUBROUTINE ESSUBH (I,HHT,EMSQR,DILATE,DELAY,ELEV,IHTSER,GENTIM,
     &                   TRAGE)
      IMPLICIT NONE
C----------
C EC $Id: essubh.f 0000 2018-02-14 00:00:00Z gedixon $
C----------
C     ASSIGNS HEIGHTS TO SUBSEQUENT AND PLANTED TREE RECORDS
C     CREATED BY THE ESTABLISHMENT MODEL.
C     COMING INTO ESSUBH, TRAGE IS THE AGE OF THE TREE AS SPECIFIED ON 
C     THE PLANT OR NATURAL KEYWORD.  LEAVING ESSUBH, TRAGE IS THE NUMBER 
C     BETWEEN PLANTING (OR NATURAL REGENERATION) AND THE END OF THE 
C     CYCLE.  AGE IS TREE AGE UP TO THE TIME REGENT WILL BEGIN GROWING 
C     THE TREE.
C
C     CALLED FROM **ESTAB
C     CALLS **SMHTGF
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'ESPARM.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER I,IHTSER,N,MODE0,ITIME
      REAL    AGE,EMSQR,DILATE,DELAY,ELEV,GENTIM,H,HHT,TRAGE
      REAL RDANUW
      INTEGER IDANUW
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = DILATE
      RDANUW = ELEV
      RDANUW = EMSQR
      IDANUW = IHTSER
C
C----------
      CALL DBCHK (DEBUG,'ESSUBH',6,ICYC)
      IF(DEBUG) 
     &WRITE(JOSTND,*)' ENTERING ESSUBH - ICYC, TRAGE= ',ICYC,TRAGE
C
      N=INT(DELAY+0.5)
      IF(N.LT.-3) N=-3
      DELAY=REAL(N)
      ITIME=INT(TIME+0.5)
      IF(N.GT.ITIME) DELAY=TIME
      AGE=TIME-DELAY-GENTIM+TRAGE
      IF(AGE.LT.1.0) AGE=1.0
      TRAGE=TIME-DELAY
C----------
C  CALL SMHTGF TO CALCULATE SEEDLING HEIGHT AT AGE "AGE".
C----------
      MODE0=0
      CALL SMHTGF (MODE0,ICYC,I,H,AGE,HHT,JOSTND,DEBUG)
C
      IF(DEBUG) THEN
      WRITE(JOSTND,*)' LEAVE ESSUBH -ICYC,I,AGE,TRAGE,TIME,DELAY,HHT= ',
     &ICYC,I,AGE,TRAGE,TIME,DELAY,HHT
      ENDIF
C
      RETURN
      END
