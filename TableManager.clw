!Carlos Gutierrez   carlosg@sca.mx    https://github.com/CarlosGtrz
!
!MIT License
!
!Copyright (c) 2021 Carlos Gutierrez Fragosa
!
!Permission is hereby granted, free of charge, to any person obtaining a copy
!of this software and associated documentation files (the "Software"), to deal
!in the Software without restriction, including without limitation the rights
!to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
!copies of the Software, and to permit persons to whom the Software is
!furnished to do so, subject to the following conditions:
!
!The above copyright notice and this permission notice shall be included in all
!copies or substantial portions of the Software.
!
!THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
!IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
!FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
!AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
!LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
!OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
!SOFTWARE.
  MEMBER()
  MAP
  END
  INCLUDE('Equates.CLW'),ONCE
  INCLUDE('TABLEMANAGER.INC'),ONCE

TableManager.ClearConditions    PROCEDURE
  CODE
  SELF.ClearConditions(SELF.Conditions)

TableManager.AddRange   PROCEDURE(*? pField,? pFirstValue,<? pLastValue>)
  CODE
  IF OMITTED(pLastValue)
    SELF.AddCondition(tm:EqualToValueRange,pField,pFirstValue)
  ELSE
    SELF.AddCondition(tm:BetweenValuesRange,pField,pFirstValue,pLastValue)
  .  

TableManager.AddFilter  PROCEDURE(*? pField,? pFirstValue,<? pLastValue>)
  CODE
  IF OMITTED(pLastValue)
    SELF.AddCondition(tm:EqualToValueFilter,pField,pFirstValue)
  ELSE
    SELF.AddCondition(tm:BetweenValuesFilter,pField,pFirstValue,pLastValue)
  .
  
TableManager.AddFilter  PROCEDURE(STRING pExpression)  
  CODE
  SELF.AddFilterExpression(pExpression)
    
TableManager.AddFilterExpression    PROCEDURE(STRING pExpression)  
  CODE
  SELF.AddCondition(tm:ExpressionFilter,,pExpression)
  
TableManager.Variable   PROCEDURE(*? pField)!,STRING
TufoType                  LONG
TufoAddress               LONG
TufoSize                  LONG
  CODE
  SELF.GetTufoInfo(pField,TufoType,TufoAddress,TufoSize)  
  RETURN '|'&TufoType&'|'&TufoAddress&'|'&TufoSize&'|'
  
TableManager.V      PROCEDURE(*? pField)!,STRING
  CODE
  RETURN SELF.Variable(pField)

TableManager.FormatString PROCEDURE(? pField)!,STRING
  CODE
  RETURN SELF.FormatField(pField,tm:String)
  
TableManager.S      PROCEDURE(? pField)!,STRING
  CODE
  RETURN SELF.FormatString(pField)

TableManager.FormatDate   PROCEDURE(? pField)!,STRING
  CODE
  RETURN SELF.FormatField(pField,tm:Date)
  
TableManager.D      PROCEDURE(? pField)!,STRING
  CODE
  RETURN SELF.FormatDate(pField)

TableManager.FormatTime   PROCEDURE(? pField)!,STRING
  CODE
  RETURN SELF.FormatField(pField,tm:Time)
  
TableManager.T      PROCEDURE(? pField)!,STRING
  CODE
  RETURN SELF.FormatTime(pField)

TableManager.SET    PROCEDURE(KEY pKey)
fileref               &FILE
  CODE  
  
  fileRef &= pKey{PROP:File} 
  SELF.AddTable(fileref)
  
  IF SELF.Tables.IsSql
    SET(pKey)
    SELF.SetSqlWhereConditions
  ELSE
    SELF.SetQueue(SELF.Tables.Ranges)
    LOOP UNTIL SELF.NextQueue(SELF.Tables.Ranges)
      SELF.Tables.Ranges.FieldRef = SELF.Tables.Ranges.FirstValue
    .
    SET(pKey,pKey)
  .

TableManager.SET    PROCEDURE(KEY pKey1,KEY pKey2)
  CODE
  SELF.SET(pKey1)

TableManager.SET    PROCEDURE(FILE pFile)
  CODE
  SELF.AddTable(pFile)
  SET(pFile)  
  IF SELF.Tables.IsSql
    SELF.SetSqlWhereConditions
  .
    
TableManager.NEXT   PROCEDURE(FILE pFile)!,LONG,PROC
  CODE  
  RETURN SELF.Move(pFile,tm:Next)  

