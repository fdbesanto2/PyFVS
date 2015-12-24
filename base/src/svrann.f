      SUBROUTINE SVRANN(SEL)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     THIS RANDOM NUMBER GENERATED WAS MODIFIED FROM THE ALGORTHM
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
C
COMMONS
C
C
      INCLUDE 'SVRCOM.F77'
C
C
COMMONS
C
C
      DOUBLE PRECISION PASSS0
      LOGICAL LSET
      REAL SEL,SEED
      SVS1=DMOD(16807D0*SVS0,2147483647D0)
      SEL=SVS1/2147483648D0
      SVS0=SVS1
      RETURN
C
C     YOU MAY RESEED THE GENERATOR BY SUPPLYING AN ODD NUMBER OF TYPE
C     REAL WITH LSET=TRUE; IF LSET=FALSE, A CALL TO RANSED WILL
C     CAUSE THE RANDOM NUMBER GENERATOR TO START OVER.
C
      ENTRY SVRSED (LSET,SEED)
      IF (LSET) GOTO 10
      SEED=SVSS
      SVS0=SEED
      RETURN
   10 CONTINUE
      IF (AMOD(SEED,2.0).EQ.0.) SEED=SEED+1
      SVSS=SEED
      SVS0=SEED
      RETURN
C
      ENTRY SVRANNGET (PASSS0)
      PASSS0=SVS0
      RETURN
C
      ENTRY SVRANNPUT (PASSS0)
      SVS0=PASSS0
      RETURN
      END
