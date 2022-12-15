pageextension 50024 "Ryc Sales Price Wksht" extends "Sales Price Worksheet"
{
    /*
    smk2018.04.17 slupg: auto-merge the following
    //ID461 Fazle, SCPLLP 20161206 10:00 AM
        - Suggest Sales Price on Wksht Based on Cost
        - created 4 New Fields:
            Mfg. Cost.
            Last Direct Cost
            Adj $
            ADj %
        - New Action to call new Report 50011 (Suggest Sales Price from Cost)
    nj20180123
    - displayed Item Category Code field
    ID938, nj20180124
    - added function to "Suggest All Cust Sales Price" (R50015)
    jl20180124
    - change Mfg. Cost caption to Mfg. Cost (Kg)
    */
    layout
    {
        addafter("Allow Line Disc.")
        {
            field("Last Direct Cost"; Rec."Last Direct Cost")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Mfg. Cost"; Rec."Mfg. Cost")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Mfg. Cost (Kg)';
            }
            field("Adj%"; Rec."Adj%")
            {
                ApplicationArea = All;
            }
            field("Adj$"; Rec."Adj$")
            {
                ApplicationArea = All;
            }
            field("Item Category Code"; Rec."Item Category Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        addlast("F&unctions")
        {
            action("Ryc Suggest Sales Price on Wksh. from Cost Change Line")
            {
                Caption = 'Suggest Sales Price on Wksh. from Cost';
                ApplicationArea = All;
                Image = Suggest;
                trigger OnAction()
                var
                begin
                    REPORT.RUNMODAL(REPORT::"Suggest Sales Price from Cost", TRUE, TRUE);//ID461
                end;
            }
            action("Ryc Suggest All Customer Sales Price")
            {
                Caption = 'Suggest All Customer Sales Price';
                ApplicationArea = All;
                Image = SalesPrices;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Report "Suggest All Cust Sales Price";
            }
            action("Ryc Refresh Item Mfg. Cost")
            {
                Caption = 'Refresh Item Mfg. Cost';
                ApplicationArea = All;
                Image = Recalculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Report "Suggest All Cust Sales Price";

                trigger OnAction()
                var
                    lcuRecalcMfgCost: Codeunit "Ryco Recalc Mfg Cost";
                    lrecSPW: Record "Sales Price Worksheet";
                begin
                    lcuRecalcMfgCost.Code(Rec."Item No.");  //nj20190327
                                                            //
                    lrecSPW.RESET;
                    lrecSPW.COPY(Rec);
                    IF lrecSPW.FINDSET THEN
                        REPEAT
                            lrecSPW.VALIDATE("Item No.");
                            lrecSPW.MODIFY(TRUE);
                        UNTIL lrecSPW.NEXT = 0;
                end;
            }
        }
    }
    var

}