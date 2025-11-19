codeunit 1000000 "TT User Management"
{
    procedure GetUsersInfo()
    var
        UserList: Text;
        Notification: Notification;
    begin
        if not GetUserList('https://jsonplaceholder.typicode.com/users', UserList) then
            exit;

        ParseAndStoreUsers(UserList);
        GetUserPosts();
        NotifySyncComplete();
    end;

    procedure GetUserList(Url: Text; var ResponseText: Text): Boolean
    var
        HttpHandler: Codeunit "TT HTTP Handler";
    begin
        ResponseText := HttpHandler.Get(Url);
        exit(ResponseText <> '');
    end;

    procedure ParseAndStoreUsers(ResponseText: Text)
    var
        UsersArray: JsonArray;
        UserToken: JsonToken;
        JToken: JsonToken;
        JTokenUserId: Integer;
        User: Record TTUser;
    begin
        UsersArray.ReadFrom(ResponseText);
        foreach UserToken in UsersArray do begin

            if not UserToken.AsObject().Get('id', JToken) then
                continue;
            JTokenUserId := JToken.AsValue().AsInteger();

            if not CheckUserExists(JTokenUserId, User) then
                InsertUser(JTokenUserId, User);

            MapUserData(UserToken, User);
        end;
    end;

    procedure CheckUserExists(UserId: Integer; var User: Record TTUser): Boolean
    begin
        exit(User.Get(UserId));
    end;

    procedure InsertUser(UserId: Integer; var User: Record TTUser): Boolean
    begin
        User.Init();
        User.Validate(ID, UserId);
        User.Insert(true);
        exit(true);
    end;

    procedure MapUserData(UserToken: JsonToken; var User: Record TTUser)
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

    procedure GetUserPosts()
    var
        UserPosts: Text;
    begin
        if not GetUserPosts('https://jsonplaceholder.typicode.com/posts', UserPosts) then
            exit;

        ParseAndStoreUserPosts(UserPosts);
    end;

    procedure GetUserPosts(Url: Text; var ResponseText: Text): Boolean
    var
        HttpHandler: Codeunit "TT HTTP Handler";
    begin
        ResponseText := HttpHandler.Get(Url);
        exit(ResponseText <> '');
    end;

    procedure ParseAndStoreUserPosts(ResponseText: Text)
    var
        PostsArray: JsonArray;
        PostToken: JsonToken;
        JToken: JsonToken;
        JTokenPostID: Integer;
        Post: Record "TT Post";
    begin
        PostsArray.ReadFrom(ResponseText);
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

    procedure InsertPost(PostID: Integer; var Post: Record "TT Post"): Boolean
    begin
        Post.Init();
        Post.Validate(ID, PostID);
        Post.Insert(true);
        exit(true);
    end;

    procedure MapPostData(PostToken: JsonToken; var Post: Record "TT Post")
    var
        JToken: JsonToken;
        OutS: OutStream;
    begin
        if PostToken.AsObject().Get('UserId', JToken) then
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
        JsonText: Text;
        ResultText: Text;
        SuccessMsg: Label 'New entry created successfully!\ %1';
    begin
        Json.Add('title', Title);
        Json.Add('body', Body);
        Json.Add('UserId', UserId);
        Json.WriteTo(JsonText);

        ResultText := HttpHandler.Post('https://jsonplaceholder.typicode.com/posts', JsonText);
        if ResultText = '' then
            exit(false);

        Message(SuccessMsg, ResultText);
        exit(true);
    end;

}
