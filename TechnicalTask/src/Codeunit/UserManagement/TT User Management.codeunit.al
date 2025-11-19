codeunit 1000000 "TT User Management"
{
    Access = Internal;

    var
        JsonParsingErr: Label 'Failed to parse JSON response.';
        EmptyResponseErr: Label 'Received empty response from server.';
        UsersApiUrl: Label 'https://jsonplaceholder.typicode.com/users', Locked = true;
        PostsApiUrl: Label 'https://jsonplaceholder.typicode.com/posts', Locked = true;

    procedure GetUsersInfo()
    var
        UserList: Text;
    begin
        if not GetUserList(UsersApiUrl, UserList) then
            exit;

        ParseAndStoreUsers(UserList);
        GetAllUserPosts();
        NotifySyncComplete();
    end;

    procedure GetUserList(Url: Text; var ResponseText: Text): Boolean
    var
        HttpHandler: Codeunit "TT HTTP Handler";
    begin
        ResponseText := HttpHandler.Get(Url);
        if ResponseText = '' then begin
            Error(EmptyResponseErr);
            exit(false);
        end;
        exit(true);
    end;

    procedure ParseAndStoreUsers(ResponseText: Text)
    var
        User: Record "TT User";
        JTokenUserId: Integer;
        UsersArray: JsonArray;
        JToken: JsonToken;
        UserToken: JsonToken;
    begin
        if not UsersArray.ReadFrom(ResponseText) then
            Error(JsonParsingErr);

        foreach UserToken in UsersArray do begin

            if not UserToken.AsObject().Get('id', JToken) then
                continue;
            JTokenUserId := JToken.AsValue().AsInteger();

            if not CheckUserExists(JTokenUserId, User) then
                InsertUser(JTokenUserId, User);

            MapUserData(UserToken, User);
        end;
    end;

    procedure CheckUserExists(UserId: Integer; var User: Record "TT User"): Boolean
    begin
        exit(User.Get(UserId));
    end;

    procedure InsertUser(UserId: Integer; var User: Record "TT User"): Boolean
    begin
        User.Init();
        User.Validate(ID, UserId);
        User.Insert(true);
        exit(true);
    end;

    procedure MapUserData(UserToken: JsonToken; var User: Record "TT User")
    var
        JToken: JsonToken;
    begin
        if UserToken.AsObject().Get('name', JToken) then
            User.Validate(Name, JToken.AsValue().AsText());

        if UserToken.AsObject().Get('username', JToken) then
            User.Validate(UserName, JToken.AsValue().AsText());

        if UserToken.AsObject().Get('email', JToken) then
            User.Validate(Email, JToken.AsValue().AsText());

        User.Modify(true);
    end;

    procedure GetAllUserPosts()
    var
        UserPosts: Text;
    begin
        if not GetUserPosts(PostsApiUrl, UserPosts) then
            exit;

        ParseAndStoreUserPosts(UserPosts);
    end;

    procedure GetUserPosts(Url: Text; var ResponseText: Text): Boolean
    var
        HttpHandler: Codeunit "TT HTTP Handler";
    begin
        ResponseText := HttpHandler.Get(Url);
        if ResponseText = '' then begin
            Error(EmptyResponseErr);
            exit(false);
        end;
        exit(true);
    end;

    procedure ParseAndStoreUserPosts(ResponseText: Text)
    var
        Post: Record "TT Post";
        JTokenPostID: Integer;
        PostsArray: JsonArray;
        JToken: JsonToken;
        PostToken: JsonToken;
    begin
        if not PostsArray.ReadFrom(ResponseText) then
            Error(JsonParsingErr);

        foreach PostToken in PostsArray do begin

            if not PostToken.AsObject().Get('id', JToken) then
                continue;
            JTokenPostID := JToken.AsValue().AsInteger();

            if not CheckPostExists(JTokenPostID, Post) then
                InsertPost(JTokenPostID, Post);

            MapPostData(PostToken, Post);
        end;
    end;

    procedure CheckPostExists(PostID: Integer; var Post: Record "TT Post"): Boolean
    begin
        exit(Post.Get(PostID));
    end;

    procedure InsertPost(PostID: Integer; var Post: Record "TT Post")
    begin
        Post.Init();
        Post.Validate(ID, PostID);
        Post.Insert(true);
    end;

    procedure MapPostData(PostToken: JsonToken; var Post: Record "TT Post")
    var
        JToken: JsonToken;
        OutS: OutStream;
    begin
        if PostToken.AsObject().Get('userId', JToken) then
            Post.Validate(UserId, JToken.AsValue().AsInteger());

        if PostToken.AsObject().Get('title', JToken) then
            Post.Validate(Title, JToken.AsValue().AsText());

        if PostToken.AsObject().Get('body', JToken) then begin
            Post.Body.CreateOutStream(OutS);
            OutS.Write(JToken.AsValue().AsText());
        end;

        Post.Modify(true);
    end;

    procedure NotifySyncComplete()
    var
        Notification: Notification;
        NotificationMsg: Label 'User data synchronization completed successfully.';
    begin
        Notification.Message(NotificationMsg);
        Notification.Send();
    end;

    procedure PostNewEntry(UserId: Integer; Title: Text; Body: Text): Boolean
    var
        HttpHandler: Codeunit "TT HTTP Handler";
        Json: JsonObject;
        SuccessMsg: Label 'New entry created successfully!\ %1';
        JsonText: Text;
        ResultText: Text;
    begin
        CheckEmptyFields(UserId, Title, Body);

        Json.Add('title', Title);
        Json.Add('body', Body);
        Json.Add('userId', UserId);
        Json.WriteTo(JsonText);

        ResultText := HttpHandler.Post(PostsApiUrl, JsonText);
        if ResultText = '' then
            exit(false);

        Message(SuccessMsg, ResultText);
        exit(true);
    end;

    procedure CheckEmptyFields(UserId: Integer; Title: Text; Body: Text)
    var
        InvalidUserIdErr: Label 'User ID must be a positive integer.';
        EmptyTitleErr: Label 'Title cannot be empty.';
        EmptyBodyErr: Label 'Body cannot be empty.';
    begin
        if UserId <= 0 then
            Error(InvalidUserIdErr);

        if Title = '' then
            Error(EmptyTitleErr);

        if Body = '' then
            Error(EmptyBodyErr);
    end;

    procedure GetPostBodyText(Post: Record "TT Post"): Text
    var
        InS: InStream;
        BodyText: Text;
    begin
        BodyText := '';

        if not Post.Body.HasValue() then
            exit(BodyText);

        Post.CalcFields(Body);
        Post.Body.CreateInStream(InS);
        InS.Read(BodyText);
        exit(BodyText);
    end;

    [EventSubscriber(ObjectType::Table, Database::"TT User", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeleteUser(var Rec: Record "TT User"; RunTrigger: Boolean)
    var
        Post: Record "TT Post";
    begin
        Post.SetRange(UserId, Rec.Id);
        if not Post.IsEmpty() then
            Post.DeleteAll();
    end;

}
