   PROGRAM



   INCLUDE('ABERROR.INC'),ONCE
   INCLUDE('ABFILE.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ERRORS.CLW'),ONCE
   INCLUDE('KEYCODES.CLW'),ONCE
   INCLUDE('ABFUZZY.INC'),ONCE
INCLUDE('TableManager.inc'),ONCE

   MAP
     MODULE('TESTAPP_BC.CLW')
DctInit     PROCEDURE                                      ! Initializes the dictionary definition module
DctKill     PROCEDURE                                      ! Kills the dictionary definition module
     END
!--- Application Global and Exported Procedure Definitions --------------------------------------------
     MODULE('TESTSTABLEMANAGER.CLW')
TestsTableManager      PROCEDURE   !
     END
   END

SilentRunning        BYTE(0)                               ! Set true when application is running in 'silent mode'

!region File Declaration
Products             FILE,DRIVER('TOPSPEED'),PRE(PRO),CREATE,BINDABLE,THREAD ! Product's Information
KeyProductNumber         KEY(PRO:ProductNumber),NOCASE,OPT,PRIMARY !                     
KeyProductSKU            KEY(PRO:ProductSKU),NOCASE,OPT    !                     
KeyDescription           KEY(PRO:Description),DUP,NOCASE,OPT !                     
Record                   RECORD,PRE()
ProductNumber               LONG                           ! Product's Identification Number
ProductSKU                  STRING(10)                     ! User defined Product Number
Description                 STRING(35)                     ! Product's Description
Price                       DECIMAL(7,2)                   ! Product's Price     
QuantityInStock             DECIMAL(7,2)                   ! Quantity of product in stock
ReorderQuantity             DECIMAL(7,2)                   ! Product's quantity for re-order
Cost                        DECIMAL(7,2)                   ! Product's cost      
PictureFile                 STRING(64)                     ! Path of graphic file
                         END
                     END                       

Detail               FILE,DRIVER('TOPSPEED'),PRE(DTL),CREATE,BINDABLE,THREAD ! Product-Order detail
KeyDetails               KEY(DTL:CustNumber,DTL:OrderNumber,DTL:LineNumber),NOCASE,OPT,PRIMARY !                     
Record                   RECORD,PRE()
CustOrderNumbers            GROUP                          !                     
CustNumber                    LONG                         ! Customer's Identification Number
OrderNumber                   LONG                         ! Order Identification Number
                            END                            !                     
LineNumber                  SHORT                          ! Line number         
ProductNumber               LONG                           ! Product Identification Number
QuantityOrdered             DECIMAL(7,2)                   ! Quantity of product ordered
BackOrdered                 BYTE                           ! Product is on back order
Price                       DECIMAL(7,2)                   ! Product's price     
TaxRate                     DECIMAL(6,4)                   ! Consumer's Tax rate 
TaxPaid                     DECIMAL(7,2)                   ! Calculated tax on product
DiscountRate                DECIMAL(6,4)                   ! Special discount rate on product
Discount                    DECIMAL(7,2)                   ! Calculated discount on product
Savings                     DECIMAL(7,2)                   ! Amount saved due to discount
TotalCost                   DECIMAL(10,2)                  ! Extended Total for product
                         END
                     END                       

Orders               FILE,DRIVER('TOPSPEED'),NAME('Orders.tps'),PRE(ORD),CREATE,BINDABLE,THREAD ! Customer's Orders   
KeyCustOrderNumber       KEY(ORD:CustNumber,ORD:OrderNumber),DUP,NOCASE,OPT !                     
InvoiceNumberKey         KEY(ORD:InvoiceNumber),NOCASE,OPT !                     
KeyOrderDate             KEY(ORD:OrderDate,ORD:CustNumber,ORD:OrderNumber),NOCASE !                     
Record                   RECORD,PRE()
CustOrderNumbers            GROUP                          !                     
CustNumber                    LONG                         ! Customer's Identification Number
OrderNumber                   LONG                         ! Order Identification Number
                            END                            !                     
