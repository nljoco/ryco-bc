codeunit 50001 "Low Stock Notifications"
{
    // ID623, RPD, 2017.02.22
    //  - New CU
    trigger OnRun()
    var
        ltxtFile: Text[30];
        teststream: InStream;
    begin
        Code;
    end;

    local procedure "Code"()
    var
        cuSendMail: Codeunit "SendEmailStream";
        ToAddr: List of [Text];
        lrecInvSetup: Record "Inventory Setup";

        ltxtSubject: Text;
        ltxtBody: Text;
        AttachmentName: Text[500];
        lrecLocation: Record Location;
        lrecItem: Record Item;
    begin
        Clear(ToAddr);
        lrecInvSetup.Get;
        lrecInvSetup.TestField("Low Stock Notif. Email");
        if cuSendMail.ValidateEMailAdd(lrecInvSetup."Low Stock Notif. Email") then begin
            ltxtSubject := 'Low Stock Report';
            ToAddr.Add(lrecInvSetup."Low Stock Notif. Email");
            AttachmentName := 'Low Stock Report - ' + Format(Today) + '.pdf';
            cuSendMail.Rep50014_SendMail(ToAddr, ltxtSubject, ltxtBody, AttachmentName);
        end;
    end;
}

