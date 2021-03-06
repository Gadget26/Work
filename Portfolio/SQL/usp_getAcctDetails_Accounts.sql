USE [GSD]
GO
/****** Object:  StoredProcedure [dbo].[usp_getAcctDetails_Accounts]    Script Date: 6/3/2019 9:56:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tarsheika West
-- Create date: 04/23/2019
-- Description:	This proc serves as the lookup for Account Details for the Accounts tab
-- Propose: GSD Inline SQL Migration to new Dev/QA/Prod server
-- =============================================
ALTER PROCEDURE [dbo].[usp_getAcctDetails_Accounts] 
	@account_num varchar (30) = ''
   ,@Admin	varchar (30) = ''
 

/*
	exec [usp_getAcctDetails_Accounts] 
	  @account_num varchar (30) = '0730179406354285'
	 ,@Admin	varchar (30) = ''
*/


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if (@Admin is not null) and (@Admin = 'N' OR @Admin = '')
		begin
			SELECT top 1
					account_num,
					account_name,
					account_type,
					account_type_cd,
					primary_resource_id,
					customer_num,
					addr_type_cd,
					city,
					Country_cd,
					country,
					street,
					state_cd,
					state,
					zipcode,
					business_unit_cd,
					region_id,
					district_id,
					region_name,
					district_name,
					reseller_cpp_num,
					fname,
					lname,
					name,
					sales_unit,
					sales_unit_id,
					job_type_group_desc,
					job_type,
					adid,							--- //RFC 2565 JPC 8/9/16 ---
					email,
					phone,
					resource_id,
					atlas,
					mobile,
					fax,
					primary_sr_address,
					primary_sr_city,
					primary_sr_state,
					primary_sr_zipcode,
					primary_sr_country,
					primary_sr_country_cd,
					primary_sr_region,
					primary_sr_district,
					manager_id,
					manager_first_name,
					manager_last_name,
					manager_name,
					manager_phone,
					manager_mobile,
					manager_email,
					sub_parent_number,
					sub_parent_name,
					parent_number,
					parent_name,
					egn_number,
					egn_name,
					rev_account_num,
					search_string,
					ID
				FROM accounts
				WHERE account_num = ltrim(rtrim(@account_num))				
				AND ISNULL(Parent_Number,0) NOT IN (select Parent_Num from common.dbo.BIASecurity_Parent_Exclusions) -- //RFC 2719 JPC 12/18/17 ---
		end        			
	else
		begin
			SELECT top 1
				account_num,
				account_name,
				account_type,
				account_type_cd,
				primary_resource_id,
				customer_num,
				addr_type_cd,
				city,
				Country_cd,
				country,
				street,
				state_cd,
				state,
				zipcode,
				business_unit_cd,
				region_id,
				district_id,
				region_name,
				district_name,
				reseller_cpp_num,
				fname,
				lname,
				name,
				sales_unit,
				sales_unit_id,
				job_type_group_desc,
				job_type,
				adid,							--- //RFC 2565 JPC 8/9/16 ---
				email,
				phone,
				resource_id,
				atlas,
				mobile,
				fax,
				primary_sr_address,
				primary_sr_city,
				primary_sr_state,
				primary_sr_zipcode,
				primary_sr_country,
				primary_sr_country_cd,
				primary_sr_region,
				primary_sr_district,
				manager_id,
				manager_first_name,
				manager_last_name,
				manager_name,
				manager_phone,
				manager_mobile,
				manager_email,
				sub_parent_number,
				sub_parent_name,
				parent_number,
				parent_name,
				egn_number,
				egn_name,
				rev_account_num,
				search_string,
				ID
			FROM accounts
			WHERE account_num = ltrim(rtrim(@account_num))
		end

END