InvoiceNumber               LONG                           ! Invoice number for each order
OrderDate                   DATE                           ! Date of Order       
SameName                    BYTE                           ! ShipTo name same as Customer's
ShipToName                  STRING(45)                     ! Customer the order is shipped to
SameAdd                     BYTE                           ! Ship to address same as customer's
ShipAddress1                STRING(35)                     ! 1st Line of ship address
ShipAddress2                STRING(35)                     ! 2nd line of ship address
ShipCity                    STRING(25)                     ! City of Ship address
ShipState                   STRING(2)                      ! State to ship to    
ShipZip                     STRING(5)                      ! ZipCode of ship city
OrderShipped                BYTE                           ! Checked if order is shipped
OrderNote                   STRING(80)                     ! Additional Information about order
                         END
                     END                       

Customers            FILE,DRIVER('TOPSPEED'),PRE(CUS),CREATE,BINDABLE,THREAD ! Customer's Information
KeyCustNumber            KEY(CUS:CustNumber),NOCASE,OPT    !                     
KeyFullName              KEY(CUS:LastName,CUS:FirstName,CUS:MI),DUP,NOCASE,OPT !                     
KeyCompany               KEY(CUS:Company),DUP,NOCASE       !                     
KeyZipCode               KEY(CUS:ZipCode),DUP,NOCASE       !                     
StateKey                 KEY(CUS:State),DUP,NOCASE,OPT     !                     
Record                   RECORD,PRE()
CustNumber                  LONG                           ! Customer's Identification Number
Company                     STRING(20)                     ! Customer's Company Name
FirstName                   STRING(20)                     ! Customer's First Name
MI                          STRING(1)                      ! Customer's Middle Initial
LastName                    STRING(25)                     ! Customer's Last Name
Address1                    STRING(35)                     ! Customer's Street Address - 1st Line
Address2                    STRING(35)                     ! Customer's Address - 2nd Line
City                        STRING(25)                     ! Customer's City     
State                       STRING(2)                      ! Customer's State    
ZipCode                     STRING(10)                     ! Customer's ZipCode  
PhoneNumber                 STRING(10)                     ! Customer's phone number
Extension                   STRING(4)                      ! Customer's phone extension
PhoneType                   STRING(8)                      ! Customer's phone type
                         END
                     END                       

OrdersS              FILE,DRIVER('MSSQL'),OWNER('localhost,TableManagerInventory;Trusted_Connection=yes;'),NAME('dbo.Orders'),PRE(ORDS),CREATE,BINDABLE,THREAD ! Customer's Orders   
KeyCustOrderNumber       KEY(ORDS:CustNumber,ORDS:OrderNumber),DUP,NOCASE,OPT !                     
InvoiceNumberKey         KEY(ORDS:InvoiceNumber),NOCASE,OPT !                     
KeyOrderDate             KEY(ORDS:OrderDate,ORDS:CustNumber,ORDS:OrderNumber),NOCASE !                     
Record                   RECORD,PRE()
CustOrderNumbers            GROUP                          !                     
CustNumber                    LONG                         ! Customer's Identification Number
OrderNumber                   LONG                         ! Order Identification Number
                            END                            !                     
InvoiceNumber               LONG                           ! Invoice number for each order
OrderDate                   DATE                           ! Date of Order       
SameName                    BYTE                           ! ShipTo name same as Customer's
ShipToName                  STRING(45)                     ! Customer the order is shipped to
SameAdd                     BYTE                           ! Ship to address same as customer's
ShipAddress1                STRING(35)                     ! 1st Line of ship address
ShipAddress2                STRING(35)                     ! 2nd line of ship address
ShipCity                    STRING(25)                     ! City of Ship address
ShipState                   STRING(2)                      ! State to ship to    
ShipZip                     STRING(5)                      ! ZipCode of ship city
OrderShipped                BYTE                           ! Checked if order is shipped
OrderNote                   STRING(80)                     ! Additional Information about order
                         END
                     END                       

