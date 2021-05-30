!
OMIT('_EndOfInclude_',_TableManager_)
_TableManager_ EQUATE(1)
!!! <summary>
!!! Generated class template - SourceClass
!!! </summary>
 
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
Group                 EQUATE
Unknown               EQUATE(99)
                    END

ConditionTypeType   EQUATE(LONG)
ConditionTypes      ITEMIZE(1),PRE(tm)
EqualToValueRange     EQUATE
BetweenValuesRange    EQUATE
EqualToValueFilter    EQUATE
BetweenValuesFilter   EQUATE
ExpressionFilter       EQUATE
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
                    END

GroupsType          QUEUE,TYPE
GroupId               LONG
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

TableManager        CLASS,MODULE('TableManager'),LINK('TableManager'),TYPE

ClearConditions       PROCEDURE()

AddRange              PROCEDURE(*? pField,? pFirstValue,<? pLastValue>)
AddFilter             PROCEDURE(*? pField,? pFirstValue,<? pLastValue>)

AddFilterExpression   PROCEDURE(STRING pExpression)
Variable              PROCEDURE(*? pField),STRING
V                     PROCEDURE(*? pField),STRING
FormatString                PROCEDURE(? pField),STRING
S                     PROCEDURE(? pField),STRING
FormatDate                  PROCEDURE(? pField),STRING
D                     PROCEDURE(? pField),STRING
FormatTime                  PROCEDURE(? pField),STRING
T                     PROCEDURE(? pField),STRING

SET                   PROCEDURE(KEY pKey)
SET                   PROCEDURE(KEY pKey1,KEY pKey2)
SET                   PROCEDURE(FILE pFile)
NEXT                  PROCEDURE(FILE pFile),LONG,PROC
PREVIOUS              PROCEDURE(FILE pFile),LONG,PROC

SET                   PROCEDURE(QUEUE pQueue)
NEXT                  PROCEDURE(QUEUE pQueue),LONG,PROC
PREVIOUS              PROCEDURE(QUEUE pQueue),LONG,PROC

Conditions            &ConditionsType,PRIVATE
Tables                &TablesType,PRIVATE
Fields                &FieldsType,PRIVATE

AddCondition          PROCEDURE(ConditionTypeType pConditionType,<*? pField>,? pFirstValue,<? pLastValue>),PRIVATE
GetTufoInfo           PROCEDURE(*? pAny,*LONG pType,*LONG pAddress,*LONG pSize),PRIVATE

AddTable              PROCEDURE(FILE pFile),PRIVATE
MoveConditionsToTable PROCEDURE,PRIVATE
AddGroupToFields      PROCEDURE(LONG pStart,LONG pTotal,<*GROUP pGroup>),PRIVATE
FieldsInGroup         PROCEDURE(*GROUP pGroup),LONG,PRIVATE

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

ClearConditions       PROCEDURE(ConditionsType pConditions),PRIVATE
Construct             PROCEDURE
Destruct              PROCEDURE

                    END
_EndOfInclude_
