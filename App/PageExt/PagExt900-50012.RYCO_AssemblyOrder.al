pageextension 50012 "Ryc Assembly Order" extends "Assembly Order"
{
    /*
    smk2018.04.17 slupg: auto-merge the following
    FH20160929 SCP, Fazle
        - Adding New Functionality for OK32X

    ID2173, nj20181119
    - Added Build Instructions for OK32UV, OK32LED
    */
    layout
    {
        addafter(Status)
        {
            field("Sales Order No."; Rec."Sales Order No.")
            {
                ApplicationArea = All;
            }
            field("Customer Name"; Rec."Customer Name")
            {
                ApplicationArea = All;
            }
            field("Production Remark"; Rec."Production Remark")
            {
                ApplicationArea = All;
            }
            field(decTotalExpectedKg; gdecTotalExpectedKg)
            {
                ApplicationArea = All;
            }
            field("Total Ink Kg (Lines)"; Rec."Total Ink Kg (Lines)")
            {
                ApplicationArea = All;
            }
            field(gdecTotalComponentKg; gdecTotalComponentKg)
            {
                ApplicationArea = All;
            }
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                lrecBuildQuantity: Record "Build Quantity";
                lrecIUoM: Record "Item Unit of Measure";
            begin
                //Fazle05262016-->
                gdecTotalExpectedKg := 0;
                Rec.CALCFIELDS("Total Ink Kg (Lines)", "Total Dryer Kg (Lines)");
                gdecTotalComponentKg := Rec."Total Ink Kg (Lines)" + Rec."Total Dryer Kg (Lines)";
                IF Rec.Quantity > 0 THEN BEGIN
                    IF Rec.CalcBasedOnBuildQty(Rec) OR Rec.CalcBasedOnBuildQty(Rec) THEN BEGIN//FH20160916    FH20160929
                        IF ((lrecIUoM.GET(Rec."Item No.", 'KG')) AND
                           (lrecBuildQuantity.GET(lrecIUoM."1 per Qty. per Unit of Measure", Rec.Quantity))) THEN BEGIN
                            gdecTotalExpectedKg := lrecBuildQuantity."Build Quantity";
                        END
                        ELSE BEGIN
                            gdecTotalExpectedKg := 0;
                            gdecTotalComponentKg := 0;
                        END;
                    END;
                END
                ELSE BEGIN
                    gdecTotalExpectedKg := 0;
                    gdecTotalComponentKg := 0;
                END;
                //Fazle05262016--<
            end;
        }
    }

    actions
    {
    }

    var
        gdecTotalExpectedKg: Decimal;
        gdecTotalComponentKg: Decimal;

    trigger OnAfterGetRecord()
    var
        lrecIUoM: Record "Item Unit of Measure";
        lrecBuildQuantity: Record "Build Quantity";
    begin
        //Fazle05262016-->
        gdecTotalExpectedKg := 0;
        Rec.CALCFIELDS("Total Ink Kg (Lines)", "Total Dryer Kg (Lines)");
        gdecTotalComponentKg := Rec."Total Ink Kg (Lines)" + Rec."Total Dryer Kg (Lines)";
        IF Rec.Quantity > 0 THEN BEGIN
            IF Rec.CalcBasedOnBuildQty(Rec) OR Rec.CalcBasedOnBuildQty2(Rec) OR //FH20160916 FH20160929
               Rec.CalcBasedOnBuildQty_OK32UV(Rec) OR Rec.CalcBasedOnBuildQty_OK32LED(Rec) THEN BEGIN //ID2173
                IF ((lrecIUoM.GET(Rec."Item No.", 'KG')) AND
                   (lrecBuildQuantity.GET(lrecIUoM."1 per Qty. per Unit of Measure", Rec.Quantity))) THEN BEGIN
                    gdecTotalExpectedKg := lrecBuildQuantity."Build Quantity";
                END
                ELSE BEGIN
                    gdecTotalExpectedKg := 0;
                    //gdecTotalComponentKg:=0;
                END;
            END;
        END
        ELSE BEGIN
            gdecTotalExpectedKg := 0;
            gdecTotalComponentKg := 0;
        END;
        //Fazle05262016--<
    end;

}