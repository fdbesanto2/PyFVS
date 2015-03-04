      SUBROUTINE VARGET (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)
      use prgprm_mod
      implicit none
C----------
C CR $Id$
C----------
C
C     READ THE VARIANT SPECIFIC VARIABLES.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION TO PROGNOSIS.
C
      INCLUDE 'GGCOM.F77'
C
C     NOTE: THE ACTUAL STORAGE LIMIT FOR INTS, LOGICS, AND REALS
C     IS MAXTRE (SEE PRGPRM).
C
      INTEGER ILIMIT,IPNT,MXL,MXI,MXR
      PARAMETER (MXL=1,MXI=1,MXR=5)
      LOGICAL LOGICS(*)
      REAL WK3(MAXTRE)
      INTEGER INTS(*)
      REAL REALS(*)
C
C     GET THE INTEGER SCALARS.
C
      CALL IFREAD (WK3, IPNT, ILIMIT, INTS, MXI, 2)
      IGFOR    = INTS ( 1)
C
C     GET THE INTEGER ARRAYS.
C
      CALL IFREAD (WK3, IPNT, ILIMIT, IEQMAP, 11*MAXSP, 2)
C
C     GET THE LOGICAL SCALARS.
C
C**   CALL LFREAD (WK3, IPNT, ILIMIT, LOGICS, MXL, 2)
C
C     GET THE REAL SCALARS.
C
      CALL BFREAD (WK3, IPNT, ILIMIT, REALS, MXR, 2)
      AGERNG  = REALS( 1)
      SEEDS   = REALS( 2)
      TPAT    = REALS( 3)
      DSTAG   = REALS( 4)
      BAINIT  = REALS( 5)
C
C     READ THE REAL ARRAYS
C
      CALL BFREAD (WK3, IPNT, ILIMIT, BCLAS,  MAXSP*41, 2)
      CALL BFREAD (WK3, IPNT, ILIMIT, TBA,    MAXSP,    2)
      CALL BFREAD (WK3, IPNT, ILIMIT, BAU,    41,       2)
      CALL BFREAD (WK3, IPNT, ILIMIT, BARK1,  MAXSP,    2)
      CALL BFREAD (WK3, IPNT, ILIMIT, BARK2,  MAXSP,    2)
      CALL BFREAD (WK3, IPNT, ILIMIT, DBHMAX, MAXSP,    2)
      CALL BFREAD (WK3, IPNT, ILIMIT, TCLAS,  MAXSP*41, 2)
      CALL BFREAD (WK3, IPNT, ILIMIT, BREAK,  MAXSP,    2)
      CALL BFREAD (WK3, IPNT, ILIMIT, SITELO, MAXSP,    2)
      CALL BFREAD (WK3, IPNT, ILIMIT, SITEHI, MAXSP,    2)
C
      RETURN
      END

      SUBROUTINE VARCHGET (CBUFF, IPNT, LNCBUF)
      use prgprm_mod
      implicit none
C----------
C     Get variant-specific character data
C----------
C
      INTEGER LNCBUF
      CHARACTER CBUFF(LNCBUF)
      INTEGER IPNT
      ! Stub for variants which need to get/put character data
      ! See /bc/varget.f and /bc/varput.f for examples of VARCHGET and VARCHPUT
      RETURN
      END
