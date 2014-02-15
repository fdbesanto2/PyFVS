      SUBROUTINE EXESTB
      IMPLICIT NONE
C----------
C  $Id: exestb.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C
C     EXTRA REFERENCES FOR REGENERATION ESTABLISHMENT
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CALDEN.F77'
C
C
COMMONS
C
C
      CHARACTER*8 KEYWRD,NOESTB,PASKEY
      REAL ARRAY(1)
      DIMENSION LNOTBK(1)
      INTEGER IPVARS(1)
      INTEGER KEY,NPNVRS,IMC1,ITREI,IPTKNT,JOSTND,I,ID,ISHAG,JPLOT
      INTEGER JSSP,ICALL,LENGTH
      REAL DBH,PREM
      LOGICAL LACTV,LNOTBK,LFG,LKECHO
C
      DATA NOESTB/'*NO ESTB'/
      ENTRY ESIN(PASKEY,ARRAY,LNOTBK,LKECHO)
      CALL ERRGRO (.TRUE.,11)
      RETURN
      ENTRY ESNUTR
      RETURN
      ENTRY ESKEY(KEY,KEYWRD)
      KEYWRD=NOESTB
      RETURN
      ENTRY ESNOAU (KEYWRD)
      RETURN
      ENTRY ESINIT
      RETURN
      ENTRY ESOUT(LFG)
      RETURN
      ENTRY ESPLT1(ITREI,IMC1,NPNVRS,IPVARS)
      RETURN
      ENTRY ESPLT2(JOSTND,IPTKNT)
      RETURN
      ENTRY ESEZCR(JOSTND)
      RETURN
      ENTRY ESFLTR
      DO 10 I=1,MAXPLT
      BAAINV(I)=0.0
   10 CONTINUE
      TPACRE=0.0
      RETURN
      ENTRY ESXTRA
      RETURN
      ENTRY ESHTS
      RETURN
      ENTRY ESDTLS (ID)
      RETURN
      ENTRY ESTUMP (JSSP,DBH,PREM,JPLOT,ISHAG)
      RETURN
      ENTRY ESADDT (ICALL)
      RETURN
C
C     EXTRA REFERENCES FOR THE PARALLEL PROCESSING SYSTEM.
C
      ENTRY ESGET
      RETURN
      ENTRY ESPUT
      RETURN
      ENTRY ESSPRQ (LENGTH)
      RETURN
      ENTRY ESACTV (LACTV)
      LACTV=.FALSE.
      RETURN
      END
