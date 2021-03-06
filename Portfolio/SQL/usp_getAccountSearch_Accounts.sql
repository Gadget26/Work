USE [GSD]
GO
/****** Object:  StoredProcedure [dbo].[usp_getAccountSearch_Accounts]    Script Date: 6/3/2019 9:51:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tarsheika West
-- Create date: 04/23/2019
-- Description:	This proc serves as the lookup for Search Results for the Accounts tab
-- Propose: GSD Inline SQL Migration to new Dev/QA/Prod server
-- =============================================
ALTER PROCEDURE [dbo].[usp_getAccountSearch_Accounts] 
   @parentEgnNumber varchar (100) = ''
  ,@accountNumber varchar (100) = ''
  ,@accountType varchar (25) = ''
  ,@accountName varchar (100) = ''  
  ,@country varchar(25) = ''
  ,@state varchar(30) = ''
  ,@city varchar (30) = ''
  ,@zips varchar (25) = ''
  ,@Admin varchar (10) = ''

/*
	exec [usp_getAccountSearch_Accounts] 
	  @accountNumber = '1982750824948177'
	 --,@accountName = 'Dell'
	 ,@accountType = ''
	 ,@parentEgnNumber = '1069497010'
	 ,@country = ''
	 ,@state = 'TX'
	 ,@city = ''
	 ,@zips = ''
	 ,@Admin = 'Y'
*/

/*
exec [usp_getAccountSearch_Accounts] 
@accountNumber  = '', @accountName  = 'Dell', @accountType  = '', @country = '', @state varchar(50) = '', @city = 'Houston',
			@zips ='', @parentEgnNumber = '1069497010', @Admin = 'Y'
*/


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
			--set @parentEgnNumber = replace(replace(@parentEgnNumber, '''''', ''''), ' ', '')
			--set @accountNumber = replace(replace(@accountNumber, '''''', ''''), ' ', '')

			SELECT DISTINCT TOP 300 *
			FROM accounts WITH (NOLOCK)
			WHERE 1 = 1
			AND (
					account_num = case when @accountNumber != '' then ltrim(rtrim(@accountNumber)) else account_num end 
					OR account_num = case when @accountNumber != '' then '0000'+ltrim(rtrim(@accountNumber)) else account_num end
					OR account_num LIKE case when @accountNumber != '' then '%'+ltrim(rtrim(@accountNumber))+'%' else account_num end
					OR account_num LIKE case when @accountNumber != '' then '0000'+ltrim(rtrim(@accountNumber))+'%' else account_num end
				)
			AND account_name LIKE case when @accountName != '' then ltrim(rtrim(@accountName))+'%' else account_name end 
			AND account_type_cd = case when @accountType != '' then @accountType else account_type_cd end 
			AND country_cd = case when @country != '' then ltrim(rtrim(@country)) else country_cd end 
			AND state_cd = case when @state != '' then ltrim(rtrim(@state)) else state_cd end 
			AND city LIKE case when @city != '' then ltrim(rtrim(@city)) else city end
			AND zipcode LIKE case when @zips != '' then ltrim(rtrim(@zips)) else zipcode end
			AND 1 = case when ltrim(rtrim(@parentEgnNumber)) = '' then 1
						 when ltrim(rtrim(@parentEgnNumber)) <> ''
							and ( parent_number LIKE @parentEgnNumber+'%'
								OR egn_number LIKE @parentEgnNumber+'%'
							    ) 
						then 1
						else 0
				end
			AND 1 = case when ( rtrim(@Admin) in ('N','') and ISNULL(Parent_Number,0) NOT IN (select Parent_Num from common.dbo.BIASecurity_Parent_Exclusions) ) then 1			--//RFC 2719 JPC 12/18/17 
						 when ( @Admin = 'Y' ) then 1
						 else 0 
					end	
			order by account_name

END