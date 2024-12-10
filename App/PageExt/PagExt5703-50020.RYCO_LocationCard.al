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

        modify("County")
        {
            caption = 'State / ZIP code';
        }
        modify("Post Code")
        {
            Caption = 'ZIP Code';
        }
        modify("ElectronicDocument")
        {
            Visible = false;
        }
        modify("Fax No.")
        {
            Visible = true;
            Importance = Standard;
        }

        modify("Use ADCs")
        {
            Visible = true;
        }

        modify("Job")
        {
            Visible = false;
        }
    }

    actions
    {
    }

    var

}