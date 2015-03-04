      SUBROUTINE ISSTAG
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C   INITIALIZE THE STAND STRUCTURAL STAGE CLASSES CALCULATIONS.
C   SEE SUBROUTINE SSTAGE.
C
C   N.L.CROOKSTON - INT MOSCOW - JUNE 1996 AND WITH
C   A.R.STAGE - INT MOSCOW - JUNE 1997
C
      INCLUDE 'SSTGMC.F77'
C
      LOGICAL LON,LPRT
      INTEGER I,J

C     INITIALIZE THE STAND STRUCTURAL STAGE ROUTINE.

      ISTRCL= 0
      LCALC = .FALSE.
      LPRNT = .TRUE.
      SSDBH = 5.
      SAWDBH= 25.
      GAPPCT= 30.
      PCTSMX= 30.
      CCMIN = 5.
      TPAMIN = 200.
      IRREF = -1
      DO I = 1,33
        DO J = 1,2
          OSTRST(I,J) = 0
        ENDDO
      ENDDO
      RETURN

      ENTRY RQSSTG (LON,LPRT)

C     ENTRY USED TO REQUEST STRUCTURE CLASSIFICATION WITHOUT KEYWORDS

      LCALC = LON
      LPRNT = LPRT

      END
