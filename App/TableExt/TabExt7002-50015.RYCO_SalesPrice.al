tableextension 50015 "RYCO Sales Price" extends "Sales Price"
{
    /*
    smk2018.04.17 slupg: automerge the following:
    nj20180123
        - added Item Category Code field

    ID2288, nj20190401
        - changed Item Category Code fieldclass to Normal
    */

    fields
    {
        // Add changes to table fields here
        field(50000; "Item Category Code"; Code[10])
        {
            //nj20180123
            Caption = 'Item Category Code';
            Editable = false;
            TableRelation = "Item Category";
        }
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
            begin
                //ID2288 - Start
                "Item Category Code" := '';
                IF "Item No." <> '' THEN BEGIN
                    IF Item.GET("Item No.") THEN
                        "Item Category Code" := Item."Item Category Code";
                END;
                //ID2288 - End;
            end;
        }
    }
}