--===========================================================================================================================================================================================
--===========================================================================================================================================================================================
--===========================================================================================================================================================================================
/****** Object:  Table [ski_int].[ESME_Staging_CustomerPolicy]    Script Date: 22/01/2018 08:36:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('ski_int.ESME_Staging_CustomerPolicy') IS NOT NULL
DROP TABLE [ski_int].[ESME_Staging_CustomerPolicy]
GO
CREATE TABLE [ski_int].[ESME_Staging_CustomerPolicy](
	
	--==================================================
	--ALWAYS PROVIDE THESE FIELDS
	--==================================================
	[CH_ExternalReference] [nvarchar](255) NOT NULL,
	[CH_CompanyInd] [int] NOT NULL,
	[CH_CountryId] [int] NOT NULL,
	[CH_Currency] [int] NOT NULL,

	--==================================================
	--ALWAYS PROVIDE THESE FIELDS - CUSTOMER HEADER
	--==================================================
	[CH_CompanyName] [nvarchar](255) NOT NULL,
	[CH_ContactName] [nvarchar](80) NOT NULL,
	[CH_Initials] [nvarchar](8) NULL,
	[CH_FirstName] [nvarchar](50) NULL,
	[CH_LastName] [nvarchar](50) NULL,
	[CH_PreferredCommsLanguage] [nvarchar](15) NOT NULL,

	--==================================================
	--CUSTOMER DETAILS
	--==================================================
	[CD_RegistrationNumber] [nvarchar](255) NULL,	
	[CD_CompanyType] [nvarchar](255) NULL,	
	[CD_SicCode] [nvarchar](255) NULL,	
	[CD_SicDescription] [nvarchar](255) NULL,	
	[CD_PreferredMethodOfCommunication] [nvarchar](50) NULL,
	[CD_PreferredMethodOfCommunicationShort] [nvarchar](50) NULL,
	[CD_Title] [nvarchar](15) NULL,
	[CD_IDType] [nvarchar](15) NULL,
	[CD_IDNumber] [nvarchar](255) NULL,
	[CD_Nationality] [nvarchar](255) NULL,
	[CD_DOB] [date] NULL,
	[CD_Gender] [nvarchar](15) NULL,
	[CD_EMailAddress] [nvarchar](255) NULL,
	[CD_Cellnumber] [nvarchar](255) NULL,
	[CD_PhysicalAddressLine1] [nvarchar](50) NULL,
	[CD_PhysicalAddressLine2] [nvarchar](50) NULL,
	[CD_PhysicalAddressLine3] [nvarchar](50) NULL,
	[CD_PhysicalAddressSuburb] [nvarchar](50) NULL,
	[CD_PhysicalAddressPostalCode] [nvarchar](13) NULL,
	[CD_PostalAddressLine1] [nvarchar](50) NULL,
	[CD_PostalAddressLine2] [nvarchar](50) NULL,
	[CD_PostalAddressLine3] [nvarchar](50) NULL,
	[CD_PostalAddressSuburb] [nvarchar](50) NULL,
	[CD_PostalAddressPostalCode] [nvarchar](13) NULL,
	[CD_KeyTitle] [nvarchar](15) NULL,
	[CD_KeyFirstName] [nvarchar](50) NULL,
	[CD_KeyLastName] [nvarchar](50) NULL,
	[CD_KeyPosition] [nvarchar](50) NULL,
	[CD_KeyEMailAddress] [nvarchar](255) NULL,
	[CD_KeyContactnumber] [nvarchar](255) NULL,
	[CD_HRSameAsKeyContact] [int] NULL,
	[CD_HRTitle] [nvarchar](15) NULL,
	[CD_HRFirstName] [nvarchar](50) NULL,
	[CD_HRLastName] [nvarchar](50) NULL,
	[CD_HRPosition] [nvarchar](50) NULL,
	[CD_HREMailAddress] [nvarchar](255) NULL,
	[CD_HRContactnumber] [nvarchar](255) NULL,

	--==================================================
	--ALWAYS PROVIDE THESE FIELDS - POLICY HEADER
	--==================================================
	[PH_PolicyCountryId] [int] NOT NULL,
	[PH_PolicyNumber] [nvarchar](50) NOT NULL,
	[PH_CreatedDate] [date] NOT NULL,
	[PH_ModifiedDate] [date] NULL,
	[PH_CancelledDate] [date] NULL,
	[PH_InceptionDate] [date] NOT NULL,
	[PH_CoverStartDate] [date] NOT NULL,
	[PH_CoverEndDate] [date] NOT NULL,
	[PH_RenewalDate] [date] NOT NULL,
	[PH_LastPaymentDate] [date] NOT NULL,
	[PH_NextPaymentDate] [date] NOT NULL,
	[PH_CoverTerm] [nvarchar](15) NOT NULL,
	[PH_PaymentTerm] [nvarchar](15) NOT NULL,
	[PH_PaymentMethod] [nvarchar](15) NOT NULL,
	[PH_CollectionDay] [int] NOT NULL,
	[PH_VAT] [int] NOT NULL,
	[PH_TAXPerc] [nvarchar](55) NOT NULL,
	[PH_PolicyFee] [nvarchar](55) NOT NULL,
	[PH_BrokerFee] [nvarchar](55) NOT NULL,
	[PH_AdminFee] [nvarchar](55) NOT NULL,
	[PH_IPTFee] [nvarchar](55) NOT NULL,

	--==================================================
	--POLICY DETAILS
	--==================================================
	[PD_ParentQuoteID] [nvarchar](55) NULL,
	[PD_QuoteID] [nvarchar](55) NOT NULL,
	[PD_MonthlyPremium] [nvarchar](55) NULL,
	[PD_EndorsementCode] [nvarchar](55) NULL,
	[PD_CancellationReason] [nvarchar](255) NULL,
	[PD_AXANumber] [nvarchar](55) NULL,
	[PD_DentalAndOptical] [nvarchar](55) NULL,
	[PD_Support] [nvarchar](55) NULL,

	--==================================================
	--SYTEM FIELDS
	--==================================================
	[iID] [INT] IDENTITY(1,1),
	[iImportRecNo] [bigint] NULL,
	[dtProcessDate] [date] NULL,
	CONSTRAINT [PK_Staging_CustomerPolicy_ID] PRIMARY KEY ([iID])
) ON [PRIMARY]

GO