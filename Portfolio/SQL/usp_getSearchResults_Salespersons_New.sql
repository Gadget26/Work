USE [GSD]
GO
/****** Object:  StoredProcedure [dbo].[usp_getSearchResults_Salespersons_New]    Script Date: 6/3/2019 10:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tarsheika West
-- Create date: 04/09/2019
-- Description:	This proc serves as the Search Results for SalesPersons tab
-- Propose: GSD Inline SQL Migration to new Dev/QA/Prod server
-- =============================================
ALTER PROCEDURE [dbo].[usp_getSearchResults_Salespersons_New] 
  @first_name varchar(30) = ''
  ,@last_name varchar(30) = ''  
  ,@country varchar(10) = ''
  ,@state varchar(30) = ''
  ,@city varchar (30) = ''
  ,@zips varchar (10) = ''
  ,@region varchar (30) = ''
  ,@district varchar (30) = ''
  ,@urlObj_id varchar (30) = ''
  ,@resourceId varchar (30) = ''
  ,@SLS_GRP_CD varchar (30) = ''
  ,@SalesJob_type varchar (100) = ''

/*
exec [usp_getSearchResults_Salespersons_New] 
  @country = ''
  ,@state = ''
  ,@city = ''
  ,@first_name = 'CHRIS'
  ,@last_name = 'P'
  ,@city = ''
  ,@zips = ''

--select top 1 * from salesPersons where zipcode like '1%'
*/

/*
drop table ##tmp
drop table ##tmp2
drop table ##tmp3
drop table ##JopTypes
*/

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @JTC varchar (30), @JT varchar (30)

	set @JTC = 'select job_type_code FROM Sales_Job_Type_Codes WHERE job_type_group_id = @SalesJob_type'
	set @JT = 'SELECT job_type_code FROM ##JopTypes'

	SELECT job_type_code
	INTO #JobTypes
	FROM Sales_Job_Type_Codes 
	WHERE job_type_group_id = case when ( @SalesJob_type = '' ) then job_type_group_id else @SalesJob_type end

	select *
	into #tmp
	from
	(
		select distinct
			resource_id,
			fname,
			state_cd,
			Employee_ID2,	 --Manager ---
	        Employee_ID3,	 --Director ---
	        Employee_ID4,	 --VP ---
	        Employee_ID5,	 --DM   ---
	        Employee_ID6	 --President ---
		from salesPersonsSearch A
		inner join Flat_Alignment B on A.resource_id = B.Employee_ID
		WHERE 1 = 1
			AND isnull(country_cd,'') LIKE case when @country != '' then @country+'%' else isnull(country_cd,'') end
			AND isnull(state_cd,'') LIKE case when @state != '' then @state+'%' else isnull(state_cd,'')  end						--- (TT11360) added _LU for PoL lookup ---
			AND isnull(city,'') LIKE case when @city != '' then @city+'%' else isnull(city,'') end						--- (TT11360) added _LU for PoL lookup ---			
			AND isnull(zipcode,'') LIKE case when @zips != '' then @zips+'%' else isnull(zipcode,'') end
			--AND resource_id = case when @urlObj_id is not null and @urlObj_id != '' then @urlObj_id else resource_id end		
			--AND isnull(resource_id,'') = case when @resourceId != '' then @resourceId else isnull(resource_id,'') end	
			AND isnull(fname,'') LIKE case when @first_name != '' then @first_name+'%' else isnull(fname,'') end
			AND isnull(lname,'') LIKE case when @last_name != '' then @last_name+'%' else isnull(lname,'') end
			AND isnull(region_id,'') = case when @region != '' then @region else isnull(region_id,'') end			
			AND isnull(district_id,'') = case when @district != '' then @district else isnull(district_id,'') end	
			AND isnull(sales_unit_id,'') = case when @SLS_GRP_CD != '' then @SLS_GRP_CD else isnull(sales_unit_id,'') end	
						
	) t

--	select * from #tmp

	SELECT resource_id, state_cd
	INTO #tmp2
	FROM
	(
		SELECT distinct resource_id, state_cd
		FROM #tmp
		UNION
		SELECT Employee_ID2 AS resource_id, state_cd --Manager
		FROM #tmp
		UNION
		SELECT Employee_ID3 AS resource_id, state_cd --Director
		FROM #tmp
		UNION
		SELECT Employee_ID4 AS resource_id, state_cd --VP
		FROM #tmp
		UNION
		SELECT Employee_ID5 AS resource_id, state_cd --DM
		FROM #tmp
		UNION
		SELECT Employee_ID6 AS resource_id, state_cd --President
		FROM #tmp
	) T
	WHERE resource_id IS NOT NULL
	
--	select * from #tmp2
			
	select distinct top 300
		s.resource_id
		--,sr.state_cd
		,s.fname
		,s.lname
		,s.name
		,s.job_type_group_desc
		,s.job_type
		,s.adid						--- //rfc 2565 jpc 8/9/16 ---
		,s.email
		,s.sales_unit_id
		,s.sales_unit
		,s.region_id
		,s.district_id
		,s.region_name
		,s.district_name
		,s.address
		,s.city
		,s.state
		,s.zipcode
		,s.country
		,s.country_cd
		,s.atlas
		,s.phone
		,s.mobile
		,s.fax
		,s.manager_id
		,s.manager_first_name
		,s.manager_last_name
		,s.manager_name
		,s.manager_phone
		,s.manager_mobile
		,s.manager_adid						--- //rfc 2565 jpc 8/9/16 ---
		,s.manager_email
		,s.business_unit_cd
		,s.primary_secondary
	from salespersons s with (nolock)
	inner join #tmp2 sr on s.resource_id = sr.resource_id
	where 1 = 1
	and s.job_type not in ('14','is08','ni07','9996','9998', '9996', '9995', '8604','x','b','l','z','w')
	AND 1 = case when (@SalesJob_type != '' and Job_type in (SELECT job_type_code FROM #JobTypes)) then 1
				 when (@SalesJob_type = '') then 1
				 else 0 end
	order by fname

END