USE DATABASE IMT577_DW_LAURA_QUANTE

/*****************************************
Course: IMT 577
Instructor: Sean Pettersen
Student: Laura Quante
Date: 5/16/22
Notes: Create fact tables & load.

Steps:
    1. Create fact tables simple
    2. Load Data
*****************************************/
DROP TABLE IF EXISTS Fact_SalesActual;
DROP TABLE IF EXISTS Fact_ProductSalesTarget;
DROP TABLE IF EXISTS Fact_SRCSalesTarget;

----1. Create fact tables COMPLETED

Select * from Dim_channel

CREATE OR REPLACE TABLE Fact_SalesActual
(
	 DimProductID INT CONSTRAINT FK_DimProductID FOREIGN KEY REFERENCES Dim_Product(DimProductID) --Foreign Key
    ,DimStoreID INT CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreID) --Foreign Key
    ,DimResellerID INT CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID) --Foreign Key
    ,DimCustomerID INT CONSTRAINT FK_DimCustomerID FOREIGN KEY REFERENCES Dim_Customer(DimCustomerID) --Foreign Key
    ,DimChannelID INT CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelID) --Foreign Key
    ,DimSaleDateID NUMBER (9) CONSTRAINT FK_DimSaleDateID FOREIGN KEY REFERENCES Dim_Date(Date_PKEY) --Foreign Key
    ,DimLocationID INT CONSTRAINT FK_DimLocationID FOREIGN KEY REFERENCES Dim_Location(DimLocationID) --Foreign Key
	,SalesHeaderID INT
    ,SalesDetailID INT
    ,SalesAmount FLOAT
    ,SalesQuantity INT
    ,SaleUnitPrice FLOAT
    ,SaleExtendedCost FLOAT
    ,SaleTotalProfit FLOAT
   
);


CREATE OR REPLACE TABLE Fact_ProductSalesTarget
(
	 DimProductID INT CONSTRAINT FK_DimProductID FOREIGN KEY REFERENCES Dim_Product(DimProductID) --Foreign Key
    ,DimTargetDateID NUMBER (9) CONSTRAINT FK_TargetDateID FOREIGN KEY REFERENCES Dim_Date(Date_PKey) --Foreign Key
	,ProductTargetSalesQuantity FLOAT
    
);


CREATE OR REPLACE TABLE Fact_SRCSalesTarget
(
	 DimStoreID INT CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreID) --Foreign Key
    ,DimResellerID INT CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID) --Foreign Key
    ,DimChannelID INT CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelID) --Foreign Key
    ,DimTargetDateID NUMBER (9) CONSTRAINT FK_DimTargetDateID FOREIGN KEY REFERENCES Dim_Date(Date_PKEY) --Foreign Key
	,SalesTargetAmount FLOAT
    
);


----PART 2: Loading Fact Tables

INSERT INTO Fact_ProductSalesTarget
	(
	 DimProductID
    ,DimTargetDateID 
	,ProductTargetSalesQuantity 
	)

SELECT DISTINCT 
		  NVL(P.DimProductID, -1) AS DimProductID
         ,NVL(D.Date_PKEY, -1) AS DimTargetDateID 
         ,NVL((TP.SalesQuantityTarget/365), -1) AS ProductTargetSalesQuantity 
         
	FROM Stage_SalesDetail SD 
    LEFT JOIN Dim_Product P ON P.ProductID = SD.ProductID
    LEFT OUTER JOIN Stage_TargetDataProduct TP ON P.ProductID = TP.ProductID
    LEFT JOIN Dim_Date D on D.Year = TP.Year
    ORDER BY DimTargetDateID
       
   

