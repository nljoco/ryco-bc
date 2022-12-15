report 50019 "RYCO Assembly Order"
{
    // ID517, nj20170117
    // - reformatted to accomodate more Assembly Lines.
    // 
    // nj20170209
    // - printing of Previous and Last Assembly Order Nos. depending on Location.
    DefaultLayout = RDLC;
    RDLCLayout = './App/Layout-Rdl/Rep50019.RYCO_AssemblyOrder.rdlc';

    Caption = 'Ryc Assembly Order';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Assembly Header"; "Assembly Header")
        {
            DataItemTableView = SORTING("Document Type", "No.");
            RequestFilterFields = "No.", "Item No.", "Due Date";
            column(No_AssemblyHeader; "No.")
            {
            }
            column(ItemNo_AssemblyHeader; "Item No.")
            {
                IncludeCaption = true;
            }
            column(Description_AssemblyHeader; Description)
            {
                IncludeCaption = true;
            }
            column(Quantity_AssemblyHeader; Quantity)
            {
                DecimalPlaces = 5 : 5;
                IncludeCaption = true;
            }
            column(QuantityToAssemble_AssemblyHeader; "Quantity to Assemble")
            {
                DecimalPlaces = 5 : 5;
                IncludeCaption = true;
            }
            column(UnitOfMeasureCode_AssemblyHeader; "Unit of Measure Code")
            {
            }
            column(DueDate_AssemblyHeader; Format("Due Date"))
            {
            }
            column(StartingDate_AssemblyHeader; Format("Starting Date"))
            {
            }
            column(EndingDate_AssemblyHeader; Format("Ending Date"))
            {
            }
            column(LocationCode_AssemblyHeader; "Location Code")
            {
                IncludeCaption = true;
            }
            column(BinCode_AssemblyHeader; "Bin Code")
            {
            }
            column(SalesDocNo; SalesDocNo)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(SalesOrderNo_AssemblyHeader; "Sales Order No.")
            {
            }
            column(Code_IUoM; grecItemUnitofMeasure.Code)
            {
            }
            column(Qty_IUoM; grecItemUnitofMeasure."1 per Qty. per Unit of Measure")
            {
            }
            column(LastAssemOrder_Item; gcodLastAssemblyNo)
            {
            }
            column(PrevAssemOrder_Item; gcodPrevAssemblyNo)
            {
            }
            column(TotalInkKgLines_AssemblyHeader; "Total Ink Kg (Lines)")
            {
            }
            column(ProductRemark_AssemblyHeader; "Production Remark")
            {
            }
            column(CustomerName_AssemblyHeader; "Assembly Header"."Customer Name")
            {
            }
            dataitem("Assembly Line"; "Assembly Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                column(Type_AssemblyLine; Type)
                {
                    IncludeCaption = true;
                }
                column(No_AssemblyLine; "No.")
                {
                    IncludeCaption = true;
                }
                column(Description_AssemblyLine; Description)
                {
                    IncludeCaption = true;
                }
                column(VariantCode_AssemblyLine; "Variant Code")
                {
                    IncludeCaption = true;
                }
                column(DueDate_AssemblyLine; Format("Due Date"))
                {
                }
                column(QuantityPer_AssemblyLine; "Quantity per")
                {
                    IncludeCaption = true;
                }
                column(Quantity_AssemblyLine; Quantity)
                {
                    DecimalPlaces = 5 : 5;
                    IncludeCaption = true;
                }
                column(UnitOfMeasureCode_AssemblyLine; "Unit of Measure Code")
                {
                }
                column(LocationCode_AssemblyLine; "Location Code")
                {
                    IncludeCaption = true;
                }
                column(BinCode_AssemblyLine; "Bin Code")
                {
                    IncludeCaption = true;
                }
                column(QuantityToConsume_AssemblyLine; "Quantity to Consume")
                {
                    IncludeCaption = true;
                }
            }

            trigger OnAfterGetRecord()
            var
                ATOLink: Record "Assemble-to-Order Link";
            begin
                Clear(SalesDocNo);
                if ATOLink.Get("Document Type", "No.") then
                    SalesDocNo := ATOLink."Document No.";

                //Fazle05312016-->
                //IF grecItem.GET("Assembly Header"."Item No.") THEN;
                if grecItemUnitofMeasure.Get("Assembly Header"."Item No.", 'KG') then;
                //Fazle05312016--<

                // nj20170209 - Start
                gcodPrevAssemblyNo := '';
                gcodLastAssemblyNo := '';
                if grecItem.Get("Assembly Header"."Item No.") then begin
                    case "Assembly Header"."Location Code" of
                        'CALGARY':
                            begin
                                gcodPrevAssemblyNo := grecItem."Prev Assembly Order No. - CGY";
                                gcodLastAssemblyNo := grecItem."Last Assembly Order No. - CGY";
                            end;
                        'MONTREAL':
                            begin
                                gcodPrevAssemblyNo := grecItem."Prev Assembly Order No. - MTL";
                                gcodLastAssemblyNo := grecItem."Last Assembly Order No. - MTL";
                            end;
                        else begin
                            gcodPrevAssemblyNo := grecItem."Prev Assembly Order No.";
                            gcodLastAssemblyNo := grecItem."Last Assembly Order No.";
                        end;
                    end;
                end;
                // nj20170209 - End
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
        AssemblyOrderHeading = 'Assembly Order';
        AssemblyItemHeading = 'Assembly Item';
        BillOfMaterialHeading = 'Bill of Material';
        PageCaption = 'Page';
        OfCaption = 'of';
        OrderNoCaption = 'Order No.';
        QuantityAssembledCaption = 'Quantity Assembled';
        QuantityPickedCaption = 'Quantity Picked';
        QuantityConsumedCaption = 'Quantity Consumed';
        AssembleToOrderNoCaption = 'Asm. to Order No.';
        UnitOfMeasureCaption = 'Unit of Measure';
        VariantCaption = 'Variant';
        DueDateCaption = 'Due Date';
        StartingDateCaption = 'Starting Date';
        EndingDateCaption = 'Ending Date';
        BatchNo = 'Batch No.:';
        LastBatchNo = 'Last Batch No.:';
        PrevBatchNo = 'Prev. Batch No.:';
        IssueDate = 'Issue Date:';
        ForOrderNo = 'For Order No.:';
        ItemNumber = 'Item Number:';
        Build = 'Build:';
        Product = 'Product';
        Quantity = 'Quantity';
        QtyUsed = 'Qty. Used';
        StockShipas = 'Stock Ship As:';
        CustomerNameLbl = 'Customer Name:';
    }

    var
        SalesDocNo: Code[20];
        grecItemUnitofMeasure: Record "Item Unit of Measure";
        grecItem: Record Item;
        gcodPrevAssemblyNo: Code[20];
        gcodLastAssemblyNo: Code[20];
}

