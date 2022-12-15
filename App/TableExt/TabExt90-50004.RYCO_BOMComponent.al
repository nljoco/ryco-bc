tableextension 50004 "RYCO BOM Component" extends "BOM Component"
{
    /*
    smk2018.04.17 slupg: automerge misc. untagged chagges

    */
    fields
    {
        field(50000; "Instruction Code"; Code[20])
        {
            //nj20160429
            Caption = 'Instruction Code';
            TableRelation = "BOM Instruction";
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                // nj20160429 - Start
                IF "Instruction Code" <> '' THEN BEGIN
                    IF grecBOMInstruction.GET("Instruction Code") THEN
                        Description := grecBOMInstruction.Description;
                END;
                // nj20160429 - End
            end;

            trigger OnLookup()
            var
            begin
                // nj20160429 - Start
                IF PAGE.RUNMODAL(0, grecBOMInstruction) = ACTION::LookupOK THEN BEGIN
                    "Instruction Code" := grecBOMInstruction.Code;
                    Description := grecBOMInstruction.Description;
                END;
                // nj20160429 - End
            end;
        }
        field(50001; "Ink Percentage"; Decimal)
        {
            //nj20160429
            Caption = 'Ink Percentage';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                // nj20160511 - Start
                // {
                // IF ("Ink Percentage" > 100) OR ("Ink Percentage" < 0) THEN
                // // Ink Percentage cannot be < 0 or > 100!
                //ERROR(TextSC002);
                // }//Fazle06152016
                grecItemUOM.GET("Parent Item No.", 'KG');
                //Fazle06062016-->
                "Quantity per" := grecItemUOM."Qty. per Unit of Measure" * "Ink Percentage" / 100;
                "Quantity per" := grecItemUOM."1 per Qty. per Unit of Measure" * "Ink Percentage" / 100;
                //Fazle06062016--<
                // nj20160511 - End
            end;
        }
        field(50002; "Type of Component"; Option)
        {
            //nj20160429
            caption = 'Type of Component';
            OptionMembers = Colour,Packaging,Resources;
            DataClassification = ToBeClassified;
        }
        field(50003; "Ink"; Boolean)
        {
            //nj20160429
            Caption = 'Ink';
            DataClassification = ToBeClassified;
        }
        modify("Quantity per")
        {
            trigger OnAfterValidate()
            var
            begin
                // nj20160511 - Start
                // IF ("Quantity per" < 0) THEN
                // Quantity per cannot be < 0!
                //ERROR(TextSC003);
                IF "Quantity per" = 0 THEN
                    "Ink Percentage" := 0
                ELSE BEGIN
                    grecItemUOM.GET("Parent Item No.", 'KG');
                    IF Ink = TRUE THEN
                        //Fazle06062016-->
                        //"Ink Percentage" := "Quantity per" / grecItemUOM."Qty. per Unit of Measure" * 100;
                        "Ink Percentage" := "Quantity per" / grecItemUOM."1 per Qty. per Unit of Measure" * 100;
                    //Fazle06062016--<
                END;
                // nj20160511 - End
            end;
        }
    }
    keys
    {
        key(key3; "Line No.", "Parent Item No.", "No.")
        {
            MaintainSqlIndex = true;
            MaintainSiftIndex = true;
        }
    }

    trigger OnInsert()
    var
    begin
        // Originally placed in Table 90 - BOM Component OnInsert function after ValidateAgainstRecursion("No.")
        // Fazle06152016--> 
        // {
        // if Item."Master Item No." then begin
        //     if "Line No." >= 1000000 then
        //         error('Line No %1 exceeded Maximum Limit (<%2) for Master Item', "Line No.", 1000000);
        // end
        // else begin
        //     if "Line No." < 1000000 then
        //         error('Line No %1 exceeded Minimum Limit (>=%2) for Master Item', "Line No.", 1000000);
        // end;
        // }
        // Fazle06152016--< */
    end;

    trigger OnModify()
    var
    begin
        //Fazle05262016-->
        IF Type = Type::" " THEN BEGIN
            IF ("Instruction Code" <> '') AND ("Instruction Code" = xRec."Instruction Code") THEN BEGIN
                IF xRec.Description <> '' THEN BEGIN
                    IF Description <> xRec.Description THEN BEGIN
                        ERROR('You cannot change the Description!');
                    END;
                END;
            END;
        END;
        //Fazle05262016--<
        Item.GET("Parent Item No.");
        //Fazle06152016-->
        IF NOT Item."Master Item No." THEN BEGIN
            IF Item."Linked to Master Item No." <> '' THEN BEGIN
                IF "Line No." < 1000000 THEN
                    ERROR('You cannot modify Line No %1, becuase it is from Master BOM', "Line No.");
            END;
        END;
        //Fazle06152016--<
    end;

    trigger OnDelete()
    var
    begin
        //Fazle06152016-->
        Item.GET("Parent Item No.");
        IF NOT Item."Master Item No." THEN BEGIN
            IF Item."Linked to Master Item No." <> '' THEN BEGIN
                IF "Line No." < 1000000 THEN
                    ERROR('You cannot delete Line No %1, becuase it is from Master BOM', "Line No.");
            END;
        END;
        //Fazle06152016--<
    end;

    local procedure ValidateItemForDuplication()
    var
        lrecBOMComponent: record "BOM Component";
    begin
        //Fazle05242016-->
        lrecBOMComponent.RESET;
        lrecBOMComponent.SETRANGE("Parent Item No.", "Parent Item No.");
        lrecBOMComponent.SETRANGE(Type, lrecBOMComponent.Type::Item);
        lrecBOMComponent.SETRANGE("No.", "No.");
        IF NOT lrecBOMComponent.ISEMPTY THEN
            ERROR(STRSUBSTNO(TextSC004, "No."));
        //Fazle05242016--<
    end;

    var
        Item: Record Item;
        ParentItem: Record Item;
        Res: Record Resource;
        ItemVariant: Record "Item Variant";
        BOMComp: Record "BOM Component";
        CalcLowLevelCode: Codeunit "Calculate Low-Level Code";
        AssemblyBOM: Page "Assembly BOM";
        grecBOMInstruction: Record "BOM Instruction";
        grecItemUOM: Record "Item Unit of Measure";
        TextSC002: Label 'Ink Percentage cannot be < 0 or > 100!';
        TextSC003: Label 'Quantity per cannot be < 0!';
        TextSC004: Label 'Item %1 already exists in Assembly BOM';
}