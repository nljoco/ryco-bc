pageextension 50023 "Ryc Sales Prices" extends "Sales Prices"
{
    /*
    smk2018.04.17 slupg: auto-merge the following changes
    nj20180123
    - displayed Item Category Code field
    */
    layout
    {
        addafter("VAT Bus. Posting Gr. (Price)")
        {
            field("Item Category Code"; Rec."Item Category Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
    }

    var

}