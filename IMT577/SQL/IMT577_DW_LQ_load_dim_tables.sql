USE "IMT577_DW_LAURA_QUANTE"

/*****************************************
Course: IMT 577
Instructor: Laura Quante
Week 6 /Dimensional Loads in Snowflake
Date: 05/08/22
Notes: Create dimension tables & load.
Steps:
    1. Loading DataUSE "IMT577_DW_LAURA_QUANTE"

/*****************************************
Course: IMT 577
Instructor: Laura Quante
Week 6 /Dimensional Loads in Snowflake
Date: 05/08/22
Notes: Create dimension tables & load.
Steps:
    1. Loading Data

Notes: 
Need to load 6 total dimensional tables: Location, Store, Reseller, Customer, Channel, Product, [Date (this has been done for me)]
(start with the ones with no FK)
Dim_Location
Dim_Channel
Dim_Store
Dim_Product
Dim_Reseller
Dim_Customer (Concatenate function is needed)
*****************************************/
--Dim Location - Load data -DONE

 
INSERT INTO Dim_Location
(
    LocationID
    ,PostalCode
    ,Address
    ,City
    ,Region
    ,Country
)
SELECT DISTINCT
    CAST(Stage_Customer.CustomerID AS VARCHAR(255))
    ,CAST(Stage_Customer.PostalCode AS INT)
    ,Stage_Customer.Address
    ,Stage_Customer.City
    ,Stage_Customer.StateProvince
    ,Stage_Customer.Country 
FROM Stage_Customer

UNION

SELECT DISTINCT
    CAST(Stage_Store.StoreID AS VARCHAR(255))
    ,CAST(Stage_Store.PostalCode As INT) 
    ,Stage_Store.Address 
    ,Stage_Store.City 
    ,Stage_Store.StateProvince 
    ,Stage_Store.Country  
FROM Stage_Store

UNION 

SELECT DISTINCT
    CAST(Stage_Reseller.ResellerID AS VARCHAR(255))
    ,CAST(Stage_Reseller.PostalCode As INT) 
    ,Stage_Reseller.Address 
    ,Stage_Reseller.City 
    ,Stage_Reseller.StateProvince 
    ,Stage_Reseller.Country
FROM Stage_Reseller


Select * from Dim_Location

--Dim Channel - load data DONE 

INSERT INTO Dim_Channel
(
    ChannelID
    ,ChannelCategoryID
    ,ChannelName
    ,ChannelCategory
)
SELECT
     
    C.ChannelID as ChannelID
    ,CC.ChannelCategoryID
    ,C.Channel as ChannelName
    ,CC.ChannelCategory 
    
    FROM STAGE_CHANNEL C
    INNER JOIN STAGE_CHANNELCATEGORY CC
    ON C.ChannelCategoryID = CC.ChannelCategoryID

Select * from Dim_Channel

--- Dim Store (Load Data) -- DONE

INSERT INTO Dim_Store 
(
    
    DimLocationID 
    ,StoreID
    ,StoreNumber
    ,StoreManager
)

SELECT    
     
    DimLocationID 
    ,ST.StoreID
    ,ST.StoreNumber
    ,ST.StoreManager

FROM STAGE_STORE ST
    INNER JOIN DIM_Location L
    ON L.DimLocationID = ST.STOREID


Select * from Dim_Store

---Dim Product (Load Data) -- DONE

INSERT INTO Dim_Product
(
    
     ProductID
    ,ProductTypeID
    ,ProductCategoryID
    ,ProductName 
    ,ProductType 
    ,ProductCategory
    ,ProductRetailPrice 
    ,ProductWholesalePrice
    ,ProductCost
    ,ProductRetailProfit
    ,ProductWholesaleUnitProfit
    ,ProductProfitMarginUnitPercent
)

SELECT
    
     P.ProductID AS ProductID
    ,PT.ProductTypeID AS ProductTypeID
    ,PC.ProductCategoryID
    ,P.Product AS ProductName 
    ,PT.ProductType AS ProductType
    ,PC.ProductCategory
    ,P.Price AS ProductRetailPrice 
    ,P.WholesalePrice AS ProductWholesalePrice
    ,P.Cost AS ProductCost
    ,(P.Price - P.Cost) AS ProductRetailProfit
    ,(P.WholesalePrice - P.Cost) AS ProductWholesaleUnitProfit
    ,(ProductRetailProfit/P.Price) AS ProductProfitMarginUnitPercent
    
    FROM STAGE_PRODUCT P
    INNER JOIN STAGE_PRODUCTTYPE PT
    ON P.PRODUCTTYPEID = PT.PRODUCTTYPEID
    INNER JOIN STAGE_PRODUCTCATEGORY PC
    ON PT.PRODUCTCATEGORYID = PC.PRODUCTCATEGORYID
    
  Select * From Dim_Product

