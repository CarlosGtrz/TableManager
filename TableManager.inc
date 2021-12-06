!!! <summary>
!!! Generated class template - SourceClass
!!! </summary>
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

ReturnValues        ITEMIZE,PRE(tm)
Record:OK             EQUATE(0)
Record:OutOfRange     EQUATE(1)
Record:Filtered       EQUATE(2)
                    END

FieldTypeType       EQUATE(LONG)
FieldTypes          ITEMIZE(1),PRE(tm)
Numeric               EQUATE
String                EQUATE
Date                  EQUATE
Time                  EQUATE
DateTime              EQUATE
Group                 EQUATE
Unknown               EQUATE(99)
                    END

ConditionTypeType   EQUATE(LONG)
ConditionTypes      ITEMIZE(1),PRE(tm)
EqualToValueRange     EQUATE
BetweenValuesRange    EQUATE
EqualToValueFilter    EQUATE
BetweenValuesFilter   EQUATE
ExpressionFilter      EQUATE
                    END

DirectionTypeType   EQUATE(LONG)
DirectionTypes      ITEMIZE(1),PRE(tm)
Next                  EQUATE
Previous              EQUATE
                    END

ReplaceTypeType     EQUATE(LONG)
ReplaceTypes        ITEMIZE(1),PRE(tm)
ReplaceWithValues     EQUATE
ReplaceWithNames      EQUATE
ReplaceWithSqlNames   EQUATE
                    END

ConditionsType      QUEUE,TYPE
TufoType              LONG
TufoAddress           LONG
TufoSize              LONG
FieldRef              ANY
FieldType             FieldTypeType
GroupId               LONG
FieldName             ANY
FieldSqlName          ANY
ConditionType         ConditionTypeType
FirstValue            ANY
LastValue             ANY
                    END

FieldsType          QUEUE,TYPE
TableAddress          LONG
TufoType              LONG
TufoAddress           LONG
TufoSize              LONG
FieldRef              ANY
FieldType             FieldTypeType
GroupId               LONG
FieldName             ANY
FieldSqlName          ANY
IsPartOfDateTime      LONG
                    END

GroupsType          QUEUE,TYPE
GroupId               LONG
IsDateTime            LONG
Fields                &FieldsType
                    END

TablesType          QUEUE,TYPE
TableAddress          LONG
FileRef               &FILE
IsSql                 LONG
Ranges                &ConditionsType
Filters               &ConditionsType
Groups                &GroupsType
                    END

DateTimeGroupType   GROUP,TYPE
DatePart              DATE
TimePart              TIME
                    END

TableManager        CLASS,MODULE('TableManager'),LINK('TableManager'),TYPE

Init                  PROCEDURE
Init                  PROCEDURE(*GROUP pRecord,SIGNED pN = 0)

AddRange              PROCEDURE(*? pField,? pFirstValue,<? pLastValue>)
AddFilter             PROCEDURE(*? pField,? pFirstValue,<? pLastValue>)
AddFilter             PROCEDURE(STRING pExpression)

AddFilterExpression   PROCEDURE(STRING pExpression)
Variable              PROCEDURE(*? pField),STRING
V                     PROCEDURE(*? pField),STRING
FormatString          PROCEDURE(? pField),STRING
S                     PROCEDURE(? pField),STRING
FormatDate            PROCEDURE(? pField),STRING
D                     PROCEDURE(? pField),STRING
FormatTime            PROCEDURE(? pField),STRING
T                     PROCEDURE(? pField),STRING
FormatDateTime        PROCEDURE(? pDate, ? pTime),STRING
DT                    PROCEDURE(? pDate, ? pTime),STRING
FormatDateTime        PROCEDURE(*DateTimeGroupType pDateTimeGroup),STRING
DT                    PROCEDURE(*DateTimeGroupType pDateTimeGroup),STRING
DateTimeGroup         PROCEDURE(? pDate, ? pTime),STRING!,DateTimeGroupType

SET                   PROCEDURE(KEY pKey1)
SET                   PROCEDURE(KEY pKey1,KEY pKey2)
SET                   PROCEDURE(FILE pFile)
NEXT                  PROCEDURE(FILE pFile),LONG,PROC
PREVIOUS              PROCEDURE(FILE pFile),LONG,PROC
GET                   PROCEDURE(KEY pKey1,? pKeyVal1,<? pKeyVal2>,<? pKeyVal3>,<? pKeyVal4>,<? pKeyVal5>,<? pKeyVal6>,<? pKeyVal7>,<? pKeyVal8>,<? pKeyVal9>,<? pKeyVal10>),BOOL,PROC
GET                   PROCEDURE(KEY pKey1,*GROUP pGroup),BOOL,PROC

