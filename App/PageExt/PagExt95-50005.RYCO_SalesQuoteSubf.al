pageextension 50005 "Ryc Sales Quote Subform" extends "Sales Quote Subform"
{
    /*
    smk2018.04.09 SLUPG
    -------------------
    changed control 12 IsEditable to FALSE
    (NAV2018 orig property value was "NOT IsCommentLine")
    */
    layout
    {
        addafter("Qty. to Assemble to Order")
        {
            field("Reserved Quantity"; rec."Reserved Quantity")
            {
                ApplicationArea = All;
            }
        }

        addafter("Line discount %")
        {
            field("Qty. to Ship"; rec."Qty. to Ship")
            {
                ApplicationArea = All;
            }
            field("Qty. Shipped"; rec."Qty. Shipped (Base)")
            {
                ApplicationArea = All;
            }
            field("Qty. to Invoice"; rec."Qty. to Invoice")
            {
                ApplicationArea = All;
            }
            field("Qty. Invoiced"; rec."Qty. Invoiced (Base)")
            {
                ApplicationArea = All;
            }
        }

        addafter("Unit Price")
        {
            field("Selling Unit of Measure"; rec."Selling Unit of Measure")
            {
                ApplicationArea = All;
            }
            field("Selling Quantity"; rec."Selling Qauntity")
            {
                ApplicationArea = ALl;
            }
            field("Selling unit Price"; rec."Selling Unit Price")
            {
                ApplicationArea = All;
            }
        }

        modify("Unit Price")
        {
            Visible = true;
            Editable = false;
        }

        modify("Item Reference No.")
        {
            Visible = false;
        }
        modify("Description 2")
        {
            Visible = true;
        }
        modify("Tax area code")
        {
            Visible = false;
        }

        modify("Unit of measure")
        {
            Visible = false;
        }
    }

    actions
    {
    }

    var

}