TableManager.PREVIOUS   PROCEDURE(FILE pFile)!,LONG,PROC
  CODE  
  RETURN SELF.Move(pFile,tm:Previous)
  
TableManager.SET    PROCEDURE(QUEUE pQueue)
  CODE
  SELF.AddTable(pQueue)
  SELF.SetQueue(pQueue)
  
TableManager.NEXT   PROCEDURE(QUEUE pQueue)!,LONG,PROC  
  CODE
  RETURN SELF.Move(pQueue,tm:Next)

TableManager.PREVIOUS   PROCEDURE(QUEUE pQueue)!,LONG,PROC  
  CODE
  RETURN SELF.Move(pQueue,tm:Previous)
  
TableManager.AddCondition   PROCEDURE(ConditionTypeType pConditionType,<*? pField>,? pFirstValue,<? pLastValue>)!,PRIVATE
  CODE
  CLEAR(SELF.Conditions)  
  SELF.Conditions.FieldRef &= pField
  SELF.GetTufoInfo(pField,SELF.Conditions.TufoType,SELF.Conditions.TufoAddress,SELF.Conditions.TufoSize)  
  SELF.Conditions.ConditionType = pConditionType
  SELF.Conditions.FirstValue = pFirstValue
  SELF.Conditions.LastValue = pLastValue
  ADD(SELF.Conditions)

TableManager.GetTufoInfo    PROCEDURE(*? pAny,*LONG pType,*LONG pAddress,*LONG pSize)
!REGION TUFO
!From https://github.com/MarkGoldberg/ClarionCommunity/blob/master/CW/Shared/Src/TUFO.INT
                                      OMIT('***',_C70_)
!--- see softvelocity.public.clarion6 "Variable Data Type" Sept,12,2006 (code posted by dedpahom) -----!
tmTUFO                                INTERFACE,TYPE
AssignLong                              PROCEDURE                           !+00h 
AssignReal                              PROCEDURE                           !+04h 
AssignUFO                               PROCEDURE                           !+08h 
DistinctsUFO                            PROCEDURE                           !+0Ch
DistinctsLong                           PROCEDURE                           !+10h
_Type                                   PROCEDURE(LONG _UfoAddr),LONG       !+14h 
ToMem                                   PROCEDURE                           !+18h
FromMem                                 PROCEDURE                           !+1Ch
OldFromMem                              PROCEDURE                           !+20h
Pop                                     PROCEDURE(LONG _UfoAddr)            !+24h
Push                                    PROCEDURE(LONG _UfoAddr)            !+28h
DPop                                    PROCEDURE(LONG _UfoAddr)            !+2Ch 
DPush                                   PROCEDURE(LONG _UfoAddr)            !+30h 
_Real                                   PROCEDURE(LONG _UfoAddr),REAL       !+34h 
_Long                                   PROCEDURE(LONG _UfoAddr),LONG       !+38h
_Free                                   PROCEDURE(LONG _UfoAddr)            !+3Ch
_Clear                                  PROCEDURE                           !+40h
_Address                                PROCEDURE(LONG _UfoAddr),LONG       !+44h
AClone                                  PROCEDURE(LONG _UfoAddr),LONG       !+48h
Select                                  PROCEDURE                           !+4Ch 
Slice                                   PROCEDURE                           !+50h 
Designate                               PROCEDURE                           !+54h
_Max                                    PROCEDURE(LONG _UfoAddr),LONG       !+58h
_Size                                   PROCEDURE(LONG _UfoAddr),LONG       !+5Ch
BaseType                                PROCEDURE(LONG _UfoAddr),LONG       !+60h
DistinctUpper                           PROCEDURE                           !+64h
Cleared                                 PROCEDURE(LONG _UfoAddr)            !+68h
IsNull                                  PROCEDURE(LONG _UfoAddr),LONG       !+6Ch
OEM2ANSI                                PROCEDURE(LONG _UfoAddr)            !+70h
ANSI2OEM                                PROCEDURE(LONG _UfoAddr)            !+74h
_Bind                                   PROCEDURE(LONG _UfoAddr)            !+78h
_Add                                    PROCEDURE                           !+7Ch
Divide                                  PROCEDURE                           !+80h
Hash                                    PROCEDURE(LONG _UfoAddr),LONG       !+84h
SetAddress                              PROCEDURE                           !+88h 
Match                                   PROCEDURE                           !+8Ch 
Identical                               PROCEDURE                           !+90h
Store                                   PROCEDURE                           !+94h
                                      END
                                      !END-OMIT('***',_C70_)
                                      COMPILE('***',_C70_)
