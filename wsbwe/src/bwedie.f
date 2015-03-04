      SUBROUTINE BWEDIE(ISTAGE,IC,IH,EATFOL,GODISP,SPRDIE,TOTDIE)
      use prgprm_mod
      implicit none
C---------
C **BWEDIE             DATE OF LAST REVISION:  07/14/10
C---------
C
C THIS SUBROUTINE CALCULATES SURVIVAL FOR SMALL LARVAE (ISTAGE=1),
C LARGE LARVAE (ISTAGE=2), OR PUPAE (ISTAGE=3).
C
C  K.A. SHEEHAN  USDA-FS, R6-NATURAL RESOURCES, PORTLAND, OR
C
C   CALLED FROM: BWELIT
C
C   SUBROUTINES CALLED: BWESLP
C
C   PARAMETERS:
C
C   ACTNEW - ACTUAL AMOUNT OF NEW FOLIAGE GROWN & NOT EATEN TO DATE
C   ANT_BD - PROP. OF PREDATOR MORTALITY ASSIGNED TO ANTS (BY CROWN LEVEL);
C            (1.0-ANT_BD) = PROP. ASSIGNED TO BIRDS
C   ANTDEN - ANT DENSITY FACTOR (SET TO 1.0 NOW)
C   ANTSI  - INSTANTANEOUS MORT. RATE FOR LARVAE KILLED BY ANTS
C   ANTS   - PROP. OF BW KILLED BY ANTS DURING THIS LIFE STAGE
C   BIRDEN - BIRD DENSITY FACTOR (SET TO 1.0 NOW)
C   BIRDS  - PROP. OF BW KILLED BY BIRDS DURING THIS LIFE STAGE
C   BIRDSI - INSTANTANEOUS MORT. RATE FOR LARVAE KILLED BY BIRDS
C   BW     - NO. OF BUDWORMS PRESENT BY CELL
C   BWNEW  - NO. OF LARVAE THAT COULD EAT NEW FOLIAGE (GIVEN AMT NEW PRESENT)
C   DAYS   - NO. OF DAYS SPENT IN A LIFE STAGE
C   DEFYRS - NO. OF YEARS WITH >20% DEFOL. BY HOST (THIS OUTBREAK ONLY)
C   DISPI  - INSTANTANEOUS MORT. RATE FOR DISPERSING LARVAE
C   EATEN  - AMOUNT OF FOLIAGE EATEN BY SMALL OR LARGE LARVAE BY HOST
C   EATFOL - AMT. OF FOLIAGE EATEN BY LARVAE THAT DIED LATER IN THIS TIME STEP
C   FOLDVX - SLIP FUNCT. TO CONVERT NO. OF YEARS OF DEFOLIATION (DEFYRS)
C            TO RELATIVE FOL. QUALITY -- EFFECTS ON DEVEL. RATES (X VALUES)
C   FOLDVY - SLIP FUNCT. TO CONVERT NO. OF YEARS OF DEFOLIATION (DEFYRS)
C            TO RELATIVE FOL. QUALITY -- EFFECTS ON DEVEL. RATES (Y VALUES)
C   FOLQL  - FOLIAGE QUALITY INDEX (SEE FOLDVX, FOLDVY)
C   GODISP - NO. (LATER PROP.) OF LARVAE THAT DISPERSE
C   ISTAGE - LIFE STAGE INDEX: 1=SMALL LARVAE, 2=LARGE LARVAE, 3=PUPAE
C   M1PRED - MYSTERY_1 PREDATOR MULTIPLIER (SET TO 1.0 NOW)
C   M2PRED - MYSTERY_2 PREDATOR MULTIPLIER (SET TO 1.0 NOW)
C   M3PRED - MYSTERY_3 PREDATOR MULTIPLIER (SET TO 1.0 NOW)
C   MYST1  - PROP. OF BW KILLED BY MYSTERY_1 DURING THIS LIFE STAGE
C   MYST2  - PROP. OF BW KILLED BY MYSTERY_2 DURING THIS LIFE STAGE
C   MYST3  - PROP. OF BW KILLED BY MYSTERY_3 DURING THIS LIFE STAGE
C   MYST1I  - INSTANTANEOUS MORT. RATE FOR BW KILLED BY MYSTERY_1
C   MYST2I  - INSTANTANEOUS MORT. RATE FOR BW KILLED BY MYSTERY_2
C   MYST3I  - INSTANTANEOUS MORT. RATE FOR BW KILLED BY MYSTERY_3
C   MYS1DN - MYSTERY_1 DENSITY FACTOR (SET TO 0.0 NOW)
C   MYS2DN - MYSTERY_2 DENSITY FACTOR (SET TO 0.0 NOW)
C   MYS3DN - MYSTERY_3 DENSITY FACTOR (SET TO 0.0 NOW)
C   NEMULT - USER-SPECIFIED MULTIPLIER USED TO CHANGE PREDATION RATES
C   OBPHAS - STORES PARASITISM RATES BY OUTBREAK PHASE AND LIFE STAGE
C   OBPHX  - SLIP FUNC. TO CONVERT YEARS OF DEFOLIATION (DEFYRS) TO PARA. RATE
C   OBPHY  - SLIP FUNC. TO CONVERT YEARS OF DEFOLIATION (DEFYRS) TO PARA. RATE
C   OUT1   - STORES INFO. FOR TABLE 1 (SEE P1.FOR FOR DETAILS)
C   OUT3   - STORES INFO. FOR TABLE 3 (SEE P3.FOR FOR DETAILS)
C   PARASI - INSTANTANEOUS MORT. RATE FOR LARVAE KILLED BY PARASITES
C   PREDKL - NO. OF BW KILLED BY PREDATORS ACC'DING TO CAMPBELL & SRIVASTAVA
C   PRATE  - PREDATION RATE (CAMPBELL & STRIVASTAVA)
C   RATIO  - PROPORTION OF LARVAE THAT ARE ABLE TO EAT NEW FOLIAGE
C   SPRAYI - INSTANTANEOUS MORT. RATE FOR BW KILLED BY INSECTICIDE SPRAY
C   SPRDIE - PROP. OF DEAD BW THAT WERE KILLED BY SPRAY
C   SSTARX - SLIP FUNCT. TO CONVERT RATIO TO PROP. OF LARVAE
C            THAT STARVE WHEN THERE ISN'T ENOUGH NEW FOL. (X VALUES)
C   SSTARY - SLIP FUNCT. TO CONVERT RATIO TO PROP. OF LARVAE
C            THAT STARVE WHEN THERE ISN'T ENOUGH NEW FOL. (Y VALUES)
C   STARV  - PROPORTION OF LARVAE THAT STARVE
C   STARVI - INSTANTANEOUS MORT. RATE FOR STARVING LARVAE
C   STARVX - STORES SSTARX VALUES FOR THE 3 LIFE STAGES
C   STARVY - STORES SSTARY VALUES FOR THE 3 LIFE STAGES
C   TOTAM  - TOTAL ACTUAL MORTALITY RATE
C   TOTDIE - NO. OF BW THAT DIE
C   TOTIR  - TOTAL INSTANTANEOUS MORTALITY RATE
C   WASTED - AMOUNT OF FOLIAGE WASTED PER LARVA
C
C Revision History:
C  17-MAY-2005 Lance R. David (FHTET)
C     Added FVS parameter file PRGPRM.F77.
C  14-JUL-2010 Lance R. David (FMSC)
C-----------------------------------------------------------
C
      INCLUDE 'BWESTD.F77'
      INCLUDE 'BWECOM.F77'
      INCLUDE 'BWECM2.F77'
      INCLUDE 'BWEBOX.F77'
