      SUBROUTINE NBOLT(ISPC,H,D,DBHMIN,BFMIND,SINDX,TOPDOB,BFTDOB,
     &           JOSTND,DEBUG,IHT1,IHT2)
      use plot_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **NBOLT--NE   DATE OF LAST REVISION:  07/11/08
C----------
C THIS ROUTINE CALCULATES THE NUMBER OF 8' BOLTS TO SPECIFIED SAWTIMBER
C TOP DIAMETER AND THE NUMBER OF 8' BOLTS TO A SPECIFIED PULPWOOD TOP
C DIAMETER.
C----------
C
      LOGICAL DEBUG
C
      REAL B1(MAXSP),B2(MAXSP),B3(MAXSP),B4(MAXSP),B5(MAXSP),
     &          B6(MAXSP),DBHMIN(MAXSP),BFMIND(MAXSP)
      INTEGER IHT1,IHT2,JOSTND,ISPC
      REAL BFTDOB,TOPDOB,SINDX,D,H,FACTOR,ESTTHT,ESTCHT,PULBOL
      REAL ESTSHT,SAWBOL
C
      IF (DEBUG) WRITE(JOSTND,10)
   10 FORMAT(' ENTERING NBOLT ')
C
C----------
C  LOADING SPECIES SPECIFIC COEFFICIENTS FOR HEIGHT EQUATIONS.
C----------
      DATA B1/14.3040,13.6200,5*31.9570,36.8510,2*16.2810,16.9340,
     &      4*8.2079,2*5.3117,8*36.8510,6.8600,3*5.3416,3*7.1852,
     &      2*7.2773,5*6.1034,9.2078,8*8.1782,5*6.4301,8.1782,
     &      5*9.2078,7*3.8011,31*6.6844,11*13.6250/
C
      DATA B2/0.19894,.24255,5*.18511,.08298,2*.08621,.12972,
     &       4*.19672,2*.10357,8*.08298,.27725,3*.23044,3*.28384,
     &       2*.22721,5*.17368,.22208,8*.27316,5*.23545,.27316,
     *       5*.22208,7*.39213,31*.19049,11*.28668/
C
      DATA B3/1.4195,1.2885,5*1.7020,4*1.0000,4*1.3112,10*1.0000,1.4287,
     &        3*1.1529,3*1.4417,8*1.0000,8*1.7250,5*1.3380,1.7250,
     &        5*1.0000,7*2.9053,31*1.0000,11*1.6124/
C
      DATA B4/0.23349,.25831,5*.0,.00001,2*.16220,.20854,4*.33978,
     &       2*.68454,8*.00001,.40115,3*.54194,3*.38884,2*.41179,
     &       5*.44725,.31723,8*.38694,5*.47370,.38694,5*.31723,
     &       7*.55634,31*.43972,11*.30651/
C
      DATA B5/.76878,.68128,5*.68967,.63884,2*.86833,.77792,4*.76173,
     &        2*.71410,8*.63884,.85299,3*.83440,3*.82157,2*.76498,
     &        5*1.02370,.83560,8*.75822,5*.73385,.75822,5*.83560,
     &        7*.84317,31*.82962,11*1.02920/
C
      DATA B6/.12399,.10771,5*.16200,.18231,2*.23316,.12902,4*.11666,
     &        2*.0,8*.18231,.12403,3*.06372,3*.11411,2*.11046,5*.14610,
     &       .13465,8*.10847,5*.08228,.10847,5*.13465,7*.09593,
     &       31*.10806,11*.07460/
C
C----------
C  IF SPECIES IS RED SPRUCE AND SITE INDEX IS LESS THAN 35 THEN
C  PREDICT HEIGHT WITH BLACK SPRUCE COEFFICIENTS INSTEAD OF WHITE
C  SPRUCE.
C----------
C
      IF (ISPC .EQ. 4 .AND. SINDX .LT. 35) THEN
    	   B1(4)=20.03800
	   B2(4) = 0.18981
	   B3(4) = 1.2909
	   B4(4) = 0.17836
	   B5(4) = 0.57343
	   B6(4) = 0.10159
      END IF
