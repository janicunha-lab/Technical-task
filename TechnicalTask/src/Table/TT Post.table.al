table 1000001 "TT Post"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "TT Post List";
    LookupPageId = "TT Post List";

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;

        }
        field(2; UserId; Integer)
        {
            Caption = 'User Id';
            DataClassification = CustomerContent;
            TableRelation = "TT User".Id;

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