C
      INTEGER IC, IH, ISTAGE, K
      REAL ANTS, ANTSI, BIRDS, BIRDSI, BWESLP, BWNEW, DAYNEW, DISPI,
     &     EATFOL, EATMAX, FOLQL, GODISP, PARAS, PARASI, POTCLP,
     &     PREDKL, RATIO, SAVKIL(9,6), SPRAY, SPRAYI, SPRDIE,
     &     SSTARX(4), SSTARY(4), STARV, STARVI, TOTAM, TOTDIE, TOTIR,
     &     X, Y
      REAL MYST1,MYST2,MYST3,MYST1I,MYST2I,MYST3I

C     WRITE (16,*)'ENTER BWEDIE: ISTAGE,IC,IH=',ISTAGE,IC,IH      ! TEMP DEBUG
C     WRITE (16,*)'ENTER BWEDIE: BW(IC,IH)=',BW(IC,IH)            ! TEMP DEBUG

C
C     INITIALIZE VARIABLES.
C
      SPRDIE = 0.0
      TOTDIE = 0.0
      EATFOL = 0.0
      EATMAX = 0.0
      POTCLP = 0.0
      FOLQL  = 0.0
      PREDKL = 0.0
      GODISP= 0.0
      STARV = 0.0
      ANTS  = 0.0
      BIRDS = 0.0
      PARAS = 0.0
      MYST1 = 0.0
      MYST2 = 0.0
      MYST3 = 0.0
      SPRAY = 0.0
