      SUBROUTINE CFTOPK(ISPC,D,H,VN,VM,VMAX,LCONE,BARK,ITHT)
      use prgprm_mod
      implicit none
C----------
C  **CFTOPK--BASE   DATE OF LAST REVISION:  04/09/08
C----------
C THIS ROUTINE CORRECTS TOTAL CUBIC FOOT VOLUME AND MERCHANTABLE
C CUBIC FOOT VOLUME FOR BROKEN/DEAD TOPS.
C----------
COMMONS
      INCLUDE 'COEFFS.F77'
C
      INCLUDE 'CONTRL.F77'
C
C----------
C  DIMENSION STATEMENT FOR INTERNAL ARRAYS.
C----------
      LOGICAL LCONE
      INTEGER ITHT,ISPC
      REAL BARK,VMAX,VM,VN,H,D,VOLT,BEHRE,HTRUNC,VOLTK,STUMP
      REAL DMRCH,S3,VOLM,HTMRCH,DTRUNC,PHT
C---------
C  IF TOTAL VOLUME IS GREATER THAN ZERO, ADJUST TOTAL VOLUME
C  ESTIMATE FOR DEAD OR MISSING TOP; OTHERWISE RETURN.
C  ASSUME IF TCFV = 0, THEN MCFV = 0 ALSO.
C----------
      IF(VN .LE. 0.) GO TO 50
      CALL BEHPRM (VMAX,D,H,BARK,LCONE)
      VOLT=BEHRE(0.0,1.0)
C----------
C     COMPUTE TOTAL CUBIC VOLUME LOSS DUE TO TOPKILL. HEIGHT AT
C     POINT OF TRUNCATION (HTRUNC) IS COMPUTED FROM ITRUNC. HEIGHT
C     AND DIAMETER AT THE POINT OF TRUNCATION ARE THEN EXPRESSED AS
C     RATIOS OF "NORMAL" HEIGHT AND DBH (PHT AND DTRUNC).
C----------
      HTRUNC = ITHT / 100.0
      PHT = 1. - (HTRUNC/H)
      DTRUNC = PHT / (AHAT*PHT + BHAT)
C----------
C     CORRECT FOR THE TRUNCATED TOP IN THE VN ESTIMATE USING THE
C     RATIO OF VOLUME BELOW TRUNCATION TO TOTAL VOLUME.
C----------
      IF(.NOT.LCONE) THEN
        VOLTK=BEHRE(PHT,1.0)
        VN=VN  *VOLTK/VOLT
C----------
C     PROCESS CONES.
C----------
      ELSE
       VN=VN  *(1.0-PHT**3)
      ENDIF
   50 CONTINUE
C
C----------
C  IF MERCHANTABLE CUBIC VOLUME IS GREATER THAN ZERO, ADJUST
C  MERCHANTABLE VOLUME ESTIMATES FOR DEAD OR MISSING TOP.
C----------
      IF(VM.LE.0.)GO TO 100
      STUMP = 1. - (STMP(ISPC)/H)
      DMRCH=TOPD(ISPC)/D
      HTMRCH=((BHAT*DMRCH)/(1.0-(AHAT*DMRCH)))
      VOLT=BEHRE(HTMRCH,STUMP)
      IF(.NOT.LCONE) THEN
        IF(DTRUNC.GT.DMRCH) THEN
C----------
C     CORRECT MERCHANTABLE VOLUME FOR TOP KILL.
C----------
          VOLTK=BEHRE(PHT,STUMP)
          VM=VM  *VOLTK/VOLT
        ENDIF
      ELSE
C----------
C     PROCESS CONES.
C----------
        S3=STUMP**3
        VOLM=S3-HTMRCH**3
        IF(DTRUNC.GT.DMRCH) THEN
C----------
C     CORRECT MERCHANTABLE VOLUME FOR TOP KILL (CONES ONLY).
C----------
          VOLTK=S3-PHT**3
          VM=VM*VOLTK/VOLM
        ENDIF
      ENDIF
C
  100 CONTINUE
      RETURN
      END
