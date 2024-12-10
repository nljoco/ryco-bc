tableextension 50006 "RYCO Sales Shipment Line" extends "Sales Shipment Line"
{
    /*
        smk2018.04.17 slupg: auto-merge untagged modifications
        Field 50010,50020,50030
    */

    fields
    {
        // Add changes to table fields here
        field(50010; "Selling Unit of Measure"; Code[10])
        {
            Caption = 'Selling Unit of Measure';
            DataClassification = ToBeClassified;

        }
        field(50020; "Selling Qauntity"; Decimal)
        {
            Caption = 'Selling Quantity';
            DataClassification = ToBeClassified;
            //Enabled = False;
        }
        field(50030; "Selling Unit Price"; Decimal)
        {
            Caption = 'Selling Unit Price';
            DataClassification = ToBeClassified;
        }
    }
}