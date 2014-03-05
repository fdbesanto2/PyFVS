      SUBROUTINE GEMCR (IMODTY,IS,CR,BAU,BAT,HF,DF,H,RELDEN,PCTI)
      IMPLICIT NONE
C----------
C CR $Id$
C
C    THIS SUBROUTINE RETURNS CROWN RATIO
C----------
C  SPECIES ORDER:
C   1=AF,  2=CB,  3=DF,  4=GF,  5=WF,  6=MH,  7=RC,  8=WL,  9=BC, 10=LM,
C  11=LP, 12=PI, 13=PP, 14=WB, 15=SW, 16=UJ, 17=BS, 18=ES, 19=WS, 20=AS,
C  21=NC, 22=PW, 23=GO, 24=AW, 25=EM, 26=BK, 27=SO, 28=PB, 29=AJ, 30=RM,
C  31=OJ, 32=ER, 33=PM, 34=PD, 35=AZ, 36=CI, 37=OS, 38=OH
C
C  SPECIES EXPANSION:
C  UJ,AJ,RM,OJ,ER USE CR JU                              
C  NC,PW USE CR CO
C  GO,AW,EM,BK,SO USE CR OA                             
C  PB USES CR AS                              
C  PM,PD,AZ USE CR PI
C  CI USES CR PP                              
C----------
      INTEGER IS,IMODTY,ICRFLG
      REAL PCTI,RELDEN,H,DF,HF,BAT,BAU,CR,CL
      ICRFLG=0
C----------
C  BRANCH TO EQUATIONS FOR APPROPRIATE SPECIES.
C----------
      SELECT CASE(IS)
C----------
C  SUB-ALPINE FIR
C  CORKBARK FIR
C
C  SWMC,SWPP USE CORKBARK EQN FOR GENGYM SWMC
C  OTHER MODEL TYPES USE AF/CB EQN FROM GENGYM S-F & LP
C----------
      CASE(1,2)
        IF(IMODTY .LE. 2) THEN
          CL = 0.50706 + 0.73070 * HF
        ELSE
          CL = 0.36135 + 0.57085 * HF
        ENDIF
C----------
C DOUGLAS-FIR --- SWMC TYPE
C----------
      CASE(3)
        CL =  6.47479 + 0.54482 * DF + 0.50703 * HF - 0.03326 * BAT
C----------
C  GRAND FIR --- USE WHITE FIR EQUATION
C  WHITE FIR
C----------
      CASE(4,5)
        CL = 6.22959 + 0.67587 * HF - 0.03098 * BAT
C----------
C  MOUNTAIN HEMLOCK
C  MH EQUATION FROM NORTH IDAHO VARIANT, HABITAT TYPE 710 (TSME/XETE),
C  BITTERROOT NATIONAL FOREST
C----------
      CASE(6)
        CR = 0.3450 - 0.00264*BAT + 0.00000512*RELDEN*RELDEN
     &       - 0.25138*ALOG(H) + 0.05140*ALOG(PCTI)
        ICRFLG=1
C----------
C  WESTERN RED CEDAR
C  EQN FROM NI VARIANT, HABITAT TYPE 550 (THPL/OPHO)
C----------
      CASE(7)
        CR = -1.6053 + 0.17479*ALOG(BAT) -0.00183*RELDEN
     &       - 0.00560*DF + 0.11050*ALOG(PCTI)
        ICRFLG=1
C----------
C  WESTERN LARCH
C  EQN FROM NI VARIANT, 260 HABITAT TYPE, BITTERROOT NF
C----------
      CASE(8)
        CR = 0.03441 - 0.00204*BAT + 0.30066*ALOG(DF)
     &       - 0.59302*ALOG(H)
        ICRFLG=1
C----------
C  LODGEPOLE PINE
C----------
      CASE(11)
        CL = 5.00215 + 0.06334 * HF + 0.88236 * DF - 0.03821 * BAU
C----------
C  BRISTLECONE PINE
C  LIMBER PINE
C  PINYON PINE, SINGLELEAF PINYON, BORDER PINYON, ARIZONA PINYON PINE
C  WHITEBARK PINE
C  UTAH JUNIPER, ALLIGATOR JUNIPER, ROCKY MTN JUNIPER, ONESEED JUNIPER
C  EASTERN REDCEDAR
C  GAMBEL OAK, ARIZONA WHITE OAK, EMORY OAK, BUR OAK, SILVERLEAF OAK
C  OTHER SOFTWOODS
C----------
      CASE(9,10,12,14,16,23:27,29:35,37)
        CL = -0.59373 + 0.67703 * HF
C----------
C  PONDEROSA PINE, CHIHUAHUA PINE
C  SWMC AND SWPP HAVE THEIR OWN EQUATIONS.
C  OTHER MODEL TYPES USE THE BLACK HILLS EQUATION
C----------
      CASE(13,36)
C
C  PONDEROSA PINE --- SWMC TYPE
C
        IF(IMODTY .EQ. 1)THEN
          CL = 5.63367 + 0.56252 * HF - 0.06411 * BAT
C
C  PONDEROSA PINE --- SWPP TYPE
C
        ELSEIF (IMODTY .EQ. 2) THEN
          CL = 4.35671 + 0.84714 * DF + 0.32549 * HF - 0.03802 * BAT
C
C  PONDEROSA PINE  --- BLACK HILLS PP TYPE
C
        ELSE
          CL =  3.49178 + 0.80767 * DF + 0.17421 * HF - 0.03272 * BAT
        ENDIF
C----------
C  WESTERN WHITE PINE
C----------
      CASE(15)
        CL = 3.03832 + 0.65587 * HF - 0.01792 * BAT
C----------
C  BLUE SPRUCE
C----------
      CASE(17)
        CL = 3.61635 + 0.93639 * DF + 0.61547 * HF - 0.02360 * BAT
C----------
C  ENGELMANN SPRUCE
C  SWMC & SWPP USE SWMC EQN
C  ALL OTHER MODEL TYPES USE S-F EQN
C----------
      CASE(18)
C
C  ENGELMANN SPRUCE --- SWMC TYPE
C
        IF(IMODTY .LE. 2) THEN
          CL = 1.05857 + 0.68442 * HF
C
C  ENGELMANN SPRUCE --- SPRUCE/FIR MODEL TYPE
C
        ELSE
          CL = 3.22244 + 0.44315 * HF + 0.44755 * DF
        ENDIF
C----------
C  WHITE SPRUCE
C----------
      CASE(19)
        CL = 0.15768 + 0.74697 * HF
C----------
C  ASPEN, PAPER BIRCH
C  NARROWLEAF COTTONWOOD, PLAINS COTTONWOOD
C  OTHER HARDWOODS
C----------
      CASE(20,21,22,28,38)
        CL = 5.17281 + 0.32552 * HF - 0.01675 * BAT
C----------
C  PLACE FOR OTHER SPECIES.
C----------
      CASE DEFAULT
        CL = 1.
C
      END SELECT
C
C----------
C  IF CROWN LENGTH WAS PREDICTED, CONVERT TO CROWN RATIO
C----------
 1000 CONTINUE
      IF(ICRFLG .EQ. 0)THEN
        IF(CL .LT. 1.0) CL = 1.0
        IF(CL .GT. HF) CL = HF
        CR = CL / HF
      ENDIF
C
      RETURN
      END
