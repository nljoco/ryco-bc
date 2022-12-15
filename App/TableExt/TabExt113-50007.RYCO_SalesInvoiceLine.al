tableextension 50007 "RYCO Sales Invoice Line" extends "Sales Invoice Line"
{
    /*
        smk2018.04.17 slupg auto-merge the following untagged changes
        new fields 50010,50020,50030
    */
    fields
    {
        // Add changes to table fields here
        field(50000; "Selling Unit of Measure"; Code[10])
        {
            CaptionML = ENU = 'Selling Unit of Measure';
            DataClassification = ToBeClassified;
        }
        field(50001; "Selling Qauntity"; Decimal)
        {
            CaptionML = ENU = 'Selling Quantity';
            DataClassification = ToBeClassified;
        }
        field(50002; "Selling Unit Price"; Decimal)
        {
            CaptionML = ENU = 'Selling Unit Price';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}