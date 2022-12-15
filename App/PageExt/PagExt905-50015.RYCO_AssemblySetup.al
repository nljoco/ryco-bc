pageextension 50015 "Ryc Assembly Setup" extends "Assembly Setup"
{
    /*
    smk2018.04.17 slupg: auto-merge the following
    FH20160929 SCP, Fazle
        - Adding New Field "Instruction Code 2" for Build Quantity field OK32X
    nj20170123
    - added Assembly Order Nos. - MTL, Pstd Assembly Order Nos. - MTL,
            Assembly Order Nos. - CGY, Pstd Assembly Order Nos. - CGY fields

    nj20181031
    - Added Build Instructions for OK32UV, OK32LED
    */
    layout
    {
        addafter("Copy Comments when Posting")
        {
            field("Instruction Code"; Rec."Instruction Code")
            {
                ApplicationArea = All;
                Caption = 'Instruction For Assembly BOM';
            }
            field("Instruction Code 2"; Rec."Instruction Code 2")
            {
                ApplicationArea = All;
                Caption = 'Instruction 2 For Assembly BOM';
            }
            field("Instruction Code 3"; Rec."Instruction Code 3")
            {
                ApplicationArea = All;
                Caption = 'Instruction 3 For Assembly BOM';
            }
            field("Instruction Code 4"; Rec."Instruction Code 4")
            {
                ApplicationArea = All;
                Caption = 'Instruction 4 For Assembly BOM';
            }
            field("Instruction Code 5"; Rec."Instruction Code 5")
            {
                ApplicationArea = All;
                Caption = 'Instruction 5 For Assembly BOM';
            }
        }
        addafter("Posted Assembly Order Nos.")
        {
            field("Assembly Order Nos. - MTL"; Rec."Assembly Order Nos. - MTL")
            {
                ApplicationArea = All;
            }
            field("Pstd Assembly Order Nos. - MTL"; Rec."Pstd Assembly Order Nos. - MTL")
            {
                ApplicationArea = All;
            }
            field("Assembly Order Nos. - CGY"; Rec."Assembly Order Nos. - CGY")
            {
                ApplicationArea = All;
            }
            field("Pstd Assembly Order Nos. - CGY"; Rec."Pstd Assembly Order Nos. - CGY")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }

    var
}
