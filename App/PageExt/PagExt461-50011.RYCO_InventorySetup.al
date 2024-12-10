pageextension 50011 "Ryc Inventory Setup" extends "Inventory Setup"
{
    /*
    smk2018.04.17 slupg: auto-merge the following
    ID623, RPD, 2017.02.22
    - Add "Low Stock Notif. Email" to General tab
    */
    layout
    {
        addafter("Prevent Negative Inventory")
        {
            field("Low Stock Notif. Email"; Rec."Low Stock Notif. Email")
            {
                ApplicationArea = All;
            }
        }

        modify("Variant Mandatory if Exists")
        {
            Visible = false;
        }
        modify("Skip Prompt To Create Item")
        {
            Visible = false;
        }
        modify("Copy Item Descr. to Entries")
        {
            Visible = false;
        }

        modify("Direct transfer posting")
        {
            visible = false;
        }
        modify("Posted Direct Trans. Nos.")
        {
            Visible = false;
        }
        modify("Phys. Invt. Order Nos.")
        {
            visible = false;
        }
        modify("Posted Phys. Invt. Order Nos.")
        {
            Visible = false;
        }
        modify("Invt. Receipt Nos.")
        {
            Visible = false;
        }
        modify("Posted Invt. Receipt Nos.")
        {
            Visible = false;
        }
        modify("Invt. Shipment Nos.")
        {
            Visible = false;
        }
        modify("Posted Invt. Shipment Nos.")
        {
            Visible = false;
        }
    }

    actions
    {
    }

    var

}