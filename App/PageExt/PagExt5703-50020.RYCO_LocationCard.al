pageextension 50020 "Ryc Location Card" extends "Location Card"
{
    /*
    smk2018.04.17 slupg: auto-merge the following:
    ID623, RPD, 2017.02.22
    - Add "Low Stock Notification" to General tab
    */
    layout
    {
        addafter("Provincial Tax Area Code")
        {
            field("Low Stock Notification"; Rec."Low Stock Notification")
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