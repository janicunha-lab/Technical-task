page 1000004 "TT User Card"
{
    PageType = Card;
    Caption = 'User Card';
    ApplicationArea = All;
    SourceTable = "TT User";
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(ID; Rec.Id)
                {
                }
                field(Name; Rec.Name)
                {
                }
                field(UserName; Rec."UserName")
                {
                }
                field(Email; Rec."Email")
                {
                }
                field(Posts; Rec.Posts)
                {
                }

            }
        }
    }
}