tableextension 50010 "RYCO Assembly Header" extends "Assembly Header"
{
    /*
    smk2018.04.10 SLUPG:
    --------------------
    FH20160921, SCP, Fazle
    - on modify of item lines are recreated

    FH20160922, SCP, Fazle
    - Qty To Assemble is made zero on insert Qty;

    FH20160929 SCP, Fazle
    - Adding New Functionality for OK32X

    FH20161028
    - New Function NewCalcBasedOnBuildQty_OK32LT

    nj20170123
    - Assignment of No. depending on User Location Code.

    smk2018.04.10 SLUPG:
    --------------------
    additiuonal manual merging on TestNoSeries(...)

    ID2173, nj20181031
    - Added Build Instructions for OK32UV, OK32LED
    */

    fields
    {
        // Add changes to table fields here
        field(50000; "Sales Order No."; Code[20])
        {
            //nj20160505
            Caption = 'Sales Order No.';
            TableRelation = IF ("Document Type" = CONST(Order)) "Sales Header"."No.";
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                lrecSalesHdr: record "Sales Header";
                lrecSalesLine: record "Sales Line";
            begin
                IF "Sales Order No." <> '' THEN BEGIN
                    //Fazle05312016-->
                    lrecSalesLine.SETRANGE("Document Type", lrecSalesLine."Document Type"::Order);
                    lrecSalesLine.SETRANGE("Document No.", "Sales Order No.");
                    lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::Item);
                    lrecSalesLine.SETRANGE("No.", "Item No.");
                    IF lrecSalesLine.ISEMPTY THEN
                        ERROR(STRSUBSTNO(Text016, "Item No.", "Sales Order No."));
                    //Fazle05312016--<
                    lrecSalesHdr.GET(lrecSalesHdr."Document Type"::Order, "Sales Order No.");
                    "Customer Name" := lrecSalesHdr."Sell-to Customer Name";
                END ELSE BEGIN
                    "Customer Name" := '';
                END;
            end;
        }
        field(50001; "Customer Name"; Text[50])
        {
            //nj20160505
            Caption = 'Customer Name';
            DataClassification = ToBeClassified;
        }
        field(50002; "Production Remark"; Text[250])
        {
            //nj20160505
            Caption = 'Production Remark';
            DataClassification = ToBeClassified;
        }
        field(50010; "Total Ink Kg (Lines)"; Decimal)
        {
            //fazle05262016
            Caption = 'Total Ink Kg (Lines)';
            FieldClass = FlowField;
            CalcFormula = Sum("Assembly Line".Quantity WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("No."), Type = FILTER(Item), Ink = FILTER(true)));
            Editable = false;
        }
        field(50020; "Total Dryer Kg (Lines)"; Decimal)
        {
            //fazle05262016
            Caption = 'Total Dryer Kg (Lines)';
            FieldClass = FlowField;
            CalcFormula = Sum("Assembly Line".Quantity WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("No."), Type = FILTER(Item), Ink = FILTER(false), "No." = FILTER('D4' | 'D25' | 'D26' | 'S407' | 'D409')));
            Editable = false;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                TestStatusOpen();
                if "No." <> xRec."No." then begin
                    AssemblySetup.Get();
                    NoSeriesMgt.TestManual(Ryco_GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;

        }
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
            begin
                //FH20160921-->
                COMMIT;
                IF ("Item No." <> xRec."Item No.") AND (xRec."Item No." <> '') THEN BEGIN
                    IF Quantity > 0 THEN BEGIN
                        VALIDATE(Quantity);
                    END;
                END;
                //FH20160921--<
            end;
        }

        modify("Posting No. Series")
        {
            trigger OnAfterValidate()
            var
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                Ryco_TestNoSeries();
            end;
        }
        modify("Quantity to Assemble")
        {
            //Workaround for NAV Customization that removes "Quantity to Assemble".OnValidate code where Quantity to Assemble > Remaining Quantity throwing error.
            trigger OnBeforeValidate()
            var

            begin
                if ("Quantity to Assemble" > "Remaining Quantity") then begin
                    gRemainingQuantity := "Remaining Quantity";
                    rec.Validate("Remaining Quantity", "Quantity to Assemble" + 1);
                end;
            end;

            trigger OnAfterValidate()
            var
            begin
                rec.Validate("Remaining Quantity", gRemainingQuantity);
                Clear(gRemainingQuantity);
            end;
        }

        //nj20221213 - Start
        /*
        modify(Quantity)
        {

        trigger OnAfterValidate()
        var
            AssemblyLineMgt: Codeunit "Ryco Assembly Line Mgt.";
            lrecBuildQuantity: Record "Build Quantity";
            lrecIUoM: Record "Item Unit of Measure";
            AssemblyHeaderReserve: Codeunit "Assembly Header-Reserve";
            CurrentFieldNum: Integer;
        begin
            // IF Quantity > 0 THEN BEGIN
            //     IF CalcBasedOnBuildQty(Rec) OR CalcBasedOnBuildQty2(Rec) THEN BEGIN
            //         IF NOT ((lrecIUoM.GET("Item No.", 'KG')) AND
            //            (lrecBuildQuantity.GET(lrecIUoM."1 per Qty. per Unit of Measure", Quantity))) THEN BEGIN
            //             ERROR('Build Quantity not defined!');
            //         END;
            //     END;
            // END;
            // CurrentFieldNum := FIELDNO(Quantity);
            // IF CalcBasedOnBuildQty(Rec) THEN //OK32R
            //     IF ("Item No." <> xRec."Item No.") AND (xRec."Item No." <> '') AND (Quantity > 0) THEN
            //         AssemblyLineMgt.UpdateAssemblyLines_BQ(Rec, xRec, FIELDNO(Quantity), TRUE, CurrFieldNo, CurrentFieldNum)//BQ: Build Quantity
            //     ELSE
            //         AssemblyLineMgt.UpdateAssemblyLines_BQ(Rec, xRec, FIELDNO(Quantity), ReplaceLinesFromBOM, CurrFieldNo, CurrentFieldNum)//BQ: Build Quantity
            // ELSE
            IF CalcBasedOnBuildQty2(Rec) THEN  //OK32X
                IF ("Item No." <> xRec."Item No.") AND (xRec."Item No." <> '') AND (Quantity > 0) THEN
                    AssemblyLineMgt.UpdateAssemblyLines_BQ2(Rec, xRec, FIELDNO(Quantity), TRUE, CurrFieldNo, CurrentFieldNum)//BQ: Build Quantity
                ELSE
                    AssemblyLineMgt.UpdateAssemblyLines_BQ2(Rec, xRec, FIELDNO(Quantity), ReplaceLinesFromBOM, CurrFieldNo, CurrentFieldNum)//BQ: Build Quantity
            ELSE
                IF CalcBasedOnBuildQty_OK32LT(Rec) THEN //OK32LT    FH20161028
                    IF ("Item No." <> xRec."Item No.") AND (xRec."Item No." <> '') AND (Quantity > 0) THEN
                        AssemblyLineMgt.UpdateAssemblyLines_BQ_OK32LT(Rec, xRec, FIELDNO(Quantity), TRUE, CurrFieldNo, CurrentFieldNum)//BQ: Build Quantity
                    ELSE
                        AssemblyLineMgt.UpdateAssemblyLines_BQ_OK32LT(Rec, xRec, FIELDNO(Quantity), ReplaceLinesFromBOM, CurrFieldNo, CurrentFieldNum)//BQ: Build Quantity
                ELSE
                    //ID2173 - Start
                    IF CalcBasedOnBuildQty_OK32UV(Rec) THEN
                        IF ("Item No." <> xRec."Item No.") AND (xRec."Item No." <> '') AND (Quantity > 0) THEN
                            AssemblyLineMgt.UpdateAssemblyLines_OK32UV(Rec, xRec, FIELDNO(Quantity), TRUE, CurrFieldNo, CurrentFieldNum)
                        ELSE
                            AssemblyLineMgt.UpdateAssemblyLines_OK32UV(Rec, xRec, FIELDNO(Quantity), ReplaceLinesFromBOM, CurrFieldNo, CurrentFieldNum)
                    ELSE
                        IF CalcBasedOnBuildQty_OK32LED(Rec) THEN
                            IF ("Item No." <> xRec."Item No.") AND (xRec."Item No." <> '') AND (Quantity > 0) THEN
                                AssemblyLineMgt.UpdateAssemblyLines_OK32LED(Rec, xRec, FIELDNO(Quantity), TRUE, CurrFieldNo, CurrentFieldNum)
                            ELSE
                                AssemblyLineMgt.UpdateAssemblyLines_OK32LED(Rec, xRec, FIELDNO(Quantity), ReplaceLinesFromBOM, CurrFieldNo, CurrentFieldNum)
                        ELSE
                            //ID2173 - End
                            //FH20160929--<
                            AssemblyLineMgt.UpdateAssemblyLines(Rec, xRec, FIELDNO(Quantity), ReplaceLinesFromBOM, CurrFieldNo, CurrentFieldNum);
            AssemblyHeaderReserve.VerifyQuantity(Rec, xRec);

            //ClearCurrentFieldNum(FIELDNO(Quantity));

            //FH20160922-->
            COMMIT;
            InitQtyToAssemble_New;
            VALIDATE("Quantity to Assemble");
            //FH20160922--<
        end;
    }
    */
        //nj20221213 - End
    }
    procedure CalcBasedOnBuildQty(precAssemblyHeader: Record "Assembly Header"): Boolean
    var
        lrecBomComponent: Record "BOM Component";
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        lrecAssemblySetup.GET();
        lrecBomComponent.RESET;
        lrecBomComponent.SETRANGE("Parent Item No.", "Item No.");
        lrecBomComponent.SETRANGE("Instruction Code", lrecAssemblySetup."Instruction Code");
        EXIT(lrecBomComponent.FINDFIRST);
    end;

    procedure InitQtyToAssemble_New()
    var
        ATOLink: Record "Assemble-to-Order Link";
    begin
        "Quantity to Assemble" := 0;//"Remaining Quantity";
        "Quantity to Assemble (Base)" := 0;//"Remaining Quantity (Base)";
        ATOLink.InitQtyToAsm(Rec, "Quantity to Assemble", "Quantity to Assemble (Base)");
    end;

    procedure CalcBasedOnBuildQty2(precAssemblyHeader: Record "Assembly Header"): Boolean
    var
        lrecBomComponent: Record "BOM Component";
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //FH20160929
        lrecAssemblySetup.GET();
        lrecBomComponent.RESET;
        lrecBomComponent.SETRANGE("Parent Item No.", "Item No.");
        lrecBomComponent.SETRANGE("Instruction Code", lrecAssemblySetup."Instruction Code 2");
        EXIT(lrecBomComponent.FINDFIRST);
    end;

    procedure CalcBasedOnBuildQty_OK32LT(precAssemblyHeader: Record "Assembly Header"): Boolean
    var
        lrecBomComponent: Record "BOM Component";
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //FH20161028
        lrecAssemblySetup.GET();
        lrecBomComponent.RESET;
        lrecBomComponent.SETRANGE("Parent Item No.", "Item No.");
        lrecBomComponent.SETRANGE("Instruction Code", lrecAssemblySetup."Instruction Code 3");
        EXIT(lrecBomComponent.FINDFIRST);
    end;

    procedure CalcBasedOnBuildQty_OK32UV(precAssemblyHeader: Record "Assembly Header"): Boolean
    var
        lrecBomComponent: Record "BOM Component";
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //ID2173 - Start
        lrecAssemblySetup.GET();
        lrecBomComponent.RESET;
        lrecBomComponent.SETRANGE("Parent Item No.", "Item No.");
        lrecBomComponent.SETRANGE("Instruction Code", lrecAssemblySetup."Instruction Code 4");
        EXIT(lrecBomComponent.FINDFIRST);
        //ID2173 - End
    end;

    procedure CalcBasedOnBuildQty_OK32LED(precAssemblyHeader: Record "Assembly Header"): Boolean
    var
        lrecBomComponent: Record "BOM Component";
        lrecAssemblySetup: Record "Assembly Setup";
    begin
        //ID2173 - Start
        lrecAssemblySetup.GET();
        lrecBomComponent.RESET;
        lrecBomComponent.SETRANGE("Parent Item No.", "Item No.");
        lrecBomComponent.SETRANGE("Instruction Code", lrecAssemblySetup."Instruction Code 5");
        EXIT(lrecBomComponent.FINDFIRST);
        //ID2173 - End
    end;

    local procedure ReplaceLinesFromBOM(): Boolean
    var
        NoLinesWerePresent: Boolean;
        LinesPresent: Boolean;
        DeleteLines: Boolean;
    begin
        NoLinesWerePresent := (xRec.Quantity * xRec."Qty. per Unit of Measure" = 0);
        LinesPresent := (Quantity * "Qty. per Unit of Measure" <> 0);
        DeleteLines := (Quantity = 0);

        EXIT((NoLinesWerePresent AND LinesPresent) OR DeleteLines);
    end;

    trigger OnBeforeInsert()
    var
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        CheckIsNotAsmToOrder();

        AssemblySetup.Get();

        if "No." = '' then begin
            Ryco_TestNoSeries();
            NoSeriesMgt.InitSeries(Ryco_GetNoSeriesCode(), xRec."No. Series", "Posting Date", "No.", "No. Series");
        end;

        if "Document Type" = "Document Type"::Order then begin
            InvtAdjmtEntryOrder.SetRange("Order Type", InvtAdjmtEntryOrder."Order Type"::Assembly);
            InvtAdjmtEntryOrder.SetRange("Order No.", "No.");
            if not InvtAdjmtEntryOrder.IsEmpty() then
                Error(Text001, Format("Document Type"), "No.");
        end;

        InitRecord();

        if GetFilter("Item No.") <> '' then
            if GetRangeMin("Item No.") = GetRangeMax("Item No.") then
                Validate("Item No.", GetRangeMin("Item No."));
    end;



    procedure Ryco_TestNoSeries()
    var
        AssemblySetup: Record "Assembly Setup";
        lrecUserSetup: Record "User setup";
    begin
        AssemblySetup.Get();
        case "Document Type" of
            "Document Type"::Quote:
                AssemblySetup.TestField("Assembly Quote Nos.");
            "Document Type"::Order:
                begin
                    ////////////////////////////////////////////////////
                    //begin add smk2018.04.10 SLUPG
                    //                *both modified and new nav2018 functionality
                    ////////////////////////////////////////////////////
                    // nj20170123 - Start
                    lrecUserSetup.GET(USERID);
                    IF lrecUserSetup."Location Code" = 'MONTREAL' THEN BEGIN
                        AssemblySetup.TESTFIELD("Assembly Order Nos. - MTL");
                        AssemblySetup.TESTFIELD("Pstd Assembly Order Nos. - MTL"); //add smk2018.04.10 SLUPG
                    END
                    ELSE
                        IF lrecUserSetup."Location Code" = 'CALGARY' THEN BEGIN
                            AssemblySetup.TESTFIELD("Assembly Order Nos. - CGY");
                            AssemblySetup.TESTFIELD("Pstd Assembly Order Nos. - CGY"); //add smk2018.04.10 SLUPG
                        END
                        ELSE BEGIN
                            AssemblySetup.TESTFIELD("Assembly Order Nos.");
                            AssemblySetup.TESTFIELD("Posted Assembly Order Nos."); //add smk2018.04.10 SLUPG (from NAV2018 CU3)
                        END
                    // nj20170123 - End
                    ///////////////////////////////////////////////////
                    //begin add smk2018.04.10 SLUPG
                    ///////////////////////////////////////////////////
                end;
            "Document Type"::"Blanket Order":
                AssemblySetup.TestField("Blanket Assembly Order Nos.");
        end;
    end;

    LOCAL procedure Ryco_GetNoSeriesCode(): Code[20]
    var
        lrecUserSetup: Record "User Setup";
    begin
        CASE "Document Type" OF
            "Document Type"::Quote:
                EXIT(AssemblySetup."Assembly Quote Nos.");
            "Document Type"::Order:
                BEGIN
                    // nj20170123 - Start
                    lrecUserSetup.GET(USERID);
                    IF lrecUserSetup."Location Code" = 'MONTREAL' THEN
                        EXIT(AssemblySetup."Assembly Order Nos. - MTL")
                    ELSE
                        IF lrecUserSetup."Location Code" = 'CALGARY' THEN
                            EXIT(AssemblySetup."Assembly Order Nos. - CGY")
                        ELSE
                            // nj20170123 - End
                            EXIT(AssemblySetup."Assembly Order Nos.");
                END;
            "Document Type"::"Blanket Order":
                EXIT(AssemblySetup."Blanket Assembly Order Nos.");
        END;
    end;

    procedure Ryco_AssistEdit(OldAssemblyHeader: Record "Assembly Header"): Boolean
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyHeader2: Record "Assembly Header";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        AssemblySetup: Record "Assembly Setup";
    begin
        with AssemblyHeader do begin
            Copy(Rec);
            AssemblySetup.Get();
            Ryco_TestNoSeries();
            if NoSeriesMgt.SelectSeries(Ryco_GetNoSeriesCode(), OldAssemblyHeader."No. Series", "No. Series") then begin
                NoSeriesMgt.SetSeries("No.");
                if AssemblyHeader2.Get("Document Type", "No.") then
                    Error(Text001, Format("Document Type"), "No.");
                Rec := AssemblyHeader;
                exit(true);
            end;
        end;
    end;

    procedure Ryco_SetDefaultLocation()
    var
        AsmSetup: Record "Assembly Setup";
        lrecUserSetup: Record "User Setup";
    begin
        IF AsmSetup.GET THEN
            IF AsmSetup."Default Location for Orders" <> '' THEN begin
                //IF "Location Code" = '' THEN BEGIN - We are expecting Location Code to be set from AssemblyHeader.SetDefaultLocation
                // nj20170123 - Start
                lrecUserSetup.GET(USERID);
                IF (lrecUserSetup."Location Code" = 'MONTREAL') OR (lrecUserSetup."Location Code" = 'CALGARY') THEN begin
                    VALIDATE("Location Code", lrecUserSetup."Location Code");
                end;
                //ELSE begin
                // nj20170123 - End
                //VALIDATE("Location Code", AsmSetup."Default Location for Orders");
                //end;
                //END;
            end;
    end;

    var
        Text001: Label '%1 %2 cannot be created, because it already exists or has been posted.', Comment = '%1 = Document Type, %2 = No.';
        Text016: Label 'Item: %1 is not in Sales Order: %2';
        AssemblySetup: Record "Assembly Setup";
        gRemainingQuantity: Decimal;
}