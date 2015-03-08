      SUBROUTINE RDSOUT
      use contrl_mod
      use metric_mod
      use plot_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **RDSOUT                       LAST REVISION:  09/03/14
C----------
C
C  PRODUCES OPTIONAL OUTPUT (IN A SEPARATE FILE) OF THE RESULTS
C  OF THE MONTE CARLO SIMULATIONS OF SPREAD RATE
C
C  CALLED BY :
C     RDCNTL  [ROOT DISEASE]
C
C  CALLS     :
C     DBCHK   (SUBROUTINE)   [PROGNOSIS]
C
C  PARAMETERS :
C     NONE
C
C  COMMON BLOCK VARIABLES :
C     MCRATE: ARRAY CONTAINING INDIVIDUAL SIMULATION RESULTS
C     SDRATE: ARRAY CONTAINING THE STANDARD DEVIATION OF THE RESULTS
C
C  LOCAL VARIABLES :
C     CMC:    NAME OF OUTPUT FILE
C     JOMCS:  NUMBER OF OUTPUT FILE
C
C  REVISION HISTORY:
C     18-JUN-2001 Lance R. David (FHTET)
C        Added Stand ID and Management ID line to header.
C     16-AUG-2006 Lance R. David (FHTET)
C        Change of metric conversion factors variable names to match
C        variables in new \FVS\COMMON\METRIC.F77. rd\src\metric.f77
C        will be retired. (mods courtesy of Don Robinson, ESSA)
C   09/03/14 Lance R. David (FMSC)
C
C----------------------------------------------------------------------
C.... PARAMETER INCLUDE FILES
C
      INCLUDE 'RDPARM.F77'
C
C.... COMMON INCLUDE FILES
C
      INCLUDE 'RDARRY.F77'
      INCLUDE 'RDCOM.F77'
      INCLUDE 'RDCRY.F77'
      INCLUDE 'RDADD.F77'

      LOGICAL FIRSTL
      INTEGER I, IDI, IJ, J, JOMCS, JYR, N
      REAL    AVG, SFPROB, SUMX
      CHARACTER*1 CHTYPE(ITOTRR)

      DATA CHTYPE /'P','S','A','W'/
      DATA FIRSTL /.FALSE./

      IF (IROOT .EQ. 0) RETURN

C     IF MONTE CARLO OUTPUT WAS NOT REQUESTED THEN RETURN

      IF (IMCOUT .LE. 0) RETURN
      JOMCS = IMCOUT

      IF (ISTEP .EQ. 2) THEN

C         SINCE THIS IS CALLED FROM RDCNTL, ISTEP=2 THE FIRST TIME IT'S CALLED
C
C         WRITE THE TABLE HEADERS
C
          WRITE (JOMCS,1100)
          WRITE (JOMCS,1105)
          WRITE (JOMCS,1100)
          WRITE (JOMCS,1110) NPLT, MGMID
          WRITE (JOMCS,1115)
          WRITE (JOMCS,1120)
          WRITE (JOMCS,1155) (N,N=1,10)
          WRITE (JOMCS,1160)

          FIRSTL = .TRUE.

      ENDIF

      JYR = IY(ISTEP) - 1

      DO 5000 IRRSP=MINRR,MAXRR

         IF (PAREA(IRRSP) .LE. 0.0) GOTO 5000

         SUMX = 0.0
         DO 100 IJ = 1,NMONT
            SUMX = SUMX + MCRATE(IRRSP,IJ)
  100    CONTINUE
         AVG = SUMX / FLOAT(NMONT)

         SFPROB = 0.0
         IDI = IRRSP
         DO 130 I = 1,ITRN
            IF (IRRSP .LT. 3) IDI = IDITYP(IRTSPC(ISP(I)))
            IF (IDI .EQ. IRRSP) SFPROB = SFPROB + FFPROB(I,1)
  130    CONTINUE

         IF (LMTRIC) THEN
            WRITE(JOMCS,2099) JYR,CHTYPE(IRRSP),NMONT,
     &                        AVG*FTTOM,SDRATE(IRRSP)*FTTOM,
     &                        SFPROB/ACRTOHA,
     &                        (MCRATE(IRRSP,J)*FTTOM,J=1,10)
            IF (FIRSTL) THEN
               WRITE(JOMCS,2210) (MCTREE(IRRSP,J),J=1,10)
               WRITE(JOMCS,2220) (SPRQMD(IRRSP,J)*INTOCM,J=1,10)
               FIRSTL = .FALSE.
            ELSE
               WRITE(JOMCS,2199) (MCTREE(IRRSP,J),J=1,10)
               WRITE(JOMCS,2200) (SPRQMD(IRRSP,J)*INTOCM,J=1,10)
            ENDIF
         ELSE
            WRITE(JOMCS,2099) JYR,CHTYPE(IRRSP),NMONT,AVG,SDRATE(IRRSP),
     &                        SFPROB,(MCRATE(IRRSP,J),J=1,10)
            IF (FIRSTL) THEN
               WRITE(JOMCS,2210) (MCTREE(IRRSP,J),J=1,10)
               WRITE(JOMCS,2220) (SPRQMD(IRRSP,J),J=1,10)
               FIRSTL = .FALSE.
            ELSE
               WRITE(JOMCS,2199) (MCTREE(IRRSP,J),J=1,10)
               WRITE(JOMCS,2200) (SPRQMD(IRRSP,J),J=1,10)
            ENDIF
         ENDIF
         IF (ISTEP .NE. 1) WRITE(JOMCS,1121)

 5000 CONTINUE

  200 CONTINUE
      RETURN

 1100 FORMAT (53('* '))
 1105 FORMAT (43X,'WESTERN ROOT DISEASE MODEL')
 1110 FORMAT (33X,'STAND ID= ',A26,5X,'MANAGEMENT ID= ',A4)
 1115 FORMAT (35X,'SPREAD RATE MONTE CARLO SIMULATION RESULTS')
 1120 FORMAT (106('-'))
 1121 FORMAT (' ')
 1155 FORMAT ('YEAR',2X,'TYPE',2X,'NUM',2X,'AVG',3X,'SD',3X,
     &        'DENS',4X,10(4X,'#',I2))
 1160 FORMAT (106('-'))

 2099 FORMAT (I4,4X,A1,3X,I2,2X,F4.2,2X,F4.2,2X,F6.2,2X,10(3X,F4.2))
 2199 FORMAT (36X,10(3X,I2,2X))
 2200 FORMAT (36X,10(3X,F4.1))

 2210 FORMAT (3X,'NUM TREES IN MC SIM.',13X,10(3X,I2,2X))
 2220 FORMAT (3X,'QMD OF TREES IN SIM.',13X,10(3X,F4.1))

      END