!According to Randy Rogers (Skype PM, Dec 13, 2010)
tmTUFO                                INTERFACE,TYPE
_Type                                   PROCEDURE(LONG _UfoAddr),LONG       !+00h
ToMem                                   PROCEDURE                           !+04h
FromMem                                 PROCEDURE                           !+08h
OldFromMem                              PROCEDURE                           !+0Ch
Pop                                     PROCEDURE(LONG _UfoAddr)            !+10h get a value from string stack
Push                                    PROCEDURE(LONG _UfoAddr)            !+14h put a vaule to string stack
DPop                                    PROCEDURE(LONG _UfoAddr)            !+18h get a value from DECIMAL stack
DPush                                   PROCEDURE(LONG _UfoAddr)            !+1Ch put a vaule to DECIMAL stack
_Real                                   PROCEDURE(LONG _UfoAddr),REAL       !+20h get a value as REAL
_Long                                   PROCEDURE(LONG _UfoAddr),LONG       !+24h get a value as LONG
_Free                                   PROCEDURE(LONG _UfoAddr)            !+28h disposes memory and frees a reference (sets it to NULL)
_Clear                                  PROCEDURE                           !+2Ch clears a variable
_Address                                PROCEDURE(LONG _UfoAddr),LONG       !+30h returns an address of a variable
AssignLong                              PROCEDURE                           !+34h
AssignReal                              PROCEDURE                           !+38h
AssignUFO                               PROCEDURE                           !+3Ch
AClone                                  PROCEDURE(LONG _UfoAddr),LONG       !+40h
Select                                  PROCEDURE                           !+44h
Slice                                   PROCEDURE                           !+48h
Designate                               PROCEDURE                           !+4Ch returns group field as UFO object
_Max                                    PROCEDURE(LONG _UfoAddr),LONG       !+50h number of elements in first dimension of an array
_Size                                   PROCEDURE(LONG _UfoAddr),LONG       !+54h size of an object
BaseType                                PROCEDURE(LONG _UfoAddr),LONG       !+58h
DistinctUpper                           PROCEDURE                           !+5Ch
DistinctsUFO                            PROCEDURE                           !+60h
DistinctsLong                           PROCEDURE                           !+64h
Cleared                                 PROCEDURE(LONG _UfoAddr)            !+68h was an object disposed?
IsNull                                  PROCEDURE(LONG _UfoAddr),LONG       !+6Ch
OEM2ANSI                                PROCEDURE(LONG _UfoAddr)            !+70h
ANSI2OEM                                PROCEDURE(LONG _UfoAddr)            !+74h
_Bind                                   PROCEDURE(LONG _UfoAddr)            !+78h bind all fields of a group
_Add                                    PROCEDURE                           !+7Ch
Divide                                  PROCEDURE                           !+80h
Hash                                    PROCEDURE(LONG _UfoAddr),LONG       !+84h Calc CRC
SetAddress                              PROCEDURE                           !+88h sets the address of a variable
Match                                   PROCEDURE                           !+8Ch compares the type and the size of a field with a field of ClassDesc structure
Identical                               PROCEDURE                           !+90h
Store                                   PROCEDURE                           !+94h writes the value of an object into the memory address
                                      END
                                      !END-COMPILE('***',_C70_)
!ENDREGION
tufo                                  &tmTUFO
addr                                  LONG
  CODE
  addr = ADDRESS(pAny)
  IF NOT addr THEN RETURN.
  tufo &= addr+0
  pType = tufo._Type(addr)
  pAddress = tufo._Address(addr)
  pSize = tufo._Size(addr)
    
TableManager.AddTable   PROCEDURE(FILE pFile)!,PRIVATE
  CODE  
  CLEAR(SELF.Tables)
  SELF.Tables.TableAddress = INSTANCE(pFile,THREAD())    
  GET(SELF.Tables,SELF.Tables.TableAddress)
  IF ERRORCODE() THEN 
    SELF.Tables.FileRef &= pFile
    SELF.Tables.IsSql = CHOOSE(INLIST(UPPER(pFile{PROP:Driver}),'MSSQL','ODBC','SCALABLE','SQLANYWHERE','SQLITE')<>0)  
    SELF.Tables.Ranges &= NEW ConditionsType  
    SELF.Tables.Filters &= NEW ConditionsType  
    SELF.Tables.Groups &= NEW GroupsType
    SELF.AddGroupToFields(0,pFile{PROP:Fields})
    ADD(SELF.Tables)
  .  
  SELF.MoveConditionsToTable
  IF RECORDS(SELF.Conditions)
    GET(SELF.Conditions,1)
    STOP('Not all conditions match fields in the table, example value: '&CLIP(SELF.Conditions.FirstValue))
    SELF.ClearConditions
  .  
  
