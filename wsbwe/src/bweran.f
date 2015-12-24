      SUBROUTINE BWERAN(SEL)
      IMPLICIT NONE
C----------
C  **BWERAN                 DATE OF LAST REVISION:  07/14/10
C----------
C
C     BASE RANDOM NUMBER GENERATOR
C
C     PART OF THE WESTERN SPRUCE BUDWORM MODEL.
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB., MOSCOW, ID.--MAY 1983.
C
C     DESCRIPTION :
C
C     THIS RANDOM NUMBER GENERATOR HAS A STOCK SEED FOR MULTIPLE
C     RUNS, OR CAN BE SUPPLIED WITH ANY OTHER SEED.  IT GENERATES
C     A REAL NUMBER BETWEEN 0. AND 1.
C
C     CALLED FROM :
C
C       BWBETA
C       BWRNP  - RANDOM DEFOLIATION GIVEN A MEAN.
C
C     SUBROUTINES CALLED : NONE
C
C     MULTIPLE ENTRIES :
C
C      BWERSD - REINITIALIZE RANDOM NUMBER GENERATOR.
C      BWERPT - RESTORE RANDOM NUMBER SEED.
C      BWERGT - GET RANDOM NUMBER SEED.
C
C     KNOWN MACHINE DEPENDENCIES : NONE
C
C     PARAMETERS :
C
C     SEL - RANDOM NUMBER RETURNED
C
C
C     THIS RANDOM NUMBER GENERATOR WAS MODIFIED FROM THE ALGORTHM
C     FOUND IN IN THE IMSL LIBRARY VOL 1 EDITION 4 TO 5,
C     DEC. 1, 1975, AND CAN BE FOUND IN THE FOLLOWING REFERENCES:
C
C     LEWIS, P.A.W., GOODMAN, A.S., AND MILLER, J.M. PSUEDO-RANDOM
C     NUMBER GENERATOR FOR THE SYSTEM/360, IBM SYSTEMS JOURNAL, NO. 2,
C     1969.
C
C     LEARMONTH, G.P. AND LEWIS, P.A.W., NAVAL POSTGRADUATE SCHOOL
C     RANDOM NUMBER GENERATOR PACKAGE LLRANDOM, NPS55LW73061A, NAVAL
C     POSTGRADUATE SCHOOL, MONTEREY, CALIFORNIA, JUNE, 1973.
C
C     LEARMONTH, G.P., AND LEWIS, P.A.W., STATISTICAL TESTS OF SOME
C     WIDELY USED AND RECENTLY PROPOSED UNIFORM RANDOM NUMBER
C     GENERATORS. NPS55LW73111A, NAVAL POSTGRADUATE SCHOOL, MONTEREY
C     CALIFORNIA, NOV. 1973.
C
C     THE CODE WAS WRITTEN BY N.L. CROOKSTON, FORESTRY SCIENCES LAB,
C     OCT 1982, FROM THE ALGORITHM PUBLISHED IN THE IMSL MANUAL AND
C     TESTED BY COMPAIRING THE FIRST 10000 DRAWS FORM THIS VERSION AND
C     AND THE GENERATOR 'GGUBS' IN THE 1981 EDITION OF IMSL.
C
C  Revision History:
C    14-JUL-2010 Lance R. David (FMSC)
C       Previous noted revision 12/05/90
C       Added IMPLICIT NONE and declared variables as needed.
C----------
      REAL SEED, SEL, SS
      DOUBLE PRECISION S0,S1,DSEED
      LOGICAL LSET
      DATA S0/55329D0/,SS/55329./
C
C
      S1=DMOD(16807D0*S0,2147483647D0)
      SEL=S1/2147483648D0
      S0=S1
C
C     WRITE (44,*) 'BWERAN: SEL= ',SEL                             ! Temp debug
      RETURN
C
C     YOU MAY RESEED THE GENERATOR BY SUPPLYING AN ODD NUMBER OF TYPE
C     REAL WITH LSET=TRUE; IF LSET=FALSE, A CALL TO BWRNSD WILL
C     CAUSE THE RANDOM NUMBER GENERATOR TO START OVER.
C
      ENTRY BWERSD (LSET,SEED)
C
C
      IF (LSET) GOTO 10
      SEED=SS
      S0=SEED
      GOTO 20
   10 CONTINUE
      IF (AMOD(SEED,2.0).EQ.0.) SEED=SEED+1
      SS=SEED
      S0=SEED
   20 CONTINUE
C
      RETURN
C
C     ENTRY POINT TO GET RANDOM NUMBER SEED.
C
      ENTRY BWERGT (DSEED )
      DSEED=S0
      RETURN
C
C     ENTRY POINT TO REPLACE RANDOM NUMBER SEED.
C
      ENTRY BWERPT (DSEED)
      S0=DSEED
      RETURN
      END
