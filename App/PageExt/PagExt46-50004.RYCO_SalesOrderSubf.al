pageextension 50004 "Ryc Sales Order Subform" extends "Sales Order Subform"
{
    /*
    smk2018.04.09 SLUPG
    -------------------
    changed control 12 IsEditable to FALSE
    (NAV2018 orig property value was "NOT IsCommentLine")
    */
    layout
    {
        modify("Unit Price")
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