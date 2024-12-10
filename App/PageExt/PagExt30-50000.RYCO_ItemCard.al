pageextension 50000 "Ryc Item Card" extends "Item Card"
{
    /*
    smk2018.04.09 SLUPG:
    ====================
    FH20160928, SCPLLP, Fazle
        - Calculate Material Cost and Manufacturing Cost
        - Added 4 Fields:  "Labor%","Labor$","Material Cost","Mfg. Cost"
        - called functions: CalcMnfCost
    FH20161103
        - Material Cost Change in Form are saved in Table.
    nj20170119
    - disabled the lines that modify the Item when closing the page.
    nj20170126
    - to disable the edit Permission of users with 'RYC-ITEM, NON-EDIT' Role
    smk2018.04.09 SLUPG:
    ====================
    moved nj20170126 code in OnInit to InitControls(...)
    Microsoft re-numbered control 1907468901 "Group >> Foreign Trade" control 177. added Editable=gblnPageEditable to that control

    ID2236, jl20180923
    - Add Pollutant "CAS5160-02-1"
    */
    layout
    {
        addafter("Warehouse")
        {
            group(Pollutant)
            {
                Caption = 'Pollutant';
                field(VOC; Rec.VOC)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
                field(Cobalt; Rec.Cobalt)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
                field(Manganese; Rec.Manganese)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
                field(Copper; Rec.Copper)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
                field(MolyBdenum; Rec.MolyBdenum)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
                field(Zinc; Rec.Zinc)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
                field("Methylene Chloride"; Rec."Methylene Chloride")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
                field(Toluene; Rec.Toluene)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
                field(Xylene; Rec.Xylene)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
                field("CAS5160-02-1"; Rec."CAS5160-02-1")
                {
                    ApplicationArea = All;
                }
                field(Other; Rec.Other)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 5;
                }
            }
            group(ManufacturingCost)
            {
                Caption = 'Manufacturing Cost';
                field("Material Cost"; Rec."Material Cost")
                {
                    ApplicationArea = All;
                }
                field("Labour%"; Rec."Labour%")
                {
                    ApplicationArea = All;
                }
                field("Labour$"; Rec."Labour$")
                {
                    ApplicationArea = All;
                }
                field("Mfg. Cost"; Rec."Mfg. Cost")
                {
                    ApplicationArea = All;
                }
                field("Mfg. Cost (Kg.)"; Rec."Mfg. Cost (Kg.)")
                {
                    ApplicationArea = All;
                }
            }
        }

        addafter("PreventNegInventoryDefaultNo")
        {
            field("Master Item No."; rec."Master Item No.")
            {
                ApplicationArea = All;
            }
            field("Dryer (%)"; rec."Dryer (%)")
            {
                ApplicationArea = All;
            }
            field("Linked to Master Item No."; rec."Linked to Master Item No.")
            {
                ApplicationArea = All;
            }
            field("Last Assembly Order No."; rec."Last Assembly Order No.")
            {
                ApplicationArea = All;
            }
            field("Prev Assembly Order No."; rec."Prev Assembly Order No.")
            {
                ApplicationArea = All;
            }
            field("Last Assembly Order No. - CGY"; rec."Last Assembly Order No. - CGY")
            {
                ApplicationArea = All;
            }
            field("Prev Assembly Order No. - CGY"; rec."Prev Assembly Order No. - CGY")
            {
                ApplicationArea = All;
            }
            field("Last Assembly Order No. - MTL"; rec."Last Assembly Order No. - MTL")
            {
                ApplicationArea = All;
            }
            field("Prev Assembly Order No. - MTL"; rec."Prev Assembly Order No. - MTL")
            {
                ApplicationArea = All;
            }
        }

        modify(Item)
        {
            Editable = gblnPageEditable;
        }

        modify("Common Item No.")
        {
            Visible = false;
        }
        modify("Service item group")
        {
            Visible = true;
        }
        modify("Purchasing code")
        {
            Visible = false;
        }
        modify("VariantMandatoryDefaultYes")
        {
            Visible = false;
        }
        modify("VariantMandatoryDefaultNo")
        {
            Visible = false;
        }

        modify("Qty. on Prod. Order")
        {
            Visible = true;
            Importance = Additional;
        }
        modify("Qty. on Component Lines")
        {
            Visible = true;
            Importance = Additional;
        }
        modify("Qty. on Service Order")
        {
            Visible = true;
            Importance = Additional;
        }
        modify("Over-Receipt Code")
        {
            Visible = false;
        }
        modify("SAT Item Classification")
        {
            Visible = true;
        }
        modify("Purchasing blocked")
        {
            Visible = false;
        }
        modify("Description 2")
        {
            Visible = true;
        }
        addafter("Sales Unit of Measure")
        {
            field("Price Unit of Measure Code"; Rec."Price Unit of Measure Code")
            {
                ApplicationArea = all;
                Caption = 'Price Unit of Measure Code';
            }
        }

        moveafter(Description; "Description 2")
    }
    actions
    {
        addlast(Functions)
        {
            action("ReportRecalculatePollutant")
            {
                ApplicationArea = all;
                Caption = 'Recalculate Pollutant';
                trigger OnAction()
                var
                    lrecItem: Record Item;
                begin
                    IF NOT rec."Assembly BOM" THEN
                        ERROR('This item has no Assembly BOM');
                    lrecItem.RESET;
                    lrecItem.SETRANGE(lrecItem."No.", rec."No.");
                    IF lrecItem.FINDFIRST THEN BEGIN
                        REPORT.RUNMODAL(REPORT::"ReCalculate Pollutant Rep", TRUE, FALSE, lrecItem);
                    END;
                end;
            }
        }
        addlast(BillOfMaterials)
        {
            action("UpdateAssemblyBOM")
            {
                ApplicationArea = all;
                Caption = 'Update Assembly BOM';
                Image = BOM;

                trigger OnAction()
                begin
                    // will do the code later
                    //MESSAGE('Update Assembly BOM');
                    //Fazle05242016-->
                    IF rec."Master Item No." THEN BEGIN
                        InsertAssmBOM;
                        MESSAGE('Assembly BOM Updated.');
                    END;
                    //Fazle05242016--<
                end;
            }
        }
    }
    var
        gblnPageEditable: Boolean;

    trigger OnAfterGetRecord()
    var
        lcuRecalcMfgCost: Codeunit "Ryco Recalc Mfg Cost";
    begin
        //FH20160928-->
        IF rec."Assembly BOM" THEN BEGIN
            lcuRecalcMfgCost.Code(rec."No.");  //nj20190405
            rec."Mfg. Cost" := LocCalcMfgCost(rec."No.");
        END;
    end;

    trigger OnOpenPage()
    var
        grecAccessControl: Record "Access Control";

    begin
        gblnPageEditable := TRUE;
        grecAccessControl.SETRANGE("User Name", USERID);
        grecAccessControl.SETRANGE("Role ID", 'RYC-ITEM, NON-EDIT');
        IF grecAccessControl.FINDFIRST THEN
            gblnPageEditable := FALSE;
    end;


    procedure AdjustEditable(IsEditable: Boolean)
    var
    begin
        gblnPageEditable := IsEditable;
    end;

    local procedure LocCalcMfgCost(pcodItemNo: Code[20]): Decimal
    var
        lrecBOMComponent: Record "BOM Component";
        lrecItem: Record Item;
        ldecMfgCost: Decimal;
        lrecIUOM: Record "Item Unit of Measure";
        lrecUOMConvert: Decimal;
    begin
        //nj20190409 - Start
        CLEAR(ldecMfgCost);
        IF lrecItem."Assembly BOM" THEN BEGIN
            lrecBOMComponent.RESET;
            lrecBOMComponent.SETRANGE("Parent Item No.", pcodItemNo);
            lrecBOMComponent.SETRANGE(Type, lrecBOMComponent.Type::Item);
            lrecBOMComponent.SETFILTER("No.", '<>%1', '');
            IF lrecBOMComponent.FINDSET THEN BEGIN
                REPEAT
                    IF lrecItem.GET(lrecBOMComponent."No.") THEN BEGIN
                        lrecIUOM.RESET;
                        lrecIUOM.SETRANGE("Item No.", lrecBOMComponent."No.");
                        lrecIUOM.SETRANGE(Code, lrecBOMComponent."Unit of Measure Code");
                        IF lrecIUOM.FINDSET THEN
                            lrecUOMConvert := lrecIUOM."Qty. per Unit of Measure"
                        ELSE
                            lrecUOMConvert := 1;
                        lrecBOMComponent.CALCFIELDS("Assembly BOM");
                        IF (lrecBOMComponent."Assembly BOM") AND (lrecItem."Mfg. Cost" > 0) THEN
                            ldecMfgCost += lrecItem."Mfg. Cost" * lrecBOMComponent."Quantity per" * lrecUOMConvert
                        ELSE
                            ldecMfgCost += lrecItem."Unit Cost" * lrecBOMComponent."Quantity per" * lrecUOMConvert;
                    END;
                UNTIL lrecBOMComponent.NEXT = 0;
            END;
        END;
        EXIT(ldecMfgCost);
        //nj20190409 - End
    end;

    LOCAL procedure InsertAssmBOM()
    var
        lrecItem: Record Item;
        lrecBOMComponent: Record "BOM Component";
        lrecBOMComponentForInsert: Record "BOM Component";
    begin
        //Fazle06152016
        lrecItem.RESET;
        lrecItem.SETRANGE("Linked to Master Item No.", rec."No.");
        IF lrecItem.FINDSET THEN BEGIN
            REPEAT
                lrecBOMComponent.RESET;
                lrecBOMComponent.SETRANGE("Parent Item No.", rec."No.");
                IF lrecBOMComponent.FINDSET THEN BEGIN
                    //Delete Anything in Child Item Under Line # one million
                    lrecBOMComponentForInsert.RESET;
                    lrecBOMComponentForInsert.SETRANGE("Parent Item No.", lrecItem."No.");
                    lrecBOMComponentForInsert.SETFILTER("Line No.", '<%1', 1000000);
                    IF lrecBOMComponentForInsert.FINDFIRST THEN BEGIN
                        lrecBOMComponentForInsert.DELETEALL;
                    END;
                    REPEAT
                        //insert all records from Master Item
                        lrecBOMComponentForInsert.INIT;
                        lrecBOMComponentForInsert.COPY(lrecBOMComponent);
                        lrecBOMComponentForInsert."Parent Item No." := lrecItem."No.";
                        lrecBOMComponentForInsert.VALIDATE("Ink Percentage", lrecBOMComponent."Ink Percentage");
                        lrecBOMComponentForInsert.INSERT(TRUE);
                    UNTIL lrecBOMComponent.NEXT = 0;
                END;
            UNTIL lrecItem.NEXT = 0;
        END;
        /*
        {
        //Fazle 06062016
        lrecItem.RESET;
        lrecItem.SETRANGE("Linked to Master Item No.","No.");
        IF lrecItem.FINDSET THEN BEGIN
          REPEAT
            lrecBOMComponent.RESET;
            lrecBOMComponent.SETRANGE("Parent Item No.","No.");
            IF lrecBOMComponent.FINDSET THEN BEGIN
              CLEAR(lintLineNo);
              lrecBOMComponentForInsert.RESET;
              lrecBOMComponentForInsert.SETRANGE("Parent Item No.",lrecItem."No.");
              IF lrecBOMComponentForInsert.FINDLAST THEN BEGIN
                lintLineNo:=lrecBOMComponentForInsert."Line No.";
              END;
              REPEAT
                lrecBOMComponentForInsert.RESET;
                lrecBOMComponentForInsert.SETRANGE("Parent Item No.",lrecItem."No.");
                lrecBOMComponentForInsert.SETRANGE(Type,lrecBOMComponent.Type);
                lrecBOMComponentForInsert.SETRANGE("No.",lrecBOMComponent."No.");
                lrecBOMComponentForInsert.SETRANGE(Description,lrecBOMComponent.Description);
                lrecBOMComponentForInsert.SETRANGE("Unit of Measure Code",lrecBOMComponent."Unit of Measure Code");
                lrecBOMComponentForInsert.SETRANGE("Ink Percentage",lrecBOMComponent."Ink Percentage");
                IF lrecBOMComponentForInsert.FINDFIRST THEN BEGIN
                  //If Matching Delete and Insert
                  lrecBOMComponentForInsert.DELETEALL;
                  lintLineNo+=10000;
                  lrecBOMComponentForInsert.INIT;
                  lrecBOMComponentForInsert.COPY(lrecBOMComponent);
                  lrecBOMComponentForInsert."Parent Item No.":=lrecItem."No.";
                  lrecBOMComponentForInsert."Line No.":=lintLineNo;
                  lrecBOMComponentForInsert.VALIDATE("Ink Percentage",lrecBOMComponent."Ink Percentage");
                  lrecBOMComponentForInsert.INSERT(TRUE);
                END
                ELSE BEGIN
                  //insert
                  lintLineNo+=10000;
                  lrecBOMComponentForInsert.INIT;
                  lrecBOMComponentForInsert.COPY(lrecBOMComponent);
                  lrecBOMComponentForInsert."Parent Item No.":=lrecItem."No.";
                  lrecBOMComponentForInsert."Line No.":=lintLineNo;
                  lrecBOMComponentForInsert.VALIDATE("Ink Percentage",lrecBOMComponent."Ink Percentage");
                  lrecBOMComponentForInsert.INSERT(TRUE);
                END;
              UNTIL lrecBOMComponent.NEXT=0;
            END;
          UNTIL lrecItem.NEXT=0;
        END;
        }
        //Fazle05242016
        {
        lrecItem.RESET;
        lrecItem.SETRANGE("Linked to Master Item No.","No.");
        IF lrecItem.FINDSET THEN BEGIN
          lrecBOMComponent.RESET;
          lrecBOMComponent.SETRANGE("Parent Item No.","No.");
          lrecBOMComponent.SETRANGE(Type,lrecBOMComponent.Type::Item);
          lrecBOMComponent.SETRANGE(Ink,TRUE);
          IF lrecBOMComponent.FINDSET THEN BEGIN
            REPEAT
              CLEAR(lintLineNo);
              lrecBOMComponentForInsert.RESET;
              lrecBOMComponentForInsert.SETRANGE("Parent Item No.",lrecItem."No.");
              IF lrecBOMComponentForInsert.FINDLAST THEN BEGIN
                lintLineNo:=lrecBOMComponentForInsert."Line No.";
              END;
              REPEAT
                lrecBOMComponentForInsert.RESET;
                lrecBOMComponentForInsert.SETRANGE("Parent Item No.",lrecItem."No.");
                lrecBOMComponentForInsert.SETRANGE(Type,lrecBOMComponentForInsert.Type::Item);
                lrecBOMComponentForInsert.SETRANGE("No.",lrecBOMComponent."No.");
                IF lrecBOMComponentForInsert.FINDFIRST THEN BEGIN
                  //modify
                  lrecBOMComponentForInsert.VALIDATE("Ink Percentage",lrecBOMComponent."Ink Percentage");
                  lrecBOMComponentForInsert.MODIFY(TRUE);
                END
                ELSE BEGIN
                  //insert
                  lintLineNo+=10000;
                  lrecBOMComponentForInsert.INIT;
                  lrecBOMComponentForInsert.COPY(lrecBOMComponent);
                  lrecBOMComponentForInsert."Parent Item No.":=lrecItem."No.";
                  lrecBOMComponentForInsert."Line No.":=lintLineNo;
                  lrecBOMComponentForInsert.VALIDATE("Ink Percentage",lrecBOMComponent."Ink Percentage");
                  lrecBOMComponentForInsert.INSERT(TRUE);
                END;
              UNTIL lrecBOMComponent.NEXT=0;
            UNTIL lrecItem.NEXT=0;
          END;
        END;
        }
        {//creating Assembly BOM when Current Item is not Master Item
        lrecBOMComponent.RESET;
        lrecBOMComponent.SETRANGE("Parent Item No.","Linked to Master Item No.");
        lrecBOMComponent.SETRANGE(Type,lrecBOMComponent.Type::Item);
        lrecBOMComponent.SETRANGE(Ink,TRUE);
        IF lrecBOMComponent.FINDSET THEN BEGIN
            CLEAR(lintLineNo);
            lrecBOMComponentForInsert.RESET;
            lrecBOMComponentForInsert.SETRANGE("Parent Item No.","No.");
            IF lrecBOMComponentForInsert.FINDLAST THEN BEGIN
              lintLineNo:=lrecBOMComponentForInsert."Line No.";
            END;
          REPEAT
            lrecBOMComponentForInsert.RESET;
            lrecBOMComponentForInsert.SETRANGE("Parent Item No.","No.");
            lrecBOMComponentForInsert.SETRANGE(Type,lrecBOMComponentForInsert.Type::Item);
            lrecBOMComponentForInsert.SETRANGE("No.",lrecBOMComponent."No.");
            IF lrecBOMComponentForInsert.FINDFIRST THEN BEGIN
              //modify
              lrecBOMComponentForInsert.VALIDATE("Ink Percentage",lrecBOMComponent."Ink Percentage");
              lrecBOMComponentForInsert.MODIFY(TRUE);
            END
            ELSE BEGIN
              //insert
              lintLineNo+=10000;
              lrecBOMComponentForInsert.INIT;
              lrecBOMComponentForInsert.COPY(lrecBOMComponent);
              lrecBOMComponentForInsert."Parent Item No.":="No.";
              lrecBOMComponentForInsert."Line No.":=lintLineNo;
              lrecBOMComponentForInsert.VALIDATE("Ink Percentage",lrecBOMComponent."Ink Percentage");
              lrecBOMComponentForInsert.INSERT(TRUE);
            END;
          UNTIL lrecBOMComponent.NEXT=0;
        END;
        }*/
    end;
}