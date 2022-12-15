pageextension 50010 "Ryc Phys. Inventory Journal" extends "Phys. Inventory Journal"
{
    /*
    smk2018.04.17 slupg: auto-merge the following:
    FH20161116
        - New Field Shelf No. (Running the process "Calculate Inventory" will populate the value from the field "Shelf No." in the item table)
    */
    layout
    {
        addafter(ShortcutDimCode8)
        {
            field("Shelf No."; Rec."Shelf No.")
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