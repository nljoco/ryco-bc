report 50013 "Cust./Item Sales bySalesperson"
{
    // ID 460
    // - Same report as Cust/Item Stat by Salesperson
    // - remove two columns Contribution margin and Contrib ratio
    DefaultLayout = RDLC;
    RDLCLayout = './App/Layout-Rdl/Rep50013.RYCO_CustItemSalesbySalesperson.rdlc';

    Caption = 'Cust./Item Stat. by Salespers.';

    dataset
    {
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            DataItemTableView = SORTING(Code);
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Code", Name;
            RequestFilterHeading = 'Salesperson';
            column(FORMAT_TODAY_0_4; Format(Today, 0, 4))
            {
            }
            column(TIME; Time)
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(FilterString; FilterString)
            {
            }
            column(PrintToExcel; PrintToExcel)
            {
            }
            column(FilterString2; FilterString2)
            {
            }
            column(FilterString3; FilterString3)
            {
            }
            column(OnlyOnePerPage; OnlyOnePerPage)
            {
            }
            column(PageGroupNo; PageGroupNo)
            {
            }
            column(Salesperson_Purchaser__TABLECAPTION___________FilterString; "Salesperson/Purchaser".TableCaption + ':  ' + FilterString)
            {
            }
            column(Customer_TABLECAPTION___________FilterString2; Customer.TableCaption + ':  ' + FilterString2)
            {
            }
            column(Value_Entry__TABLECAPTION___________FilterString3; "Value Entry".TableCaption + ':  ' + FilterString3)
            {
            }
            column(SalespersonString; SalespersonString)
            {
            }
            column(Salesperson_Purchaser_Code; Code)
            {
            }
            column(Salesperson_Purchaser_Name; Name)
            {
            }
            column(Value_Entry___Sales_Amount__Actual__; "Value Entry"."Sales Amount (Actual)")
            {
            }
            column(Profit; Profit)
            {
            }
            column(Value_Entry___Discount_Amount_; "Value Entry"."Discount Amount")
            {
            }
            column(Profit__; "Profit%")
            {
                DecimalPlaces = 1 : 1;
            }
            column(Customer_Item_Statistics_by_SalespersonCaption; Customer_Item_Statistics_by_SalespersonCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Salesperson_Purchaser_CodeCaption; Salesperson_Purchaser_CodeCaptionLbl)
            {
            }
            column(Salesperson_Purchaser_NameCaption; Salesperson_Purchaser_NameCaptionLbl)
            {
            }
            column(Customer__No__Caption; Customer__No__CaptionLbl)
            {
            }
            column(Customer_NameCaption; Customer_NameCaptionLbl)
            {
            }
            column(Item__Base_Unit_of_Measure_Caption; Item__Base_Unit_of_Measure_CaptionLbl)
            {
            }
            column(Profit_Control51Caption; Profit_Control51CaptionLbl)
            {
            }
            column(Profit___Control53Caption; Profit___Control53CaptionLbl)
            {
            }
            column(Value_Entry__Item_No__Caption; Value_Entry__Item_No__CaptionLbl)
            {
            }
            column(Item_DescriptionCaption; Item_DescriptionCaptionLbl)
            {
            }
            column(Invoiced_Quantity_Caption; Invoiced_Quantity_CaptionLbl)
            {
            }
            column(Value_Entry__Sales_Amount__Actual__Caption; Value_Entry__Sales_Amount__Actual__CaptionLbl)
            {
            }
            column(Value_Entry__Discount_Amount_Caption; Value_Entry__Discount_Amount_CaptionLbl)
            {
            }
            column(Report_TotalsCaption; Report_TotalsCaptionLbl)
            {
            }
            dataitem(Customer; Customer)
            {
                DataItemTableView = SORTING("Salesperson Code", "No.");
                PrintOnlyIfDetail = true;
                RequestFilterFields = "No.", "Search Name";
                column(Customer__No__; "No.")
                {
                }
                column(Customer_Name; Name)
                {
                }
                column(Customer__Phone_No__; "Phone No.")
                {
                }
                column(Customer_Contact; Contact)
                {
                }
                column(Salesperson_Purchaser__Code; "Salesperson/Purchaser".Code)
                {
                }
                column(Value_Entry___Sales_Amount__Actual___Control41; "Value Entry"."Sales Amount (Actual)")
                {
                }
                column(Profit_Control42; Profit)
                {
                }
                column(Value_Entry___Discount_Amount__Control43; "Value Entry"."Discount Amount")
                {
                }
                column(Profit___Control44; "Profit%")
                {
                    DecimalPlaces = 1 : 1;
                }
                column(Customer_Global_Dimension_1_Filter; "Global Dimension 1 Filter")
                {
                }
                column(Customer_Global_Dimension_2_Filter; "Global Dimension 2 Filter")
                {
                }
                column(Phone_Caption; Phone_CaptionLbl)
                {
                }
                column(Contact_Caption; Contact_CaptionLbl)
                {
                }
                column(Salesperson_TotalsCaption; Salesperson_TotalsCaptionLbl)
                {
                }
                dataitem("Value Entry"; "Value Entry")
                {
                    DataItemLink = "Source No." = FIELD("No."), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter");
                    DataItemTableView = SORTING("Source Type", "Source No.", "Item Ledger Entry Type", "Item No.", "Posting Date") WHERE("Source Type" = CONST(Customer), "Item Ledger Entry Type" = CONST(Sale), "Expected Cost" = CONST(false));
                    RequestFilterFields = "Item No.", "Inventory Posting Group", "Posting Date";
                    column(Value_Entry__Item_No__; "Item No.")
                    {
                    }
                    column(Item_Description; Item.Description)
                    {
                    }
                    column(Invoiced_Quantity_; -"Invoiced Quantity")
                    {
                    }
                    column(Item__Base_Unit_of_Measure_; Item."Base Unit of Measure")
                    {
                    }
                    column(Value_Entry__Sales_Amount__Actual__; "Sales Amount (Actual)")
                    {
                    }
                    column(Profit_Control51; Profit)
                    {
                    }
                    column(Value_Entry__Discount_Amount_; "Discount Amount")
                    {
                    }
                    column(Profit___Control53; "Profit%")
                    {
                        DecimalPlaces = 1 : 1;
                    }
                    column(Customer__No___Control54; Customer."No.")
                    {
                    }
                    column(Value_Entry__Sales_Amount__Actual___Control55; "Sales Amount (Actual)" + 0)
                    {
                    }
                    column(Profit_Control56; Profit + 0)
                    {
                    }
                    column(Value_Entry__Discount_Amount__Control57; "Discount Amount" + 0)
                    {
                    }
                    column(Profit___Control58; "Profit%" + 0)
                    {
                        DecimalPlaces = 1 : 1;
                    }
                    column(Value_Entry_Entry_No_; "Entry No.")
                    {
                    }
                    column(Value_Entry_Source_No_; "Source No.")
                    {
                    }
                    column(Value_Entry_Global_Dimension_1_Code; "Global Dimension 1 Code")
                    {
                    }
                    column(Value_Entry_Global_Dimension_2_Code; "Global Dimension 2 Code")
                    {
                    }
                    column(Customer_TotalsCaption; Customer_TotalsCaptionLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if ValueEntryTotalForItem."Item No." <> "Item No." then begin
                            "CalculateProfit%";
                            if PrintToExcel and (ValueEntryTotalForItem."Item No." <> '') then
                                MakeExcelDataBody;
                            Clear(ValueEntryTotalForItem);
                            ProfitTotalForItem := 0;
                            if not Item.Get("Item No.") then begin
                                Item.Description := 'Others';
                                Item."Base Unit of Measure" := '';
                            end;
                        end;

                        Profit := "Sales Amount (Actual)" + "Cost Amount (Actual)";
                        "Discount Amount" := -"Discount Amount";

                        ValueEntryTotalForItem."Item No." := "Item No.";
                        ValueEntryTotalForItem."Invoiced Quantity" += "Invoiced Quantity";
                        ValueEntryTotalForItem."Sales Amount (Actual)" += "Sales Amount (Actual)";
                        ValueEntryTotalForItem."Discount Amount" += "Discount Amount";
                        ProfitTotalForItem += Profit;
                    end;

                    trigger OnPostDataItem()
                    begin
                        if PrintToExcel and (ValueEntryTotalForItem."Item No." <> '') then begin
                            "CalculateProfit%";
                            MakeExcelDataBody;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        case SalespersonToUse of
                            SalespersonToUse::"Assigned To Customer":
                                SetRange("Salespers./Purch. Code");
                            SalespersonToUse::"Assigned To Sales Order":
                                SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                        end;

                        CurrReport.CreateTotals("Invoiced Quantity", "Sales Amount (Actual)", Profit, "Discount Amount");
                        Clear(ValueEntryTotalForItem);
                        ProfitTotalForItem := 0;
                    end;
                }

                trigger OnPreDataItem()
                begin
                    case SalespersonToUse of
                        SalespersonToUse::"Assigned To Customer":
                            begin
                                SetCurrentKey("Salesperson Code", "No.");
                                SetRange("Salesperson Code", "Salesperson/Purchaser".Code);
                            end;
                        SalespersonToUse::"Assigned To Sales Order":
                            begin
                                SetCurrentKey("No.");
                                SetRange("Salesperson Code");
                            end;
                    end;

                    CurrReport.CreateTotals("Value Entry"."Sales Amount (Actual)", Profit, "Value Entry"."Discount Amount");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.NewPagePerRecord := OnlyOnePerPage;

                if OnlyOnePerPage then
                    PageGroupNo := PageGroupNo + 1
            end;

            trigger OnPreDataItem()
            begin
                CurrReport.CreateTotals("Value Entry"."Sales Amount (Actual)", Profit, "Value Entry"."Discount Amount");
            end;
        }
    }

    requestpage
    {
        SaveValues = false;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(SalespersonToUse; SalespersonToUse)
                    {
                        Caption = 'Salesperson To Use';
                        OptionCaption = 'Assigned To Customer,Assigned To Sales Order';
                        ApplicationArea = All;
                    }
                    field(OnlyOnePerPage; OnlyOnePerPage)
                    {
                        Caption = 'New Page per Salesperson';
                        ApplicationArea = All;
                    }
                    field(PrintToExcel; PrintToExcel)
                    {
                        Caption = 'Print to Excel';
                        ApplicationArea = All;
                    }
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

    trigger OnPostReport()
    begin
        if PrintToExcel then
            CreateExcelbook;
    end;

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        FilterString := "Salesperson/Purchaser".GetFilters;
        FilterString2 := Customer.GetFilters;
        FilterString3 := "Value Entry".GetFilters;
        case SalespersonToUse of
            SalespersonToUse::"Assigned To Customer":
                SalespersonString := Text002;
            SalespersonToUse::"Assigned To Sales Order":
                SalespersonString := Text003;
            else
                Error(Text001);
        end;

        if PrintToExcel then
            MakeExcelInfo;
    end;

    var
        ExcelBuf: Record "Excel Buffer" temporary;
        FilterString: Text;
        FilterString2: Text;
        FilterString3: Text;
        Profit: Decimal;
        "Profit%": Decimal;
        OnlyOnePerPage: Boolean;
        Item: Record Item;
        CompanyInformation: Record "Company Information";
        SalespersonToUse: Option "Assigned To Customer","Assigned To Sales Order";
        SalespersonString: Text[250];
        Text001: Label 'Invalid option chosen for Salesperson To Use.';
        Text002: Label 'Individual sale shows under the Salesperson assigned to that Customer.';
        Text003: Label 'Individual sale shows under the Salesperson assigned to that individual Sales Order.';
        PrintToExcel: Boolean;
        Text101: Label 'Data';
        Text102: Label 'Customer/Item Sales by Salesperson';
        Text103: Label 'Company Name';
        Text104: Label 'Report No.';
        Text105: Label 'Report Name';
        Text106: Label 'User ID';
        Text107: Label 'Date / Time';
        Text108: Label 'Salesperson Filters';
        Text109: Label 'Customer Filters';
        Text110: Label 'Value Entry Filters';
        Text111: Label 'Salesperson to Use';
        Text112: Label 'Contribution Margin';
        Text113: Label 'Contribution Ratio';
        Text114: Label 'Salesperson';
        PageGroupNo: Integer;
        ValueEntryTotalForItem: Record "Value Entry";
        ProfitTotalForItem: Decimal;
        Customer_Item_Statistics_by_SalespersonCaptionLbl: Label 'Customer/Item Statistics by Salesperson';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Salesperson_Purchaser_CodeCaptionLbl: Label 'Salesperson';
        Salesperson_Purchaser_NameCaptionLbl: Label 'Salesperson Name';
        Customer__No__CaptionLbl: Label 'Customer No.';
        Customer_NameCaptionLbl: Label 'Customer Name';
        Item__Base_Unit_of_Measure_CaptionLbl: Label 'Unit of Measure';
        Profit_Control51CaptionLbl: Label 'Contribution Margin';
        Profit___Control53CaptionLbl: Label 'Contrib Ratio';
        Value_Entry__Item_No__CaptionLbl: Label 'Item Number';
        Item_DescriptionCaptionLbl: Label 'Item Description';
        Invoiced_Quantity_CaptionLbl: Label 'Quantity';
        Value_Entry__Sales_Amount__Actual__CaptionLbl: Label 'Amount';
        Value_Entry__Discount_Amount_CaptionLbl: Label 'Discount';
        Report_TotalsCaptionLbl: Label 'Report Totals';
        Phone_CaptionLbl: Label 'Phone:';
        Contact_CaptionLbl: Label 'Contact:';
        Salesperson_TotalsCaptionLbl: Label 'Salesperson Totals';
        Customer_TotalsCaptionLbl: Label 'Customer Totals';

    //[Scope('Internal')]
    local procedure "CalculateProfit%"()
    begin
        if ValueEntryTotalForItem."Sales Amount (Actual)" <> 0 then
            "Profit%" := Round(100 * ProfitTotalForItem / ValueEntryTotalForItem."Sales Amount (Actual)", 0.1)
        else
            "Profit%" := 0;
    end;

    local procedure MakeExcelInfo()
    begin

        ExcelBuf.SetUseInfoSheet;

        //////////////////////////////////////////////////////////////////////////////
        //begin rem smk2018.04.18 slupg:
        //------------------------------
        //seems sometime after NAV2016 CU3, Microsoft removed the third parameter in
        //ExcelBuf.AddInfoColumn which used to be CommentText@1004 : Text[1000].
        //removed in NAV2018?
        //////////////////////////////////////////////////////////////////////////////
        /*
        ExcelBuf.AddInfoColumn(FORMAT(Text103),FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(CompanyInformation.Name,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text105),FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FORMAT(Text102),FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text104),FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(REPORT::"Cust./Item Stat. by Salespers.",FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Number);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text106),FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(USERID,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text107),FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(TODAY,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddInfoColumn(TIME,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Time);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text111),FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(SalespersonString,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text108),FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FilterString,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text109),FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FilterString2,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(FORMAT(Text110),FALSE,'',TRUE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FilterString3,FALSE,'',FALSE,FALSE,FALSE,'',ExcelBuf."Cell Type"::Text);
        */
        //////////////////////////////////////////////////////////////////////////////
        //end rem smk2018.04.18 slupg
        //////////////////////////////////////////////////////////////////////////////

        //////////////////////////////////////////////////////////////////////////////
        //begin add smk2018.04.18 slupg (replaced the above code
        //////////////////////////////////////////////////////////////////////////////
        ExcelBuf.AddInfoColumn(Format(Text103), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(CompanyInformation.Name, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text105), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Format(Text102), false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text104), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(REPORT::"Cust./Item Stat. by Salespers.", false, false, false, false, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text106), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(UserId, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text107), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(Today, false, false, false, false, '', ExcelBuf."Cell Type"::Date);
        ExcelBuf.AddInfoColumn(Time, false, false, false, false, '', ExcelBuf."Cell Type"::Time);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text111), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(SalespersonString, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text108), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FilterString, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text109), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FilterString2, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.NewRow;
        ExcelBuf.AddInfoColumn(Format(Text110), false, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddInfoColumn(FilterString3, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        //////////////////////////////////////////////////////////////////////////////
        //end add smk2018.04.18 slupg
        //////////////////////////////////////////////////////////////////////////////

        ExcelBuf.ClearNewRow;
        MakeExcelDataHeader;

    end;

    local procedure MakeExcelDataHeader()
    begin
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn(
          Text114 + ' ' + "Salesperson/Purchaser".FieldCaption(Code), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(
          Text114 + ' ' + "Salesperson/Purchaser".FieldCaption(Name), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(
          Customer.TableCaption + ' ' + Customer.FieldCaption("No."), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Customer.FieldCaption(Name), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Value Entry".FieldCaption("Item No."), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Item.FieldCaption(Description), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Value Entry".FieldCaption("Invoiced Quantity"), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Item.FieldCaption("Base Unit of Measure"), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Value Entry".FieldCaption("Sales Amount (Actual)"), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Format(Text112), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Format(Text113), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Value Entry".FieldCaption("Discount Amount"), false, '', true, false, true, '', ExcelBuf."Cell Type"::Text);
    end;

    local procedure MakeExcelDataBody()
    begin
        ExcelBuf.NewRow;
        ExcelBuf.AddColumn("Salesperson/Purchaser".Code, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Salesperson/Purchaser".Name, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Customer."No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Customer.Name, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(ValueEntryTotalForItem."Item No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(Item.Description, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(-ValueEntryTotalForItem."Invoiced Quantity", false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(Item."Base Unit of Measure", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(
          ValueEntryTotalForItem."Sales Amount (Actual)", false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(ProfitTotalForItem, false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn("Profit%" / 100, false, '', false, false, false, '0.0%', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn(ValueEntryTotalForItem."Discount Amount", false, '', false, false, false, '#,##0.00', ExcelBuf."Cell Type"::Number);
    end;

    local procedure CreateExcelbook()
    var
        SheetName: Text[250];
    begin
        SheetName := Text102;
        ExcelBuf.CreateNewBook('Data');
        ExcelBuf.WriteSheet(SheetName, CompanyName(), UserId());
        ExcelBuf.CloseBook();
        ExcelBuf.OpenExcel();
        ExcelBuf.DeleteAll;
    end;
}