C
C  IF VIRTUALLY NO LARVAE ARE PRESENT, THEN NO LARVAE DIE (DUH...)
C
      IF (BW(IC,IH).LT.1.0) GO TO 900                            ! RETURN
C
C  HANDLE STARVATION ONLY FOR LARVAE.  PUPAE DON'T STARVE.
C
      IF (ISTAGE.EQ.3) GOTO 40
C
C  IF VIRTUALLY NO FOLIAGE IS PRESENT, THEN MOST LARVAE STARVE.
C
      IF (ACTNEW(IC,IH).LT.1.0) THEN
         STARV=STARVY(ISTAGE,1)
         GO TO 40
      ENDIF
C
C  CALCULATE POTENTIAL AMOUNT OF FOLIAGE CLIPPED
C  IF THERE'S ENOUGH FOLIAGE, THEN NOBODY STARVES.
C
      POTCLP=BW(IC,IH)*EATEN(ISTAGE,IH)/(1.0-WASTED(ISTAGE))
      IF (POTCLP.LE.ACTNEW(IC,IH)) THEN
         CONTINUE
C
C  IF THERE ISN'T ENOUGH FOLIAGE, CALC. THE PROPORTION THAT STARVE.
C
      ELSE
         BWNEW=ACTNEW(IC,IH)*(1.0-WASTED(ISTAGE))/EATEN(ISTAGE,IH)
         RATIO=1.0
         IF (BW(IC,IH).GT.1.0) RATIO=BWNEW/BW(IC,IH)
         DO 30 K=1,4
           SSTARX(K)=STARVX(ISTAGE,K)
           SSTARY(K)=STARVY(ISTAGE,K)
   30    CONTINUE
         STARV=BWESLP(RATIO,SSTARX,SSTARY,4)
C
C  STARVING LARVAE EAT SOME FOLIAGE - ARBITRARILY SET TO 50% OF POTENTIAL
C  BUT! DON'T LET LARVAE EAT EVERY SINGLE NEEDLE.  LIMIT THEM ARBITRARILY TO
C  85% OF WHAT'S THERE.
C
         EATFOL=(POTCLP-ACTNEW(IC,IH))*.5
         EATMAX=ACTNEW(IC,IH)*.85
         IF (EATFOL.GT.EATMAX) EATFOL=EATMAX
      ENDIF
C
   40 CONTINUE
