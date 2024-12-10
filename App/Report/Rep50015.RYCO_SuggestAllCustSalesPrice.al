report 50015 "Suggest All Cust Sales Price"
{
    // ID938, nj20180124
    // - new object

    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") WHERE(Blocked = FILTER(false), "Price Unit of Measure Code" = FILTER(<> ''));
            RequestFilterFields = "No.", "Item Category Code";

            trigger OnAfterGetRecord()
            begin
                grecSalesPriceWksht.Reset;
                grecSalesPriceWksht.SetRange("Item No.", "No.");
                grecSalesPriceWksht.SetRange("Sales Type", grecSalesPriceWksht."Sales Type"::"All Customers");
                grecSalesPriceWksht.SetRange("Starting Date", gdteStarting);
                grecSalesPriceWksht.SetRange("Ending Date", gdteEnding);
                if not grecSalesPriceWksht.FindFirst then begin
                    grecSalesPriceWksht.Init;
                    grecSalesPriceWksht.Validate("Item No.", "No.");
                    grecSalesPriceWksht.Validate("Starting Date", gdteStarting);
                    if gdteEnding <> 0D then
                        grecSalesPriceWksht.Validate("Ending Date", gdteEnding);
                    grecSalesPriceWksht.Validate("Sales Type", grecSalesPriceWksht."Sales Type"::"All Customers");
                    //grecSalesPriceWksht.VALIDATE("Item Category Code", "Item Category Code");
                    grecSalesPriceWksht.Validate("New Unit Price", "Unit Price");
                    grecSalesPriceWksht.Validate("Unit of Measure Code", "Price Unit of Measure Code");
                    grecSalesPriceWksht.Insert(true);
                end else begin
                    grecSalesPriceWksht.Validate("New Unit Price", "Unit Price");
                    grecSalesPriceWksht.Validate("Starting Date", gdteStarting);
                    if gdteEnding <> 0D then
                        grecSalesPriceWksht.Validate("Ending Date", gdteEnding);
                    grecSalesPriceWksht.Modify(true);
                end;
            end;

            trigger OnPreDataItem()
            begin
                if gdteStarting = 0D then
                    Error(TxtSC001);
                if gdteStarting < WorkDate then
                    Error(TxtSC002);
                if gdteEnding <> 0D then begin
                    if gdteStarting > gdteEnding then
                        Error(TxtSC003);
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(gdteStarting; gdteStarting)
                {
                    Caption = 'Starting Date';
                    ApplicationArea = All;
                }
                field(gdteEnding; gdteEnding)
                {
                    Caption = 'Ending Date';
                    ApplicationArea = All;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        grecSalesPriceWksht: Record "Sales Price Worksheet";
        gdteStarting: Date;
        TxtSC001: Label 'Starting Date cannot be Blank!';
        TxtSC002: Label 'Starting Date cannot be earlier than WORKDATE!';
        gdteEnding: Date;
        TxtSC003: Label 'Starting Date must be earlier than Ending Date!';
}

