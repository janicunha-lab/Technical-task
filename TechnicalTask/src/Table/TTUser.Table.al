table 1000000 TTUser
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'ID';
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
            CalcFormula = Count("TT Post" where(UserID = FIELD(ID)));
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

    trigger OnDelete()
    var
        Post: Record "TT Post";
    begin
        Post.SetRange(UserID, Rec.ID);
        if not Post.IsEmpty() then
            Post.DeleteAll();
    end;

}