C
C  NEXT DEAL WITH PREDATORS AND MYSTERY MORTALITY SOURCES
C
      X=1.0
      FOLQL=BWESLP(DEFYRS(IH),FOLDVX,FOLDVY,4)
      IF (ISTAGE.EQ.1) THEN
         DAYNEW=DAYS(1)*.333*FOLQL
         Y=EXP(PRATE(IC)*DAYNEW)
      ELSEIF (ISTAGE.EQ.2) THEN
         Y=EXP(PRATE(IC)*DAYS(ISTAGE)*FOLQL)
         SAVKIL(IC,IH)=Y
      ELSE
         DAYNEW=DAYS(2)+DAYS(3)
         Y=EXP(PRATE(IC)*DAYNEW)
         X=SAVKIL(IC,IH)
      ENDIF
      PREDKL=BW(IC,IH)*(X-Y)
      ANTS=ANTDEN(IC,IH)*PREDKL*ANT_BD(IC)*NEMULT(1,ISTAGE)/BW(IC,IH)
      BIRDS=BIRDEN(IC,IH)*PREDKL*(1.0-ANT_BD(IC))*NEMULT(2,ISTAGE)
     *    /BW(IC,IH)

C     WRITE (16,*) 'IN BWEDIE: POTCLP, STARV =',POTCLP, STARV     ! TEMP DEBUG
C     WRITE (16,*) 'IN BWEDIE: EATFOL, EATMAX =',EATFOL,EATMAX    ! TEMP DEBUG
C     WRITE (16,*) 'IN BWEDIE: FOLQL, PREDKL =',FOLQL,PREDKL      ! TEMP DEBUG
C     WRITE (16,*) 'IN BWEDIE: ANTS, BIRDS =',ANTS,BIRDS          ! TEMP DEBUG

C  PARAS. RATE IS A FUNCTION OF HOW LONG THE OUTBREAK HAS BEEN
C  GOING ON IN THIS STAND (DEFYRS) AND IS NOT A FACTOR IN STAGE 1
C  OF AN OUTBREAK.
C
      IF (ISTAGE.NE.1) THEN
         OBPHY(1)=OBPHAS(ISTAGE,1)
         OBPHY(2)=OBPHAS(ISTAGE,1)
         OBPHY(3)=OBPHAS(ISTAGE,2)
         OBPHY(4)=OBPHAS(ISTAGE,2)
         PARAS=BWESLP(DEFYRS(IH),OBPHX,OBPHY,4)
         PARAS=PARAS*NEMULT(3,ISTAGE)
      ENDIF
      MYST1=MYS1DN(IC,IH)*DAYS(ISTAGE)*M1PRED(ISTAGE)*WRAIN1(ISTAGE)*
     *   NEMULT(4,ISTAGE)/BW(IC,IH)
      MYST2=MYS2DN(IC,IH)*DAYS(ISTAGE)*M2PRED(ISTAGE)*WRAIN2(ISTAGE)*
     *   NEMULT(4,ISTAGE)/BW(IC,IH)
      MYST3=MYS3DN(IC,IH)*DAYS(ISTAGE)*M3PRED(ISTAGE)*WRAIN3(ISTAGE)*
     *   NEMULT(4,ISTAGE)/BW(IC,IH)

C     WRITE (16,*) 'IN BWEDIE: MYST1-2-3 =',MYST1,MYST2,MYST3      ! TEMP DEBUG

      GODISP=GODISP/BW(IC,IH)

C     WRITE (16,*) 'IN BWEDIE: GODISP =',GODISP                    ! TEMP DEBUG

C
C  DEAL WITH INSECTICIDE APPLICATION (LARGE LARVAE ONLY)
C
      IF (LSPRAY.AND.ISTAGE.EQ.2) THEN
         SPRAY=SPEFF/100.0
      ELSE
         SPRAY=0.0
      ENDIF
C
C  CONVERT TO INSTANTANEOUS MORTALITY RATES
C
      IF (GODISP.GT.0.99) GODISP=0.99
      IF (STARV.GT.0.99) STARV=0.99
      IF (ANTS.GT.0.99) ANTS=0.99
      IF (BIRDS.GT.0.99) BIRDS=0.99
      IF (PARAS.GT.0.99) PARAS=0.99
      IF (MYST1.GT.0.99) MYST1=0.99
      IF (MYST2.GT.0.99) MYST2=0.99
      IF (MYST3.GT.0.99) MYST3=0.99
      IF (SPRAY.GT.0.99) SPRAY=0.99
      DISPI=-LOG(1.0-GODISP)
      STARVI=-LOG(1.0-STARV)
      ANTSI=-LOG(1.0-ANTS)
      BIRDSI=-LOG(1.0-BIRDS)
      PARASI=-LOG(1.0-PARAS)
      MYST1I=-LOG(1.0-MYST1)
      MYST2I=-LOG(1.0-MYST2)
      MYST3I=-LOG(1.0-MYST3)
      SPRAYI=-LOG(1.0-SPRAY)
      TOTIR=DISPI+STARVI+ANTSI+BIRDSI+PARASI+
     &      MYST1I+MYST2I+MYST3I+SPRAYI

