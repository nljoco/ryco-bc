pageextension 50019 "Ryc Item Units of Measure" extends "Item Units of Measure"
{
    /*
    smk2018.04.17 slupg: auto-merge the following untagged modifications:
    - new field 1000000000 1 per qty. per unit of measure 
    - change decimalplaces for field 4 to 0:5
    */
    layout
    {
        addafter(Code)
        {
            field("1 per Qty. per Unit of Measure"; Rec."1 per Qty. per Unit of Measure")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }

    var

}