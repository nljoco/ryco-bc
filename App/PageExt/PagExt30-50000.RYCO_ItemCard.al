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
        addafter("Use Cross-Docking")
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

        modify(Item)
        {
            Editable = gblnPageEditable;
        }

    }

    actions
    {
    }

    var
        gblnPageEditable: Boolean;

    trigger OnOpenPage()
    var
        recAccessControl: Record "Access Control";
    begin
        // nj20170126 - Start
        gblnPageEditable := TRUE;
        recAccessControl.SETRANGE("User Name", USERID);
        recAccessControl.SETRANGE("Role ID", 'RYC-ITEM, NON-EDIT');
        IF recAccessControl.FINDFIRST THEN
            gblnPageEditable := FALSE;
        // nj20170126 - End
    end;

}