tableextension 50014 "RYCO Item Category" extends "Item Category"
{
    /*
    smk2018.04.17 slupg: automerge the following changes
    nj20160505
        - added Paint field.

    FH20161031
        - New Fields Added: Labour %,Labour$
    */
    fields
    {
        field(50000; "Ink"; Boolean)
        {
            //nj20160505
            Caption = 'Ink';
            DataClassification = ToBeClassified;
        }
        field(50010; "Labour%"; Decimal)
        {
            //FH20161031
            Caption = 'Labour%';
            DataClassification = ToBeClassified;
        }
        field(50020; "Labour$"; Decimal)
        {
            //FH20161031
            Caption = 'Labour$';
            DataClassification = ToBeClassified;
        }
    }
}