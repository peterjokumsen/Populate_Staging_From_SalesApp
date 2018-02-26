SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('dbo.Populate_Staging_From_SalesApp') IS NOT NULL
DROP PROCEDURE [dbo].[Populate_Staging_From_SalesApp]    
GO
CREATE PROCEDURE [dbo].[Populate_Staging_From_SalesApp]    
AS
BEGIN

--======================================================================================================================
--               ***********                   BEGIN RISK ITERATOR                      ************
--======================================================================================================================

--Base Premium (used for checks and balances)
DECLARE @PremLev4 [FLOAT]                      = 3.406376--6.7
DECLARE @PremLev3 [FLOAT]                      = 7.562382--15.85
DECLARE @PremLev2 [FLOAT]                      = 16.315926--26.85
DECLARE @PremLev1 [FLOAT]                      = 18.542471--32.85
--Premium Splits
DECLARE @Equipsme_Margin_4 [FLOAT]            = 2.45924716
DECLARE @AXA_Margin_4 [FLOAT]                 = 2.89542
DECLARE @Equipsme_Comm_4 [FLOAT]              = 0.43398479--0.997882440000001
DECLARE @AXA_Margin_IPT_4 [FLOAT]             = 0.3474504

DECLARE @Equipsme_Margin_3 [FLOAT]            = 6.21631645
DECLARE @AXA_Margin_3 [FLOAT]                 = 6.428025
DECLARE @Equipsme_Comm_3 [FLOAT]              = 1.09699702--2.43429555
DECLARE @AXA_Margin_IPT_3 [FLOAT]             = 0.771363

DECLARE @Equipsme_Margin_2 [FLOAT]            = 7.21687167499998
DECLARE @AXA_Margin_2 [FLOAT]                 = 13.8685375
DECLARE @Equipsme_Comm_2 [FLOAT]              = 1.27356559--4.100366325
DECLARE @AXA_Margin_IPT_2 [FLOAT]             = 1.6642245

DECLARE @Equipsme_Margin_1 [FLOAT]            = 9.9312678
DECLARE @AXA_Margin_1 [FLOAT]                 = 15.7611
DECLARE @Equipsme_Comm_1 [FLOAT]              = 1.75257667--5.2663002
DECLARE @AXA_Margin_IPT_1 [FLOAT]             = 1.891332 

DECLARE @Dental_Equipsme_Margin [FLOAT]       = 2.49631--2.12186773333334
DECLARE @Dental_AXA_Margin [FLOAT]            = 4.540549--3.85946666666667
DECLARE @Dental_Equipsme_Comm [FLOAT]         = 1.0555296
DECLARE @Dental_AXA_MARGIN_IPT [FLOAT]        = 0.463136

DECLARE @Support_Equipsme_Margin [FLOAT]      = 0.530576923
DECLARE @Support_Health_Assured [FLOAT]       = 0.559166667
DECLARE @Support_VAT [FLOAT]                  = 0.217948718
DECLARE @Support_Equipsme_Comm [FLOAT]        = 0.192307692

DECLARE @Thriva_4 [FLOAT]                     = 0.15
DECLARE @Thriva_3 [FLOAT]                     = 1
DECLARE @Thriva_2 [FLOAT]                     = 2
DECLARE @Thriva_1 [FLOAT]                     = 4
DECLARE @Medical_Solutions [FLOAT]            = 0.15

