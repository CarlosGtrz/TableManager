# Table Manager
A class to read tables with less code while optimizing for SQL backends.

## Introduction
This is classic code to read two related tables with Clarion:

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

    tm.Init(ORD:Record)
    tm.AddRange(ORD:OrderDate,DATE(10,12,1996),DATE(10,28,1996))
    tm.AddFilter(ORD:ShipState,'FL')
    tm.SET(ORD:KeyOrderDate)
    LOOP UNTIL tm.NEXT(Orders)
      tm.Init(DTL:Record)
      tm.AddRange(DTL:CustOrderNumbers,ORD:CustOrderNumbers)
      tm.SET(DTL:KeyDetails)
      LOOP UNTIL tm.NEXT(Detail)
        !Some code
      .
    .  

When executed against a SQL backend, the first example generates this `WHERE` clause:
    
    WHERE (ORDERDATE >= ? AND (ORDERDATE > ? OR (CUSTNUMBER >= ? AND (CUSTNUMBER > ? OR (ORDERNUMBER >= ? )))))
    
It only filters records lower than the initial key value. The end of the range and the filters have to be evaluated on the client side. 

Using **Table Manager**, a SQL logical expression is created and sent to the backend:

    WHERE (ORDERDATE >= '19961012' AND ORDERDATE <= '19961028' AND SHIPSTATE = 'FL'  )
    
## Install
Copy `TableManager.clw` and `TableManager.inc` to the app folder or a folder in your `.red` file, like `Accessory\libsrc`.

## Use
Add to a global data embed (like _After Global INCLUDEs_) the line:

    INCLUDE('TableManager.inc'),ONCE
    
In your procedure or routine, declare an instance, and start modifying your code:

    tm TableManager
      CODE
      tm.Init(TBL:Record)                  !Old code:
      tm.AddRange(TBL:field,LOC:value)   ! TBL:field = LOC:Value
      tm.SET(TBL:fieldKey)               ! SET(TBL:fieldKey,TBL:fieldKey)      
      ...

## Methods

### Init
    .Init
    .Init( record )
    
Initializes the class conditions. If a record is passed, it also clears the records, and if the record's tables has been used before, it clears the table's ranges and filters.

*Parameters*
* _record_ The label of a table's record.

### AddRange, AddFilter
    .AddRange ( field , value )
    .AddRange ( field , firstvalue , lastvalue )
    .AddFilter ( field , value )
    .AddFilter ( field , firstvalue , lastvalue )
    .AddFilter ( expression )

Adds a condition to process the table referenced in the next `.SET` method call.

*Parameters*
* _field_ The label of a field in the table.
* _value_ A constant, variable or expression. Only records where _field_ is equal to _value_ will be processed.
* _firstvalue_, _lastvalue_ A constant, variable or expression. Only records where _field_ is between _firstvalue_ and _lastvalue_ will be processed.
* _expression_ A short form of the method `.AddFilterExpression`

A _Range_ condition will cause the `.NEXT` method to return `tm:Record:OutOfRange` when a record doesn't match the condition, causing a `LOOP UNTIL` to break.

A _Filter_ condition will cause the `.NEXT` method to skip records not matching the condition without breaking the loop.

When the table is SQL, a `WHERE` clause will be sent to the backend, using the _field_'s SQL name and properly formatted `value`s.

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
    .AddFilterExpression ( expression ), .AddFilter ( expression )
    .Variable ( field ), .V ( field )
    .FormatString ( value ), .F (value)
    .FormatDate ( value ), .D ( value )
    .FormatTime ( value), .T (value )

Adds a _filter_ condition using a logical expression. 

Method `.Variable` (or its short form `.V`) must be used to enclose the field of the table to be used to evaluate the expression. It's not needed to use the `BIND()` instruction.

Methods `.FormatString` (or `.F`),  `.FormatDate` (or `.D`) and `.FormatTime` (or `.T`) can be used to format the values to be used in the expression.

*Parameters*
* _expression_ A logical expression using operators common to Clarion and SQL, like `=`, `<>`, `<`, `>`, `<=`, `>=`, `AND`, `OR`, `NOT`, `( )`; and simple math operators like `+ - * /`

*Example*
This code:
 
    IF ORD:ShipZip = '33012' OR ORD:ShipZip = '33015' THEN CYCLE.

Can be changed to:

    tm.AddFilter('NOT ('&tm.V(ORD:ShipZip)&' = '&tm.S(33012)&' OR '&tm.V(ORD:ShipZip)&' = '&tm.S(33015)&' )')

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
    
Reads the next or previous records of the table. If a record doesn't match a _Filter_ condition, it's skipped. It can be used as a logical expression in a `LOOP UNTIL` structure.

*Parameters*
* _table_ The lable of the `FILE` 
* _queue_ The label or a `QUEUE`

*Returns*
* `tm:Record:OK` (0) If the record read matches all conditions.
* `tm:Record:OutOfRange` (1) If the record read fails a _Range_ condition.
* `ERRORCODE()` If there is an error posted by Clarion's `NEXT` or `PREVIOUS` instruction.