TableManager.MoveConditionsToTable  PROCEDURE!,PRIVATE
  CODE 
  
  SELF.ClearConditions(SELF.Tables.Ranges)
  SELF.ClearConditions(SELF.Tables.Filters)  
  SELF.SetQueue(SELF.Conditions)
  LOOP UNTIL SELF.NextQueue(SELF.Conditions)
        
    !Expresson filters can't be linked to fields yet
    IF SELF.Conditions.ConditionType = tm:ExpressionFilter
      CLEAR(SELF.Tables.Filters)
      SELF.Tables.Filters = SELF.Conditions
      ADD(SELF.Tables.Filters)
      SELF.Conditions.ConditionType = 0 !Flag to delete
      PUT(SELF.Conditions)
      CYCLE
    .    
    
    CLEAR(SELF.Fields)
    SELF.Fields.TableAddress = SELF.Tables.TableAddress
    SELF.Fields.TufoType = SELF.Conditions.TufoType
    SELF.Fields.TufoAddress = SELF.Conditions.TufoAddress
    SELF.Fields.TufoSize = SELF.Conditions.TufoSize
    GET(SELF.Fields,SELF.Fields.TableAddress,SELF.Fields.TufoType,SELF.Fields.TufoAddress,SELF.Fields.TufoSize)
    IF NOT ERRORCODE()
      SELF.Conditions.FieldType = SELF.Fields.FieldType
      SELF.Conditions.GroupId = SELF.Fields.GroupId
      SELF.Conditions.FieldName = SELF.Fields.FieldName
      SELF.Conditions.FieldSqlName = SELF.Fields.FieldSqlName
      CASE SELF.Conditions.ConditionType
        OF tm:EqualToValueRange OROF tm:BetweenValuesRange
          CLEAR(SELF.Tables.Ranges)
          SELF.Tables.Ranges.FieldRef &= SELF.Conditions.FieldRef
          SELF.Tables.Ranges = SELF.Conditions
          ADD(SELF.Tables.Ranges)
        OF tm:EqualToValueFilter OROF tm:BetweenValuesFilter 
          CLEAR(SELF.Tables.Filters)
          SELF.Tables.Filters.FieldRef &= SELF.Conditions.FieldRef
          SELF.Tables.Filters = SELF.Conditions
          ADD(SELF.Tables.Filters)
      .        
      SELF.Conditions.ConditionType = 0 !Flag to delete
      PUT(SELF.Conditions)
    .    
  .
  SELF.SetQueue(SELF.Conditions)
  LOOP UNTIL SELF.PreviousQueue(SELF.Conditions)
    IF SELF.Conditions.ConditionType = 0
      DELETE(SELF.Conditions)
    .
  .  

