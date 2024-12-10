table 50001 "Build Quantity"
{

    fields
    {
        field(10; "Build Conversion"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Number of Cans"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Build Quantity"; Decimal)
        {
            Caption = 'Build Quantity OK32R';
            DataClassification = ToBeClassified;
        }
        field(40; "Build Quantity 2"; Decimal)
        {
            Caption = 'Build Quantity OK32X';
            DataClassification = ToBeClassified;
            Description = 'FH20160929';
        }
        field(50; "Build Quantity OK32LT"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'FH20161107';
        }
        field(51; "Build Quantity OK32UV"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'ID2173';
        }
        field(52; "Build Quantity OK32LED"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'ID2173';
        }
    }

    keys
    {
        key(Key1; "Build Conversion", "Number of Cans")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

