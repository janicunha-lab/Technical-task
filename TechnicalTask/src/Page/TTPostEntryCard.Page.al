page 1000003 "TT Post Entry Card"
{
    Caption = 'New Post';
    PageType = Card;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(PostEntryGroup)
            {
                ShowCaption = false;
                field(UserID; UserID)
                {
                }
                field(Title; Title)
                {
                }
                field(Body; Body)
                {
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                Caption = 'Post';
                Promoted = true;
                PromotedCategory = Process;
                Image = Post;

                trigger OnAction()
                var
                    TTUserManagement: Codeunit "TT User Management";
                begin
                    TTUserManagement.PostNewEntry(UserID, Title, Body);
                end;
            }
        }
    }

    var
        UserID: Integer;
        Title: Text[100];
        Body: Text;
}