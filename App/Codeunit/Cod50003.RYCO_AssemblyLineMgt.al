codeunit 50003 "Ryco Assembly Line Mgt."
{
    /*
    Note: extension of Codeunit 905 Assembly Line Management
    */
    trigger OnRun()
    begin
    end;

    var
        gcodItemNo: Code[20];
        AssemblyLineMgt: codeunit "Assembly Line Management";
        Text001: Label 'Do you want to update the %1 on the lines?';
        Text002: Label 'Do you want to update the Dimensions on the lines?';
        Text003: Label 'Changing %1 will change all the lines. Do you want to change the %1 from %2 to %3?';
        Text004: Label 'This assembly order may have customized lines. Are you sure that you want to reset the lines according to the assembly BOM?';

    local procedure AddBOMLine2_BQ(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean; BomComponent: Record "BOM Component"; ShowDueDateBeforeWorkDateMessage: Boolean)
    var
        DueDateBeforeWorkDateMsgShown: Boolean;
        SkipVerificationsThatChangeDatabase: Boolean;
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        lrecItem: Record Item;
    begin
        //BQ: Build Quantity - this calculation is based on Build Quantity
        //with AsmHeader do begin
        SkipVerificationsThatChangeDatabase := AsmLineRecordIsTemporary;
        AssemblyLine.SetSkipVerificationsThatChangeDatabase(SkipVerificationsThatChangeDatabase);
        AssemblyLine.Validate(Type, BomComponent.Type);
        AssemblyLine.Validate("No.", BomComponent."No.");
        if AssemblyLine.Type = AssemblyLine.Type::Resource then
            case BomComponent."Resource Usage Type" of
                BomComponent."Resource Usage Type"::Direct:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Direct);
                BomComponent."Resource Usage Type"::Fixed:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Fixed);
            end;
        AssemblyLine.Validate("Unit of Measure Code", BomComponent."Unit of Measure Code");
        //Fazle05252016-->
        //IF AssemblyLine.Type <> AssemblyLine.Type::" " THEN
        //  AssemblyLine.VALIDATE(
        //    "Quantity per",
        //    AssemblyLine.CalcQuantityFromBOM(
        //      BomComponent.Type,BomComponent."Quantity per",1,"Qty. per Unit of Measure",AssemblyLine."Resource Usage Type"));
        if BomComponent.Ink then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                if lrecIUoM.Get(BomComponent."Parent Item No.", 'KG') then begin
                    if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                        BomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity" / AsmHeader.Quantity) * BomComponent."Ink Percentage") / 100;
                    end;
                end;
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
            end;
        end
        else begin
            if AssemblyLine.Type <> AssemblyLine.Type::" " then
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        end;
        //Fazle05252016--<

        AssemblyLine.Validate(
          Quantity,
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        AssemblyLine.Validate(
          "Quantity to Consume",
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
            AssemblyLine."Resource Usage Type"));
        AssemblyLine.ValidateDueDate(AsmHeader, AsmHeader."Starting Date", ShowDueDateBeforeWorkDateMessage);
        DueDateBeforeWorkDateMsgShown := (AssemblyLine."Due Date" < WorkDate) and ShowDueDateBeforeWorkDateMessage;
        AssemblyLine.ValidateLeadTimeOffset(
          AsmHeader, BomComponent."Lead-Time Offset", not DueDateBeforeWorkDateMsgShown and ShowDueDateBeforeWorkDateMessage);
        AssemblyLine.Description := BomComponent.Description;
        AssemblyLine."Description 2" := AsmHeader."Description 2";
        if AssemblyLine.Type = AssemblyLine.Type::Item then
            AssemblyLine.Validate("Variant Code", BomComponent."Variant Code");
        AssemblyLine.Position := BomComponent.Position;
        AssemblyLine."Position 2" := BomComponent."Position 2";
        AssemblyLine."Position 3" := BomComponent."Position 3";
        if AsmHeader."Location Code" <> '' then
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        // nj20160511 - Start
        AssemblyLine."Instruction Code" := BomComponent."Instruction Code";
        AssemblyLine."Ink Percentage" := BomComponent."Ink Percentage";
        AssemblyLine.Ink := BomComponent.Ink;
        // nj20160511 - End
        AssemblyLine.Modify(true);
        //end;
    end;

    //[Scope('Internal')]
    procedure UpdateAssemblyLines_BQ(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; FieldNum: Integer; ReplaceLinesFromBOM: Boolean; CurrFieldNo: Integer; CurrentFieldNum: Integer)
    var
        AssemblyLine: Record "Assembly Line";
        TempAssemblyHeader: Record "Assembly Header" temporary;
        TempAssemblyLine: Record "Assembly Line" temporary;
        BomComponent: Record "BOM Component";
        TempCurrAsmLine: Record "Assembly Line" temporary;
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        NoOfLinesFound: Integer;
        UpdateDueDate: Boolean;
        UpdateLocation: Boolean;
        UpdateQuantity: Boolean;
        UpdateUOM: Boolean;
        UpdateQtyToConsume: Boolean;
        UpdateDimension: Boolean;
        DueDateBeforeWorkDate: Boolean;
        NewLineDueDate: Date;
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
        lrecBOMInstruction: Record "BOM Instruction";
        lboolDryerLineInserted: Boolean;
        lrecItem1: Record Item;
        lrecBuildQuantity: Record "Build Quantity";
        lrecBomComponent: Record "BOM Component";
    //xltmprecItem: Record Item temporary;
    begin
        if (FieldNum <> CurrentFieldNum) or // Update has been called from OnValidate of another field than was originally intended.
           ((not (FieldNum in [AsmHeader.FieldNo("Item No."),
                               AsmHeader.FieldNo("Variant Code"),
                               AsmHeader.FieldNo("Location Code"),
                               AsmHeader.FieldNo("Starting Date"),
                               AsmHeader.FieldNo(Quantity),
                               AsmHeader.FieldNo("Unit of Measure Code"),
                               AsmHeader.FieldNo("Quantity to Assemble"),
                               AsmHeader.FieldNo("Dimension Set ID")])) and (not ReplaceLinesFromBOM))
        then
            exit;
        Clear(lboolDryerLineInserted);//Fazle05252016
        NoOfLinesFound := AssemblyLineMgt.CopyAssemblyData(AsmHeader, TempAssemblyHeader, TempAssemblyLine);
        if ReplaceLinesFromBOM then begin
            TempAssemblyLine.DeleteAll;
            if not ((AsmHeader."Quantity (Base)" = 0) or (AsmHeader."Item No." = '')) then begin  // condition to replace asm lines
                //AssemblyLineMgt.SetLinkToBOM(AsmHeader, BomComponent);
                BOMComponent.SETRANGE("Parent Item No.", AsmHeader."Item No.");
                if BomComponent.FindSet then begin
                    //Fazle05262016-->
                    //ltmprecItem.DELETEALL;
                    //Fazle05262016-->
                    repeat
                        //AssemblyLineMgt.InsertAsmLine(AsmHeader, TempAssemblyLine, true);
                        TempAssemblyLine.INIT;
                        TempAssemblyLine."Document Type" := AsmHeader."Document Type";
                        TempAssemblyLine."Document No." := AsmHeader."No.";
                        TempAssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(TempAssemblyLine, true);
                        TempAssemblyLine.INSERT(TRUE);
                        AddBOMLine2_BQ(AsmHeader, TempAssemblyLine, true, BomComponent, false);
                    /*
                    // nj20160511 - Start
                    // if line has an Instruction Code, check if the
                    IF BomComponent."Instruction Code" <> '' THEN BEGIN
                      lrecBOMInstruction.GET(BomComponent."Instruction Code");
                      IF lrecBOMInstruction.Dryer <> lrecBOMInstruction.Dryer::" " THEN BEGIN
                        IF (lrecItem.GET(BomComponent."Parent Item No.")) AND (lrecItem."Dryer (%)" > 0) THEN BEGIN
                          IF (lrecItemUOM.GET(BomComponent."Parent Item No.",'KG')) AND (lrecItemUOM."Qty. per Unit of Measure" > 0) THEN BEGIN
                            BomComponent.Description := FORMAT(lrecBOMInstruction.Dryer) + ': ' +
                                                        FORMAT(lrecItem."Dryer (%)" * lrecItemUOM."Qty. per Unit of Measure" / 100) + ' Colour';
                            BomComponent."Ink Percentage" := lrecItem."Dryer (%)";
                            BomComponent."Instruction Code" := '';
                            InsertAsmLine(AsmHeader,TempAssemblyLine,TRUE);
                            AddBOMLine2(AsmHeader,TempAssemblyLine,TRUE,BomComponent,FALSE);
                          END;
                        END;
                      END;
                    END;
                    // nj20160511 - End
                    *///Fazle05252016
                      /*//Fazle05262016-->
                      IF (BomComponent.Type=BomComponent.Type::Item) AND (BomComponent.Ink=TRUE) THEN BEGIN
                        ltmprecItem.INIT;
                        IF lrecItem.GET(BomComponent."No.") THEN BEGIN
                          ltmprecItem.INIT;
                          ltmprecItem.TRANSFERFIELDS(lrecItem);
                          IF ltmprecItem.INSERT(TRUE) THEN;
                        END;
                      END;
                      //Fazle05262016--<
                      */
                    until BomComponent.Next <= 0;
                    //Fazle05252016-->
                    //MESSAGE(FORMAT(ltmprecItem.COUNT));
                    BomComponent.FindLast;
                    if not lboolDryerLineInserted then begin
                        //IF (lrecItem.GET(BomComponent."Parent Item No.")) AND (lrecItem."Dryer (%)" > 0) THEN BEGIN
                        lrecBomComponent.Reset;
                        lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                        lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                        lrecBomComponent.SetRange(Ink, true);
                        if not lrecBomComponent.IsEmpty then begin
                            //IF NOT ltmprecItem.ISEMPTY THEN BEGIN
                            if (lrecItemUOM.Get(BomComponent."Parent Item No.", 'KG')) and (lrecItemUOM."1 per Qty. per Unit of Measure" > 0) then begin
                                if lrecBuildQuantity.Get(lrecItemUOM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                    BomComponent."Quantity per" := 0;
                                    /*
                                    IF lrecItem."Master Item No." THEN BEGIN
                                      //D25 line
                                      BomComponent.Type:=BomComponent.Type::Item;
                                      lrecItem1.GET('D25');
                                      BomComponent."No.":='D25';
                                      BomComponent."Unit of Measure Code":=lrecItem1."Base Unit of Measure";

                                      //BomComponent.Description := 'D25' + ': ' +FORMAT((lrecItem."Dryer (%)" * lrecItemUOM."Qty. per Unit of Measure"*AsmHeader.Quantity / 100)/2) + ' Colour';
                                      //BomComponent."Quantity per":= (lrecItem."Dryer (%)" * lrecItemUOM."Qty. per Unit of Measure"/ 100)/2;
                                      IF ltmprecItem.FINDSET THEN BEGIN
                                        REPEAT
                                          lrecBomComponent.RESET;
                                          lrecBomComponent.SETRANGE("Parent Item No.",AsmHeader."Item No.");
                                          lrecBomComponent.SETRANGE(Type,lrecBomComponent.Type::Item);
                                          lrecBomComponent.SETRANGE("No.",ltmprecItem."No.");
                                          lrecBomComponent.SETRANGE(Ink,TRUE);
                                          IF lrecBomComponent.FINDFIRST THEN BEGIN
                                            BomComponent."Quantity per"+=(((ltmprecItem."Dryer (%)"/100)*(lrecBomComponent."Ink Percentage"/100)*(lrecBuildQuantity."Build Quantity"))/AsmHeader.Quantity)/2;
                                          END;
                                        UNTIL ltmprecItem.NEXT=0;
                                      END;
                                      InsertAsmLine(AsmHeader,TempAssemblyLine,TRUE);
                                      AddBOMLine2_BQ(AsmHeader,TempAssemblyLine,TRUE,BomComponent,FALSE);
                                      //D26 line
                                      BomComponent."No.":='D26';
                                      InsertAsmLine(AsmHeader,TempAssemblyLine,TRUE);
                                      AddBOMLine2_BQ(AsmHeader,TempAssemblyLine,TRUE,BomComponent,FALSE);
                                      lboolDryerLineInserted:=TRUE;
                                    END
                                    ELSE BEGIN
                                    *///Always D4 Master Item or Not a Master Item
                                      //D4 line
                                    BomComponent.Type := BomComponent.Type::Item;
                                    lrecItem1.Get('D4');
                                    BomComponent."No." := 'D4';
                                    BomComponent."Unit of Measure Code" := lrecItem1."Base Unit of Measure";
                                    BomComponent.Ink := false;//FH20161003
                                    if lrecBomComponent.FindSet then begin
                                        //IF ltmprecItem.FINDSET THEN BEGIN
                                        repeat
                                            if lrecItem.Get(lrecBomComponent."No.") then begin
                                                //lrecBomComponent.RESET;
                                                //lrecBomComponent.SETRANGE("Parent Item No.",AsmHeader."Item No.");
                                                //lrecBomComponent.SETRANGE(Type,lrecBomComponent.Type::Item);
                                                //lrecBomComponent.SETRANGE("No.",ltmprecItem."No.");
                                                //lrecBomComponent.SETRANGE(Ink,TRUE);
                                                //IF lrecBomComponent.FINDFIRST THEN BEGIN

                                                //BomComponent."Quantity per"+=((ltmprecItem."Dryer (%)"/100)*(lrecBomComponent."Ink Percentage"/100)*(lrecBuildQuantity."Build Quantity"))/AsmHeader.Quantity;
                                                //BomComponent."Quantity per"+=((lrecItem."Dryer (%)"/100)*(lrecBomComponent."Ink Percentage"/100)*(lrecBuildQuantity."Build Quantity"))/AsmHeader.Quantity;
                                                BomComponent."Quantity per" += (lrecItem."Dryer (%)" / 100) * (lrecBomComponent."Ink Percentage" / 100) * (lrecItemUOM."1 per Qty. per Unit of Measure");//Fazle06102016
                                                                                                                                                                                                         //BomComponent."Quantity per":= (lrecItem."Dryer (%)" * lrecItemUOM."Qty. per Unit of Measure" / 100);
                                                                                                                                                                                                         //END;
                                                                                                                                                                                                         //UNTIL ltmprecItem.NEXT=0;
                                            end;
                                        until lrecBomComponent.Next = 0;
                                    end;
                                    InsertAsmLine_D4(AsmHeader, TempAssemblyLine, true);//FH20160916
                                    AddBOMLine2_BQ(AsmHeader, TempAssemblyLine, true, BomComponent, false);
                                    lboolDryerLineInserted := true;
                                    //END;}//Always D4 Master Item or Not a Master Item
                                end;
                            end;
                        end;
                        //END;
                    end;
                    //Fazle05252016--<
                end;
            end;
        end else
            if NoOfLinesFound = 0 then
                exit; // MODIFY condition but no lines to modify

        // make pre-checks OR ask user to confirm
        if PreCheckAndConfirmUpdate(AsmHeader, OldAsmHeader, FieldNum, ReplaceLinesFromBOM, TempAssemblyLine,
             UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension)
        then
            exit;

        if not ReplaceLinesFromBOM then
            if TempAssemblyLine.Find('-') then
                repeat
                    TempCurrAsmLine := TempAssemblyLine;
                    TempCurrAsmLine.Insert;
                    TempAssemblyLine.SetSkipVerificationsThatChangeDatabase(true);
                    UpdateExistingLine_BQ(AsmHeader, OldAsmHeader, CurrFieldNo, TempAssemblyLine,
                      UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension);//Fazle05312017
                until TempAssemblyLine.Next = 0;

        if not (FieldNum in [AsmHeader.FieldNo("Quantity to Assemble"), AsmHeader.FieldNo("Dimension Set ID")]) then
            if AssemblyLineMgt.ShowAvailability(false, TempAssemblyHeader, TempAssemblyLine) then
                ItemCheckAvail.RaiseUpdateInterruptedError;

        DoVerificationsSkippedEarlier(
          ReplaceLinesFromBOM, TempAssemblyLine, TempCurrAsmLine, UpdateDimension, AsmHeader."Dimension Set ID",
          OldAsmHeader."Dimension Set ID");

        AssemblyLine.Reset;
        if ReplaceLinesFromBOM then begin
            //rem smk2018.04.18 SLUPG: DeleteLines(AsmHeader);
            AsmHeader.DeleteAssemblyLines; //add smk2018.04.18 SLUPG
            TempAssemblyLine.Reset;
        end;

        if TempAssemblyLine.Find('-') then
            repeat
                if not ReplaceLinesFromBOM then
                    AssemblyLine.Get(TempAssemblyLine."Document Type", TempAssemblyLine."Document No.", TempAssemblyLine."Line No.");
                AssemblyLine := TempAssemblyLine;
                if ReplaceLinesFromBOM then
                    AssemblyLine.Insert(true)
                else
                    AssemblyLine.Modify(true);
                AsmHeader.AutoReserveAsmLine(AssemblyLine);
                if AssemblyLine."Due Date" < WorkDate then begin
                    DueDateBeforeWorkDate := true;
                    NewLineDueDate := AssemblyLine."Due Date";
                end;
            until TempAssemblyLine.Next = 0;

        if ReplaceLinesFromBOM or UpdateDueDate then
            if DueDateBeforeWorkDate then
                AssemblyLineMgt.ShowDueDateBeforeWorkDateMsg(NewLineDueDate);

    end;

    local procedure UpdateExistingLine_BQ(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; CurrFieldNo: Integer; var AssemblyLine: Record "Assembly Line"; UpdateDueDate: Boolean; UpdateLocation: Boolean; UpdateQuantity: Boolean; UpdateUOM: Boolean; UpdateQtyToConsume: Boolean; UpdateDimension: Boolean)
    var
        QtyRatio: Decimal;
        QtyToConsume: Decimal;
        lrecBomComponent: Record "BOM Component";
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        ldecQuantityper: Decimal;
        lrecItem: Record Item;
    begin
        //with AsmHeader do begin
        if AsmHeader.IsStatusCheckSuspended then
            AssemblyLine.SuspendStatusCheck(true);

        if UpdateLocation then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        end;

        if UpdateDueDate then begin
            AssemblyLine.SetTestReservationDateConflict(CurrFieldNo <> 0);
            AssemblyLine.ValidateLeadTimeOffset(AsmHeader, AssemblyLine."Lead-Time Offset", false);
        end;

        if UpdateQuantity then begin
            QtyRatio := AsmHeader.Quantity / OldAsmHeader.Quantity;
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate(Quantity)
            else
                AssemblyLine.Validate(Quantity, AssemblyLine.Quantity * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateUOM then begin
            QtyRatio := AsmHeader."Qty. per Unit of Measure" / OldAsmHeader."Qty. per Unit of Measure";
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate("Quantity per")
            else
                AssemblyLine.Validate("Quantity per", AssemblyLine."Quantity per" * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateQtyToConsume then
            if not AssemblyLine.FixedUsage then begin
                AssemblyLine.InitQtyToConsume;
                QtyToConsume := AssemblyLine.Quantity * AsmHeader."Quantity to Assemble" / AsmHeader.Quantity;
                AsmHeader.RoundQty(QtyToConsume);
                if QtyToConsume <= AssemblyLine.MaxQtyToConsume then
                    AssemblyLine.Validate("Quantity to Consume", QtyToConsume);
            end;

        //Fazle05252016-->
        if UpdateQuantity then begin
            if not AssemblyLine.FixedUsage then begin
                if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                    lrecBomComponent.Reset;
                    lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                    lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                    lrecBomComponent.SetRange("No.", AssemblyLine."No.");
                    lrecBomComponent.SetRange(Ink, true);
                    if lrecBomComponent.FindFirst then begin
                        if lrecIUoM.Get(lrecBomComponent."Parent Item No.", 'KG') then begin
                            if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                lrecBomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity" / AsmHeader.Quantity) * lrecBomComponent."Ink Percentage") / 100;
                                AssemblyLine.Validate("Quantity per", lrecBomComponent."Quantity per");
                                //copied from AddBOMLine2()-->

                                AssemblyLine.Validate(
                                  Quantity,
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));

                                AssemblyLine.Validate(
                                  "Quantity to Consume",
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
                                    AssemblyLine."Resource Usage Type"));

                                //copied from AddBOMLine2()--<
                            end;
                        end;
                    end
                    //D4 D25 D26 Line Update
                    else begin
                        //IF AssemblyLine."No." IN ['D4','D25','D26'] THEN BEGIN
                        if AssemblyLine."No." = 'D4' then begin//Always D4 Master Item or Not a Master Item
                            ldecQuantityper := 0;
                            lrecBomComponent.Reset;
                            lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                            lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                            lrecBomComponent.SetRange(Ink, true);
                            if lrecBomComponent.FindSet then begin
                                repeat
                                    if lrecItem.Get(lrecBomComponent."No.") then begin
                                        if lrecIUoM.Get(lrecBomComponent."Parent Item No.", 'KG') then begin
                                            if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                                //ldecQuantityper+=((lrecItem."Dryer (%)"/100)*(lrecBomComponent."Ink Percentage"/100)*(lrecBuildQuantity."Build Quantity"))/AsmHeader.Quantity;
                                                ldecQuantityper += (lrecItem."Dryer (%)" / 100) * (lrecBomComponent."Ink Percentage" / 100) * (lrecIUoM."1 per Qty. per Unit of Measure");//Fazle06102016
                                            end;
                                        end;
                                    end;
                                until lrecBomComponent.Next = 0;
                                AssemblyLine.Validate("Quantity per", ldecQuantityper);
                                AssemblyLine.Validate(
                                  Quantity,
                                  AssemblyLine.CalcBOMQuantity(
                                    AssemblyLine.Type, ldecQuantityper, AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));

                                AssemblyLine.Validate(
                                  "Quantity to Consume",
                                  AssemblyLine.CalcBOMQuantity(
                                    AssemblyLine.Type, ldecQuantityper, AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
                            end;
                        end;
                    end;
                end;
            end;
        end;
        //Fazle05252016--<


        if UpdateDimension then
            AssemblyLine.UpdateDim(AsmHeader."Dimension Set ID", OldAsmHeader."Dimension Set ID");

        AssemblyLine.Modify(true);
        //end;
    end;

    local procedure InsertAsmLine_D4(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean)
    var
        lrecAssemblyLine: Record "Assembly Line";
        lintLineNo: Integer;
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //with AsmHeader do begin
        AssemblyLine.Init;
        AssemblyLine."Document Type" := AsmHeader."Document Type";
        AssemblyLine."Document No." := AsmHeader."No.";
        AssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(AssemblyLine, AsmLineRecordIsTemporary);

        //New for D4 Line--> FH20160916
        lintLineNo := 0;
        AssemblyLine.Reset;
        AssemblyLine.SetRange("Document Type", AsmHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AsmHeader."No.");
        //FH20160929-->
        //AssemblyLine.SETFILTER(Description,'*D4*');
        lrecAssemblySetup.Get();
        if AsmHeader.CalcBasedOnBuildQty(AsmHeader) then
            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code")
        else
            if AsmHeader.CalcBasedOnBuildQty2(AsmHeader) then
                AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 2")
            else
                if AsmHeader.CalcBasedOnBuildQty_OK32LT(AsmHeader) then
                    AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 3")
                //ID2173 - Start
                else
                    if AsmHeader.CalcBasedOnBuildQty_OK32UV(AsmHeader) then
                        AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 4")
                    else
                        if AsmHeader.CalcBasedOnBuildQty_OK32LED(AsmHeader) then
                            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 5");
        //ID2173 - End

        //FH20160929--<
        if AssemblyLine.FindLast then begin
            lintLineNo := AssemblyLine."Line No." - 10;
        end;
        if lintLineNo > 0 then
            //New--<
            AssemblyLine."Line No." := lintLineNo;
        AssemblyLine.Insert(true);
        //end;
    end;

    //[Scope('Internal')]
    procedure UpdateAssemblyLines_BQ2(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; FieldNum: Integer; ReplaceLinesFromBOM: Boolean; CurrFieldNo: Integer; CurrentFieldNum: Integer)
    var
        AssemblyLine: Record "Assembly Line";
        TempAssemblyHeader: Record "Assembly Header" temporary;
        TempAssemblyLine: Record "Assembly Line" temporary;
        BomComponent: Record "BOM Component";
        TempCurrAsmLine: Record "Assembly Line" temporary;
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        NoOfLinesFound: Integer;
        UpdateDueDate: Boolean;
        UpdateLocation: Boolean;
        UpdateQuantity: Boolean;
        UpdateUOM: Boolean;
        UpdateQtyToConsume: Boolean;
        UpdateDimension: Boolean;
        DueDateBeforeWorkDate: Boolean;
        NewLineDueDate: Date;
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
        lrecBOMInstruction: Record "BOM Instruction";
        lboolDryerLineInserted: Boolean;
        lrecItem1: Record Item;
        lrecBuildQuantity: Record "Build Quantity";
        lrecBomComponent: Record "BOM Component";
        //xltmprecItem: Record Item temporary;
        lcodItemNo: Code[20];
    begin
        //FH20160929

        if (FieldNum <> CurrentFieldNum) or // Update has been called from OnValidate of another field than was originally intended.
           ((not (FieldNum in [AsmHeader.FieldNo("Item No."),
                               AsmHeader.FieldNo("Variant Code"),
                               AsmHeader.FieldNo("Location Code"),
                               AsmHeader.FieldNo("Starting Date"),
                               AsmHeader.FieldNo(Quantity),
                               AsmHeader.FieldNo("Unit of Measure Code"),
                               AsmHeader.FieldNo("Quantity to Assemble"),
                               AsmHeader.FieldNo("Dimension Set ID")])) and (not ReplaceLinesFromBOM))
        then
            exit;
        Clear(lboolDryerLineInserted);//Fazle05252016
        NoOfLinesFound := AssemblyLineMgt.CopyAssemblyData(AsmHeader, TempAssemblyHeader, TempAssemblyLine);
        if ReplaceLinesFromBOM then begin
            TempAssemblyLine.DeleteAll;
            if not ((AsmHeader."Quantity (Base)" = 0) or (AsmHeader."Item No." = '')) then begin  // condition to replace asm lines
                //SetLinkToBOM(AsmHeader, BomComponent);
                BOMComponent.SETRANGE("Parent Item No.", AsmHeader."Item No.");

                if BomComponent.FindSet then begin
                    //Fazle05262016-->
                    //ltmprecItem.DELETEALL;
                    //Fazle05262016-->
                    repeat
                        //InsertAsmLine(AsmHeader, TempAssemblyLine, true);
                        TempAssemblyLine.INIT;
                        TempAssemblyLine."Document Type" := AsmHeader."Document Type";
                        TempAssemblyLine."Document No." := AsmHeader."No.";
                        TempAssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(TempAssemblyLine, true);
                        TempAssemblyLine.INSERT(TRUE);

                        AddBOMLine2_BQ2(AsmHeader, TempAssemblyLine, true, BomComponent, false);
                    until BomComponent.Next <= 0;
                    //Fazle05252016-->
                    //MESSAGE(FORMAT(ltmprecItem.COUNT));
                    BomComponent.FindLast;
                    if not lboolDryerLineInserted then begin
                        //IF (lrecItem.GET(BomComponent."Parent Item No.")) AND (lrecItem."Dryer (%)" > 0) THEN BEGIN
                        lrecBomComponent.Reset;
                        lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                        lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                        lrecBomComponent.SetRange(Ink, true);
                        if not lrecBomComponent.IsEmpty then begin
                            //IF NOT ltmprecItem.ISEMPTY THEN BEGIN
                            if (lrecItemUOM.Get(BomComponent."Parent Item No.", 'KG')) and (lrecItemUOM."1 per Qty. per Unit of Measure" > 0) then begin
                                if lrecBuildQuantity.Get(lrecItemUOM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                    BomComponent."Quantity per" := 0;
                                    //Always D4 Master Item or Not a Master Item
                                    //FH20160929-->
                                    BomComponent.Type := BomComponent.Type::Item;
                                    // rem nj20161230 lrecItem1.GET('D33');
                                    // rem nj20161230 BomComponent."No.":='D33';
                                    // nj20161230 - Start
                                    lcodItemNo := 'D 33-1';
                                    lrecItem1.Get(lcodItemNo);
                                    BomComponent."No." := lcodItemNo;
                                    // nj20161230 - End
                                    //BomComponent."Unit of Measure Code":=lrecItem1."Base Unit of Measure";
                                    // jl20180209 start
                                    if lcodItemNo = 'D 33-1' then
                                        BomComponent."Unit of Measure Code" := 'KG'
                                    else
                                        BomComponent."Unit of Measure Code" := lrecItem1."Base Unit of Measure";
                                    // jl2018029 end
                                    BomComponent.Ink := false;//FH20161003
                                    BomComponent."Quantity per" := (lrecItemUOM."1 per Qty. per Unit of Measure" / 100);

                                    InsertAsmLine_D33(AsmHeader, TempAssemblyLine, true);//FH20160929
                                    AddBOMLine2_BQ2(AsmHeader, TempAssemblyLine, true, BomComponent, false);
                                    //FH20160929--<

                                    //D4 line
                                    BomComponent."Quantity per" := 0;  // nj20161230
                                    BomComponent.Type := BomComponent.Type::Item;
                                    lrecItem1.Get('D4');
                                    BomComponent."No." := 'D4';
                                    BomComponent."Unit of Measure Code" := lrecItem1."Base Unit of Measure";
                                    BomComponent.Ink := false;//FH20161003
                                    if lrecBomComponent.FindSet then begin
                                        //IF ltmprecItem.FINDSET THEN BEGIN
                                        repeat
                                            if lrecItem.Get(lrecBomComponent."No.") then begin
                                                BomComponent."Quantity per" += (lrecItem."Dryer (%)" / 100) * (lrecBomComponent."Ink Percentage" / 100) * (lrecItemUOM."1 per Qty. per Unit of Measure");//Fazle06102016
                                            end;
                                        until lrecBomComponent.Next = 0;
                                        BomComponent."Quantity per" := BomComponent."Quantity per" * 1.5;//FH20160929
                                    end;
                                    InsertAsmLine_D4(AsmHeader, TempAssemblyLine, true);//FH20160916
                                    AddBOMLine2_BQ2(AsmHeader, TempAssemblyLine, true, BomComponent, false);

                                    lboolDryerLineInserted := true;
                                    //Always D4 Master Item or Not a Master Item
                                end;
                            end;
                        end;
                        //END;
                    end;
                    //Fazle05252016--<
                end;
            end;
        end else
            if NoOfLinesFound = 0 then
                exit; // MODIFY condition but no lines to modify

        // make pre-checks OR ask user to confirm
        if PreCheckAndConfirmUpdate(AsmHeader, OldAsmHeader, FieldNum, ReplaceLinesFromBOM, TempAssemblyLine,
             UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension)
        then
            exit;

        if not ReplaceLinesFromBOM then
            if TempAssemblyLine.Find('-') then
                repeat
                    TempCurrAsmLine := TempAssemblyLine;
                    TempCurrAsmLine.Insert;
                    TempAssemblyLine.SetSkipVerificationsThatChangeDatabase(true);
                    UpdateExistingLine_BQ2(AsmHeader, OldAsmHeader, CurrFieldNo, TempAssemblyLine,
                      UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension);//Fazle05312017
                until TempAssemblyLine.Next = 0;

        if not (FieldNum in [AsmHeader.FieldNo("Quantity to Assemble"), AsmHeader.FieldNo("Dimension Set ID")]) then
            if AssemblyLineMgt.ShowAvailability(false, TempAssemblyHeader, TempAssemblyLine) then
                ItemCheckAvail.RaiseUpdateInterruptedError;

        DoVerificationsSkippedEarlier(
          ReplaceLinesFromBOM, TempAssemblyLine, TempCurrAsmLine, UpdateDimension, AsmHeader."Dimension Set ID",
          OldAsmHeader."Dimension Set ID");

        AssemblyLine.Reset;
        if ReplaceLinesFromBOM then begin
            //rem smk2018.04.18 SLUPG: DeleteLines(AsmHeader);
            AsmHeader.DeleteAssemblyLines; //add smk2018.04.18 SLUPG
            TempAssemblyLine.Reset;
        end;

        if TempAssemblyLine.Find('-') then
            repeat
                if not ReplaceLinesFromBOM then
                    AssemblyLine.Get(TempAssemblyLine."Document Type", TempAssemblyLine."Document No.", TempAssemblyLine."Line No.");
                AssemblyLine := TempAssemblyLine;
                if ReplaceLinesFromBOM then
                    AssemblyLine.Insert(true)
                else
                    AssemblyLine.Modify(true);
                AsmHeader.AutoReserveAsmLine(AssemblyLine);
                if AssemblyLine."Due Date" < WorkDate then begin
                    DueDateBeforeWorkDate := true;
                    NewLineDueDate := AssemblyLine."Due Date";
                end;
            until TempAssemblyLine.Next = 0;

        if ReplaceLinesFromBOM or UpdateDueDate then
            if DueDateBeforeWorkDate then
                AssemblyLineMgt.ShowDueDateBeforeWorkDateMsg(NewLineDueDate);
    end;

    local procedure AddBOMLine2_BQ2(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean; BomComponent: Record "BOM Component"; ShowDueDateBeforeWorkDateMessage: Boolean)
    var
        DueDateBeforeWorkDateMsgShown: Boolean;
        SkipVerificationsThatChangeDatabase: Boolean;
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        lrecItem: Record Item;
    begin
        //FH20160929
        //BQ: Build Quantity - this calculation is based on Build Quantity
        //with AsmHeader do begin
        SkipVerificationsThatChangeDatabase := AsmLineRecordIsTemporary;
        AssemblyLine.SetSkipVerificationsThatChangeDatabase(SkipVerificationsThatChangeDatabase);
        AssemblyLine.Validate(Type, BomComponent.Type);
        AssemblyLine.Validate("No.", BomComponent."No.");
        if AssemblyLine.Type = AssemblyLine.Type::Resource then
            case BomComponent."Resource Usage Type" of
                BomComponent."Resource Usage Type"::Direct:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Direct);
                BomComponent."Resource Usage Type"::Fixed:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Fixed);
            end;
        AssemblyLine.Validate("Unit of Measure Code", BomComponent."Unit of Measure Code");
        //Fazle05252016-->
        //IF AssemblyLine.Type <> AssemblyLine.Type::" " THEN
        //  AssemblyLine.VALIDATE(
        //    "Quantity per",
        //    AssemblyLine.CalcQuantityFromBOM(
        //      BomComponent.Type,BomComponent."Quantity per",1,"Qty. per Unit of Measure",AssemblyLine."Resource Usage Type"));
        if BomComponent.Ink then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                if lrecIUoM.Get(BomComponent."Parent Item No.", 'KG') then begin
                    if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                        BomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity 2" / AsmHeader.Quantity) * BomComponent."Ink Percentage") / 100;
                    end;
                end;
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
            end;
        end
        else begin
            if AssemblyLine.Type <> AssemblyLine.Type::" " then
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        end;
        //Fazle05252016--<

        AssemblyLine.Validate(
          Quantity,
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        AssemblyLine.Validate(
          "Quantity to Consume",
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
            AssemblyLine."Resource Usage Type"));
        AssemblyLine.ValidateDueDate(AsmHeader, AsmHeader."Starting Date", ShowDueDateBeforeWorkDateMessage);
        DueDateBeforeWorkDateMsgShown := (AssemblyLine."Due Date" < WorkDate) and ShowDueDateBeforeWorkDateMessage;
        AssemblyLine.ValidateLeadTimeOffset(
          AsmHeader, BomComponent."Lead-Time Offset", not DueDateBeforeWorkDateMsgShown and ShowDueDateBeforeWorkDateMessage);
        AssemblyLine.Description := BomComponent.Description;
        AssemblyLine."Description 2" := AsmHeader."Description 2";
        if AssemblyLine.Type = AssemblyLine.Type::Item then
            AssemblyLine.Validate("Variant Code", BomComponent."Variant Code");
        AssemblyLine.Position := BomComponent.Position;
        AssemblyLine."Position 2" := BomComponent."Position 2";
        AssemblyLine."Position 3" := BomComponent."Position 3";
        if AsmHeader."Location Code" <> '' then
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        // nj20160511 - Start
        AssemblyLine."Instruction Code" := BomComponent."Instruction Code";
        AssemblyLine."Ink Percentage" := BomComponent."Ink Percentage";
        AssemblyLine.Ink := BomComponent.Ink;
        // nj20160511 - End
        AssemblyLine.Modify(true);
        //end;
    end;

    local procedure UpdateExistingLine_BQ2(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; CurrFieldNo: Integer; var AssemblyLine: Record "Assembly Line"; UpdateDueDate: Boolean; UpdateLocation: Boolean; UpdateQuantity: Boolean; UpdateUOM: Boolean; UpdateQtyToConsume: Boolean; UpdateDimension: Boolean)
    var
        QtyRatio: Decimal;
        QtyToConsume: Decimal;
        lrecBomComponent: Record "BOM Component";
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        ldecQuantityper: Decimal;
        lrecItem: Record Item;
    begin
        //FH20160929
        //with AsmHeader do begin
        if AsmHeader.IsStatusCheckSuspended then
            AssemblyLine.SuspendStatusCheck(true);

        if UpdateLocation then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        end;

        if UpdateDueDate then begin
            AssemblyLine.SetTestReservationDateConflict(CurrFieldNo <> 0);
            AssemblyLine.ValidateLeadTimeOffset(AsmHeader, AssemblyLine."Lead-Time Offset", false);
        end;

        if UpdateQuantity then begin
            QtyRatio := AsmHeader.Quantity / OldAsmHeader.Quantity;
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate(Quantity)
            else
                AssemblyLine.Validate(Quantity, AssemblyLine.Quantity * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateUOM then begin
            QtyRatio := AsmHeader."Qty. per Unit of Measure" / OldAsmHeader."Qty. per Unit of Measure";
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate("Quantity per")
            else
                AssemblyLine.Validate("Quantity per", AssemblyLine."Quantity per" * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateQtyToConsume then
            if not AssemblyLine.FixedUsage then begin
                AssemblyLine.InitQtyToConsume;
                QtyToConsume := AssemblyLine.Quantity * AsmHeader."Quantity to Assemble" / AsmHeader.Quantity;
                AsmHeader.RoundQty(QtyToConsume);
                if QtyToConsume <= AssemblyLine.MaxQtyToConsume then
                    AssemblyLine.Validate("Quantity to Consume", QtyToConsume);
            end;

        //Fazle05252016-->
        if UpdateQuantity then begin
            if not AssemblyLine.FixedUsage then begin
                if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                    lrecBomComponent.Reset;
                    lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                    lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                    lrecBomComponent.SetRange("No.", AssemblyLine."No.");
                    lrecBomComponent.SetRange(Ink, true);
                    if lrecBomComponent.FindFirst then begin
                        if lrecIUoM.Get(lrecBomComponent."Parent Item No.", 'KG') then begin
                            if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                lrecBomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity 2" / AsmHeader.Quantity) * lrecBomComponent."Ink Percentage") / 100;
                                AssemblyLine.Validate("Quantity per", lrecBomComponent."Quantity per");
                                //copied from AddBOMLine2()-->

                                AssemblyLine.Validate(
                                  Quantity,
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));

                                AssemblyLine.Validate(
                                  "Quantity to Consume",
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
                                    AssemblyLine."Resource Usage Type"));

                                //copied from AddBOMLine2()--<
                            end;
                        end;
                    end
                    //D4 D25 D26 Line Update
                    else begin
                        //IF AssemblyLine."No." IN ['D4','D25','D26'] THEN BEGIN
                        if AssemblyLine."No." = 'D4' then begin//Always D4 Master Item or Not a Master Item
                            ldecQuantityper := 0;
                            lrecBomComponent.Reset;
                            lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                            lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                            lrecBomComponent.SetRange(Ink, true);
                            if lrecBomComponent.FindSet then begin
                                repeat
                                    if lrecItem.Get(lrecBomComponent."No.") then begin
                                        if lrecIUoM.Get(lrecBomComponent."Parent Item No.", 'KG') then begin
                                            if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                                //ldecQuantityper+=((lrecItem."Dryer (%)"/100)*(lrecBomComponent."Ink Percentage"/100)*(lrecBuildQuantity."Build Quantity"))/AsmHeader.Quantity;
                                                ldecQuantityper += (lrecItem."Dryer (%)" / 100) * (lrecBomComponent."Ink Percentage" / 100) * (lrecIUoM."1 per Qty. per Unit of Measure");//Fazle06102016
                                            end;
                                        end;
                                    end;
                                until lrecBomComponent.Next = 0;
                                ldecQuantityper := ldecQuantityper * 1.5;//FH20160929
                                AssemblyLine.Validate("Quantity per", ldecQuantityper);
                                AssemblyLine.Validate(
                                  Quantity,
                                  AssemblyLine.CalcBOMQuantity(
                                    AssemblyLine.Type, ldecQuantityper, AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));

                                AssemblyLine.Validate(
                                  "Quantity to Consume",
                                  AssemblyLine.CalcBOMQuantity(
                                    AssemblyLine.Type, ldecQuantityper, AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
                            end;
                        end;
                    end;
                end;
            end;
        end;
        //Fazle05252016--<


        if UpdateDimension then
            AssemblyLine.UpdateDim(AsmHeader."Dimension Set ID", OldAsmHeader."Dimension Set ID");

        AssemblyLine.Modify(true);
        //end;
    end;

    local procedure InsertAsmLine_D33(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean)
    var
        lrecAssemblyLine: Record "Assembly Line";
        lintLineNo: Integer;
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //with AsmHeader do begin
        AssemblyLine.Init;
        AssemblyLine."Document Type" := AsmHeader."Document Type";
        AssemblyLine."Document No." := AsmHeader."No.";
        AssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(AssemblyLine, AsmLineRecordIsTemporary);

        //New for D4 Line--> FH20160916
        lintLineNo := 0;
        AssemblyLine.Reset;
        AssemblyLine.SetRange("Document Type", AsmHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AsmHeader."No.");
        //FH20160929-->
        //AssemblyLine.SETFILTER(Description,'*D4*');
        lrecAssemblySetup.Get();
        if AsmHeader.CalcBasedOnBuildQty(AsmHeader) then
            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code")
        else
            if AsmHeader.CalcBasedOnBuildQty2(AsmHeader) then
                AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 2");
        //FH20160929--<
        if AssemblyLine.FindFirst then begin
            lintLineNo := AssemblyLine."Line No." - 5;
        end;
        if lintLineNo > 0 then
            //New--<
            AssemblyLine."Line No." := lintLineNo;
        AssemblyLine.Insert(true);
        //end;
    end;

    //[Scope('Internal')]
    procedure UpdateAssemblyLines_BQ_OK32LT(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; FieldNum: Integer; ReplaceLinesFromBOM: Boolean; CurrFieldNo: Integer; CurrentFieldNum: Integer)
    var
        AssemblyLine: Record "Assembly Line";
        TempAssemblyHeader: Record "Assembly Header" temporary;
        TempAssemblyLine: Record "Assembly Line" temporary;
        BomComponent: Record "BOM Component";
        TempCurrAsmLine: Record "Assembly Line" temporary;
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        NoOfLinesFound: Integer;
        UpdateDueDate: Boolean;
        UpdateLocation: Boolean;
        UpdateQuantity: Boolean;
        UpdateUOM: Boolean;
        UpdateQtyToConsume: Boolean;
        UpdateDimension: Boolean;
        DueDateBeforeWorkDate: Boolean;
        NewLineDueDate: Date;
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
        lrecBOMInstruction: Record "BOM Instruction";
        lboolDryerLineInserted: Boolean;
        lrecItem1: Record Item;
        lrecBuildQuantity: Record "Build Quantity";
        lrecBomComponent: Record "BOM Component";
    //xltmprecItem: Record Item temporary;
    begin
        //FH20161028

        if (FieldNum <> CurrentFieldNum) or // Update has been called from OnValidate of another field than was originally intended.
           ((not (FieldNum in [AsmHeader.FieldNo("Item No."),
                               AsmHeader.FieldNo("Variant Code"),
                               AsmHeader.FieldNo("Location Code"),
                               AsmHeader.FieldNo("Starting Date"),
                               AsmHeader.FieldNo(Quantity),
                               AsmHeader.FieldNo("Unit of Measure Code"),
                               AsmHeader.FieldNo("Quantity to Assemble"),
                               AsmHeader.FieldNo("Dimension Set ID")])) and (not ReplaceLinesFromBOM))
        then
            exit;
        Clear(lboolDryerLineInserted);//Fazle05252016
        NoOfLinesFound := AssemblyLineMgt.CopyAssemblyData(AsmHeader, TempAssemblyHeader, TempAssemblyLine);
        if ReplaceLinesFromBOM then begin
            TempAssemblyLine.DeleteAll;
            if not ((AsmHeader."Quantity (Base)" = 0) or (AsmHeader."Item No." = '')) then begin  // condition to replace asm lines
                //SetLinkToBOM(AsmHeader, BomComponent);
                BOMComponent.SETRANGE("Parent Item No.", AsmHeader."Item No.");

                if BomComponent.FindSet then begin
                    repeat
                        //InsertAsmLine(AsmHeader, TempAssemblyLine, true);
                        TempAssemblyLine.INIT;
                        TempAssemblyLine."Document Type" := AsmHeader."Document Type";
                        TempAssemblyLine."Document No." := AsmHeader."No.";
                        TempAssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(TempAssemblyLine, true);
                        TempAssemblyLine.INSERT(TRUE);

                        AddBOMLine2_BQ_OK32LT(AsmHeader, TempAssemblyLine, true, BomComponent, false);
                    until BomComponent.Next <= 0;
                    BomComponent.FindLast;
                    if not lboolDryerLineInserted then begin
                        lrecBomComponent.Reset;
                        lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                        lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                        lrecBomComponent.SetRange(Ink, true);
                        if not lrecBomComponent.IsEmpty then begin
                            if (lrecItemUOM.Get(BomComponent."Parent Item No.", 'KG')) and (lrecItemUOM."1 per Qty. per Unit of Measure" > 0) then begin
                                if lrecBuildQuantity.Get(lrecItemUOM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                    BomComponent."Quantity per" := 0;
                                    BomComponent.Type := BomComponent.Type::Item;
                                    lrecItem1.Get('S50');
                                    BomComponent."No." := 'S50';
                                    BomComponent."Unit of Measure Code" := lrecItem1."Base Unit of Measure";
                                    BomComponent.Ink := false;
                                    BomComponent."Quantity per" := (lrecItemUOM."1 per Qty. per Unit of Measure" / 100) * 3;
                                    InsertAsmLine_OK32LT_S50(AsmHeader, TempAssemblyLine, true);
                                    AddBOMLine2_BQ_OK32LT(AsmHeader, TempAssemblyLine, true, BomComponent, false);

                                    //D4 line
                                    BomComponent.Type := BomComponent.Type::Item;
                                    lrecItem1.Get('D4');
                                    BomComponent."No." := 'D4';
                                    BomComponent."Unit of Measure Code" := lrecItem1."Base Unit of Measure";
                                    BomComponent.Ink := false;
                                    BomComponent."Quantity per" := 0;
                                    if lrecBomComponent.FindSet then begin
                                        repeat
                                            if lrecItem.Get(lrecBomComponent."No.") then begin
                                                BomComponent."Quantity per" += (lrecItem."Dryer (%)" / 100) * (lrecBomComponent."Ink Percentage" / 100) * (lrecItemUOM."1 per Qty. per Unit of Measure");
                                            end;
                                        until lrecBomComponent.Next = 0;
                                        //BomComponent."Quantity per":=BomComponent."Quantity per"*1.5;
                                    end;
                                    InsertAsmLine_D4(AsmHeader, TempAssemblyLine, true);
                                    AddBOMLine2_BQ_OK32LT(AsmHeader, TempAssemblyLine, true, BomComponent, false);

                                    lboolDryerLineInserted := true;
                                end;
                            end;
                        end;
                    end;
                    //Fazle05252016--<
                end;
            end;
        end else
            if NoOfLinesFound = 0 then
                exit; // MODIFY condition but no lines to modify

        // make pre-checks OR ask user to confirm
        if PreCheckAndConfirmUpdate(AsmHeader, OldAsmHeader, FieldNum, ReplaceLinesFromBOM, TempAssemblyLine,
             UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension)
        then
            exit;

        if not ReplaceLinesFromBOM then
            if TempAssemblyLine.Find('-') then
                repeat
                    TempCurrAsmLine := TempAssemblyLine;
                    TempCurrAsmLine.Insert;
                    TempAssemblyLine.SetSkipVerificationsThatChangeDatabase(true);
                    UpdateExistingLine_BQ_OK32LT(AsmHeader, OldAsmHeader, CurrFieldNo, TempAssemblyLine,
                      UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension);//Fazle05312017
                until TempAssemblyLine.Next = 0;

        if not (FieldNum in [AsmHeader.FieldNo("Quantity to Assemble"), AsmHeader.FieldNo("Dimension Set ID")]) then
            if AssemblyLineMgt.ShowAvailability(false, TempAssemblyHeader, TempAssemblyLine) then
                ItemCheckAvail.RaiseUpdateInterruptedError;

        DoVerificationsSkippedEarlier(
          ReplaceLinesFromBOM, TempAssemblyLine, TempCurrAsmLine, UpdateDimension, AsmHeader."Dimension Set ID",
          OldAsmHeader."Dimension Set ID");

        AssemblyLine.Reset;
        if ReplaceLinesFromBOM then begin
            //rem smk2018.04.18 SLUPG: DeleteLines(AsmHeader);
            AsmHeader.DeleteAssemblyLines; //add smk2018.04.18 SLUPG
            TempAssemblyLine.Reset;
        end;

        if TempAssemblyLine.Find('-') then
            repeat
                if not ReplaceLinesFromBOM then
                    AssemblyLine.Get(TempAssemblyLine."Document Type", TempAssemblyLine."Document No.", TempAssemblyLine."Line No.");
                AssemblyLine := TempAssemblyLine;
                if ReplaceLinesFromBOM then
                    AssemblyLine.Insert(true)
                else
                    AssemblyLine.Modify(true);
                AsmHeader.AutoReserveAsmLine(AssemblyLine);
                if AssemblyLine."Due Date" < WorkDate then begin
                    DueDateBeforeWorkDate := true;
                    NewLineDueDate := AssemblyLine."Due Date";
                end;
            until TempAssemblyLine.Next = 0;

        if ReplaceLinesFromBOM or UpdateDueDate then
            if DueDateBeforeWorkDate then
                AssemblyLineMgt.ShowDueDateBeforeWorkDateMsg(NewLineDueDate);
    end;

    local procedure AddBOMLine2_BQ_OK32LT(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean; BomComponent: Record "BOM Component"; ShowDueDateBeforeWorkDateMessage: Boolean)
    var
        DueDateBeforeWorkDateMsgShown: Boolean;
        SkipVerificationsThatChangeDatabase: Boolean;
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        lrecItem: Record Item;
    begin
        //FH20161028
        //BQ: Build Quantity - this calculation is based on Build Quantity
        //with AsmHeader do begin
        SkipVerificationsThatChangeDatabase := AsmLineRecordIsTemporary;
        AssemblyLine.SetSkipVerificationsThatChangeDatabase(SkipVerificationsThatChangeDatabase);
        AssemblyLine.Validate(Type, BomComponent.Type);
        AssemblyLine.Validate("No.", BomComponent."No.");
        if AssemblyLine.Type = AssemblyLine.Type::Resource then
            case BomComponent."Resource Usage Type" of
                BomComponent."Resource Usage Type"::Direct:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Direct);
                BomComponent."Resource Usage Type"::Fixed:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Fixed);
            end;
        AssemblyLine.Validate("Unit of Measure Code", BomComponent."Unit of Measure Code");
        if BomComponent.Ink then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                if lrecIUoM.Get(BomComponent."Parent Item No.", 'KG') then begin
                    if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                        //BomComponent."Quantity per":=((lrecBuildQuantity."Build Quantity 2"/AsmHeader.Quantity) * BomComponent."Ink Percentage") / 100;
                        BomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity OK32LT" / AsmHeader.Quantity) * BomComponent."Ink Percentage") / 100;
                    end;
                end;
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
            end;
        end
        else begin
            if AssemblyLine.Type <> AssemblyLine.Type::" " then
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        end;

        AssemblyLine.Validate(
          Quantity,
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        AssemblyLine.Validate(
          "Quantity to Consume",
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
            AssemblyLine."Resource Usage Type"));
        AssemblyLine.ValidateDueDate(AsmHeader, AsmHeader."Starting Date", ShowDueDateBeforeWorkDateMessage);
        DueDateBeforeWorkDateMsgShown := (AssemblyLine."Due Date" < WorkDate) and ShowDueDateBeforeWorkDateMessage;
        AssemblyLine.ValidateLeadTimeOffset(
          AsmHeader, BomComponent."Lead-Time Offset", not DueDateBeforeWorkDateMsgShown and ShowDueDateBeforeWorkDateMessage);
        AssemblyLine.Description := BomComponent.Description;
        AssemblyLine."Description 2" := AsmHeader."Description 2";
        if AssemblyLine.Type = AssemblyLine.Type::Item then
            AssemblyLine.Validate("Variant Code", BomComponent."Variant Code");
        AssemblyLine.Position := BomComponent.Position;
        AssemblyLine."Position 2" := BomComponent."Position 2";
        AssemblyLine."Position 3" := BomComponent."Position 3";
        if AsmHeader."Location Code" <> '' then
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        // nj20160511 - Start
        AssemblyLine."Instruction Code" := BomComponent."Instruction Code";
        AssemblyLine."Ink Percentage" := BomComponent."Ink Percentage";
        AssemblyLine.Ink := BomComponent.Ink;
        // nj20160511 - End
        AssemblyLine.Modify(true);
        //end;
    end;

    local procedure UpdateExistingLine_BQ_OK32LT(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; CurrFieldNo: Integer; var AssemblyLine: Record "Assembly Line"; UpdateDueDate: Boolean; UpdateLocation: Boolean; UpdateQuantity: Boolean; UpdateUOM: Boolean; UpdateQtyToConsume: Boolean; UpdateDimension: Boolean)
    var
        QtyRatio: Decimal;
        QtyToConsume: Decimal;
        lrecBomComponent: Record "BOM Component";
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        ldecQuantityper: Decimal;
        lrecItem: Record Item;
    begin
        //FH20161028
        //with AsmHeader do begin
        if AsmHeader.IsStatusCheckSuspended then
            AssemblyLine.SuspendStatusCheck(true);

        if UpdateLocation then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        end;

        if UpdateDueDate then begin
            AssemblyLine.SetTestReservationDateConflict(CurrFieldNo <> 0);
            AssemblyLine.ValidateLeadTimeOffset(AsmHeader, AssemblyLine."Lead-Time Offset", false);
        end;

        if UpdateQuantity then begin
            QtyRatio := AsmHeader.Quantity / OldAsmHeader.Quantity;
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate(Quantity)
            else
                AssemblyLine.Validate(Quantity, AssemblyLine.Quantity * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateUOM then begin
            QtyRatio := AsmHeader."Qty. per Unit of Measure" / OldAsmHeader."Qty. per Unit of Measure";
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate("Quantity per")
            else
                AssemblyLine.Validate("Quantity per", AssemblyLine."Quantity per" * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateQtyToConsume then
            if not AssemblyLine.FixedUsage then begin
                AssemblyLine.InitQtyToConsume;
                QtyToConsume := AssemblyLine.Quantity * AsmHeader."Quantity to Assemble" / AsmHeader.Quantity;
                AsmHeader.RoundQty(QtyToConsume);
                if QtyToConsume <= AssemblyLine.MaxQtyToConsume then
                    AssemblyLine.Validate("Quantity to Consume", QtyToConsume);
            end;

        //Fazle05252016-->
        if UpdateQuantity then begin
            if not AssemblyLine.FixedUsage then begin
                if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                    lrecBomComponent.Reset;
                    lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                    lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                    lrecBomComponent.SetRange("No.", AssemblyLine."No.");
                    lrecBomComponent.SetRange(Ink, true);
                    if lrecBomComponent.FindFirst then begin
                        if lrecIUoM.Get(lrecBomComponent."Parent Item No.", 'KG') then begin
                            if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                //lrecBomComponent."Quantity per":=((lrecBuildQuantity."Build Quantity 2"/AsmHeader.Quantity) * lrecBomComponent."Ink Percentage") / 100;
                                lrecBomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity OK32LT" / AsmHeader.Quantity) * lrecBomComponent."Ink Percentage") / 100;
                                AssemblyLine.Validate("Quantity per", lrecBomComponent."Quantity per");
                                //copied from AddBOMLine2()-->

                                AssemblyLine.Validate(
                                  Quantity,
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));

                                AssemblyLine.Validate(
                                  "Quantity to Consume",
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
                                    AssemblyLine."Resource Usage Type"));

                                //copied from AddBOMLine2()--<
                            end;
                        end;
                    end
                    //D4 D25 D26 Line Update
                    else begin
                        if AssemblyLine."No." = 'D4' then begin
                            ldecQuantityper := 0;
                            lrecBomComponent.Reset;
                            lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                            lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                            lrecBomComponent.SetRange(Ink, true);
                            if lrecBomComponent.FindSet then begin
                                repeat
                                    if lrecItem.Get(lrecBomComponent."No.") then begin
                                        if lrecIUoM.Get(lrecBomComponent."Parent Item No.", 'KG') then begin
                                            if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                                ldecQuantityper += (lrecItem."Dryer (%)" / 100) * (lrecBomComponent."Ink Percentage" / 100) * (lrecIUoM."1 per Qty. per Unit of Measure");
                                            end;
                                        end;
                                    end;
                                until lrecBomComponent.Next = 0;
                                //ldecQuantityper:=ldecQuantityper*1.5;//FH20160929
                                AssemblyLine.Validate("Quantity per", ldecQuantityper);
                                AssemblyLine.Validate(
                                  Quantity,
                                  AssemblyLine.CalcBOMQuantity(
                                    AssemblyLine.Type, ldecQuantityper, AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));

                                AssemblyLine.Validate(
                                  "Quantity to Consume",
                                  AssemblyLine.CalcBOMQuantity(
                                    AssemblyLine.Type, ldecQuantityper, AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
                            end;
                        end;
                    end;
                end;
            end;
        end;
        //Fazle05252016--<


        if UpdateDimension then
            AssemblyLine.UpdateDim(AsmHeader."Dimension Set ID", OldAsmHeader."Dimension Set ID");

        AssemblyLine.Modify(true);
        //end;
    end;

    local procedure InsertAsmLine_OK32LT_S50(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean)
    var
        lrecAssemblyLine: Record "Assembly Line";
        lintLineNo: Integer;
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //FH20161028
        //with AsmHeader do begin
        AssemblyLine.Init;
        AssemblyLine."Document Type" := AsmHeader."Document Type";
        AssemblyLine."Document No." := AsmHeader."No.";
        AssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(AssemblyLine, AsmLineRecordIsTemporary);

        //New for D4 Line--> FH20160916
        lintLineNo := 0;
        AssemblyLine.Reset;
        AssemblyLine.SetRange("Document Type", AsmHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AsmHeader."No.");
        //FH20160929-->
        //AssemblyLine.SETFILTER(Description,'*D4*');
        lrecAssemblySetup.Get();
        if AsmHeader.CalcBasedOnBuildQty(AsmHeader) then
            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code")
        else
            if AsmHeader.CalcBasedOnBuildQty2(AsmHeader) then
                AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 2")
            else
                if AsmHeader.CalcBasedOnBuildQty_OK32LT(AsmHeader) then
                    AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 3")
                //ID2173 - Start
                else
                    if AsmHeader.CalcBasedOnBuildQty_OK32UV(AsmHeader) then
                        AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 4")
                    else
                        if AsmHeader.CalcBasedOnBuildQty_OK32LED(AsmHeader) then
                            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 5");
        //ID2173 - End

        //FH20160929--<
        if AssemblyLine.FindFirst then begin
            lintLineNo := AssemblyLine."Line No." - 5;
        end;
        if lintLineNo > 0 then
            //New--<
            AssemblyLine."Line No." := lintLineNo;
        AssemblyLine.Insert(true);
        //end;
    end;

    local procedure AddBOMLine2_OK32UV(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean; BomComponent: Record "BOM Component"; ShowDueDateBeforeWorkDateMessage: Boolean)
    var
        DueDateBeforeWorkDateMsgShown: Boolean;
        SkipVerificationsThatChangeDatabase: Boolean;
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        lrecItem: Record Item;
    begin
        //ID2173 - Start
        //BQ: Build Quantity - this calculation is based on Build Quantity
        //with AsmHeader do begin
        SkipVerificationsThatChangeDatabase := AsmLineRecordIsTemporary;
        AssemblyLine.SetSkipVerificationsThatChangeDatabase(SkipVerificationsThatChangeDatabase);
        AssemblyLine.Validate(Type, BomComponent.Type);
        AssemblyLine.Validate("No.", BomComponent."No.");
        if AssemblyLine.Type = AssemblyLine.Type::Resource then
            case BomComponent."Resource Usage Type" of
                BomComponent."Resource Usage Type"::Direct:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Direct);
                BomComponent."Resource Usage Type"::Fixed:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Fixed);
            end;
        AssemblyLine.Validate("Unit of Measure Code", BomComponent."Unit of Measure Code");
        if BomComponent.Ink then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                if lrecIUoM.Get(BomComponent."Parent Item No.", 'KG') then begin
                    if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                        //BomComponent."Quantity per":=((lrecBuildQuantity."Build Quantity OK32UV"/AsmHeader.Quantity) * BomComponent."Ink Percentage") / 100;
                        BomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity OK32UV" / AsmHeader.Quantity) * BomComponent."Ink Percentage") / 100;
                    end;
                end;
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
            end;
        end
        else begin
            if AssemblyLine.Type <> AssemblyLine.Type::" " then
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        end;

        AssemblyLine.Validate(
          Quantity,
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        AssemblyLine.Validate(
          "Quantity to Consume",
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
            AssemblyLine."Resource Usage Type"));
        AssemblyLine.ValidateDueDate(AsmHeader, AsmHeader."Starting Date", ShowDueDateBeforeWorkDateMessage);
        DueDateBeforeWorkDateMsgShown := (AssemblyLine."Due Date" < WorkDate) and ShowDueDateBeforeWorkDateMessage;
        AssemblyLine.ValidateLeadTimeOffset(
          AsmHeader, BomComponent."Lead-Time Offset", not DueDateBeforeWorkDateMsgShown and ShowDueDateBeforeWorkDateMessage);
        AssemblyLine.Description := BomComponent.Description;
        AssemblyLine."Description 2" := AsmHeader."Description 2";
        if AssemblyLine.Type = AssemblyLine.Type::Item then
            AssemblyLine.Validate("Variant Code", BomComponent."Variant Code");
        AssemblyLine.Position := BomComponent.Position;
        AssemblyLine."Position 2" := BomComponent."Position 2";
        AssemblyLine."Position 3" := BomComponent."Position 3";
        if AsmHeader."Location Code" <> '' then
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        //
        AssemblyLine."Instruction Code" := BomComponent."Instruction Code";
        AssemblyLine."Ink Percentage" := BomComponent."Ink Percentage";
        AssemblyLine.Ink := BomComponent.Ink;
        //
        AssemblyLine.Modify(true);
        //end;
        //ID2173 - End
    end;

    //[Scope('Internal')]
    procedure UpdateAssemblyLines_OK32UV(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; FieldNum: Integer; ReplaceLinesFromBOM: Boolean; CurrFieldNo: Integer; CurrentFieldNum: Integer)
    var
        AssemblyLine: Record "Assembly Line";
        TempAssemblyHeader: Record "Assembly Header" temporary;
        TempAssemblyLine: Record "Assembly Line" temporary;
        BomComponent: Record "BOM Component";
        TempCurrAsmLine: Record "Assembly Line" temporary;
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        NoOfLinesFound: Integer;
        UpdateDueDate: Boolean;
        UpdateLocation: Boolean;
        UpdateQuantity: Boolean;
        UpdateUOM: Boolean;
        UpdateQtyToConsume: Boolean;
        UpdateDimension: Boolean;
        DueDateBeforeWorkDate: Boolean;
        NewLineDueDate: Date;
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
        lrecBOMInstruction: Record "BOM Instruction";
        lboolDryerLineInserted: Boolean;
        lrecItem1: Record Item;
        lrecBuildQuantity: Record "Build Quantity";
        lrecBomComponent: Record "BOM Component";
    //xltmprecItem: Record Item temporary;
    begin
        //ID2173 - Start
        if (FieldNum <> CurrentFieldNum) or // Update has been called from OnValidate of another field than was originally intended.
           ((not (FieldNum in [AsmHeader.FieldNo("Item No."),
                               AsmHeader.FieldNo("Variant Code"),
                               AsmHeader.FieldNo("Location Code"),
                               AsmHeader.FieldNo("Starting Date"),
                               AsmHeader.FieldNo(Quantity),
                               AsmHeader.FieldNo("Unit of Measure Code"),
                               AsmHeader.FieldNo("Quantity to Assemble"),
                               AsmHeader.FieldNo("Dimension Set ID")])) and (not ReplaceLinesFromBOM))
        then
            exit;
        Clear(lboolDryerLineInserted);
        NoOfLinesFound := AssemblyLineMgt.CopyAssemblyData(AsmHeader, TempAssemblyHeader, TempAssemblyLine);
        if ReplaceLinesFromBOM then begin
            TempAssemblyLine.DeleteAll;
            if not ((AsmHeader."Quantity (Base)" = 0) or (AsmHeader."Item No." = '')) then begin  // condition to replace asm lines
                //SetLinkToBOM(AsmHeader, BomComponent);
                BOMComponent.SETRANGE("Parent Item No.", AsmHeader."Item No.");

                if BomComponent.FindSet then begin
                    repeat
                        //InsertAsmLine(AsmHeader, TempAssemblyLine, true);
                        TempAssemblyLine.INIT;
                        TempAssemblyLine."Document Type" := AsmHeader."Document Type";
                        TempAssemblyLine."Document No." := AsmHeader."No.";
                        TempAssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(TempAssemblyLine, true);
                        TempAssemblyLine.INSERT(TRUE);

                        AddBOMLine2_OK32UV(AsmHeader, TempAssemblyLine, true, BomComponent, false);
                    until BomComponent.Next <= 0;
                    BomComponent.FindLast;
                    if not lboolDryerLineInserted then begin
                        lrecBomComponent.Reset;
                        lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                        lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                        lrecBomComponent.SetRange(Ink, true);
                        if not lrecBomComponent.IsEmpty then begin
                            if (lrecItemUOM.Get(BomComponent."Parent Item No.", 'KG')) and (lrecItemUOM."1 per Qty. per Unit of Measure" > 0) then begin
                                if lrecBuildQuantity.Get(lrecItemUOM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                    BomComponent."Quantity per" := 0;
                                    BomComponent.Type := BomComponent.Type::Item;
                                    lrecItem1.Get('S407');
                                    BomComponent."No." := 'S407';
                                    BomComponent."Unit of Measure Code" := lrecItem1."Base Unit of Measure";
                                    BomComponent.Ink := false;
                                    if lrecBomComponent.FindSet then
                                        repeat
                                            if lrecItem.Get(lrecBomComponent."No.") then
                                                BomComponent."Quantity per" := (lrecItemUOM."1 per Qty. per Unit of Measure" / 100) * 3;
                                        until lrecBomComponent.Next = 0;
                                    InsertAsmLine_OK32UV(AsmHeader, TempAssemblyLine, true);
                                    AddBOMLine2_OK32UV(AsmHeader, TempAssemblyLine, true, BomComponent, false);
                                    /*
                                    //D4 line
                                    BomComponent.Type:=BomComponent.Type::Item;
                                    lrecItem1.GET('D4');
                                    BomComponent."No.":='D4';
                                    BomComponent."Unit of Measure Code":=lrecItem1."Base Unit of Measure";
                                    BomComponent.Ink:=FALSE;
                                    BomComponent."Quantity per":=0;
                                    IF lrecBomComponent.FINDSET THEN BEGIN
                                      REPEAT
                                        IF lrecItem.GET(lrecBomComponent."No.") THEN BEGIN
                                          BomComponent."Quantity per"+=(lrecItem."Dryer (%)"/100)*(lrecBomComponent."Ink Percentage"/100)*(lrecItemUOM."1 per Qty. per Unit of Measure");
                                        END;
                                      UNTIL lrecBomComponent.NEXT=0;
                                      //BomComponent."Quantity per":=BomComponent."Quantity per"*1.5;
                                    END;
                                    InsertAsmLine_D4(AsmHeader,TempAssemblyLine,TRUE);
                                    AddBOMLine2_OK32UV(AsmHeader,TempAssemblyLine,TRUE,BomComponent,FALSE);
                                    */
                                    lboolDryerLineInserted := true;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end else
            if NoOfLinesFound = 0 then
                exit; // MODIFY condition but no lines to modify

        // make pre-checks OR ask user to confirm
        if PreCheckAndConfirmUpdate(AsmHeader, OldAsmHeader, FieldNum, ReplaceLinesFromBOM, TempAssemblyLine,
             UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension)
        then
            exit;

        if not ReplaceLinesFromBOM then
            if TempAssemblyLine.Find('-') then
                repeat
                    TempCurrAsmLine := TempAssemblyLine;
                    TempCurrAsmLine.Insert;
                    TempAssemblyLine.SetSkipVerificationsThatChangeDatabase(true);
                    UpdateExistingLine_OK32UV(AsmHeader, OldAsmHeader, CurrFieldNo, TempAssemblyLine,
                      UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension);
                until TempAssemblyLine.Next = 0;

        if not (FieldNum in [AsmHeader.FieldNo("Quantity to Assemble"), AsmHeader.FieldNo("Dimension Set ID")]) then
            if AssemblyLineMgt.ShowAvailability(false, TempAssemblyHeader, TempAssemblyLine) then
                ItemCheckAvail.RaiseUpdateInterruptedError;

        DoVerificationsSkippedEarlier(
          ReplaceLinesFromBOM, TempAssemblyLine, TempCurrAsmLine, UpdateDimension, AsmHeader."Dimension Set ID",
          OldAsmHeader."Dimension Set ID");

        AssemblyLine.Reset;
        if ReplaceLinesFromBOM then begin
            //rem smk2018.04.18 SLUPG: DeleteLines(AsmHeader);
            AsmHeader.DeleteAssemblyLines; //add smk2018.04.18 SLUPG
            TempAssemblyLine.Reset;
        end;

        if TempAssemblyLine.Find('-') then
            repeat
                if not ReplaceLinesFromBOM then
                    AssemblyLine.Get(TempAssemblyLine."Document Type", TempAssemblyLine."Document No.", TempAssemblyLine."Line No.");
                AssemblyLine := TempAssemblyLine;
                if ReplaceLinesFromBOM then
                    AssemblyLine.Insert(true)
                else
                    AssemblyLine.Modify(true);
                AsmHeader.AutoReserveAsmLine(AssemblyLine);
                if AssemblyLine."Due Date" < WorkDate then begin
                    DueDateBeforeWorkDate := true;
                    NewLineDueDate := AssemblyLine."Due Date";
                end;
            until TempAssemblyLine.Next = 0;

        if ReplaceLinesFromBOM or UpdateDueDate then
            if DueDateBeforeWorkDate then
                AssemblyLineMgt.ShowDueDateBeforeWorkDateMsg(NewLineDueDate);

    end;

    local procedure UpdateExistingLine_OK32UV(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; CurrFieldNo: Integer; var AssemblyLine: Record "Assembly Line"; UpdateDueDate: Boolean; UpdateLocation: Boolean; UpdateQuantity: Boolean; UpdateUOM: Boolean; UpdateQtyToConsume: Boolean; UpdateDimension: Boolean)
    var
        QtyRatio: Decimal;
        QtyToConsume: Decimal;
        lrecBomComponent: Record "BOM Component";
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        ldecQuantityper: Decimal;
        lrecItem: Record Item;
    begin
        //ID2173 - Start
        //with AsmHeader do begin
        if AsmHeader.IsStatusCheckSuspended then
            AssemblyLine.SuspendStatusCheck(true);

        if UpdateLocation then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        end;

        if UpdateDueDate then begin
            AssemblyLine.SetTestReservationDateConflict(CurrFieldNo <> 0);
            AssemblyLine.ValidateLeadTimeOffset(AsmHeader, AssemblyLine."Lead-Time Offset", false);
        end;

        if UpdateQuantity then begin
            QtyRatio := AsmHeader.Quantity / OldAsmHeader.Quantity;
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate(Quantity)
            else
                AssemblyLine.Validate(Quantity, AssemblyLine.Quantity * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateUOM then begin
            QtyRatio := AsmHeader."Qty. per Unit of Measure" / OldAsmHeader."Qty. per Unit of Measure";
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate("Quantity per")
            else
                AssemblyLine.Validate("Quantity per", AssemblyLine."Quantity per" * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateQtyToConsume then
            if not AssemblyLine.FixedUsage then begin
                AssemblyLine.InitQtyToConsume;
                QtyToConsume := AssemblyLine.Quantity * AsmHeader."Quantity to Assemble" / AsmHeader.Quantity;
                AsmHeader.RoundQty(QtyToConsume);
                if QtyToConsume <= AssemblyLine.MaxQtyToConsume then
                    AssemblyLine.Validate("Quantity to Consume", QtyToConsume);
            end;

        if UpdateQuantity then begin
            if not AssemblyLine.FixedUsage then begin
                if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                    lrecBomComponent.Reset;
                    lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                    lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                    lrecBomComponent.SetRange("No.", AssemblyLine."No.");
                    lrecBomComponent.SetRange(Ink, true);
                    if lrecBomComponent.FindFirst then begin
                        if lrecIUoM.Get(lrecBomComponent."Parent Item No.", 'KG') then begin
                            if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                lrecBomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity OK32UV" / AsmHeader.Quantity) * lrecBomComponent."Ink Percentage") / 100;
                                AssemblyLine.Validate("Quantity per", lrecBomComponent."Quantity per");

                                AssemblyLine.Validate(
                                  Quantity,
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));

                                AssemblyLine.Validate(
                                  "Quantity to Consume",
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
                                    AssemblyLine."Resource Usage Type"));

                            end;
                        end;
                        /*
                        END
                        //D4 D25 D26 Line Update
                        ELSE BEGIN
                          IF AssemblyLine."No." ='D4' THEN BEGIN
                            ldecQuantityper:=0;
                            lrecBomComponent.RESET;
                            lrecBomComponent.SETRANGE("Parent Item No.","Item No.");
                            lrecBomComponent.SETRANGE(Type,lrecBomComponent.Type::Item);
                            lrecBomComponent.SETRANGE(Ink,TRUE);
                            IF lrecBomComponent.FINDSET THEN BEGIN
                              REPEAT
                                IF lrecItem.GET(lrecBomComponent."No.") THEN BEGIN
                                  IF lrecIUoM.GET(lrecBomComponent."Parent Item No.",'KG') THEN BEGIN
                                    IF lrecBuildQuantity.GET(lrecIUoM."1 per Qty. per Unit of Measure",AsmHeader.Quantity) THEN BEGIN
                                      ldecQuantityper+=(lrecItem."Dryer (%)"/100)*(lrecBomComponent."Ink Percentage"/100)*(lrecIUoM."1 per Qty. per Unit of Measure");
                                    END;
                                  END;
                                END;
                              UNTIL lrecBomComponent.NEXT=0;
                              //ldecQuantityper:=ldecQuantityper*1.5;//FH20160929
                              AssemblyLine.VALIDATE("Quantity per",ldecQuantityper);
                              AssemblyLine.VALIDATE(
                                Quantity,
                                AssemblyLine.CalcQuantityFromBOM(
                                  AssemblyLine.Type,ldecQuantityper,Quantity,"Qty. per Unit of Measure",AssemblyLine."Resource Usage Type"));

                              AssemblyLine.VALIDATE(
                                "Quantity to Consume",
                                AssemblyLine.CalcQuantityFromBOM(
                                  AssemblyLine.Type,ldecQuantityper,"Quantity to Assemble","Qty. per Unit of Measure",AssemblyLine."Resource Usage Type"));
                            END;
                          END;
                          */
                    end;
                end;
            end;
        end;

        if UpdateDimension then
            AssemblyLine.UpdateDim(AsmHeader."Dimension Set ID", OldAsmHeader."Dimension Set ID");

        AssemblyLine.Modify(true);
        //end;
        //ID2173 - End
    end;

    local procedure InsertAsmLine_OK32UV(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean)
    var
        lrecAssemblyLine: Record "Assembly Line";
        lintLineNo: Integer;
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //ID2173 - Start
        //with AsmHeader do begin
        AssemblyLine.Init;
        AssemblyLine."Document Type" := AsmHeader."Document Type";
        AssemblyLine."Document No." := AsmHeader."No.";
        AssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(AssemblyLine, AsmLineRecordIsTemporary);

        lintLineNo := 0;
        AssemblyLine.Reset;
        AssemblyLine.SetRange("Document Type", AsmHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AsmHeader."No.");
        //
        lrecAssemblySetup.Get();
        if AsmHeader.CalcBasedOnBuildQty(AsmHeader) then
            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code")
        else
            if AsmHeader.CalcBasedOnBuildQty2(AsmHeader) then
                AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 2")
            else
                if AsmHeader.CalcBasedOnBuildQty_OK32LT(AsmHeader) then
                    AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 3")
                //
                else
                    if AsmHeader.CalcBasedOnBuildQty_OK32UV(AsmHeader) then
                        AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 4")
                    else
                        if AsmHeader.CalcBasedOnBuildQty_OK32LED(AsmHeader) then
                            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 5");
        //
        if AssemblyLine.FindFirst then begin
            lintLineNo := AssemblyLine."Line No." - 5;
        end;
        if lintLineNo > 0 then
            //
            AssemblyLine."Line No." := lintLineNo;
        AssemblyLine.Insert(true);
        //end;
        //ID2173 - End
    end;

    local procedure AddBOMLine2_OK32LED(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean; BomComponent: Record "BOM Component"; ShowDueDateBeforeWorkDateMessage: Boolean)
    var
        DueDateBeforeWorkDateMsgShown: Boolean;
        SkipVerificationsThatChangeDatabase: Boolean;
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        lrecItem: Record Item;
    begin
        //ID2173 - Start
        //BQ: Build Quantity - this calculation is based on Build Quantity
        //with AsmHeader do begin
        SkipVerificationsThatChangeDatabase := AsmLineRecordIsTemporary;
        AssemblyLine.SetSkipVerificationsThatChangeDatabase(SkipVerificationsThatChangeDatabase);
        AssemblyLine.Validate(Type, BomComponent.Type);
        AssemblyLine.Validate("No.", BomComponent."No.");
        if AssemblyLine.Type = AssemblyLine.Type::Resource then
            case BomComponent."Resource Usage Type" of
                BomComponent."Resource Usage Type"::Direct:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Direct);
                BomComponent."Resource Usage Type"::Fixed:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Fixed);
            end;
        AssemblyLine.Validate("Unit of Measure Code", BomComponent."Unit of Measure Code");
        if BomComponent.Ink then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                if lrecIUoM.Get(BomComponent."Parent Item No.", 'KG') then begin
                    if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                        BomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity OK32LED" / AsmHeader.Quantity) * BomComponent."Ink Percentage") / 100;
                    end;
                end;
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
            end;
        end
        else begin
            if AssemblyLine.Type <> AssemblyLine.Type::" " then
                AssemblyLine.Validate(
                  "Quantity per",
                  AssemblyLine.CalcBOMQuantity(
                    BomComponent.Type, BomComponent."Quantity per", 1, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        end;

        AssemblyLine.Validate(
          Quantity,
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
        AssemblyLine.Validate(
          "Quantity to Consume",
          AssemblyLine.CalcBOMQuantity(
            BomComponent.Type, BomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
            AssemblyLine."Resource Usage Type"));
        AssemblyLine.ValidateDueDate(AsmHeader, AsmHeader."Starting Date", ShowDueDateBeforeWorkDateMessage);
        DueDateBeforeWorkDateMsgShown := (AssemblyLine."Due Date" < WorkDate) and ShowDueDateBeforeWorkDateMessage;
        AssemblyLine.ValidateLeadTimeOffset(
          AsmHeader, BomComponent."Lead-Time Offset", not DueDateBeforeWorkDateMsgShown and ShowDueDateBeforeWorkDateMessage);
        AssemblyLine.Description := BomComponent.Description;
        AssemblyLine."Description 2" := AsmHeader."Description 2";
        if AssemblyLine.Type = AssemblyLine.Type::Item then
            AssemblyLine.Validate("Variant Code", BomComponent."Variant Code");
        AssemblyLine.Position := BomComponent.Position;
        AssemblyLine."Position 2" := BomComponent."Position 2";
        AssemblyLine."Position 3" := BomComponent."Position 3";
        if AsmHeader."Location Code" <> '' then
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        //
        AssemblyLine."Instruction Code" := BomComponent."Instruction Code";
        AssemblyLine."Ink Percentage" := BomComponent."Ink Percentage";
        AssemblyLine.Ink := BomComponent.Ink;
        //
        AssemblyLine.Modify(true);
        //end;
        //ID2173 - End
    end;

    //[Scope('Internal')]
    procedure UpdateAssemblyLines_OK32LED(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; FieldNum: Integer; ReplaceLinesFromBOM: Boolean; CurrFieldNo: Integer; CurrentFieldNum: Integer)
    var
        AssemblyLine: Record "Assembly Line";
        TempAssemblyHeader: Record "Assembly Header" temporary;
        TempAssemblyLine: Record "Assembly Line" temporary;
        BomComponent: Record "BOM Component";
        TempCurrAsmLine: Record "Assembly Line" temporary;
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        NoOfLinesFound: Integer;
        UpdateDueDate: Boolean;
        UpdateLocation: Boolean;
        UpdateQuantity: Boolean;
        UpdateUOM: Boolean;
        UpdateQtyToConsume: Boolean;
        UpdateDimension: Boolean;
        DueDateBeforeWorkDate: Boolean;
        NewLineDueDate: Date;
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
        lrecBOMInstruction: Record "BOM Instruction";
        lboolDryerLineInserted: Boolean;
        lrecItem1: Record Item;
        lrecBuildQuantity: Record "Build Quantity";
        lrecBomComponent: Record "BOM Component";
    //xltmprecItem: Record Item temporary;
    begin
        //ID2173 - Start
        if (FieldNum <> CurrentFieldNum) or // Update has been called from OnValidate of another field than was originally intended.
           ((not (FieldNum in [AsmHeader.FieldNo("Item No."),
                               AsmHeader.FieldNo("Variant Code"),
                               AsmHeader.FieldNo("Location Code"),
                               AsmHeader.FieldNo("Starting Date"),
                               AsmHeader.FieldNo(Quantity),
                               AsmHeader.FieldNo("Unit of Measure Code"),
                               AsmHeader.FieldNo("Quantity to Assemble"),
                               AsmHeader.FieldNo("Dimension Set ID")])) and (not ReplaceLinesFromBOM))
        then
            exit;
        Clear(lboolDryerLineInserted);
        NoOfLinesFound := AssemblyLineMgt.CopyAssemblyData(AsmHeader, TempAssemblyHeader, TempAssemblyLine);
        if ReplaceLinesFromBOM then begin
            TempAssemblyLine.DeleteAll;
            if not ((AsmHeader."Quantity (Base)" = 0) or (AsmHeader."Item No." = '')) then begin  // condition to replace asm lines
                //SetLinkToBOM(AsmHeader, BomComponent);
                BOMComponent.SETRANGE("Parent Item No.", AsmHeader."Item No.");

                if BomComponent.FindSet then begin
                    repeat
                        //InsertAsmLine(AsmHeader, TempAssemblyLine, true);
                        TempAssemblyLine.INIT;
                        TempAssemblyLine."Document Type" := AsmHeader."Document Type";
                        TempAssemblyLine."Document No." := AsmHeader."No.";
                        TempAssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(TempAssemblyLine, true);
                        TempAssemblyLine.INSERT(TRUE);

                        AddBOMLine2_OK32LED(AsmHeader, TempAssemblyLine, true, BomComponent, false);
                    until BomComponent.Next <= 0;
                    BomComponent.FindLast;
                    if not lboolDryerLineInserted then begin
                        lrecBomComponent.Reset;
                        lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                        lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                        lrecBomComponent.SetRange(Ink, true);
                        if not lrecBomComponent.IsEmpty then begin
                            if (lrecItemUOM.Get(BomComponent."Parent Item No.", 'KG')) and (lrecItemUOM."1 per Qty. per Unit of Measure" > 0) then begin
                                if lrecBuildQuantity.Get(lrecItemUOM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                    BomComponent."Quantity per" := 0;
                                    BomComponent.Type := BomComponent.Type::Item;
                                    lrecItem1.Get('S407');
                                    BomComponent."No." := 'S407';
                                    BomComponent."Unit of Measure Code" := lrecItem1."Base Unit of Measure";
                                    BomComponent.Ink := false;
                                    if lrecBomComponent.FindSet then
                                        repeat
                                            if lrecItem.Get(lrecBomComponent."No.") then
                                                BomComponent."Quantity per" := (lrecItemUOM."1 per Qty. per Unit of Measure" / 100) * 3;
                                        until lrecBomComponent.Next = 0;
                                    InsertAsmLine_OK32LED_S407(AsmHeader, TempAssemblyLine, true);
                                    AddBOMLine2_OK32LED(AsmHeader, TempAssemblyLine, true, BomComponent, false);

                                    //D409 line
                                    BomComponent.Type := BomComponent.Type::Item;
                                    lrecItem1.Get('D409');
                                    BomComponent."No." := 'D409';
                                    BomComponent."Unit of Measure Code" := lrecItem1."Base Unit of Measure";
                                    BomComponent.Ink := false;
                                    BomComponent."Quantity per" := 0;
                                    if lrecBomComponent.FindSet then begin
                                        repeat
                                            if lrecItem.Get(lrecBomComponent."No.") then begin
                                                //BomComponent."Quantity per"+=(lrecItem."Dryer (%)"/100)*(lrecBomComponent."Ink Percentage"/100)*(lrecItemUOM."1 per Qty. per Unit of Measure");
                                                BomComponent."Quantity per" := (lrecItemUOM."1 per Qty. per Unit of Measure" / 100) * 2;
                                            end;
                                        until lrecBomComponent.Next = 0;
                                        //BomComponent."Quantity per":=BomComponent."Quantity per"*1.5;
                                    end;
                                    InsertAsmLine_OK32LED_D409(AsmHeader, TempAssemblyLine, true);
                                    AddBOMLine2_OK32LED(AsmHeader, TempAssemblyLine, true, BomComponent, false);

                                    lboolDryerLineInserted := true;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end else
            if NoOfLinesFound = 0 then
                exit; // MODIFY condition but no lines to modify

        // make pre-checks OR ask user to confirm
        if PreCheckAndConfirmUpdate(AsmHeader, OldAsmHeader, FieldNum, ReplaceLinesFromBOM, TempAssemblyLine,
             UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension)
        then
            exit;

        if not ReplaceLinesFromBOM then
            if TempAssemblyLine.Find('-') then
                repeat
                    TempCurrAsmLine := TempAssemblyLine;
                    TempCurrAsmLine.Insert;
                    TempAssemblyLine.SetSkipVerificationsThatChangeDatabase(true);
                    UpdateExistingLine_OK32LED(AsmHeader, OldAsmHeader, CurrFieldNo, TempAssemblyLine,
                      UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension);
                until TempAssemblyLine.Next = 0;

        if not (FieldNum in [AsmHeader.FieldNo("Quantity to Assemble"), AsmHeader.FieldNo("Dimension Set ID")]) then
            if AssemblyLineMgt.ShowAvailability(false, TempAssemblyHeader, TempAssemblyLine) then
                ItemCheckAvail.RaiseUpdateInterruptedError;

        DoVerificationsSkippedEarlier(
          ReplaceLinesFromBOM, TempAssemblyLine, TempCurrAsmLine, UpdateDimension, AsmHeader."Dimension Set ID",
          OldAsmHeader."Dimension Set ID");

        AssemblyLine.Reset;
        if ReplaceLinesFromBOM then begin
            //rem smk2018.04.18 SLUPG: DeleteLines(AsmHeader);
            AsmHeader.DeleteAssemblyLines; //add smk2018.04.18 SLUPG
            TempAssemblyLine.Reset;
        end;

        if TempAssemblyLine.Find('-') then
            repeat
                if not ReplaceLinesFromBOM then
                    AssemblyLine.Get(TempAssemblyLine."Document Type", TempAssemblyLine."Document No.", TempAssemblyLine."Line No.");
                AssemblyLine := TempAssemblyLine;
                if ReplaceLinesFromBOM then
                    AssemblyLine.Insert(true)
                else
                    AssemblyLine.Modify(true);
                AsmHeader.AutoReserveAsmLine(AssemblyLine);
                if AssemblyLine."Due Date" < WorkDate then begin
                    DueDateBeforeWorkDate := true;
                    NewLineDueDate := AssemblyLine."Due Date";
                end;
            until TempAssemblyLine.Next = 0;

        if ReplaceLinesFromBOM or UpdateDueDate then
            if DueDateBeforeWorkDate then
                AssemblyLineMgt.ShowDueDateBeforeWorkDateMsg(NewLineDueDate);
        //ID2173 - End
    end;

    local procedure UpdateExistingLine_OK32LED(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; CurrFieldNo: Integer; var AssemblyLine: Record "Assembly Line"; UpdateDueDate: Boolean; UpdateLocation: Boolean; UpdateQuantity: Boolean; UpdateUOM: Boolean; UpdateQtyToConsume: Boolean; UpdateDimension: Boolean)
    var
        QtyRatio: Decimal;
        QtyToConsume: Decimal;
        lrecBomComponent: Record "BOM Component";
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        ldecQuantityper: Decimal;
        lrecItem: Record Item;
    begin
        //ID2173 - Start
        //with AsmHeader do begin
        if AsmHeader.IsStatusCheckSuspended then
            AssemblyLine.SuspendStatusCheck(true);

        if UpdateLocation then begin
            if AssemblyLine.Type = AssemblyLine.Type::Item then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");
        end;

        if UpdateDueDate then begin
            AssemblyLine.SetTestReservationDateConflict(CurrFieldNo <> 0);
            AssemblyLine.ValidateLeadTimeOffset(AsmHeader, AssemblyLine."Lead-Time Offset", false);
        end;

        if UpdateQuantity then begin
            QtyRatio := AsmHeader.Quantity / OldAsmHeader.Quantity;
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate(Quantity)
            else
                AssemblyLine.Validate(Quantity, AssemblyLine.Quantity * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateUOM then begin
            QtyRatio := AsmHeader."Qty. per Unit of Measure" / OldAsmHeader."Qty. per Unit of Measure";
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate("Quantity per")
            else
                AssemblyLine.Validate("Quantity per", AssemblyLine."Quantity per" * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateQtyToConsume then
            if not AssemblyLine.FixedUsage then begin
                AssemblyLine.InitQtyToConsume;
                QtyToConsume := AssemblyLine.Quantity * AsmHeader."Quantity to Assemble" / AsmHeader.Quantity;
                AsmHeader.RoundQty(QtyToConsume);
                if QtyToConsume <= AssemblyLine.MaxQtyToConsume then
                    AssemblyLine.Validate("Quantity to Consume", QtyToConsume);
            end;

        if UpdateQuantity then begin
            if not AssemblyLine.FixedUsage then begin
                if AssemblyLine.Type = AssemblyLine.Type::Item then begin
                    lrecBomComponent.Reset;
                    lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                    lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                    lrecBomComponent.SetRange("No.", AssemblyLine."No.");
                    lrecBomComponent.SetRange(Ink, true);
                    if lrecBomComponent.FindFirst then begin
                        if lrecIUoM.Get(lrecBomComponent."Parent Item No.", 'KG') then begin
                            if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then begin
                                lrecBomComponent."Quantity per" := ((lrecBuildQuantity."Build Quantity OK32LED" / AsmHeader.Quantity) * lrecBomComponent."Ink Percentage") / 100;
                                AssemblyLine.Validate("Quantity per", lrecBomComponent."Quantity per");

                                AssemblyLine.Validate(
                                  Quantity,
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));

                                AssemblyLine.Validate(
                                  "Quantity to Consume",
                                  AssemblyLine.CalcBOMQuantity(
                                    lrecBomComponent.Type, lrecBomComponent."Quantity per", AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure",
                                    AssemblyLine."Resource Usage Type"));
                            end;
                        end;
                    end
                    //D4 D25 D26 Line Update
                    else begin
                        if AssemblyLine."No." = 'D409' then begin
                            ldecQuantityper := 0;
                            lrecBomComponent.Reset;
                            lrecBomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                            lrecBomComponent.SetRange(Type, lrecBomComponent.Type::Item);
                            lrecBomComponent.SetRange(Ink, true);
                            if lrecBomComponent.FindFirst then begin
                                //REPEAT
                                if lrecItem.Get(AssemblyLine."No.") then begin
                                    if (lrecIUoM.Get(lrecBomComponent."Parent Item No.", 'KG')) and (lrecIUoM."1 per Qty. per Unit of Measure" > 0) then begin
                                        if lrecBuildQuantity.Get(lrecIUoM."1 per Qty. per Unit of Measure", AsmHeader.Quantity) then
                                            ldecQuantityper := (lrecIUoM."1 per Qty. per Unit of Measure" / 100) * 2;
                                    end;
                                end;
                                //UNTIL lrecBomComponent.NEXT=0;
                                AssemblyLine.Validate("Quantity per", ldecQuantityper);
                                AssemblyLine.Validate(
                                  Quantity,
                                  AssemblyLine.CalcBOMQuantity(
                                    AssemblyLine.Type, ldecQuantityper, AsmHeader.Quantity, AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));

                                AssemblyLine.Validate(
                                  "Quantity to Consume",
                                  AssemblyLine.CalcBOMQuantity(
                                    AssemblyLine.Type, ldecQuantityper, AsmHeader."Quantity to Assemble", AsmHeader."Qty. per Unit of Measure", AssemblyLine."Resource Usage Type"));
                            end;
                        end;
                    end;
                end;
            end;
        end;

        if UpdateDimension then
            AssemblyLine.UpdateDim(AsmHeader."Dimension Set ID", OldAsmHeader."Dimension Set ID");

        AssemblyLine.Modify(true);
        //end;
        //ID2173 - End
    end;

    local procedure InsertAsmLine_OK32LED_S407(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean)
    var
        lrecAssemblyLine: Record "Assembly Line";
        lintLineNo: Integer;
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //ID2173 - Start
        //with AsmHeader do begin
        AssemblyLine.Init;
        AssemblyLine."Document Type" := AsmHeader."Document Type";
        AssemblyLine."Document No." := AsmHeader."No.";
        AssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(AssemblyLine, AsmLineRecordIsTemporary);

        //
        lintLineNo := 0;
        AssemblyLine.Reset;
        AssemblyLine.SetRange("Document Type", AsmHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AsmHeader."No.");
        //
        lrecAssemblySetup.Get();
        if AsmHeader.CalcBasedOnBuildQty(AsmHeader) then
            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code")
        else
            if AsmHeader.CalcBasedOnBuildQty2(AsmHeader) then
                AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 2")
            else
                if AsmHeader.CalcBasedOnBuildQty_OK32LT(AsmHeader) then
                    AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 3")
                //
                else
                    if AsmHeader.CalcBasedOnBuildQty_OK32UV(AsmHeader) then
                        AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 4")
                    else
                        if AsmHeader.CalcBasedOnBuildQty_OK32LED(AsmHeader) then
                            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 5");
        //
        if AssemblyLine.FindFirst then begin
            lintLineNo := AssemblyLine."Line No." - 10;
        end;
        if lintLineNo > 0 then
            AssemblyLine."Line No." := lintLineNo;
        AssemblyLine.Insert(true);
        //end;
        //ID2173 - End
    end;

    local procedure InsertAsmLine_OK32LED_D409(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean)
    var
        lrecAssemblyLine: Record "Assembly Line";
        lintLineNo: Integer;
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //ID2173 - Start
        //with AsmHeader do begin
        AssemblyLine.Init;
        AssemblyLine."Document Type" := AsmHeader."Document Type";
        AssemblyLine."Document No." := AsmHeader."No.";
        AssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(AssemblyLine, AsmLineRecordIsTemporary);

        //
        lintLineNo := 0;
        AssemblyLine.Reset;
        AssemblyLine.SetRange("Document Type", AsmHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AsmHeader."No.");
        //
        lrecAssemblySetup.Get();
        if AsmHeader.CalcBasedOnBuildQty(AsmHeader) then
            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code")
        else
            if AsmHeader.CalcBasedOnBuildQty2(AsmHeader) then
                AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 2")
            else
                if AsmHeader.CalcBasedOnBuildQty_OK32LT(AsmHeader) then
                    AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 3")
                //
                else
                    if AsmHeader.CalcBasedOnBuildQty_OK32UV(AsmHeader) then
                        AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 4")
                    else
                        if AsmHeader.CalcBasedOnBuildQty_OK32LED(AsmHeader) then
                            AssemblyLine.SetRange("Instruction Code", lrecAssemblySetup."Instruction Code 5");
        //
        if AssemblyLine.FindFirst then begin
            lintLineNo := AssemblyLine."Line No." - 5;
        end;
        if lintLineNo > 0 then
            AssemblyLine."Line No." := lintLineNo;
        AssemblyLine.Insert(true);
        //end;
        //ID2173 - End
    end;

    local procedure PreCheckAndConfirmUpdate(AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; FieldNum: Integer; var ReplaceLinesFromBOM: Boolean; var TempAssemblyLine: Record "Assembly Line" temporary; var UpdateDueDate: Boolean; var UpdateLocation: Boolean; var UpdateQuantity: Boolean; var UpdateUOM: Boolean; var UpdateQtyToConsume: Boolean; var UpdateDimension: Boolean): Boolean
    begin
        UpdateDueDate := false;
        UpdateLocation := false;
        UpdateQuantity := false;
        UpdateUOM := false;
        UpdateQtyToConsume := false;
        UpdateDimension := false;

        //with AsmHeader do
        case FieldNum of
            AsmHeader.FieldNo("Item No."):
                begin
                    if AsmHeader."Item No." <> OldAsmHeader."Item No." then
                        if LinesExist(AsmHeader) then
                            if GuiAllowed then
                                if not Confirm(StrSubstNo(Text003, AsmHeader.FieldCaption("Item No."), OldAsmHeader."Item No.", AsmHeader."Item No."), true) then
                                    Error('');
                end;
            AsmHeader.FieldNo("Variant Code"):
                UpdateDueDate := true;
            AsmHeader.FieldNo("Location Code"):
                begin
                    UpdateDueDate := true;
                    if AsmHeader."Location Code" <> OldAsmHeader."Location Code" then begin
                        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Item);
                        TempAssemblyLine.SetFilter("Location Code", '<>%1', AsmHeader."Location Code");
                        if not TempAssemblyLine.IsEmpty then
                            if GuiAllowed then
                                if Confirm(StrSubstNo(Text001, TempAssemblyLine.FieldCaption("Location Code")), false) then
                                    UpdateLocation := true;
                        TempAssemblyLine.SetRange("Location Code");
                        TempAssemblyLine.SetRange(Type);
                    end;
                end;
            AsmHeader.FieldNo("Starting Date"):
                UpdateDueDate := true;
            AsmHeader.FieldNo(Quantity):
                if AsmHeader.Quantity <> OldAsmHeader.Quantity then begin
                    UpdateQuantity := true;
                    UpdateQtyToConsume := true;
                end;
            AsmHeader.FieldNo("Unit of Measure Code"):
                if AsmHeader."Unit of Measure Code" <> OldAsmHeader."Unit of Measure Code" then
                    UpdateUOM := true;
            AsmHeader.FieldNo("Quantity to Assemble"):
                UpdateQtyToConsume := true;
            AsmHeader.FieldNo("Dimension Set ID"):
                if AsmHeader."Dimension Set ID" <> OldAsmHeader."Dimension Set ID" then begin
                    if LinesExist(AsmHeader) then
                        if GuiAllowed then
                            if Confirm(Text002) then
                                UpdateDimension := true;
                end;
            else
                if CalledFromRefreshBOM(ReplaceLinesFromBOM, FieldNum) then
                    if LinesExist(AsmHeader) then
                        if GuiAllowed then
                            if not Confirm(Text004, false) then
                                ReplaceLinesFromBOM := false;
        end;

        if not (UpdateDueDate or UpdateLocation or UpdateQuantity or UpdateUOM or UpdateQtyToConsume or UpdateDimension) and
           // nothing to update
           not ReplaceLinesFromBOM
        then
            exit(true);
    end;

    local procedure DoVerificationsSkippedEarlier(ReplaceLinesFromBOM: Boolean; var TempNewAsmLine: Record "Assembly Line" temporary; var TempOldAsmLine: Record "Assembly Line" temporary; UpdateDimension: Boolean; NewHeaderSetID: Integer; OldHeaderSetID: Integer)
    var
        dimDict: Dictionary of [Integer, Code[20]];
        dictList: List of [Dictionary of [Integer, Code[20]]];
    begin
        if TempNewAsmLine.Find('-') then
            repeat
                TempNewAsmLine.SetSkipVerificationsThatChangeDatabase(false);
                if not ReplaceLinesFromBOM then
                    TempOldAsmLine.Get(TempNewAsmLine."Document Type", TempNewAsmLine."Document No.", TempNewAsmLine."Line No.");
                TempNewAsmLine.VerifyReservationQuantity(TempNewAsmLine, TempOldAsmLine);
                TempNewAsmLine.VerifyReservationChange(TempNewAsmLine, TempOldAsmLine);
                TempNewAsmLine.VerifyReservationDateConflict(TempNewAsmLine);

                if ReplaceLinesFromBOM then
                    //dimDict.Add(DATABASE::Item, TempNewAsmLine."No.");
                    case TempNewAsmLine.Type of
                        TempNewAsmLine.Type::Item:
                            begin
                                dimDict.Add(DATABASE::Item, TempNewAsmLine."No.");
                                dictList.add(dimDict);
                                TempNewAsmLine.CreateDim(dictList, NewHeaderSetID);
                                dimDict.Remove(Database::Item);
                                dictList.RemoveAt(1);
                            end;
                        TempNewAsmLine.Type::Resource:
                            begin
                                dimDict.Add(DATABASE::Resource, TempNewAsmLine."No.");
                                dictList.add(dimDict);
                                TempNewAsmLine.CreateDim(dictlist, NewHeaderSetID);
                                dimDict.Remove(Database::Resource);
                                dictList.RemoveAt(1);
                            end;
                    end
                else begin
                    if UpdateDimension then
                        TempNewAsmLine.UpdateDim(NewHeaderSetID, OldHeaderSetID);
                end;

                TempNewAsmLine.Modify;
            until TempNewAsmLine.Next = 0;
    end;

    local procedure LinesExist(AsmHeader: Record "Assembly Header"): Boolean
    var
        AssemblyLine: Record "Assembly Line";
    begin
        SetLinkToLines(AsmHeader, AssemblyLine);
        exit(not AssemblyLine.IsEmpty);
    end;

    local procedure SetLinkToLines(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line")
    begin
        AssemblyLine.SetRange("Document Type", AsmHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AsmHeader."No.");
    end;

    local procedure CalledFromRefreshBOM(ReplaceLinesFromBOM: Boolean; FieldNum: Integer): Boolean
    begin
        exit(ReplaceLinesFromBOM and (FieldNum = 0));
    end;

    //[Scope('Internal')]
    procedure UpdateAssemblyLines(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; FieldNum: Integer; ReplaceLinesFromBOM: Boolean; CurrFieldNo: Integer; CurrentFieldNum: Integer)
    var
        AssemblyLine: Record "Assembly Line";
        TempAssemblyHeader: Record "Assembly Header" temporary;
        TempAssemblyLine: Record "Assembly Line" temporary;
        BOMComponent: Record "BOM Component";
        TempCurrAsmLine: Record "Assembly Line" temporary;
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        NoOfLinesFound: Integer;
        UpdateDueDate: Boolean;
        UpdateLocation: Boolean;
        UpdateQuantity: Boolean;
        UpdateUOM: Boolean;
        UpdateQtyToConsume: Boolean;
        UpdateDimension: Boolean;
        DueDateBeforeWorkDate: Boolean;
        NewLineDueDate: Date;
        IsHandled: Boolean;
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
        lrecBOMInstruction: Record "BOM Instruction";
    begin
        //OnBeforeUpdateAssemblyLines(AsmHeader, OldAsmHeader, FieldNum, ReplaceLinesFromBOM, CurrFieldNo, CurrentFieldNum);

        if (FieldNum <> CurrentFieldNum) or // Update has been called from OnValidate of another field than was originally intended.
           ((not (FieldNum in [AsmHeader.FieldNo("Item No."),
                               AsmHeader.FieldNo("Variant Code"),
                               AsmHeader.FieldNo("Location Code"),
                               AsmHeader.FieldNo("Starting Date"),
                               AsmHeader.FieldNo(Quantity),
                               AsmHeader.FieldNo("Unit of Measure Code"),
                               AsmHeader.FieldNo("Quantity to Assemble"),
                               AsmHeader.FieldNo("Dimension Set ID")])) and (not ReplaceLinesFromBOM))
        then
            exit;

        NoOfLinesFound := AssemblyLineMgt.CopyAssemblyData(AsmHeader, TempAssemblyHeader, TempAssemblyLine);
        if ReplaceLinesFromBOM then begin
            TempAssemblyLine.DeleteAll;
            if not ((AsmHeader."Quantity (Base)" = 0) or (AsmHeader."Item No." = '')) then begin  // condition to replace asm lines
                IsHandled := false;
                //OnBeforeReplaceAssemblyLines(AsmHeader, TempAssemblyLine, IsHandled);
                if not IsHandled then begin
                    //SetLinkToBOM(AsmHeader, BOMComponent);
                    BOMComponent.SETRANGE("Parent Item No.", AsmHeader."Item No.");
                    if BOMComponent.FindSet then
                        repeat
                            //InsertAsmLine(AsmHeader, TempAssemblyLine, true);
                            TempAssemblyLine.INIT;
                            TempAssemblyLine."Document Type" := AsmHeader."Document Type";
                            TempAssemblyLine."Document No." := AsmHeader."No.";
                            TempAssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(TempAssemblyLine, true);
                            TempAssemblyLine.INSERT(TRUE);
                            //AddBOMLine2(AsmHeader,TempAssemblyLine,TRUE,BOMComponent,FALSE,AsmHeader."Qty. per Unit of Measure");

                            AddBOMLine2(AsmHeader, TempAssemblyLine, true, BOMComponent, false, AsmHeader."Qty. per Unit of Measure");

                            ///////////////////////////////
                            //begin add smk2018.04.10 slupg
                            ///////////////////////////////
                            // nj20160511 - Start
                            // if line has an Instruction Code, check if the
                            if BOMComponent."Instruction Code" <> '' then begin
                                lrecBOMInstruction.Get(BOMComponent."Instruction Code");
                                if lrecBOMInstruction.Dryer <> lrecBOMInstruction.Dryer::" " then begin
                                    if (lrecItem.Get(BOMComponent."Parent Item No.")) and (lrecItem."Dryer (%)" > 0) then begin
                                        if (lrecItemUOM.Get(BOMComponent."Parent Item No.", 'KG')) and (lrecItemUOM."1 per Qty. per Unit of Measure" > 0) then begin
                                            BOMComponent.Description := Format(lrecBOMInstruction.Dryer) + ': ' +
                                                                        Format(lrecItem."Dryer (%)" * lrecItemUOM."1 per Qty. per Unit of Measure" / 100) + ' Colour';
                                            BOMComponent."Ink Percentage" := lrecItem."Dryer (%)";
                                            BOMComponent."Instruction Code" := '';
                                            //InsertAsmLine(AsmHeader, TempAssemblyLine, true);
                                            TempAssemblyLine.INIT;
                                            TempAssemblyLine."Document Type" := AsmHeader."Document Type";
                                            TempAssemblyLine."Document No." := AsmHeader."No.";
                                            TempAssemblyLine."Line No." := AssemblyLineMgt.GetNextAsmLineNo(TempAssemblyLine, true);
                                            TempAssemblyLine.INSERT(TRUE);

                                            ///////////////////////////////
                                            //begin rem smk2018.04.10 slupg
                                            // from nav2016 modified
                                            ///////////////////////////////
                                            //AddBOMLine2(AsmHeader,TempAssemblyLine,TRUE,BomComponent,FALSE);
                                            ///////////////////////////////
                                            //end rem smk2018.04.10 slupg
                                            ///////////////////////////////

                                            /////////////////////////////////////
                                            //end add smk2018.04.10 slupg
                                            //  new parameter appended in NAV2018
                                            /////////////////////////////////////
                                            AddBOMLine2(AsmHeader, TempAssemblyLine, true, BOMComponent, false, AsmHeader."Qty. per Unit of Measure");
                                            /////////////////////////////////////
                                            //end add smk2018.04.10 slupg
                                            /////////////////////////////////////
                                        end;
                                    end;
                                end;
                            end;
                        // nj20160511 - End
                        ///////////////////////////////
                        //end add smk2018.04.10 slupg
                        ///////////////////////////////

                        until BOMComponent.Next <= 0;
                end;
            end;
        end else
            if NoOfLinesFound = 0 then
                exit; // MODIFY condition but no lines to modify

        // make pre-checks OR ask user to confirm
        if PreCheckAndConfirmUpdate(AsmHeader, OldAsmHeader, FieldNum, ReplaceLinesFromBOM, TempAssemblyLine,
             UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension)
        then
            exit;

        if not ReplaceLinesFromBOM then
            if TempAssemblyLine.Find('-') then
                repeat
                    TempCurrAsmLine := TempAssemblyLine;
                    TempCurrAsmLine.Insert;
                    TempAssemblyLine.SetSkipVerificationsThatChangeDatabase(true);
                    UpdateExistingLine(AsmHeader, OldAsmHeader, CurrFieldNo, TempAssemblyLine,
                      UpdateDueDate, UpdateLocation, UpdateQuantity, UpdateUOM, UpdateQtyToConsume, UpdateDimension);
                until TempAssemblyLine.Next = 0;

        if not (FieldNum in [AsmHeader.FieldNo("Quantity to Assemble"), AsmHeader.FieldNo("Dimension Set ID")]) then
            if AssemblyLineMgt.ShowAvailability(false, TempAssemblyHeader, TempAssemblyLine) then
                ItemCheckAvail.RaiseUpdateInterruptedError;

        DoVerificationsSkippedEarlier(
          ReplaceLinesFromBOM, TempAssemblyLine, TempCurrAsmLine, UpdateDimension, AsmHeader."Dimension Set ID",
          OldAsmHeader."Dimension Set ID");

        AssemblyLine.Reset;
        if ReplaceLinesFromBOM then begin
            AsmHeader.DeleteAssemblyLines;
            TempAssemblyLine.Reset;
        end;

        if TempAssemblyLine.Find('-') then
            repeat
                if not ReplaceLinesFromBOM then
                    AssemblyLine.Get(TempAssemblyLine."Document Type", TempAssemblyLine."Document No.", TempAssemblyLine."Line No.");
                AssemblyLine := TempAssemblyLine;
                if ReplaceLinesFromBOM then
                    AssemblyLine.Insert(true)
                else
                    AssemblyLine.Modify(true);
                AsmHeader.AutoReserveAsmLine(AssemblyLine);
                if AssemblyLine."Due Date" < WorkDate then begin
                    DueDateBeforeWorkDate := true;
                    NewLineDueDate := AssemblyLine."Due Date";
                end;
            until TempAssemblyLine.Next = 0;

        if ReplaceLinesFromBOM or UpdateDueDate then
            if DueDateBeforeWorkDate then
                AssemblyLineMgt.ShowDueDateBeforeWorkDateMsg(NewLineDueDate);
    end;

    local procedure AddBOMLine2(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; AsmLineRecordIsTemporary: Boolean; BOMComponent: Record "BOM Component"; ShowDueDateBeforeWorkDateMessage: Boolean; QtyPerUoM: Decimal)
    var
        DueDateBeforeWorkDateMsgShown: Boolean;
        SkipVerificationsThatChangeDatabase: Boolean;
    begin
        //with AsmHeader do begin
        SkipVerificationsThatChangeDatabase := AsmLineRecordIsTemporary;
        AssemblyLine.SetSkipVerificationsThatChangeDatabase(SkipVerificationsThatChangeDatabase);
        AssemblyLine.Validate(Type, BOMComponent.Type);
        AssemblyLine.Validate("No.", BOMComponent."No.");
        if AssemblyLine.Type = AssemblyLine.Type::Resource then
            case BOMComponent."Resource Usage Type" of
                BOMComponent."Resource Usage Type"::Direct:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Direct);
                BOMComponent."Resource Usage Type"::Fixed:
                    AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Fixed);
            end;
        AssemblyLine.Validate("Unit of Measure Code", BOMComponent."Unit of Measure Code");
        if AssemblyLine.Type <> AssemblyLine.Type::" " then
            AssemblyLine.Validate(
              "Quantity per",
              AssemblyLine.CalcBOMQuantity(
                BOMComponent.Type, BOMComponent."Quantity per", 1, QtyPerUoM, AssemblyLine."Resource Usage Type"));
        AssemblyLine.Validate(
          Quantity,
          AssemblyLine.CalcBOMQuantity(
            BOMComponent.Type, BOMComponent."Quantity per", AsmHeader.Quantity, QtyPerUoM, AssemblyLine."Resource Usage Type"));
        AssemblyLine.Validate(
          "Quantity to Consume",
          AssemblyLine.CalcBOMQuantity(
            BOMComponent.Type, BOMComponent."Quantity per", AsmHeader."Quantity to Assemble", QtyPerUoM, AssemblyLine."Resource Usage Type"));
        AssemblyLine.ValidateDueDate(AsmHeader, AsmHeader."Starting Date", ShowDueDateBeforeWorkDateMessage);
        DueDateBeforeWorkDateMsgShown := (AssemblyLine."Due Date" < WorkDate) and ShowDueDateBeforeWorkDateMessage;
        AssemblyLine.ValidateLeadTimeOffset(
          AsmHeader, BOMComponent."Lead-Time Offset", not DueDateBeforeWorkDateMsgShown and ShowDueDateBeforeWorkDateMessage);
        AssemblyLine.Description := BOMComponent.Description;
        if AssemblyLine.Type = AssemblyLine.Type::Item then
            AssemblyLine.Validate("Variant Code", BOMComponent."Variant Code");
        AssemblyLine.Position := BOMComponent.Position;
        AssemblyLine."Position 2" := BOMComponent."Position 2";
        AssemblyLine."Position 3" := BOMComponent."Position 3";
        if AsmHeader."Location Code" <> '' then
            if AssemblyLine.IsInventoriableItem then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");

        AssemblyLine."Instruction Code" := BOMComponent."Instruction Code";
        AssemblyLine."Ink Percentage" := BOMComponent."Ink Percentage";
        AssemblyLine.Ink := BOMComponent.Ink;

        //OnAfterTransferBOMComponent(AssemblyLine, BOMComponent);

        AssemblyLine.Modify(true);
        //end;
    end;

    local procedure UpdateExistingLine(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; CurrFieldNo: Integer; var AssemblyLine: Record "Assembly Line"; UpdateDueDate: Boolean; UpdateLocation: Boolean; UpdateQuantity: Boolean; UpdateUOM: Boolean; UpdateQtyToConsume: Boolean; UpdateDimension: Boolean)
    var
        QtyRatio: Decimal;
        QtyToConsume: Decimal;
    begin
        //with AsmHeader do begin
        if AsmHeader.IsStatusCheckSuspended then
            AssemblyLine.SuspendStatusCheck(true);

        if UpdateLocation then
            if AssemblyLine.IsInventoriableItem then
                AssemblyLine.Validate("Location Code", AsmHeader."Location Code");

        if UpdateDueDate then begin
            AssemblyLine.SetTestReservationDateConflict(CurrFieldNo <> 0);
            AssemblyLine.ValidateLeadTimeOffset(AsmHeader, AssemblyLine."Lead-Time Offset", false);
        end;

        if UpdateQuantity then begin
            QtyRatio := AsmHeader.Quantity / OldAsmHeader.Quantity;
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate(Quantity)
            else
                AssemblyLine.Validate(Quantity, AssemblyLine.Quantity * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateUOM then begin
            QtyRatio := AsmHeader."Qty. per Unit of Measure" / OldAsmHeader."Qty. per Unit of Measure";
            if AssemblyLine.FixedUsage then
                AssemblyLine.Validate("Quantity per")
            else
                AssemblyLine.Validate("Quantity per", AssemblyLine."Quantity per" * QtyRatio);
            AssemblyLine.InitQtyToConsume;
        end;

        if UpdateQtyToConsume then
            if not AssemblyLine.FixedUsage then begin
                AssemblyLine.InitQtyToConsume;
                QtyToConsume := AssemblyLine.Quantity * AsmHeader."Quantity to Assemble" / AsmHeader.Quantity;
                AsmHeader.RoundQty(QtyToConsume);
                if QtyToConsume <= AssemblyLine.MaxQtyToConsume then
                    AssemblyLine.Validate("Quantity to Consume", QtyToConsume);
            end;

        if UpdateDimension then
            AssemblyLine.UpdateDim(AsmHeader."Dimension Set ID", OldAsmHeader."Dimension Set ID");

        AssemblyLine.Modify(true);
        //end;
    end;
}