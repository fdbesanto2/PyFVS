      BLOCK DATA ESBLKD
      use prgprm_mod
      implicit none
C----------
C   **ESBLKD--ESTB   DATE OF LAST REVISION:   05/12/11
C----------
COMMONS
      INCLUDE 'ESPARM.F77'
C
      INCLUDE 'ESCOM2.F77'
C
      INCLUDE 'ESRNCM.F77'
C
      INCLUDE 'ESHAP.F77'
C
      INCLUDE 'ESHAP2.F77'
C
        INTEGER I,J
        DATA JOREGT/17/,ESS0/55329D0/,ESSS/55329.0/
C
C     COEFFICIENTS FOR P(SITE PREPS) BY PREP AND SERIES.
C     SITE PREP--> NONE     MECH     BURN     ROAD
C
      DATA XPREP/  0.0,     0.0,     0.0,     0.0,
     &           0.085732,-0.226844, 0.087087,0.620176,
     &           0.151164,-0.605840,-0.097998,1.390994,
     &           0.680760,-0.832692,-0.756665,0.951442,
     &           0.203387,-0.305596,-0.263820,0.995664 /
C
C     CHAB HOLDS CONSTANTS FOR P(ADVANCE SPECIES) BY HABITAT TYPE
C     H.T:1,9     2,10    3,11    4,12    5,13    6,14    7,15     8,16
C     ONLY USED IN **ESPADV.F***
C
      DATA ((CHAB(I,J), I=1,16),J=1,2)/
     1   0.0,  0.0,  0.0,  0.0,  0.0,-1.224798,  0.0,-1.224798,
     1   -.4296644,-1.224798,0.0,-1.224798,-.4296644,0.0,-.4296644,0.0,
     2   0.0,    0.0,    0.0,    0.0,1.4934765, 0.0,    0.0,    0.0,
     2   0.0,    0.0,    0.0,1.4934765,    0.0,    0.0,    0.0,    0.0/
      DATA ((CHAB(I,J), I=1,16),J=3,4)/
     3   0.0, 0.0, 0.0, 0.0,-0.6200184,-0.6200184,-1.1547343,-1.1547343,
     3  -2.1232,-2.3086,-1.36119,-.13552,-1.36119,-1.36119,-1.36119,0.0,
     4   0.0,   0.0,   0.0,   0.0, 0.674118, 0.0, 0.0, -0.3889028,
     4 -.7004423,-.7004423,-1.587698,-2.06589,2*-0.8935856,-2.06589,0.0/
      DATA ((CHAB(I,J), I=1,16),J=5,6)/24*0.0,0.0,0.6572366,6*0.0/
      DATA ((CHAB(I,J), I=1,16),J=7,8)/
     7   1.9319803,  0.0,  0.0,  0.0,  0.0,1.3270519,1.3270519,    0.0,
     7   0.0,0.0,1.9319803,1.9319803,0.0,0.0,1.3270519,0.0,     16*0.0/
      DATA ((CHAB(I,J), I=1,16),J=9,10)/ 8*0.0,
     9  0.0,1.404156,2.40966,2.40966,2.40966,2.40966,3.23979,3.23979,
     O   0.0, 0.0, 0.0, 0.0,-2.5921190,-2.5921190,-2.5921190,-0.7036813,
     O   -2.5921190,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0/
C
C     CPRE HOLDS CONSTANTS FOR P(ADVANCE SPECIES) BY PLOT SITE PREP
C     PREP-->     NONE    MECH      BURN       ROAD
C     ONLY USED IN **ESPADV.F***
C
      DATA CPRE/  0.0,-0.8986977,-0.8739164,     0.0,
     2            0.0,    0.0,     0.0,     0.0,
     3            0.0,-0.9135126,-1.5960879,-1.2667466,
     4            0.0,-0.9944621,-1.9561505,-1.3659292,
     5            0.0,-1.1545026,-3.1841443,-1.4654944,
     6            0.0,-0.5937042,-1.3850973,-1.5701306,
     7      4*0.0,0.0,-0.7526562,-0.9553895,-0.1442125,
     9            0.0,-0.7226382,-1.4396372, 0.0,
     O            0.0,-0.5682936,-0.7261403, 0.0/
C
C     DHAB HOLDS CONSTANTS FOR P(SUBSEQUENT SPECIES) BY HABITAT TYPE.
C     H.T:1,9   2,10    3,11    4,12    5,13    6,14    7,15    8,16
C     ONLY USED IN **ESPSUB.F***
C
      DATA ((DHAB(I,J),I=1,16),J=1,2)/8*0.0,
     1   0.6572202,1.0375612,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,
     2   .6603087, 3*0.0, 2*.6603087, 2*0.0,
     2   .7437406,.8959712,3*.7381694,0.0,.7381694,0.0/
      DATA ((DHAB(I,J),I=1,16),J=3,4)/8*0.0,
     3   2*0.0,-1.108112,2*-0.1829031,2*-1.108112,0.0,
     4   0.0,    0.0,    0.0,    0.0,    0.0,-0.2163169,   0.0, 0.0,
     4 .2288325,0.0,-2.442296,-2.442296,-.812497,2*-2.442296,0.0/
      DATA ((DHAB(I,J),I=1,16),J=5,6)/24*0.0,0.0,-0.6403333,6*0.0/
      DATA ((DHAB(I,J),I=1,16),J=7,8)/
     7   2*0.4017175,2*-0.7714835,0.0,0.6710793,0.0,-0.7714835,
     7   -0.543113,-.0868212,1.7321693,0.6710793,-.6315747,
     7   1.7321693,.4315782,-.6315747,
     8   0.0,0.0,0.0,0.0,0.3424427,0.3424427,-0.7935050,-0.7935050,
     8   0.0,0.2115143, 4*0.0954259, 2*0.5586635/
      DATA ((DHAB(I,J),I=1,16),J=9,10)/8*0.0,
     9   0.0,1.285995,2*1.036427,2.449334,1.036427,2*2.449334,
     O  0.0,.6557608,.6557608,.6557608,-.3939905,0.0,-.3939905,.6557608,
     O  8*0.0/
