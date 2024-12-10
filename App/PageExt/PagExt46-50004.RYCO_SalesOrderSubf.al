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

        modify("Description 2")
        {
            Visible = true;
        }
        modify("Tax Area Code")
        {
            Visible = false;
        }
        modify("Line Amount")
        {
            visible = true;
        }
        modify("Amount Including VAT")
        {
            visible = true;
        }
        modify("Drop Shipment")
        {
            Visible = true;
        }
        modify("Purchasing Code")
        {
            Visible = true;
        }

        addafter("Unit Price")
        {
            field("Selling Unit of Measure"; Rec."Selling Unit of Measure")
            {
                ApplicationArea = all;
                Caption = 'Selling Unit of Measure';
            }
            field("Selling Qauntity"; Rec."Selling Qauntity")
            {
                ApplicationArea = all;
                Caption = 'Selling Quantity';
            }
            field("Selling Unit Price"; Rec."Selling Unit Price")
            {
                ApplicationArea = all;
                Caption = 'Selling Unit Price';
            }
        }
    }
}