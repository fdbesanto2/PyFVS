      BLOCK DATA DMBLKD
      IMPLICIT NONE
C----------
C  $Id: dmblkd.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C  **DMBLKD  DATE OF LAST REVISION:  02/15/96
C----------
C Purpose:
C   An immense data statement that assigns all the precomputed
C trajectory information, and a matrix of pointers to grid cell
C positions in that list
C
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'DMCOM.F77'
C
C
COMMONS
C

      INTEGER I

      DATA ( Shd1(i), i=    1,  120 ) /
     &     1,    98,     1,    18,     1,    10,     1,     9,
     &     1,     8,     1,     7,     1,     6,     1,     5,
     &     1,     4,     1,     3,     1,     2,     1,   100,
     &     1,    16,     1,    10,     1,     9,     1,     8,
     &     1,     7,     1,     6,     1,     5,     1,     4,
     &     1,     3,     1,   104,     1,    14,     1,    10,
     &     1,     9,     1,     8,     1,     7,     1,     6,
     &     1,     5,     1,     4,     1,   110,     1,    12,
     &     1,    10,     1,     9,     1,     8,     1,     7,
     &     1,     6,     1,     5,     1,   119,     1,    10,
     &     1,    10,     1,     9,     1,     8,     1,     7,
     &     1,     6,     1,   137,     1,     8,     1,    10,
     &     1,     9,     1,     8,     1,     7,     1,   167,
     &     1,     6,     1,    10,     1,     9,     1,     8,
     &     1,   232,     1,     4,     1,    10,     1,     9 / 

      DATA ( Shd1(i), i=  121,  240 ) /
     &     1,   397,     1,     2,     1,    10,     1,    38,
     &     1,    12,     1,    10,     1,    11,     1,    12,
     &     1,    13,     1,    12,     1,    11,     1,   384,
     &     1,     2,     1,    10,     1,   222,     1,     4,
     &     1,    10,     1,    11,     1,   107,     1,     6,
     &     1,    10,     1,    11,     1,    12,     1,   103,
     &     1,    32,     1,    10,     1,    11,     1,    12,
     &     1,    13,     2,    13,     2,    12,     2,    11,
     &     2,    10,     2,     9,     2,     8,     2,     7,
     &     2,     6,     2,     5,     2,     4,     2,     3,
     &     2,     2,     1,   105,     1,    18,     1,    10,
     &     1,     9,     1,     8,     1,     7,     2,     7,
     &     2,     6,     2,     5,     2,     4,     2,     3,
     &     1,   111,     1,    16,     1,    10,     1,     9,
     &     1,     8,     1,     7,     2,     7,     2,     6 / 

      DATA ( Shd1(i), i=  241,  360 ) /
     &     2,     5,     2,     4,     1,   118,     1,    14,
     &     1,    10,     1,     9,     1,     8,     1,     7,
     &     2,     7,     2,     6,     2,     5,     1,   129,
     &     1,    12,     1,    10,     1,     9,     1,     8,
     &     2,     8,     2,     7,     2,     6,     1,   148,
     &     1,    10,     1,    10,     1,     9,     1,     8,
     &     2,     8,     2,     7,     1,   176,     1,     8,
     &     1,    10,     1,     9,     1,     8,     2,     8,
     &     1,   224,     1,     6,     1,    10,     1,     9,
     &     2,     9,     1,   286,     1,     4,     1,    10,
     &     1,     9,     1,   338,     1,     2,     1,    10,
     &     1,   272,     1,     4,     1,    10,     1,    11,
     &     1,   221,     1,     6,     1,    10,     1,    11,
     &     2,    11,     1,   135,     1,     8,     1,    10,
     &     1,    11,     1,    12,     2,    12,     1,   111 / 

      DATA ( Shd1(i), i=  361,  480 ) /
     &     1,    22,     1,    10,     1,     9,     1,     8,
     &     2,     8,     2,     7,     2,     6,     3,     6,
     &     3,     5,     3,     4,     3,     3,     3,     2,
     &     1,   115,     1,    20,     1,    10,     1,     9,
     &     1,     8,     2,     8,     2,     7,     2,     6,
     &     3,     6,     3,     5,     3,     4,     3,     3,
     &     1,   121,     1,    18,     1,    10,     1,     9,
     &     1,     8,     2,     8,     2,     7,     2,     6,
     &     3,     6,     3,     5,     3,     4,     1,   126,
     &     1,    16,     1,    10,     1,     9,     1,     8,
     &     2,     8,     2,     7,     2,     6,     3,     6,
     &     3,     5,     1,   137,     1,    14,     1,    10,
     &     1,     9,     2,     9,     2,     8,     2,     7,
     &     3,     7,     3,     6,     1,   152,     1,    12,
     &     1,    10,     1,     9,     2,     9,     2,     8 / 

      DATA ( Shd1(i), i=  481,  600 ) /
     &     2,     7,     3,     7,     1,   173,     1,    10,
     &     1,    10,     1,     9,     2,     9,     2,     8,
     &     3,     8,     1,   199,     1,     8,     1,    10,
     &     1,     9,     2,     9,     2,     8,     1,   218,
     &     1,     6,     1,    10,     2,    10,     2,     9,
     &     1,   213,     1,     4,     1,    10,     2,    10,
     &     1,   200,     1,     6,     1,    10,     1,    11,
     &     2,    11,     1,   234,     1,     8,     1,    10,
     &     1,    11,     2,    11,     2,    12,     1,    99,
     &     1,    10,     1,    10,     1,    11,     1,    12,
     &     2,    12,     2,    13,     1,   126,     1,    24,
     &     1,    10,     1,     9,     2,     9,     2,     8,
     &     3,     8,     3,     7,     3,     6,     4,     6,
     &     4,     5,     4,     4,     4,     3,     4,     2,
     &     1,   130,     1,    22,     1,    10,     1,     9 / 

      DATA ( Shd1(i), i=  601,  720 ) /
     &     2,     9,     2,     8,     3,     8,     3,     7,
     &     3,     6,     4,     6,     4,     5,     4,     4,
     &     4,     3,     1,   134,     1,    20,     1,    10,
     &     1,     9,     2,     9,     2,     8,     3,     8,
     &     3,     7,     3,     6,     4,     6,     4,     5,
     &     4,     4,     1,   140,     1,    18,     1,    10,
     &     1,     9,     2,     9,     2,     8,     3,     8,
     &     3,     7,     3,     6,     4,     6,     4,     5,
     &     1,   151,     1,    16,     1,    10,     1,     9,
     &     2,     9,     2,     8,     3,     8,     3,     7,
     &     4,     7,     4,     6,     1,   162,     1,    14,
     &     1,    10,     1,     9,     2,     9,     2,     8,
     &     3,     8,     3,     7,     4,     7,     1,   178,
     &     1,    12,     1,    10,     1,     9,     2,     9,
     &     2,     8,     3,     8,     3,     7,     1,   192 / 

      DATA ( Shd1(i), i=  721,  840 ) /
     &     1,    10,     1,    10,     2,    10,     2,     9,
     &     3,     9,     4,     9,     1,   205,     1,     8,
     &     1,    10,     2,    10,     2,     9,     3,     9,
     &     1,   211,     1,     6,     1,    10,     2,    10,
     &     3,    10,     1,   276,     1,    12,     1,    10,
     &     1,    11,     2,    11,     2,    12,     3,    12,
     &     4,    12,     1,   160,     1,    10,     1,    10,
     &     1,    11,     2,    11,     2,    12,     3,    12,
     &     1,   152,     1,    34,     1,    10,     1,    11,
     &     2,    11,     2,    12,     3,    12,     4,    12,
     &     4,    11,     5,    11,     5,    10,     5,     9,
     &     5,     8,     5,     7,     5,     6,     5,     5,
     &     5,     4,     5,     3,     5,     2,     1,   156,
     &     1,    24,     1,    10,     1,     9,     2,     9,
     &     3,     9,     3,     8,     4,     8,     4,     7 / 

      DATA ( Shd1(i), i=  841,  960 ) /
     &     4,     6,     5,     6,     5,     5,     5,     4,
     &     5,     3,     1,   161,     1,    30,     1,    10,
     &     1,    11,     2,    11,     2,    12,     3,    12,
     &     4,    12,     4,    11,     5,    11,     5,    10,
     &     5,     9,     5,     8,     5,     7,     5,     6,
     &     5,     5,     5,     4,     1,   168,     1,    28,
     &     1,    10,     1,    11,     2,    11,     2,    12,
     &     3,    12,     4,    12,     4,    11,     5,    11,
     &     5,    10,     5,     9,     5,     8,     5,     7,
     &     5,     6,     5,     5,     1,   178,     1,    26,
     &     1,    10,     1,    11,     2,    11,     2,    12,
     &     3,    12,     4,    12,     4,    11,     5,    11,
     &     5,    10,     5,     9,     5,     8,     5,     7,
     &     5,     6,     1,   189,     1,    16,     1,    10,
     &     2,    10,     2,     9,     3,     9,     4,     9 / 

      DATA ( Shd1(i), i=  961, 1080 ) /
     &     4,     8,     5,     8,     5,     7,     1,   207,
     &     1,    22,     1,    10,     1,    11,     2,    11,
     &     2,    12,     3,    12,     4,    12,     4,    11,
     &     5,    11,     5,    10,     5,     9,     5,     8,
     &     1,   230,     1,    20,     1,    10,     1,    11,
     &     2,    11,     2,    12,     3,    12,     4,    12,
     &     4,    11,     5,    11,     5,    10,     5,     9,
     &     1,   287,     1,    18,     1,    10,     1,    11,
     &     2,    11,     2,    12,     3,    12,     4,    12,
     &     4,    11,     5,    11,     5,    10,     1,   283,
     &     1,    16,     1,    10,     1,    11,     2,    11,
     &     2,    12,     3,    12,     4,    12,     4,    11,
     &     5,    11,     1,   179,     1,    14,     1,    10,
     &     1,    11,     2,    11,     2,    12,     3,    12,
     &     4,    12,     4,    11,     1,   232,     1,    28 / 

      DATA ( Shd1(i), i= 1081, 1200 ) /
     &     1,    10,     2,    10,     2,     9,     3,     9,
     &     4,     9,     4,     8,     5,     8,     5,     7,
     &     5,     6,     6,     6,     6,     5,     6,     4,
     &     6,     3,     6,     2,     1,   240,     1,    30,
     &     1,    10,     1,    11,     2,    11,     3,    11,
     &     4,    11,     5,    11,     5,    10,     6,    10,
     &     6,     9,     6,     8,     6,     7,     6,     6,
     &     6,     5,     6,     4,     6,     3,     1,   253,
     &     1,    28,     1,    10,     1,    11,     2,    11,
     &     3,    11,     4,    11,     5,    11,     5,    10,
     &     6,    10,     6,     9,     6,     8,     6,     7,
     &     6,     6,     6,     5,     6,     4,     1,   275,
     &     1,    26,     1,    10,     1,    11,     2,    11,
     &     3,    11,     4,    11,     5,    11,     5,    10,
     &     6,    10,     6,     9,     6,     8,     6,     7 / 

      DATA ( Shd1(i), i= 1201, 1320 ) /
     &     6,     6,     6,     5,     1,   329,     1,    20,
     &     1,    10,     2,    10,     3,    10,     4,    10,
     &     4,     9,     5,     9,     5,     8,     6,     8,
     &     6,     7,     6,     6,     1,   358,     1,    18,
     &     1,    10,     2,    10,     3,    10,     4,    10,
     &     5,    10,     5,     9,     6,     9,     6,     8,
     &     6,     7,     1,   323,     1,    16,     1,    10,
     &     2,    10,     3,    10,     4,    10,     5,    10,
     &     5,     9,     6,     9,     6,     8,     1,   272,
     &     1,    14,     1,    10,     2,    10,     3,    10,
     &     4,    10,     5,    10,     5,     9,     6,     9,
     &     1,   201,     1,    12,     1,    10,     2,    10,
     &     3,    10,     4,    10,     5,    10,     5,     9,
     &     1,    78,     1,    14,     1,    10,     1,    11,
     &     2,    11,     3,    11,     4,    11,     5,    11 / 

      DATA ( Shd1(i), i= 1321, 1440 ) /
     &     5,    10,     1,   209,     1,    30,     1,    10,
     &     2,    10,     3,    10,     4,    10,     5,    10,
     &     5,     9,     6,     9,     6,     8,     6,     7,
     &     6,     6,     6,     5,     7,     5,     7,     4,
     &     7,     3,     7,     2,     1,   199,     1,    28,
     &     1,    10,     2,    10,     3,    10,     4,    10,
     &     5,    10,     5,     9,     6,     9,     6,     8,
     &     6,     7,     6,     6,     6,     5,     7,     5,
     &     7,     4,     7,     3,     1,   184,     1,    26,
     &     1,    10,     2,    10,     3,    10,     4,    10,
     &     5,    10,     5,     9,     6,     9,     6,     8,
     &     6,     7,     6,     6,     6,     5,     7,     5,
     &     7,     4,     1,   162,     1,    24,     1,    10,
     &     2,    10,     3,    10,     4,    10,     5,    10,
     &     5,     9,     6,     9,     6,     8,     6,     7 / 

      DATA ( Shd1(i), i= 1441, 1496 ) /
     &     6,     6,     6,     5,     7,     5,     1,   127,
     &     1,    22,     1,    10,     2,    10,     3,    10,
     &     4,    10,     5,    10,     5,     9,     6,     9,
     &     6,     8,     6,     7,     6,     6,     6,     5,
     &     1,    54,     1,    20,     1,    10,     2,    10,
     &     3,    10,     4,    10,     5,    10,     5,     9,
     &     6,     9,     6,     8,     6,     7,     6,     6 /


      DATA ShdPtr  /
     &     1,    23,    43,    61,    77,    91,   103,   113,
     &   121,   127,   143,   149,   157,   167,   203,   225,
     &   245,   263,   279,   293,   305,   315,   323,   329,
     &   337,   347,   359,   385,   409,   431,   451,   469,
     &   485,   499,   511,   521,   529,   539,   551,   565,
     &   593,   619,   643,   665,   685,   703,   719,   733,
     &   745,   755,   771,     0,   785,   823,   851,   885,
     &   917,   947,   967,   993,  1017,  1039,  1059,     0,
     &     0,  1077,  1109,  1143,  1175,  1205,  1229,  1251,
     &  1271,  1289,  1305,     0,     0,     0,  1323,  1357,
     &  1389,  1419,  1447,  1473,     0,     0,     0,     0,
     &     0,     0,     0 /

      END
