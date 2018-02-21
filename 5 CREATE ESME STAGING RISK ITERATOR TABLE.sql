--===========================================================================================================================================================================================
--===========================================================================================================================================================================================
--===========================================================================================================================================================================================
/****** Object:  Table [ski_int].[ESME_Staging_Risk]    Script Date: 22/01/2018 08:36:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('ski_int.ESME_Staging_Risk') IS NOT NULL
DROP TABLE [ski_int].[ESME_Staging_Risk]
GO
CREATE TABLE [ski_int].[ESME_Staging_Risk](
	
	--==================================================
	--RISK DETAILS
	--==================================================
	[RH_ExternalReference] [nvarchar](255) NOT NULL,
	[CH_RegistrationNumber] [nvarchar](255) NULL,	
	[PH_PolicyNumber] [nvarchar](50) NOT NULL,
	[RH_ParentQuoteID] [nvarchar](55) NOT NULL,
	[RH_QuoteID] [nvarchar](55) NOT NULL,

	--==================================================
	--RISK SME MAIN COVER 1005
	--==================================================
	[MC_1_Number_of_Employees] [nvarchar](5) NULL,
	[MC_1_Premium] [nvarchar](55) NULL,
	[MC_2_Number_of_Employees] [nvarchar](5) NULL,
	[MC_2_Premium] [nvarchar](55) NULL,
	[MC_3_Number_of_Employees] [nvarchar](5) NULL,
	[MC_3_Premium] [nvarchar](55) NULL,
	[MC_4_Number_of_Employees] [nvarchar](5) NULL,
	[MC_4_Premium] [nvarchar](55) NULL,
	[MC_1_Single_Cover] [nvarchar](55) NULL,
	[MC_1_Single_Cover_Premium] [nvarchar](55) NULL,
	[MC_1_Couple_Cover] [nvarchar](55) NULL,
	[MC_1_Couple_Cover_Premium] [nvarchar](55) NULL,
	[MC_1_Single_Family_Cover] [nvarchar](55) NULL,
	[MC_1_Single_Family_Cover_Premium] [nvarchar](55) NULL,
	[MC_1_Couple_Family_Cover] [nvarchar](55) NULL,
	[MC_1_Couple_Family_Cover_Premium] [nvarchar](55) NULL,
	[MC_2_Single_Cover] [nvarchar](55) NULL,
	[MC_2_Single_Cover_Premium] [nvarchar](55) NULL,
	[MC_2_Couple_Cover] [nvarchar](55) NULL,
	[MC_2_Couple_Cover_Premium] [nvarchar](55) NULL,
	[MC_2_Single_Family_Cover] [nvarchar](55) NULL,
	[MC_2_Single_Family_Cover_Premium] [nvarchar](55) NULL,
	[MC_2_Couple_Family_Cover] [nvarchar](55) NULL,
	[MC_2_Couple_Family_Cover_Premium] [nvarchar](55) NULL,
	[MC_3_Single_Cover] [nvarchar](55) NULL,
	[MC_3_Single_Cover_Premium] [nvarchar](55) NULL,
	[MC_3_Couple_Cover] [nvarchar](55) NULL,
	[MC_3_Couple_Cover_Premium] [nvarchar](55) NULL,
	[MC_3_Single_Family_Cover] [nvarchar](55) NULL,
	[MC_3_Single_Family_Cover_Premium] [nvarchar](55) NULL,
	[MC_3_Couple_Family_Cover] [nvarchar](55) NULL,
	[MC_3_Couple_Family_Cover_Premium] [nvarchar](55) NULL,
	[MC_4_Single_Cover] [nvarchar](55) NULL,
	[MC_4_Single_Cover_Premium] [nvarchar](55) NULL,
	[MC_4_Couple_Cover] [nvarchar](55) NULL,
	[MC_4_Couple_Cover_Premium] [nvarchar](55) NULL,
	[MC_4_Single_Family_Cover] [nvarchar](55) NULL,
	[MC_4_Single_Family_Cover_Premium] [nvarchar](55) NULL,
	[MC_4_Couple_Family_Cover] [nvarchar](55) NULL,
	[MC_4_Couple_Family_Cover_Premium] [nvarchar](55) NULL,

	--==================================================
	--RISK DENTAL 1002
	--==================================================
	[Dental_EffectiveDate] [date] NULL,
	[Dental_Number_of_Employees] [nvarchar](5) NULL,
	[Dental_Dental_And_Optical_Pack] [nvarchar](50) NULL,
	[Dental_Equipsme_Margin] [nvarchar](50) NULL,
	[Dental_AXA_Margin] [nvarchar](50) NULL,
	[Dental_Equipsme_Comm] [nvarchar](50) NULL,
	[Dental_AXA_Margin_IPT] [nvarchar](50) NULL,

	--==================================================
	--RISK SUPPORT 1003
	--==================================================
	[Support_EffectiveDate] [date] NULL,
	[Support_Number_of_Employees] [nvarchar](5) NULL,
	[Support_Pack] [nvarchar](50) NULL,
	[Support_Equipsme_Margin] [nvarchar](50) NULL,
	[Support_Health_Assured] [nvarchar](50) NULL,
	[Support_VAT] [nvarchar](50) NULL,
	[Support_Equipsme_Comm] [nvarchar](50) NULL,

	--==================================================
	--RISK Thriva 1007
	--==================================================
	[Thriva_Premium] [nvarchar](50) NULL,

	--==================================================
	--RISK Medical Solutions 1006
	--==================================================
	[Medical_Solutions_Premium] [nvarchar](50) NULL,

	--==================================================
	--RISK SME EMPLOYEE PACKAGE 1001
	--==================================================
	[SME_EmpPack_EffectiveDate] [date] NULL,
	[SME_EmpPack_Employee_Ref_Number] [nvarchar](50) NULL,
	[SME_EmpPack_Employee_Policy_Number] [nvarchar](50) NULL,
	[SME_EmpPack_AXA_PPP_Policy_No] [nvarchar](50) NULL,
	[SME_EmpPack_Title] [nvarchar](50) NULL,
	[SME_EmpPack_First_Name] [nvarchar](50) NULL,
	[SME_EmpPack_Last_Name] [nvarchar](50) NULL,
	[SME_EmpPack_Position] [nvarchar](50) NULL,
	[SME_EmpPack_Position_Other] [nvarchar](50) NULL,
	[SME_EmpPack_Sex] [nvarchar](50) NULL,
	[SME_EmpPack_Date_Of_Birth] [date] NULL,
	[SME_EmpPack_Email_Address] [nvarchar](255) NULL,
	[SME_EmpPack_Premises] [nvarchar](50) NULL,
	[SME_EmpPack_Home_Address_Line_1] [nvarchar](50) NULL,
	[SME_EmpPack_Home_Address_Line_2] [nvarchar](50) NULL,
	[SME_EmpPack_Home_Address_Line_3] [nvarchar](50) NULL,
	[SME_EmpPack_Province] [nvarchar](50) NULL,
	[SME_EmpPack_Area_Code] [nvarchar](50) NULL,
	[SME_EmpPack_SME_Level] [nvarchar](50) NULL,
	[SME_EmpPack_SME_Level_Premium] [nvarchar](50) NULL,
	[SME_EmpPack_Equipsme_Margin] [nvarchar](50) NULL,
	[SME_EmpPack_AXA_Margin] [nvarchar](50) NULL,
	[SME_EmpPack_Equipsme_Comm] [nvarchar](50) NULL,
	[SME_EmpPack_AXA_Margin_IPT] [nvarchar](50) NULL,
	[SME_EmpPack_SME_Cover_Status] [nvarchar](50) NULL,
	[SME_EmpPack_Beneficiaries] [nvarchar](255) NULL,

	--==================================================
	--RISK BUY UP EMPLOYEE PACKAGE 1004
	--==================================================
	[BP_EmpPack_EffectiveDate] [date] NULL,
	[BP_EmpPack_Title] [nvarchar](50) NULL,
	[BP_EmpPack_First_Name] [nvarchar](50) NULL,
	[BP_EmpPack_Last_Name] [nvarchar](50) NULL,
	[BP_EmpPack_Position] [nvarchar](50) NULL,
	[BP_EmpPack_Position_Other] [nvarchar](50) NULL,
	[BP_EmpPack_Sex] [nvarchar](50) NULL,
	[BP_EmpPack_Date_Of_Birth] [date] NULL,
	[BP_EmpPack_Email_Address] [nvarchar](255) NULL,
	[BP_EmpPack_Premises] [nvarchar](50) NULL,
	[BP_EmpPack_Home_Address_Line_1] [nvarchar](50) NULL,
	[BP_EmpPack_Home_Address_Line_2] [nvarchar](50) NULL,
	[BP_EmpPack_Home_Address_Line_3] [nvarchar](50) NULL,
	[BP_EmpPack_Province] [nvarchar](50) NULL,
	[BP_EmpPack_Area_Code] [nvarchar](50) NULL,
	[BP_EmpPack_SME_Level] [nvarchar](50) NULL,
	[BP_EmpPack_Optional_Level_Buy_Up] [nvarchar](50) NULL,
	[BP_EmpPack_SME_Cover_Status] [nvarchar](50) NULL,
	[BP_EmpPack_Optional_Cover_Status_Buy_Up] [nvarchar](50) NULL,
	[BP_EmpPack_Beneficiaries] [nvarchar](255) NULL,
	[BP_EmpPack_Employee_Total_Premium] [nvarchar](50) NULL,
	[BP_EmpPack_Employee_Equipsme_Margin] [nvarchar](50) NULL,
	[BP_EmpPack_Employee_AXA_Margin] [nvarchar](50) NULL,
	[BP_EmpPack_Employee_Equipsme_Comm] [nvarchar](50) NULL,
	[BP_EmpPack_Employee_AXA_Margin_IPT] [nvarchar](50) NULL,
	[BP_EmpPack_Employee_Thriva] [nvarchar](50) NULL,
	[BP_Emppack_Employee_Medical_Solutions] [nvarchar](50) NULL,

	--==================================================
	--SYTEM FIELDS
	--==================================================
	[iID] [INT] IDENTITY(1,1),
	[iImportRecNo] [bigint] NOT NULL,
	[dtProcessDate] [date] NOT NULL,
	CONSTRAINT [PK_Staging_Risk_ID] PRIMARY KEY ([iID])
) ON [PRIMARY]

GO
