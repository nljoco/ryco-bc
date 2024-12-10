tableextension 50005 "RYCO User Setup" extends "User Setup"
{
    /*
    smk2018.04.17 slupg: automerge the following
    nj20170123
    - added Location Code Field

    */
    fields
    {
        // Add changes to table fields here
        field(50000; "Location Code"; Code[10])
        {
            //nj20170123
            Caption = 'Location Code';
            TableRelation = Location;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;

        }
    }
}