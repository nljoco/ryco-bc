page 50002 "Build Quantity List"
{
    SourceTable = "Build Quantity";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Build Conversion"; Rec."Build Conversion")
                {
                }
                field("Number of Cans"; Rec."Number of Cans")
                {
                }
                field("Build Quantity"; Rec."Build Quantity")
                {
                }
                field("Build Quantity 2"; Rec."Build Quantity 2")
                {
                }
                field("Build Quantity OK32LT"; Rec."Build Quantity OK32LT")
                {
                }
                field("Build Quantity OK32UV"; Rec."Build Quantity OK32UV")
                {
                }
                field("Build Quantity OK32LED"; Rec."Build Quantity OK32LED")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1000000001; Links)
            {
                Visible = false;
            }
            systempart(Control1000000000; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

