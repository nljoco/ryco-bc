report 50016 "Pollutants - Items for a Cust."
{
    // ID2136,nj20180917
    // - added new Pollutant
    DefaultLayout = RDLC;
    RDLCLayout = './App/Layout-Rdl/Rep50016.RYCO_PollutantsItemsforaCust.rdlc';


    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Date Filter";

            trigger OnAfterGetRecord()
            begin
                grecTempItem.Reset;
                grecRef.GetTable(grecTempItem);
                if grecRef.IsTemporary then
                    grecTempItem.DeleteAll;
                //grecILE.SETRANGE("Source No.");
                if grecILE.FindSet then
                    repeat
                        if grecItem.Get(grecILE."Item No.") then begin
                            //IF (grecItem.VOC > 0) OR (grecItem.Cobalt > 0) OR (grecItem.Manganese > 0) OR
                            //   (grecItem.Copper > 0) OR (grecItem.MolyBdenum > 0) OR (grecItem.Zinc > 0) OR
                            //   (grecItem."Methylene Chloride" > 0) OR (grecItem.Toluene > 0) OR
                            //   (grecItem.Xylene > 0) OR (grecItem.Other > 0) THEN BEGIN
                            if not grecTempItem.Get(grecILE."Item No.") then begin
                                grecItem.Get(grecILE."Item No.");
                                grecTempItem := grecItem;
                                grecTempItem."Item Disc. Group" := grecILE."Source No."; //Customer."No.";
                                grecTempItem."Reorder Point" := grecILE.Quantity * -1;
                                grecTempItem.Insert;
                            end else begin
                                grecTempItem."Reorder Point" += grecILE.Quantity * -1;
                                grecTempItem.Modify;
                            end;
                            //END;
                        end;
                    until grecILE.Next = 0;
            end;

            trigger OnPreDataItem()
            begin
                grecILE.Reset;
                grecILE.SetCurrentKey("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date");
                grecILE.SetRange("Entry Type", grecILE."Entry Type"::Sale);
                if Customer.GetFilter("Date Filter") <> '' then
                    grecILE.SetFilter("Posting Date", '%1..%2', Customer.GetRangeMin("Date Filter"), Customer.GetRangeMax("Date Filter"));
                if Customer.GetFilter("No.") <> '' then
                    grecILE.SetFilter("Source No.", '%1..%2', Customer.GetRangeMin("No."), Customer.GetRangeMax("No."));
            end;
        }
        dataitem(TempItem; "Integer")
        {
            DataItemTableView = SORTING(Number);
            column(Name_Company; grecCompany.Name)
            {
            }
            column(No_Customer; grecTempItem."Item Disc. Group")
            {
            }
            column(Name_Customer; grecCustomer.Name)
            {
            }
            column(No_TempItem; grecTempItem."No.")
            {
            }
            column(Description_TempItem; grecTempItem.Description)
            {
            }
            column(Qty_TempItem; grecTempItem."Reorder Point")
            {
            }
            column(QtyPerUOM_ItemUOM; grecItemUOM."1 per Qty. per Unit of Measure")
            {
            }
            column(BaseUOM_TempItem; grecTempItem."Base Unit of Measure")
            {
            }
            column(Description_UOM; grecUOM.Description)
            {
            }
            column(VOC_TempItem; grecTempItem.VOC)
            {
            }
            column(Cobalt_TempItem; grecTempItem.Cobalt)
            {
            }
            column(Manganese_TempItem; grecTempItem.Manganese)
            {
            }
            column(Copper_TempItem; grecTempItem.Copper)
            {
            }
            column(Molybdenum_TempItem; grecTempItem.MolyBdenum)
            {
            }
            column(Zinc_TempItem; grecTempItem.Zinc)
            {
            }
            column(Methylene_TempItem; grecTempItem."Methylene Chloride")
            {
            }
            column(Toluene_TempItem; grecTempItem.Toluene)
            {
            }
            column(Xylene_TempItem; grecTempItem.Xylene)
            {
            }
            column(CAS5160021_TempItem; grecTempItem."CAS5160-02-1")
            {
            }
            column(Other_TempItem; grecTempItem.Other)
            {
            }
            column(VOC; gdecVOC)
            {
            }
            column(Cobalt; gdecCobalt)
            {
            }
            column(Manganese; gdecManganese)
            {
            }
            column(Copper; gdecCopper)
            {
            }
            column(Molybdenum; gdecMolybdenum)
            {
            }
            column(Zinc; gdecZinc)
            {
            }
            column(Methylene; gdecMethylene)
            {
            }
            column(Toluene; gdecToluene)
            {
            }
            column(Xylene; gdecXylene)
            {
            }
            column(CAS5160021; gdecCAS5160021)
            {
            }
            column(Other; gdecOther)
            {
            }
            column(RepFilters; Customer.TableCaption + ':  ' + gtxtRepFilters)
            {
            }
            column(RepTitleCaption; RepTitleCaptionLbl)
            {
            }
            column(DateCaption; DateCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(RepFiltersCaption; RepFiltersCaptionLbl)
            {
            }
            column(ItemNoCaption; ItemNoCaptionLbl)
            {
            }
            column(UnitCaption; UnitCaptionLbl)
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(ContainersCaption; ContainersCaptionLbl)
            {
            }
            column(SoldCaption; SoldCaptionLbl)
            {
            }
            column(BuildCaption; BuildCaptionLbl)
            {
            }
            column(ConvCaption; ConvCaptionLbl)
            {
            }
            column(POLPctCaption; POLPctCaptionLbl)
            {
            }
            column(KgofPOLCaption; KgofPOLCaptionLbl)
            {
            }
            column(CustomerCaption; CustomerCaptionLbl)
            {
            }
            column(VOCCaption; VOCCaptionLbl)
            {
            }
            column(CobaltCaption; CobaltCaptionLbl)
            {
            }
            column(ManganCaption; ManganCaptionLbl)
            {
            }
            column(CopperCaption; CopperCaptionLbl)
            {
            }
            column(MolybdCaption; MolybdCaptionLbl)
            {
            }
            column(ZincCaption; ZincCaptionLbl)
            {
            }
            column(MetylCaption; MetylCaptionLbl)
            {
            }
            column(ToluenCaption; ToluenCaptionLbl)
            {
            }
            column(XyleneCaption; XyleneCaptionLbl)
            {
            }
            column(CAS5160021Caption; CAS5160021CaptionLbl)
            {
            }
            column(OtherCaption; OtherCaptionLbl)
            {
            }
            column(CustTotalsCaption; CustTotalsCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                OnLineNumber := OnLineNumber + 1;
                //with grecTempItem do begin
                if OnLineNumber = 1 then
                    FindFirst
                else
                    Next;
                grecCustomer.Get(grecTempItem."Item Disc. Group");  // Customer No.
                grecUOM.Get(grecTempItem."Base Unit of Measure");
                if grecTempItem."Base Unit of Measure" <> 'KG' then begin

                    if (grecTempItem.VOC > 0) or (grecTempItem.Cobalt > 0) or (grecTempItem.Manganese > 0) or
                       (grecTempItem.Copper > 0) or (grecTempItem.MolyBdenum > 0) or (grecTempItem.Zinc > 0) or
                       (grecTempItem."Methylene Chloride" > 0) or (grecTempItem.Toluene > 0) or
                       (grecTempItem.Xylene > 0) or (grecTempItem.Other > 0) or
                       (grecTempItem."CAS5160-02-1" > 0) then begin   //ID2136
                        grecItemUOM.Get(grecTempItem."No.", 'KG');
                    end else begin
                        grecItemUOM.Get(grecTempItem."No.", grecTempItem."Base Unit of Measure");
                    end;

                    //grecItemUOM.GET(grecTempItem."No.",'KG')
                end else begin
                    grecItemUOM.Get(grecTempItem."No.", grecTempItem."Base Unit of Measure");
                end;

                gdecVOC := grecTempItem.VOC * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecCobalt := grecTempItem.Cobalt * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecManganese := grecTempItem.Manganese * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecCopper := grecTempItem.Copper * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecMolybdenum := grecTempItem.MolyBdenum * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecZinc := grecTempItem.Zinc * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecMethylene := grecTempItem."Methylene Chloride" * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecToluene := grecTempItem.Toluene * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecXylene := grecTempItem.Xylene * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecOther := grecTempItem.Other * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;
                gdecCAS5160021 := grecTempItem."CAS5160-02-1" * grecItemUOM."1 per Qty. per Unit of Measure" * grecTempItem."Reorder Point" / 100;  //ID2136
                //end;
            end;

            trigger OnPreDataItem()
            begin
                grecTempItem.Reset;
                NumberOfLines := grecTempItem.Count;
                SetRange(Number, 1, NumberOfLines);
                OnLineNumber := 0;
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

    trigger OnPreReport()
    begin
        grecCompany.Get;
        gtxtRepFilters := Customer.GetFilters;
    end;

    var
        grecCompany: Record "Company Information";
        grecILE: Record "Item Ledger Entry";
        grecItem: Record Item;
        grecTempItem: Record Item temporary;
        grecCustomer: Record Customer;
        grecItemUOM: Record "Item Unit of Measure";
        grecUOM: Record "Unit of Measure";
        grecRef: RecordRef;
        RepTitleCaptionLbl: Label 'Pollutants - Items for a Customer';
        DateCaptionLbl: Label 'Date';
        PageCaptionLbl: Label 'Page';
        RepFiltersCaptionLbl: Label 'Report Filters:';
        ItemNoCaptionLbl: Label 'Item No.';
        UnitCaptionLbl: Label 'Unit';
        DescriptionCaptionLbl: Label 'Description';
        ContainersCaptionLbl: Label 'Containers';
        SoldCaptionLbl: Label 'Sold';
        BuildCaptionLbl: Label 'Build';
        ConvCaptionLbl: Label 'Conversion';
        POLPctCaptionLbl: Label 'POL %';
        KgofPOLCaptionLbl: Label 'Kg of POL';
        CustomerCaptionLbl: Label 'Customer';
        VOCCaptionLbl: Label 'VOC %';
        CobaltCaptionLbl: Label 'Cobalt  %';
        ManganCaptionLbl: Label 'Mangan  %';
        CopperCaptionLbl: Label 'Copper %';
        MolybdCaptionLbl: Label 'Molybd %';
        ZincCaptionLbl: Label 'Zinc %';
        MetylCaptionLbl: Label 'Metyl %';
        ToluenCaptionLbl: Label 'Toluen %';
        XyleneCaptionLbl: Label 'Xylene %';
        CAS5160021CaptionLbl: Label 'CAS5160-02-1';
        OtherCaptionLbl: Label 'Other %';
        CaptionLbl: Label 'Page';
        NumberOfLines: Integer;
        OnLineNumber: Integer;
        gdecVOC: Decimal;
        gdecCobalt: Decimal;
        gdecManganese: Decimal;
        gdecCopper: Decimal;
        gdecMolybdenum: Decimal;
        gdecZinc: Decimal;
        gdecMethylene: Decimal;
        gdecToluene: Decimal;
        gdecXylene: Decimal;
        gdecOther: Decimal;
        gtxtRepFilters: Text[250];
        CustTotalsCaptionLbl: Label ' - Totals';
        gdecCAS5160021: Decimal;
}

