pageextension 50011 "Ryc Inventory Setup" extends "Inventory Setup"
{
    /*
    smk2018.04.17 slupg: auto-merge the following
    ID623, RPD, 2017.02.22
    - Add "Low Stock Notif. Email" to General tab
    */
    layout
    {
        addafter("Use Item References")
        {
            field("Low Stock Notif. Email"; Rec."Low Stock Notif. Email")
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