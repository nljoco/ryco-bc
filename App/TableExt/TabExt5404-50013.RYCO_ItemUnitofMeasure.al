tableextension 50013 "RYCO Item Unit of Measure" extends "Item Unit of Measure"
{
    /*
    smk2018.04.18 slupg automerge the following untagged changes
        - new field 50010
    */
    fields
    {
        // Add changes to table fields here
        field(50010; "1 per Qty. per Unit of Measure"; Decimal)
        {
            //Fazle06062016
            CaptionML = ENU = '1 / Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                //Fazle06062016-->
                IF "1 per Qty. per Unit of Measure" <> 0 THEN
                    "Qty. per Unit of Measure" := 1 / "1 per Qty. per Unit of Measure"
                ELSE
                    VALIDATE("Qty. per Unit of Measure", 0);
                //Fazle06062016--<
            end;
        }
        modify("Qty. per Unit of Measure")
        {
            trigger OnAfterValidate()
            var
            begin
                //Fazle06062016-->
                IF "Qty. per Unit of Measure" <> 0 THEN
                    "1 per Qty. per Unit of Measure" := 1 / "Qty. per Unit of Measure"
                ELSE
                    "1 per Qty. per Unit of Measure" := 0;
                //Fazle06062016--<
            end;
        }
    }

    var
        myInt: Integer;
}