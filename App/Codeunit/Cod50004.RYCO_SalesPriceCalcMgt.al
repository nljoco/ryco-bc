codeunit 50004 "Ryco Sales Price Calc. Mgt."
{
    /*
    Note: extension of Codeunit 905 Assembly Line Management
    */
    trigger OnRun()
    begin
    end;

    var
        cuSalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        recItem: Record Item;
        TempSalesPrice: Record "Sales Price" temporary;
        PricesInCurrency: Boolean;
        Currency: Record Currency;
        CurrencyFactor: Decimal;
        ExchRateDate: Date;
        GLSetup: Record "General Ledger Setup";
        PricesInclVAT: Boolean;
        VATPerCent: Decimal;
        VATCalcType: Option "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        VATBusPostingGr: Code[20];
        Qty: Decimal;
        QtyPerUOM: Decimal;
        LineDiscPerCent: Decimal;
        AllowLineDisc: Boolean;
        AllowInvDisc: Boolean;
        FoundSalesPrice: Boolean;
        DateCaption: Text[30];

    procedure CalcBestUnitPriceShipTo(VAR SalesPrice: Record "Sales Price"; CustNo: Code[20]; ShipTo: Code[10])
    var
        BestSalesPrice: Record "Sales Price";
    begin
        //<change rpd05>
        //WITH SalesPrice DO BEGIN
        SalesPrice.SETRANGE("Sales Type", SalesPrice."Sales Type"::Customer);
        SalesPrice.SETRANGE("Sales Code", CustNo);
        //SETRANGE("Ship-to Address Code",ShipTo);
        FoundSalesPrice := SalesPrice.FIND('-');
        IF FoundSalesPrice THEN
            REPEAT
                IF IsInMinQty(SalesPrice."Unit of Measure Code", SalesPrice."Minimum Quantity") THEN BEGIN
                    ConvertPriceToVAT(
                      SalesPrice."Price Includes VAT", recItem."VAT Prod. Posting Group",
                      SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Unit Price");
                    ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Unit Price");
                    ConvertPriceLCYToFCY(SalesPrice."Currency Code", SalesPrice."Unit Price");

                    CASE TRUE OF
                        ((BestSalesPrice."Currency Code" = '') AND (SalesPrice."Currency Code" <> '')) OR
                      ((BestSalesPrice."Variant Code" = '') AND (SalesPrice."Variant Code" <> '')):
                            BestSalesPrice := SalesPrice;
                        ((BestSalesPrice."Currency Code" = '') OR (SalesPrice."Currency Code" <> '')) AND
                      ((BestSalesPrice."Variant Code" = '') OR (SalesPrice."Variant Code" <> '')):
                            IF (BestSalesPrice."Unit Price" = 0) OR
                               (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                            THEN
                                BestSalesPrice := SalesPrice;
                    END;
                END;
            UNTIL SalesPrice.NEXT = 0;
        //END;

        // No price found in agreement
        IF BestSalesPrice."Unit Price" <> 0 THEN
            SalesPrice := BestSalesPrice;
        //</change>
    end;

    procedure CalcBestUnitPriceCustomer(VAR SalesPrice: Record "Sales Price"; CustNo: Code[20])
    var
        BestSalesPrice: Record "Sales Price";
    begin
        //WITH SalesPrice DO BEGIN
        //CUSTOMER
        //SETRANGE("Ship-to Address Code");
        SalesPrice.SETRANGE("Sales Type", SalesPrice."Sales Type"::Customer);
        SalesPrice.SETRANGE("Sales Code", CustNo);
        //2007.01.24, late in the day... may not need next line
        //SETRANGE("Ship-to Address Code",'');
        FoundSalesPrice := SalesPrice.FIND('-');
        //MESSAGE(GETFILTERS);
        IF FoundSalesPrice THEN BEGIN
            REPEAT
                IF IsInMinQty(SalesPrice."Unit of Measure Code", SalesPrice."Minimum Quantity") THEN BEGIN
                    ConvertPriceToVAT(
                      SalesPrice."Price Includes VAT", recItem."VAT Prod. Posting Group",
                      SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Unit Price");
                    ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Unit Price");
                    ConvertPriceLCYToFCY(SalesPrice."Currency Code", SalesPrice."Unit Price");

                    CASE TRUE OF
                        ((BestSalesPrice."Currency Code" = '') AND (SalesPrice."Currency Code" <> '')) OR
                      ((BestSalesPrice."Variant Code" = '') AND (SalesPrice."Variant Code" <> '')):
                            BestSalesPrice := SalesPrice;
                        ((BestSalesPrice."Currency Code" = '') OR (SalesPrice."Currency Code" <> '')) AND
                      ((BestSalesPrice."Variant Code" = '') OR (SalesPrice."Variant Code" <> '')):
                            IF (BestSalesPrice."Unit Price" = 0) OR
                               (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                            THEN
                                BestSalesPrice := SalesPrice;
                    END;
                END;
            UNTIL SalesPrice.NEXT = 0;
        END
        ELSE BEGIN
            //CUSTOMER PRICE GROUP
            SalesPrice.SETRANGE("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
            SalesPrice.SETRANGE("Sales Code");
            FoundSalesPrice := SalesPrice.FIND('-');
            IF FoundSalesPrice THEN BEGIN
                REPEAT
                    IF IsInMinQty(SalesPrice."Unit of Measure Code", SalesPrice."Minimum Quantity") THEN BEGIN
                        ConvertPriceToVAT(
                          SalesPrice."Price Includes VAT", recItem."VAT Prod. Posting Group",
                          SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Unit Price");
                        ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Unit Price");
                        ConvertPriceLCYToFCY(SalesPrice."Currency Code", SalesPrice."Unit Price");

                        CASE TRUE OF
                            ((BestSalesPrice."Currency Code" = '') AND (SalesPrice."Currency Code" <> '')) OR
                          ((BestSalesPrice."Variant Code" = '') AND (SalesPrice."Variant Code" <> '')):
                                BestSalesPrice := SalesPrice;
                            ((BestSalesPrice."Currency Code" = '') OR (SalesPrice."Currency Code" <> '')) AND
                          ((BestSalesPrice."Variant Code" = '') OR (SalesPrice."Variant Code" <> '')):
                                IF (BestSalesPrice."Unit Price" = 0) OR
                                   (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                                THEN
                                    BestSalesPrice := SalesPrice;
                        END;
                    END;
                UNTIL SalesPrice.NEXT = 0;
            END ELSE BEGIN
                //ALL CUSTOMERS
                SalesPrice.SETRANGE("Sales Type", SalesPrice."Sales Type"::"All Customers");
                SalesPrice.SETRANGE("Sales Code");
                FoundSalesPrice := SalesPrice.FIND('-');
                IF FoundSalesPrice THEN BEGIN
                    REPEAT
                        IF IsInMinQty(SalesPrice."Unit of Measure Code", SalesPrice."Minimum Quantity") THEN BEGIN
                            ConvertPriceToVAT(
                              SalesPrice."Price Includes VAT", recItem."VAT Prod. Posting Group",
                              SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Unit Price");
                            ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Unit Price");
                            ConvertPriceLCYToFCY(SalesPrice."Currency Code", SalesPrice."Unit Price");

                            CASE TRUE OF
                                ((BestSalesPrice."Currency Code" = '') AND (SalesPrice."Currency Code" <> '')) OR
                              ((BestSalesPrice."Variant Code" = '') AND (SalesPrice."Variant Code" <> '')):
                                    BestSalesPrice := SalesPrice;
                                ((BestSalesPrice."Currency Code" = '') OR (SalesPrice."Currency Code" <> '')) AND
                              ((BestSalesPrice."Variant Code" = '') OR (SalesPrice."Variant Code" <> '')):
                                    IF (BestSalesPrice."Unit Price" = 0) OR
                                       (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                                    THEN
                                        BestSalesPrice := SalesPrice;
                            END;
                        END;
                    UNTIL SalesPrice.NEXT = 0;
                END;
            END;
        END;
        //END;

        IF BestSalesPrice."Unit Price" <> 0 THEN
            SalesPrice := BestSalesPrice;
    end;

    procedure FindSalesLinePriceSelling(SalesHeader: Record "Sales Header"; VAR SalesLine: Record "Sales Line")
    var
    begin
        //WITH SalesLine DO BEGIN
        SetCurrency(
          SalesHeader."Currency Code", SalesHeader."Currency Factor", cuSalesPriceCalcMgt.SalesHeaderExchDate(SalesHeader));
        SetVAT(SalesHeader."Prices Including VAT", SalesLine."VAT %", SalesLine."VAT Calculation Type", SalesLine."VAT Bus. Posting Group");
        SetUoM(ABS(SalesLine.Quantity), SalesLine."Qty. per Unit of Measure");
        SetLineDisc(SalesLine."Line Discount %", SalesLine."Allow Line Disc.", SalesLine."Allow Invoice Disc.");

        SalesLine.TESTFIELD("Qty. per Unit of Measure");
        IF PricesInCurrency THEN
            SalesHeader.TESTFIELD("Currency Factor");

        CASE SalesLine.Type OF
            SalesLine.Type::Item:
                BEGIN
                    recItem.GET(SalesLine."No.");
                    //SalesLinePriceExists(SalesHeader,SalesLine,FALSE);
                    SalesLinePriceExistsSelling(SalesHeader, SalesLine, FALSE);

                    IF (SalesHeader."Sell-to Customer No." <> '') THEN BEGIN
                        CalcBestUnitPriceCustomer(TempSalesPrice, SalesHeader."Sell-to Customer No.");
                        IF NOT (FoundSalesPrice) THEN
                            CalcBestUnitPrice(TempSalesPrice);
                    END ELSE
                        CalcBestUnitPrice(TempSalesPrice);
                    SalesLine."Selling Unit Price" := TempSalesPrice."Unit Price";
                END;
            SalesLine.Type::Resource:
                BEGIN
                END;
        END;
        //END;

    end;

    procedure SalesLinePriceExistsSelling(SalesHeader: Record "Sales Header"; VAR SalesLine: Record "Sales Line"; ShowAll: Boolean): Boolean
    var

    begin
        //WITH SalesLine DO
        IF (SalesLine.Type = SalesLine.Type::Item) AND recItem.GET(SalesLine."No.") THEN BEGIN
            cuSalesPriceCalcMgt.FindSalesPrice(
            TempSalesPrice, SalesLine."Bill-to Customer No.", SalesHeader."Bill-to Contact No.",
            SalesLine."Customer Price Group", '', SalesLine."No.", SalesLine."Variant Code", SalesLine."Selling Unit of Measure",
            SalesHeader."Currency Code", SalesHeaderStartDate(SalesHeader, DateCaption), ShowAll);
            EXIT(TempSalesPrice.FINDFIRST);
            //END;
            EXIT(FALSE);

        end;
    end;

    procedure CalcBestUnitPrice(VAR SalesPrice: Record "Sales Price")
    var
        BestSalesPrice: Record "Sales Price";
    begin
        //WITH SalesPrice DO BEGIN
        FoundSalesPrice := SalesPrice.FINDSET;
        IF FoundSalesPrice THEN
            REPEAT
                IF IsInMinQty(SalesPrice."Unit of Measure Code", SalesPrice."Minimum Quantity") THEN BEGIN
                    ConvertPriceToVAT(
                      SalesPrice."Price Includes VAT", recItem."VAT Prod. Posting Group",
                      SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Unit Price");
                    ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Unit Price");
                    ConvertPriceLCYToFCY(SalesPrice."Currency Code", SalesPrice."Unit Price");

                    CASE TRUE OF
                        ((BestSalesPrice."Currency Code" = '') AND (SalesPrice."Currency Code" <> '')) OR
                      ((BestSalesPrice."Variant Code" = '') AND (SalesPrice."Variant Code" <> '')):
                            BestSalesPrice := SalesPrice;
                        ((BestSalesPrice."Currency Code" = '') OR (SalesPrice."Currency Code" <> '')) AND
                      ((BestSalesPrice."Variant Code" = '') OR (SalesPrice."Variant Code" <> '')):
                            IF (BestSalesPrice."Unit Price" = 0) OR
                               (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                            THEN
                                BestSalesPrice := SalesPrice;
                    END;
                END;
            UNTIL SalesPrice.NEXT = 0;
        //END;

        // No price found in agreement
        IF BestSalesPrice."Unit Price" = 0 THEN BEGIN
            ConvertPriceToVAT(
              recItem."Price Includes VAT", recItem."VAT Prod. Posting Group",
              recItem."VAT Bus. Posting Gr. (Price)", recItem."Unit Price");
            ConvertPriceToUoM('', recItem."Unit Price");
            ConvertPriceLCYToFCY('', recItem."Unit Price");

            CLEAR(BestSalesPrice);
            BestSalesPrice."Unit Price" := recItem."Unit Price";
            BestSalesPrice."Allow Line Disc." := AllowLineDisc;
            BestSalesPrice."Allow Invoice Disc." := AllowInvDisc;
        END;

        SalesPrice := BestSalesPrice;
    end;

    local procedure SetCurrency(CurrencyCode2: Code[10]; CurrencyFactor2: Decimal; ExchRateDate2: Date)
    var
    begin
        PricesInCurrency := CurrencyCode2 <> '';
        IF PricesInCurrency THEN BEGIN
            Currency.GET(CurrencyCode2);
            Currency.TESTFIELD("Unit-Amount Rounding Precision");
            CurrencyFactor := CurrencyFactor2;
            ExchRateDate := ExchRateDate2;
        END ELSE
            GLSetup.GET;
    end;

    local procedure SetVAT(PriceInclVAT2: Boolean; VATPerCent2: Decimal; VATCalcType2: Option; VATBusPostingGr2: Code[20])
    var
    begin
        PricesInclVAT := PriceInclVAT2;
        VATPerCent := VATPerCent2;
        VATCalcType := VATCalcType2;
        VATBusPostingGr := VATBusPostingGr2;
    end;

    local procedure SetUoM(Qty2: Decimal; QtyPerUoM2: Decimal)
    var
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    local procedure SetLineDisc(LineDiscPerCent2: Decimal; AllowLineDisc2: Boolean; AllowInvDisc2: Boolean)
    var
    begin
        LineDiscPerCent := LineDiscPerCent2;
        AllowLineDisc := AllowLineDisc2;
        AllowInvDisc := AllowInvDisc2;
    end;

    local procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean
    var
    begin
        IF UnitofMeasureCode = '' THEN
            EXIT(MinQty <= QtyPerUOM * Qty);
        EXIT(MinQty <= Qty);
    end;

    local procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATProdPostingGr: Code[20]; FromVATBusPostingGr: Code[20]; VAR UnitPrice: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Text010: Label 'Prices including Tax cannot be calculated when %1 is %2.';

    begin
        IF FromPricesInclVAT THEN BEGIN
            VATPostingSetup.GET(FromVATBusPostingGr, FromVATProdPostingGr);

            CASE VATPostingSetup."VAT Calculation Type" OF
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATPostingSetup."VAT %" := 0;
                VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                    ERROR(
                      Text010,
                      VATPostingSetup.FIELDCAPTION("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            END;

            CASE VATCalcType OF
                VATCalcType::"Normal VAT",
                VATCalcType::"Full VAT",
                VATCalcType::"Sales Tax":
                    BEGIN
                        IF PricesInclVAT THEN BEGIN
                            IF VATBusPostingGr <> FromVATBusPostingGr THEN
                                UnitPrice := UnitPrice * (100 + VATPerCent) / (100 + VATPostingSetup."VAT %");
                        END ELSE
                            UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
                    END;
                VATCalcType::"Reverse Charge VAT":
                    UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
            END;
        END ELSE
            IF PricesInclVAT THEN
                UnitPrice := UnitPrice * (1 + VATPerCent / 100);
    end;

    local procedure SalesHeaderStartDate(SalesHeader: Record "Sales Header"; VAR DateCaption: Text[30]): Date
    var
    begin
        //WITH SalesHeader DO
        IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"] THEN BEGIN
            DateCaption := SalesHeader.FIELDCAPTION("Posting Date");
            EXIT(SalesHeader."Posting Date")
        END ELSE BEGIN
            DateCaption := SalesHeader.FIELDCAPTION("Order Date");
            EXIT(SalesHeader."Order Date");
        END;
    end;

    local procedure ConvertPriceToUoM(UnitOfMeasureCode: Code[10]; VAR UnitPrice: Decimal)
    var
    begin
        IF UnitOfMeasureCode = '' THEN
            UnitPrice := UnitPrice * QtyPerUOM;
    end;

    local procedure ConvertPriceLCYToFCY(CurrencyCode: Code[10]; VAR UnitPrice: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        IF PricesInCurrency THEN BEGIN
            IF CurrencyCode = '' THEN
                UnitPrice :=
                  CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate, Currency.Code, UnitPrice, CurrencyFactor);
            UnitPrice := ROUND(UnitPrice, Currency."Unit-Amount Rounding Precision");
        END ELSE
            UnitPrice := ROUND(UnitPrice, GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalcLineAmount(SalesPrice: Record "Sales Price"): Decimal
    var
    begin
        //WITH SalesPrice DO
        BEGIN
            IF SalesPrice."Allow Line Disc." THEN
                EXIT(SalesPrice."Unit Price" * (1 - LineDiscPerCent / 100));
            EXIT(SalesPrice."Unit Price");
        END;
    end;

}