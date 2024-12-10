report 50011 "Suggest Sales Price from Cost"
{
    // //ID461 Fazle, SCPLLP 20161206 10:00 AM
    //   - Suggest Sales Price on Wksht Based on Cost

    Caption = 'Suggest Sales Price from Cost';
    ProcessingOnly = true;

    dataset
    {
        dataitem(ItemRec; Item)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                if Item."No." <> "No." then begin
                    Item.Get("No.");
                    Window.Update(1, "No.");
                end;

                //ReplaceSalesCode := NOT (("Sales Type" = ToSalesType) AND ("Sales Code" = ToSalesCode));

                if (ToSalesCode = '') and (ToSalesType <> ToSalesType::"All Customers") then
                    Error(Text002, ToSalesType);

                Clear(SalesPriceWksh);

                SalesPriceWksh.Validate("Sales Type", ToSalesType);
                //IF NOT ReplaceSalesCode THEN
                //  SalesPriceWksh.VALIDATE("Sales Code","Sales Code")
                //ELSE
                SalesPriceWksh.Validate("Sales Code", ToSalesCode);

                SalesPriceWksh.Validate("Item No.", Item."No.");
                //SalesPriceWksh."New Unit Price" := "Unit Price";
                //SalesPriceWksh."Minimum Quantity" := "Minimum Quantity";
                SalesPriceWksh.Validate("Adj%", gdecAdjPercentage);
                SalesPriceWksh.Validate("Adj$", gdecAdjAmount);
                //IF NOT ReplaceUnitOfMeasure THEN
                //  SalesPriceWksh."Unit of Measure Code" := "Unit of Measure Code"
                //ELSE BEGIN
                SalesPriceWksh."Unit of Measure Code" := ToUnitOfMeasure.Code;
                if not (SalesPriceWksh."Unit of Measure Code" in ['', Item."Base Unit of Measure"]) then
                    if not ItemUnitOfMeasure.Get(Item."No.", SalesPriceWksh."Unit of Measure Code") then
                        CurrReport.Skip;
                SalesPriceWksh."New Unit Price" :=
                  SalesPriceWksh."New Unit Price" *
                  UOMMgt.GetQtyPerUnitOfMeasure(Item, SalesPriceWksh."Unit of Measure Code") /
                  UOMMgt.GetQtyPerUnitOfMeasure(Item, ItemUnitOfMeasure.Code);
                //END;
                SalesPriceWksh.Validate("Unit of Measure Code");
                //SalesPriceWksh.VALIDATE("Variant Code","Variant Code");

                //IF NOT ReplaceCurrency THEN
                //  SalesPriceWksh."Currency Code" := "Currency Code"
                //ELSE
                SalesPriceWksh."Currency Code" := ToCurrency.Code;

                //IF NOT ReplaceStartingDate THEN BEGIN
                //  IF NOT ReplaceEndingDate THEN
                //    SalesPriceWksh.VALIDATE("Starting Date","Starting Date")
                //END ELSE
                SalesPriceWksh.Validate("Starting Date", ToStartDate);

                //IF NOT ReplaceEndingDate THEN BEGIN
                //  IF NOT ReplaceStartingDate THEN
                //    SalesPriceWksh.VALIDATE("Ending Date","Ending Date")
                //END ELSE
                SalesPriceWksh.Validate("Ending Date", ToEndDate);

                //IF "Currency Code" <> SalesPriceWksh."Currency Code" THEN BEGIN
                //IF "Currency Code" <> '' THEN BEGIN
                //  FromCurrency.GET(SalesPriceWksh."Currency Code");
                //  FromCurrency.TESTFIELD(Code);
                //  SalesPriceWksh."New Unit Price" :=
                //    CurrExchRate.ExchangeAmtFCYToLCY(
                //      WORKDATE,SalesPriceWksh."Currency Code",SalesPriceWksh."New Unit Price",
                //      CurrExchRate.ExchangeRate(
                //        WORKDATE,SalesPriceWksh."Currency Code"));
                //END;
                if SalesPriceWksh."Currency Code" <> '' then
                    SalesPriceWksh."New Unit Price" :=
                      CurrExchRate.ExchangeAmtLCYToFCY(
                        WorkDate, SalesPriceWksh."Currency Code",
                        SalesPriceWksh."New Unit Price", CurrExchRate.ExchangeRate(
                          WorkDate, SalesPriceWksh."Currency Code"));
                //END;

                if SalesPriceWksh."Currency Code" = '' then
                    Currency2.InitRoundingPrecision
                else begin
                    Currency2.Get(SalesPriceWksh."Currency Code");
                    Currency2.TestField("Unit-Amount Rounding Precision");
                end;
                SalesPriceWksh."New Unit Price" :=
                  Round(SalesPriceWksh."New Unit Price", Currency2."Unit-Amount Rounding Precision");

                //IF SalesPriceWksh."New Unit Price" > PriceLowerLimit THEN
                //  SalesPriceWksh."New Unit Price" := SalesPriceWksh."New Unit Price" * UnitPriceFactor;
                if RoundingMethod.Code <> '' then begin
                    RoundingMethod."Minimum Amount" := SalesPriceWksh."New Unit Price";
                    if RoundingMethod.Find('=<') then begin
                        SalesPriceWksh."New Unit Price" :=
                          SalesPriceWksh."New Unit Price" + RoundingMethod."Amount Added Before";
                        if RoundingMethod.Precision > 0 then
                            SalesPriceWksh."New Unit Price" :=
                              Round(
                                SalesPriceWksh."New Unit Price",
                                RoundingMethod.Precision, CopyStr('=><', RoundingMethod.Type + 1, 1));
                        SalesPriceWksh."New Unit Price" := SalesPriceWksh."New Unit Price" +
                          RoundingMethod."Amount Added After";
                    end;
                end;

                SalesPriceWksh."Price Includes VAT" := "Price Includes VAT";
                SalesPriceWksh."VAT Bus. Posting Gr. (Price)" := "VAT Bus. Posting Gr. (Price)";
                //SalesPriceWksh."Allow Invoice Disc." := "Allow Invoice Disc.";
                //SalesPriceWksh."Allow Line Disc." := "Allow Line Disc.";
                SalesPriceWksh.CalcCurrentPrice(PriceAlreadyExists);

                if PriceAlreadyExists or CreateNewPrices then begin
                    SalesPriceWksh2 := SalesPriceWksh;
                    if SalesPriceWksh2.Find('=') then
                        SalesPriceWksh.Modify(true)
                    else
                        SalesPriceWksh.Insert(true);
                end;

                SalesPriceWksh.Validate("Item No.", Item."No.");
            end;

            trigger OnPreDataItem()
            begin
                Window.Open(Text001);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group("Copy to Sales Price Worksheet...")
                    {
                        Caption = 'Copy to Sales Price Worksheet...';
                        field(SalesType; ToSalesType)
                        {
                            Caption = 'Sales Type';
                            OptionCaption = 'Customer,Customer Price Group,All Customers,Campaign';
                            ApplicationArea = All;

                            trigger OnValidate()
                            begin
                                SalesCodeCtrlEnable := ToSalesType <> ToSalesType::"All Customers";
                                ToStartDateCtrlEnable := ToSalesType <> ToSalesType::Campaign;
                                ToEndDateCtrlEnable := ToSalesType <> ToSalesType::Campaign;

                                ToSalesCode := '';
                                ToStartDate := 0D;
                                ToEndDate := 0D;
                            end;
                        }
                        field(SalesCodeCtrl; ToSalesCode)
                        {
                            Caption = 'Sales Code';
                            Enabled = SalesCodeCtrlEnable;
                            ApplicationArea = All;

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                CustList: Page "Customer List";
                                CustPriceGrList: Page "Customer Price Groups";
                                CampaignList: Page "Campaign List";
                            begin
                                case ToSalesType of
                                    ToSalesType::Customer:
                                        begin
                                            CustList.LookupMode := true;
                                            CustList.SetRecord(ToCust);
                                            if CustList.RunModal = ACTION::LookupOK then begin
                                                CustList.GetRecord(ToCust);
                                                ToSalesCode := ToCust."No.";
                                            end;
                                        end;
                                    ToSalesType::"Customer Price Group":
                                        begin
                                            CustPriceGrList.LookupMode := true;
                                            CustPriceGrList.SetRecord(ToCustPriceGr);
                                            if CustPriceGrList.RunModal = ACTION::LookupOK then begin
                                                CustPriceGrList.GetRecord(ToCustPriceGr);
                                                ToSalesCode := ToCustPriceGr.Code;
                                            end;
                                        end;
                                    ToSalesType::Campaign:
                                        begin
                                            CampaignList.LookupMode := true;
                                            CampaignList.SetRecord(ToCampaign);
                                            if CampaignList.RunModal = ACTION::LookupOK then begin
                                                CampaignList.GetRecord(ToCampaign);
                                                ToSalesCode := ToCampaign."No.";
                                                ToStartDate := ToCampaign."Starting Date";
                                                ToEndDate := ToCampaign."Ending Date";
                                            end;
                                        end;
                                end;
                            end;

                            trigger OnValidate()
                            var
                                Customer: Record Customer;
                                CustomerPriceGroup: Record "Customer Price Group";
                                Campaign: Record Campaign;
                            begin
                                if ToSalesType = ToSalesType::"All Customers" then
                                    exit;

                                case ToSalesType of
                                    ToSalesType::Customer:
                                        Customer.Get(ToSalesCode);
                                    ToSalesType::"Customer Price Group":
                                        CustomerPriceGroup.Get(ToSalesCode);
                                    ToSalesType::Campaign:
                                        begin
                                            Campaign.Get(ToSalesCode);
                                            ToStartDate := Campaign."Starting Date";
                                            ToEndDate := Campaign."Ending Date";
                                        end;
                                end;
                            end;
                        }
                        field(UnitOfMeasureCode; ToUnitOfMeasure.Code)
                        {
                            Caption = 'Unit of Measure Code';
                            TableRelation = "Unit of Measure";
                            ApplicationArea = All;

                            trigger OnValidate()
                            begin
                                if ToUnitOfMeasure.Code <> '' then
                                    ToUnitOfMeasure.Find;
                            end;
                        }
                        field(CurrencyCode; ToCurrency.Code)
                        {
                            Caption = 'Currency Code';
                            TableRelation = Currency;
                            ApplicationArea = All;

                            trigger OnValidate()
                            begin
                                if ToCurrency.Code <> '' then
                                    ToCurrency.Find;
                            end;
                        }
                        field(ToStartDateCtrl; ToStartDate)
                        {
                            Caption = 'Starting Date';
                            Enabled = ToStartDateCtrlEnable;
                            ApplicationArea = All;
                        }
                        field(ToEndDateCtrl; ToEndDate)
                        {
                            Caption = 'Ending Date';
                            Enabled = ToEndDateCtrlEnable;
                            ApplicationArea = All;
                        }
                    }
                    field(OnlyPricesAbove; PriceLowerLimit)
                    {
                        Caption = 'Only Prices Above';
                        DecimalPlaces = 2 : 5;
                        ApplicationArea = All;
                    }
                    field(AdjustmentFactor; UnitPriceFactor)
                    {
                        Caption = 'Adjustment Factor';
                        DecimalPlaces = 0 : 5;
                        MinValue = 0;
                        Visible = false;
                        ApplicationArea = All;
                    }
                    field(RoundingMethodCtrl; RoundingMethod.Code)
                    {
                        Caption = 'Rounding Method';
                        TableRelation = "Rounding Method";
                        ApplicationArea = All;
                    }
                    field(CreateNewPrices; CreateNewPrices)
                    {
                        Caption = 'Create New Prices';
                        ApplicationArea = All;
                    }
                    field(gdecAdjPercentage; gdecAdjPercentage)
                    {
                        Caption = 'Adjustment %';
                        ApplicationArea = All;
                    }
                    field(gdecAdjAmount; gdecAdjAmount)
                    {
                        Caption = 'Adjustment $';
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            ToEndDateCtrlEnable := true;
            ToStartDateCtrlEnable := true;
            SalesCodeCtrlEnable := true;
        end;

        trigger OnOpenPage()
        begin
            if UnitPriceFactor = 0 then begin
                UnitPriceFactor := 1;
                ToCustPriceGr.Code := '';
                ToUnitOfMeasure.Code := '';
                ToCurrency.Code := '';
            end;

            SalesCodeCtrlEnable := true;
            if ToSalesType = ToSalesType::"All Customers" then
                SalesCodeCtrlEnable := false;

            SalesCodeCtrlEnable := ToSalesType <> ToSalesType::"All Customers";
            ToStartDateCtrlEnable := ToSalesType <> ToSalesType::Campaign;
            ToEndDateCtrlEnable := ToSalesType <> ToSalesType::Campaign;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        case ToSalesType of
            ToSalesType::Customer:
                begin
                    ToCust."No." := ToSalesCode;
                    if ToCust."No." <> '' then
                        ToCust.Find
                    else begin
                        if not ToCust.Find then
                            ToCust.Init;
                        ToSalesCode := ToCust."No.";
                    end;
                end;
            ToSalesType::"Customer Price Group":
                begin
                    ToCustPriceGr.Code := ToSalesCode;
                    if ToCustPriceGr.Code <> '' then
                        ToCustPriceGr.Find
                    else begin
                        if not ToCustPriceGr.Find then
                            ToCustPriceGr.Init;
                        ToSalesCode := ToCustPriceGr.Code;
                    end;
                end;
            ToSalesType::Campaign:
                begin
                    ToCampaign."No." := ToSalesCode;
                    if ToCampaign."No." <> '' then
                        ToCampaign.Find
                    else begin
                        if not ToCampaign.Find then
                            ToCampaign.Init;
                        ToSalesCode := ToCampaign."No.";
                    end;
                    ToStartDate := ToCampaign."Starting Date";
                    ToEndDate := ToCampaign."Ending Date";
                end;
        end;

        ReplaceUnitOfMeasure := ToUnitOfMeasure.Code <> '';
        ReplaceCurrency := ToCurrency.Code <> '';
        ReplaceStartingDate := ToStartDate <> 0D;
        ReplaceEndingDate := ToEndDate <> 0D;

        if ReplaceUnitOfMeasure and (ToUnitOfMeasure.Code <> '') then
            ToUnitOfMeasure.Find;

        RoundingMethod.SetRange(Code, RoundingMethod.Code);
    end;

    var
        Text001: Label 'Processing items  #1##########';
        SalesPriceWksh2: Record "Sales Price Worksheet";
        SalesPriceWksh: Record "Sales Price Worksheet";
        ToCust: Record Customer;
        ToCustPriceGr: Record "Customer Price Group";
        ToCampaign: Record Campaign;
        ToUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ToCurrency: Record Currency;
        FromCurrency: Record Currency;
        Currency2: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        RoundingMethod: Record "Rounding Method";
        Item: Record Item;
        UOMMgt: Codeunit "Unit of Measure Management";
        Window: Dialog;
        PriceAlreadyExists: Boolean;
        CreateNewPrices: Boolean;
        UnitPriceFactor: Decimal;
        PriceLowerLimit: Decimal;
        ToSalesType: Option Customer,"Customer Price Group","All Customers",Campaign;
        ToSalesCode: Code[20];
        ToStartDate: Date;
        ToEndDate: Date;
        ReplaceSalesCode: Boolean;
        ReplaceUnitOfMeasure: Boolean;
        ReplaceCurrency: Boolean;
        ReplaceStartingDate: Boolean;
        ReplaceEndingDate: Boolean;
        Text002: Label 'Sales Code must be specified when copying from %1 to All Customers.';
        [InDataSet]
        SalesCodeCtrlEnable: Boolean;
        [InDataSet]
        ToStartDateCtrlEnable: Boolean;
        [InDataSet]
        ToEndDateCtrlEnable: Boolean;
        gdecAdjPercentage: Decimal;
        gdecAdjAmount: Decimal;

    //[Scope('Internal')]
    local procedure InitializeRequest(NewToSalesType: Option Customer,"Customer Price Group",Campaign,"All CUstomers"; NewToSalesCode: Code[20]; NewToStartDate: Date; NewToEndDate: Date; NewToCurrCode: Code[10]; NewToUOMCode: Code[10]; NewCreateNewPrices: Boolean)
    begin
        ToSalesType := NewToSalesType;
        ToSalesCode := NewToSalesCode;
        ToStartDate := NewToStartDate;
        ToEndDate := NewToEndDate;
        ToCurrency.Code := NewToCurrCode;
        ToUnitOfMeasure.Code := NewToUOMCode;
        CreateNewPrices := NewCreateNewPrices;
    end;

    //[Scope('Internal')]
    local procedure InitializeRequest2(NewToSalesType: Option Customer,"Customer Price Group",Campaign,"All CUstomers"; NewToSalesCode: Code[20]; NewToStartDate: Date; NewToEndDate: Date; NewToCurrCode: Code[10]; NewToUOMCode: Code[10]; NewCreateNewPrices: Boolean; NewPriceLowerLimit: Decimal; NewUnitPriceFactor: Decimal; NewRoundingMethodCode: Code[10])
    begin
        InitializeRequest(NewToSalesType, NewToSalesCode, NewToStartDate, NewToEndDate, NewToCurrCode, NewToUOMCode, NewCreateNewPrices);
        PriceLowerLimit := NewPriceLowerLimit;
        UnitPriceFactor := NewUnitPriceFactor;
        RoundingMethod.Code := NewRoundingMethodCode;
    end;
}

