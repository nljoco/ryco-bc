pageextension 50002 "Ryc Assembly BOM" extends "Assembly BOM"
{
    /*
    smk2018.04.09 SLUPG:
    ====================
    merge OnInsertRecord >> fazle06152016

    ID2858 jl20200817 - displayed item unit cost
    */
    layout
    {
        addafter("No.")
        {
            field("Instruction Code"; rec."Instruction Code")
            {
                Visible = true;
                ApplicationArea = all;
            }
        }
        addafter("Resource Usage Type")
        {
            field("Ink Percentage"; Rec."Ink Percentage")
            {
                ApplicationArea = All;
                trigger OnValidate()
                var
                begin
                    //Fazle06152016-->
                    IF (Rec."Ink Percentage" > 100) OR (Rec."Ink Percentage" < 0) THEN
                        // Ink Percentage cannot be < 0 or > 100!
                        MESSAGE(TextSC004);
                    //Fazle06152016--<
                end;
            }
            field(Ink; Rec.Ink)
            {
                ApplicationArea = All;
            }
            field(gItemUnitCost; gItemUnitCost)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 5;
                Caption = 'Unit Cost';
            }
            field(gItemTotCost; gItemTotCost)
            {
                ApplicationArea = All;
                DecimalPlaces = 2 : 5;
                Caption = 'Total Cost';
            }
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
            begin
                ValidUnitCost; //ID2858 jl20200817
            end;
        }
        modify(Description)
        {
            trigger OnAfterValidate()
            var
            begin
                ValidUnitCost; //ID2858 jl20200817
            end;
        }
        modify("Quantity per")
        {
            trigger OnAfterValidate()
            var
            begin
                ValidUnitCost; //ID2858 jl20200817
                               //Fazle06152016-->
                IF (Rec."Ink Percentage" > 100) OR (Rec."Ink Percentage" < 0) THEN
                    // Ink Percentage cannot be < 0 or > 100!
                    MESSAGE(TextSC004);
                //Fazle06152016--<
            end;
        }
        modify("Unit of Measure Code")
        {
            trigger OnAfterValidate()
            var
            begin
                ValidUnitCost; //ID2858 jl20200817
            end;
        }
    }

    actions
    {
    }

    var
        IsEmptyOrItem: Boolean;
        grecItem: Record Item;
        gItemUnitCost: Decimal;
        gItemTotCost: Decimal;
        TextSC001: Label 'WARNING: The Total Percentage %1 is less than 100%.';
        TextSC002: Label 'WARNING: No BOM Component has been set up.';
        TextSC003: Label 'WARNING: The Total Percentage %1 is greater than 100%.';
        TextSC004: Label 'Ink Percentage is < 0 or > 100!';

    trigger OnClosePage()
    var
    begin
        ValidatePercentage;   // nj20160430
    end;

    trigger OnAfterGetRecord()
    var
    begin
        //ID2858 jl20200817 start
        gItemUnitCost := 0;
        gItemTotCost := 0;

        ValidUnitCost;

        //ID2858 jl20200817 end
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        lrecBOMComponent: Record "BOM Component";
        lintLastLineNo: Integer;
    begin
        ///////////////////////////////////////////////////
        //BEGIN add smk2018.04.09 SLUPG
        //      from nav2016 modified
        ///////////////////////////////////////////////////
        //fazle06152016-->
        grecItem.GET(Rec."Parent Item No.");
        IF NOT grecItem."Master Item No." THEN BEGIN
            IF grecItem."Linked to Master Item No." <> '' THEN BEGIN
                IF Rec."Line No." < 1000000 THEN BEGIN
                    lintLastLineNo := 1000000;
                    lrecBOMComponent.RESET;
                    lrecBOMComponent.SETRANGE(lrecBOMComponent."Parent Item No.", Rec."Parent Item No.");
                    lrecBOMComponent.SETFILTER("Line No.", '>=%1', lintLastLineNo);
                    IF lrecBOMComponent.FINDLAST THEN BEGIN
                        lintLastLineNo := lrecBOMComponent."Line No.";
                    END;
                    Rec."Line No." += lintLastLineNo;
                END;
            END;
        END;

        IF grecItem."Master Item No." THEN BEGIN
            IF Rec."Line No." >= 1000000 THEN
                ERROR('Line No %1 exceeded Maximum Limit (<%2) for Master Item', Rec."Line No.", 1000000);
        END
        ELSE BEGIN
            IF grecItem."Linked to Master Item No." <> '' THEN BEGIN
                IF Rec."Line No." < 1000000 THEN
                    ERROR('Line No %1 exceeded Minimum Limit (>=%2) for Child Item', Rec."Line No.", 1000000);
            END;
        END;
        //fazle06152016--<

        ///////////////////////////////////////////////////
        //END add smk2018.04.09 SLUPG
        ///////////////////////////////////////////////////
        IsEmptyOrItem := Rec.Type in [Rec.Type::" ", Rec.Type::Item];

    end;

    trigger OnModifyRecord(): Boolean
    var
    begin
        //Fazle06152016-->
        IF (Rec."Ink Percentage" > 100) OR (Rec."Ink Percentage" < 0) THEN
            // Ink Percentage cannot be < 0 or > 100!
            MESSAGE(TextSC004);
        //Fazle06152016--<

    end;

    local procedure ValidatePercentage()
    var
        lrecBOMComponent: Record "BOM Component";
        ldecTotalPct: Decimal;

    begin
        ldecTotalPct := 0;
        lrecBOMComponent.RESET;
        lrecBOMComponent.SETRANGE("Parent Item No.", Rec."Parent Item No.");
        lrecBOMComponent.SETRANGE(Type, lrecBOMComponent.Type::Item);
        IF lrecBOMComponent.FINDFIRST THEN BEGIN
            REPEAT
                ldecTotalPct += lrecBOMComponent."Ink Percentage";
            UNTIL lrecBOMComponent.NEXT = 0;
            IF ldecTotalPct < 100 THEN
                // WARNING: The Total Percentage is less than 100%.

                //MESSAGE(TextSC001);
                MESSAGE(STRSUBSTNO(TextSC001, ldecTotalPct));//Fazle07132016
            IF ldecTotalPct > 100 THEN
                // WARNING: The Total Percentage is greater than 100%.
                //MESSAGE(TextSC003);
                MESSAGE(STRSUBSTNO(TextSC003, ldecTotalPct));//Fazle07132016
        END ELSE BEGIN
            // WARNING: No BOM Component has been set up.
            IF NOT CONFIRM(TextSC002, FALSE) THEN
                ERROR('');
        END;
    end;

    local procedure ValidUnitCost()
    var
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
        lrecItemQtyPer: Decimal;
    begin
        //ID2858 jl20200817 start
        gItemUnitCost := 0;
        gItemTotCost := 0;
        IF Rec.Type = Rec.Type::Item THEN BEGIN
            lrecItem.RESET;
            lrecItem.SETRANGE("No.", Rec."No.");
            IF lrecItem.FINDFIRST THEN BEGIN
                lrecItemUOM.SETRANGE("Item No.", Rec."No.");
                lrecItemUOM.SETRANGE(Code, Rec."Unit of Measure Code");
                IF lrecItemUOM.FINDFIRST THEN
                    lrecItemQtyPer := lrecItemUOM."Qty. per Unit of Measure";

                gItemUnitCost := lrecItem."Unit Cost" * lrecItemQtyPer;
                gItemTotCost := gItemUnitCost * Rec."Quantity per";
            END;
        END;
        //ID2858 jl20200817 end
    end;
}