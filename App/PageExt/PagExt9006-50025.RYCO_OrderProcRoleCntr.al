pageextension 50025 "Ryc Order Procr Role Cntr" extends "Order Processor Role Center"
{
    /*
    smk2018.04.17 slupg: auto-merge the following untagged changes
    new action 1000000000 "Assembly Orders"
    */
    actions
    {
        addafter(SalesJournals)
        {
            action("Ryc Assembly Orders")
            {
                Caption = 'Assembly Orders';
                ApplicationArea = All;
                Image = AssemblyOrder;
                RunObject = Page "Assembly Orders";

            }
        }
    }

    var

}