---Dim_Reseller

INSERT INTO Dim_Reseller -- DONE
(
     
     DimLocationID
    ,ResellerID
    ,ResellerName
    ,ContactName
    ,PhoneNumber
    ,Email
)

SELECT DISTINCT
     
     DimLocationID 
    ,R.ResellerID
    ,ResellerName 
    ,Contact AS ContactName
    ,R.PhoneNumber
    ,R.EmailAddress AS Email 
    
    FROM STAGE_RESELLER R
    INNER JOIN DIM_Location L
    ON L.LocationID = R.ResellerID
    
Select * FROM Dim_Reseller

--Dim_Customer --DONE

INSERT INTO Dim_Customer 
(
     DimLocationID 
    ,CustomerID
    ,FullName 
    ,FirstName
    ,LastName
    ,Gender 
    ,EmailAddress
    ,PhoneNumber
)

SELECT
     
     L.DimLocationID 
    ,C.CustomerID 
    ,CONCAT (C.FirstName, ' ', C.LastName) AS FullName 
    ,C.FirstName
    ,C.LastName
    ,C.Gender 
    ,C.EmailAddress
    ,C.PhoneNumber 
    
    FROM STAGE_CUSTOMER C
    INNER JOIN DIM_Location L
    ON L.LocationID = C.CustomerID
    
    
 






Notes: 
Need to load 6 total dimensional tables: Location, Store, Reseller, Customer, Channel, Product, [Date (this has been done for me)]
(start with the ones with no FK)
Dim_Location
Dim_Channel
Dim_Store
Dim_Product
Dim_Reseller
Dim_Customer (Concatenate function is needed)
*****************************************/
--Dim Location - Load data -DONE

 
INSERT INTO Dim_Location
(
    LocationID
    ,PostalCode
    ,Address
    ,City
    ,Region
    ,Country
)
SELECT DISTINCT
    CAST(Stage_Customer.CustomerID AS VARCHAR(255))
    ,CAST(Stage_Customer.PostalCode AS INT)
    ,Stage_Customer.Address
    ,Stage_Customer.City
    ,Stage_Customer.StateProvince
    ,Stage_Customer.Country 
FROM Stage_Customer

UNION

SELECT DISTINCT
    CAST(Stage_Store.StoreID AS VARCHAR(255))
    ,CAST(Stage_Store.PostalCode As INT) 
    ,Stage_Store.Address 
    ,Stage_Store.City 
    ,Stage_Store.StateProvince 
    ,Stage_Store.Country  
FROM Stage_Store

UNION 

SELECT DISTINCT
    CAST(Stage_Reseller.ResellerID AS VARCHAR(255))
    ,CAST(Stage_Reseller.PostalCode As INT) 
    ,Stage_Reseller.Address 
    ,Stage_Reseller.City 
    ,Stage_Reseller.StateProvince 
    ,Stage_Reseller.Country
FROM Stage_Reseller


Select * from Dim_Location

--Dim Channel - load data DONE 

INSERT INTO Dim_Channel
(
    ChannelID
    ,ChannelCategoryID
    ,ChannelName
    ,ChannelCategory
)
SELECT
     
    C.ChannelID as ChannelID
    ,CC.ChannelCategoryID
    ,C.Channel as ChannelName
    ,CC.ChannelCategory 
    
    FROM STAGE_CHANNEL C
    INNER JOIN STAGE_CHANNELCATEGORY CC
    ON C.ChannelCategoryID = CC.ChannelCategoryID

Select * from Dim_Channel

--- Dim Store (Load Data) -- DONE

INSERT INTO Dim_Store 
(
    
    DimLocationID 
    ,StoreID
    ,StoreNumber
    ,StoreManager
)

SELECT    
     
    DimLocationID 
    ,ST.StoreID
    ,ST.StoreNumber
    ,ST.StoreManager

