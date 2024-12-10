pageextension 50006 "Ryc User Setup" extends "User Setup"
{
    /*
    smk2018.04.17 slupg: auto-merge the following:
    nj20170123
    - added Location Code field.
    */
    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("Location Code"; Rec."Location Code")
            {
                ApplicationArea = All;
            }
        }

        modify("Allow Deferral Posting From")
        {
            Visible = false;
        }
        modify("Allow Deferral Posting To")
        {
            Visible = false;
        }
        modify("Service Resp. Ctr. Filter")
        {
            ApplicationArea = all;
            Visible = true;
        }
        modify("PhoneNo")
        {
            visible = false;
        }
    }

    actions
    {
    }

    var

}