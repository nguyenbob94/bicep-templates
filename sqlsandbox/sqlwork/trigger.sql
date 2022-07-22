-- Select the table for the trigger
USE [cars]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Provide the name for the trigger and the table as per above
ALTER TRIGGER [dbo].[yourNewTrigger] ON [dbo].[cars]
FOR UPDATE, INSERT
AS

-- Variables from the Stored Procedure (REST API)
DECLARE @OUTSTATUS VARCHAR(MAX),@OUTRESPONSE VARCHAR(MAX),@POSTDATA VARCHAR(MAX), @INSERTDATA VARCHAR(MAX)

BEGIN
SET NOCOUNT ON

-- Change keys to match the scope of the entity. id, model, luxary are used as examples for a car table
INSERT INTO staging
(id, model, luxury)
SELECT
id , model, luxury
FROM inserted

-- Format the data to parse into Azure Logic Apps. Below is an example for sending UID info to Azure Logic App. This must be formatted properly to match json
SET @INSERTDATA = (SELECT MAX(id) FROM cars)
SET @POSTDATA = '{"id": ' + @INSERTDATA + '}'

-- Execute the POST Trigger
-- Set a fixed db and schema for the master, in case if client db has some funky permission which prevents it from talking to master
EXEC master.dbo.SPX_MAKE_API_REQUEST 'POST','XXX',@POSTDATA,'https:/',@OUTSTATUS OUTPUT,@OUTRESPONSE OUTPUT

end
