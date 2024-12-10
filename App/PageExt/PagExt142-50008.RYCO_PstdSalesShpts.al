pageextension 50008 "Ryc Pstd. Sales Shpts" extends "Posted Sales Shipments"
{
    /*
    SMK2018.04.09 SLUPG
    ===================
    merged the following from OnOpenPage
    nj20170202
    - List only Orders depending on User Location Code.
    - If user Location Code is Blank, display all.
    */
    layout
    {
        modify("Ship-to Country/Region Code")
        {
            caption = 'State';
        }
        modify("Ship-to Post Code")
        {
            Caption = 'ZIP code';
        }

        modify("Document Date")
        {
            Visible = true;
        }
        modify("Ship-to code")
        {
            Visible = true;
        }
        modify("Posting Date")
        {
            Visible = true;
        }
        modify("Requested Delivery Date")
        {
            Visible = true;
        }
        modify("Shipment Date")
        {
            Visible = true;
        }
        modify("Sell-to contact")
        {
            Visible = true;
        }
    }

    actions
    {
    }

    var

    trigger OnOpenPage()
    var
        lrecUserSetup: Record "User Setup";
    begin
        //////////////////////////////////////////
        //BEGIN add smk2018.04.09 SLUPG
        //      from nav2016 modified
        //////////////////////////////////////////
        // nj20170202 - Start
        lrecUserSetup.GET(USERID);
        IF lrecUserSetup."Location Code" <> '' THEN
            Rec.SETRANGE("Location Code", lrecUserSetup."Location Code");
        // nj20170202 - End
        //////////////////////////////////////////
        //END add smk2018.04.09 SLUPG
        //////////////////////////////////////////
    end;
}