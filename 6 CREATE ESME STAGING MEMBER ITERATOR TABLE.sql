--===========================================================================================================================================================================================
--===========================================================================================================================================================================================
--===========================================================================================================================================================================================
/****** Object:  Table [ski_int].[ESME_Staging_Member]    Script Date: 22/01/2018 08:36:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('ski_int.ESME_Staging_Member') IS NOT NULL
DROP TABLE [ski_int].[ESME_Staging_Member]
GO
CREATE TABLE [ski_int].[ESME_Staging_Member](

	--==================================================
	--RISK DETAILS
	--==================================================
	[RH_ExternalReference] [nvarchar](255) NULL,
	[CH_RegistrationNumber] [nvarchar](255) NULL,	
	[PH_PolicyNumber] [nvarchar](50) NOT NULL,
	[RH_ParentQuoteID] [nvarchar](55) NULL,
	[RH_QuoteID] [nvarchar](55) NULL,

	--==================================================
	--RISK SME EMPLOYEE PACKAGE 1001
	--==================================================
	[RD_Member_ID] [nvarchar](50) NULL,
	[RD_Member_EffectiveDate] [date] NULL,
	[RD_Employee_Ref_Number] [nvarchar](50) NULL,
	[RD_Member_Employee_Policy_Number] [nvarchar](50) NULL,
	[RD_Member_AXA_PPP_Policy_No] [nvarchar](50) NULL,
	[RD_Member_Title] [nvarchar](50) NULL,
	[RD_Member_First_Name] [nvarchar](50) NULL,
	[RD_Member_Last_Name] [nvarchar](50) NULL,
	[RD_Member_Position] [nvarchar](50) NULL,
	[RD_Member_Position_Other] [nvarchar](50) NULL,
	[RD_Member_Sex] [nvarchar](50) NULL,
	[RD_Member_Date_Of_Birth] [date] NULL,
	[RD_Member_Email_Address] [nvarchar](255) NULL,
	[RD_Member_Premises] [nvarchar](50) NULL,
	[RD_Member_Home_Address_Line_1] [nvarchar](50) NULL,
	[RD_Member_Home_Address_Line_2] [nvarchar](50) NULL,
	[RD_Member_Home_Address_Line_3] [nvarchar](50) NULL,
	[RD_Member_Province] [nvarchar](50) NULL,
	[RD_Member_Area_Code] [nvarchar](50) NULL,
	
	--==================================================
	--SYTEM FIELDS
	--==================================================
	[iID] [INT] IDENTITY(1,1),
	[iImportRecNo] [bigint] NOT NULL,
	[dtProcessDate] [date] NOT NULL,
	CONSTRAINT [PK_Staging_Member_ID] PRIMARY KEY ([iID])
) ON [PRIMARY]

GO
