!== last modified  03-29-2004
      SUBROUTINE R6VOL2(VOLEQ,DBHOB,HT,VOL,ERRFLAG)
C  CREATED:   06-05-91

C  PURPOSE:   THIS ROUTINE WILL CALCULATE R6 BDFT VOLUMES ACCORDING TO
C                THE MOST RECENTLY ADDED VOLUME EQUATIONS.
C  DECLARE VARIABLES

      CHARACTER*10 VOLEQ
      INTEGER EQU,ERRFLAG

      REAL DBHOB, HT, VOL(15), COEFF(6,5)

      DATA ((COEFF(I,J), J = 1,5), I = 1,6) /
     >    0.0000000,  1.9510920, -.1313649,  -.3926337,  .0115273,
     >  -38.6517248, 14.7619230, -.2773275, -1.3283856,  .0142368,
     >  -50.9378600, 21.4280400, -.4476645, -2.1493860,  .0203710,
     >    0.0000000,  3.9434930, -.3229676,  -.5601420,  .0144415,
     >  -50.9602199, 21.9511399, -.5506570, -2.3294660,  .0247944,
     >    8.7000000,  0.0000000, 0.0000000, -0.7600000, 0.0200000/

      ERRFLAG = 0
      IF(VOLEQ(8:10).EQ.'205' .AND. VOLEQ(1:3).EQ.'601')THEN
         EQU = 1
      ELSEIF(VOLEQ(8:10).EQ.'263' .AND. VOLEQ(1:3).EQ.'601')THEN
         EQU = 2
      ELSEIF(VOLEQ(8:10).EQ.'015' .AND. VOLEQ(1:3).EQ.'601')THEN
         EQU = 3
      ELSEIF(VOLEQ(8:10).EQ.'204' .AND. VOLEQ(1:3).EQ.'602')THEN
         EQU = 4
      ELSEIF(VOLEQ(8:10).EQ.'015' .AND. VOLEQ(1:3).EQ.'602')THEN
         EQU = 5
      ELSEIF(VOLEQ(8:10).EQ.'108' .AND. VOLEQ(1:3).EQ.'602')THEN
         EQU = 6
      ELSEIF(VOLEQ(8:10).EQ.'122')THEN
         EQU = 7
      ELSE
         ERRFLAG = 0
         RETURN
      ENDIF
      
      IF (EQU.EQ.7) THEN
        VOL(2) = -2.9815 + (-0.2013*DBHOB*DBHOB) + (0.000141*DBHOB**3 *
     >            HT) + (0.0084*DBHOB*DBHOB*HT)
      ELSE
        VOL(2) = COEFF(EQU,1) + COEFF(EQU,2)*DBHOB + COEFF(EQU,3)*HT +
     >           COEFF(EQU,4)*DBHOB*DBHOB + COEFF(EQU,5)*DBHOB*DBHOB*HT
      ENDIF

      VOL(3) = VOL(2)

      RETURN
      END
