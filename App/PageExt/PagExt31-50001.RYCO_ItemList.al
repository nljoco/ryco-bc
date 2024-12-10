pageextension 50001 "Ryc Item List" extends "Item List"
{
    layout
    {
        addafter("Item Tracking Code")
        {
            field("Linked to Master Item No."; rec."Linked to Master Item No.")
            {
                ApplicationArea = All;
            }
            field("Master Item No."; rec."Master Item No.")
            {
                ApplicationArea = All;
            }
        }

        //Product group code has been removed

        modify("Type")
        {
            Visible = false;
        }
        modify("InventoryField")
        {
            Caption = 'Quantity on Hand';
        }
        modify("Substitutes Exist")
        {
            Visible = false;
        }
        modify("Search Description")
        {
            Visible = true;
            //ApplicationArea = Basic, Suite;
        }
        /*modify("Created From Catalog Item")
        {
            Visible = false;
        }*/
        modify(Blocked)
        {
            Visible = true;
        }
        modify("Item Category Code")
        {
            Visible = true;
        }
        modify("Assembly Policy")
        {
            Visible = true;
        }
        modify("Item Tracking Code")
        {
            Visible = true;
        }
        modify("Created From Nonstock Item")
        {
            Visible = true;
            Caption = 'Created from Nonstock Item';
        }
        modify("Last Date Modified")
        {
            Visible = true;
        }

        moveafter(InventoryField; "Assembly BOM")
        moveafter("Item Tracking Code"; "Created From Nonstock Item")
    }
}