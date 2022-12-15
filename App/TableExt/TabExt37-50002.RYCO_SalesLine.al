tableextension 50002 "RYCO Sales Line" extends "Sales Line"
{
    /*
    smk2018.04.09 SLUPG
    -------------------
    merged the following:
        Field 6: OnValidate Fazle06092016
        Field 15: OnValidate Fazle06092016

    ID2136, jl20180923
    -  Pop message if item has pollutant "CAS5160-02-1"
    */

    fields
    {
        // Add changes to table fields here
        field(50010; "Selling Unit of Measure"; Code[10])
        {
            Caption = 'Selling Unit of Measure';
            DataClassification = ToBeClassified;
            TableRelation = IF (Type = CONST(Item), "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            IF (Type = CONST(Resource), "No." = FILTER(<> '')) "Resource Unit of Measure".Code WHERE("Resource No." = FIELD("No.")) ELSE
            "Unit of Measure";
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                lrecIUoM: Record "Item Unit of Measure";
                lrecSalesPrice: Record "Sales Price";
                lrecItem: Record Item;
                SalesHeader: Record "Sales Header";
                PriceCalcMgt: Codeunit "Ryco Sales Price Calc. Mgt.";

            begin
                //Fazle06092016-->
                IF Type = Type::Item THEN BEGIN
                    IF "Selling Unit of Measure" = '' THEN BEGIN
                        //"Selling Unit of Measure":="Unit of Measure Code";
                        //"Selling Qauntity":=Quantity;
                        //"Selling Unit Price":="Unit Price";
                        lrecItem.GET("No.");
                        IF lrecItem."Price Unit of Measure Code" <> '' THEN
                            "Selling Unit of Measure" := lrecItem."Price Unit of Measure Code"
                        ELSE
                            "Selling Unit of Measure" := lrecItem."Sales Unit of Measure";

                        lrecIUoM.GET("No.", "Selling Unit of Measure");
                        "Selling Qauntity" := Quantity * lrecIUoM."1 per Qty. per Unit of Measure";
                        SalesHeader := GetSalesHeader;
                        //GetSalesPrice;
                        PriceCalcMgt.FindSalesLinePriceSelling(SalesHeader, Rec);
                        VALIDATE("Selling Unit Price");
                    END
                    ELSE BEGIN
                        IF "Unit of Measure Code" = "Selling Unit of Measure" THEN BEGIN
                            "Selling Qauntity" := Quantity;
                            "Selling Unit Price" := "Unit Price";
                        END
                        ELSE BEGIN
                            lrecIUoM.GET("No.", "Selling Unit of Measure");
                            "Selling Qauntity" := Quantity * lrecIUoM."1 per Qty. per Unit of Measure";
                            GetSalesHeader;
                            PriceCalcMgt.FindSalesLinePriceSelling(SalesHeader, Rec);
                            VALIDATE("Selling Unit Price")
                        END;
                    END;
                END
                //Fazle06092016--<
            end;
        }
        field(50020; "Selling Qauntity"; Decimal)
        {
            Caption = 'Selling Quantity';
            AutoFormatExpression = "Currency Code";
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(50030; "Selling Unit Price"; Decimal)
        {
            Caption = 'Selling Unit Price';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                lrecIUoM: Record "Item Unit of Measure";
            begin
                //Fazle06092016-->
                IF (Type = Type::Item) AND ("Selling Qauntity" <> 0) AND (Quantity <> 0) THEN
                    "Unit Price" := "Selling Unit Price" * ("Selling Qauntity" / Quantity);
                IF (Type = Type::Item) AND (("Selling Qauntity" = 0) OR (Quantity = 0)) THEN BEGIN
                    lrecIUoM.GET("No.", "Selling Unit of Measure");
                    "Unit Price" := "Selling Unit Price" * (lrecIUoM."1 per Qty. per Unit of Measure" * 1);
                END;

                //jl20160617
                IF (Type = Type::"G/L Account") AND (Quantity <> 0) THEN
                    "Unit Price" := "Selling Unit Price";
                //jl20160617

                VALIDATE("Unit Price");
                //Fazle06092016--<
            end;
        }
    }
}