

   MEMBER('TestApp.clw')                                   ! This is a MEMBER module

                     MAP
                       INCLUDE('TESTSTABLEMANAGER.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
TestsTableManager    PROCEDURE                             ! Declare Procedure
  MAP
AssertEqual PROCEDURE(? pExpected,? pActual,STRING pInfo)
  .
testResults             ANY

QTest                   QUEUE
Id                        LONG
Number                    LONG
                        END
IQTest                  LONG

  CODE
? DEBUGHOOK(Detail:Record)
? DEBUGHOOK(DetailS:Record)
? DEBUGHOOK(Orders:Record)
? DEBUGHOOK(OrdersS:Record)

  DO OpenTps
  
  IF MESSAGE('Test SQL?|(database: TableManagerInventory)','SQL?',ICON:Question,BUTTON:YES+BUTTON:NO,BUTTON:YES) = BUTTON:YES
    DO OpenSql 
  .
  DO FillQTest
  
  DO TestLegacyTps 
  DO TestTableManagerTps  
  DO TestLegacySql 
  DO TestTableManagerSql
  DO TestLegacyQueue
  DO TestTableManagerQueue
    
  DO CloseTps
  DO CloseSql
  
  SETCLIPBOARD(testResults)
  STOP(testResults)

TestLegacyTps       ROUTINE
  DATA
ordrecs LONG
detrecs LONG
total   DECIMAL(15,2)
  CODE  
  
  CLEAR(ORD:Record)
  ORD:OrderDate = DATE(10,12,1996)
  SET(ORD:KeyOrderDate,ORD:KeyOrderDate)
  LOOP
    NEXT(Orders)
    IF ERRORCODE() THEN BREAK.
    IF ORD:OrderDate > DATE(10,28,1996) THEN BREAK.
    IF ORD:ShipState <> 'FL' THEN CYCLE.
    IF ORD:ShipZip = '33012' OR ORD:ShipZip = '33015' THEN CYCLE.
    ordrecs += 1
    CLEAR(DTL:Record)
    DTL:CustOrderNumbers = ORD:CustOrderNumbers
    SET(DTL:KeyDetails,DTL:KeyDetails)
    LOOP
      NEXT(Detail)
      IF ERRORCODE() THEN BREAK.
      IF DTL:CustOrderNumbers <> ORD:CustOrderNumbers THEN BREAK.
      detrecs += 1
      total += DTL:TotalCost
    .
  .
  
  AssertEqual('4 7 435.82',ordrecs&' '&detrecs&' '&total,'Legacy code TPS')

TestTableManagerTps       ROUTINE
  DATA
ordrecs LONG
detrecs LONG
total   DECIMAL(15,2)
tm  TableManager
  CODE  
  
  CLEAR(ORD:Record)
  tm.AddRange(ORD:OrderDate,DATE(10,12,1996),DATE(10,28,1996))
  tm.AddFilter(ORD:ShipState,'FL')
  tm.AddFilter('NOT ('&tm.V(ORD:ShipZip)&' = '&tm.S(33012)&' OR '&tm.V(ORD:ShipZip)&' = '&tm.S(33015)&' )')
  tm.SET(ORD:KeyOrderDate)
  LOOP UNTIL tm.NEXT(Orders)
    ordrecs += 1
    CLEAR(DTL:Record)
    tm.AddRange(DTL:CustOrderNumbers,ORD:CustOrderNumbers)
    tm.SET(DTL:KeyDetails)
    LOOP UNTIL tm.NEXT(Detail)
      detrecs += 1
      total += DTL:TotalCost
    .
  .  
  
  AssertEqual('4 7 435.82',ordrecs&' '&detrecs&' '&total,'Table Manager TPS')  
  
TestLegacySql       ROUTINE
  DATA
ordrecs LONG
detrecs LONG
total   DECIMAL(15,2)
  CODE  
 
  IF NOT STATUS(OrdersS) THEN EXIT.
  
  CLEAR(ORDS:Record)
  ORDS:OrderDate = DATE(10,12,1996)
  SET(ORDS:KeyOrderDate,ORDS:KeyOrderDate)
  LOOP
    NEXT(OrdersS)
    IF ERRORCODE() THEN BREAK.
    IF ORDS:OrderDate > DATE(10,28,1996) THEN BREAK.
    IF ORDS:ShipState <> 'FL' THEN CYCLE.
    IF ORDS:ShipZip = '33012' OR ORDS:ShipZip = '33015' THEN CYCLE.
    ordrecs += 1
    CLEAR(DTLS:Record)
    DTLS:CustOrderNumbers = ORDS:CustOrderNumbers
    SET(DTLS:KeyDetails,DTLS:KeyDetails)
    LOOP
      NEXT(DetailS)
      IF ERRORCODE() THEN BREAK.
      IF DTLS:CustOrderNumbers <> ORDS:CustOrderNumbers THEN BREAK.
      detrecs += 1
      total += DTLS:TotalCost
    .
  .
  
  AssertEqual('4 7 435.82',ordrecs&' '&detrecs&' '&total,'Legacy code SQL<13,10,13,10>'&OrdersS{PROP:SQL}&'<13,10,13,10>'&DetailS{PROP:SQL})

TestTableManagerSql       ROUTINE
  DATA
ordrecs LONG
detrecs LONG
total   DECIMAL(15,2)
tm TableManager
  CODE  
  
  IF NOT STATUS(OrdersS) THEN EXIT.

  CLEAR(ORDS:Record)
  tm.AddRange(ORDS:OrderDate,DATE(10,12,1996),DATE(10,28,1996) )
  tm.AddFilter(ORDS:ShipState,'FL')
  tm.AddFilter('NOT ('&tm.V(ORDS:ShipZip)&' = '&tm.S(33012)&' OR '&tm.V(ORDS:ShipZip)&' = '&tm.S(33015)&' )')
  tm.SET(ORDS:KeyOrderDate)
  LOOP UNTIL tm.NEXT(OrdersS)
    ordrecs += 1
    CLEAR(DTLS:Record)
    tm.AddRange(DTLS:CustOrderNumbers,ORDS:CustOrderNumbers)
    tm.SET(DTLS:KeyDetails)
    LOOP UNTIL tm.NEXT(DetailS)
      detrecs += 1
      total += DTLS:TotalCost
    .
  .
  
  AssertEqual('4 7 435.82',ordrecs&' '&detrecs&' '&total,'Table Manager SQL<13,10,13,10>'&OrdersS{PROP:SQL}&'<13,10,13,10>'&DetailS{PROP:SQL})
  
TestLegacyQueue     ROUTINE
  DATA
total   LONG
  CODE
  
  LOOP IQTest = 1 TO RECORDS(QTest)
    GET(QTest,IQTest)
    IF NOT INRANGE(QTest.Number,2000,4000) THEN CYCLE.
    total += QTest.Number
  .
  
  AssertEqual('6003000',total,'Legacy code Queue')
  
TestTableManagerQueue   ROUTINE
  DATA
total   LONG
tm TableManager
  CODE
  
  tm.AddFilter(QTest.Number,2000,4000)  
  tm.SET(QTest)
  LOOP UNTIL tm.NEXT(QTest)
    total += QTest.Number
  .
  
  AssertEqual('6003000',total,'Table Manager Queue')
  
OpenTps             ROUTINE
  OPEN(Orders)
  OPEN(Detail)

CloseTps            ROUTINE
  CLOSE(Orders)
  CLOSE(Detail)
  
OpenSql             ROUTINE 
  OPEN(OrdersS)
  IF ERRORCODE() = 2
    CREATE(OrdersS)
    OPEN(OrdersS)
  .   
  IF ERRORCODE() THEN STOP(ERRORCODE()&' '&ERROR()&' '&ERRORFILE()&' '&FILEERRORCODE()&' '&FILEERROR()).
  OPEN(DetailS)
  IF ERRORCODE() = 2
    CREATE(DetailS)
    OPEN(DetailS)
  .   
  IF ERRORCODE() THEN STOP(ERRORCODE()&' '&ERROR()&' '&ERRORFILE()&' '&FILEERRORCODE()&' '&FILEERROR()).
  
  IF NOT RECORDS(OrdersS)
    SET(Orders)
    LOOP 
      NEXT(Orders)
      IF ERRORCODE() THEN BREAK.
      ORDS:Record = ORD:Record
      ADD(OrdersS)
    .
  .

  IF NOT RECORDS(DetailS)
    SET(Detail)
    LOOP 
      NEXT(Detail)
      IF ERRORCODE() THEN BREAK.
      DTLS:Record = DTL:Record
      ADD(DetailS)
    .
  .

CloseSql            ROUTINE
  CLOSE(OrdersS)
  CLOSE(DetailS)
    
FillQTest           ROUTINE
  
  FREE(QTest)
  CLEAR(IQTest)
  LOOP 100000 TIMES
    IQTest += 1
    CLEAR(QTest)
    QTest.Id = IQTest
    QTest.Number = IQTest
    ADD(QTest)
  .


AssertEqual         PROCEDURE(? pExpected,? pActual,STRING pInfo)!,LONG,PROC
  CODE 
  testResults = testResults & |      
    CHOOSE(pExpected = pActual,'ok','--')&'<9>'& |
    CLIP(pInfo)&'<13,10>' & |
    'Exp: <'&CLIP(pExpected)&'>'&'<13,10>'& |
    'Act: <'&CLIP(pActual)&'>' & |
    '<13,10,13,10>'
