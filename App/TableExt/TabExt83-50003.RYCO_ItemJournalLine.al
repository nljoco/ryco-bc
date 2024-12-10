tableextension 50003 "RYCO Item Journal Line" extends "Item Journal Line"
{
    /*
    smk2018.04.17 slupg: automerge the following
        FH20161116
        - New Field Shelf No. (Running the process "Calculate Inventory" will populate the value from the field "Shelf No." in the item table)
        nj20170201
        - added SubKey: Shelf No.,Item No.

    */
    fields
    {
        field(50000; "Shelf No."; Code[10])
        {
            //FH20161116
            Caption = 'Shelf No.';
            //CaptionML = ENU = 'Shelf No.', ESM = 'Nº estante', FRC = 'N° de tablette', ENC = 'Shelf No.';
            DataClassification = ToBeClassified;
        }
    }
    // keys
    // {
    //     key(key6; "Shelf No.", "Item No.")
    //     {

    //     }
    // }

}