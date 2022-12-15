tableextension 50012 "RYCO Assembly Setup" extends "Assembly Setup"
{
    fields
    {
        /*
        smk2018.04.27 slupg: automerge the following:

        FH20160929 SCP, Fazle
            - Adding New Field "Instruction Code 2" for Build Quantity field OK32X

        FH20161028
            - Added New Field "Instruction Code 3" for Build Quantity field OK32LT

        nj20170123
            - added Assembly Order Nos. - MTL, Pstd Assembly Order Nos. - MTL,
                Assembly Order Nos. - CGY, Pstd Assembly Order Nos. - CGY fields

        ID2173, nj20181031
            - Added Build Instructions for OK32UV, OK32LED

        */
        // Add changes to table fields here
        field(50000; "Instruction Code"; Code[20])
        {
            Caption = 'Instruction Code';
            TableRelation = "BOM Instruction";
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                //Fazle05312016-->
                IF PAGE.RUNMODAL(0, grecBOMInstruction) = ACTION::LookupOK THEN BEGIN
                    "Instruction Code" := grecBOMInstruction.Code;
                END;
                //Fazle05312016--<
            end;
        }
        field(50010; "Instruction Code 2"; Code[20])
        {
            //FH20160929
            Caption = 'Instruction Code 2';
            TableRelation = "BOM Instruction";
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                //FH20160929-->
                IF PAGE.RUNMODAL(0, grecBOMInstruction) = ACTION::LookupOK THEN BEGIN
                    "Instruction Code 2" := grecBOMInstruction.Code;
                END;
                //FH20160929--<
            end;
        }
        field(50020; "Instruction Code 3"; Code[20])
        {
            //FH20161028
            Caption = 'Instruction Code 3';
            TableRelation = "BOM Instruction";
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                //FH20160929-->
                IF PAGE.RUNMODAL(0, grecBOMInstruction) = ACTION::LookupOK THEN BEGIN
                    "Instruction Code 2" := grecBOMInstruction.Code;
                END;
                //FH20160929--<
            end;
        }
        field(50021; "Assembly Order Nos. - MTL"; Code[10])
        {
            //nj20170123
            CaptionML = ENU = 'Assembly Order Nos. - MTL', ESM = 'Núms. pedidos ensamblado', FRC = 'Numéros ordres d''assemblage', ENC = 'Assembly Order Nos. - MTL';
            TableRelation = "No. Series";
            AccessByPermission = TableData "Sales Shipment Header" = R;
            DataClassification = ToBeClassified;

        }
        field(50022; "Pstd Assembly Order Nos. - MTL"; Code[10])
        {
            //nj20170123
            CaptionML = ENU = 'Pstd Assembly Order Nos. - MTL', ESM = 'Núms. pedidos registrados ensamblado', FRC = 'Numéros ordres d''assemblage reportés', ENC = 'Pstd Assembly Order Nos. - MTL';
            TableRelation = "No. Series";
            DataClassification = ToBeClassified;
        }
        field(50023; "Assembly Order Nos. - CGY"; Code[10])
        {
            //nj20170123
            CaptionMl = ENU = 'Assembly Order Nos. - CGY', ESM = 'Núms. pedidos ensamblado', FRC = 'Numéros ordres d''assemblage', ENC = 'Assembly Order Nos. - CGY';
            TableRelation = "No. Series";
            AccessByPermission = TableData "Sales Shipment Header" = R;
            DataClassification = ToBeClassified;
        }
        field(50024; "Pstd Assembly Order Nos. - CGY"; Code[10])
        {
            //nj20170123
            CaptionML = ENU = 'Pstd Assembly Order Nos. - CGY', ESM = 'Núms. pedidos registrados ensamblado', FRC = 'Numéros ordres d''assemblage reportés', ENC = 'Pstd Assembly Order Nos. - CGY';
            TableRelation = "No. Series";
            DataClassification = ToBeClassified;
        }
        field(50025; "Instruction Code 4"; Code[20])
        {
            //ID2173
            Caption = 'Instruction Code 4';
            TableRelation = "BOM Instruction";
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                //ID2173 - Start
                IF PAGE.RUNMODAL(0, grecBOMInstruction) = ACTION::LookupOK THEN BEGIN
                    "Instruction Code 4" := grecBOMInstruction.Code;
                END;
                //ID2173 - End
            end;
        }
        field(50026; "Instruction Code 5"; Code[20])
        {
            //ID2173
            Caption = 'Instruction Code 5';
            TableRelation = "BOM Instruction";
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                //ID2173 - Start
                IF PAGE.RUNMODAL(0, grecBOMInstruction) = ACTION::LookupOK THEN BEGIN
                    "Instruction Code 5" := grecBOMInstruction.Code;
                END;
                //ID2173 - End
            end;
        }
    }

    var
        grecBOMInstruction: Record "BOM Instruction";
}