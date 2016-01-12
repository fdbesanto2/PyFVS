      SUBROUTINE VARGET (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)
      use prgprm_mod
      implicit none
C----------
C  **VARGET--CI   DATE OF LAST REVISION:  09/18/08
C----------
C
C     READ THE VARIANT SPECIFIC VARIABLES.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION TO PROGNOSIS.
C
      INCLUDE 'CICOM.F77'
C
C     NOTE: THE ACTUAL STORAGE LIMIT FOR INTS, LOGICS, AND REALS
C     IS MAXTRE (SEE PRGPRM).
C
      INTEGER ILIMIT,IPNT,MXL,MXI,MXR
      PARAMETER (MXL=1,MXI=1,MXR=1)
      LOGICAL LOGICS(*)
      REAL WK3(MAXTRE)
      INTEGER INTS (*)
      REAL REALS (*)
C
C     GET THE INTEGER SCALARS.
C
      CALL IFREAD (WK3, IPNT, ILIMIT, INTS, MXI, 2)
      ICINDX = INTS(1)
C
C     GET THE LOGICAL SCALARS.
C
C**   CALL LFREAD (WK3, IPNT, ILIMIT, LOGICS, MXL, 2)
C
C     GET THE REAL SCALARS.
C
C**   CALL BFREAD (WK3, IPNT, ILIMIT, REALS, MXR, 2)
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