C----------
C  COMPUTE ESTIMATED TOTAL TREE HEIGHT.
C----------
       IF(D .LT. DBHMIN(ISPC)) THEN
         IHT1=0
         IHT2=0
         GO TO 100
       ELSE
         FACTOR = 0.0
         ESTTHT = 4.5+B1(ISPC)*(1.0-EXP(-1.0*B2(ISPC)*D))
     &         **B3(ISPC)*SINDX**B4(ISPC)*(1.00001-FACTOR)
     &         **B5(ISPC)*BA**B6(ISPC)
         IF(DEBUG)WRITE(JOSTND,*)' ESTTHT=',ESTTHT,' ISPC=',ISPC,
     &      ' B1=',B1(ISPC),' B2=',B2(ISPC),' B3=',B3(ISPC),' B4=',
     &      B4(ISPC),' B5=',B5(ISPC),' B6=',B6(ISPC),' D=',D,' H=',H,
     &      ' SINDX=',SINDX,' TOP/D=',TOPDOB/D,' BA=',BA,
     &      ' TOPDOB=',TOPDOB
       ENDIF
C----------
C  COMPUTE THE NUMBER OF 8' BOLTS TO SPECIFIED PULPWOOD TOP DIAMETER.
C----------
       IF(D .LT. DBHMIN(ISPC)) THEN
         IHT1=0
         IHT2=0
         GO TO 100
       ELSE
         FACTOR = TOPDOB/D
         IF(FACTOR .GT. 1.0) FACTOR=1.0
         ESTCHT = 4.5+B1(ISPC)*(1.0-EXP(-1.0*B2(ISPC)*D))
     &         **B3(ISPC)*SINDX**B4(ISPC)*(1.00001-FACTOR)
     &         **B5(ISPC)*BA**B6(ISPC)
         IF(DEBUG)WRITE(JOSTND,*)' ESTCHT=',ESTCHT,' ISPC=',ISPC,
     &      ' B1=',B1(ISPC),' B2=',B2(ISPC),' B3=',B3(ISPC),' B4=',
     &      B4(ISPC),' B5=',B5(ISPC),' B6=',B6(ISPC),' D=',D,' H=',H,
     &      ' SINDX=',SINDX,' TOP/D=',TOPDOB/D,' BA=',BA,
     &      ' TOPDOB=',TOPDOB
		PULBOL=ESTCHT*(H/ESTTHT)
         IHT2=PULBOL/8.333333
         IF(DEBUG)WRITE(JOSTND,*)' No. PULPWOOD BOLTS (IHT2)= ',IHT2
       ENDIF
C----------
C  COMPUTE THE NUMBER OF 8' BOLTS TO A SPECIFIED SAWTIMBER TOP
C  DIAMETER.
C----------
       IF(D .LT. BFMIND(ISPC)) THEN
         IHT1=0
         GO TO 100
       ELSE
         FACTOR = BFTDOB/D
         IF(FACTOR .GT. 1.0) FACTOR=1.0
         ESTSHT = 4.5+B1(ISPC)*(1.0-EXP(-1.0*B2(ISPC)*D))
     &         **B3(ISPC)*SINDX**B4(ISPC)*(1.00001-FACTOR)
     &         **B5(ISPC)*BA**B6(ISPC)
         IF(DEBUG)WRITE(JOSTND,*)' B1=',B1(ISPC),' B2=',B2(ISPC),
     &     ' B3=',B3(ISPC),' B4=',B4(ISPC),' B5=',B5(ISPC),' B6=',
     &     B6(ISPC),' ISPC=',ISPC,' BA=',BA,' SINDX=',SINDX,
     &     ' BFT/D=',BFTDOB/D,' D=',D,' H=',H,' ESTSHT=',ESTSHT
		SAWBOL=ESTSHT*(H/ESTTHT)
         IHT1=SAWBOL/8.333333
         IF(DEBUG)WRITE(JOSTND,*)' No. SAWWOOD BOLTS (IHT1)= ',IHT1
      ENDIF
100   CONTINUE
      RETURN
      END