FROM STAGE_STORE ST
    INNER JOIN DIM_Location L
    ON L.DimLocationID = ST.STOREID


Select * from Dim_Store

---Dim Product (Load Data) -- DONE

INSERT INTO Dim_Product
(
    
     ProductID
    ,ProductTypeID
    ,ProductCategoryID
    ,ProductName 
    ,ProductType 
    ,ProductCategory
    ,ProductRetailPrice 
    ,ProductWholesalePrice
    ,ProductCost
    ,ProductRetailProfit
    ,ProductWholesaleUnitProfit
    ,ProductProfitMarginUnitPercent
)

SELECT
    
     P.ProductID AS ProductID
    ,PT.ProductTypeID AS ProductTypeID
    ,PC.ProductCategoryID
    ,P.Product AS ProductName 
    ,PT.ProductType AS ProductType
    ,PC.ProductCategory
    ,P.Price AS ProductRetailPrice 
    ,P.WholesalePrice AS ProductWholesalePrice
    ,P.Cost AS ProductCost
    ,(P.Price - P.Cost) AS ProductRetailProfit
    ,(P.WholesalePrice - P.Cost) AS ProductWholesaleUnitProfit
    ,(ProductRetailProfit/P.Price) AS ProductProfitMarginUnitPercent
    
    FROM STAGE_PRODUCT P
    INNER JOIN STAGE_PRODUCTTYPE PT
    ON P.PRODUCTTYPEID = PT.PRODUCTTYPEID
    INNER JOIN STAGE_PRODUCTCATEGORY PC
    ON PT.PRODUCTCATEGORYID = PC.PRODUCTCATEGORYID
    
  Select * From Dim_Product

---Dim_Reseller

INSERT INTO Dim_Reseller -- DONE
(
     
     DimLocationID
    ,ResellerID
    ,ResellerName
    ,ContactName
    ,PhoneNumber
    ,Email
)

SELECT DISTINCT
     
     DimLocationID 
    ,R.ResellerID
    ,ResellerName 
    ,Contact AS ContactName
    ,R.PhoneNumber
    ,R.EmailAddress AS Email 
    
    FROM STAGE_RESELLER R
    INNER JOIN DIM_Location L
    ON L.LocationID = R.ResellerID
    
Select * FROM Dim_Reseller

--Dim_Customer --DONE

INSERT INTO Dim_Customer 
(
     DimLocationID 
    ,CustomerID
    ,FullName 
    ,FirstName
    ,LastName
    ,Gender 
    ,EmailAddress
    ,PhoneNumber
)

SELECT
     
     L.DimLocationID 
    ,C.CustomerID 
    ,CONCAT (C.FirstName, ' ', C.LastName) AS FullName 
    ,C.FirstName
    ,C.LastName
    ,C.Gender 
    ,C.EmailAddress
    ,C.PhoneNumber 
    
    FROM STAGE_CUSTOMER C
    INNER JOIN DIM_Location L
    ON L.LocationID = C.CustomerID
    
    
 




USE "IMT577_DW_LAURA_QUANTE"

/*****************************************
Course: IMT 577
Instructor: Laura Quante
Week 6 /Dimensional Loads in Snowflake
Date: 05/08/22
Notes: Create dimension tables & load.
Steps:
    1. Loading Data

Notes: 
Need to load 6 total dimensional tables: Location, Store, Reseller, Customer, Channel, Product, [Date (this has been done for me)]
(start with the ones with no FK)
Dim_Location
Dim_Channel
Dim_Store
Dim_Product
Dim_Reseller
Dim_Customer (Concatenate function is needed)
*****************************************/
--Dim Location - Load data -DONE

 
INSERT INTO Dim_Location
(
    LocationID
    ,PostalCode
    ,Address
    ,City
    ,Region
    ,Country
)
SELECT DISTINCT
    CAST(Stage_Customer.CustomerID AS VARCHAR(255))
    ,CAST(Stage_Customer.PostalCode AS INT)
    ,Stage_Customer.Address
    ,Stage_Customer.City
    ,Stage_Customer.StateProvince
    ,Stage_Customer.Country 
FROM Stage_Customer

UNION

SELECT DISTINCT
    CAST(Stage_Store.StoreID AS VARCHAR(255))
    ,CAST(Stage_Store.PostalCode As INT) 
    ,Stage_Store.Address 
    ,Stage_Store.City 
    ,Stage_Store.StateProvince 
    ,Stage_Store.Country  
