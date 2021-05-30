# Table Manager

A class to read tables with less code while optimizing for SQL backends.

This is the common code to read a table:

  CLEAR(ORD:Record)
  ORD:OrderDate = DATE(10,12,1996)
  SET(ORD:KeyOrderDate,ORD:KeyOrderDate)
  LOOP
    NEXT(Orders)
    IF ERRORCODE() THEN BREAK.
    IF ORD:OrderDate > DATE(10,28,1996) THEN BREAK.
    IF ORD:ShipState <> 'FL' THEN CYCLE.
    CLEAR(DTL:Record)
    DTL:CustOrderNumbers = ORD:CustOrderNumbers
    SET(DTL:KeyDetails,DTL:KeyDetails)
    LOOP
      NEXT(Detail)
      IF ERRORCODE() THEN BREAK.
      IF DTL:CustOrderNumbers <> ORD:CustOrderNumbers THEN BREAK.
      !Some code
    .
  .

Using table manager, it can reduced to:

  CLEAR(ORD:Record)
  tm.AddRange(ORD:OrderDate,DATE(10,12,1996),DATE(10,28,1996))
  tm.AddFilter(ORD:ShipState,'FL')
  tm.SET(ORD:KeyOrderDate)
  LOOP UNTIL tm.NEXT(Orders)
    CLEAR(DTL:Record)
    tm.AddRange(DTL:CustOrderNumbers,ORD:CustOrderNumbers)
    tm.SET(DTL:KeyDetails)
    LOOP UNTIL tm.NEXT(Detail)
      !Some code
    .
  .  

