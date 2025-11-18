page 1000001 "TT Post List"
{
    PageType = List;
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
                field(ID; Rec.ID)
                {
                }
                field(UserID; Rec.UserID)
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
        InS: InStream;

    trigger OnAfterGetRecord()
    begin
        BodyText := '';

        if not Rec.Body.HasValue() then
            exit;

        Rec.CalcFields(Body);
        Rec.Body.CreateInStream(InS);
        InS.Read(BodyText);
    end;
}