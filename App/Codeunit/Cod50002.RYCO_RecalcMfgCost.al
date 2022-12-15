codeunit 50002 "Ryco Recalc Mfg Cost"
{

    trigger OnRun()
    begin
    end;

    var
        gcodItemNo: Code[20];

    //[Scope('Internal')]
    procedure "Code"(pcodItemNo: Code[20])
    var
        lrecTempItem: Record Item temporary;
        lrecItem: Record Item;
        lrecTempBOMComp1: Record "BOM Component" temporary;
        lrecTempBOMComp2: Record "BOM Component" temporary;
        lrecTempBOMComp3: Record "BOM Component" temporary;
        lrecTempBOMComp4: Record "BOM Component" temporary;
        lrecTempBOMComp5: Record "BOM Component" temporary;
        lrecTempBOMComp6: Record "BOM Component" temporary;
        lrecTempBOMComp7: Record "BOM Component" temporary;
        lrecTempBOMComp8: Record "BOM Component" temporary;
        lrecTempBOMComp9: Record "BOM Component" temporary;
        lrecTempBOMComp10: Record "BOM Component" temporary;
        lrecBOMComp1: Record "BOM Component";
        lintLineNo: Integer;
    begin
        gcodItemNo := pcodItemNo;
        lintLineNo := 0;
        lrecTempItem.Reset;
        lrecTempItem.DeleteAll;
        lrecTempBOMComp1.Reset;
        lrecTempBOMComp1.DeleteAll;
        lrecTempBOMComp2.Reset;
        lrecTempBOMComp2.DeleteAll;
        lrecTempBOMComp3.Reset;
        lrecTempBOMComp3.DeleteAll;
        lrecTempBOMComp4.Reset;
        lrecTempBOMComp4.DeleteAll;
        lrecTempBOMComp5.Reset;
        lrecTempBOMComp5.DeleteAll;
        lrecTempBOMComp6.Reset;
        lrecTempBOMComp6.DeleteAll;
        lrecTempBOMComp7.Reset;
        lrecTempBOMComp7.DeleteAll;
        lrecTempBOMComp8.Reset;
        lrecTempBOMComp8.DeleteAll;
        lrecTempBOMComp9.Reset;
        lrecTempBOMComp9.DeleteAll;
        lrecTempBOMComp10.Reset;
        lrecTempBOMComp10.DeleteAll;
        lrecBOMComp1.Reset;
        lrecBOMComp1.SetRange("Parent Item No.", gcodItemNo);
        lrecBOMComp1.SetRange("Assembly BOM", true);
        if lrecBOMComp1.FindFirst then
            repeat
                lintLineNo += 10000;
                lrecTempBOMComp1.Init;
                lrecTempBOMComp1."Parent Item No." := gcodItemNo;
                lrecTempBOMComp1."Line No." := lintLineNo;
                lrecTempBOMComp1."No." := lrecBOMComp1."No.";
                lrecTempBOMComp1.Insert;
            until lrecBOMComp1.Next = 0;

        lrecTempBOMComp1.Reset;
        if lrecTempBOMComp1.FindSet then
            repeat
                lrecBOMComp1.Reset;
                lrecBOMComp1.SetRange("Parent Item No.", lrecTempBOMComp1."No.");
                lrecBOMComp1.SetRange("Assembly BOM", true);
                if lrecBOMComp1.FindFirst then
                    repeat
                        lintLineNo += 10000;
                        lrecTempBOMComp2.Init;
                        lrecTempBOMComp2."Parent Item No." := lrecTempBOMComp1."No.";
                        lrecTempBOMComp2."Line No." := lintLineNo;
                        lrecTempBOMComp2."No." := lrecBOMComp1."No.";
                        lrecTempBOMComp2.Insert;
                    until lrecBOMComp1.Next = 0;
            until lrecTempBOMComp1.Next = 0;

        lrecTempBOMComp2.Reset;
        if lrecTempBOMComp2.FindSet then
            repeat
                lrecBOMComp1.Reset;
                lrecBOMComp1.SetRange("Parent Item No.", lrecTempBOMComp2."No.");
                lrecBOMComp1.SetRange("Assembly BOM", true);
                if lrecBOMComp1.FindFirst then
                    repeat
                        lintLineNo += 10000;
                        lrecTempBOMComp3.Init;
                        lrecTempBOMComp3."Parent Item No." := lrecTempBOMComp2."No.";
                        lrecTempBOMComp3."Line No." := lintLineNo;
                        lrecTempBOMComp3."No." := lrecBOMComp1."No.";
                        lrecTempBOMComp3.Insert;
                    until lrecBOMComp1.Next = 0;
            until lrecTempBOMComp2.Next = 0;

        lrecTempBOMComp3.Reset;
        if lrecTempBOMComp3.FindSet then
            repeat
                lrecBOMComp1.Reset;
                lrecBOMComp1.SetRange("Parent Item No.", lrecTempBOMComp3."No.");
                lrecBOMComp1.SetRange("Assembly BOM", true);
                if lrecBOMComp1.FindFirst then
                    repeat
                        lintLineNo += 10000;
                        lrecTempBOMComp4.Init;
                        lrecTempBOMComp4."Parent Item No." := lrecTempBOMComp3."No.";
                        lrecTempBOMComp4."Line No." := lintLineNo;
                        lrecTempBOMComp4."No." := lrecBOMComp1."No.";
                        lrecTempBOMComp4.Insert;
                    until lrecBOMComp1.Next = 0;
            until lrecTempBOMComp3.Next = 0;

        lrecTempBOMComp4.Reset;
        if lrecTempBOMComp4.FindSet then
            repeat
                lrecBOMComp1.Reset;
                lrecBOMComp1.SetRange("Parent Item No.", lrecTempBOMComp4."No.");
                lrecBOMComp1.SetRange("Assembly BOM", true);
                if lrecBOMComp1.FindFirst then
                    repeat
                        lintLineNo += 10000;
                        lrecTempBOMComp5.Init;
                        lrecTempBOMComp5."Parent Item No." := lrecTempBOMComp4."No.";
                        lrecTempBOMComp5."Line No." := lintLineNo;
                        lrecTempBOMComp5."No." := lrecBOMComp1."No.";
                        lrecTempBOMComp5.Insert;
                    until lrecBOMComp1.Next = 0;
            until lrecTempBOMComp4.Next = 0;

        lrecTempBOMComp5.Reset;
        if lrecTempBOMComp5.FindSet then
            repeat
                lrecBOMComp1.Reset;
                lrecBOMComp1.SetRange("Parent Item No.", lrecTempBOMComp5."No.");
                lrecBOMComp1.SetRange("Assembly BOM", true);
                if lrecBOMComp1.FindFirst then
                    repeat
                        lintLineNo += 10000;
                        lrecTempBOMComp6.Init;
                        lrecTempBOMComp6."Parent Item No." := lrecTempBOMComp5."No.";
                        lrecTempBOMComp6."Line No." := lintLineNo;
                        lrecTempBOMComp6."No." := lrecBOMComp1."No.";
                        lrecTempBOMComp6.Insert;
                    until lrecBOMComp1.Next = 0;
            until lrecTempBOMComp5.Next = 0;

        lrecTempBOMComp6.Reset;
        if lrecTempBOMComp6.FindSet then
            repeat
                lrecBOMComp1.Reset;
                lrecBOMComp1.SetRange("Parent Item No.", lrecTempBOMComp6."No.");
                lrecBOMComp1.SetRange("Assembly BOM", true);
                if lrecBOMComp1.FindFirst then
                    repeat
                        lintLineNo += 10000;
                        lrecTempBOMComp7.Init;
                        lrecTempBOMComp7."Parent Item No." := lrecTempBOMComp6."No.";
                        lrecTempBOMComp7."Line No." := lintLineNo;
                        lrecTempBOMComp7."No." := lrecBOMComp1."No.";
                        lrecTempBOMComp7.Insert;
                    until lrecBOMComp1.Next = 0;
            until lrecTempBOMComp6.Next = 0;

        lrecTempBOMComp7.Reset;
        if lrecTempBOMComp7.FindSet then
            repeat
                lrecBOMComp1.Reset;
                lrecBOMComp1.SetRange("Parent Item No.", lrecTempBOMComp7."No.");
                lrecBOMComp1.SetRange("Assembly BOM", true);
                if lrecBOMComp1.FindFirst then
                    repeat
                        lintLineNo += 10000;
                        lrecTempBOMComp8.Init;
                        lrecTempBOMComp8."Parent Item No." := lrecTempBOMComp7."No.";
                        lrecTempBOMComp8."Line No." := lintLineNo;
                        lrecTempBOMComp8."No." := lrecBOMComp1."No.";
                        lrecTempBOMComp8.Insert;
                    until lrecBOMComp1.Next = 0;
            until lrecTempBOMComp7.Next = 0;

        lrecTempBOMComp8.Reset;
        if lrecTempBOMComp8.FindSet then
            repeat
                lrecBOMComp1.Reset;
                lrecBOMComp1.SetRange("Parent Item No.", lrecTempBOMComp8."No.");
                lrecBOMComp1.SetRange("Assembly BOM", true);
                if lrecBOMComp1.FindFirst then
                    repeat
                        lintLineNo += 10000;
                        lrecTempBOMComp9.Init;
                        lrecTempBOMComp9."Parent Item No." := lrecTempBOMComp8."No.";
                        lrecTempBOMComp9."Line No." := lintLineNo;
                        lrecTempBOMComp9."No." := lrecBOMComp1."No.";
                        lrecTempBOMComp9.Insert;
                    until lrecBOMComp1.Next = 0;
            until lrecTempBOMComp8.Next = 0;

        lrecTempBOMComp9.Reset;
        if lrecTempBOMComp9.FindSet then
            repeat
                lrecBOMComp1.Reset;
                lrecBOMComp1.SetRange("Parent Item No.", lrecTempBOMComp9."No.");
                lrecBOMComp1.SetRange("Assembly BOM", true);
                if lrecBOMComp1.FindFirst then
                    repeat
                        lintLineNo += 10000;
                        lrecTempBOMComp10.Init;
                        lrecTempBOMComp10."Parent Item No." := lrecTempBOMComp9."No.";
                        lrecTempBOMComp10."Line No." := lintLineNo;
                        lrecTempBOMComp10."No." := lrecBOMComp1."No.";
                        lrecTempBOMComp10.Insert;
                    until lrecBOMComp1.Next = 0;
            until lrecTempBOMComp9.Next = 0;

        lrecTempBOMComp10.Reset;
        lrecTempBOMComp10.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp10.Ascending(false);
        if lrecTempBOMComp10.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp10."No.");
            until lrecTempBOMComp10.Next = 0;

        lrecTempBOMComp9.Reset;
        lrecTempBOMComp9.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp9.Ascending(false);
        if lrecTempBOMComp9.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp9."No.");
            until lrecTempBOMComp9.Next = 0;

        lrecTempBOMComp8.Reset;
        lrecTempBOMComp8.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp8.Ascending(false);
        if lrecTempBOMComp8.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp8."No.");
            until lrecTempBOMComp8.Next = 0;

        lrecTempBOMComp7.Reset;
        lrecTempBOMComp7.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp7.Ascending(false);
        if lrecTempBOMComp7.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp7."No.");
            until lrecTempBOMComp7.Next = 0;

        lrecTempBOMComp6.Reset;
        lrecTempBOMComp6.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp6.Ascending(false);
        if lrecTempBOMComp6.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp6."No.");
            until lrecTempBOMComp6.Next = 0;

        lrecTempBOMComp5.Reset;
        lrecTempBOMComp5.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp5.Ascending(false);
        if lrecTempBOMComp5.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp5."No.");
            until lrecTempBOMComp5.Next = 0;

        lrecTempBOMComp4.Reset;
        lrecTempBOMComp4.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp4.Ascending(false);
        if lrecTempBOMComp4.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp4."No.");
            until lrecTempBOMComp4.Next = 0;

        lrecTempBOMComp3.Reset;
        lrecTempBOMComp3.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp3.Ascending(false);
        if lrecTempBOMComp3.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp3."No.");
            until lrecTempBOMComp3.Next = 0;

        lrecTempBOMComp2.Reset;
        lrecTempBOMComp2.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp2.Ascending(false);
        if lrecTempBOMComp2.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp2."No.");
            until lrecTempBOMComp2.Next = 0;

        lrecTempBOMComp1.Reset;
        lrecTempBOMComp1.SetCurrentKey("Line No.", "Parent Item No.", "No.");
        lrecTempBOMComp1.Ascending(false);
        if lrecTempBOMComp1.FindSet then
            repeat
                CalcMfgCost(lrecTempBOMComp1."No.");
            until lrecTempBOMComp1.Next = 0;

        CalcMfgCost(gcodItemNo);
    end;

    local procedure CalcMfgCost(pcodItemNo: Code[20])
    var
        lrecItem: Record Item;
        ldecMfgCost: Decimal;
        ldecMaterialCost: Decimal;
    begin
        lrecItem.Get(pcodItemNo);
        lrecItem.CalcFields("Assembly BOM");
        Clear(ldecMfgCost);
        Clear(ldecMaterialCost);
        if lrecItem."Assembly BOM" then begin
            ldecMaterialCost := CalcMaterialCost(lrecItem);
            ldecMfgCost := ldecMaterialCost + (ldecMaterialCost * (lrecItem."Labour%" / 100)) + lrecItem."Labour$";
        end;
        //IF ldecMfgCost <> 0 THEN BEGIN
        lrecItem.Validate("Mfg. Cost", ldecMfgCost);
        lrecItem.Validate("Material Cost", ldecMaterialCost);
        lrecItem.Modify;
        Commit;
        //END;
    end;

    local procedure CalcMaterialCost(precItem: Record Item): Decimal
    var
        lrecItem: Record Item;
        lrecIUOM: Record "Item Unit of Measure";
        lrecBOMComponent: Record "BOM Component";
        ldecMaterialCost: Decimal;
        ldecUOMConvert: Decimal;
        ldecCompCost: Decimal;
    begin
        Clear(ldecMaterialCost);
        if precItem."Assembly BOM" then begin
            lrecBOMComponent.Reset;
            lrecBOMComponent.SetRange("Parent Item No.", precItem."No.");
            lrecBOMComponent.SetRange(Type, lrecBOMComponent.Type::Item);
            lrecBOMComponent.SetFilter("No.", '<>%1', '');
            if lrecBOMComponent.FindSet then
                repeat
                    if lrecItem.Get(lrecBOMComponent."No.") then begin
                        lrecIUOM.Reset;
                        lrecIUOM.SetRange("Item No.", lrecBOMComponent."No.");
                        lrecIUOM.SetRange(Code, lrecBOMComponent."Unit of Measure Code");
                        if lrecIUOM.FindSet then
                            ldecUOMConvert := lrecIUOM."Qty. per Unit of Measure"
                        else
                            ldecUOMConvert := 1;
                        lrecBOMComponent.CalcFields("Assembly BOM");
                        if lrecBOMComponent."Assembly BOM" then begin
                            if lrecItem."Material Cost" = 0 then
                                ldecMaterialCost += lrecItem."Unit Cost" * lrecBOMComponent."Quantity per" * ldecUOMConvert
                            else
                                ldecMaterialCost += lrecItem."Material Cost" * lrecBOMComponent."Quantity per" * ldecUOMConvert;
                        end else begin
                            ldecCompCost := CalcMaterialCost(lrecItem);
                            if ldecCompCost <> 0 then
                                lrecItem.Validate("Mfg. Cost", ldecCompCost + (ldecCompCost * (lrecItem."Labour%" / 100)) + lrecItem."Labour$");
                            if lrecItem."Mfg. Cost" = 0 then
                                ldecMaterialCost += lrecItem."Unit Cost" * lrecBOMComponent."Quantity per" * ldecUOMConvert
                            else
                                ldecMaterialCost += lrecItem."Mfg. Cost" * lrecBOMComponent."Quantity per" * ldecUOMConvert;
                        end;
                    end;
                until lrecBOMComponent.Next = 0;
        end;
        //IF ldecMaterialCost<>0 THEN
        //  "Material Cost" := ldecMaterialCost;
        exit(ldecMaterialCost);
    end;
}

