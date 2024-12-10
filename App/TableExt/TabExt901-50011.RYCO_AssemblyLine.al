tableextension 50011 "RYCO Assembly Line" extends "Assembly Line"
{
    /*
    smk2018.04.17 slupg: automerge the following
    nj20160429
        - added Instruction Code, Colour Percentage, Colour fields.
    */
    fields
    {
        // Add changes to table fields here
        field(50000; "Instruction Code"; Code[20])
        {
            //nj20160429
            Caption = 'Instruction Code';
            DataClassification = ToBeClassified;
        }
        field(50001; "Ink Percentage"; Decimal)
        {
            //nj20160429
            Caption = 'Ink Percentage';
            DataClassification = ToBeClassified;
        }
        field(50002; "Ink"; Boolean)
        {
            //nj20160429
            Caption = 'Ink';
            DataClassification = ToBeClassified;
        }

        modify("Quantity to Consume")
        {
            trigger OnBeforeValidate()
            var
            begin
                if ("Quantity to Consume" > "Remaining Quantity") then begin
                    gRemainingQuantity := "Remaining Quantity";
                    rec.Validate("Remaining Quantity", "Quantity to Consume");
                end;
            end;

            trigger OnAfterValidate()
            var
            begin
                rec.Validate("Remaining Quantity", gRemainingQuantity);
            end;
        }
    }

    var
        gRemainingQuantity: Decimal;
}