DetailS              FILE,DRIVER('MSSQL'),OWNER('localhost,TableManagerInventory;Trusted_Connection=yes;'),NAME('dbo.Detail'),PRE(DTLS),CREATE,BINDABLE,THREAD ! Product-Order detail
KeyDetails               KEY(DTLS:CustNumber,DTLS:OrderNumber,DTLS:LineNumber),NOCASE,OPT,PRIMARY !                     
Record                   RECORD,PRE()
CustOrderNumbers            GROUP                          !                     
CustNumber                    LONG                         ! Customer's Identification Number
OrderNumber                   LONG                         ! Order Identification Number
                            END                            !                     
LineNumber                  SHORT                          ! Line number         
ProductNumber               LONG                           ! Product Identification Number
QuantityOrdered             DECIMAL(7,2)                   ! Quantity of product ordered
BackOrdered                 BYTE                           ! Product is on back order
Price                       DECIMAL(7,2)                   ! Product's price     
TaxRate                     DECIMAL(6,4)                   ! Consumer's Tax rate 
TaxPaid                     DECIMAL(7,2)                   ! Calculated tax on product
DiscountRate                DECIMAL(6,4)                   ! Special discount rate on product
Discount                    DECIMAL(7,2)                   ! Calculated discount on product
Savings                     DECIMAL(7,2)                   ! Amount saved due to discount
TotalCost                   DECIMAL(10,2)                  ! Extended Total for product
                         END
                     END                       

!endregion

Access:Products      &FileManager,THREAD                   ! FileManager for Products
Relate:Products      &RelationManager,THREAD               ! RelationManager for Products
Access:Detail        &FileManager,THREAD                   ! FileManager for Detail
Relate:Detail        &RelationManager,THREAD               ! RelationManager for Detail
Access:Orders        &FileManager,THREAD                   ! FileManager for Orders
Relate:Orders        &RelationManager,THREAD               ! RelationManager for Orders
Access:Customers     &FileManager,THREAD                   ! FileManager for Customers
Relate:Customers     &RelationManager,THREAD               ! RelationManager for Customers
Access:OrdersS       &FileManager,THREAD                   ! FileManager for OrdersS
Relate:OrdersS       &RelationManager,THREAD               ! RelationManager for OrdersS
Access:DetailS       &FileManager,THREAD                   ! FileManager for DetailS
Relate:DetailS       &RelationManager,THREAD               ! RelationManager for DetailS

FuzzyMatcher         FuzzyClass                            ! Global fuzzy matcher
GlobalErrorStatus    ErrorStatusClass,THREAD
GlobalErrors         ErrorClass                            ! Global error manager
INIMgr               INIClass                              ! Global non-volatile storage manager
GlobalRequest        BYTE(0),THREAD                        ! Set when a browse calls a form, to let it know action to perform
GlobalResponse       BYTE(0),THREAD                        ! Set to the response from the form
VCRRequest           LONG(0),THREAD                        ! Set to the request from the VCR buttons

Dictionary           CLASS,THREAD
Construct              PROCEDURE
Destruct               PROCEDURE
                     END


  CODE
  GlobalErrors.Init(GlobalErrorStatus)
  FuzzyMatcher.Init                                        ! Initilaize the browse 'fuzzy matcher'
  FuzzyMatcher.SetOption(MatchOption:NoCase, 1)            ! Configure case matching
  FuzzyMatcher.SetOption(MatchOption:WordOnly, 0)          ! Configure 'word only' matching
  INIMgr.Init('.\TestApp.INI', NVD_INI)                    ! Configure INIManager to use INI file
  DctInit()
  TestsTableManager
  INIMgr.Update
  INIMgr.Kill                                              ! Destroy INI manager
  FuzzyMatcher.Kill                                        ! Destroy fuzzy matcher


Dictionary.Construct PROCEDURE

  CODE
  IF THREAD()<>1
     DctInit()
  END


Dictionary.Destruct PROCEDURE

  CODE
  DctKill()