C     WRITE (16,*) 'IN BWEDIE: TOTIR =',TOTIR                      ! TEMP DEBUG

C
C  CONVERT BACK TO ACTUAL MORTALITY, AND PARTITION TO SOURCES
C
      TOTAM=1.0-EXP(-TOTIR)
      TOTDIE=TOTAM*BW(IC,IH)
	BW(IC,IH)=BW(IC,IH)-TOTDIE
      IF (TOTIR.LE.0.0) GO TO 900                                  ! RETURN
      SPRDIE=SPRAYI/TOTIR
C
C  SAVE NO. OF BW KILLED FOR OUTPUT TABLE (P1)
C
      OUT1(IC,IH,3)=TOTDIE*DISPI/TOTIR
      OUT1(IC,IH,4)=TOTDIE*STARVI/TOTIR
      OUT1(IC,IH,5)=TOTDIE*ANTSI/TOTIR
      OUT1(IC,IH,6)=TOTDIE*BIRDSI/TOTIR
      OUT1(IC,IH,7)=TOTDIE*PARASI/TOTIR
      OUT1(IC,IH,8)=TOTDIE*(MYST1I+MYST2I+MYST3I)/TOTIR
      IF (ISTAGE.EQ.1) THEN
        OUT3(IC,IH,3)=TOTDIE*STARVI/TOTIR
        OUT3(IC,IH,4)=TOTDIE*(ANTSI+BIRDSI+MYST1I+
     *     MYST2I+MYST3I)/TOTIR
        OUT3(IC,IH,18)=TOTDIE*PARASI/TOTIR
c        sumdie=out3(ic,ih,3)+out3(ic,ih,4)+out3(ic,ih,18)
      ELSEIF (ISTAGE.EQ.2) THEN
        OUT3(IC,IH,5)=OUT3(IC,IH,5)+(TOTDIE*(DISPI+STARVI)/TOTIR)
        OUT3(IC,IH,6)=TOTDIE*(ANTSI+BIRDSI+MYST1I+
     *     MYST2I+MYST3I)/TOTIR
        OUT3(IC,IH,19)=TOTDIE*PARASI/TOTIR
        OUT3(IC,IH,17)=TOTDIE*SPRAYI/TOTIR
c        sumdie=out3(ic,ih,5)+out3(ic,ih,6)+out3(ic,ih,17)+
c     *     out3(ic,ih,19)
      ELSE
        OUT3(IC,IH,7)=TOTDIE*(ANTSI+BIRDSI+MYST1I+
     *     MYST2I+MYST3I)/TOTIR
        OUT3(IC,IH,20)=TOTDIE*PARASI/TOTIR
c        sumdie=out3(ic,ih,7)+out3(ic,ih,20)
      ENDIF
c      diff=totdie-sumdie
c      sumdie=0.0
C
  900 CONTINUE

C     WRITE (16,*) 'IN BWEDIE: ISTAGE, IC, IH=',ISTAGE,IC,IH       ! TEMP DEBUG
C     WRITE (16,*) 'IN BWEDIE: BW(IC,IH)=',BW(IC,IH)               ! TEMP DEBUG
C     WRITE (16,*) 'IN BWEDIE: EATFOL,GODISP=',EATFOL,GODISP       ! TEMP DEBUG
C     WRITE (16,*) 'IN BWEDIE: SPRDIE,TOTDIE=',SPRDIE,TOTDIE       ! TEMP DEBUG

      RETURN
      END
