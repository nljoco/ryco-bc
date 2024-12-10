report 50014 "Items Below Safety Stock"
{
    // ID623, RPD, 2017.02.24
    //  - newish report
    DefaultLayout = RDLC;
    RDLCLayout = './App/Layout-Rdl/Rep50014.RYCO_ItemsBelowSafetyStock.rdlc';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;


    dataset
    {
        dataitem(Location; Location)
        {
            DataItemTableView = SORTING(Code) WHERE("Low Stock Notification" = CONST(true));
            dataitem(Item; Item)
            {
                DataItemTableView = SORTING("No.");
                column(Name_CompanyInfo; CompanyInfo.Name)
                {
                }
                column(No_Item; Item."No.")
                {
                }
                column(Description_Item; Item.Description)
                {
                }
                column(TotalQty; gdecTotalQty)
                {
                }
                column(SafetyStockQty_Item; Item."Safety Stock Quantity")
                {
                }

                trigger OnAfterGetRecord()
                var
                    ldecValue: Decimal;
                    lrecTL: Record "Transfer Line";
                    ldecShip: Decimal;
                    ldecRec: Decimal;
                begin
                    //VALIDATE("Location Filter",Location.Code);
                    SetFilter("Location Filter", Location.Code);
                    CalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Sales Order", "Qty. on Assembly Order", "Qty. on Asm. Component", "Trans. Ord. Receipt (Qty.)", "Trans. Ord. Shipment (Qty.)");


                    ldecShip := 0;
                    lrecTL.Reset;
                    lrecTL.SetRange("Item No.", "No.");
                    lrecTL.SetRange("Transfer-from Code", Location.Code);
                    lrecTL.CalcSums("Qty. to Ship (Base)");
                    ldecShip := lrecTL."Qty. to Ship (Base)";

                    ldecRec := 0;
                    lrecTL.Reset;
                    lrecTL.SetRange("Item No.", "No.");
                    lrecTL.SetRange("Transfer-to Code", Location.Code);
                    lrecTL.CalcSums("Qty. to Receive (Base)");
                    ldecRec := lrecTL."Qty. to Receive (Base)";


                    //ldecValue := Inventory + "Qty. on Purch. Order" + "Qty. on Assembly Order" + ldecRec;
                    //ldecValue := ldecValue - "Qty. on Sales Order" - "Qty. on Asm. Component" - ldecShip;
                    ldecValue := Inventory + "Qty. on Purch. Order" + "Qty. on Assembly Order" + "Trans. Ord. Receipt (Qty.)";
                    ldecValue := ldecValue - "Qty. on Sales Order" - "Qty. on Asm. Component" - "Trans. Ord. Shipment (Qty.)";


                    if ldecValue >= "Safety Stock Quantity" then
                        CurrReport.Skip;

                    gdecTotalQty := ldecValue;

                    /*
                    CALCFIELDS(Inventory,"Qty. on Purch. Order","Qty. on Sales Order","Qty. on Assembly Order","Qty. on Asm. Component");
                    gdecTotalQty := Inventory+"Qty. on Purch. Order"+"Qty. on Sales Order"+"Qty. on Assembly Order"+"Qty. on Asm. Component";
                    grecTxferLine.RESET;
                    grecTxferLine.SETRANGE("Item No.", "No.");
                    grecTxferLine.SETFILTER(Quantity, '>%1', 0);
                    grecTxferLine.SETFILTER("Transfer-from Code", GETFILTER("Location Filter"));
                    IF grecTxferLine.FINDFIRST THEN
                      REPEAT
                        gdecTotalQty -= grecTxferLine.Quantity;
                      UNTIL grecTxferLine.NEXT = 0;
                    grecTxferLine.SETRANGE("Transfer-from Code");
                    grecTxferLine.SETRANGE("Transfer-to Code", GETFILTER("Location Filter"));
                    IF grecTxferLine.FINDFIRST THEN
                      REPEAT
                        gdecTotalQty += grecTxferLine.Quantity;
                      UNTIL grecTxferLine.NEXT = 0;
                    
                    IF gdecTotalQty > "Safety Stock Quantity" THEN
                      CurrReport.SKIP;
                    */

                end;

                trigger OnPreDataItem()
                begin
                    //ID623.start
                    /*
                    IF GETFILTER("Location Filter") = '' THEN
                      SETFILTER("Location Filter", 'TORONTO');
                    */
                    //ID623.end

                end;
            }
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

    trigger OnPreReport()
    begin
        CompanyInfo.Get;

        if Item.GetFilters <> '' then
            gtxtItemFilters := Item.TableCaption + ': ' + Item.GetFilters;
    end;

    var
        CompanyInfo: Record "Company Information";
        grecTxferLine: Record "Transfer Line";
        gdecTotalQty: Decimal;
        RepTitleCaptionLbl: Label 'Items Below Safety Stock';
        PageNoCaptionLbl: Label 'Page No.';
        DateCaptionLbl: Label 'Date';
        UserIDCaptionLbl: Label 'UserID';
        ItemNoCaptionLbl: Label 'Item No.';
        DescriptionCaptionLbl: Label 'Description';
        TotalQtyCaptionLbl: Label 'Total Qty.';
        SafetyStockQtyCaptionLbl: Label 'Safety Stock Qty.';
        gtxtItemFilters: Text[250];
}

