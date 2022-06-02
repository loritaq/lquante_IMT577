USE "IMT577_DW_LAURA_QUANTE"

/*****************************************
Course: IMT 577USE "IMT577_DW_LAURA_QUANTE"

/*****************************************
Course: IMT 577
Instructor: Sean Pettersen
Student: Laura Quante
Week 8
Date: 5/22/2022
Notes: 
1. Create simple views (as base for Tableau) - 9 total
2. Create aggregate views to help answer the analysis questions - 6 total
*****************************************/

---Create simple SQL "pass-through" views of each table (as base for Tableau)

CREATE OR REPLACE SECURE VIEW Dim_StoreView
    AS
        SELECT DISTINCT
             DimStoreID
            ,DimLocationID 
            ,StoreID
            ,StoreNumber
            ,StoreManager
    FROM Dim_Store

CREATE OR REPLACE SECURE VIEW Dim_ResellerView
    AS
        SELECT DISTINCT
             DimResellerID
            ,DimLocationID 
            ,ResellerID 
            ,ResellerName 
            ,ContactName 
            ,PhoneNumber 
            ,Email 
    FROM Dim_Reseller
    
CREATE OR REPLACE SECURE VIEW Dim_CustomerView
    AS
        SELECT DISTINCT
             DimCustomerID
            ,DimLocationID 
            ,CustomerID
            ,FullName 
            ,FirstName
            ,LastName
            ,Gender 
            ,EmailAddress
            ,PhoneNumber
FROM Dim_Customer

CREATE OR REPLACE SECURE VIEW Dim_LocationView
    AS
    SELECT DISTINCT
        DimLocationID
        ,LocationID
        ,PostalCode
        ,Address
        ,City
        ,Region
        ,Country
FROM Dim_Location
 
CREATE OR REPLACE SECURE VIEW Dim_ChannelView
    AS
        SELECT DISTINCT
        DimChannelID
        ,ChannelID
        ,ChannelCategoryID
        ,ChannelName
        ,ChannelCategory
FROM Dim_Channel
        
    
CREATE OR REPLACE SECURE VIEW Dim_ProductView
    AS
       SELECT DISTINCT
            DimProductID
            ,ProductID 
            ,ProductTypeID
            ,ProductCategoryID
            ,ProductName 
            ,ProductType 
            ,ProductCategory
            ,round(ProductRetailPrice, 2) AS ProductRetailPrice
            ,round(ProductWholesalePrice, 2) AS ProductWholesalePrice
            ,round(ProductCost, 2) AS ProductCost
            ,round(ProductRetailProfit, 2) AS ProductRetailProfit
            ,round(ProductWholesaleUnitProfit,2) AS ProductWholesaleUnitProfit
            ,round(ProductProfitMarginUnitPercent, 2) AS ProductProfitMarginUnitPercent
            
    FROM Dim_Product
      
CREATE OR REPLACE SECURE VIEW Fact_SalesActualView
    AS
        SELECT DISTINCT
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
           ,round(SaleUnitPrice, 2) AS SaleUnitPrice
           ,round(SaleExtendedCost, 2) AS SaleExtendedCost
           ,round(SaleTotalProfit, 2) AS SaleTotalProfit
   FROM Fact_SalesActual

CREATE OR REPLACE SECURE VIEW Fact_ProductSalesTargetView
    AS
        SELECT DISTINCT
            DimProductID 
           ,DimTargetDateID
	       ,round(ProductTargetSalesQuantity, 2) AS ProductTargetSalesQuantity
           
FROM Fact_ProductSalesTarget

CREATE OR REPLACE SECURE VIEW Fact_SRCSalesTargetView
    AS
        SELECT DISTINCT
            DimStoreID
           ,DimResellerID 
           ,DimChannelID
           ,DimTargetDateID 
	       ,round(SalesTargetAmount, 2) AS SalesTargetAmount
FROM Fact_SRCSalesTarget


---Create aggregate views to help answer the analysis questions

---1. What are the overall sales amounts (quantity * price ) of stores 5 and 8
CREATE OR REPLACE SECURE  VIEW Product_Sales_Daily
    AS
        SELECT DISTINCT
        S.StoreID
        ,S.StoreNumber
        ,P.ProductID
        ,round(F.SalesQuantity, 2) AS SalesQuantity
        ,round(F.SalesAmount, 2) AS SalesAmount
        ,round(F.SaleTotalProfit, 2) AS SaleTotalProfit
        ,D.Day_Name AS DayoftheWeek
    
