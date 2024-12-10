pageextension 50010 "Ryc Phys. Inventory Journal" extends "Phys. Inventory Journal"
{
    /*
    smk2018.04.17 slupg: auto-merge the following:
    FH20161116
        - New Field Shelf No. (Running the process "Calculate Inventory" will populate the value from the field "Shelf No." in the item table)
    */
    layout
    {
        addafter(ShortcutDimCode8)
        {
            field("Shelf No."; Rec."Shelf No.")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        modify(CalculateInventory)
        {
            Visible = false;
            Enabled = false;
        }
        addbefore(CalculateCountingPeriod)
        {
            action(RycCalculateInventory)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Ryc Calculate Inventory';
                Ellipsis = true;
                Image = CalculateInventory;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Category5;
                Scope = Repeater;
                ToolTip = 'Start the process of counting inventory by filling the journal with known quantities.';

                trigger OnAction()
                var
                    CalcQtyOnHand: Report "RYCO Calculate Inventory";
                begin
                    CalcQtyOnHand.SetItemJnlLine(Rec);
                    CalcQtyOnHand.RunModal;
                    Clear(CalcQtyOnHand);
                end;
            }
        }
    }

    var

}