TableManager.AddGroupToFields   PROCEDURE(LONG pStart,LONG pTotal,<*GROUP pGroup>)!,PRIVATE
fld                               LONG
grpref                            &GROUP
pos                               LONG
grpref2                           &GROUP
grpflds                           LONG
  CODE
  
  IF OMITTED(pGroup)        
    grpref &= SELF.Tables.FileRef{PROP:Record}
  ELSE
    grpref &= pGroup
  .  
  LOOP fld = pStart+1 TO pStart+pTotal
    CLEAR(SELF.Fields)
    SELF.Fields.TableAddress = SELF.Tables.TableAddress
    SELF.Fields.FieldRef &= WHAT(grpref,fld-pStart)
    SELF.GetTufoInfo(SELF.Fields.FieldRef,SELF.Fields.TufoType,SELF.Fields.TufoAddress,SELF.Fields.TufoSize)
    SELF.Fields.FieldName = WHO(grpref,fld-pStart)
    pos = INSTRING('|',SELF.Fields.FieldName,1,1)
    IF pos
      SELF.Fields.FieldName = SUB(SELF.Fields.FieldName,1,pos-1)
    .
    SELF.Fields.FieldSqlName = SELF.Fields.FieldName
    pos = INSTRING(':',SELF.Fields.FieldSqlName,1,1)
    IF pos
      SELF.Fields.FieldSqlName = CLIP(SUB(SELF.Fields.FieldSqlName,pos+1,LEN(SELF.Fields.FieldSqlName)))
    .    
    IF ISGROUP(grpref,fld-pStart)
      SELF.Fields.FieldType = tm:Group        
      SELF.Fields.GroupId = fld
    ELSE
      CASE SELF.Fields.TufoType
        OF DataType:BYTE 
        OROF DataType:SHORT 
        OROF DataType:USHORT 
        OROF DataType:LONG       
        OROF DataType:ULONG 
        OROF DataType:DECIMAL 
        OROF DataType:PDECIMAL 
        OROF DataType:REAL 
        OROF DataType:SREAL
          SELF.Fields.FieldType = tm:Numeric        
        OF DataType:STRING 
        OROF DataType:CSTRING
        OROF DataType:PSTRING        
          SELF.Fields.FieldType = tm:String        
        OF DataType:DATE
          SELF.Fields.FieldType = tm:Date
        OF DataType:TIME
          SELF.Fields.FieldType = tm:Time
        ELSE
          SELF.Fields.FieldType = tm:Unknown
      .
      SELF.Fields.GroupId = pStart
    .    
    ADD(SELF.Fields)
    
    !Add member fields to Groups queue
    IF SELF.Fields.GroupId AND SELF.Fields.FieldType <> tm:Group
      CLEAR(SELF.Tables.Groups)
      SELF.Tables.Groups.GroupId = SELF.Fields.GroupId
      GET(SELF.Tables.Groups,SELF.Tables.Groups.GroupId)
      IF ERRORCODE()
        SELF.Tables.Groups.Fields &= NEW FieldsType
        ADD(SELF.Tables.Groups)      
      .
      CLEAR(SELF.Tables.Groups.Fields)      
      SELF.Tables.Groups.Fields.FieldRef &= SELF.Fields.FieldRef
      SELF.Tables.Groups.Fields = SELF.Fields
      ADD(SELF.Tables.Groups.Fields)
    .    
    
    !Recursively add fields in groups
    IF SELF.Fields.FieldType = tm:Group
      grpref2 &= GETGROUP(grpref,fld-pStart)
      grpflds = SELF.FieldsInGroup(grpref2)
      SELF.AddGroupToFields(fld,grpflds,grpref2)
      fld += grpflds
    .
  .    
  
TableManager.FieldsInGroup  PROCEDURE(*GROUP pGroup)!,LONG,PRIVATE
idx                           LONG
fld                           ANY
grpref                        &GROUP
count                         LONG
  CODE
  LOOP
    idx += 1
    fld &= WHAT(pGroup,idx)
    IF fld &= NULL THEN BREAK.
    IF ISGROUP(pGroup,idx)
      grpref &= GETGROUP(pGroup,idx)
      count += SELF.FieldsInGroup(grpref)
    ELSE
      count += 1
    .
  .
  RETURN count
    
TableManager.SetSqlWhereConditions  PROCEDURE!,PRIVATE
where                                 ANY
  CODE
  where = ''
  SELF.SetQueue(SELF.Tables.Ranges)
  LOOP UNTIL SELF.NextQueue(SELF.Tables.Ranges)
    where = where & CHOOSE(where <> '',' AND ','') & |
      SELF.SqlCondition(SELF.Tables.Ranges)    
  .
  SELF.SetQueue(SELF.Tables.Filters)
  LOOP UNTIL SELF.NextQueue(SELF.Tables.Filters)
    where = where & CHOOSE(where <> '',' AND ','') & |
      SELF.SqlCondition(SELF.Tables.Filters)    
  .
  SELF.Tables.FileRef{PROP:Where} = where   
  