FROM Dim_Store S
    JOIN Fact_SalesActual F ON F.DimStoreID = S.DimStoreID
    JOIN Dim_Product P ON P.DimProductID = F.DimProductID
    JOIN Dim_Date D ON F.DimSaleDateID = D.Date_Pkey 
    
 Select * from   Product_Sales_Daily    
        
--- 2. How are they performing compared to the target? (Daily sales amount -  daily target amount)
---Done need to officially load

CREATE OR REPLACE SECURE VIEW Sales_Daily_vs_Target
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,D.Day_Name
            ,round(SUM(FST.SalesTargetAmount),2) AS DailyTargetSalesAmount
            ,round(SUM(SA.SalesAmount), 2) AS DailySalesAmount 
            
  FROM Fact_SRCSalesTarget FST
  JOIN Dim_Store S ON S.DimStoreID = FST.DimStoreID
  JOIN Fact_SalesActual SA ON SA.DimStoreID = FST.DimStoreID 
  JOIN Dim_Date D ON D.Date_PKEY = FST.DimTargetDateID
  WHERE S.StoreNumber = 5 OR S.StoreNumber = 8 
  GROUP BY S.StoreNumber, D.Day_Name


---3. Based on profit margins what should be done in the next year to maximize store profits?


CREATE OR REPLACE SECURE  VIEW Product_Profit_Store_5
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,P.ProductName
            ,round(SUM(SD.SalesAmount), 2) AS TotalSales
            ,round(SUM(P.ProductRetailProfit*SD.SalesQuantity),2) AS TotalProfit
            
            
    FROM Dim_Store S
    JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SD.SalesHeaderID
    JOIN Dim_Product P ON P.ProductID = SD.ProductID
    WHERE S.StoreNumber = 5
    GROUP BY S.StoreNumber, P.ProductName

--- 4. Same as above but Store 8 Done, needs to load 

CREATE OR REPLACE SECURE VIEW Product_Profit_Store_8
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,P.ProductName
            ,round(SUM(SD.SalesAmount),2) AS TotalSales
            ,round(SUM(P.ProductRetailProfit*SD.SalesQuantity),2) AS TotalProfit        
            
    FROM Dim_Store S
    JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SD.SalesHeaderID
    JOIN Dim_Product P ON P.ProductID = SD.ProductID
    WHERE S.StoreNumber = 8
    GROUP BY S.StoreNumber, P.ProductName



---5. Based on sales quantity how well are the product types Men's casual and Women's casual performing to recommend bonus allocation



CREATE OR REPLACE SECURE VIEW Sales_Quantity_Mens_Womens_Casual
    AS
        SELECT DISTINCT
             P.ProductName
            ,P.ProductType
            ,P.ProductCategoryUSE "IMT577_DW_LAURA_QUANTE"

/*****************************************
Course: IMT 577
Instructor: Sean Pettersen
Student: Laura Quante
Week 8
Date: 5/22/2022
Notes: 
1. Create simple views (as base for Tableau) - 9 total
2. Create aggregate views to help answer the analysis questions - 6 total
*****************************************/

---Create simple SQL "pass-through" views of each table (as base for Tableau)

CREATE OR REPLACE SECURE VIEW Dim_StoreView
    AS
        SELECT DISTINCT
             DimStoreID
            ,DimLocationID 
            ,StoreID
            ,StoreNumber
            ,StoreManager
    FROM Dim_Store

CREATE OR REPLACE SECURE VIEW Dim_ResellerView
    AS
        SELECT DISTINCT
             DimResellerID
            ,DimLocationID 
            ,ResellerID 
            ,ResellerName 
            ,ContactName 
            ,PhoneNumber 
            ,Email 
    FROM Dim_Reseller
    
CREATE OR REPLACE SECURE VIEW Dim_CustomerView
    AS
        SELECT DISTINCT
             DimCustomerID
            ,DimLocationID 
            ,CustomerID
            ,FullName 
            ,FirstName
            ,LastName
            ,Gender 
            ,EmailAddress
            ,PhoneNumber
FROM Dim_Customer

CREATE OR REPLACE SECURE VIEW Dim_LocationView
    AS
    SELECT DISTINCT
        DimLocationID
        ,LocationID
        ,PostalCode
        ,Address
        ,City
        ,Region
        ,Country
FROM Dim_Location
 
