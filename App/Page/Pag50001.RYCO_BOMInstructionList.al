page 50001 "BOM Instruction List"
{
    Caption = 'BOM Instruction List';
    PageType = List;
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = "BOM Instruction";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Dryer; Rec.Dryer)
                {
                }
            }
        }
    }

    actions
    {
    }
}