TableManager.SqlCondition   PROCEDURE(ConditionsType pCondition)!,STRING,PRIVATE  
where                         ANY
  CODE
  
  IF pCondition.FieldType = tm:Group
    
    IF pCondition.ConditionType =  tm:ExpressionFilter
      STOP('Expression filters are not allowed with group fields in SQL tables')
      RETURN ''
    .
    CLEAR(SELF.Tables.Groups)
    SELF.Tables.Groups.GroupId = pCondition.GroupId
    GET(SELF.Tables.Groups,SELF.Tables.Groups.GroupId)
    IF NOT ERRORCODE()
      where = ''
      SELF.SetQueue(SELF.Tables.Groups.Fields)          
      LOOP UNTIL SELF.NextQueue(SELF.Tables.Groups.Fields)
        CASE pCondition.ConditionType
          OF tm:EqualToValueRange OROF tm:EqualToValueFilter
            pCondition.FieldRef = pCondition.FirstValue
            where = where & CHOOSE(where <> '',' AND ','') & |
              CLIP(SELF.Tables.Groups.Fields.FieldSqlName)&' = '&SELF.FormatField(SELF.Tables.Groups.Fields.FieldRef,SELF.Tables.Groups.Fields.FieldType)
          OF tm:BetweenValuesRange OROF tm:BetweenValuesFilter
            pCondition.FieldRef = pCondition.FirstValue
            where = where & CHOOSE(where <> '',' AND ','') & |
              CLIP(SELF.Tables.Groups.Fields.FieldSqlName)&' >= '&SELF.FormatField(SELF.Tables.Groups.Fields.FieldRef,SELF.Tables.Groups.Fields.FieldType)
            pCondition.FieldRef = pCondition.LastValue
            where = where & ' AND ' & |
              CLIP(SELF.Tables.Groups.Fields.FieldSqlName)&' <= '&SELF.FormatField(SELF.Tables.Groups.Fields.FieldRef,SELF.Tables.Groups.Fields.FieldType)
        .    
      .      
      RETURN where
    .    
    
  ELSE
    
    CASE pCondition.ConditionType
      OF tm:EqualToValueRange OROF tm:EqualToValueFilter
        RETURN CLIP(pCondition.FieldSqlName)&' = '&SELF.FormatField(pCondition.FirstValue,pCondition.FieldType)
      OF tm:BetweenValuesRange OROF tm:BetweenValuesFilter
        RETURN CLIP(pCondition.FieldSqlName)&' >= '&SELF.FormatField(pCondition.FirstValue,pCondition.FieldType)&' AND '&CLIP(pCondition.FieldSqlName)&' <= '&SELF.FormatField(pCondition.LastValue,pCondition.FieldType)
      OF tm:ExpressionFilter
        RETURN CLIP(SELF.ReplaceVariables(pCondition.FirstValue,tm:ReplaceWithSqlNames))        
    .  
  .
  
TableManager.FormatField    PROCEDURE(? pFieldValue,FieldTypeType pFieldType)!,STRING,PRIVATE
  CODE
  CASE pFieldType
    OF tm:Numeric
      RETURN CLIP(pFieldValue)
    OF tm:String
      RETURN ''''&CLIP(pFieldValue)&''''      
    OF tm:Date
      RETURN ''''&FORMAT(pFieldValue,@D12)&''''      
    OF tm:Time
      RETURN ''''&FORMAT(pFieldValue,@T04-)&''''
  .
  
TableManager.Move   PROCEDURE(FILE pFile,DirectionTypeType pDirection)!,LONG,PRIVATE
addr                   LONG
  CODE
  
  addr = INSTANCE(pFile,THREAD())
  IF SELF.Tables.TableAddress <> addr
    CLEAR(SELF.Tables)
    SELF.Tables.TableAddress = addr
    GET(SELF.Tables,SELF.Tables.TableAddress)
    IF ERRORCODE() THEN RETURN tm:Record:OutOfRange.
  .
  
  IF SELF.Tables.IsSql
    CASE pDirection
      OF tm:Next
        NEXT(pFile)
      OF tm:Previous        
        PREVIOUS(pFile)
    .
    RETURN ERRORCODE()
  .
  
  LOOP
    CASE pDirection
      OF tm:Next
        NEXT(pFile)
      OF tm:Previous        
        PREVIOUS(pFile)
    .
    IF ERRORCODE() THEN RETURN ERRORCODE().
    CASE SELF.EvaluateConditions()
      OF tm:Record:OK
        RETURN tm:Record:OK
      OF tm:Record:Filtered
        CYCLE
      OF tm:Record:OutOfRange
        RETURN tm:Record:OutOfRange
    .    
  .
      
TableManager.EvaluateConditions PROCEDURE!,LONG,PRIVATE
  CODE  
      
  SELF.SetQueue(SELF.Tables.Ranges)
  LOOP UNTIL SELF.NextQueue(SELF.Tables.Ranges)
    CASE SELF.Tables.Ranges.ConditionType
      OF tm:EqualToValueRange 
        IF NOT (SELF.Tables.Ranges.FieldRef = SELF.Tables.Ranges.FirstValue) THEN RETURN tm:Record:OutOfRange.
      OF tm:BetweenValuesRange 
        IF NOT (SELF.Tables.Ranges.FieldRef >= SELF.Tables.Ranges.FirstValue AND |
          SELF.Tables.Ranges.FieldRef <= SELF.Tables.Ranges.LastValue) THEN RETURN tm:Record:OutOfRange.
    .
  .
  
  SELF.SetQueue(SELF.Tables.Filters)
  LOOP UNTIL SELF.NextQueue(SELF.Tables.Filters)
    CASE SELF.Tables.Filters.ConditionType
      OF tm:EqualToValueFilter
        IF NOT (SELF.Tables.Filters.FieldRef = SELF.Tables.Filters.FirstValue) THEN RETURN tm:Record:Filtered.
      OF tm:BetweenValuesFilter
        IF NOT (SELF.Tables.Filters.FieldRef >= SELF.Tables.Filters.FirstValue AND |
          SELF.Tables.Filters.FieldRef <= SELF.Tables.Filters.LastValue) THEN RETURN tm:Record:Filtered.
      OF tm:ExpressionFilter
        IF NOT (SELF.EvaluateExpression(SELF.Tables.Filters.FirstValue)) THEN RETURN tm:Record:Filtered.
    .
  .
  
  RETURN tm:Record:OK
  