CREATE OR REPLACE SECURE VIEW Dim_ChannelView
    AS
        SELECT DISTINCT
        DimChannelID
        ,ChannelID
        ,ChannelCategoryID
        ,ChannelName
        ,ChannelCategory
FROM Dim_Channel
        
    
CREATE OR REPLACE SECURE VIEW Dim_ProductView
    AS
       SELECT DISTINCT
            DimProductID
            ,ProductID 
            ,ProductTypeID
            ,ProductCategoryID
            ,ProductName 
            ,ProductType 
            ,ProductCategory
            ,round(ProductRetailPrice, 2) AS ProductRetailPrice
            ,round(ProductWholesalePrice, 2) AS ProductWholesalePrice
            ,round(ProductCost, 2) AS ProductCost
            ,round(ProductRetailProfit, 2) AS ProductRetailProfit
            ,round(ProductWholesaleUnitProfit,2) AS ProductWholesaleUnitProfit
            ,round(ProductProfitMarginUnitPercent, 2) AS ProductProfitMarginUnitPercent
            
    FROM Dim_Product
      
CREATE OR REPLACE SECURE VIEW Fact_SalesActualView
    AS
        SELECT DISTINCT
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
           ,round(SaleUnitPrice, 2) AS SaleUnitPrice
           ,round(SaleExtendedCost, 2) AS SaleExtendedCost
           ,round(SaleTotalProfit, 2) AS SaleTotalProfit
   FROM Fact_SalesActual

CREATE OR REPLACE SECURE VIEW Fact_ProductSalesTargetView
    AS
        SELECT DISTINCT
            DimProductID 
           ,DimTargetDateID
	       ,round(ProductTargetSalesQuantity, 2) AS ProductTargetSalesQuantity
           
FROM Fact_ProductSalesTarget

CREATE OR REPLACE SECURE VIEW Fact_SRCSalesTargetView
    AS
        SELECT DISTINCT
            DimStoreID
           ,DimResellerID 
           ,DimChannelID
           ,DimTargetDateID 
	       ,round(SalesTargetAmount, 2) AS SalesTargetAmount
FROM Fact_SRCSalesTarget


---Create aggregate views to help answer the analysis questions

---1. What are the overall sales amounts (quantity * price ) of stores 5 and 8
CREATE OR REPLACE SECURE  VIEW Product_Sales_Daily
    AS
        SELECT DISTINCT
        S.StoreID
        ,S.StoreNumber
        ,P.ProductID
        ,round(F.SalesQuantity, 2) AS SalesQuantity
        ,round(F.SalesAmount, 2) AS SalesAmount
        ,round(F.SaleTotalProfit, 2) AS SaleTotalProfit
        ,D.Day_Name AS DayoftheWeek
    
FROM Dim_Store S
    JOIN Fact_SalesActual F ON F.DimStoreID = S.DimStoreID
    JOIN Dim_Product P ON P.DimProductID = F.DimProductID
    JOIN Dim_Date D ON F.DimSaleDateID = D.Date_Pkey 
    
 Select * from   Product_Sales_Daily    
        
--- 2. How are they performing compared to the target? (Daily sales amount -  daily target amount)
---Done need to officially load

CREATE OR REPLACE SECURE VIEW Sales_Daily_vs_Target
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,D.Day_Name
            ,round(SUM(FST.SalesTargetAmount),2) AS DailyTargetSalesAmount
            ,round(SUM(SA.SalesAmount), 2) AS DailySalesAmount 
            
  FROM Fact_SRCSalesTarget FST
  JOIN Dim_Store S ON S.DimStoreID = FST.DimStoreID
  JOIN Fact_SalesActual SA ON SA.DimStoreID = FST.DimStoreID 
  JOIN Dim_Date D ON D.Date_PKEY = FST.DimTargetDateID
  WHERE S.StoreNumber = 5 OR S.StoreNumber = 8 
  GROUP BY S.StoreNumber, D.Day_Name


---3. Based on profit margins what should be done in the next year to maximize store profits?


CREATE OR REPLACE SECURE  VIEW Product_Profit_Store_5
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,P.ProductName
            ,round(SUM(SD.SalesAmount), 2) AS TotalSales
            ,round(SUM(P.ProductRetailProfit*SD.SalesQuantity),2) AS TotalProfit
            
            
    FROM Dim_Store S
    JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SD.SalesHeaderID
    JOIN Dim_Product P ON P.ProductID = SD.ProductID
    WHERE S.StoreNumber = 5
    GROUP BY S.StoreNumber, P.ProductName

--- 4. Same as above but Store 8 Done, needs to load 

