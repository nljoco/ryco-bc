tableextension 50000 "RYCO Location" extends Location
{
    /*
    smk2018.04.17 slupg: auto-merge the following: 
        ID623, RPD, 2017.02.22
        - Add "Low Stock Notification" (bool)
    */

    fields
    {
        field(50000; "Low Stock Notification"; Boolean)
        {
            //smk2018.04.17 ID623
            DataClassification = ToBeClassified;
            Caption = 'Low Stock Notification';
            Description = 'ID623';
        }
    }

}