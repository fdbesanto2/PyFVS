      SUBROUTINE EXORGANON
      IMPLICIT NONE
C
C $ID-BASE
C
C  SATISFY EXTERNAL REFRENCES FOR THE ORGANON EXTENSION
C
      LOGICAL DEBUG,LKECHO
      INTEGER I,ITFN,JOSTND,IMODTY
C----------
C  CALLED FROM INITRE
C----------
      ENTRY ORIN(DEBUG,LKECHO)
      RETURN
C----------
C  CALLED FROM TRIPLE
C----------
      ENTRY ORGTRIP(I,ITFN)
      RETURN
C----------
C  CALLED FROM INITRE
C----------
      ENTRY ORGTAB(JOSTND,IMODTY)
      RETURN
C
      END