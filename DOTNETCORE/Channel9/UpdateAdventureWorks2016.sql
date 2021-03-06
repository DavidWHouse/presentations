/*
Run this script on:

        AdventureWorks2016    -  This database will be modified
*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping extended properties'
GO
BEGIN TRY
	EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'FK_Product_UnitMeasure_SizeUnitMeasureCode'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
PRINT N'Dropping foreign keys from [Production].[Product]'
GO
ALTER TABLE [Production].[Product] DROP CONSTRAINT [FK_Product_UnitMeasure_WeightUnitMeasureCode]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [Production].[Product] DROP CONSTRAINT [FK_Product_UnitMeasure_SizeUnitMeasureCode]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[uspGetAllProducts]'
GO
CREATE PROCEDURE [dbo].[uspGetAllProducts]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ProductID,
           Name,
           ProductNumber,
           MakeFlag,
           FinishedGoodsFlag,
           Color,
           SafetyStockLevel,
           ReorderPoint,
           StandardCost,
           ListPrice,
           Size,
           SizeUnitMeasureCode,
           WeightUnitMeasureCode,
           Weight,
           DaysToManufacture,
           ProductLine,
           Class,
           Style,
           ProductSubcategoryID,
           ProductModelID,
           SellStartDate,
           SellEndDate,
           DiscontinuedDate,
           rowguid,
           ModifiedDate
	FROM Production.Product
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [Production].[Product]'
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [FK_Product_UnitMeasure] FOREIGN KEY ([SizeUnitMeasureCode]) REFERENCES [Production].[UnitMeasure] ([UnitMeasureCode])
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [FK_Product_UnitMeasure_WeightUnitMeasureCode] FOREIGN KEY ([WeightUnitMeasureCode]) REFERENCES [Production].[UnitMeasure] ([UnitMeasureCode]) ON DELETE SET NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
-- This statement writes to the SQL Server Log so SQL Monitor can show this deployment.
IF HAS_PERMS_BY_NAME(N'sys.xp_logevent', N'OBJECT', N'EXECUTE') = 1
BEGIN
    DECLARE @databaseName AS nvarchar(2048), @eventMessage AS nvarchar(2048)
    SET @databaseName = REPLACE(REPLACE(DB_NAME(), N'\', N'\\'), N'"', N'\"')
    SET @eventMessage = N'Redgate SQL Compare: { "deployment": { "description": "Redgate SQL Compare deployed to ' + @databaseName + N'", "database": "' + @databaseName + N'" }}'
    EXECUTE sys.xp_logevent 55000, @eventMessage
END
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
