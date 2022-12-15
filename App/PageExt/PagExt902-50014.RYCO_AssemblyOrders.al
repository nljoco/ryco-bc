pageextension 50014 "Ryc Assembly Orders" extends "Assembly Orders"
{
    /*
    smk2018.04.27 slupg: auto-merge the following:
    nj20170123
    - List only Orders depending on User Location Code.
    - If user Location Code is Blank, display all.
    */
    layout
    {
    }

    actions
    {
    }

    var

    trigger OnOpenPage()
    var
        lrecUserSetup: Record "User Setup";
    begin
        // nj20170123 - Start
        lrecUserSetup.GET(USERID);
        //IF (lrecUserSetup."Location Code" = 'MONTREAL') OR (lrecUserSetup."Location Code" = 'CALGARY') THEN
        IF lrecUserSetup."Location Code" <> '' THEN
            Rec.SETRANGE("Location Code", lrecUserSetup."Location Code");
        // nj20170123 - End
    end;

}