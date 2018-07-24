      SUBROUTINE REVISE (VAR,REV)
      IMPLICIT NONE
C----------
C CANADA-BC $Id$
C----------
C    $$ DON'T CHANGE THIS DATE UNLESS THE SUBROUTINE LOGIC CHANGES.
C----------
C
C  THIS ROUTINE PROVIDES THE LATEST REVISION DATE FOR EACH VARIANT
C  WHICH GETS PRINTED IN THE MAIN HEADER ON THE OUTPUT.
C  CALLED FROM GROHED, FILOPN, SUMHED, SUMOUT, ECVOLS, PRTRLS,
C  AND DGDRIV.
C----------
      CHARACTER VAR*7,REV*10

C---------------------------
C NORTH IDAHO -> INTERIOR BC
C---------------------------
      IF(VAR(:2) .EQ. 'BC') THEN
        REV = '10/01/12'
        GO TO 100
      ENDIF
C
  100 CONTINUE
      RETURN
      END
