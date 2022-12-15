codeunit 50005 "SendEmailStream"
{
    procedure Rep50014_SendMail(ToAddr: List of [Text]; Subject: Text[100]; Body: Text; AttachmentName: Text[100]): Boolean
    var
        outStreamReport: OutStream;
        inStreamReport: InStream;
        Parameters: Text;
        tempBlob: Codeunit "Temp Blob";
        Base64EncodedString: Text;
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailAccount: Record "Email Account";
        EmailAccountUtil: Codeunit "Email Account";
        RecRef: RecordRef;

        lrep50014: Report "Items Below Safety Stock";
        lrecLocation: Record Location;
    //ldtePeriodEnding: Date;
    //ldtfPeriodCalculation: DateFormula;
    begin
        TempBlob.CreateOutStream(outStreamReport);
        TempBlob.CreateInStream(inStreamReport);

        //Print Report
        lrecLocation.Reset();
        RecRef.GetTable(lrecLocation);
        lrep50014.SetTableView(lrecLocation);
        lrep50014.UseRequestPage(false);
        lrep50014.SaveAs(Parameters, ReportFormat::Pdf, outStreamReport, RecRef);

        //Create mail
        CLEAR(Email);
        Clear(EmailMessage);
        EmailMessage.Create(ToAddr, Subject, Body, true);
        EmailMessage.AddAttachment(AttachmentName, 'pdf', inStreamReport);

        EmailAccountUtil.GetAllAccounts(true, EmailAccount);
        EmailAccount.SetFilter("Email Address", 'noreply@northerndocksystems.com');

        if (EmailAccount.FindFirst()) then begin
            //Send mail
            exit(Email.Send(EmailMessage, EmailAccount));
        end else
            exit;
    end;

    procedure ValidateEMailAdd(EmailAddress: Text[250]): Boolean;
    var
        ltxtEMail1: Text;
        ltxtEMail2: Text;
        lblnValidEmail: Boolean;
        i: Integer;
        x: Integer;
        y: Integer;
        NoOfAtSigns: Integer;
    begin
        IF EmailAddress = '' THEN
            exit(false);

        IF (EmailAddress[1] = '@') OR (EmailAddress[STRLEN(EmailAddress)] = '@') THEN
            exit(false);

        FOR i := 1 TO STRLEN(EmailAddress) DO BEGIN
            IF EmailAddress[i] = '@' THEN
                NoOfAtSigns := NoOfAtSigns + 1;
            IF NOT (
              ((EmailAddress[i] >= 'a') AND (EmailAddress[i] <= 'z')) OR
              ((EmailAddress[i] >= 'A') AND (EmailAddress[i] <= 'Z')) OR
              ((EmailAddress[i] >= '0') AND (EmailAddress[i] <= '9')) OR
              (EmailAddress[i] IN ['@', '.', '-', '_', ';'])) THEN
                exit(false);
        END;

        IF STRPOS(EmailAddress, ',') > 0 THEN
            exit(false);

        IF NoOfAtSigns = 0 THEN
            exit(false);

        lblnValidEmail := true;
        i := 1;
        ltxtEMail1 := EmailAddress;
        WHILE ltxtEMail1 <> '' DO BEGIN
            IF STRPOS(ltxtEMail1, ';') > 0 THEN BEGIN
                i += 1;
                x := STRLEN(ltxtEMail1);
                y := STRPOS(ltxtEMail1, ';');
                ltxtEMail1 := COPYSTR(ltxtEMail1, STRPOS(ltxtEMail1, ';') + 1, x - y);
            END ELSE
                ltxtEMail1 := '';
        END;
        //
        ltxtEMail1 := EmailAddress;
        //WHILE ltxtEMail1 <> '' DO BEGIN
        FOR x := 1 TO i DO BEGIN
            IF STRPOS(ltxtEMail1, ';') > 0 THEN
                ltxtEMail2 := COPYSTR(ltxtEMail1, 1, STRPOS(ltxtEMail1, ';') - 1)
            ELSE
                ltxtEMail2 := ltxtEMail1;
            //lblnValidEmail := CheckEmailAddress(ltxtEMail2, 'Customer', 'E-Mail', FALSE);
            IF lblnValidEmail = FALSE THEN
                exit(lblnValidEmail);
            IF STRPOS(ltxtEMail1, ';') > 0 THEN BEGIN
                IF COPYSTR(ltxtEMail1, STRPOS(ltxtEMail1, ';') + 1, STRPOS(ltxtEMail1, ';') - 1) = '' THEN
                    exit(FALSE);
                ltxtEMail1 := COPYSTR(ltxtEMail1, STRPOS(ltxtEMail1, ';') + 1, STRPOS(ltxtEMail1, ';') - 1);
            END ELSE
                exit(lblnValidEmail);
        END;
        exit(lblnValidEmail);
        // nj20171030 - End
    end;

}