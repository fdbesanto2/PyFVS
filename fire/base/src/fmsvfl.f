      SUBROUTINE FMSVFL (NOUT)
      use fmcom_mod
      use fmfcom_mod
      use fmparm_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C     FIRE MODEL STAND VISUALIZATION GENERATION
C     N.L.CROOKSTON -- RMRS MOSCOW -- JANUARY 2000
C     A.H.DALLMANN  -- RMRS MOSCOW -- JANUARY 2000
C     D. ROBINSON   -- ESSA        -- MAY 2005
C
C     INPUT:
C     NOUT  =THE OUTPUT FILE REFERENCE NUMBER
C


      INCLUDE 'SVDATA.F77'

      INCLUDE 'FMSVCM.F77'



      INCLUDE 'METRIC.F77'

COMMONS

      EXTERNAL SVRANN
      INTEGER  NOUT,NFLF,NFLAMES,NFLMS,IFLAMES,II,IFLR0T
      INTEGER  I
      REAL     WIDTHMIN,TILTBASE,WMAX,WIDTH,FLMX,FLMY,BACHLO,TEMP,
     &         TEMP2,TMPDIST,TMPPCT,TMPVAR,TMPHEIGHT,FLMHT,FMWDTH,
     &         FLMWDTH,X,FLMTILT,XD,XR,XR2

C     OUTPUT THE FIRE LINE

      WRITE (NOUT,10) '#FIRE_LINE ',FMY2
   10 FORMAT (A,100(1X,F6.2))

C     OUTPUT THE FUEL LOADS BEFORE AND AFTER THE FIRE LINE

      WRITE (NOUT, 10) '#PRE_FIRE_LOAD',TCWD
      WRITE (NOUT, 10) '#POST_FIRE_LOAD',TCWD2

C     CALCULATE THE GEOMETRY INFORMATION USED BY THE FLAME OUTPUT.

C     WIDTH REFERS TO THE MAX-X VALUE OF THE STAND.  IT IS SHIFTED
C     BY MINWIDTH.

      WIDTHMIN = 0.

C     CALCULATE THE FLAMES TILT ANGLE BASED ON THE WIND.

      IF (FWIND.LE.1.) THEN
        TILTBASE = 5.
      ELSEIF (FWIND.LE.10.) THEN
        TILTBASE = 15.
      ELSEIF (FWIND.LE.35.) THEN
        TILTBASE = 30.
      ELSE
        TILTBASE = 40.
      ENDIF

C     FOR ONLY PASSIVE (TORCHING) OR SURFACE FIRES, DRAW SOME FLAMES
C     ON THE GROUND IN A FLAME WALL.

      IF (FIRTYPE .EQ. 1) THEN
        NFLF = 0
      ELSE
        NFLF = 250
      ENDIF

      IF (IMETRIC.EQ.0) THEN
        IF (IPLGEM .LE. 1) THEN
          WMAX   = 208.71
          WIDTH  = 208.71
        ELSE
          WMAX   = 235.50
        ENDIF
      ELSE
        IF (IPLGEM .LE. 1) THEN
          WMAX   = 100.0
          WIDTH  = 100.0
        ELSE
          WMAX   = 112.84
        ENDIF
      ENDIF
      FLPART = WMAX / NFLPTS

C     NFLAMES IS THE NUMBER OF RANDOM FLAME OBJECTS TO DRAW.

      NFLAMES = NFLF
      NFLMS = NFLAMES

      DO 30 IFLAMES=1, NFLAMES

C       INITIALIZE THE FLAMES

        IF (IFLAMES .LE. NFLF) THEN

C         CALCULATE AN INITIAL X-VALUE.  BRANCH BACK IF THE POINT IS REJECTED

   20     CONTINUE
          CALL SVRANN( FLMX )
          FLMX = FLMX * WMAX

C         FIGURE OUT WHICH FLAME SECTION THIS VALUE WOULD BE IN.

          II = IFIX( FLMX / FLPART )
          IF ( II.GT.NFLPTS ) THEN
            II = NFLPTS
          ELSEIF ( II.LT.1 ) THEN
            II = 1
          ENDIF

C         BASE THE INITIAL Y-VALUE ON THE SECTION.

          FLMY = BACHLO( FMY2(II), 2.5, SVRANN )

C         IF THE Y IS OUTSIDE THE ALLOWED RANGE ,
C         THEN WE SHOULDN'T DRAW THE FLAME.

          IF ( FLMY .LT. 0. .OR. FLMY .GT. WMAX ) GOTO 30

C         CHECK TO MAKE SURE THIS VALUE IS WITHIN THE STAND

          IF (IPLGEM .GT. 1) THEN

