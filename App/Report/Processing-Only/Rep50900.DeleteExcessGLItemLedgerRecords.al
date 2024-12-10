report 50900 "Delete Excess G/L Item Ledger"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    Permissions = tabledata "G/L - Item Ledger Relation" = rimd;

    dataset
    {
        dataitem("G/L - Item Ledger Relation"; "G/L - Item Ledger Relation")
        {
            trigger OnAfterGetRecord()
            var
            begin
                if ("G/L - Item Ledger Relation"."G/L Entry No." > grecLastEntryNo) then
                    "G/L - Item Ledger Relation".Delete();
            end;
        }
    }

    trigger OnInitReport()
    var
        vrecGeneralLedgerEntry: Record "G/L Entry";
    begin
        if vrecGeneralLedgerEntry.FindLast() then begin
            grecLastEntryNo := vrecGeneralLedgerEntry."Entry No.";
        end;
    end;

    var
        grecLastEntryNo: Integer;
}