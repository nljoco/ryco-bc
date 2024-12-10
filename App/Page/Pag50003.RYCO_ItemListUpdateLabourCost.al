page 50003 "Item List - Update Labour Cost"
{
    Caption = 'Item List - Update Labour Cost';
    SourceTable = Item;
    SourceTableView = SORTING("No.")
                      ORDER(Ascending)
                      WHERE("Assembly BOM" = CONST(true));
    ApplicationArea = All;
    UsageCategory = Lists;

    PageType = List;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                }
                field("Material Cost"; Rec."Material Cost")
                {
                }
                field("Labour%"; Rec."Labour%")
                {
                }
                field("Labour$"; Rec."Labour$")
                {
                }
                field("Mfg. Cost"; Rec."Mfg. Cost")
                {
                }
                field("Mfg. Cost (Kg.)"; Rec."Mfg. Cost (Kg.)")
                {
                }
            }
        }
    }

    actions
    {
    }
}

