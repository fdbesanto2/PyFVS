      SUBROUTINE OPINIT
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     OPTION PROCESSING ROUTINE - NL CROOKSTON - JUNE 1981 - MOSCOW
C
C     OPINIT IS USED TO INITIALIZE OPTION PROCESSING POINTERS.
C
      INCLUDE 'OPCOM.F77'
C
      INTEGER I
C
      ISEQDN=0
      IMGL=1
      IMPL=1
      ITOPRM=MAXPRM
      IEVA=1
      ICOD=1
      IEVT=1
      ICACT=1
      ILGNUM=0
      ITST5=0
      IEPT=MAXACT
      LOPEVN=.FALSE.
      DO 10 I=1,MXTST4
      LTSTV4(I)=.FALSE.
   10 CONTINUE
      LBSETS=.FALSE.
      DO 20 I=1,MAXEVA
      LENAGL(I)=-1
   20 CONTINUE
      LENSLS=-1
      RETURN
      END