TableManager.EvaluateExpression PROCEDURE(STRING pExpression)!,LONG,PRIVATE
res LONG
  CODE
  res = EVALUATE(SELF.ReplaceVariables(pExpression,tm:ReplaceWithValues))
  IF INRANGE(ERRORCODE(),1010,1015)
    STOP('Error evaluating expression: '&ERRORCODE()&' '&ERROR()&'<13,10>'& |
      pExpression&'<13,10>'& |
      SELF.ReplaceVariables(pExpression,tm:ReplaceWithValues) |
      )
  .
  RETURN res
  
TableManager.ReplaceVariables   PROCEDURE(STRING pExpression,ReplaceTypeType pReplaceType)!,STRING,PRIVATE
str                               ANY
strvar                            ANY
pos                               LONG
varstart                          LONG
varend                            LONG
TufoType                          LONG
TufoAddress                       LONG
TufoSize                          LONG
  CODE

  str = pExpression
  LOOP
    
    pos = STRPOS(str,'\|[0-9]+\|[0-9]+\|[0-9]+\|')
    IF NOT pos THEN BREAK.
    
    strvar = str

    varstart = pos
    varend = varstart

    strvar = CLIP(SUB(str,pos+1,LEN(str)))
    
    pos = INSTRING('|',strvar)
    TufoType = SUB(strvar,1,pos-1)    
    varend += pos

    strvar = CLIP(SUB(strvar,pos+1,LEN(strvar)))
    pos = INSTRING('|',strvar)
    TufoAddress = SUB(strvar,1,pos-1)
    varend += pos

    strvar = CLIP(SUB(strvar,pos+1,LEN(strvar)))
    pos = INSTRING('|',strvar)
    TufoSize = SUB(strvar,1,pos-1)
    varend += pos    
    
    CLEAR(SELF.Fields)
    SELF.Fields.TufoType = TufoType
    SELF.Fields.TufoAddress = TufoAddress
    SELF.Fields.TufoSize = TufoSize
    
    GET(SELF.Fields,SELF.Fields.TufoAddress,SELF.Fields.TufoType,SELF.Fields.TufoSize)
    IF ERRORCODE()
      STOP('Not all variables in expression can be linked to a structure. Expression: '&CLIP(pExpression)&'<13,10>|'&TufoType&'|'&TufoAddress&'|'&TufoSize&'|')
      RETURN pExpression
    .
    
    str = SUB(str,1,varstart-1) & |
      CHOOSE(pReplaceType = tm:ReplaceWithValues,SELF.FormatField(SELF.Fields.FieldRef,SELF.Fields.FieldType),'') & |
      CHOOSE(pReplaceType = tm:ReplaceWithNames,CLIP(SELF.Fields.FieldName),'') & |
      CHOOSE(pReplaceType = tm:ReplaceWithSqlNames,CLIP(SELF.Fields.FieldSqlName),'') & |
      CLIP(SUB(str,varend+1,LEN(str)))
    
  .
  RETURN str

TableManager.AddTable   PROCEDURE(QUEUE pQueue)!,PRIVATE
  CODE  
  CLEAR(SELF.Tables)
  SELF.Tables.TableAddress = INSTANCE(pQueue,THREAD())    
  GET(SELF.Tables,SELF.Tables.TableAddress)
  IF ERRORCODE() THEN 
    SELF.Tables.Ranges &= NEW ConditionsType  
    SELF.Tables.Filters &= NEW ConditionsType  
    SELF.Tables.Groups &= NEW GroupsType
    SELF.AddGroupToFields(0,SELF.FieldsInGroup(pQueue),pQueue)
    ADD(SELF.Tables)
  .  
  SELF.MoveConditionsToTable
  IF RECORDS(SELF.Conditions)
    GET(SELF.Conditions,1)
    STOP('Not all conditions match fields in the table, example value: '&CLIP(SELF.Conditions.FirstValue))
    SELF.ClearConditions
  .
  
