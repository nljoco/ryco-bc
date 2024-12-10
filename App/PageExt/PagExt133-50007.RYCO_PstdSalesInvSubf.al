pageextension 50007 "Posted Sales Invoice Subform" extends "Posted Sales Invoice Subform"
{
    layout
    {

        modify("Item Reference No.")
        {
            Visible = false;
        }
        modify("Description 2")
        {
            Visible = true;
        }

        modify("Tax group code")
        {
            visible = true;
        }
        modify("Tax area code")
        {
            visible = false;
        }
    }
}