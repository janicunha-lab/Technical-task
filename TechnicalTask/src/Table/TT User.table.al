table 1000000 "TT User"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

        }
        field(3; UserName; Text[100])
        {
            Caption = 'User Name';
            DataClassification = CustomerContent;

        }
        field(4; Email; Text[100])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;

        }
        field(5; Posts; Integer)
        {
            Caption = 'Posts';
            FieldClass = FlowField;
            CalcFormula = Count("TT Post" where(UserId = FIELD(ID)));
            Editable = false;

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