TableManager.Move   PROCEDURE(QUEUE pQueue,DirectionTypeType pDirection)!,LONG,PRIVATE
addr                   LONG
  CODE
  
  addr = INSTANCE(pQueue,THREAD())
  IF SELF.Tables.TableAddress <> addr
    CLEAR(SELF.Tables)
    SELF.Tables.TableAddress = addr
    GET(SELF.Tables,SELF.Tables.TableAddress)
    IF ERRORCODE() THEN RETURN tm:Record:OutOfRange.
  .
    
  LOOP
    CASE pDirection
      OF tm:Next
        SELF.NextQueue(pQueue)
      OF tm:Previous 
        SELF.PreviousQueue(pQueue)
    .
    IF ERRORCODE() THEN RETURN ERRORCODE().    
    CASE SELF.EvaluateConditions()
      OF tm:Record:OK
        RETURN tm:Record:OK
      OF tm:Record:OutOfRange OROF tm:Record:Filtered
        CYCLE
    .    
  .  

TableManager.SetQueue   PROCEDURE(QUEUE pQueue)!,PRIVATE
  CODE
  GET(pQueue,0)  
  
TableManager.NextQueue  PROCEDURE(QUEUE pQueue)!,LONG,PROC,PRIVATE  
  CODE
  GET(pQueue,POINTER(pQueue)+1)
  RETURN ERRORCODE()

TableManager.PreviousQueue  PROCEDURE(QUEUE pQueue)!,LONG,PROC,PRIVATE
ptr                       LONG
  CODE
  ptr = POINTER(pQueue)
  IF ptr 
    GET(pQueue,ptr-1)
  ELSE
    GET(pQueue,RECORDS(pQueue))
  .
  RETURN ERRORCODE()
  
TableManager.ClearConditions    PROCEDURE(ConditionsType pConditions)!,PRIVATE
  CODE
  IF NOT pConditions &= NULL
    SELF.SetQueue(pConditions)
    LOOP UNTIL SELF.PreviousQueue(pConditions)
      CLEAR(pConditions)
      pConditions.FieldRef &= NULL
      DELETE(pConditions)
    .
  .  

TableManager.Construct  PROCEDURE
  CODE  
  SELF.Conditions &= NEW ConditionsType
  SELF.Tables &= NEW TablesType
  SELF.Fields &= NEW FieldsType
  
TableManager.Destruct   PROCEDURE
  CODE
  SELF.ClearConditions(SELF.Conditions)
  DISPOSE(SELF.Conditions) 
  IF NOT SELF.Tables &= NULL
    SELF.SetQueue(SELF.Tables)    
    LOOP UNTIL SELF.PreviousQueue(SELF.Tables) 
      CLEAR(SELF.Tables)
      SELF.Tables.FileRef &= NULL
      SELF.ClearConditions(SELF.Tables.Ranges)
      DISPOSE(SELF.Tables.Ranges)
      SELF.ClearConditions(SELF.Tables.Filters)      
      DISPOSE(SELF.Tables.Filters)
      IF NOT SELF.Tables.Groups &= NULL
        SELF.SetQueue(SELF.Tables.Groups)
        LOOP UNTIL SELF.PreviousQueue(SELF.Tables.Groups)          
          IF NOT SELF.Tables.Groups.Fields &= NULL
            LOOP UNTIL SELF.PreviousQueue(SELF.Tables.Groups.Fields)
              CLEAR(SELF.Tables.Groups.Fields) !gpf without this
              SELF.Tables.Groups.Fields.FieldRef &= NULL 
              DELETE(SELF.Tables.Groups.Fields)
            .
            DISPOSE(SELF.Tables.Groups.Fields)            
          .
          DELETE(SELF.Tables.Groups)
        .        
        DISPOSE(SELF.Tables.Groups)
      .
      DELETE(SELF.Tables)
    .
    DISPOSE(SELF.Tables)
  .
  IF NOT SELF.Fields &= NULL  
    SELF.SetQueue(SELF.Fields)
    LOOP UNTIL SELF.PreviousQueue(SELF.Fields)
      CLEAR(SELF.Fields)
      SELF.Fields.FieldRef &= NULL
      DELETE(SELF.Fields)
    .  
    DISPOSE(SELF.Fields)
  .
  