C
C     DPRE HOLDS CONSTANTS FOR P(SUBSEQUENT SPECIES) BY SITE PREP.
C     SITE PREP--> NONE     MECH     BURN     ROAD
C     ONLY USED IN **ESPSUB.F***
C
      DATA DPRE/   0.0,0.1547952,0.0230249,0.5517443,
     2             0.0,0.9831529,1.1296833,1.5132390,
     3             0.0,0.2274977,0.4415658,0.6000910,
     4             0.0,0.1840748,0.0475563,0.5660518,
     5             0.0,0.2282684,0.6218803,0.6568975,
     6             0.0,0.6319225,1.0655327,1.4428914,
     7             0.0,0.6404021,0.3812159,0.7928200,
     8             0.0,1.1533183,1.0900837,1.4772912,
     9             0.0,0.2232152,0.1324877,0.9357350,
     O             0.0,0.6788768,0.7407734,0.8536627/
C
C     FHAB HOLDS CONSTANTS FOR P(EXCESS BY SPECIES) BY HABITAT TYPE.
C     H.T:1,9   2,10     3,11    4,12     5,13    6,14     7,15     8,16
C     ONLY USED IN **ESPXCS.F***
C
      DATA ((FHAB(I,J),I=1,16),J=1,2)/
     1  4*0.0,-0.6746051,-0.6746051,0.0,-0.6746051,
     1  0.0,  0.0, 0.0,-0.6746051,-0.6746051,  0.0,     0.0,   0.0,
     2  1.0573224,0.0,0.0,0.0,1.0573224,1.0573224,.4331883,0.0,
     2  .433188,1.2050298,1.556329,1.556329,1.556329,0.0,1.556329 ,0.0/
      DATA ((FHAB(I,J),I=1,16),J=3,4)/
     3  .7860276,.7860276, 0.0, 0.0,  0.0,  0.0,  0.0, -.6077863,
     3  0.0,.4930977,-.6364138,.5219281,  0.0,-.6364138,  0.0,   0.0,
     4  0.0,   0.0,   0.0,  0.0,    0.0,-1.14939,-.5557902,-1.14939,
     4  0.0,    0.0,-2.43159,-2.43159,-.88282,-2.43159,-2.43159,0.0/
      DATA ((FHAB(I,J),I=1,16),J=5,6)/  24*0.0,0.0,-0.4357035,6*0.0/
      DATA ((FHAB(I,J),I=1,16),J=7,8)/
     7  0.0,0.0,-1.675261,4*-0.404111,-1.675261,
     7  -1.716393,-0.465368,2*0.786260,-0.653006,0.786260,2*-0.653006,
     8  0.0,   0.0,   0.0,  0.0,  0.0,   0.0,0.9266407,   0.0,
     8  1.859201,2.333042,.612418,.612418,1.852301,.0,1.852301,1.852301/
      DATA ((FHAB(I,J),I=1,16),J=9,10)/8*0.0,
     9  0.0,2.101272,2*1.8053228,3.371353,0.0,3.371353,2.101272,
     O  0.0, 0.0, 0.0, 0.0,-0.8002471,-0.8002471,-1.6319422,-0.8002471,
     O  -1.9000533,  0.0,   0.0,  0.0,  0.0,  0.0,  0.0,   0.0/
C
C     FPRE HOLDS CONSTANTS FOR P(EXCESS BY SPECIES) BY SITE PREP METHOD
C     SITE PREP-->    NONE     MECH      BURN      ROAD
C     ONLY USED IN **ESPXCS.F***
C
      DATA FPRE/4*0.0,0.0, 0.7580304, 0.6728193, 1.9293740,
     3                0.0,-0.4115679,-0.4939831, 0.0397986,
     4                0.0,-0.4249178,-0.8300082,-0.2121915,
     5                0.0,-0.2623001,-0.5655652,-0.1897423,
     6                0.0,-0.0647744, 0.1818555, 0.5362320,
     7                0.0, 0.0321509,-0.6495806,-0.5745220,
     8                0.0, 0.9904144, 0.5408921, 1.5293173,
     9                0.0,-0.5096514,-0.8132929, 0.2181278,4*0.0/
C
C     SPEHAB HOLDS CONSTANTS BY SERIES FOR P(X SPECIES ON THE PLOT)
C     HAB.TYPE-->  DF/     GF/       WRC/      WH/      SAF/
C     ONLY USED IN **ESNSPE.F***
C
      DATA SPEHAB/ 0.0, -.695637, -.776415, -1.227597,-1.058980,
     &             0.0,  .436955,  .426625,  .363575,   .721468,
     &             0.0,  .677341,  .900422,  1.290210,  .900652,
     &             0.0, 2.301903, 2.602609, 3.089499, 2.156324/
      END