CREATE OR REPLACE SECURE VIEW Product_Profit_Store_8
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,P.ProductName
            ,round(SUM(SD.SalesAmount),2) AS TotalSales
            ,round(SUM(P.ProductRetailProfit*SD.SalesQuantity),2) AS TotalProfit        
            
    FROM Dim_Store S
    JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SD.SalesHeaderID
    JOIN Dim_Product P ON P.ProductID = SD.ProductID
    WHERE S.StoreNumber = 8
    GROUP BY S.StoreNumber, P.ProductName



---5. Based on sales quantity how well are the product types Men's casual and Women's casual performing to recommend bonus allocation



CREATE OR REPLACE SECURE VIEW Sales_Quantity_Mens_Womens_Casual
    AS
        SELECT DISTINCT
             P.ProductName
            ,P.ProductType
            ,P.ProductCategory
            ,P.ProductProfitMarginUnitPercent
            ,round(SD.SalesQuantity, 2) AS SalesQuantity
            ,round(SD.SalesAmount, 2) AS SalesAmount
 
    FROM Dim_Product P 
    JOIN Stage_SalesDetail SD ON SD.ProductID = P.ProductID
    WHERE P.ProductType = 'Men''s Casual' OR P.ProductType ='Women''s Casual'
    


---6. What are the sales amounts of all stores located in states that have more than one store to all stores that are the only store in the state


CREATE OR REPLACE SECURE VIEW Sales_By_Location
    AS
        SELECT DISTINCT
            S.StoreNumber
            ,L.City
            ,L.Region
            ,round(SUM(SA.SaleTotalProfit),2) AS StoreTotalProfit

            
    FROM Dim_Store S
        JOIN Dim_Location L ON L.DimLocationID = S.DimLocationID
        JOIN Stage_SalesHeader SH ON SH.StoreID = S.StoreID
        JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SD.SalesHeaderID
        JOIN Fact_SalesActual SA ON SA.SalesHeaderID = SD.SalesHeaderID
    GROUP BY S.StoreNumber, L.City, L.Region
   

            
  ---7. Sales by Store by Year
  
  
  CREATE OR REPLACE SECURE VIEW Sales_by_Store
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,P.ProductName
            ,round(SUM(SD.SalesQuantity), 2) AS TotalSalesQuantity
            ,round(SUM(SD.SalesAmount), 2) AS TotalSalesAmount
            ,D.Year          
      
    FROM Stage_SalesDetail SD 
        JOIN Stage_SalesHeader SH ON SD.SalesHeaderID = SD.SalesHeaderID
        JOIN Dim_Store S ON SH.StoreID = S.StoreID
        JOIN Fact_SRCSalesTarget ST ON ST.DimStoreID = S.DimStoreID
        JOIN Dim_Product P ON P.ProductID = SD.ProductID      
        JOIN Dim_Date D ON D.Date_Pkey = ST.DimTargetDateID
        WHERE S.StoreNumber = 5 OR S.StoreNumber = 8
        GROUP BY S.StoreNumber, P.ProductName, D.Year
        

            ,P.ProductProfitMarginUnitPercent
            ,round(SD.SalesQuantity, 2) AS SalesQuantity
            ,round(SD.SalesAmount, 2) AS SalesAmount
 
    FROM Dim_Product P 
    JOIN Stage_SalesDetail SD ON SD.ProductID = P.ProductID
    WHERE P.ProductType = 'Men''s Casual' OR P.ProductType ='Women''s Casual'
    


---6. What are the sales amounts of all stores located in states that have more than one store to all stores that are the only store in the state


CREATE OR REPLACE SECURE VIEW Sales_By_Location
    AS
        SELECT DISTINCT
            S.StoreNumber
            ,L.City
            ,L.Region
            ,round(SUM(SA.SaleTotalProfit),2) AS StoreTotalProfit

            
    FROM Dim_Store S
        JOIN Dim_Location L ON L.DimLocationID = S.DimLocationID
        JOIN Stage_SalesHeader SH ON SH.StoreID = S.StoreID
        JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SD.SalesHeaderID
        JOIN Fact_SalesActual SA ON SA.SalesHeaderID = SD.SalesHeaderID
    GROUP BY S.StoreNumber, L.City, L.Region
   

            
  ---7. Sales by Store by Year
  
  
  CREATE OR REPLACE SECURE VIEW Sales_by_Store
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,P.ProductName
            ,round(SUM(SD.SalesQuantity), 2) AS TotalSalesQuantity
            ,round(SUM(SD.SalesAmount), 2) AS TotalSalesAmount
            ,D.Year          
      
    FROM Stage_SalesDetail SD 
        JOIN Stage_SalesHeader SH ON SD.SalesHeaderID = SD.SalesHeaderID
        JOIN Dim_Store S ON SH.StoreID = S.StoreID
        JOIN Fact_SRCSalesTarget ST ON ST.DimStoreID = S.DimStoreID
        JOIN Dim_Product P ON P.ProductID = SD.ProductID      
        JOIN Dim_Date D ON D.Date_Pkey = ST.DimTargetDateID
        WHERE S.StoreNumber = 5 OR S.StoreNumber = 8
        GROUP BY S.StoreNumber, P.ProductName, D.Year
        

