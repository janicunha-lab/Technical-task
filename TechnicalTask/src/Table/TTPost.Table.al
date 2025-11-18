table 1000001 "TT Post"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "TT Post List";
    LookupPageId = "TT Post List";

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = CustomerContent;

        }
        field(2; UserID; Integer)
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;

        }
        field(3; Title; Text[100])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;

        }
        field(4; Body; Blob)
        {
            Caption = 'Body';
            DataClassification = CustomerContent;

        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
    }

}