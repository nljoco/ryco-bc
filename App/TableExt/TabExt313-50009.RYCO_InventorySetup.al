tableextension 50009 "RYCO Inventory Setup" extends "Inventory Setup"
{
    /*
    smk2018.04.17 slupg: auto-merge the following changes:
        ID623, nj20170221
        - added Below Safety Stock E-Mail field
        used when sending Items Below Safety Stock Report

    ID623, RPD, 2017.02.22
        - Changed fieldname to "Low Stock Notif. Email"
    */
    fields
    {
        // Add changes to table fields here
        field(50000; "Low Stock Notif. Email"; Text[80])
        {
            //ID623
            Caption = 'Low Stock Notif. Email';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}