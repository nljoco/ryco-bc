pageextension 50013 "Ryc Assembly Order Subf" extends "Assembly Order Subform"
{
    /*
    smk2018.04.17 slupg: auto-merge the following untagged changes
    - field 1000000001, 1000000002, 1000000003
    */
    layout
    {
        addafter("Appl.-from Item Entry")
        {
            field("Instruction Code"; Rec."Instruction Code")
            {
                ApplicationArea = All;
            }
            field("Ink Percentage"; Rec."Ink Percentage")
            {
                ApplicationArea = All;
            }
            field(Ink; Rec.Ink)
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
