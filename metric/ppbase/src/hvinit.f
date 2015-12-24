      SUBROUTINE HVINIT
      use metric_mod
      use prgprm_mod
      implicit none
C----------
C  **HVINIT DATE OF LAST REVISION:  06/03/10
C----------
C
C     CALLED FROM PPINIT.  INITIALIZE THE MULTISTAND POLICY VARIABLES
C
C     MULTISTAND POLICY ROUTINE - N.L. CROOKSTON  - JULY 1987
C     FORESTRY SCIENCES LABORATORY - MOSCOW, ID 83843
C
      INCLUDE 'PPEPRM.F77'
C
      INCLUDE 'PPHVCM.F77'
C
      INCLUDE 'HVDNCM.F77'
C
      INTEGER IHV
C
      LNEDNG=.FALSE.
      HXSIZE=ACRtoHA
      LHVDEB=.FALSE.
      LPRTCT=.TRUE.
      HVMXCC=40.
      LHVMXC=.FALSE.
      LHVUNT=.FALSE.
      LHIER =.FALSE.
      IXHRVP=0
      IHVEXT=0
      DO 10 IHV=1,MXHRVP
      HVPLAB(IHV)=' '
      LNHPLB(IHV,1)=0
      LNHPLB(IHV,2)=0
      IHVTAB(IHV,1)=0
      IHVTAB(IHV,2)=0
      IHVTAB(IHV,3)=0
      TRGSTS(8,IHV)=0.0
      JOHVDS(IHV)=0
   10 CONTINUE
      RETURN
      END
