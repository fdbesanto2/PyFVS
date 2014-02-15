      SUBROUTINE TREMOV (IREC1,IREC2)
      IMPLICIT NONE
C----------
C  $Id: tremov.f 767 2013-04-10 22:29:22Z rhavis@msn.com $
C----------
C
C      SWITCH THE TREES FROM POSITION IREC1 AND POSITION IREC2.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'ESTREE.F77'
C
C
      INCLUDE 'STDSTK.F77'
C
C
COMMONS
C
C----------
      REAL RTEM(21)
      INTEGER ITEM(13),IREC2,IREC1,IDMR,JDMR
C
      RTEM( 1) = BFV(IREC1)
      RTEM( 2) = CFV(IREC1)
      RTEM( 3) = DBH(IREC1)
      RTEM( 4) = DG(IREC1)
      RTEM( 5) = HT(IREC1)
      RTEM( 6) = HTG(IREC1)
      RTEM( 7) = OLDPCT(IREC1)
      RTEM( 8) = OLDRN(IREC1)
      RTEM( 9) = PCT(IREC1)
      RTEM(10) = WK1(IREC1)
      RTEM(11) = WK2(IREC1)
      RTEM(12) = WK3(IREC1)
      RTEM(13) = PROB(IREC1)
      RTEM(14) = ABIRTH(IREC1)
      RTEM(15) = ZRAND(IREC1)
      RTEM(16) = PTOCFV(IREC1)
      RTEM(17) = PMRCFV(IREC1)
      RTEM(18) = PMRBFV(IREC1)
      RTEM(19) = PDBH(IREC1)
      RTEM(20) = PHT(IREC1)
      RTEM(21) = CRWDTH(IREC1)
      ITEM( 1) = ICR(IREC1)
      ITEM( 2) = IMC(IREC1)
      ITEM( 3) = ISP(IREC1)
      ITEM( 4) = DEFECT(IREC1)
      ITEM( 5) = ISPECL(IREC1)
      ITEM( 6) = KUTKOD(IREC1)
      ITEM( 7) = ITRUNC(IREC1)
      ITEM( 8) = NORMHT(IREC1)
      ITEM( 9) = ITRE(IREC1)
      ITEM(10) = IESTAT(IREC1)
      ITEM(11) = IDTREE(IREC1)
      ITEM(12) = NCFDEF(IREC1)
      ITEM(13) = NBFDEF(IREC1)
C----------
      BFV(IREC1)    = BFV(IREC2)
      CFV(IREC1)    = CFV(IREC2)
      DBH(IREC1)    = DBH(IREC2)
      DG(IREC1)     = DG(IREC2)
      HT(IREC1)     = HT(IREC2)
      HTG(IREC1)    = HTG(IREC2)
      OLDPCT(IREC1) = OLDPCT(IREC2)
      OLDRN(IREC1)  = OLDRN(IREC2)
      PCT(IREC1)    = PCT(IREC2)
      WK1(IREC1)    = WK1(IREC2)
      WK2(IREC1)    = WK2(IREC2)
      WK3(IREC1)    = WK3(IREC2)
      ICR(IREC1)    = ICR(IREC2)
      IMC(IREC1)    = IMC(IREC2)
      ISP(IREC1)    = ISP(IREC2)
      DEFECT(IREC1) = DEFECT(IREC2)
      ISPECL(IREC1) = ISPECL(IREC2)
      KUTKOD(IREC1) = KUTKOD(IREC2)
      ITRUNC(IREC1) = ITRUNC(IREC2)
      NORMHT(IREC1) = NORMHT(IREC2)
      ITRE(IREC1)   = ITRE(IREC2)
      PROB(IREC1)   = PROB(IREC2)
      IESTAT(IREC1) = IESTAT(IREC2)
      ABIRTH(IREC1) = ABIRTH(IREC2)
      IDTREE(IREC1) = IDTREE(IREC2)
      ZRAND(IREC1)  = ZRAND(IREC2)
      PTOCFV(IREC1) = PTOCFV(IREC2)
      PMRCFV(IREC1) = PMRCFV(IREC2)
      PMRBFV(IREC1) = PMRBFV(IREC2)
      NCFDEF(IREC1) = NCFDEF(IREC2)
      NBFDEF(IREC1) = NBFDEF(IREC2)
      PDBH(IREC1)   = PDBH(IREC2)
      PHT(IREC1)    = PHT(IREC2)
      CRWDTH(IREC1) = CRWDTH(IREC2)
C----------
C  ZERO OUT IREC2 POSITION
C----------
      BFV(IREC2)    = RTEM( 1)
      CFV(IREC2)    = RTEM( 2)
      DBH(IREC2)    = RTEM( 3)
      DG(IREC2)     = RTEM( 4)
      HT(IREC2)     = RTEM( 5)
      HTG(IREC2)    = RTEM( 6)
      OLDPCT(IREC2) = RTEM( 7)
      OLDRN(IREC2)  = RTEM( 8)
      PCT(IREC2)    = RTEM( 9)
      WK1(IREC2)    = RTEM(10)
      WK2(IREC2)    = RTEM(11)
      WK3(IREC2)    = RTEM(12)
      PROB(IREC2)   = RTEM(13)
      ABIRTH(IREC2) = RTEM(14)
      ZRAND(IREC2)  = RTEM(15)
      PTOCFV(IREC2) = RTEM(16)
      PMRCFV(IREC2) = RTEM(17)
      PMRBFV(IREC2) = RTEM(18)
      PDBH(IREC2)   = RTEM(19)
      PHT(IREC2)    = RTEM(20)
      CRWDTH(IREC2) = RTEM(21)
      ICR(IREC2)    = ITEM( 1)
      IMC(IREC2)    = ITEM( 2)
      ISP(IREC2)    = ITEM( 3)
      DEFECT(IREC2) = ITEM( 4)
      ISPECL(IREC2) = ITEM( 5)
      KUTKOD(IREC2) = ITEM( 6)
      ITRUNC(IREC2) = ITEM( 7)
      NORMHT(IREC2) = ITEM( 8)
      ITRE(IREC2)   = ITEM( 9)
      IESTAT(IREC2) = ITEM(10)
      IDTREE(IREC2) = ITEM(11)
      NCFDEF(IREC2) = ITEM(12)
      NBFDEF(IREC2) = ITEM(13)
C----------
C  GET MISTLETOE RATING FROM POSITION IREC2 AND PUT IT AT IEND.
C----------
      CALL MISGET(IREC2,IDMR)
      CALL MISGET(IREC1,JDMR)
      CALL MISPUT(IREC2,JDMR)
      CALL MISPUT(IREC1,IDMR)
C
      RETURN
      END
