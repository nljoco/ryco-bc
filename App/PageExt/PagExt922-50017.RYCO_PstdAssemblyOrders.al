pageextension 50017 "Ryc Pstd. Assembly Orders" extends "Posted Assembly Orders"
{
    /*
    smk2018.04.17 slupg: auto-merge the following:
    nj20170202
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
        // nj20170202 - Start
        lrecUserSetup.GET(USERID);
        IF lrecUserSetup."Location Code" <> '' THEN
            Rec.SETRANGE("Location Code", lrecUserSetup."Location Code");
        // nj20170202 - End
    end;

}