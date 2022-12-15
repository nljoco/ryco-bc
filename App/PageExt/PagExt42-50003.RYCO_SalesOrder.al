pageextension 50003 "Ryc Sales Order" extends "Sales Order"
{
    /*
    smk2018.04.17 slupg: auto-merge the following:
    ID622, nj20170217
    - added printing of Cust./Item Sales bySalesperson Report to the Menu.
    */
    actions
    {
        addafter("Pick Instruction")
        {
            action("Ryc Commercial Invoice")
            {
                Caption = 'Commercial Invoice';
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                var
                    lrepCommercialInvoice: Report "Commercial Invoice";
                    lrecSalesHeader: Record "Sales Header";
                begin
                    //Fazle06072016-->
                    lrecSalesHeader.RESET;
                    lrecSalesHeader.SETRANGE("Document Type", Rec."Document Type");
                    lrecSalesHeader.SETRANGE("No.", Rec."No.");
                    IF lrecSalesHeader.FINDFIRST THEN BEGIN
                        CLEAR(lrepCommercialInvoice);
                        lrepCommercialInvoice.SETTABLEVIEW(lrecSalesHeader);
                        lrepCommercialInvoice.RUNMODAL;
                        CLEAR(lrepCommercialInvoice);
                    END;
                    //Fazle06072016--<
                end;
            }
        }

        addafter("Report Picking List by Order")
        {
            action("Ryc Cust/Item Sales by Salesperson")
            {
                Caption = 'Cust./Item Sales by Salesperson';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                var
                    lrecCustomer: Record Customer;
                    lrepSalesbySalesperson: Report "Cust./Item Sales bySalesperson";
                begin
                    lrecCustomer.RESET;
                    lrecCustomer.SETRANGE("No.", Rec."Sell-to Customer No.");
                    lrepSalesbySalesperson.SETTABLEVIEW(lrecCustomer);
                    lrepSalesbySalesperson.USEREQUESTPAGE(TRUE);
                    lrepSalesbySalesperson.RUNMODAL;
                end;
            }
        }
    }

    var

}