page 1000001 "TT Post List"
{
    PageType = List;
    Caption = 'Post List';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TT Post";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ID; Rec.Id)
                {
                }
                field(UserId; Rec.UserId)
                {
                }
                field(Title; Rec.Title)
                {
                }
                field(Body; BodyText)
                {
                    Caption = 'Body';
                    Style = Standard;
                    StyleExpr = true;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PostEntry)
            {
                Promoted = true;
                PromotedCategory = Process;
                Image = PostDocument;
                Caption = 'Post Entry';
                RunObject = page "TT Post Entry Card";
            }
        }
    }

    var
        BodyText: Text;

    trigger OnAfterGetRecord()
    var
        TTUserManagement: Codeunit "TT User Management";
    begin
        BodyText := TTUserManagement.GetPostBodyText(Rec);
    end;
}