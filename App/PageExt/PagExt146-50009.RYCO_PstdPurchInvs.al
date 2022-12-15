pageextension 50009 "Ryc Pstd. Purch Invs" extends "Posted Purchase Invoices"
{
    /*
    smk2018.04.17 slupg: auto-merge untagged nav customization (new field: "Order No.")
    */
    layout
    {
        modify("Order No.")
        {
            Visible = true;
            Editable = false;
        }
    }

    actions
    {
    }

    var

}