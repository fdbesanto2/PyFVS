      SUBROUTINE FORKOD
      use prgprm_mod
      implicit none
C----------
C CR $Id$
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'CONTRL.F77'
C
C----------
C  NATIONAL FORESTS:
C  201 = ARAPAHO (MAPPED TO ARAPAHO-ROOSEVELT)
C  202 = BIGHORN
C  203 = BLACK HILLS
C  204 = GRAND MESA, UNCOMPAHGRE, GUNNISON
C  205 = GUNNISON (MAPPED TO GMUG)
C  206 = MEDICINE BOW-ROUTT
C  207 = NEBRASKA
C  208 = PIKE (MAPPED TO PIKE-SAN ISABEL)
C  209 = RIO GRANDE
C  210 = ARAPAHO-ROOSEVELT
C  211 = ROUTT (MAPPED TO MEDICINE BOW-ROUTT)
C  212 = PIKE-SAN ISABEL
C  213 = SAN JUAN
C  214 = SHOSHONE
C  215 = WHITE RIVER
C  224 = GRAND MESA (MAPPED TO GMUG)
C  301 = APACHE-SITGREAVES
C  302 = CARSON
C  303 = CIBOLA
C  304 = COCONINO
C  305 = CORONADO
C  306 = GILA
C  307 = KAIBAB
C  308 = LINCOLN
C  309 = PRESCOTT
C  310 = SANTE FE
C  311 = SITGREAVES (MAPPED TO APACHE-SITGREAVES)
C  312 = TONTO
C----------
      INTEGER JFOR(28),NUMFOR,I
      DATA JFOR/ 202, 203, 204, 206, 207, 209, 210, 211, 212, 213,
     & 214, 215, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 312,
     & 201, 205, 208, 224, 311/
      DATA NUMFOR/28/
C
      IF (KODFOR .EQ. 0) GOTO 45
      DO 40 I=1,NUMFOR
      IF (KODFOR .EQ. JFOR(I)) GOTO 20
   40 CONTINUE
      CALL ERRGRO (.TRUE.,3)
   45 CONTINUE
      IF(IMODTY.LE.2) THEN
        IF(IFOR.EQ.0)IFOR=15
C----------
C IF REGION 2, AND MODEL TYPE 1 OR 2 CHANGE DEFAULT TO SAN JUAN (213)
C----------
        IF(KODFOR.GT.0 .AND. KODFOR.LT.300) IFOR=10
      ELSEIF (IMODTY.EQ.3) THEN
        IF(IFOR.EQ.0)IFOR=2
      ELSE
        IF(IFOR.EQ.0)IFOR=4
      ENDIF
      IF(KODFOR.GT.0) WRITE(JOSTND,11) JFOR(IFOR)
   11 FORMAT(T12,'FOREST CODE USED IN THIS PROJECTION IS ',I4)
      GOTO 30
   20 CONTINUE
      IF(I .EQ. 24)THEN
        WRITE(JOSTND,21)
   21   FORMAT(T12,'ARAPAHO NF (201) BEING MAPPED TO ARAPAHO-',
     &  'ROOSEVELT (210) FOR FURTHER PROCESSING.')
        I=7
      ELSEIF(I .EQ. 25)THEN
        WRITE(JOSTND,22)
   22   FORMAT(T12,'GUNNISON NF (205) BEING MAPPED TO GRAND MESA-',
     &  'UNCOMPAHGRE-GUNNISON (204) FOR FURTHER PROCESSING.')
        I=3
      ELSEIF(I .EQ. 26)THEN
        WRITE(JOSTND,23)
   23   FORMAT(T12,'PIKE NF (208) BEING MAPPED TO PIKE-SAN ',
     &  'ISABEL (212) FOR FURTHER PROCESSING.')
        I=9
      ELSEIF(I .EQ. 27)THEN
        WRITE(JOSTND,24)
   24   FORMAT(T12,'GRAND MESA NF (224) BEING MAPPED TO GRAND MESA-',
     &  'UNCOMPAHGRE-GUNNISON (204) FOR FURTHER PROCESSING.')
        I=3
      ELSEIF(I .EQ. 28)THEN
        WRITE(JOSTND,25)
   25   FORMAT(T12,'SITGREAVES NF (311) BEING MAPPED TO APACHE-',
     &  'SITGREAVES (301) FOR FURTHER PROCESSING.')
        I=13
      ELSEIF(I .EQ. 8)THEN
        WRITE(JOSTND,26)
   26   FORMAT(T12,'ROUTT NF (211) BEING MAPPED TO MEDICINE BOW-',
     &  'ROUTT (206) FOR FURTHER PROCESSING.')
        I=4
      ENDIF
      IFOR=I
   30 CONTINUE
      KODFOR=JFOR(IFOR)
      RETURN
      END