INSERT INTO Fact_SRCSalesTarget
	(    
	 DimStoreID 
    ,DimResellerID 
    ,DimChannelID
    ,DimTargetDateID 
	,SalesTargetAmount 
	)

 SELECT 
           NVL(S.DimStoreID, -1) AS DimStoreID
		  ,NVL(R.DimResellerID, -1) as DimResellerID 
          ,NVL(DC.DimChannelID, -1) AS DimChannelID
		  ,NVL(D.Date_PKEY, -1) AS DimTargetDateID
          ,NVL((TDC.TargetSalesAmount/365), -1) AS SalesTargetAmount  
    
    FROM Stage_TargetDataChannel TDC      
	LEFT JOIN Dim_Store S ON 
        (CASE
            WHEN TDC.TargetName = 'Store Number 5' then '5'
            WHEN TDC.TargetName = 'Store Number 8' then '8'
            WHEN TDC.TargetName = 'Store Number 10' then '10'
            WHEN TDC.TargetName = 'Store Number 21' then '21'
            WHEN TDC.TargetName = 'Store Number 34' then '34'
            WHEN TDC.TargetName = 'Store Number 39' then '39'
            ELSE TDC.TargetName
        END)
	= CAST(S.StoreNumber AS VARCHAR(255))
    LEFT JOIN Dim_Reseller R ON R.ResellerName = CASE WHEN R.ResellerName = 'Mississipi Distributors' THEN 'Mississippi Distributors' ELSE R.ResellerName END
    LEFT JOIN Dim_Channel DC ON DC.ChannelName = CASE WHEN TDC.ChannelName = 'Online' THEN 'On-line' ELSE TDC.ChannelName END
    LEFT JOIN Dim_Date D ON TDC.YEAR = D.Year
    ORDER BY DimTargetDateID
    
  
 Select * from  Fact_SRCSalesTarget
   
 ---Last but not least, change varchar to a different type of varchar. In this case, you are changing the spelling.

---INNER JOIN Dim_Channel dimChannel ON dimChannel.ChannelName = CASE WHEN SRC.ChannelName = 'Online' THEN 'On-line' ELSE SRC.ChannelName END
---INNER JOIN Dim_Reseller ON dimReseller.ResellerName R = CASE WHEN R.ResellerName = 'Mississipi Distributors' THEN 'Mississippi Distributors' ELSE R.ResellerName END


INSERT INTO Fact_SalesActual
	(
	 DimProductID 
    ,DimStoreID 
    ,DimResellerID 
    ,DimCustomerID 
    ,DimChannelID 
    ,DimSaleDateID 
    ,DimLocationID 
	,SalesHeaderID 
    ,SalesDetailID 
    ,SalesAmount 
    ,SalesQuantity 
    ,SaleUnitPrice 
    ,SaleExtendedCost 
    ,SaleTotalProfit
	)
    
	SELECT DISTINCT 
		 NVL(P.DimProductID, -1) AS DimProductID 
        ,NVL(S.DimStoreID, -1) AS DimStoreID
        ,NVL(R.DimResellerID, -1) AS DimResellerID
        ,NVL(CU.DimCustomerID, -1) AS DimCustomerID
        ,NVL(C.DimChannelID, -1) AS DimChannelID 
        ,NVL(D.DATE_PKEY, -1) AS DimSaleDateID 
        ,NVL(L.DimLocationID, -1) AS DimLocationID 
	    ,NVL(SH.SalesHeaderID, -1) AS SalesHeaderID 
        ,NVL(SD.SalesDetailID, -1) AS SalesDetailID 
        ,SD.SalesAmount 
        ,SD.SalesQuantity 
        ,P.ProductCost AS SaleUnitPrice 
        ,(SD.SalesQuantity * P.ProductCost) AS SaleExtendedCost 
        ,(SD.SalesAmount-(P.ProductCost*SD.SalesQuantity)) AS SaleTotalProfit
	FROM Stage_SalesHeader SH
    LEFT JOIN Dim_Store S ON S.StoreID = SH.StoreID
    LEFT JOIN Dim_Reseller R ON R.ResellerID = SH.ResellerID
    LEFT JOIN Dim_Channel C ON C.ChannelID = SH.ChannelID
    JOIN Dim_Channel DC ON DC.ChannelName = CASE WHEN C.ChannelName = 'Online' THEN 'On-line' ELSE C.ChannelName END
    LEFT OUTER JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SH.SalesHeaderID
	LEFT JOIN Dim_Product P ON P.ProductID = SD.ProductID
    LEFT JOIN Dim_Customer CU ON CU.CustomerID = SH.CustomerID
    LEFT JOIN Dim_Location L ON L.DimLocationID = R.DimLocationID OR L.DimLocationID = CU.DimLocationID OR L.DimLocationID = S.DimLocationID
    LEFT JOIN Dim_Date D ON D.Date = SH.Date
    
    
