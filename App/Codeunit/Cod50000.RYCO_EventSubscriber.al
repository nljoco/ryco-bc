codeunit 50000 "Event Subscriber"
{
    //Sales-Post
    #region Page 30 - Item Card
    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnBeforeOnOpenPage', '', false, false)]
    local procedure OnBeforeOnOpenPage(var Item: Record Item)
    var
        lcuRecalcMfgCost: Codeunit "Ryco Recalc Mfg Cost";
    begin
        //FH20160928-->
        IF Item."Assembly BOM" THEN BEGIN
            lcuRecalcMfgCost.Code(Item."No.");  //nj20190405
            Item."Mfg. Cost" := LocCalcMfgCost(Item."No.");
        END;
    end;

    local procedure LocCalcMfgCost(pcodItemNo: Code[20]): Decimal
    var
        lrecBOMComponent: Record "BOM Component";
        lrecItem: Record Item;
        ldecMfgCost: Decimal;
        lrecIUOM: Record "Item Unit of Measure";
        lrecUOMConvert: Decimal;
    begin
        //nj20190409 - Start
        CLEAR(ldecMfgCost);
        IF lrecItem."Assembly BOM" THEN BEGIN
            lrecBOMComponent.RESET;
            lrecBOMComponent.SETRANGE("Parent Item No.", pcodItemNo);
            lrecBOMComponent.SETRANGE(Type, lrecBOMComponent.Type::Item);
            lrecBOMComponent.SETFILTER("No.", '<>%1', '');
            IF lrecBOMComponent.FINDSET THEN BEGIN
                REPEAT
                    IF lrecItem.GET(lrecBOMComponent."No.") THEN BEGIN
                        lrecIUOM.RESET;
                        lrecIUOM.SETRANGE("Item No.", lrecBOMComponent."No.");
                        lrecIUOM.SETRANGE(Code, lrecBOMComponent."Unit of Measure Code");
                        IF lrecIUOM.FINDSET THEN
                            lrecUOMConvert := lrecIUOM."Qty. per Unit of Measure"
                        ELSE
                            lrecUOMConvert := 1;
                        lrecBOMComponent.CALCFIELDS("Assembly BOM");
                        IF (lrecBOMComponent."Assembly BOM") AND (lrecItem."Mfg. Cost" > 0) THEN
                            ldecMfgCost += lrecItem."Mfg. Cost" * lrecBOMComponent."Quantity per" * lrecUOMConvert
                        ELSE
                            ldecMfgCost += lrecItem."Unit Cost" * lrecBOMComponent."Quantity per" * lrecUOMConvert;
                    END;
                UNTIL lrecBOMComponent.NEXT = 0;
            END;
        END;
        EXIT(ldecMfgCost);
        //nj20190409 - End
    end;
    #endregion

    #region Codeunit 81 - Sales-Post (Yes/No)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeConfirmSalesPost', '', false, false)]
    local procedure OnBeforeConfirmSalesPost(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer; var PostAndSend: Boolean)
    var
    begin
        DefaultOption := 1;
    end;
    #endregion

    #region Codeunit 82 - Sales-Post + Print
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post + Print", 'OnBeforeConfirmPost', '', false, false)]
    local procedure OnBeforeConfirmPost(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean; var IsHandled: Boolean; var SendReportAsEmail: Boolean; var DefaultOption: Integer)
    var
    begin
        DefaultOption := 1;
    end;
    #endregion

    #region Codeunit 91 - Purch.-Post (Yes/No)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnBeforeConfirmPost', '', false, false)]
    local procedure OnBeforeConfirmPost_P1(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer)
    var
    begin
        DefaultOption := 1;
    end;
    #endregion

    #region Codeunit 92 - Purch.-Post + Print
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post + Print", 'OnBeforeConfirmPost', '', false, false)]
    local procedure OnBeforeConfirmPost_P2(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer)
    var
    begin
        DefaultOption := 1;
    end;
    #endregion

    #region Codeunit 228=9 - Document-rint
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document-Print", 'OnBeforePrintAsmHeader', '', false, false)]
    local procedure OnBeforePrintAsmHeader(var AssemblyHeader: Record "Assembly Header"; ReportUsage: Integer; var IsPrinted: Boolean)
    var
        Text001: Label 'Cannot Print, Order is %1';
        ReportSelections: Record "Report Selections";

    begin
        if AssemblyHeader."Document Type" = AssemblyHeader."Document Type"::Order then begin
            //Fazle05312016-->
            //DocPrint.PrintAsmHeader(Rec);
            IF AssemblyHeader.Status = AssemblyHeader.Status::Open THEN BEGIN
                ReportSelections.PrintReport(ReportUsage, AssemblyHeader);
                AssemblyHeader.Status := AssemblyHeader.Status::Released;
                AssemblyHeader.Modify();
                IsPrinted := true;
                //TESTFIELD(Status,Status::Released);
                //Status := Status::Open;
                //MODIFY;
                //COMMIT;
                //Status := Status::Released;
            END
            ELSE BEGIN
                ERROR(STRSUBSTNO(Text001, AssemblyHeader.Status));
            END;
            //Fazle05312016--<
        end;
    end;
    #endregion

    #region Codeunit 900 - Assembly-Post
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterFinalizePost', '', false, false)]
    local procedure OnAfterFinalizePost(var AssemblyHeader: Record "Assembly Header")
    var
    begin
        UpdateItem(AssemblyHeader);//Fazle05312016
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnBeforeDeleteAssemblyDocument', '', false, false)]
    local procedure OnBeforeDeleteAssemblyDocument(AssemblyHeader: Record "Assembly Header"; var IsHandled: Boolean)
    var
        AssemblyLine: Record "Assembly Line";
        AssemblyCommentLine: Record "Assembly Comment Line";
        AssemblyLineReserve: Codeunit "Assembly Line-Reserve";
    begin
        with AssemblyHeader do begin
            // Delete header and lines
            AssemblyLine.Reset();
            AssemblyLine.SetRange("Document Type", "Document Type");
            AssemblyLine.SetRange("Document No.", "No.");
            if "Remaining Quantity (Base)" <> 0 then begin //Fazle05302016
                if HasLinks then
                    DeleteLinks();
                DeleteWhseRequest(AssemblyHeader);
                Delete();
                if AssemblyLine.Find('-') then
                    repeat
                        if AssemblyLine.HasLinks then
                            DeleteLinks();
                        AssemblyLineReserve.SetDeleteItemTracking(true);
                        AssemblyLineReserve.DeleteLine(AssemblyLine);
                    until AssemblyLine.Next() = 0;
                AssemblyLine.DeleteAll();
                AssemblyCommentLine.SetCurrentKey("Document Type", "Document No.");
                AssemblyCommentLine.SetRange("Document Type", "Document Type");
                AssemblyCommentLine.SetRange("Document No.", "No.");
                if not AssemblyCommentLine.IsEmpty() then
                    AssemblyCommentLine.DeleteAll();
            end;
        end;
        //IsHandled := true;
    end;

    local procedure UpdateItem(AssemblyHeader: Record "Assembly Header")
    var
        lrecItem: Record Item;
        lrecItemMaster: Record Item;

    begin
        IF lrecItem.GET(AssemblyHeader."Item No.") THEN BEGIN
            CASE AssemblyHeader."Location Code" OF
                'CALGARY':
                    BEGIN
                        lrecItem."Prev Assembly Order No. - CGY" := lrecItem."Last Assembly Order No. - CGY";
                        lrecItem."Last Assembly Order No. - CGY" := AssemblyHeader."No.";
                    END;
                'MONTREAL':
                    BEGIN
                        lrecItem."Prev Assembly Order No. - MTL" := lrecItem."Last Assembly Order No. - MTL";
                        lrecItem."Last Assembly Order No. - MTL" := AssemblyHeader."No.";
                    END;
                ELSE BEGIN
                    lrecItem."Prev Assembly Order No." := lrecItem."Last Assembly Order No.";
                    lrecItem."Last Assembly Order No." := AssemblyHeader."No.";
                END;
            END;
            lrecItem.Modify();
            //nj20241003 - Start
            if (lrecItem."Master Item No." = false) and (lrecItem."Linked to Master Item No." <> '') then begin
                if lrecItemMaster.GET(lrecItem."Linked to Master Item No.") then begin
                    case AssemblyHeader."Location Code" of
                        'CALGARY':
                            begin
                                lrecItemMaster."Prev Assembly Order No. - CGY" := lrecItemMaster."Last Assembly Order No. - CGY";
                                lrecItemMaster."Last Assembly Order No. - CGY" := AssemblyHeader."No.";
                            end;
                        'MONTREAL':
                            begin
                                lrecItemMaster."Prev Assembly Order No. - MTL" := lrecItemMaster."Last Assembly Order No. - MTL";
                                lrecItemMaster."Last Assembly Order No. - MTL" := AssemblyHeader."No.";
                            end;
                        else begin
                            lrecItemMaster."Prev Assembly Order No." := lrecItemMaster."Last Assembly Order No.";
                            lrecItemMaster."Last Assembly Order No." := AssemblyHeader."No.";
                        end;
                    end;
                    lrecItemMaster.Modify();
                end;
            end;
            //nj20241003 - End
        END;
    end;

    local procedure DeleteWhseRequest(AssemblyHeader: Record "Assembly Header")
    var
        WhseRqst: Record "Warehouse Request";
    begin
        with WhseRqst do begin
            SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            SetRange("Source Type", DATABASE::"Assembly Line");
            SetRange("Source Subtype", AssemblyHeader."Document Type");
            SetRange("Source No.", AssemblyHeader."No.");
            if not IsEmpty() then
                DeleteAll(true);
        end;
    end;
    #endregion

    #region Codeunit 905 - Assembly Line Management
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly Line Management", 'OnAfterTransferBOMComponent', '', false, false)]
    local procedure OnAfterTransferBOMComponent(var AssemblyLine: Record "Assembly Line"; BOMComponent: Record "BOM Component"; AssemblyHeader: Record "Assembly Header")
    var
    begin
        // nj20160511 - Start
        AssemblyLine."Instruction Code" := BOMComponent."Instruction Code";
        AssemblyLine."Ink Percentage" := BOMComponent."Ink Percentage";
        AssemblyLine.Ink := BOMComponent.Ink;
        // nj20160511 - End
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly Line Management", 'OnBeforeUpdateQuantityToConsume', '', false, false)]
    local procedure OnBeforeUpdateQuantityToConsume(AssemblyHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; var QtyToConsume: Decimal; var IsHandled: Boolean)
    begin
        AssemblyLine.Validate("Quantity to Consume", QtyToConsume);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly Line Management", 'OnBeforeUpdateExistingLine', '', false, false)]
    local procedure OnBeforeUpdateExistingLine(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; CurrFieldNo: Integer; var AssemblyLine: Record "Assembly Line"; UpdateDueDate: Boolean; UpdateLocation: Boolean; UpdateQuantity: Boolean; UpdateUOM: Boolean; UpdateQtyToConsume: Boolean; UpdateDimension: Boolean; var IsHandled: Boolean)
    begin
        //Message('Original quantity to assemble: %1', AsmHeader."Quantity to Assemble");
        //Message('Old quantity to assemble: %1', OldAsmHeader."Quantity to Assemble");

        If (AsmHeader."Quantity to Assemble" <> OldAsmHeader."Quantity to Assemble") then begin
            IsHandled := true;
            //UpdateQtyToConsume := false;
        end
    end;
    #endregion

    #region Table 27 - Item
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateItemCategorycode', '', false, false)]
    local procedure OnAfterValidateItemCategoryCode(var Item: Record Item; xItem: Record Item)
    var
        SalesPrice: Record "Sales Price";
    begin
        //ID2288 - Start
        IF Item."Item Category Code" <> xItem."Item Category Code" THEN BEGIN

            SalesPrice.RESET;
            SalesPrice.SETRANGE("Item No.", Item."No.");
            SalesPrice.MODIFYALL("Item Category Code", Item."Item Category Code");
        END;
        //ID2288 - End
    end;


    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeCreateItemUnitOfMeasure', '', false, false)]
    local procedure OnBeforeCreateItemUnitOfMeasure(var Item: Record Item; var ItemUnitOfMeasure: Record "Item Unit of Measure"; var IsHandled: Boolean)
    var
    begin
        ItemUnitOfMeasure.Init();
        if Item.IsTemporary then
            ItemUnitOfMeasure."Item No." := Item."No."
        else
            ItemUnitOfMeasure.Validate("Item No.", Item."No.");
        ItemUnitOfMeasure.Validate(Code, Item."Base Unit of Measure");
        //Fazle06142016-->
        //ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
        ItemUnitOfMeasure.VALIDATE("Qty. per Unit of Measure", 1);
        //Fazle06142016--<
        ItemUnitOfMeasure.Insert();
        IsHandled := true;
    end;

    #endregion

    #region Table37 - Sales Line
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateNoOnAfterUpdateUnitPrice', '', false, false)]
    local procedure OnValidateNoOnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary)
    var
        FindRecordMgt: Codeunit "Find Record Management";
        lrecItem2: Record Item;
        PostingSetupMgt: Codeunit PostingSetupManagement;
        Text061: Label 'Item has pollutant "CAS5160-02-1"';
    begin
        /////////////////////////////////
        //BEGIN ADD smk2018.04.09 SLUPG
        //      from nav2016 modified
        /////////////////////////////////
        //Fazle06092016-->
        IF SalesLine.Type = SalesLine.Type::Item THEN BEGIN
            Salesline.VALIDATE(SalesLine."Selling Unit of Measure");
        END;
        //Fazle06092016--<
        /////////////////////////////////
        //END ADD smk2018.04.09 SLUPG
        /////////////////////////////////
        /////////////////////////////////
        //BEGIN ADD smk2018.04.09 SLUPG
        //      from nav2018 cu3 original
        /////////////////////////////////
        PostingSetupMgt.CheckGenPostingSetupSalesAccount(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        PostingSetupMgt.CheckGenPostingSetupCOGSAccount(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        PostingSetupMgt.CheckVATPostingSetupSalesAccount(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");
        /////////////////////////////////
        //END ADD smk2018.04.09 SLUPG
        /////////////////////////////////

        //ID2136 start
        IF SalesLine.Type = SalesLine.Type::Item THEN
            IF lrecItem2.GET(SalesLine."No.") THEN
                IF lrecItem2."CAS5160-02-1" <> 0 THEN
                    MESSAGE(Text061);
        //ID2136 end

    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateQuantityOnBeforeResetAmounts', '', false, false)]
    local procedure OnValidateQuantityOnBeforeResetAmounts(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
        If SalesLine.Type = SalesLine.Type::Item THEN begin
            SalesLine.Validate(SalesLine."Selling Unit of Measure");
        end;
    end;
    #endregion

    #region Table 90 - BOM Component
    [EventSubscriber(ObjectType::Table, Database::"BOM Component", 'OnBeforeCopyFromItem', '', false, false)]
    procedure OnBeforeCopyFromItem(var BOMComponent: Record "BOM Component"; xBOMComponent: Record "BOM Component"; Item: Record Item; CallingFieldNo: Integer; var IsHandled: Boolean)
    var
        lrecItemCategory: Record "Item Category";
    begin
        //BOMComponent.ValidateItemForDuplication();//Fazle05242016
        //Fazle05242016-->
        IF Item."Item Category Code" <> '' THEN BEGIN
            IF lrecItemCategory.GET(Item."Item Category Code") THEN BEGIN
                BOMComponent.Ink := lrecItemCategory.Ink;
            END
            ELSE BEGIN
                BOMComponent.Ink := FALSE;
            END;
        END
        ELSE BEGIN
            BOMComponent.Ink := FALSE;
        END;
        //Fazle05242016--<
    end;
    #endregion

    #region Table 900 - Assembly Header
    [EventSubscriber(ObjectType::Table, Database::"Assembly Header", 'OnAfterInitRecord', '', false, false)]
    local procedure OnAfterInitRecord(var AssemblyHeader: Record "Assembly Header")
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        lrecUserSetup: Record "User Setup";
        AssemblySetup: Record "Assembly Setup";
    begin
        AssemblySetup.Get();

        case AssemblyHeader."Document Type" of
            AssemblyHeader."Document Type"::Quote, AssemblyHeader."Document Type"::"Blanket Order":
                NoSeriesMgt.SetDefaultSeries(AssemblyHeader."Posting No. Series", AssemblySetup."Posted Assembly Order Nos.");
            AssemblyHeader."Document Type"::Order:
                begin
                    // nj20170123 - Start
                    lrecUserSetup.GET(USERID);
                    IF lrecUserSetup."Location Code" = 'MONTREAL' THEN BEGIN
                        IF (AssemblyHeader."No. Series" <> '') AND (AssemblySetup."Assembly Order Nos. - MTL" = AssemblySetup."Pstd Assembly Order Nos. - MTL") THEN
                            AssemblyHeader."Posting No. Series" := AssemblyHeader."No. Series"
                        ELSE begin
                            NoSeriesMgt.SetDefaultSeries(AssemblyHeader."Posting No. Series", AssemblySetup."Pstd Assembly Order Nos. - MTL");
                        end;
                    END ELSE BEGIN
                        IF lrecUserSetup."Location Code" = 'CALGARY' THEN BEGIN
                            IF (AssemblyHeader."No. Series" <> '') AND (AssemblySetup."Assembly Order Nos. - CGY" = AssemblySetup."Pstd Assembly Order Nos. - CGY") THEN
                                AssemblyHeader."Posting No. Series" := AssemblyHeader."No. Series"
                            ELSE
                                NoSeriesMgt.SetDefaultSeries(AssemblyHeader."Posting No. Series", AssemblySetup."Pstd Assembly Order Nos. - CGY");
                        END ELSE BEGIN
                            // nj20170123 - End
                            if (AssemblyHeader."No. Series" <> '') and (AssemblySetup."Assembly Order Nos." = AssemblySetup."Posted Assembly Order Nos.") then
                                AssemblyHeader."Posting No. Series" := AssemblyHeader."No. Series"
                            else
                                NoSeriesMgt.SetDefaultSeries(AssemblyHeader."Posting No. Series", AssemblySetup."Posted Assembly Order Nos.");
                        end;
                    end;
                end;
        end;
        AssemblyHeader.Ryco_SetDefaultLocation();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Assembly Header", 'OnBeforeUpdateAssemblyLinesAndVerifyReserveQuantity', '', false, false)]
    local procedure OnBeforeUpdateAssemblyLinesAndVerifyReserveQuantity(var AssemblyHeader: Record "Assembly Header"; var xAssemblyHeader: Record "Assembly Header"; CallingFieldNo: Integer; CurrentFieldNum: Integer; var IsHandled: Boolean)
    var
        lrecBuildQuantity: Record "Build Quantity";
        lrecIUoM: Record "Item Unit of Measure";
        AssemblyLineMgt: Codeunit "Ryco Assembly Line Mgt.";
        blnReplLinesFromBOM: Boolean;
        AssemblyHeaderReserve: Codeunit "Assembly Header-Reserve";
    begin
        AssemblyHeader.InitRemainingQty;

        AssemblyHeader.InitQtyToAssemble;

        AssemblyHeader.VALIDATE("Quantity to Assemble");
        //FH20160929-->
        // {
        // //Fazle05252016-->
        // IF Quantity > 0 THEN BEGIN
        //             IF CalcBasedOnBuildQty THEN BEGIN
        //                 IF NOT ((lrecIUoM.GET("Item No.", 'KG')) AND
        //                    (lrecBuildQuantity.GET(lrecIUoM."1 per Qty. per Unit of Measure", Quantity))) THEN BEGIN
        //                     ERROR('Build Quantity not defined!');
        //                 END;
        //             END;
        //         END;
        //         IF CalcBasedOnBuildQty THEN
        //             //FH20160921-->
        //             IF ("Item No." <> xRec."Item No.") AND (xRec."Item No." <> '') AND (Quantity > 0) THEN
        //                 AssemblyLineMgt.UpdateAssemblyLines_BQ(Rec, xRec, FIELDNO(Quantity), TRUE, CurrFieldNo, CurrentFieldNum)//BQ: Build Quantity
        //             ELSE
        //                 //FH20160921--<
        //                 AssemblyLineMgt.UpdateAssemblyLines_BQ(Rec, xRec, FIELDNO(Quantity), ReplaceLinesFromBOM, CurrFieldNo, CurrentFieldNum)//BQ: Build Quantity
        //         ELSE
        // //Fazle05252016--<
        // }
        IF AssemblyHeader.Quantity > 0 THEN BEGIN
            IF AssemblyHeader.CalcBasedOnBuildQty(AssemblyHeader) OR AssemblyHeader.CalcBasedOnBuildQty2(AssemblyHeader) THEN BEGIN
                IF NOT ((lrecIUoM.GET(AssemblyHeader."Item No.", 'KG')) AND
                   (lrecBuildQuantity.GET(lrecIUoM."1 per Qty. per Unit of Measure", AssemblyHeader.Quantity))) THEN BEGIN
                    ERROR('Build Quantity not defined!');
                END;
            END;
        END;
        blnReplLinesFromBOM := ReplaceLinesFromBOM(AssemblyHeader, xAssemblyHeader);
        IF AssemblyHeader.CalcBasedOnBuildQty(AssemblyHeader) THEN //OK32R
            IF (AssemblyHeader."Item No." <> xAssemblyHeader."Item No.") AND (xAssemblyHeader."Item No." <> '') AND (AssemblyHeader.Quantity > 0) THEN BEGIN
                AssemblyLineMgt.UpdateAssemblyLines_BQ(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), TRUE, CallingFieldNo, CurrentFieldNum);//BQ: Build Quantity
                IsHandled := true;
            END ELSE begin
                AssemblyLineMgt.UpdateAssemblyLines_BQ(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), blnReplLinesFromBOM, CallingFieldNo, CurrentFieldNum);//BQ: Build Quantity
                IsHandled := true;
            end
        ELSE
            IF AssemblyHeader.CalcBasedOnBuildQty2(AssemblyHeader) THEN  //OK32X
                IF (AssemblyHeader."Item No." <> xAssemblyHeader."Item No.") AND (xAssemblyHeader."Item No." <> '') AND (AssemblyHeader.Quantity > 0) THEN begin
                    AssemblyLineMgt.UpdateAssemblyLines_BQ2(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), TRUE, CallingFieldNo, CurrentFieldNum);//BQ: Build Quantity
                    IsHandled := true;
                end ELSE begin
                    AssemblyLineMgt.UpdateAssemblyLines_BQ2(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), blnReplLinesFromBOM, CallingFieldNo, CurrentFieldNum);//BQ: Build Quantity
                    IsHandled := true;
                end
            ELSE
                IF AssemblyHeader.CalcBasedOnBuildQty_OK32LT(AssemblyHeader) THEN //OK32LT    FH20161028
                    IF (AssemblyHeader."Item No." <> xAssemblyHeader."Item No.") AND (xAssemblyHeader."Item No." <> '') AND (AssemblyHeader.Quantity > 0) THEN begin
                        AssemblyLineMgt.UpdateAssemblyLines_BQ_OK32LT(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), TRUE, CallingFieldNo, CurrentFieldNum);//BQ: Build Quantity
                        IsHandled := true;
                    end ELSE begin
                        AssemblyLineMgt.UpdateAssemblyLines_BQ_OK32LT(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), blnReplLinesFromBOM, CallingFieldNo, CurrentFieldNum);//BQ: Build Quantity
                        IsHandled := true;
                    end
                ELSE
                    //ID2173 - Start
                    IF AssemblyHeader.CalcBasedOnBuildQty_OK32UV(AssemblyHeader) THEN //OK32UV
                        IF (AssemblyHeader."Item No." <> xAssemblyHeader."Item No.") AND (xAssemblyHeader."Item No." <> '') AND (AssemblyHeader.Quantity > 0) THEN begin
                            AssemblyLineMgt.UpdateAssemblyLines_OK32UV(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), TRUE, CallingFieldNo, CurrentFieldNum);
                            IsHandled := true;
                        end ELSE begin
                            AssemblyLineMgt.UpdateAssemblyLines_OK32UV(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), blnReplLinesFromBOM, CallingFieldNo, CurrentFieldNum);
                            IsHandled := true;
                        end
                    ELSE
                        IF AssemblyHeader.CalcBasedOnBuildQty_OK32LED(AssemblyHeader) THEN //OK32LED
                            IF (AssemblyHeader."Item No." <> xAssemblyHeader."Item No.") AND (xAssemblyHeader."Item No." <> '') AND (AssemblyHeader.Quantity > 0) THEN begin
                                AssemblyLineMgt.UpdateAssemblyLines_OK32LED(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), TRUE, CallingFieldNo, CurrentFieldNum);
                                IsHandled := true;
                            end ELSE begin
                                AssemblyLineMgt.UpdateAssemblyLines_OK32LED(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), blnReplLinesFromBOM, CallingFieldNo, CurrentFieldNum);
                                IsHandled := true;
                            end
                        ELSE begin
                            //ID2173 - End
                            //FH20160929--<
                            AssemblyLineMgt.UpdateAssemblyLines(AssemblyHeader, xAssemblyHeader, AssemblyHeader.FIELDNO(Quantity), blnReplLinesFromBOM, CallingFieldNo, CurrentFieldNum);
                            IsHandled := True;
                        end;

        //nj20221215 - Start
        if IsHandled then
            AssemblyHeaderReserve.VerifyQuantity(AssemblyHeader, xAssemblyHeader);
        //nj20221215 - End

        // FH20160922-->
        COMMIT;
        InitQtyToAssemble_New(AssemblyHeader);
        AssemblyHeader.VALIDATE(AssemblyHeader."Quantity to Assemble");
        // FH20160922--<
    end;

    local procedure ReplaceLinesFromBOM(AssemblyHeader: Record "Assembly Header"; var xAssemblyHeader: Record "Assembly Header"): Boolean
    var
        NoLinesWerePresent: Boolean;
        LinesPresent: Boolean;
        DeleteLines: Boolean;
    begin
        NoLinesWerePresent := (xAssemblyHeader.Quantity * xAssemblyHeader."Qty. per Unit of Measure" = 0);
        LinesPresent := (AssemblyHeader.Quantity * AssemblyHeader."Qty. per Unit of Measure" <> 0);
        DeleteLines := (AssemblyHeader.Quantity = 0);
        EXIT((NoLinesWerePresent AND LinesPresent) OR DeleteLines);
    end;

    local procedure InitQtyToAssemble_New(var AssemblyHeader: record "Assembly Header")
    var
        ATOLink: Record "Assemble-to-Order Link";
    begin
        AssemblyHeader."Quantity to Assemble" := 0;//"Remaining Quantity";
        AssemblyHeader."Quantity to Assemble (Base)" := 0;//"Remaining Quantity (Base)";
        ATOLink.InitQtyToAsm(AssemblyHeader, AssemblyHeader."Quantity to Assemble", AssemblyHeader."Quantity to Assemble (Base)");
    end;
    #endregion

    #region Table 5741 - Transfer Line
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnBeforeValidateDescription', '', false, false)]
    local procedure OnBeforeValidateDescription(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line"; CurrFieldNo: Integer; var IsHandled: Boolean)
    var
        Item: Record Item;
        ItemDescriptionIsNo: Boolean;
        ConfirmManagement: Codeunit "Confirm Management";
        AnotherItemWithSameDescrQst: Label 'We found an item with the description "%2" (No. %1).\Did you mean to change the current item to %1?', Comment = '%1=Item no., %2=item description';
    begin
        if (StrLen(TransferLine.Description) <= MaxStrLen(Item."No.")) and (TransferLine."Item No." <> '') then
            ItemDescriptionIsNo := Item.Get(TransferLine.Description);

        if (TransferLine."Item No." <> '') and (not ItemDescriptionIsNo) and (TransferLine.Description <> '') then begin
            Item.SetFilter(Description, '''@' + ConvertStr(TransferLine.Description, '''', '?') + '''');
            if not Item.FindFirst() then begin
                IsHandled := true;
                exit;
            end;
            if Item."No." = TransferLine."Item No." then begin
                IsHandled := true;
                exit;
            end;
            IsHandled := true;
            //IsHandled will remove the below lines of code from running in "Transfer Line" Table Line 268
            //if ConfirmManagement.GetResponseOrDefault(
            //  StrSubstNo(AnotherItemWithSameDescrQst, Item."No.", Item.Description), true)
            // then
            //     Validate("Item No.", Item."No.");
            // exit;
        end;
    end;
    #endregion

    #region Report 790 - Calculate Inventory
    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory", 'OnInsertItemJnlLineOnAfterValidateLocationCode', '', false, false)]
    local procedure OnInsertItemJnlLineOnAfterValidateLocationCode(ItemNo: Code[20]; VariantCode2: Code[10]; DimEntryNo2: Integer; BinCode2: Code[20]; Quantity2: Decimal; PhysInvQuantity: Decimal; var ItemJournalLine: Record "Item Journal Line")
    var
        lrecItem: Record Item;
    begin
        IF lrecItem.GET(ItemNo) THEN
            ItemJournalLine."Shelf No." := lrecItem."Shelf No.";
    end;
    #endregion
}