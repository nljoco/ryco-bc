report 50010 "ReCalculate Pollutant Rep"
{
    // jl20170315 add boolean gUpdateItem to modify the value in the item table or not
    DefaultLayout = RDLC;
    RDLCLayout = './App/Layout-Rdl/Rep50010.RYCO_ReCalculatePollutantRep.rdlc';

    Caption = 'ReCalculate Pollutant';

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") WHERE("Assembly BOM" = FILTER(true));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Item No.';
            dataitem("BOM Component"; "BOM Component")
            {
                DataItemLink = "Parent Item No." = FIELD("No.");
                DataItemTableView = SORTING("Parent Item No.", "Line No.") ORDER(Ascending) WHERE(Type = FILTER(Item), Ink = FILTER(true));
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = WHERE(Number = FILTER(0 .. 10));
                    column(ParentItem_No; Item."No.")
                    {
                    }
                    column(ParentItem_Description; Item.Description)
                    {
                    }
                    column(ParentItem_UoM; grecItemUnitofMeasure.Code)
                    {
                    }
                    column(Lvl; Integer.Number)
                    {
                    }
                    column(Component_No; gcodeItem)
                    {
                    }
                    column(Component_Description; gtxtDesc)
                    {
                    }
                    column(Component_Qty; gdecQty)
                    {
                    }
                    column(Component_UOM; gcodeUOM)
                    {
                    }
                    column(Component_PolPerc; gdecPolPerc)
                    {
                    }
                    column(Component_ExtPolPerc; gdecExtPolPerc)
                    {
                    }
                    column(PolDescHdr1; gcodePolDescHdr[1])
                    {
                    }
                    column(PolDescHdr2; gcodePolDescHdr[2])
                    {
                    }
                    column(PolDescHdr3; gcodePolDescHdr[3])
                    {
                    }
                    column(PolDescHdr4; gcodePolDescHdr[4])
                    {
                    }
                    column(PolDescHdr5; gcodePolDescHdr[5])
                    {
                    }
                    column(PolDescHdr6; gcodePolDescHdr[6])
                    {
                    }
                    column(PolDescHdr7; gcodePolDescHdr[7])
                    {
                    }
                    column(PolDescHdr8; gcodePolDescHdr[8])
                    {
                    }
                    column(PolDescHdr9; gcodePolDescHdr[9])
                    {
                    }
                    column(PolDescHdr10; gcodePolDescHdr[10])
                    {
                    }
                    column(PolDescFtr1; gcodePolDescFtr[1])
                    {
                    }
                    column(PolDescFtr2; gcodePolDescFtr[2])
                    {
                    }
                    column(PolDescFtr3; gcodePolDescFtr[3])
                    {
                    }
                    column(PolDescFtr4; gcodePolDescFtr[4])
                    {
                    }
                    column(PolDescFtr5; gcodePolDescFtr[5])
                    {
                    }
                    column(PolDescFtr6; gcodePolDescFtr[6])
                    {
                    }
                    column(PolDescFtr7; gcodePolDescFtr[7])
                    {
                    }
                    column(PolDescFtr8; gcodePolDescFtr[8])
                    {
                    }
                    column(PolDescFtr9; gcodePolDescFtr[9])
                    {
                    }
                    column(PolDescFtr10; gcodePolDescFtr[10])
                    {
                    }
                    column(PolPercHdr1; gdecPolPercHdr[1])
                    {
                    }
                    column(PolPercHdr2; gdecPolPercHdr[2])
                    {
                    }
                    column(PolPercHdr3; gdecPolPercHdr[3])
                    {
                    }
                    column(PolPercHdr4; gdecPolPercHdr[4])
                    {
                    }
                    column(PolPercHdr5; gdecPolPercHdr[5])
                    {
                    }
                    column(PolPercHdr6; gdecPolPercHdr[6])
                    {
                    }
                    column(PolPercHdr7; gdecPolPercHdr[7])
                    {
                    }
                    column(PolPercHdr8; gdecPolPercHdr[8])
                    {
                    }
                    column(PolPercHdr9; gdecPolPercHdr[9])
                    {
                    }
                    column(PolPercHdr10; gdecPolPercHdr[10])
                    {
                    }
                    column(PolPercFtr1; gdecPolPercFtr[1])
                    {
                    }
                    column(PolPercFtr2; gdecPolPercFtr[2])
                    {
                    }
                    column(PolPercFtr3; gdecPolPercFtr[3])
                    {
                    }
                    column(PolPercFtr4; gdecPolPercFtr[4])
                    {
                    }
                    column(PolPercFtr5; gdecPolPercFtr[5])
                    {
                    }
                    column(PolPercFtr6; gdecPolPercFtr[6])
                    {
                    }
                    column(PolPercFtr7; gdecPolPercFtr[7])
                    {
                    }
                    column(PolPercFtr8; gdecPolPercFtr[8])
                    {
                    }
                    column(PolPercFtr9; gdecPolPercFtr[9])
                    {
                    }
                    column(PolPercFtr10; gdecPolPercFtr[10])
                    {
                    }
                    column(ItemFilter; gtxtItemFilter)
                    {
                    }
                    column(CompanyInfo_Name; grecCompanyInfo.Name)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if (Number = 0) then begin
                            gcodeItem := "BOM Component"."No.";
                            gtxtDesc := "BOM Component".Description;
                            gdecQty := "BOM Component"."Quantity per";
                            gcodeUOM := "BOM Component"."Unit of Measure Code";
                            gdecPolPerc := 0;
                            gdecExtPolPerc := 0;
                        end
                        else begin
                            gcodeItem := '';
                            gtxtDesc := gcodePolDescHdr[Number];
                            gdecQty := 0;
                            gcodeUOM := '';
                            gdecPolPerc := gdecPolPercComp[Number];
                            gdecExtPolPerc := "BOM Component"."Quantity per" * gdecPolPercComp[Number];
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    lrecItem: Record Item;
                begin



                    //For Report-->
                    Clear(gdecPolPercComp);
                    if lrecItem.Get("BOM Component"."No.") then begin
                        gdecPolPercComp[1] := lrecItem.VOC;
                        gdecPolPercComp[2] := lrecItem.Cobalt;
                        gdecPolPercComp[3] := lrecItem.Manganese;
                        gdecPolPercComp[4] := lrecItem.Copper;
                        gdecPolPercComp[5] := lrecItem.MolyBdenum;
                        gdecPolPercComp[6] := lrecItem.Zinc;
                        gdecPolPercComp[7] := lrecItem."Methylene Chloride";
                        gdecPolPercComp[8] := lrecItem.Toluene;
                        gdecPolPercComp[9] := lrecItem.Xylene;
                        gdecPolPercComp[10] := lrecItem.Other;
                        gdecPolPercComp[11] := lrecItem."CAS5160-02-1"; //jl20180820
                    end;
                    //For Report--<
                end;
            }

            trigger OnAfterGetRecord()
            var
                ltmprecItem: Record Item temporary;
                lrecItem: Record Item;
                lrecBOMComponent: Record "BOM Component";
                lcodItemUOM: Code[10];
                ldec1QtyperUOM: Decimal;
            begin
                //For Update
                //Item.CALCFIELDS("Assembly BOM");
                //IF NOT Item."Assembly BOM" THEN
                //  CurrReport.SKIP;

                gdialogWindow.Update(1, Item."No.");

                // nj20170317 - Start
                if lcodItemUOM <> 'KG' then
                    grecItemUnitofMeasure.Get(Item."No.", 'KG')
                else
                    grecItemUnitofMeasure.Get(Item."No.", Item."Base Unit of Measure");
                lcodItemUOM := grecItemUnitofMeasure.Code;
                ldec1QtyperUOM := grecItemUnitofMeasure."Qty. per Unit of Measure";
                // nj20170317 - End

                //For Report---<
                gdecPolPercHdr[1] := VOC;
                gdecPolPercHdr[2] := Cobalt;
                gdecPolPercHdr[3] := Manganese;
                gdecPolPercHdr[4] := Copper;
                gdecPolPercHdr[5] := MolyBdenum;
                gdecPolPercHdr[6] := Zinc;
                gdecPolPercHdr[7] := "Methylene Chloride";
                gdecPolPercHdr[8] := Toluene;
                gdecPolPercHdr[9] := Xylene;
                gdecPolPercHdr[10] := Other;
                gdecPolPercHdr[11] := "CAS5160-02-1"; //jl20180820
                                                      //For report---<

                Clear(ltmprecItem);
                lrecBOMComponent.Reset;
                lrecBOMComponent.SetRange("Parent Item No.", Item."No.");
                lrecBOMComponent.SetRange(Type, lrecBOMComponent.Type::Item);
                lrecBOMComponent.SetRange(Ink, true);
                if lrecBOMComponent.FindSet then begin
                    repeat
                        lrecItem.Get(lrecBOMComponent."No.");
                        ltmprecItem.VOC += ldec1QtyperUOM * lrecItem.VOC * lrecBOMComponent."Quantity per";
                        ltmprecItem.Cobalt += ldec1QtyperUOM * lrecItem.Cobalt * lrecBOMComponent."Quantity per";
                        ltmprecItem.Manganese += ldec1QtyperUOM * lrecItem.Manganese * lrecBOMComponent."Quantity per";
                        ltmprecItem.Copper += ldec1QtyperUOM * lrecItem.Copper * lrecBOMComponent."Quantity per";
                        ltmprecItem.MolyBdenum += ldec1QtyperUOM * lrecItem.MolyBdenum * lrecBOMComponent."Quantity per";
                        ltmprecItem.Zinc += ldec1QtyperUOM * lrecItem.Zinc * lrecBOMComponent."Quantity per";
                        ltmprecItem."Methylene Chloride" += ldec1QtyperUOM * lrecItem."Methylene Chloride" * lrecBOMComponent."Quantity per";
                        ltmprecItem.Toluene += ldec1QtyperUOM * lrecItem.Toluene * lrecBOMComponent."Quantity per";
                        ltmprecItem.Xylene += ldec1QtyperUOM * lrecItem.Xylene * lrecBOMComponent."Quantity per";
                        ltmprecItem.Other += ldec1QtyperUOM * lrecItem.Other * lrecBOMComponent."Quantity per";
                        ltmprecItem."CAS5160-02-1" += ldec1QtyperUOM * lrecItem."CAS5160-02-1" * lrecBOMComponent."Quantity per"; //jl20180820
                    until lrecBOMComponent.Next = 0;
                end;

                VOC := ltmprecItem.VOC;
                Cobalt := ltmprecItem.Cobalt;
                Manganese := ltmprecItem.Manganese;
                Copper := ltmprecItem.Copper;
                MolyBdenum := ltmprecItem.MolyBdenum;
                Zinc := ltmprecItem.Zinc;
                "Methylene Chloride" := ltmprecItem."Methylene Chloride";
                Toluene := ltmprecItem.Toluene;
                Xylene := ltmprecItem.Xylene;
                Other := ltmprecItem.Other;
                "CAS5160-02-1" := ltmprecItem."CAS5160-02-1";

                // jl20170315 start
                if gUpdateItem then
                    Modify;
                // MODIFY;
                // jl20170315 end
                gintCount += 1;

                //For Report-->
                //grecItemUnitofMeasure.GET("No.",'KG');

                // jl20170315 start
                if lrecItem.Get(Item."No.") then begin
                    gdecPolPercFtr[1] += ltmprecItem.VOC;
                    gdecPolPercFtr[2] += ltmprecItem.Cobalt;
                    gdecPolPercFtr[3] += ltmprecItem.Manganese;
                    gdecPolPercFtr[4] += ltmprecItem.Copper;
                    gdecPolPercFtr[5] += ltmprecItem.MolyBdenum;
                    gdecPolPercFtr[6] += ltmprecItem.Zinc;
                    gdecPolPercFtr[7] += ltmprecItem."Methylene Chloride";
                    gdecPolPercFtr[8] += ltmprecItem.Toluene;
                    gdecPolPercFtr[9] += ltmprecItem.Xylene;
                    gdecPolPercFtr[10] += ltmprecItem.Other;
                    gdecPolPercFtr[11] += ltmprecItem."CAS5160-02-1"; //jl20180820
                end;
                /*
                IF lrecItem.GET(Item."No.") THEN BEGIN
                  gdecPolPercFtr[1]:=lrecItem.VOC;
                  gdecPolPercFtr[2]:=lrecItem.Cobalt;
                  gdecPolPercFtr[3]:=lrecItem.Manganese;
                  gdecPolPercFtr[4]:=lrecItem.Copper;
                  gdecPolPercFtr[5]:=lrecItem.MolyBdenum;
                  gdecPolPercFtr[6]:=lrecItem.Zinc;
                  gdecPolPercFtr[7]:=lrecItem."Methylene Chloride";
                  gdecPolPercFtr[8]:=lrecItem.Toluene;
                  gdecPolPercFtr[9]:=lrecItem.Xylene;
                  gdecPolPercFtr[10]:=lrecItem.Other;
                END;
                */ // jl20170315 end

                //For Report--<

            end;

            trigger OnPostDataItem()
            var
                iteml: Record Item temporary;
            begin
                gdialogWindow.Close;
                if gintCount = 0 then
                    Message('No Assembly BOM Item Selected');
                if gintCount = 1 then
                    Message('Recalculation of Pollutant done for item %1', Item."No.");
                if gintCount > 1 then
                    Message('Recalculation of Pollutant done for %1 items', gintCount);
            end;

            trigger OnPreDataItem()
            begin
                gdialogWindow.Open(Text001);
                gintCount := 0
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control1000000001)
                {
                    ShowCaption = false;
                    field(gUpdateItem; gUpdateItem)
                    {
                        Caption = 'Update Item Card';
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            gUpdateItem := true;
        end;
    }

    labels
    {
        ReportNameLbl = 'RECALCULATE POLLUTANT %''S';
        PageNoLbl = 'Page';
        ItemNoLbl = 'Item:';
        UOMLbl = 'UOM:';
        LvlLbl = 'Lvl';
        CompNoLbl = 'Component No.';
        CompQtyLbl = 'Qty';
        ComUOMLbl = 'UOM';
        CompPolPerLbl = 'Pol %';
        CompExtPolPerLbl = 'Ext Pol %';
    }

    trigger OnInitReport()
    begin
        grecCompanyInfo.Get;
    end;

    trigger OnPreReport()
    begin
        gcodePolDescHdr[1] := 'VOC    %:';
        gcodePolDescHdr[2] := 'Cobalt %:';
        gcodePolDescHdr[3] := 'Mangan %:';
        gcodePolDescHdr[4] := 'Copper %:';
        gcodePolDescHdr[5] := 'Molybd %:';
        gcodePolDescHdr[6] := 'Zinc   %:';
        gcodePolDescHdr[7] := 'Methyl %:';
        gcodePolDescHdr[8] := 'Toluen %:';
        gcodePolDescHdr[9] := 'Xylene %:';
        gcodePolDescHdr[10] := 'Other  %:';
        gcodePolDescHdr[11] := 'CAS#5160-02-1  %:'; //jl20180820

        gcodePolDescFtr[1] := 'New VOC    %:';
        gcodePolDescFtr[2] := 'New Cobalt %:';
        gcodePolDescFtr[3] := 'New Mangan %:';
        gcodePolDescFtr[4] := 'New Copper %:';
        gcodePolDescFtr[5] := 'New Molybd %:';
        gcodePolDescFtr[6] := 'New Zinc   %:';
        gcodePolDescFtr[7] := 'New Methyl %:';
        gcodePolDescFtr[8] := 'New Toluen %:';
        gcodePolDescFtr[9] := 'New Xylene %:';
        gcodePolDescFtr[10] := 'New Other  %:';
        gcodePolDescFtr[11] := 'New CAS#5160-02-1  %:'; //jl20180820

        Clear(gdecPolPercHdr);
        Clear(gdecPolPercFtr);

        gtxtItemFilter := Item.GetFilters;
        if gtxtItemFilter <> '' then
            gtxtItemFilter := Item.TableCaption + ': ' + gtxtItemFilter;
    end;

    var
        gdialogWindow: Dialog;
        Text001: Label '##1############';
        gintCount: Integer;
        grecItemUnitofMeasure: Record "Item Unit of Measure";
        grecItem: Record Item;
        gintLvl: Integer;
        gcodeItem: Code[20];
        gtxtDesc: Text;
        gdecQty: Decimal;
        gcodeUOM: Code[10];
        gdecPolPerc: Decimal;
        gdecExtPolPerc: Decimal;
        gcodePolDescHdr: array[11] of Text;
        gdecPolPercHdr: array[11] of Decimal;
        gcodePolDescFtr: array[11] of Text;
        gdecPolPercFtr: array[11] of Decimal;
        grecCompanyInfo: Record "Company Information";
        gtxtItemFilter: Text;
        gdecPolPercComp: array[11] of Decimal;
        gUpdateItem: Boolean;
}

