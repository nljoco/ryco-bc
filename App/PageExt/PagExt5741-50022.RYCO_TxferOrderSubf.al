pageextension 50022 "Ryc Transfer ORder Subform" extends "Transfer Order Subform"
{
    layout
    {
        modify("Custom Transit Number")
        {
            Visible = false;
        }
        modify("Description 2")
        {
            Visible = true;
        }
        moveafter(Description; "Description 2")
    }
}