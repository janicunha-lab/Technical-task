page 1000000 "TT User List"
{
    PageType = List;
    Caption = 'User List';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = TTUser;
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

    actions
    {
        area(Processing)
        {
            action(GetUsers)
            {
                Image = Users;
                Caption = 'Get Users';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    UserManagement: Codeunit "TT User Management";
                begin
                    UserManagement.GetUsersInfo();
                end;
            }
        }
    }
}