C           Calculate the width based on FLMY
C           D=235.50, R=117.75, R^2 = 13865.06250

            IF (IMETRIC.EQ.0) THEN
              XD  =   235.50
              XR  =   117.75
              XR2 = 13865.06
            ELSE
              XD  =   112.84
              XR  =    56.42
              XR2 =  3183.22
            ENDIF

            IF (FLMY .GT. XR) THEN
              TEMP  = FLMY - XR
              TEMP2 = TEMP**2
              WIDTH = 2. * SQRT(XR2 - (FLMY-XR)**2)
            ELSE
              TEMP  = XR - FLMY
              TEMP2 = TEMP**2
              WIDTH = 2. * SQRT(XR2 - (XR-FLMY)**2 )
            ENDIF
            WIDTHMIN = (XD - WIDTH) / 2.
          ENDIF

C         IF THE X-VALUE DOESN'T WORK WITH THE Y-VALUE, REDO THE
C         CALCULATION.

          IF ( FLMX.LT.WIDTHMIN .OR.
     >         FLMX.GT.(WIDTHMIN+WIDTH) ) GOTO 20

C         CALCULATE THE FLAME HEIGHT.  IN FRONT OF THE MAIN WALL, THE
C         FLAMES WILL LIKELY BE ABOUT 10% FULL, 100% AT THE MAIN WALL
C         AND TAILING OFF WITH AN F(X) = X^3 FUNCTION.

          IF ( FLMY.GT.(FMY2(II)+1.0) ) THEN

C           TMPDIST IS GUARANTEED TO BE GREATER THAN 1.0 AT THIS POINT

            TMPDIST = FLMY - FMY2(II)
            TMPPCT = 1.0 / TMPDIST
            TMPVAR = 1.0 - TMPPCT**2
            TMPHEIGHT = FLAMEHT - ((FLAMEHT * TMPVAR))
            FLMHT = BACHLO(TMPHEIGHT, TMPHEIGHT * 0.05, SVRANN)

          ELSEIF (FLMY.GE.(FMY2(II)-1.0)) THEN
            FLMHT = BACHLO(FLAMEHT, FLAMEHT * 0.1, SVRANN)
          ELSE

C           TMPDIST IS GUARANTEED TO BE GREATER THAN 1.0 AT THIS POINT

            TMPDIST = FMY2(II) - FLMY
            TMPPCT = 1.0 / TMPDIST
            TMPVAR = 1.0 - TMPPCT**3
            TMPHEIGHT = FLAMEHT - ((FLAMEHT * TMPVAR)/2.0)
            FLMHT = BACHLO(TMPHEIGHT, TMPHEIGHT * 0.05, SVRANN)
          ENDIF
        ELSE

C       ANY RANDOM FLAMES WOULD BE DRAWN HERE.

        ENDIF

        CALL SVRANN( FMWDTH )
        FLMWDTH = FMWDTH * FLAMEHT + 1.0
        FLMTILT = BACHLO(TILTBASE, 5.0, SVRANN)
        CALL SVRANN(X)
        IFLR0T=INT(X*360.)

C       GO AHEAD AND WRITE OUT THE FIRE INFORMATION TO THE SVS FILE.

        IF (IMETRIC.EQ.0) THEN
          WRITE (NOUT,25) IFLAMES+NSVOBJ,
     >      FLMHT,FLMTILT,IFLR0T,FLMWDTH,FLMX,FLMY,0.
        ELSE
         WRITE (NOUT,25) IFLAMES+NSVOBJ,
     >      FLMHT*FTtoM,FLMTILT,IFLR0T,FLMWDTH*FTtoM,FLMX,FLMY,0.
        ENDIF

   25   FORMAT ('@flame.eob',T16,I5,' 99 0 1 0',2F6.0,I5,' 0',F6.1,
     >    ' 0 0 0 0 0 0 0 1 0',3F8.2)
   30 CONTINUE

      RETURN
      END

      SUBROUTINE FMGETFL(ASIZE, FLINE)
      use prgprm_mod
      implicit none
C----------
C     **FMGETFL--FIRE   DATE OF LAST REVISION: 06/19/02
C----------
C
C     FIRE MODEL GET FIRE LINE INFORMATION
C     D.L.GAMMEL -- SEM -- JUNE 2002
C
C     INPUT:
C     ASIZE  =THE SIZE OF THE ARRAY PASSED IN
C     FLINE  =THE ARRAY TO BE FILLED WITH THE FIRE LINE INFO
C
      INCLUDE 'SVDATA.F77'
C
      INCLUDE 'FMSVCM.F77'
C
      REAL FLINE
      INTEGER ASIZE
      INTEGER I

      DIMENSION FLINE(ASIZE)

      DO I = 1,MIN(ASIZE,NFLPTS)
         FLINE(I) = FMY2(I)
      ENDDO

      END


