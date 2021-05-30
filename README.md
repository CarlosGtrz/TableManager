# Table Manager
A class to read tables with less code while optimizing for SQL backends.

## Introduction
This is a common way to read a table with Clarion:

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

Using **Table Manager**, it can be reduced to:

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

When executed against a SQL backend, the first example generates this `WHERE` clause:
    
    WHERE (ORDERDATE >= ? AND (ORDERDATE > ? OR (CUSTNUMBER >= ? AND (CUSTNUMBER > ? OR (ORDERNUMBER >= ? )))))
    
It only filters records lower than the initial key value. The end of the range and the filters must be evaluated on the client side. 

Using **Table Manager**, the backend does all the filtering:

    WHERE (ORDERDATE >= '19961012' AND ORDERDATE <= '19961028' AND SHIPSTATE = 'FL'  )
    
## Install
Copy `TableManager.clw` and `TableManager.inc` to any folder in your `.red` file (for example `Accessory\libsrc`).

## Using
Add the line:

    INCLUDE('TableManager.inc'),ONCE
    
To a global data embed (like _After Global INCLUDEs_), and declare an instance in your procedure or routine:

    tm TableManager
      CODE
      CLEAR(tlb:Record)
      tm.AddRange(tbl:field,loc:value)
      ...

## Methods

### AddRange, AddFilter
    .AddRange ( field , value )
    .AddRange ( field , firstvalue , lastvalue )
    .AddFilter ( field , value )
    .AddFilter ( field , firstvalue , lastvalue )

Adds a condition to process the table referenced in the next `.SET` method.

*Parameters*
* _field_ The label of a field in the table.
* _value_ A constant, variable or expression. Only records where _field_ equal _value_ will be processed.
* _firstvalue_, _lastvalue_ A constant, variable or expression. Only records where _field_ has a value between _firstvalue_ and _lastvalue_ will be processed.

A _Range_ condition will cause the `.NEXT` method to return `tm:Record:OutOfRange` when the records doesn't meet the condition, causing the `LOOP` to break.
A _Filter_ condition will cause the `.NEXT` method to skip the record and advance to the next one, without breaking the `LOOP`.

If the _field_ is a `GROUP` and the table is SQL, the condition for the `WHERE` clause will be created using the member fields. Example:

    Orders               FILE,DRIVER('MSSQL')
    ...
    Record                   RECORD,PRE()
    CustOrderNumbers            GROUP
    CustNumber                    LONG
    OrderNumber                   LONG
                                END              
    ...
       tm.AddRange(DTL:CustOrderNumbers,ORD:CustOrderNumbers)
       
Will add this to the `WHERE` clause:

    AND (CUSTNUMBER = 11 AND ORDERNUMBER = 1 )

### AddFilterExpression
    .AddFilterExpression ( expression ), 
     .Variable ( field ) .V ( field )
    .FormatString ( value ), .F (value)
    .FormatDate ( value ), .D ( value )
    .FormatTime ( value), .T (value )

Adds a _filter_ condition using a logical expression. 
Method `.Variable` (or its short form `.V`) must be used to enclose the field of the table to be used to evaluate the expression. It's not needed to use the `BIND()` instruction.
Methods `.FormatString` (or `.F`),  `.FormatDate` (or `.D`) and `.FormatTime` (or `.T`) can be used to format the constants to be used in the expression.

*Parameters*
* _expression_ A logical expression using operators common to Clarion and SQL. For example, `AND`, `OR`, `NOT`, `( )` and simple math operators like `+ - * /`

*Example*
This legacy code:
 
    IF ORD:ShipZip = '33012' OR ORD:ShipZip = '33015' THEN CYCLE.

Can be changed to:

    tm.AddFilterExpression('NOT ('&tm.V(ORD:ShipZip)&' = '&tm.S(33012)&' OR '&tm.V(ORD:ShipZip)&' = '&tm.S(33015)&' )')

When executed against a TPS table or a queue, it will be passed to Clarion's `EVALUATE` as:

    NOT ( '33064' = '33012' OR '33064' = '33015' )
    
When executed against a SQL table, it will be appended to the `WHERE` clause as:

    AND NOT ( SHIPZIP = '33012' OR SHIPZIP = '33015' )

### SET
    .SET ( key )
    .SET ( key , key )
    .SET ( file )
    .SET ( queue )

Links all the conditions to the table to be processed, sets the order, and prepares to sequentially read the records.

*Parameters*
* _key_ The label of a key of the table to be processed. For backward compatibility witch Clarion's `SET` instruction, it can be passed twice.
* _file_ The label of the `FILE` declaration of the table to be processed. It will be read in physical record order.
* _queue_ The label of a `QUEUE` to be read as a table.

### NEXT, PREVIOUS
    .NEXT( table )
    .NEXT( queue )
    .PREVIOUS( table )
    .PREVIOUS( queue )
    
Reads the next or previous records of the table. If the record read doesn't match a _Filter_ condition, it's skipped. It can be used as a conditon in a `LOOP UNTIL` structure.

*Parameters*
* _table_ The lable of the `FILE` 
* _queue_ The label or a `QUEUE`

*Returns*
* `tm:Record:OK` (0) If the records matches all conditions.
* `tm:Record:OutOfRange` (1) If the records fails a _Range_ condition.
* `ERRORCODE()` If there is an error reported by Clarion's `NEXT` or `PREVIOUS` instruction.
