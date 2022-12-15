tableextension 50011 "RYCO Assembly Line" extends "Assembly Line"
{
    /*
    smk2018.04.17 slupg: automerge the following
    nj20160429
        - added Instruction Code, Colour Percentage, Colour fields.
    */
    fields
    {
        // Add changes to table fields here
        field(50000; "Instruction Code"; Code[20])
        {
            //nj20160429
            Caption = 'Instruction Code';
            DataClassification = ToBeClassified;
        }
        field(50001; "Ink Percentage"; Decimal)
        {
            //nj20160429
            Caption = 'Ink Percentage';
            DataClassification = ToBeClassified;
        }
        field(50002; "Ink"; Boolean)
        {
            //nj20160429
            Caption = 'Ink';
            DataClassification = ToBeClassified;
        }
    }
}