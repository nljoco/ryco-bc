table 50000 "BOM Instruction"
{

    fields
    {
        field(10; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; Description; Text[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                UpdateDescription;   // nj20170131
            end;
        }
        field(30; Dryer; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",D4,"D25 D26",OK32UV,OK32LED;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    local procedure UpdateDescription()
    var
        lrecAssemblyLine: Record "Assembly Line";
        lrecBOMComponent: Record "BOM Component";
    begin
        // nj20170131 - Start
        lrecAssemblyLine.Reset;
        lrecAssemblyLine.SetRange("Instruction Code", Code);
        if lrecAssemblyLine.FindSet then
            repeat
                lrecAssemblyLine.Description := Description;
                lrecAssemblyLine.Modify;
            until lrecAssemblyLine.Next = 0;

        lrecBOMComponent.Reset;
        lrecBOMComponent.SetRange("Instruction Code", Code);
        if lrecBOMComponent.FindSet then
            repeat
                lrecBOMComponent.Description := Description;
                lrecBOMComponent.Modify;
            until lrecBOMComponent.Next = 0;
        // nj20170131 - End
    end;
}