Select * From Fact_SalesActual










USE DATABASE IMT577_DW_LAURA_QUANTE

/*****************************************
Course: IMT 577
Instructor: Sean Pettersen
Student: Laura Quante
Date: 5/16/22
Notes: Create fact tables & load.

Steps:
    1. Create fact tables simple
    2. Load Data
*****************************************/
DROP TABLE IF EXISTS Fact_SalesActual;
DROP TABLE IF EXISTS Fact_ProductSalesTarget;
DROP TABLE IF EXISTS Fact_SRCSalesTarget;

----1. Create fact tables COMPLETED

Select * from Dim_channel

CREATE OR REPLACE TABLE Fact_SalesActual
(
	 DimProductID INT CONSTRAINT FK_DimProductID FOREIGN KEY REFERENCES Dim_Product(DimProductID) --Foreign Key
    ,DimStoreID INT CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreID) --Foreign Key
    ,DimResellerID INT CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID) --Foreign Key
    ,DimCustomerID INT CONSTRAINT FK_DimCustomerID FOREIGN KEY REFERENCES Dim_Customer(DimCustomerID) --Foreign Key
    ,DimChannelID INT CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelID) --Foreign Key
    ,DimSaleDateID NUMBER (9) CONSTRAINT FK_DimSaleDateID FOREIGN KEY REFERENCES Dim_Date(Date_PKEY) --Foreign Key
    ,DimLocationID INT CONSTRAINT FK_DimLocationID FOREIGN KEY REFERENCES Dim_Location(DimLocationID) --Foreign Key
	,SourceSalesHeaderID INT
    ,SourceSalesDetailID INT
    ,SalesAmount FLOAT
    ,SalesQuantity INT
    ,SaleUnitPrice FLOAT
    ,SaleExtendedCost FLOAT
    ,SaleTotalProfit FLOAT
   
);


CREATE OR REPLACE TABLE Fact_ProductSalesTarget
(
	 DimProductID INT CONSTRAINT FK_DimProductID FOREIGN KEY REFERENCES Dim_Product(DimProductID) --Foreign Key
    ,DimTargetDateID NUMBER (9) CONSTRAINT FK_TargetDateID FOREIGN KEY REFERENCES Dim_Date(Date_PKey) --Foreign Key
	,ProductTargetSalesQuantity FLOAT
    
);


CREATE OR REPLACE TABLE Fact_SRCSalesTarget
(
	 DimStoreID INT CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreID) --Foreign Key
    ,DimResellerID INT CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID) --Foreign Key
    ,DimChannelID INT CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelID) --Foreign Key
    ,DimTargetDateID NUMBER (9) CONSTRAINT FK_DimTargetDateID FOREIGN KEY REFERENCES Dim_Date(Date_PKEY) --Foreign Key
	,SalesTargetAmount FLOAT
    
);


----PART 2: Loading Fact Tables

INSERT INTO Fact_ProductSalesTarget
	(
	 DimProductID
    ,DimTargetDateID 
	,ProductTargetSalesQuantity 
	)

SELECT DISTINCT 
		  P.DimProductID AS DimProductID
         ,D.Date_PKEY AS DimTargetDateID 
         ,TP.SalesQuantityTarget/365 AS ProductTargetSalesQuantity 
         
	FROM Stage_SalesDetail SD 
    LEFT JOIN Dim_Product P ON P.ProductID = SD.ProductID
    LEFT OUTER JOIN Stage_TargetDataProduct TP ON P.ProductID = TP.ProductID
    LEFT JOIN Dim_Date D on D.Year = TP.Year
    ORDER BY D.Date_PKEY
   
    
   
Select * From Dim_Product   
Select * From Stage_Product   
Select * From Stage_SalesHeader 
Select * From Stage_SalesDetail
Select * From Stage_targetdatachannel
Select * From Dim_date
Select * FROM Dim_Reseller
Select * FROM Dim_Store
Select * FROM Dim_Channel

