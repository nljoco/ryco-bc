tableextension 50016 "RYCO Sales Price Worksheet" extends "Sales Price Worksheet"
{
    /*
    begin smk2018.04.17 slupg: automerge the following
        //ID461 Fazle, SCPLLP 20161206 10:00 AM
            - Suggest Sales Price on Wksht Based on Cost
                - created 4 New Fields:
                    Mfg. Cost.
                    Last Direct Cost
                    Adj $
                    ADj %
        nj20180123
        - added Item Category Code field
        jl20180124
        - Mfg Cost is Item.Mfg.Cost(Kg)
    */

    fields
    {
        field(50000; "Last Direct Cost"; Decimal)
        {
            //ID461
            Caption = 'Last Direct Cost';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
            begin
                IF Item.GET("Item No.") THEN BEGIN
                    Item.CALCFIELDS("Assembly BOM");
                    IF Item."Assembly BOM" THEN
                        "New Unit Price" := ROUND("Mfg. Cost" + (("Mfg. Cost" * "Adj%") / 100) + "Adj$", 0.01, '=')
                    ELSE
                        "New Unit Price" := ROUND("Last Direct Cost" + (("Last Direct Cost" * "Adj%") / 100) + "Adj$", 0.01, '=');
                END;//ID461
            end;

        }
        field(50010; "Mfg. Cost"; Decimal)
        {
            //ID461
            Caption = 'Mfg. Cost';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                IF Item.GET("Item No.") THEN BEGIN
                    Item.CALCFIELDS("Assembly BOM");
                    IF Item."Assembly BOM" THEN
                        "New Unit Price" := ROUND("Mfg. Cost" + (("Mfg. Cost" * "Adj%") / 100) + "Adj$", 0.01, '=')
                    ELSE
                        "New Unit Price" := ROUND("Last Direct Cost" + (("Last Direct Cost" * "Adj%") / 100) + "Adj$", 0.01, '=');
                END;//ID461
            end;

        }
        field(50011; "Adj%"; Decimal)
        {
            //ID461
            Caption = 'Adj%';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                IF Item.GET("Item No.") THEN BEGIN
                    Item.CALCFIELDS("Assembly BOM");
                    IF Item."Assembly BOM" THEN
                        "New Unit Price" := ROUND("Mfg. Cost" + (("Mfg. Cost" * "Adj%") / 100) + "Adj$", 0.01, '=')
                    ELSE
                        "New Unit Price" := ROUND("Last Direct Cost" + (("Last Direct Cost" * "Adj%") / 100) + "Adj$", 0.01, '=');
                END;//ID461
            end;
        }
        field(50012; "Adj$"; Decimal)
        {
            //ID461
            Caption = 'Adj$';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                //{
                // IF Item.GET("Item No.") THEN BEGIN
                //                     Item.CALCFIELDS("Assembly BOM");
                //                     IF Item."Assembly BOM" THEN
                //                         "New Unit Price" := "Mfg. Cost" + (("Mfg. Cost" * "Adj%") / 100) + "Adj$"
                //                     ELSE
                //                         "New Unit Price" := "Last Direct Cost" + (("Last Direct Cost" * "Adj%") / 100) + "Adj$";
                //                 END;//ID461
                //}
                IF Item.GET("Item No.") THEN BEGIN
                    Item.CALCFIELDS("Assembly BOM");
                    IF Item."Assembly BOM" THEN
                        "New Unit Price" := ROUND("Mfg. Cost" + (("Mfg. Cost" * "Adj%") / 100) + "Adj$", 0.01, '=')
                    ELSE
                        "New Unit Price" := ROUND("Last Direct Cost" + (("Last Direct Cost" * "Adj%") / 100) + "Adj$", 0.01, '=');
                END;//ID461
            end;
        }
        field(50013; "Item Category Code"; Code[20])
        {
            //ID461
            Caption = 'Item Category Code';
            FieldClass = FlowField;
            CalcFormula = Lookup(Item."Item Category Code" WHERE("No." = FIELD("Item No.")));
            TableRelation = "Item Category";
        }
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
            begin
                CalcCurrentPrice(PriceAlreadyExists);
                //ID461-->
                IF Item.GET("Item No.") THEN BEGIN
                    Item.CALCFIELDS("Assembly BOM");
                    IF Item."Assembly BOM" THEN BEGIN
                        "Last Direct Cost" := 0;
                        //VALIDATE("Mfg. Cost",Item."Mfg. Cost");
                        Item.CalcMfgCost; //jl20180124
                        VALIDATE("Mfg. Cost", Item."Mfg. Cost (Kg.)");  //jl20180124
                    END ELSE BEGIN
                        VALIDATE("Last Direct Cost", Item."Last Direct Cost");
                        "Mfg. Cost" := 0;
                    END;
                END ELSE BEGIN
                    VALIDATE("Last Direct Cost", 0);
                    VALIDATE("Mfg. Cost", 0);
                END;
                //ID461--<
            end;
        }
    }
    local procedure CalcCurrentPrice(VAR PriceAlreadyExists: Boolean)
    var
        SalesPrice: Record "Sales Price";
    begin
        SalesPrice.SETRANGE("Item No.", "Item No.");
        SalesPrice.SETRANGE("Sales Type", "Sales Type");
        SalesPrice.SETRANGE("Sales Code", "Sales Code");
        SalesPrice.SETRANGE("Currency Code", "Currency Code");
        SalesPrice.SETRANGE("Unit of Measure Code", "Unit of Measure Code");
        SalesPrice.SETRANGE("Starting Date", 0D, "Starting Date");
        SalesPrice.SETRANGE("Minimum Quantity", 0, "Minimum Quantity");
        SalesPrice.SETRANGE("Variant Code", "Variant Code");
        IF SalesPrice.FINDLAST THEN BEGIN
            "Current Unit Price" := SalesPrice."Unit Price";
            "Price Includes VAT" := SalesPrice."Price Includes VAT";
            "Allow Line Disc." := SalesPrice."Allow Line Disc.";
            "Allow Invoice Disc." := SalesPrice."Allow Invoice Disc.";
            "VAT Bus. Posting Gr. (Price)" := SalesPrice."VAT Bus. Posting Gr. (Price)";
            PriceAlreadyExists := SalesPrice."Starting Date" = "Starting Date";
        END ELSE BEGIN
            "Current Unit Price" := 0;
            PriceAlreadyExists := FALSE;
        END;
    end;

    local procedure SetSalesDescription()
    var
        Customer: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
        Campaign: Record Campaign;
    begin
        "Sales Description" := '';
        IF "Sales Code" = '' THEN
            EXIT;
        CASE "Sales Type" OF
            "Sales Type"::Customer:
                IF Customer.GET("Sales Code") THEN
                    "Sales Description" := Customer.Name;
            "Sales Type"::"Customer Price Group":
                IF CustomerPriceGroup.GET("Sales Code") THEN
                    "Sales Description" := CustomerPriceGroup.Description;
            "Sales Type"::Campaign:
                IF Campaign.GET("Sales Code") THEN
                    "Sales Description" := Campaign.Description;
        END;
    end;


    var
        PriceAlreadyExists: Boolean;
}