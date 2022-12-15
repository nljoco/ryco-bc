report 50000 "ReCalculate Pollutant"
{
    Caption = 'ReCalculate Pollutant';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Item No.';

            trigger OnAfterGetRecord()
            var
                ltmprecItem: Record Item temporary;
                lrecItem: Record Item;
                lrecBOMComponent: Record "BOM Component";
            begin

                Item.CalcFields("Assembly BOM");
                if not Item."Assembly BOM" then
                    CurrReport.Skip;

                gdialogWindow.Update(1, Item."No.");
                Clear(ltmprecItem);
                lrecBOMComponent.Reset;
                lrecBOMComponent.SetRange("Parent Item No.", Item."No.");
                lrecBOMComponent.SetRange(Type, lrecBOMComponent.Type::Item);
                lrecBOMComponent.SetRange(Ink, true);
                if lrecBOMComponent.FindSet then begin
                    repeat
                        lrecItem.Get(lrecBOMComponent."No.");
                        ltmprecItem.VOC += lrecBOMComponent."Quantity per" * lrecItem.VOC;
                        ltmprecItem.Cobalt += lrecBOMComponent."Quantity per" * lrecItem.Cobalt;
                        ltmprecItem.Manganese += lrecBOMComponent."Quantity per" * lrecItem.Manganese;
                        ltmprecItem.Copper += lrecBOMComponent."Quantity per" * lrecItem.Copper;
                        ltmprecItem.MolyBdenum += lrecBOMComponent."Quantity per" * lrecItem.MolyBdenum;
                        ltmprecItem.Zinc += lrecBOMComponent."Quantity per" * lrecItem.Zinc;
                        ltmprecItem."Methylene Chloride" += lrecBOMComponent."Quantity per" * lrecItem."Methylene Chloride";
                        ltmprecItem.Toluene += lrecBOMComponent."Quantity per" * lrecItem.Toluene;
                        ltmprecItem.Xylene += lrecBOMComponent."Quantity per" * lrecItem.Xylene;
                        ltmprecItem.Other += lrecBOMComponent."Quantity per" * lrecItem.Other;
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

                Modify;
                gintCount += 1;
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
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        gdialogWindow: Dialog;
        Text001: Label '##1############';
        gintCount: Integer;
}

