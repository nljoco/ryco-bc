pageextension 50003 "Ryc Sales Order" extends "Sales Order"
{
    /*
    smk2018.04.17 slupg: auto-merge the following:
    ID622, nj20170217
    - added printing of Cust./Item Sales bySalesperson Report to the Menu.
    */


    layout
    {
        addafter("SelectedPayments")
        {
            field("Invoice Transaction Type"; Rec."Transaction Specification")
            {
                ApplicationArea = All;
                Caption = 'Transaction Type';
                ToolTip = 'Specifies a specification of the document''s transaction, for the purpose of reporting to INTRASTAT.';
            }
        }

        modify("Sell-to contact")
        {
            Editable = true;
        }
        /*modify(Status)
        {
            Visible = false;
        }*/

        modify("Company Bank Account Code")
        {
            Visible = false;
        }
        modify("VAT bus. posting group")
        {
            Visible = false;
        }

        modify("Ship-to code")
        {
            Visible = true;
        }
        modify("Ship-to Name")
        {
            Visible = true;
        }
        modify("Ship-to Address")
        {
            Visible = true;
        }
        modify("Ship-to Address 2")
        {
            Visible = true;
        }
        modify("Ship-to City")
        {
            Visible = true;
        }
        modify("Ship-to UPS Zone")
        {
            Visible = true;
        }
        modify("Sell-to county")
        {
            Visible = true;
            Caption = 'State';
        }
        modify("Sell-to Post Code")
        {
            Visible = true;
            Caption = 'ZIP code';
            ToolTip = 'Specifies the ZIP code';
        }
        modify("Sell-to Country/Region Code")
        {
            Visible = false;
        }
        modify("Combine Shipments")
        {
            Visible = false;
        }
        modify("Completely shipped")
        {
            Visible = false;
        }

        modify("Transaction Specification")
        {
            Visible = true;
            //ApplicationArea = All;
        }
        modify("Transport Method")
        {
            Visible = true;
            //ApplicationArea = All;
        }
        modify("Exit Point")
        {
            Visible = true;
            //ApplicationArea = All;
        }
        modify("Area")
        {
            Visible = true;
            //ApplicationArea = All;
        }

        modify("Sell-to Phone No.")
        {
            Visible = false;
        }
        modify("SellToMobilePhoneNo")
        {
            Visible = false;
        }
        modify("Sell-to E-mail")
        {
            Visible = false;
        }
        modify("Sell-to Contact No.")
        {
            Visible = true;
        }
        modify("Your Reference")
        {
            Visible = false;
        }

        modify("Payment method code")
        {
            Visible = true;
        }
        modify("Pmt. Discount Date")
        {
            Visible = true;
        }
    }

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