INSERT INTO Fact_SRCSalesTarget
	(    
	 DimStoreID 
    ,DimResellerID 
    ,DimChannelID
    ,DimTargetDateID 
	,SalesTargetAmount 
	)

 SELECT 
           NVL(S.DimStoreID, -1) AS DimStoreID
		  ,NVL(R.DimResellerID, -1) as DimResellerID 
          ,NVL(DC.DimChannelID, -1) AS DimChannelID
		  ,NVL(D.Date_PKEY, -1) AS DimTargetDateID
          ,NVL((TDC.TargetSalesAmount/365), -1) AS SalesTargetAmount  
    
    FROM Stage_TargetDataChannel TDC      
	LEFT JOIN Dim_Store S ON S.StoreNumber = 
        (CASE
            WHEN TDC.TargetName = 'Store Number 5' then 5
            WHEN TDC.TargetName = 'Store Number 8' then 8
            WHEN TDC.TargetName = 'Store Number 10' then 10
            WHEN TDC.TargetName = 'Store Number 21' then 21
            WHEN TDC.TargetName = 'Store Number 34' then 34
            WHEN TDC.TargetName = 'Store Number 39' then 39
            ELSE TDC.TargetName
        END)
	= CAST(S.StoreNumber AS VARCHAR(255))
    LEFT JOIN Dim_Reseller R ON TDC.TargetName = R.ResellerName 
    INNER JOIN Dim_Channel DC
    ON DC.ChannelName = CASE WHEN TDC.ChannelName = 'Online' THEN 'On-line' ELSE TDC.ChannelName END
    LEFT JOIN Dim_Date D ON TDC.YEAR = D.Year
    
  
 Select * from  Fact_SRCSalesTarget
   
 ---Last but not least, change varchar to a different type of varchar. In this case, you are changing the spelling.

INNER JOIN Dim_Channel dimChannel
ON dimChannel.ChannelName = CASE WHEN SRC.ChannelName = 'Online' THEN 'On-line' ELSE SRC.ChannelName END

Select * From Dim_Product   
Select * From Stage_Product   
Select * From Stage_SalesHeader 
Select * From Stage_SalesDetail
Select * From Stage_targetdatachannel
Select * From Dim_date
Select * FROM Dim_Reseller
Select * FROM Dim_Store
Select * FROM Dim_Channel
Select * From Dim_Location


INSERT INTO Fact_SalesActual
	(
	 DimProductID 
    ,DimStoreID 
    ,DimResellerID 
    ,DimCustomerID 
    ,DimChannelID 
    ,DimSaleDateID 
    ,DimLocationID 
	,SalesHeaderID 
    ,SalesDetailID 
    ,SalesAmount 
    ,SalesQuantity 
    ,SaleUnitPrice 
    ,SaleExtendedCost 
    ,SaleTotalProfit
	)
    
	SELECT DISTINCT
		 P.DimProductID 
        ,NVL(S.DimStoreID, -1) AS DimStoreID
        ,NVL(R.DimResellerID, -1) AS DimResellerID
        ,NVL(CU.DimCustomerID, -1) AS DimCustomerID
        ,NVL(C.DimChannelID, -1) AS DimChannelID 
        ,SH.Date AS DimSaleDateID 
        ,NVL(L.DimLocationID, -1) AS DimLocationID 
	    ,NVL(SH.SalesHeaderID, -1) AS SalesHeaderID 
        ,NVL(SD.SalesDetailID, -1) AS SalesDetailID 
        ,SD.SalesAmount 
        ,SD.SalesQuantity 
        ,P.ProductCost AS SaleUnitPrice 
        ,(SD.SalesQuantity * P.ProductCost) AS SaleExtendedCost 
        ,(SD.SalesAmount-(P.ProductCost*SD.SalesQuantity)) AS SaleTotalProfit
	FROM Stage_SalesHeader SH
    LEFT JOIN Dim_Store S ON S.StoreID = SH.StoreID
    LEFT JOIN Dim_Reseller R ON R.ResellerID = SH.ResellerID
    LEFT JOIN Dim_Channel C ON C.ChannelID = SH.ChannelID
    LEFT OUTER JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SH.SalesHeaderID
	LEFT JOIN Dim_Product P ON P.ProductID = SD.ProductID
    LEFT JOIN Dim_Customer CU ON CU.CustomerID = SH.CustomerID
    LEFT JOIN Dim_Date D ON D.Date = SH.Date
    LEFT JOIN Dim_Location L ON L.DimLocationID = R.DimLocationID
    



