;WITH MainCover
AS (
    SELECT
        q.QuoteNumber,
        q.Reference,
        ISNULL(q.ParentQuoteId,0)                                              [ParentQuoteId],
        q.Id,
        q.CompanyId,
        c.RegistrationNumber,
        qd.Lev1Count,
        (qd.Lev1Count * @PremLev1)                                             [PremLev1],
        qd.Lev2Count,
        (qd.Lev2Count * @PremLev2)                                             [PremLev2],
        qd.Lev3Count,
        (qd.Lev3Count * @PremLev3)                                             [PremLev3],
        qd.Lev4Count,
        (qd.Lev4Count * @PremLev4)                                             [PremLev4],
        qd.EmployeeCount,
        qd.DentalOption,
        qd.SupportOption,
        qd.CoverStart
    FROM
        dbo.Quote q
        JOIN dbo.QuoteDetail qd ON q.Id = qd.QuoteId
        JOIN dbo.Company c ON q.CompanyId = c.Id
        JOIN dbo.QuoteStatusHistory qsh ON q.Id = qsh.QuoteId
        JOIN (
            SELECT QuoteId, MAX(Id) Id
            FROM QuoteStatusHistory
            GROUP BY QuoteId
            ) qshl ON qsh.QuoteId = qshl.QuoteId AND qsh.Id = qshl.Id
    WHERE
        (q.ParentQuoteId IS NULL)
        AND qsh.[Status] = 3
        AND q.ETLStatus = 0
), EmployeePackage
AS (
    SELECT 
        q.Id                                                                   [QuoteId],
        ISNULL(q.ParentQuoteId,0)                                              [ParentQuoteId],
        p.Id                                                                   [PersonID],
        ISNULL(lTitle.[Value],'')                                              [Title],
        p.Initials,
        p.FirstName,
        p.LastName,
        lPosition.[Value]                                                      [Position],
        p.PositionOther,
        lGender.[Value]                                                        [Gender],
        p.DateOfBirth,
        p.EmailAddress,
        ISNULL(pa.AddressLine1,'') AS AddressLine1,
        ISNULL(pa.AddressLine2,'') AS AddressLine2,
        ISNULL(pa.AddressLine3,'') AS AddressLine3,
        pa.Town,
        pa.PostalCode,
    --  ===========================================================================================================
    --           CALCULATE THE PREMIUM SPLIT PER LEVEL - COMPANY CONTRIBUTION
    --  ===========================================================================================================
        qd.EmployerLev,
        (
        CASE qd.EmployerLev
            WHEN 4 THEN @PremLev4
            WHEN 3 THEN @PremLev3
            WHEN 2 THEN @PremLev2
            WHEN 1 THEN @PremLev1
        END
        )                                                                      [Employer_Prem_Total],
        ( --Equipsme Margin
        CASE qd.EmployerLev
            WHEN 4 THEN @Equipsme_Margin_4
            WHEN 3 THEN @Equipsme_Margin_3
            WHEN 2 THEN @Equipsme_Margin_2
            WHEN 1 THEN @Equipsme_Margin_1
        END
        )                                                                      [Employer_Prem_Equipsme_Margin],
        ( --AXA Margin
        CASE qd.EmployerLev
            WHEN 4 THEN @AXA_Margin_4
            WHEN 3 THEN @AXA_Margin_3
            WHEN 2 THEN @AXA_Margin_2
            WHEN 1 THEN @AXA_Margin_1
        END
        )                                                                      [Employer_Prem_AXA_Margin],
        ( --Equipsme Comm
        CASE qd.EmployerLev
            WHEN 4 THEN @Equipsme_Comm_4
            WHEN 3 THEN @Equipsme_Comm_3
            WHEN 2 THEN @Equipsme_Comm_2
            WHEN 1 THEN @Equipsme_Comm_1
        END
        )                                                                      [Employer_Prem_Equipsme_Comm],
        ( --AXA Margin IPT
        CASE qd.EmployerLev
            WHEN 4 THEN @AXA_Margin_IPT_4
            WHEN 3 THEN @AXA_Margin_IPT_3
            WHEN 2 THEN @AXA_Margin_IPT_2
            WHEN 1 THEN @AXA_Margin_IPT_1
        END
        )                                                                      [Employer_Prem_AXA_Margin_IPT],
        ( --Thriva
        CASE qd.EmployerLev
            WHEN 4 THEN @Thriva_4
            WHEN 3 THEN @Thriva_3
            WHEN 2 THEN @Thriva_2
            WHEN 1 THEN @Thriva_1
        END
        )                                                                      [Employer_Prem_Thriva],
        @Medical_Solutions                                                     [Employer_Medical_Solutions],
       
    --  ===========================================================================================================
    --           CALCULATE THE PREMIUM SPLIT PER LEVEL - EMPLOYEE CONTRIBUTION
    --  ===========================================================================================================
        lCover.[Value]                                                         [CoverType],
        EmployeeLevel                                                          [EmployeeLevel],
        (
        CASE
            WHEN qd.EmployeeLevel = 4 THEN @PremLev4
            WHEN qd.EmployeeLevel = 3 THEN @PremLev3
            WHEN qd.EmployeeLevel = 2 THEN @PremLev2
            WHEN qd.EmployeeLevel = 1 THEN @PremLev1
   
        END
        )                                                                      [Employee_Prem_Total],
        ( --Equipsme Margin
        CASE
            WHEN qd.EmployeeLevel = 4 THEN @Equipsme_Margin_4
            WHEN qd.EmployeeLevel = 3 THEN @Equipsme_Margin_3
            WHEN qd.EmployeeLevel = 2 THEN @Equipsme_Margin_2
            WHEN qd.EmployeeLevel = 1 THEN @Equipsme_Margin_1
   
        END
        )                                                                      [Employee_Prem_Equipsme_Margin],
        ( --AXA Margin
        CASE
            WHEN qd.EmployeeLevel = 4 THEN @AXA_Margin_4
            WHEN qd.EmployeeLevel = 3 THEN @AXA_Margin_3
            WHEN qd.EmployeeLevel = 2 THEN @AXA_Margin_2
            WHEN qd.EmployeeLevel = 1 THEN @AXA_Margin_1
   
        END
        )                                                                      [Employee_Prem_AXA_Margin],
        ( --Equipsme Comm
        CASE
            WHEN qd.EmployeeLevel = 4 THEN @Equipsme_Comm_4
            WHEN qd.EmployeeLevel = 3 THEN @Equipsme_Comm_3
            WHEN qd.EmployeeLevel = 2 THEN @Equipsme_Comm_2
            WHEN qd.EmployeeLevel = 1 THEN @Equipsme_Comm_1
   
        END
        )                                                                      [Employee_Prem_Equipsme_Comm],
        ( --AXA Margin IPT
        CASE
            WHEN qd.EmployeeLevel = 4 THEN @AXA_Margin_IPT_4
            WHEN qd.EmployeeLevel = 3 THEN @AXA_Margin_IPT_3
            WHEN qd.EmployeeLevel = 2 THEN @AXA_Margin_IPT_2
            WHEN qd.EmployeeLevel = 1 THEN @AXA_Margin_IPT_1
   
        END
        )                                                                      [Employee_Prem_AXA_Margin_IPT],
        ( --Thriva
        CASE
            WHEN qd.EmployeeLevel = 4 THEN @Thriva_4
            WHEN qd.EmployeeLevel = 3 THEN @Thriva_3
            WHEN qd.EmployeeLevel = 2 THEN @Thriva_2
            WHEN qd.EmployeeLevel = 1 THEN @Thriva_1
   
        END
        )                                                                      [Employee_Prem_Thriva],
        @Medical_Solutions                                                     [Employee_Medical_Solutions],
    --  ===========================================================================================================
    --           CALCULATE THE PREMIUM SPLIT PER LEVEL - EMPLOYEE DEPENDENTS CONTRIBUTION
    --       this calculates the dependents premium (Employee Level x Cover Option multiplier)
    --  ===========================================================================================================
        (
        CASE c.[Type]
            WHEN 0 THEN 0 --Single
            WHEN 1 THEN --Couple (2x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @PremLev4
                    WHEN qd.EmployeeLevel = 3 THEN @PremLev3
                    WHEN qd.EmployeeLevel = 2 THEN @PremLev2
                    WHEN qd.EmployeeLevel = 1 THEN @PremLev1
                END * 2
            WHEN 2 THEN --SingleDependent (1.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @PremLev4
                    WHEN qd.EmployeeLevel = 3 THEN @PremLev3
                    WHEN qd.EmployeeLevel = 2 THEN @PremLev2
                    WHEN qd.EmployeeLevel = 1 THEN @PremLev1
                END * 1.5
            WHEN 3 THEN --Family (2.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @PremLev4
                    WHEN qd.EmployeeLevel = 3 THEN @PremLev3
                    WHEN qd.EmployeeLevel = 2 THEN @PremLev2
                    WHEN qd.EmployeeLevel = 1 THEN @PremLev1
                END * 2.5
        END 
        )                                                                      [Dependent_Prem_Total],
        ( -- Equipsme_Margin
        CASE c.[Type]
            WHEN 0 THEN 0 --Single
            WHEN 1 THEN --Couple (2x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @Equipsme_Margin_4
                    WHEN qd.EmployeeLevel = 3 THEN @Equipsme_Margin_3
                    WHEN qd.EmployeeLevel = 2 THEN @Equipsme_Margin_2
                    WHEN qd.EmployeeLevel = 1 THEN @Equipsme_Margin_1
                END * 2
            WHEN 2 THEN --SingleDependent (1.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @Equipsme_Margin_4
                    WHEN qd.EmployeeLevel = 3 THEN @Equipsme_Margin_3
                    WHEN qd.EmployeeLevel = 2 THEN @Equipsme_Margin_2
                    WHEN qd.EmployeeLevel = 1 THEN @Equipsme_Margin_1
                END * 1.5
            WHEN 3 THEN --Family (2.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @Equipsme_Margin_4
                    WHEN qd.EmployeeLevel = 3 THEN @Equipsme_Margin_3
                    WHEN qd.EmployeeLevel = 2 THEN @Equipsme_Margin_2
                    WHEN qd.EmployeeLevel = 1 THEN @Equipsme_Margin_1
                END * 2.5
        END 
        )                                                                      [Dependent_Prem_Equipsme_Margin],
        ( -- AXA_Margin
        CASE c.[Type]
            WHEN 0 THEN 0 --Single
            WHEN 1 THEN --Couple (2x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @AXA_Margin_4
                    WHEN qd.EmployeeLevel = 3 THEN @AXA_Margin_3
                    WHEN qd.EmployeeLevel = 2 THEN @AXA_Margin_2
                    WHEN qd.EmployeeLevel = 1 THEN @AXA_Margin_1
                END * 2
            WHEN 2 THEN --SingleDependent (1.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @AXA_Margin_4
                    WHEN qd.EmployeeLevel = 3 THEN @AXA_Margin_3
                    WHEN qd.EmployeeLevel = 2 THEN @AXA_Margin_2
                    WHEN qd.EmployeeLevel = 1 THEN @AXA_Margin_1
                END * 1.5
            WHEN 3 THEN --Family (2.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @AXA_Margin_4
                    WHEN qd.EmployeeLevel = 3 THEN @AXA_Margin_3
                    WHEN qd.EmployeeLevel = 2 THEN @AXA_Margin_2
                    WHEN qd.EmployeeLevel = 1 THEN @AXA_Margin_1
                END * 2.5
        END 
        )                                                                      [Dependent_Prem_AXA_Margin],
        (-- Equipsme_Comm
        CASE c.[Type]
            WHEN 0 THEN 0 --Single
            WHEN 1 THEN --Couple (2x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @Equipsme_Comm_4
                    WHEN qd.EmployeeLevel = 3 THEN @Equipsme_Comm_3
                    WHEN qd.EmployeeLevel = 2 THEN @Equipsme_Comm_2
                    WHEN qd.EmployeeLevel = 1 THEN @Equipsme_Comm_1
                END * 2
            WHEN 2 THEN --SingleDependent (1.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @Equipsme_Comm_4
                    WHEN qd.EmployeeLevel = 3 THEN @Equipsme_Comm_3
                    WHEN qd.EmployeeLevel = 2 THEN @Equipsme_Comm_2
                    WHEN qd.EmployeeLevel = 1 THEN @Equipsme_Comm_1
                END * 1.5
            WHEN 3 THEN --Family (2.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @Equipsme_Comm_4
                    WHEN qd.EmployeeLevel = 3 THEN @Equipsme_Comm_3
                    WHEN qd.EmployeeLevel = 2 THEN @Equipsme_Comm_2
                    WHEN qd.EmployeeLevel = 1 THEN @Equipsme_Comm_1
                END * 2.5
        END 
        )                                                                      [Dependent_Prem_Equipsme_Comm],
        ( -- AXA_Margin_IPT
        CASE c.[Type]
            WHEN 0 THEN 0 --Single
            WHEN 1 THEN --Couple (2x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @AXA_Margin_IPT_4
                    WHEN qd.EmployeeLevel = 3 THEN @AXA_Margin_IPT_3
                    WHEN qd.EmployeeLevel = 2 THEN @AXA_Margin_IPT_2
                    WHEN qd.EmployeeLevel = 1 THEN @AXA_Margin_IPT_1
                END * 2
            WHEN 2 THEN --SingleDependent (1.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @AXA_Margin_IPT_4
                    WHEN qd.EmployeeLevel = 3 THEN @AXA_Margin_IPT_3
                    WHEN qd.EmployeeLevel = 2 THEN @AXA_Margin_IPT_2
                    WHEN qd.EmployeeLevel = 1 THEN @AXA_Margin_IPT_1
                END * 1.5
            WHEN 3 THEN --Family (2.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @AXA_Margin_IPT_4
                    WHEN qd.EmployeeLevel = 3 THEN @AXA_Margin_IPT_3
                    WHEN qd.EmployeeLevel = 2 THEN @AXA_Margin_IPT_2
                    WHEN qd.EmployeeLevel = 1 THEN @AXA_Margin_IPT_1
                END * 2.5
        END 
        )                                                                      [Dependent_Prem_AXA_Margin_IPT],
        ( -- Thriva
        CASE c.[Type]
            WHEN 0 THEN 0 --Single
            WHEN 1 THEN --Couple (2x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @Thriva_4
                    WHEN qd.EmployeeLevel = 3 THEN @Thriva_3
                    WHEN qd.EmployeeLevel = 2 THEN @Thriva_2
                    WHEN qd.EmployeeLevel = 1 THEN @Thriva_1
                END * 2
            WHEN 2 THEN --SingleDependent (1.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @Thriva_4
                    WHEN qd.EmployeeLevel = 3 THEN @Thriva_3
                    WHEN qd.EmployeeLevel = 2 THEN @Thriva_2
                    WHEN qd.EmployeeLevel = 1 THEN @Thriva_1
                END * 1.5
            WHEN 3 THEN --Family (2.5x)
                CASE
                    WHEN qd.EmployeeLevel = 4 THEN @Thriva_4
                    WHEN qd.EmployeeLevel = 3 THEN @Thriva_3
                    WHEN qd.EmployeeLevel = 2 THEN @Thriva_2
                    WHEN qd.EmployeeLevel = 1 THEN @Thriva_1
                END * 2.5
        END 
        )                                                                      [Dependent_Prem_Thriva],
        ( -- Medical_Solutions
        CASE c.[Type]
            WHEN 0 THEN 0.00 --Single
            WHEN 1 THEN @Medical_Solutions * 2.00 --Couple (2x)
            WHEN 2 THEN @Medical_Solutions * 1.50 --SingleDependent (1.5x)
            WHEN 3 THEN @Medical_Solutions * 2.50 --Family (2.5x)
        END 
        )                                                                      [Dependent_Prem_Medical_Solutions],
        qd.CoverStart,
        q.Reference
    FROM
        dbo.Quote q
        JOIN dbo.Member m ON q.MemberId = m.Id
        JOIN dbo.Person p ON m.PersonId = p.Id
        JOIN dbo.Address pa ON p.AddressId = pa.Id
        JOIN (
            SELECT qd.Id, CoverStart, DentalOption, EmployeeCount, EmployerLev,
            CASE
                WHEN Lev1Count > 0 THEN 1
                WHEN Lev2Count > 0 THEN 2
                WHEN Lev3Count > 0 THEN 3
                WHEN Lev4Count > 0 THEN 4
            END [EmployeeLevel],
            qd.SupportOption
        FROM
            dbo.Quote q
            JOIN dbo.QuoteDetail qd ON q.Id = qd.Id AND q.ParentQuoteId IS NOT NULL
        ) qd ON q.Id = qd.Id
        JOIN dbo.Cover c ON m.CoverId = c.Id
        JOIN dbo.Lookup lTitle ON p.Title = lTitle.EnumValue AND lTitle.GroupName = 'Title'
        JOIN dbo.Lookup lPosition ON p.Position = lPosition.EnumValue AND lPosition.GroupName = 'Position'
        JOIN dbo.Lookup lGender ON p.Gender = lGender.EnumValue AND lGender.GroupName = 'Gender'
        JOIN dbo.Lookup lCover ON c.[Type] = lCover.EnumValue AND lCover.GroupName = 'CoverType'
        JOIN dbo.QuoteStatusHistory qsh ON q.Id = qsh.QuoteId
        JOIN (
            SELECT QuoteId, MAX(Id) Id
            FROM QuoteStatusHistory
            GROUP BY QuoteId
            ) qshl ON qsh.QuoteId = qshl.QuoteId AND qsh.Id = qshl.Id
    WHERE
        (q.ParentQuoteId IS NOT NULL)
        AND q.ETLStatus = 0
)
INSERT INTO [SKi_Equipsme_UAT].[ski_int].[ESME_Staging_Risk]
SELECT
    mc.QuoteNumber                                                             [RH_ExternalReference],
    mc.RegistrationNumber                                                      [CH_RegistrationNumber],   
    mc.Reference                                                               [PH_PolicyNumber],
    ep.ParentQuoteId                                                           [RH_ParentQuoteID],
    ep.QuoteId                                                                 [RH_QuoteID],
    --==================================================
    --RISK SME MAIN COVER 1005
    --==================================================
    mc.Lev1Count                                                               [MC_1_Number_of_Employees],
    mc.PremLev1                                                                [MC_1_Premium],
    mc.Lev2Count                                                               [MC_2_Number_of_Employees],
    mc.PremLev2                                                                [MC_2_Premium],
    mc.Lev3Count                                                               [MC_3_Number_of_Employees],
    mc.PremLev3                                                                [MC_3_Premium],
    mc.Lev4Count                                                               [MC_4_Number_of_Employees],
    mc.PremLev4                                                                [MC_4_Premium],
    --these fields are not currently being used, so not populating them
    ''                                                                         [MC_1_Single_Cover],
    ''                                                                         [MC_1_Single_Cover_Premium],
    ''                                                                         [MC_1_Couple_Cover],
    ''                                                                         [MC_1_Couple_Cover_Premium],
    ''                                                                         [MC_1_Single_Family_Cover],
    ''                                                                         [MC_1_Single_Family_Cover_Premium],
    ''                                                                         [MC_1_Couple_Family_Cover],
    ''                                                                         [MC_1_Couple_Family_Cover_Premium],
    ''                                                                         [MC_2_Single_Cover],
    ''                                                                         [MC_2_Single_Cover_Premium],
    ''                                                                         [MC_2_Couple_Cover],
    ''                                                                         [MC_2_Couple_Cover_Premium],
    ''                                                                         [MC_2_Single_Family_Cover],
    ''                                                                         [MC_2_Single_Family_Cover_Premium],
    ''                                                                         [MC_2_Couple_Family_Cover],
    ''                                                                         [MC_2_Couple_Family_Cover_Premium],
    ''                                                                         [MC_3_Single_Cover],
    ''                                                                         [MC_3_Single_Cover_Premium],
    ''                                                                         [MC_3_Couple_Cover],
    ''                                                                         [MC_3_Couple_Cover_Premium],
    ''                                                                         [MC_3_Single_Family_Cover],
    ''                                                                         [MC_3_Single_Family_Cover_Premium],
    ''                                                                         [MC_3_Couple_Family_Cover],
    ''                                                                         [MC_3_Couple_Family_Cover_Premium],
    ''                                                                         [MC_4_Single_Cover],
    ''                                                                         [MC_4_Single_Cover_Premium],
    ''                                                                         [MC_4_Couple_Cover],
    ''                                                                         [MC_4_Couple_Cover_Premium],
    ''                                                                         [MC_4_Single_Family_Cover],
    ''                                                                         [MC_4_Single_Family_Cover_Premium],
    ''                                                                         [MC_4_Couple_Family_Cover],
    ''                                                                         [MC_4_Couple_Family_Cover_Premium],
    --==================================================
    --RISK DENTAL 1002
    --==================================================
    mc.CoverStart                                                              [Dental_EffectiveDate],
    mc.EmployeeCount                                                           [Dental_Number_of_Employees],
    CASE mc.DentalOption
        WHEN 0 THEN 0
        WHEN 1 THEN mc.EmployeeCount * 7.5
    END                                                                        [Dental_Dental_And_Optical_Pack],
    CASE mc.DentalOption
        WHEN 0 THEN 0
        WHEN 1 THEN mc.EmployeeCount * @Dental_Equipsme_Margin
    END                                                                        [Dental_Equipsme_Margin],
    CASE mc.DentalOption
        WHEN 0 THEN 0
        WHEN 1 THEN mc.EmployeeCount * @Dental_AXA_Margin
    END                                                                        [Dental_AXA_Margin],
    CASE mc.DentalOption
        WHEN 0 THEN 0
        WHEN 1 THEN mc.EmployeeCount * @Dental_Equipsme_Comm
    END                                                                        [Dental_Equipsme_Comm],
    CASE mc.DentalOption
        WHEN 0 THEN 0
        WHEN 1 THEN mc.EmployeeCount * @Dental_AXA_MARGIN_IPT
    END                                                                        [Dental_AXA_Margin_IPT],
    --==================================================
    --RISK SUPPORT 1003
    --==================================================
    mc.CoverStart                                                              [Support_EffectiveDate],
    mc.EmployeeCount                                                           [Support_Number_of_Employees],
    CASE mc.SupportOption
        WHEN 0 THEN 0
       WHEN 1 THEN mc.EmployeeCount * 1.5
    END                                                                        [Support_Pack],
    CASE mc.SupportOption
        WHEN 0 THEN 0
        WHEN 1 THEN mc.EmployeeCount * @Support_Equipsme_Margin
    END                                                                        [Support_Equipsme_Margin],
    CASE mc.SupportOption
        WHEN 0 THEN 0
        WHEN 1 THEN mc.EmployeeCount * @Support_Health_Assured
    END                                                                        [Support_Health_Assured],
    CASE mc.SupportOption
        WHEN 0 THEN 0
        WHEN 1 THEN mc.EmployeeCount * @Support_VAT
    END                                                                        [Support_VAT],
    CASE mc.SupportOption
        WHEN 0 THEN 0
        WHEN 1 THEN mc.EmployeeCount * @Support_Equipsme_Comm
    END                                                                        [Support_Equipsme_Comm],
    --==================================================
    --RISK Thriva 1007
    --==================================================
    (mc.Lev4Count * @Thriva_4) +
    (mc.Lev3Count * @Thriva_3) +
    (mc.Lev2Count * @Thriva_2) +
    (mc.Lev1Count * @Thriva_1)                                                 [Thriva_Premium],
    --==================================================
    --RISK Medical Solutions 1006
    --==================================================
    (mc.EmployeeCount * @Medical_Solutions)                                    [Medical_Solutions_Premium],
    --==================================================
    --RISK SME EMPLOYEE PACKAGE 1001
   --==================================================
    ep.CoverStart                                                              [SME_EmpPack_EffectiveDate],
    ep.QuoteId                                                                 [SME_EmpPack_Employee_Ref_Number],
    --ep.Reference                                                             [SME_EmpPack_Employee_Policy_Number],
       STUFF(RTRIM(ep.Reference),LEN(RTRIM(ep.Reference))-2,0,'-')             [SME_EmpPack_Employee_Policy_Number],
    ''                                                                         [SME_EmpPack_AXA_PPP_Policy_No],
    ep.Title                                                                   [SME_EmpPack_Title],
    ep.FirstName                                                               [SME_EmpPack_First_Name],
    ep.LastName                                                                [SME_EmpPack_Last_Name],
    ep.Position                                                                [SME_EmpPack_Position],
    ep.PositionOther                                                           [SME_EmpPack_Position_Other],
    ep.Gender                                                                  [SME_EmpPack_Sex],
    ep.DateOfBirth                                                             [SME_EmpPack_Date_Of_Birth],
    ep.EmailAddress                                                            [SME_EmpPack_Email_Address],
    ''                                                                         [SME_EmpPack_Premises],
    ISNULL(ep.AddressLine1,'')                                                 [SME_EmpPack_Home_Address_Line_1],
    ISNULL(ep.AddressLine2,'')                                                 [SME_EmpPack_Home_Address_Line_2],
    ISNULL(ep.AddressLine3,'')                                                 [SME_EmpPack_Home_Address_Line_3],
    ep.Town                                                                    [SME_EmpPack_Province],
    ep.PostalCode                                                              [SME_EmpPack_Area_Code],
    ep.EmployerLev                                                             [SME_EmpPack_SME_Level],
    ep.[Employer_Prem_Total]                                                   [SME_EmpPack_SME_Level_Premium],
    ep.[Employer_Prem_Equipsme_Margin]                                         [SME_EmpPack_Equipsme_Margin],
    ep.[Employer_Prem_AXA_Margin]                                              [SME_EmpPack_AXA_Margin],
    ep.[Employer_Prem_Equipsme_Comm]                                           [SME_EmpPack_Equipsme_Comm],
    ep.[Employer_Prem_AXA_Margin_IPT]                                          [SME_EmpPack_AXA_Margin_IPT],
    ''                                                                         [SME_EmpPack_SME_Cover_Status],
    ''                                                                         [SME_EmpPack_Beneficiaries],
    --==================================================
    --RISK BUY UP EMPLOYEE PACKAGE 1004
    --==================================================
    ep.CoverStart                                                              [BP_EmpPack_EffectiveDate],
    ep.Title                                                                   [BP_EmpPack_Title],
    ep.FirstName                                                               [BP_EmpPack_First_Name],
    ep.LastName                                                                [BP_EmpPack_Last_Name],
    ep.Position                                                                [BP_EmpPack_Position],
    ep.PositionOther                                                           [BP_EmpPack_Position_Other],
    ep.Gender                                                                  [BP_EmpPack_Sex],
    ep.DateOfBirth                                                             [BP_EmpPack_Date_Of_Birth],
    ep.EmailAddress                                                            [BP_EmpPack_Email_Address],
    ''                                                                         [BP_EmpPack_Premises],
    ISNULL(ep.AddressLine1 ,'')                                                [BP_EmpPack_Home_Address_Line_1],
    ISNULL(ep.AddressLine2,'')                                                 [BP_EmpPack_Home_Address_Line_2],
    ISNULL(ep.AddressLine3 ,'')                                                [BP_EmpPack_Home_Address_Line_3],
    ep.Town                                                                    [BP_EmpPack_Province],
    ep.PostalCode                                                              [BP_EmpPack_Area_Code],
    ep.CoverType                                                               [BP_EmpPack_SME_Level],
    ep.EmployeeLevel                                                           [BP_EmpPack_Optional_Level_Buy_Up],
    ''                                                                         [BP_EmpPack_SME_Cover_Status],
    ''                                                                         [BP_EmpPack_Optional_Cover_Status_Buy_Up],
    ''                                                                         [BP_EmpPack_Beneficiaries], -- This field is not required
    --Employee contributions (Employee Total - Company Contribution + Employee Beneficiary)
    (
        ep.[Employee_Prem_Total] -
        ep.[Employer_Prem_Total] +
        ep.[Dependent_Prem_Total]
    )
                                                                               [BP_EmpPack_Employee_Total_Premium],
    (
        ep.[Employee_Prem_Equipsme_Margin] -
        ep.[Employer_Prem_Equipsme_Margin] +
        ep.[Dependent_Prem_Equipsme_Margin]
    )                                                                          [BP_EmpPack_Employee_Equipsme_Margin],
    (
        ep.[Employee_Prem_AXA_Margin] -
        ep.[Employer_Prem_AXA_Margin] +
        ep.[Dependent_Prem_AXA_Margin]
    )                                                                          [BP_EmpPack_Employee_AXA_Margin],
    (
        ep.[Employee_Prem_Equipsme_Comm] -
        ep.[Employer_Prem_Equipsme_Comm] +
        ep.[Dependent_Prem_Equipsme_Comm]
    )                                                                          [BP_EmpPack_Employee_Equipsme_Comm],
    (
        ep.[Employee_Prem_AXA_Margin_IPT] -
        ep.[Employer_Prem_AXA_Margin_IPT] +
        ep.[Dependent_Prem_AXA_Margin_IPT]
    )                                                                          [BP_EmpPack_Employee_AXA_Margin_IPT],
    (
        ep.[Employee_Prem_Thriva] -
        ep.[Employer_Prem_Thriva] +
        ep.[Dependent_Prem_Thriva]
    )                                                                          [BP_EmpPack_Employee_Thriva],
    (
        ep.[Employee_Medical_Solutions] -
        ep.[Employer_Medical_Solutions] +
        ep.[Dependent_Prem_Medical_Solutions]
    )                                                                          [BP_EmpPack_Employee_Medical_Solutions],
    --==================================================
    --SYTEM FIELDS
    --==================================================
    --                                                                         [iID],  --changed to IDENTITY column
    -1                                                                         [iImportRecNo],
    GETDATE()                                                                  [dtProcessDate]
FROM MainCover mc
    JOIN EmployeePackage ep ON mc.iD = ep.ParentQuoteId

--======================================================================================================================
--               ***********                   BEGIN Customer Policy                      ************
--======================================================================================================================
;WITH PHCalc
AS (
    SELECT
        ROW_NUMBER() OVER(PARTITION BY PH_PolicyNumber ORDER BY PH_PolicyNumber) [Row],
        CH_RegistrationNumber,
        PH_PolicyNumber,
        RH_QuoteID,
            --Dental
        Dental_Dental_And_Optical_Pack,
        Dental_Equipsme_Margin,
        Dental_AXA_Margin,
        Dental_Equipsme_Comm,   
        [Dental_AXA_Margin_IPT],
            --support
        Support_Dental_And_Optical_Pack [Support_Pack],
        Support_Equipsme_Margin,
        Support_Health_Assured,
        Support_VAT,
        Support_Equipsme_Comm,
            --thriva
        Thriva_Premium,
            --medical solutions
        Medical_Solutions_Premium,
        SME_EmpPack_SME_Level_Premium,
        SME_EmpPack_Equipsme_Margin,
        SME_EmpPack_AXA_Margin,
        SME_EmpPack_Equipsme_Comm,   
        SME_EmpPack_AXA_Margin_IPT,

        BP_EmpPack_Employee_Equipsme_Margin,
        BP_EmpPack_Employee_AXA_Margin,
        BP_EmpPack_Employee_Equipsme_Comm,
        BP_EmpPack_Employee_AXA_Margin_IPT,
        BP_EmpPack_Employee_Thriva
    FROM [SKi_Equipsme_UAT].[ski_int].[ESME_Staging_Risk]
), PHCalcSum
AS (
    SELECT
        CH_RegistrationNumber,
        PH_PolicyNumber,
        RH_QuoteID,
           --Dental
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST(Dental_Equipsme_Margin AS FLOAT) END Dental_Equipsme_Margin,
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST(Dental_AXA_Margin AS FLOAT) END Dental_AXA_Margin,
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST(Dental_Equipsme_Comm AS FLOAT) END Dental_Equipsme_Comm,   
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST([Dental_AXA_Margin_IPT] AS FLOAT) END [Dental_AXA_Margin_IPT],
            --support
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST(Support_Equipsme_Margin AS FLOAT) END Support_Equipsme_Margin,
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST(Support_Health_Assured AS FLOAT) END Support_Health_Assured,
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST(Support_VAT AS FLOAT) END Support_VAT,
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST(Support_Equipsme_Comm AS FLOAT) END Support_Equipsme_Comm,
            --thriva
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST(Thriva_Premium AS FLOAT) END Thriva_Premium,
            --medical solutions
        CASE WHEN [Row] > 1 THEN 0 ELSE CAST(Medical_Solutions_Premium AS FLOAT) END Medical_Solutions_Premium,
        CAST(SME_EmpPack_Equipsme_Margin AS FLOAT) SME_EmpPack_Equipsme_Margin,
        CAST(SME_EmpPack_AXA_Margin AS FLOAT) SME_EmpPack_AXA_Margin,
        CAST(SME_EmpPack_Equipsme_Comm AS FLOAT) SME_EmpPack_Equipsme_Comm,   
        CAST(SME_EmpPack_AXA_Margin_IPT AS FLOAT) SME_EmpPack_AXA_Margin_IPT
    FROM PHCalc
), PHCalcTotal
AS (
    SELECT
        CH_RegistrationNumber,
        PH_PolicyNumber,
    --Vat
        SUM(Support_VAT)                                                       [VAT],
    --IPT (Admin Fee)
        SUM(Dental_AXA_Margin_IPT) +
        SUM(SME_EmpPack_AXA_Margin_IPT)                                        [IPT],
    --Premium
        SUM(Dental_Equipsme_Margin) +
        SUM(Dental_AXA_Margin) +
        SUM(Dental_Equipsme_Comm) +
        SUM(Support_Equipsme_Margin) +
        SUM(Support_Health_Assured) +
        SUM(Support_Equipsme_Comm) +
        SUM(Thriva_Premium) +
        SUM(Medical_Solutions_Premium) +
        SUM(SME_EmpPack_Equipsme_Margin) +
        SUM(SME_EmpPack_AXA_Margin) +
        SUM(SME_EmpPack_Equipsme_Comm)                                         [Premium]
    FROM
        PHCalcSum
    GROUP BY
        CH_RegistrationNumber,
        PH_PolicyNumber
), BuyUp
AS (
    SELECT 
        SME_EmpPack_Employee_Policy_Number,
        CAST(BP_EmpPack_Employee_AXA_Margin_IPT AS FLOAT)                      [IPT], 
        0                                                                      [VAT],
        CAST(BP_EmpPack_Employee_Equipsme_Margin AS FLOAT) +
        CAST(BP_EmpPack_Employee_AXA_Margin AS FLOAT) +
        CAST(BP_EmpPack_Employee_Equipsme_Comm AS FLOAT) + 
        CAST(BP_EmpPack_Employee_Thriva AS FLOAT)                              [Premium]
    FROM [SKi_Equipsme_UAT].[ski_int].[ESME_Staging_Risk]
)

INSERT INTO [SKi_Equipsme_UAT].[ski_int].[ESME_Staging_CustomerPolicy]
SELECT
    --==================================================
    --ALWAYS PROVIDE THESE FIELDS
    --==================================================
    q.QuoteNumber                                                              [CH_ExternalReference],
    1                                                                          [CH_CompanyInd],      
    235                                                                        [CH_CountryId],      
    2                                                                          [CH_Currency],     
    --==================================================
    --ALWAYS PROVIDE THESE FIELDS - CUSTOMER HEADER
    --==================================================
    c.Name                                                                     [CH_CompanyName],
    KeyContact.FirstName + ' ' + KeyContact.LastName                           [CH_ContactName],
    KeyContact.Initials                                                        [CH_Initials],
    KeyContact.FirstName                                                       [CH_FirstName],
    KeyContact.LastName                                                        [CH_LastName],
    1                                                                          [CH_PreferredCommsLanguage],
    --==================================================
    --CUSTOMER DETAILS
    --==================================================
    c.RegistrationNumber                                                       [CD_RegistrationNumber],
    c.[Type]                                                                   [CD_CompanyType],
    c.SICCode                                                                  [CD_SicCode],
    c.SICDescription                                                           [CD_SicDescription],
    c.MethodOfCommunication                                                    [CD_PreferredMethodOfCommunication],
    c.MethodOfCommunicationShort                                               [CD_PreferredMethodOfCommunicationShort],
    KeyContact.Title                                                           [CD_Title],
    ''                                                                         [CD_IDType],
    ''                                                                         [CD_IDNumber],
    ''                                                                         [CD_Nationality],
    ''                                                                         [CD_DOB],
    ''                                                                         [CD_Gender],
    KeyContact.EmailAddress                                                    [CD_EMailAddress],
    KeyContact.ContactNumber                                                   [CD_Cellnumber],
    CAddress.AddressLine1                                                      [CD_PhysicalAddressLine1],
    ISNULL(CAddress.AddressLine2,'')                                           [CD_PhysicalAddressLine2],
    ISNULL(CAddress.AddressLine3,'')                                           [CD_PhysicalAddressLine3],
    ISNULL(CAddress.Suburb,'')                                                 [CD_PhysicalAddressSuburb],
    ISNULL(CAddress.PostalCode,'')                                             [CD_PhysicalAddressPostalCode],
    CAddress.AddressLine1                                                      [CD_PostalAddressLine1],
    ISNULL(CAddress.AddressLine2,'')                                           [CD_PostalAddressLine2],
    ISNULL(CAddress.AddressLine3,'')                                           [CD_PostalAddressLine3],
    ISNULL(CAddress.Suburb,'')                                                 [CD_PostalAddressSuburb],
    ISNULL(CAddress.PostalCode,'')                                             [CD_PostalAddressPostalCode],
    KeyContact.Title                                                           [CD_KeyTitle],
    KeyContact.FirstName                                                       [CD_KeyFirstName],
    KeyContact.LastName                                                        [CD_KeyLastName],
    KeyContact.Position                                                        [CD_KeyPosition],
    KeyContact.EmailAddress                                                    [CD_KeyEMailAddress],
    KeyContact.ContactNumber                                                   [CD_KeyContactnumber],
    CASE
        WHEN KeyContact.FirstName = HRContact.FirstName
            AND KeyContact.LastName = HRContact.LastName
        THEN '1'
        ELSE '0'
    END                                                                        [CD_HRSameAsKeyContact],
    HRContact.Title                                                            [CD_HRTitle],
    HRContact.FirstName                                                        [CD_HRFirstName],
    HRContact.LastName                                                         [CD_HRLastName],
    HRContact.Position                                                         [CD_HRPosition],
    HRContact.EmailAddress                                                     [CD_HREMailAddress],
    HRContact.ContactNumber                                                    [CD_HRContactnumber],
    --==================================================
    --ALWAYS PROVIDE THESE FIELDS - POLICY HEADER
    --==================================================
    235                                                                        [PH_PolicyCountryId],
    q.Reference                                                                [PH_PolicyNumber],
    q.InitialQuoteDate                                                         [PH_CreatedDate],
    q.UpdateDate                                                               [PH_ModifiedDate],
    ''                                                                         [PH_CancelledDate],
    qd.CoverStart                                                              [PH_InceptionDate],
    qd.CoverStart                                                              [PH_CoverStartDate],
    DATEADD(DAY, -1, DATEADD(YEAR, 1, qd.CoverStart))                          [PH_CoverEndDate],
    DATEADD(YEAR, 1, qd.CoverStart)                                            [PH_RenewalDate],
    ''                                                                         [PH_LastPaymentDate],
    DATEADD(MONTH, 1, CoverStart)                                              [PH_NextPaymentDate],
    0                                                                          [PH_CoverTerm], --Annual
    3                                                                          [PH_PaymentTerm], --Monthly
    7                                                                          [PH_PaymentMethod], --direct debit
    DAY(qd.CoverStart)                                                         [PH_CollectionDay],
    CASE ISNULL(q.ParentQuoteID,0)
        WHEN 0 THEN PHCalcTotal.VAT 
        ELSE ISNULL(BuyUp.VAT,0)
    END                                                                        [PH_VAT],
    1                                                                          [PH_TAXPerc],
    0                                                                          [PH_PolicyFee],
    0                                                                          [PH_BrokerFee],
    CASE ISNULL(q.ParentQuoteID,0)
        WHEN 0 THEN PHCalcTotal.IPT 
        ELSE ISNULL(BuyUp.IPT,0)        
    END                                                                        [PH_AdminFee],
    CASE ISNULL(q.ParentQuoteID,0)
        WHEN 0 THEN PHCalcTotal.IPT 
        ELSE ISNULL(BuyUp.IPT,0)
    END                                                                        [PH_IPTFee], --IPT is stored in the AdminFee column
    --==================================================
    --POLICY DETAILS
    --==================================================
    ISNULL(q.ParentQuoteID,0)                                                  [PD_ParentQuoteID],
    q.Id                                                                       [PD_QuoteID],
    CASE ISNULL(q.ParentQuoteID,0)
        WHEN 0 THEN PHCalcTotal.Premium + PHCalcTotal.VAT + PHCalcTotal.IPT  
        ELSE BuyUp.Premium + BuyUp.IPT
    END                                                                        [PD_MonthlyPremium],
    2                                                                          [PD_EndorsementCode],  --new business = 2
    ''                                                                         [PD_CancellationReason],
    ''                                                                         [PD_AXANumber],
    qd.DentalOption                                                            [PD_DentalAndOptical],
    qd.SupportOption                                                           [PD_Support],
    --==================================================
    --SYTEM FIELDS
    --==================================================
    --                                                                         [iID], --changed to IDENTITY column
    -1                                                                         [iImportRecNo],
    GETDATE()                                                                  [dtProcessDate] 
FROM
    dbo.Company c
    JOIN dbo.Person KeyContact ON c.KeyContactPersonId = KeyContact.ID
    JOIN dbo.Person HRContact ON c.HrPersonId = HRContact.Id
    JOIN dbo.Address CAddress ON c.AddressId = CAddress.Id
    JOIN dbo.Quote q ON c.Id = q.CompanyId
    JOIN dbo.QuoteDetail qd ON q.Id = qd.Id
    JOIN dbo.QuoteStatusHistory qsh ON q.Id = qsh.QuoteId
    JOIN (
        SELECT QuoteId, MAX(Id) Id
        FROM QuoteStatusHistory
        GROUP BY QuoteId
        ) qshl ON qsh.QuoteId = qshl.QuoteId AND qsh.Id = qshl.Id
    LEFT JOIN PHCalcTotal ON q.Reference = PHCalcTotal.PH_PolicyNumber
    LEFT JOIN BuyUp on q.Reference = BuyUp.SME_EmpPack_Employee_Policy_Number
WHERE
    qsh.[Status] = 3
    AND q.ETLStatus = 0

--======================================================================================================================
--               ***********                   BEGIN Members                      ************
--======================================================================================================================
;
INSERT INTO [SKi_Equipsme_UAT].[ski_int].[ESME_Staging_Member]
SELECT
    --==================================================
    --RISK DETAILS
    --==================================================
    q.QuoteNumber                                                              [RH_ExternalReference],
    c.RegistrationNumber                                                       [CH_RegistrationNumber],   
    pq.Reference                                                               [PH_PolicyNumber],
    ISNULL(q.ParentQuoteId,0)                                                  [RH_ParentQuoteID],
    q.Id                                                                       [RH_QuoteID],
    --==================================================
    --RISK SME EMPLOYEE PACKAGE 1001
    --==================================================
    p.Id                                                                       [RD_Member_ID],
    ''                                                                         [RD_Member_EffectiveDate],
    q.QuoteNumber                                                              [RD_Employee_Ref_Number],
    q.Reference                                                                [RD_Member_Employee_Policy_Number],
    ''                                                                         [RD_Member_AXA_PPP_Policy_No],
    lTitle.[Value]                                                             [RD_Member_Title],
    ISNULL(p.FirstName,'')                                                     [RD_Member_First_Name],
    ISNULL(p.LastName,'')                                                      [RD_Member_Last_Name],
    lPosition.[Value]                                                          [RD_Member_Position],
    p.PositionOther                                                            [RD_Member_Position_Other],
    lGender.[Value]                                                            [RD_Member_Sex],
    ISNULL(p.DateOfBirth,'')                                                   [RD_Member_Date_Of_Birth],
    ISNULL(p.EmailAddress,'')                                                  [RD_Member_Email_Address],
    ''                                                                         [RD_Member_Premises],
    ISNULL(a.AddressLine1,'')                                                  [RD_Member_Home_Address_Line_1],
    ISNULL(a.AddressLine2,'')                                                  [RD_Member_Home_Address_Line_2],
    ISNULL(a.AddressLine3,'')                                                  [RD_Member_Home_Address_Line_3],
    ISNULL(a.Town,'')                                                          [RD_Member_Province],
    ISNULL(a.PostalCode,'')                                                    [RD_Member_Area_Code],
    --==================================================
    --SYTEM FIELDS
    --==================================================
--                                                                             [iID] --changed to IDENTITY column
-1                                                                             [iImportRecNo],
''                                                                             [dtProcessDate]
FROM
    dbo.Dependent d
    JOIN dbo.Person p ON d.PersonId = p.Id
    JOIN dbo.Address a ON p.AddressId = a.Id
    JOIN dbo.Quote q ON d.QuoteId = q.iD
    JOIN dbo.Quote pq on q.ParentQuoteId = pq.Id
    JOIN dbo.Company c ON c.Id = q.CompanyId
    JOIN dbo.Lookup lTitle ON p.Title = lTitle.EnumValue AND lTitle.GroupName = 'Title'
    JOIN dbo.Lookup lGender ON p.Gender = lGender.EnumValue AND lGender.GroupName = 'Gender'
    JOIN dbo.Lookup lPosition ON p.Position = lPosition.EnumValue AND lPosition.GroupName = 'Position'
    JOIN dbo.QuoteStatusHistory qsh ON q.Id = qsh.QuoteId
    JOIN (
        SELECT QuoteId, MAX(Id) Id
        FROM QuoteStatusHistory
        GROUP BY QuoteId
        ) qshl ON qsh.QuoteId = qshl.QuoteId AND qsh.Id = qshl.Id
    WHERE
        (q.ParentQuoteId IS NOT NULL)
        AND q.ETLStatus = 0;



INSERT INTO 
       [SKi_Equipsme_UAT].[ski_int].[ESME_Staging_BuyUp_Risk]
       (
              RH_ExternalReference
              ,CH_RegistrationNumber
              ,PH_PolicyNumber
              ,RH_ParentQuoteID
              ,RH_QuoteID
              ,MC_1_Number_of_Employees
              ,MC_1_Premium
              ,MC_2_Number_of_Employees
              ,MC_2_Premium
              ,MC_3_Number_of_Employees
              ,MC_3_Premium
              ,MC_4_Number_of_Employees
              ,MC_4_Premium
              ,MC_1_Single_Cover
              ,MC_1_Single_Cover_Premium
              ,MC_1_Couple_Cover
              ,MC_1_Couple_Cover_Premium
              ,MC_1_Single_Family_Cover
              ,MC_1_Single_Family_Cover_Premium
              ,MC_1_Couple_Family_Cover
              ,MC_1_Couple_Family_Cover_Premium
              ,MC_2_Single_Cover
              ,MC_2_Single_Cover_Premium
              ,MC_2_Couple_Cover
              ,MC_2_Couple_Cover_Premium
              ,MC_2_Single_Family_Cover
              ,MC_2_Single_Family_Cover_Premium
              ,MC_2_Couple_Family_Cover
              ,MC_2_Couple_Family_Cover_Premium
              ,MC_3_Single_Cover
              ,MC_3_Single_Cover_Premium
              ,MC_3_Couple_Cover
              ,MC_3_Couple_Cover_Premium
              ,MC_3_Single_Family_Cover
              ,MC_3_Single_Family_Cover_Premium
              ,MC_3_Couple_Family_Cover
              ,MC_3_Couple_Family_Cover_Premium
              ,MC_4_Single_Cover
              ,MC_4_Single_Cover_Premium
              ,MC_4_Couple_Cover
              ,MC_4_Couple_Cover_Premium
              ,MC_4_Single_Family_Cover
              ,MC_4_Single_Family_Cover_Premium
              ,MC_4_Couple_Family_Cover
              ,MC_4_Couple_Family_Cover_Premium
              ,Dental_EffectiveDate
              ,Dental_Number_of_Employees
              ,Dental_Dental_And_Optical_Pack
              ,Dental_Equipsme_Margin
              ,Dental_AXA_Margin
              ,Dental_Equipsme_Comm
              ,Dental_AXA_Margin_IPT
              ,Support_EffectiveDate
              ,Support_Number_of_Employees
              ,Support_Dental_And_Optical_Pack
              ,Support_Equipsme_Margin
              ,Support_Health_Assured
              ,Support_VAT
              ,Support_Equipsme_Comm
              ,Thriva_Premium
              ,Medical_Solutions_Premium
              ,SME_EmpPack_EffectiveDate
              ,SME_EmpPack_Employee_Ref_Number
              ,SME_EmpPack_Employee_Policy_Number
              ,SME_EmpPack_AXA_PPP_Policy_No
              ,SME_EmpPack_Title
              ,SME_EmpPack_First_Name
              ,SME_EmpPack_Last_Name
              ,SME_EmpPack_Position
              ,SME_EmpPack_Position_Other
              ,SME_EmpPack_Sex
              ,SME_EmpPack_Date_Of_Birth
              ,SME_EmpPack_Email_Address
              ,SME_EmpPack_Premises
              ,SME_EmpPack_Home_Address_Line_1
              ,SME_EmpPack_Home_Address_Line_2
              ,SME_EmpPack_Home_Address_Line_3
              ,SME_EmpPack_Province
              ,SME_EmpPack_Area_Code
              ,SME_EmpPack_SME_Level
              ,SME_EmpPack_SME_Level_Premium
              ,SME_EmpPack_Equipsme_Margin
              ,SME_EmpPack_AXA_Margin
              ,SME_EmpPack_Equipsme_Comm
              ,SME_EmpPack_AXA_Margin_IPT
              ,SME_EmpPack_SME_Cover_Status
              ,SME_EmpPack_Beneficiaries
              ,BP_EmpPack_EffectiveDate
              ,BP_EmpPack_Title
              ,BP_EmpPack_First_Name
              ,BP_EmpPack_Last_Name
              ,BP_EmpPack_Position
              ,BP_EmpPack_Position_Other
              ,BP_EmpPack_Sex
              ,BP_EmpPack_Date_Of_Birth
              ,BP_EmpPack_Email_Address
              ,BP_EmpPack_Premises
              ,BP_EmpPack_Home_Address_Line_1
              ,BP_EmpPack_Home_Address_Line_2
              ,BP_EmpPack_Home_Address_Line_3
              ,BP_EmpPack_Province
              ,BP_EmpPack_Area_Code
              ,BP_EmpPack_SME_Level
              ,BP_EmpPack_Optional_Level_Buy_Up
              ,BP_EmpPack_SME_Cover_Status
              ,BP_EmpPack_Optional_Cover_Status_Buy_Up
              ,BP_EmpPack_Beneficiaries
              ,BP_EmpPack_Employee_Total_Premium
              ,BP_EmpPack_Employee_Equipsme_Margin
              ,BP_EmpPack_Employee_AXA_Margin
              ,BP_EmpPack_Employee_Equipsme_Comm
              ,BP_EmpPack_Employee_AXA_Margin_IPT
              ,BP_EmpPack_Employee_Thriva
              ,BP_Emppack_Employee_Medical_Solutions
              ,iImportRecNo
              ,dtProcessDate
       )
SELECT
       RH_ExternalReference
       ,CH_RegistrationNumber
       ,PH_PolicyNumber
       ,RH_ParentQuoteID
       ,RH_QuoteID
       ,MC_1_Number_of_Employees
       ,MC_1_Premium
       ,MC_2_Number_of_Employees
       ,MC_2_Premium
       ,MC_3_Number_of_Employees
       ,MC_3_Premium
       ,MC_4_Number_of_Employees
       ,MC_4_Premium
       ,MC_1_Single_Cover
       ,MC_1_Single_Cover_Premium
       ,MC_1_Couple_Cover
       ,MC_1_Couple_Cover_Premium
       ,MC_1_Single_Family_Cover
       ,MC_1_Single_Family_Cover_Premium
       ,MC_1_Couple_Family_Cover
       ,MC_1_Couple_Family_Cover_Premium
       ,MC_2_Single_Cover
       ,MC_2_Single_Cover_Premium
       ,MC_2_Couple_Cover
       ,MC_2_Couple_Cover_Premium
       ,MC_2_Single_Family_Cover
       ,MC_2_Single_Family_Cover_Premium
       ,MC_2_Couple_Family_Cover
       ,MC_2_Couple_Family_Cover_Premium
       ,MC_3_Single_Cover
       ,MC_3_Single_Cover_Premium
       ,MC_3_Couple_Cover
       ,MC_3_Couple_Cover_Premium
       ,MC_3_Single_Family_Cover
       ,MC_3_Single_Family_Cover_Premium
       ,MC_3_Couple_Family_Cover
       ,MC_3_Couple_Family_Cover_Premium
       ,MC_4_Single_Cover
       ,MC_4_Single_Cover_Premium
       ,MC_4_Couple_Cover
       ,MC_4_Couple_Cover_Premium
       ,MC_4_Single_Family_Cover
       ,MC_4_Single_Family_Cover_Premium
       ,MC_4_Couple_Family_Cover
       ,MC_4_Couple_Family_Cover_Premium
       ,Dental_EffectiveDate
       ,Dental_Number_of_Employees
       ,Dental_Dental_And_Optical_Pack
       ,Dental_Equipsme_Margin
       ,Dental_AXA_Margin
       ,Dental_Equipsme_Comm
       ,Dental_AXA_Margin_IPT
       ,Support_EffectiveDate
       ,Support_Number_of_Employees
       ,Support_Dental_And_Optical_Pack
       ,Support_Equipsme_Margin
       ,Support_Health_Assured
       ,Support_VAT
       ,Support_Equipsme_Comm
       ,Thriva_Premium
       ,Medical_Solutions_Premium
       ,SME_EmpPack_EffectiveDate
       ,SME_EmpPack_Employee_Ref_Number
       ,SME_EmpPack_Employee_Policy_Number
       ,SME_EmpPack_AXA_PPP_Policy_No
       ,SME_EmpPack_Title
       ,SME_EmpPack_First_Name
       ,SME_EmpPack_Last_Name
       ,SME_EmpPack_Position
       ,SME_EmpPack_Position_Other
       ,SME_EmpPack_Sex
       ,SME_EmpPack_Date_Of_Birth
       ,SME_EmpPack_Email_Address
       ,SME_EmpPack_Premises
       ,SME_EmpPack_Home_Address_Line_1
       ,SME_EmpPack_Home_Address_Line_2
       ,SME_EmpPack_Home_Address_Line_3
       ,SME_EmpPack_Province
       ,SME_EmpPack_Area_Code
       ,SME_EmpPack_SME_Level
       ,SME_EmpPack_SME_Level_Premium
       ,SME_EmpPack_Equipsme_Margin
       ,SME_EmpPack_AXA_Margin
       ,SME_EmpPack_Equipsme_Comm
       ,SME_EmpPack_AXA_Margin_IPT
       ,SME_EmpPack_SME_Cover_Status
       ,SME_EmpPack_Beneficiaries
       ,BP_EmpPack_EffectiveDate
       ,BP_EmpPack_Title
       ,BP_EmpPack_First_Name
       ,BP_EmpPack_Last_Name
       ,BP_EmpPack_Position
       ,BP_EmpPack_Position_Other
       ,BP_EmpPack_Sex
       ,BP_EmpPack_Date_Of_Birth
       ,BP_EmpPack_Email_Address
       ,BP_EmpPack_Premises
       ,BP_EmpPack_Home_Address_Line_1
       ,BP_EmpPack_Home_Address_Line_2
       ,BP_EmpPack_Home_Address_Line_3
       ,BP_EmpPack_Province
       ,BP_EmpPack_Area_Code
       ,BP_EmpPack_SME_Level
       ,BP_EmpPack_Optional_Level_Buy_Up
       ,BP_EmpPack_SME_Cover_Status
       ,BP_EmpPack_Optional_Cover_Status_Buy_Up
       ,BP_EmpPack_Beneficiaries
       ,BP_EmpPack_Employee_Total_Premium
       ,BP_EmpPack_Employee_Equipsme_Margin
       ,BP_EmpPack_Employee_AXA_Margin
       ,BP_EmpPack_Employee_Equipsme_Comm
       ,BP_EmpPack_Employee_AXA_Margin_IPT
       ,BP_EmpPack_Employee_Thriva
       ,BP_Emppack_Employee_Medical_Solutions
       ,iImportRecNo
       ,dtProcessDate
FROM   
       [SKi_Equipsme_UAT].[ski_int].[ESME_Staging_Risk] S
WHERE
       ROUND(CAST(S.BP_EmpPack_Employee_Total_Premium AS decimal(18,2)), 2) <> 0.0;



--======================================================================================================================
--               ***********                   FLAG Records as imported                      ************
--======================================================================================================================

;UPDATE q
SET q.ETLStatus = 1
FROM
    dbo.Quote q
    JOIN dbo.QuoteStatusHistory qsh ON q.Id = qsh.QuoteId
    JOIN (
        SELECT QuoteId, MAX(Id) Id
        FROM QuoteStatusHistory
        GROUP BY QuoteId
        ) qshl ON qsh.QuoteId = qshl.QuoteId AND qsh.Id = qshl.Id
    WHERE
        qsh.[Status] = 3
        AND q.ETLStatus = 0
        AND EXISTS (SELECT NULL FROM [SKi_Equipsme_UAT].[ski_int].[ESME_Staging_CustomerPolicy] stage WHERE stage.CH_ExternalReference = q.QuoteNumber)
END

GO