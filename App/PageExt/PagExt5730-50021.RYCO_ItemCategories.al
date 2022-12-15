pageextension 50021 "Ryc Item Categories" extends "Item Categories"
{
    /*
SMK2018.04.09 SLUPG - merged the following:
-------------------------------------------
  FH20161031
    - New Fields Added: Labour %,Labour Amount
      and New Action "Update Labour Cost" to Update them In Item.

SMK2018.04.09 SLUPG:
--------------------
  moved control 1000000001, 1000000002 after control 1000000000
  (in NAV2016 they were after control# 14 which no longer exists in NAV2018)
    */
    layout
    {
        addafter(Description)
        {
            field(Ink; Rec.Ink)
            {
                ApplicationArea = All;
            }
            field("Labour%"; Rec."Labour%")
            {
                ApplicationArea = All;
            }
            field("Labour$"; Rec."Labour$")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action("Ryc Update Labor Cost")
            {
                Caption = 'Update Labor Cost';
                ApplicationArea = All;
                Image = Process;

                trigger OnAction()
                var
                    lrecItem: Record Item;
                begin
                    //FH20161031
                    CurrPage.SETSELECTIONFILTER(Rec);
                    IF Rec.FindSet() then begin
                        REPEAT
                            lrecItem.RESET;
                            lrecItem.SETRANGE("Item Category Code", Rec.Code);
                            lrecItem.CALCFIELDS("Assembly BOM");
                            lrecItem.SETRANGE("Assembly BOM", TRUE);
                            IF lrecItem.FINDSET THEN BEGIN
                                REPEAT
                                    lrecItem.VALIDATE("Labour%", Rec."Labour%");
                                    lrecItem.VALIDATE("Labour$", Rec."Labour$");
                                    lrecItem.MODIFY(TRUE);
                                UNTIL lrecItem.NEXT = 0;
                            END;
                        UNTIL Rec.NEXT = 0;
                    END;
                    Rec.RESET;
                    MESSAGE('Item Labour % and Labour $ Updated');
                end;
            }
        }
    }

    var

}