Instructor: Sean Pettersen
Student: Laura Quante
Week 8
Date: 5/22/2022
Notes: 
1. Create simple views (as base for Tableau) - 9 total
2. Create aggregate views to help answer the analysis questions - 6 total
*****************************************/

---Create simple SQL "pass-through" views of each table (as base for Tableau)

CREATE OR REPLACE SECURE VIEW Dim_StoreView
    AS
        SELECT DISTINCT
             DimStoreID
            ,DimLocationID 
            ,StoreID
            ,StoreNumber
            ,StoreManager
    FROM Dim_Store

CREATE OR REPLACE SECURE VIEW Dim_ResellerView
    AS
        SELECT DISTINCT
             DimResellerID
            ,DimLocationID 
            ,ResellerID 
            ,ResellerName 
            ,ContactName 
            ,PhoneNumber 
            ,Email 
    FROM Dim_Reseller
    
CREATE OR REPLACE SECURE VIEW Dim_CustomerView
    AS
        SELECT DISTINCT
             DimCustomerID
            ,DimLocationID 
            ,CustomerID
            ,FullName 
            ,FirstName
            ,LastName
            ,Gender 
            ,EmailAddress
            ,PhoneNumber
FROM Dim_Customer

CREATE OR REPLACE SECURE VIEW Dim_LocationView
    AS
    SELECT DISTINCT
        DimLocationID
        ,LocationID
        ,PostalCode
        ,Address
        ,City
        ,Region
        ,Country
FROM Dim_Location
 
CREATE OR REPLACE SECURE VIEW Dim_ChannelView
    AS
        SELECT DISTINCT
        DimChannelID
        ,ChannelID
        ,ChannelCategoryID
        ,ChannelName
        ,ChannelCategory
FROM Dim_Channel
        
    
CREATE OR REPLACE SECURE VIEW Dim_ProductView
    AS
       SELECT DISTINCT
            DimProductID
            ,ProductID 
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
    FROM Dim_Product
      
CREATE OR REPLACE SECURE VIEW Fact_SalesActualView
    AS
        SELECT DISTINCT
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
   FROM Fact_SalesActual

CREATE OR REPLACE SECURE VIEW Fact_ProductSalesTargetView
    AS
        SELECT DISTINCT
            DimProductID 
           ,DimTargetDateID
	       ,ProductTargetSalesQuantity 
           
FROM Fact_ProductSalesTarget

CREATE OR REPLACE SECURE VIEW Fact_SRCSalesTargetView
    AS
        SELECT DISTINCT
            DimStoreID
           ,DimResellerID 
           ,DimChannelID
           ,DimTargetDateID 
	       ,SalesTargetAmount 
FROM Fact_SRCSalesTarget


---Create aggregate views to help answer the analysis questions

---1. What are the overall sales amounts (quantity * price ) of stores 5 and 8
CREATE OR REPLACE SECURE  VIEW Product_Sales_Daily
    AS
        SELECT DISTINCT
        S.StoreID
        ,S.StoreNumber
        ,P.ProductID
        ,F.SalesQuantity
        ,F.SalesAmount
        ,F.SaleTotalProfit
        ,D.Day_Name AS DayoftheWeek
    
FROM Dim_Store S
    JOIN Fact_SalesActual F ON F.DimStoreID = S.DimStoreID
    JOIN Dim_Product P ON P.DimProductID = F.DimProductID
    JOIN Dim_Date D ON F.DimSaleDateID = D.Date_Pkey 
    
       
        
--- 2. How are they performing compared to the target? (Daily sales amount -  daily target amount)
---Done need to officially load

