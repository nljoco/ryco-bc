tableextension 50001 "RYCO Item" extends Item
{
    /*
    ===========================================================
    begin smk2018.04.17 slupg: auto-merge the following changes
    ===========================================================
    nj20160429
    - added Master Item No., Dryer KG fields.

    FH20160928, SCPLLP, Fazle
        - Calculate Material Cost and Manufacturing Cost
        - Added 4 Fields:  "Labor%","Labor$","Material Cost","Mfg. Cost"
        - Added 2 function:  CalcMaterialCost, CalcMnfCost

    FH20161028
        - New Field Added: Mfg. Cost (Kg.)

    FH20161117
        - Calculate Material Cost for All item (Not Ink Only)

    ID552, nj20170131
    - updating of corresponding Assembly and BOM Components Items whenever Description or Description 2 is changed

    ID XXX, nj20170202
    - added Last Assembly Order No. - CGY, Prev Assembly Order No. - CGY,
            Last Assembly Order No. - MTL, Prev Assembly Order No. - MTL fields

    jl20180201
    - modify function CalcMaterialCost
    ===========================================================
    end smk2018.04.17
    ===========================================================

    ID2136, jl20180923
    - Add Pollutant "CAS5160-02-1"

    ID2288, nj20190401
    - changed Item Category Code fieldclass to Normal
      update Sales Price whenever the Item Category is changed.
    */

    fields
    {
        field(50000; "Master Item No."; Boolean)
        {
            //nj20160429
            Caption = 'Master Item No.';
            DataClassification = ToBeClassified;
        }
        field(50001; "Dryer (%)"; Decimal)
        {
            //nj20160429
            Caption = 'Dryer (%)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(50002; "Linked to Master Item No."; Code[20])
        {
            //nj20160429
            Caption = 'Linked to Master Item No.';
            DataClassification = ToBeClassified;
            TableRelation = Item."No." WHERE("Master Item No." = CONST(true));
            ValidateTableRelation = true;
        }
        field(50003; "Last Assembly Order No."; Code[20])
        {
            //nj20160505
            Caption = 'Last Assembly Order No.';
            DataClassification = ToBeClassified;
        }
        field(50004; "Prev Assembly Order No."; Code[20])
        {
            //nj20160505
            Caption = 'Prev Assembly Order No.';
            DataClassification = ToBeClassified;
        }
        field(50005; "Last Assembly Order No. - CGY"; Code[20])
        {
            //nj20170202
            Caption = 'Last Assembly Order No. - CGY';
            DataClassification = ToBeClassified;
        }
        field(50006; "Prev Assembly Order No. - CGY"; Code[20])
        {
            //nj20170202
            Caption = 'Prev Assembly Order No. - CGY';
            DataClassification = ToBeClassified;
        }
        field(50007; "Last Assembly Order No. - MTL"; Code[20])
        {
            //nj20170202
            Caption = 'Last Assembly Order No. - MTL';
            DataClassification = ToBeClassified;
        }
        field(50008; "Prev Assembly Order No. - MTL"; Code[20])
        {
            //nj20170202
            Caption = 'Prev Assembly Order No. - MTL';
            DataClassification = ToBeClassified;
        }
        field(50010; "Price Unit of Measure Code"; Code[10])
        {
            //fazle06132016
            Caption = 'Price Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = field("No."));
            ValidateTableRelation = true;
        }
        field(50011; "VOC"; Decimal)
        {
            Caption = 'VOC';
            DataClassification = ToBeClassified;
        }
        field(50012; "Cobalt"; Decimal)
        {
            Caption = 'Cobalt';
            DataClassification = ToBeClassified;
        }
        field(50013; "Manganese"; Decimal)
        {
            Caption = 'Manganese';
            DataClassification = ToBeClassified;
        }
        field(50014; "Copper"; Decimal)
        {
            Caption = 'Copper';
            DataClassification = ToBeClassified;
        }
        field(50015; "MolyBdenum"; Decimal)
        {
            Caption = 'MolyBdenum';
            DataClassification = ToBeClassified;
        }
        field(50016; "Zinc"; Decimal)
        {
            Caption = 'Zinc';
            DataClassification = ToBeClassified;
        }
        field(50017; "Methylene Chloride"; Decimal)
        {
            Caption = 'Methylene Chloride';
            DataClassification = ToBeClassified;
        }
        field(50018; "Toluene"; Decimal)
        {
            Caption = 'Toluene';
            DataClassification = ToBeClassified;
        }
        field(50019; "Xylene"; Decimal)
        {
            Caption = 'Xylene';
            DataClassification = ToBeClassified;
        }
        field(50020; "Other"; Decimal)
        {
            Caption = 'Other';
            DataClassification = ToBeClassified;
        }
        field(50021; "CAS5160-02-1"; Decimal)
        {
            Caption = 'CAS5160-02-1';
            DataClassification = ToBeClassified;
        }
        field(50030; "Labour%"; Decimal)
        {
            //FH20160928
            Caption = 'Labour%';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                CalcMFGCost;
            end;
        }
        field(50040; "Labour$"; Decimal)
        {
            //FH20160928
            Caption = 'Labour$';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                CalcMFGCost;
            end;
        }
        field(50050; "Material Cost"; Decimal)
        {
            //FH20160928
            Caption = 'Material Cost';
            DataClassification = ToBeClassified;
        }
        field(50060; "Mfg. Cost"; Decimal)
        {
            //FH20160928
            Caption = 'Mfg. Cost';
            DataClassification = ToBeClassified;
            //Enabled = false;
            Editable = false;

            trigger OnValidate()
            var
                lrecItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                //20161028-->
                IF lrecItemUnitofMeasure.GET("No.", 'KG') THEN BEGIN
                    "Mfg. Cost (Kg.)" := "Mfg. Cost" * lrecItemUnitofMeasure."Qty. per Unit of Measure";
                END ELSE BEGIN
                    "Mfg. Cost (Kg.)" := "Mfg. Cost";
                END;
                //20161028--<
            End;
        }
        field(50070; "Mfg. Cost (Kg.)"; Decimal)
        {
            //FH20160928
            Caption = 'Mfg. Cost (Kg.)';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        modify(Description)
        {
            trigger OnAfterValidate()
            begin
                UpdateDescription(FieldName(Description)); // nj20170131
            end;
        }
        modify("Description 2")
        {
            trigger OnAfterValidate()
            begin
                UpdateDescription(FieldName("Description 2")); // nj20170131
            end;
        }
    }

    procedure CalcMaterialCost(): Decimal
    var
        lrecBOMComponent: Record "BOM Component";
        lrecItem: Record Item;
        lrecIUOM: Record "Item Unit of Measure";
        ldecMaterialCost: Decimal;
        lrecUOMConvert: Decimal;
        lrecCompCost: Decimal;
    begin
        //FH20160928-->
        CLEAR(ldecMaterialCost);
        IF "Assembly BOM" THEN BEGIN
            lrecBOMComponent.RESET;
            lrecBOMComponent.SETRANGE("Parent Item No.", "No.");
            lrecBOMComponent.SETRANGE(Type, lrecBOMComponent.Type::Item);
            lrecBOMComponent.SETFILTER("No.", '<>%1', '');
            //lrecBOMComponent.SETRANGE(Ink,TRUE);//FH20161117
            IF lrecBOMComponent.FINDSET THEN BEGIN
                REPEAT
                    IF lrecItem.GET(lrecBOMComponent."No.") THEN BEGIN
                        //rpd.2017.02.22.start
                        //ldecMaterialCost+=lrecItem."Unit Cost"*lrecBOMComponent."Quantity per";
                        // jl20180201 start
                        lrecIUOM.RESET;
                        lrecIUOM.SETRANGE("Item No.", lrecBOMComponent."No.");
                        lrecIUOM.SETRANGE(Code, lrecBOMComponent."Unit of Measure Code");
                        IF lrecIUOM.FINDSET THEN
                            lrecUOMConvert := lrecIUOM."Qty. per Unit of Measure"
                        ELSE
                            lrecUOMConvert := 1;

                        lrecCompCost := lrecItem.CalcMaterialCost;
                        IF lrecCompCost <> 0 THEN
                            //lrecItem.VALIDATE("Mfg. Cost",lrecCompCost);
                            lrecItem.VALIDATE("Mfg. Cost", lrecCompCost + (lrecCompCost * (lrecItem."Labour%" / 100)) + lrecItem."Labour$");

                        // jl20180201 end

                        IF lrecItem."Mfg. Cost" = 0 THEN
                            // ldecMaterialCost+=lrecItem."Unit Cost"*lrecBOMComponent."Quantity per" //jl20180201
                            ldecMaterialCost += lrecItem."Unit Cost" * lrecBOMComponent."Quantity per" * lrecUOMConvert
                        ELSE
                            // ldecMaterialCost+=lrecItem."Mfg. Cost"*lrecBOMComponent."Quantity per"; //jl20180201
                            ldecMaterialCost += lrecItem."Mfg. Cost" * lrecBOMComponent."Quantity per" * lrecUOMConvert;
                        //rpd.2017.02.22.end
                    END;
                UNTIL lrecBOMComponent.NEXT = 0;
            END;
        END;
        IF ldecMaterialCost <> 0 THEN BEGIN
            "Material Cost" := ldecMaterialCost;
        END;
        EXIT("Material Cost");
        //FH20160928--<
    end;

    procedure CalcMfgCost()
    var
        ldecMaterialCost: Decimal;
        ldecMfgCost: Decimal;
    begin
        //FH20160928-->
        CLEAR(ldecMfgCost);
        IF "Assembly BOM" THEN BEGIN
            ldecMaterialCost := CalcMaterialCost;
            ldecMfgCost := ldecMaterialCost + (ldecMaterialCost * ("Labour%" / 100)) + "Labour$";
        END;
        IF ldecMfgCost <> 0 THEN BEGIN
            //"Mfg. Cost":=ldecMfgCost;//Removed FH20161028
            VALIDATE("Mfg. Cost", ldecMfgCost);//Added FH20161028
        END;
        //EXIT("Mfg. Cost");

        //FH20160928--<
    end;

    local procedure UpdateDescription(ptxtFieldName: Text)
    var
        lrecAssemblyHdr: Record "Assembly Header";
        lrecAssemblyLine: Record "Assembly Line";
        lrecBOMComponent: Record "BOM Component";
    begin
        // nj20170131 - Start
        lrecAssemblyHdr.RESET;
        lrecAssemblyHdr.SETRANGE("Item No.", "No.");

        lrecAssemblyLine.RESET;
        lrecAssemblyLine.SETRANGE(Type, lrecAssemblyLine.Type::Item);
        lrecAssemblyLine.SETRANGE("No.", "No.");

        lrecBOMComponent.RESET;
        lrecBOMComponent.SETRANGE(Type, lrecBOMComponent.Type::Item);
        lrecBOMComponent.SETRANGE("No.", "No.");

        CASE ptxtFieldName OF
            'Description':
                BEGIN
                    IF lrecAssemblyHdr.FINDSET THEN
                        REPEAT
                            lrecAssemblyHdr.Description := Description;
                            lrecAssemblyHdr.MODIFY;
                        UNTIL lrecAssemblyHdr.NEXT = 0;

                    IF lrecAssemblyLine.FINDSET THEN
                        REPEAT
                            lrecAssemblyLine.Description := Description;
                            lrecAssemblyLine.MODIFY;
                        UNTIL lrecAssemblyLine.NEXT = 0;

                    IF lrecBOMComponent.FINDSET THEN
                        REPEAT
                            lrecBOMComponent.Description := Description;
                            lrecBOMComponent.MODIFY;
                        UNTIL lrecBOMComponent.NEXT = 0;
                END;
            'Description 2':
                BEGIN
                    IF lrecAssemblyHdr.FINDSET THEN
                        REPEAT
                            lrecAssemblyHdr."Description 2" := "Description 2";
                            lrecAssemblyHdr.MODIFY;
                        UNTIL lrecAssemblyHdr.NEXT = 0;

                    IF lrecAssemblyLine.FINDSET THEN
                        REPEAT
                            lrecAssemblyLine."Description 2" := "Description 2";
                            lrecAssemblyLine.MODIFY;
                        UNTIL lrecAssemblyLine.NEXT = 0;
                END;
        END;
        // nj20170131 - End
    end;


    var
        CannotDeleteItemIfSalesDocExistInvoicingErr: Label 'You cannot delete %1 %2 because at least one sales document (%3 %4) includes the item.';
}