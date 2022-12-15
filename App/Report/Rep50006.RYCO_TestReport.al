report 50006 "Test Report"
{
    RDLCLayout = './App/Layout-Rdl/Rep50006.Ryc_TestReport.rdlc';
    WordLayout = './App/Layout-Rdl/Rep50006.Word_TestReport.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(printEnvelop; "Gen. Journal Line")
        {
            DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            RequestFilterFields = "Journal Template Name", "Journal Batch Name", "Posting Date";
            column(CheckToAddr1; CheckToAddr[1])
            {
            }
            column(CheckToAddr2; CheckToAddr[2])
            {
            }
            column(CheckToAddr3; CheckToAddr[3])
            {
            }
            column(CheckToAddr4; CheckToAddr[4])
            {
            }
            column(CheckToAddr5; CheckToAddr[5])
            {
            }
            column(CheckToAddr6; CheckToAddr[6])
            {
            }
            column(CheckToAddr7; CheckToAddr[7])
            {
            }
            column(CheckToAddr8; CheckToAddr[8])
            {
            }

            trigger OnAfterGetRecord()
            begin
                if ("Account No." <> '') and ("Bal. Account No." <> '') then begin
                    BalancingType := "Account Type";
                    BalancingNo := "Account No.";
                end else
                    if "Account No." = '' then
                        FieldError("Account No.", Text004)
                    else
                        FieldError("Bal. Account No.", Text004);

                Clear(CheckToAddr);
                case BalancingType of
                    BalancingType::"G/L Account":
                        begin
                            CheckToAddr[1] := Description;
                        end;
                    BalancingType::Customer:
                        begin
                            Cust.Get(BalancingNo);
                            if Cust.Blocked = Cust.Blocked::All then
                                Error(Text064, Cust.FieldCaption(Blocked), Cust.Blocked, Cust.TableCaption, Cust."No.");
                            Cust.Contact := '';
                            FormatAddr.Customer(CheckToAddr, Cust);
                        end;
                    BalancingType::Vendor:
                        begin
                            Vend.Get(BalancingNo);
                            if Vend.Blocked in [Vend.Blocked::All, Vend.Blocked::Payment] then
                                Error(Text064, Vend.FieldCaption(Blocked), Vend.Blocked, Vend.TableCaption, Vend."No.");
                            Vend.Contact := '';
                            FormatAddr.Vendor(CheckToAddr, Vend);
                        end;
                    BalancingType::"Bank Account":
                        begin
                            BankAcc.Get(BalancingNo);
                            BankAcc.TestField(Blocked, false);
                            BankAcc.Contact := '';
                            FormatAddr.BankAcc(CheckToAddr, BankAcc);
                        end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Bank Payment Type", "Bank Payment Type"::"Computer Check");
                SetRange("Check Printed", true);
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
        BalancingType: Option "G/L Account",Customer,Vendor,"Bank Account";
        BalancingNo: Code[20];
        Text004: Label 'must be entered.';
        CheckToAddr: array[8] of Text[50];
        Cust: Record Customer;
        Vend: Record Vendor;
        BankAcc: Record "Bank Account";
        Text064: Label '%1 must not be %2 for %3 %4.';
        FormatAddr: Codeunit "Format Address";
}

