      SUBROUTINE BWEEST
      use prgprm_mod
      implicit none
C----------
C  **BWEEST                 DATE OF LAST REVISION:  07/14/10
C----------
C
C     SETS THE YEARS BW-CAUSED DEFOLIATION OCCURED IN IBWHST
C     THEREBY PROVIDING THE LINKS BETWEEN THE BUDWORM MODEL AND
C     THE ESTABLISHMENT MODEL.  CALLED BY BWCUPL.
C
C     PART OF THE WESTERN SPRUCE BUDWORM MODEL/PROGNOSIS LINKAGE CODE.
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--JANUARY 1984
c
c     minor changes by K.Sheehan 7/96 to remove IDBLVL
C
C  Revision History:
C    17-MAY-2005 Lance R. David (FHTET)
C       Added FVS parameter file PRGPRM.F77.
C    14-JUL-2010 Lance R. David (FMSC)
C-----------------------------------------------------------
C
      INCLUDE 'ESWSBW.F77'
      INCLUDE 'BWESTD.F77'
      INCLUDE 'BWECOM.F77'
C
      INTEGER I, IHERE, IHOST, ISZI
      REAL XXX

C     FIND THE MAXIMUM AMOUNT OF DEFOLIATON IN FOR ANY HOST, AND
C     ANY TREE SIZE.
C
      IHERE=-1
      XXX=1.0
      DO 20 IHOST=1,6
      IF (IFHOST(IHOST).NE.1) GOTO 20
      DO 10 ISZI=1,3
      IF (APRBYR(IHOST,ISZI,2,ICUMYR).LT.XXX)
     >           XXX=APRBYR(IHOST,ISZI,2,ICUMYR)
   10 CONTINUE
   20 CONTINUE
C
C     IF THE DEFOLIATION IS GREATER THAN A CRITICAL VALUE, THEN THE
C     YEAR IS "ADDED" TO THE LIST OF BUDWORM YEARS.
C
      IF (XXX.LT. .90) THEN
C
C        CHECK OUT THE ENTRIES IN IBWHST.  IF THE LIST IS EMPTY,
C        BRANCH TO ADD.
C
         IF (NBWHST.LE.0) THEN
            IHERE=1
            NBWHST=1
            GOTO 100
         ENDIF
C
C        IF THE YEAR IS ALREADY IN THE HISTORY, WERE DONE.
C
         IHERE=0
         DO 30 I=1,NBWHST
         IF (IYRCUR.GE.IBWHST(1,I).AND.IYRCUR.LE.IBWHST(2,I)) GOTO 200
   30    CONTINUE
C
C        SEE IF THE CURRENT BUDWORM YEAR CAN BE ADDED TO AN ENTRY.
C
         DO 40 I=1,NBWHST
         IF (IYRCUR-IBWHST(2,I).EQ.1) THEN
            IHERE=I
            IBWHST(2,I)=IYRCUR
            GOTO 200
         ENDIF
   40    CONTINUE
C
C        IS THERE ROOM IN THE LIST, IF YES, BRANCH TO ADD ENTRY.
C
         IF (NBWHST.LT.20) THEN
            NBWHST=NBWHST+1
            IHERE=NBWHST
            GOTO 100
         ENDIF
C
C        FIND THE OLDEST ENTRY (BASED ON THE "ENDING" DATE), AND
C        ADD THE ENTRY AT THAT LOCATION.
C
         IHERE=1
         DO 70 I=2,NBWHST
         IF (IBWHST(2,I).LT.IBWHST(2,IHERE)) IHERE=I
   70    CONTINUE
      ENDIF
C
C	Added work-arround to avoid array out of bounds when
C	 starting defoliation model in middle of cycle (RNH Dec 98)
C
      IF (IHERE .EQ. -1) GO TO 200
C
C     ADD THE ENTRY AT LOCATION "IHERE"
C
  100 CONTINUE
      IBWHST(1,IHERE)=IYRCUR
      IBWHST(2,IHERE)=IYRCUR
  200 CONTINUE
C
      RETURN
      END
