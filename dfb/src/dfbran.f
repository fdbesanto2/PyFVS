      SUBROUTINE DFBRAN(SEL)
      use prgprm_mod
      implicit none
C----------
C  **DFBRAN DATE OF LAST REVISION:  06/30/10
C----------
C
C  THIS RANDOM NUMBER GENERATED WAS MODIFIED FROM THE ALGORTHM
C  FOUND IN IN THE IMSL LIBRARY VOL 1 EDITION 4 TO 5,
C  DEC. 1, 1975, AND CAN BE FOUND IN THE FOLLOWING REFERENCES:
C
C  LEWIS, P.A.W., GOODMAN, A.S., AND MILLER, J.M. PSUEDO-RANDOM
C  NUMBER GENERATOR FOR THE SYSTEM/360, IBM SYSTEMS JOURNAL, NO. 2,
C  1969.
C
C  LEARMONTH, G.P. AND LEWIS, P.A.W., NAVAL POSTGRADUATE SCHOOL
C  RANDOM NUMBER GENERATOR PACKAGE LLRANDOM, NPS55LW73061A, NAVAL
C  POSTGRADUATE SCHOOL, MONTEREY, CALIFORNIA, JUNE, 1973.
C
C  LEARMONTH, G.P., AND LEWIS, P.A.W., STATISTICAL TESTS OF SOME
C  WIDELY USED AND RECENTLY PROPOSED UNIFORM RANDOM NUMBER
C  GENERATORS. NPS55LW73111A, NAVAL POSTGRADUATE SCHOOL, MONTEREY
C  CALIFORNIA, NOV. 1973.
C
C  THE CODE WAS WRITTEN BY N.L. CROOKSTON, FORESTRY SCIENCES LAB,
C  OCT 1982, FROM THE ALGORITHM PUBLISHED IN THE IMSL MANUAL AND
C  TESTED BY COMPAIRING THE FIRST 10000 DRAWS FORM THIS VERSION AND
C  AND THE GENERATOR 'GGUBS' IN THE 1981 EDITION OF IMSL.
C
C  CALLED BY :
C     DFBGO   [DFB]
C     DFBSCH  [DFB]
C
C  CALLS :
C     NONE
C
C  ENTRY POINTS :
C     DFBNSD
C     DFBGSD
C     DFBCSD
C
C  PARAMETERS :
C     SEL    - THE RANDOM NUMBER GENERATED.
C
C  LOCAL VARIABLES :
C     S0     - SEED VALUE FOR RANDOM NUMBER GENERATOR.
C     S1     - VARIABLE IN RANDOM NUMBER GENERATOR THAT BECOMES THE NEXT
C              SEED VALUE.
C     SS     - HOLDS THE ORIGINAL SEED
C

      LOGICAL LSET
      REAL   SEL, SEED
      DOUBLE PRECISION SS0


      INCLUDE 'CONTRL.F77'

      INCLUDE 'DFBCOM.F77'

      S1 = DMOD(16807D0 * S0, 2147483647D0)
      SEL = S1 / 2147483648D0
      S0 = S1

      RETURN


      ENTRY DFBNSD (LSET,SEED)
C------------------------------
C     THIS ENTRY POINT IS USED TO START THE RANDOM NUMBER GENERATOR
C     OVER OR RESEED THE RANDOM NUMBER GENERATOR.
C
C     PARAMETERS :
C        LSET   - IF SET TO .TRUE. THEN THE RANDOM NUMBER GENERATOR IS
C                 RESEEDED WITH THE VALUE OF SEED.  IF SET TO .FALSE.
C                 THE RANDOM NUMBER GENERATOR WILL BE RESTARTED WITH THE
C                 ORIGINAL SEED.
C        SEED   - THE NEW SEED IF THE RANDOM NUMBER GENERATOR IS BEING
C                 RESEEDED.
C
      IF (LSET) GOTO 10
      SEED = SS
      S0 = SEED
      RETURN

   10 CONTINUE
      IF (AMOD(SEED,2.0) .EQ. 0.0) SEED = SEED + 1.0
      SS = SEED
      S0 = SEED
      RETURN

      ENTRY DFBGSD (SS0)
C------------------------------
C     THIS ENTRY POINT IS USED TO GET THE CURRENT SEED IN THE RANDOM
C     GENERATOR.
C
C     PARAMETERS :
C        SS0    - HOLDS THE CURRENT RANDOM NUMBER SEED (OUTPUT).
C
      SS0 = S0

      RETURN


      ENTRY DFBCSD (SS0)
C------------------------------
C     THIS ENTRY POINT IS USED TO CHANGE THE SEED IN THE RANDOM NUMBER
C     GENERATOR.
C
C     PARAMETERS :
C        SS0    - HOLDS THE NEW RANDOM NUMBER SEED (INPUT).
C
      S0 = SS0

      RETURN
      END