FROM Stage_Store

UNION 

SELECT DISTINCT
    CAST(Stage_Reseller.ResellerID AS VARCHAR(255))
    ,CAST(Stage_Reseller.PostalCode As INT) 
    ,Stage_Reseller.Address 
    ,Stage_Reseller.City 
    ,Stage_Reseller.StateProvince 
    ,Stage_Reseller.Country
FROM Stage_Reseller


Select * from Dim_Location

--Dim Channel - load data DONE 

INSERT INTO Dim_Channel
(
    ChannelID
    ,ChannelCategoryID
    ,ChannelName
    ,ChannelCategory
)
SELECT
     
    C.ChannelID as ChannelID
    ,CC.ChannelCategoryID
    ,C.Channel as ChannelName
    ,CC.ChannelCategory 
    
    FROM STAGE_CHANNEL C
    INNER JOIN STAGE_CHANNELCATEGORY CC
    ON C.ChannelCategoryID = CC.ChannelCategoryID

Select * from Dim_Channel

--- Dim Store (Load Data) -- DONE

INSERT INTO Dim_Store 
(
    
    DimLocationID 
    ,StoreID
    ,StoreNumber
    ,StoreManager
)

SELECT    
     
    DimLocationID 
    ,ST.StoreID
    ,ST.StoreNumber
    ,ST.StoreManager

FROM STAGE_STORE ST
    INNER JOIN DIM_Location L
    ON L.DimLocationID = ST.STOREID


Select * from Dim_Store

---Dim Product (Load Data) -- DONE

INSERT INTO Dim_Product
(
    
     ProductID
    ,ProductTypeID
    ,ProductCategoryID
    ,ProductName 
    ,ProductType 
    ,ProductCategory
    ,ProductRetailPrice 
    ,ProductWholesalePrice
    ,ProductCost
    ,ProductRetailProfit
    ,ProductWholesaleUnitProfit
    ,ProductProfitMarginUnitPercent
)

SELECT
    
     P.ProductID AS ProductID
    ,PT.ProductTypeID AS ProductTypeID
    ,PC.ProductCategoryID
    ,P.Product AS ProductName 
    ,PT.ProductType AS ProductType
    ,PC.ProductCategory
    ,P.Price AS ProductRetailPrice 
    ,P.WholesalePrice AS ProductWholesalePrice
    ,P.Cost AS ProductCost
    ,(P.Price - P.Cost) AS ProductRetailProfit
    ,(P.WholesalePrice - P.Cost) AS ProductWholesaleUnitProfit
    ,(ProductRetailProfit/P.Price) AS ProductProfitMarginUnitPercent
    
    FROM STAGE_PRODUCT P
    INNER JOIN STAGE_PRODUCTTYPE PT
    ON P.PRODUCTTYPEID = PT.PRODUCTTYPEID
    INNER JOIN STAGE_PRODUCTCATEGORY PC
    ON PT.PRODUCTCATEGORYID = PC.PRODUCTCATEGORYID
    
  Select * From Dim_Product

---Dim_Reseller

INSERT INTO Dim_Reseller -- DONE
(
     
     DimLocationID
    ,ResellerID
    ,ResellerName
    ,ContactName
    ,PhoneNumber
    ,Email
)

SELECT DISTINCT
     
     DimLocationID 
    ,R.ResellerID
    ,Contact AS ResellerName
    ,Contact AS ContactName
    ,R.PhoneNumber
    ,R.EmailAddress AS Email 
    
    FROM STAGE_RESELLER R
    INNER JOIN DIM_Location L
    ON L.LocationID = R.ResellerID
    
Select * FROM Dim_Reseller

--Dim_Customer --DONE

INSERT INTO Dim_Customer 
(
     DimLocationID 
    ,CustomerID
    ,FullName 
    ,FirstName
    ,LastName
    ,Gender 
    ,EmailAddress
    ,PhoneNumber
)

SELECT
     
     L.DimLocationID 
    ,C.CustomerID 
    ,CONCAT (C.FirstName, ' ', C.LastName) AS FullName 
    ,C.FirstName
    ,C.LastName
    ,C.Gender 
    ,C.EmailAddress
    ,C.PhoneNumber 
    
    FROM STAGE_CUSTOMER C
    INNER JOIN DIM_Location L
    ON L.LocationID = C.CustomerID
    
    
 