SET                   PROCEDURE(QUEUE pQueue)
NEXT                  PROCEDURE(QUEUE pQueue),LONG,PROC
PREVIOUS              PROCEDURE(QUEUE pQueue),LONG,PROC
GET                   PROCEDURE(QUEUE pQueue,*? pKey1,? pKeyVal1),BOOL,PROC
GET                   PROCEDURE(QUEUE pQueue,*? pKey1,*? pKey2,? pKeyVal1,? pKeyVal2),BOOL,PROC
GET                   PROCEDURE(QUEUE pQueue,*? pKey1,*? pKey2,*? pKey3,? pKeyVal1,? pKeyVal2,? pKeyVal3),BOOL,PROC
GET                   PROCEDURE(QUEUE pQueue,*? pKey1,*? pKey2,*? pKey3,*? pKey4,? pKeyVal1,? pKeyVal2,? pKeyVal3,? pKeyVal4),BOOL,PROC
GET                   PROCEDURE(QUEUE pQueue,*? pKey1,*? pKey2,*? pKey3,*? pKey4,*? pKey5,? pKeyVal1,? pKeyVal2,? pKeyVal3,? pKeyVal4,? pKeyVal5),BOOL,PROC
GET                   PROCEDURE(QUEUE pQueue,*? pKey1,*? pKey2,*? pKey3,*? pKey4,*? pKey5,*? pKey6,? pKeyVal1,? pKeyVal2,? pKeyVal3,? pKeyVal4,? pKeyVal5,? pKeyVal6),BOOL,PROC
GET                   PROCEDURE(QUEUE pQueue,*? pKey1,*? pKey2,*? pKey3,*? pKey4,*? pKey5,*? pKey6,*? pKey7,? pKeyVal1,? pKeyVal2,? pKeyVal3,? pKeyVal4,? pKeyVal5,? pKeyVal6,? pKeyVal7),BOOL,PROC
GET                   PROCEDURE(QUEUE pQueue,*? pKey1,*? pKey2,*? pKey3,*? pKey4,*? pKey5,*? pKey6,*? pKey7,*? pKey8,? pKeyVal1,? pKeyVal2,? pKeyVal3,? pKeyVal4,? pKeyVal5,? pKeyVal6,? pKeyVal7,? pKeyVal8),BOOL,PROC

SetGETClearsBuffer    PROCEDURE(BOOL pValue)

!Private methods
AddCondition          PROCEDURE(ConditionTypeType pConditionType,<*? pField>,? pFirstValue,<? pLastValue>),PRIVATE
GetTufoInfo           PROCEDURE(*? pAny,*LONG pType,*LONG pAddress,*LONG pSize),PRIVATE

AddTable              PROCEDURE(FILE pFile),PRIVATE
MoveConditionsToTable PROCEDURE,PRIVATE
AddGroupToFields      PROCEDURE(LONG pStart,LONG pTotal,<*GROUP pGroup>),PRIVATE
FieldsInGroup         PROCEDURE(*GROUP pGroup),LONG,PRIVATE
MarkDateTimeGroups    PROCEDURE,PRIVATE

SetSqlWhereConditions PROCEDURE,PRIVATE
SqlCondition          PROCEDURE(ConditionsType pCondition),STRING,PRIVATE  
FormatField           PROCEDURE(? pFieldValue,FieldTypeType),STRING,PRIVATE

Move                  PROCEDURE(FILE pFile,DirectionTypeType pDirection),LONG,PRIVATE
EvaluateConditions    PROCEDURE,LONG,PRIVATE
EvaluateExpression    PROCEDURE(STRING pExpression),LONG,PRIVATE
ReplaceVariables      PROCEDURE(STRING pExpression,ReplaceTypeType pReplaceType),STRING,PRIVATE

AddTable              PROCEDURE(QUEUE pQueue),PRIVATE
Move                  PROCEDURE(QUEUE pQueue,DirectionTypeType pDirection),LONG,PRIVATE
SetQueue              PROCEDURE(QUEUE pQueue),PRIVATE
NextQueue             PROCEDURE(QUEUE pQueue),LONG,PROC,PRIVATE
PreviousQueue         PROCEDURE(QUEUE pQueue),LONG,PROC,PRIVATE
GetQueueName          PROCEDURE(QUEUE pQueue,STRING pName),BOOL,PROC,PRIVATE

ClearConditions       PROCEDURE(ConditionsType pConditions),PRIVATE
Construct             PROCEDURE
Destruct              PROCEDURE

Conditions            &ConditionsType,PRIVATE
Tables                &TablesType,PRIVATE
Fields                &FieldsType,PRIVATE

GETClearsBuffer       BOOL,PRIVATE

                    END
