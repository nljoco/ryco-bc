report 50017 "Set Item Labour to zero"
{
    DefaultLayout = RDLC;
    RDLCLayout = './App/Layout-Rdl/Rep50017.RYCO_SetItemLabourtozero.rdlc';

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                Item.Validate("Labour$", 0);
                Item.Validate("Labour%", 0);
                Item.Modify;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }
}