CREATE OR REPLACE SECURE VIEW Sales_Daily_vs_Target
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,D.Day_Name
            ,SUM(FST.SalesTargetAmount) AS DailyTargetSalesAmount
            ,SUM(SA.SalesAmount) AS DailySalesAmount 
            
  FROM Fact_SRCSalesTarget FST
  JOIN Dim_Store S ON S.DimStoreID = FST.DimStoreID
  JOIN Fact_SalesActual SA ON SA.DimStoreID = FST.DimStoreID 
  JOIN Dim_Date D ON D.Date_PKEY = FST.DimTargetDateID
  WHERE S.StoreNumber = 5 OR S.StoreNumber = 8 
  GROUP BY S.StoreNumber, D.Day_Name


---3. Based on profit margins what should be done in the next year to maximize store profits?

---Done needs to load

CREATE OR REPLACE SECURE  VIEW Product_Profit_Store_5
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,P.ProductName
            ,SUM(SD.SalesAmount) AS TotalSales
            ,SUM(P.ProductRetailProfit*SD.SalesQuantity) AS TotalProfit
            
            
    FROM Dim_Store S
    JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SD.SalesHeaderID
    JOIN Dim_Product P ON P.ProductID = SD.ProductID
    WHERE S.StoreNumber = 5
    GROUP BY S.StoreNumber, P.ProductName

--- 4. Same as above but Store 8 Done, needs to load 

CREATE OR REPLACE SECURE VIEW Product_Profit_Store_8
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,P.ProductName
            ,SUM(SD.SalesAmount) AS TotalSales
            ,SUM(P.ProductRetailProfit*SD.SalesQuantity) AS TotalProfit        
            
    FROM Dim_Store S
    JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SD.SalesHeaderID
    JOIN Dim_Product P ON P.ProductID = SD.ProductID
    WHERE S.StoreNumber = 8
    GROUP BY S.StoreNumber, P.ProductName



---5. Based on sales quantity how well are the product types Men's casual and Women's casual performing to recommend bonus allocation



CREATE OR REPLACE SECURE VIEW Sales_Quantity_Mens_Womens_Casual
    AS
        SELECT DISTINCT
             P.ProductName
            ,P.ProductType
            ,P.ProductCategory
            ,P.ProductProfitMarginUnitPercent
            ,SD.SalesQuantity
            ,SD.SalesAmount        
 
    FROM Dim_Product P 
    JOIN Stage_SalesDetail SD ON SD.ProductID = P.ProductID
    WHERE P.ProductType = 'Men''s Casual' OR P.ProductType ='Women''s Casual'
    ORDER BY SalesAmount


---6. What are the sales amounts of all stores located in states that have more than one store to all stores that are the only store in the state


CREATE OR REPLACE SECURE VIEW Sales_By_Location
    AS
        SELECT DISTINCT
            S.StoreNumber
            ,L.City
            ,L.Region
            ,SUM(SA.SaleTotalProfit) AS StoreTotalProfit

            
    FROM Dim_Store S
        JOIN Dim_Location L ON L.DimLocationID = S.DimLocationID
        JOIN Stage_SalesHeader SH ON SH.StoreID = S.StoreID
        JOIN Stage_SalesDetail SD ON SD.SalesHeaderID = SD.SalesHeaderID
        JOIN Fact_SalesActual SA ON SA.SalesHeaderID = SD.SalesHeaderID
    GROUP BY S.StoreNumber, L.City, L.Region
    ORDER BY StoreTotalProfit

            
  ---7. Sales by Store by Year
  
  
  CREATE OR REPLACE SECURE VIEW Sales_by_Store
    AS
        SELECT DISTINCT
             S.StoreNumber
            ,P.ProductName
            ,SUM(SD.SalesQuantity) AS TotalSalesQuantity
            ,SUM(SD.SalesAmount) AS TotalSalesAmount
            ,D.Year          
      
    FROM Stage_SalesDetail SD 
        JOIN Stage_SalesHeader SH ON SD.SalesHeaderID = SD.SalesHeaderID
        JOIN Dim_Store S ON SH.StoreID = S.StoreID
        JOIN Fact_SRCSalesTarget ST ON ST.DimStoreID = S.DimStoreID
        JOIN Dim_Product P ON P.ProductID = SD.ProductID      
        JOIN Dim_Date D ON D.Date_Pkey = ST.DimTargetDateID
        WHERE S.StoreNumber = 5 OR S.StoreNumber = 8
        GROUP BY S.StoreNumber, P.ProductName, D.Year
        ORDER BY D.Year
