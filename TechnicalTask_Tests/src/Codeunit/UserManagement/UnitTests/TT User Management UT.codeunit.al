codeunit 1000010 "TT User Management Test"
{
    SubType = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";

    #region Fixtures
    var
        _initialized: Boolean;

    local procedure Initialize()
    begin
        if _initialized then
            exit;

        InitializeSharedFixtures();
        _initialized := true;
    end;

    local procedure InitializeSharedFixtures()
    var
        User: Record "TT User";
        Post: Record "TT Post";
    begin
        User.Init();
        User.Id := 123456789;
        User.Insert();

        Post.Init();
        Post.Id := 12345;
        Post.Insert();
    end;

    local procedure GetSampleUsersJson(): Text
    begin
        exit('[{"id":1111,"name":"Leanne Graham","username":"Bret","email":"Sincere@april.biz"},' +
             '{"id":2222,"name":"Ervin Howell","username":"Antonette","email":"Shanna@melissa.tv"}]');
    end;

    local procedure GetSamplePostsJson(): Text
    begin
        exit('[{"UserId":1111,"id":1111,"title":"Test Title 1","body":"Test body content 1"},' +
             '{"UserId":2222,"id":2222,"title":"Test Title 2","body":"Test body content 2"}]');
    end;

    local procedure GetSingleUserJson(): Text
    begin
        exit('{"id":100,"name":"Test User","username":"testuser","email":"test@example.com"}');
    end;

    local procedure GetInvalidJson(): Text
    begin
        exit('{"invalid": json structure');
    end;
    #endregion

    #region CheckUserExists Tests
    [Test]
    procedure Test_CheckUserExists_Returns_True_When_UserExists()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record "TT User";
        UserId: Integer;
    begin
        Initialize();
        UserId := 123456789;
        Assert.IsTrue(TTUserManagement.CheckUserExists(UserId, User), 'CheckUserExists should return true for existing user');
    end;

    [Test]
    procedure Test_CheckUserExists_Returns_False_When_UserDoesNotExist()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record "TT User";
        UserId: Integer;
    begin
        Initialize();
        UserId := 1234567890;
        Assert.IsFalse(TTUserManagement.CheckUserExists(UserId, User), 'CheckUserExists should return false for non-existing user');
    end;
    #endregion

    #region InsertUser Tests
    [Test]
    procedure Test_InsertUser_Successfully_Creates_New_User()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record "TT User";
        UserId: Integer;
        Result: Boolean;
    begin
        Initialize();
        UserId := 999888777;

        Result := TTUserManagement.InsertUser(UserId, User);

        Assert.IsTrue(Result, 'InsertUser should return true for successful insertion');
        Assert.AreEqual(UserId, UserId, 'User should have correct ID');
        Assert.IsTrue(User.Get(UserId), 'User should exist in the database');
    end;
    #endregion

    #region MapUserData Tests
    [Test]
    procedure Test_MapUserData_Successfully_Maps_All_Fields()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record "TT User";
        UserToken: JsonToken;
        UserObject: JsonObject;
    begin
        Initialize();
        User.Id := 123456789;
        UserObject.Add('name', 'John Doe');
        UserObject.Add('username', 'johndoe');
        UserObject.Add('email', 'john@example.com');
        UserToken := UserObject.AsToken();

        TTUserManagement.MapUserData(UserToken, User);

        Assert.AreEqual('John Doe', User.Name, 'Name should be mapped correctly');
        Assert.AreEqual('johndoe', User.UserName, 'Username should be mapped correctly');
        Assert.AreEqual('john@example.com', User.Email, 'Email should be mapped correctly');
    end;
    #endregion

    #region ParseAndStoreUsers Tests
    [Test]
    procedure Test_ParseAndStoreUsers_With_Valid_Json()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record "TT User";
        JsonText: Text;
    begin
        Initialize();
        JsonText := GetSampleUsersJson();

        TTUserManagement.ParseAndStoreUsers(JsonText);

        Assert.IsTrue(User.Get(1111), 'First user should be created');
        Assert.AreEqual('Leanne Graham', User.Name, 'First user name should be correct');
        Assert.AreEqual('Bret', User.UserName, 'First user username should be correct');
        Assert.IsTrue(User.Get(2222), 'Second user should be created');
        Assert.AreEqual('Ervin Howell', User.Name, 'Second user name should be correct');
        Assert.AreEqual('Antonette', User.UserName, 'Second user username should be correct');
    end;

    [Test]
    procedure Test_ParseAndStoreUsers_With_Existing_User()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record "TT User";
        JsonText: Text;
    begin
        Initialize();
        User.Id := 123456789;

        JsonText := '[{"id":123456789,"name":"Updated Name","username":"updated","email":"updated@example.com"}]';
        TTUserManagement.ParseAndStoreUsers(JsonText);

        User.Get(123456789);
        Assert.AreEqual('Updated Name', User.Name, 'Existing user should be updated');
    end;
    #endregion

    #region CheckPostExists Tests
    [Test]
    procedure Test_CheckPostExists_Returns_True_When_PostExists()
    var
        TTUserManagement: Codeunit "TT User Management";
        Post: Record "TT Post";
        PostID: Integer;
    begin
        Initialize();
        PostID := 12345;
        Assert.IsTrue(TTUserManagement.CheckPostExists(PostID, Post), 'CheckPostExists should return true for existing post');
    end;

    [Test]
    procedure Test_CheckPostExists_Returns_False_When_PostDoesNotExist()
    var
        TTUserManagement: Codeunit "TT User Management";
        Post: Record "TT Post";
        PostID: Integer;
    begin
        Initialize();
        PostID := 987654321;
        Assert.IsFalse(TTUserManagement.CheckPostExists(PostID, Post), 'CheckPostExists should return false for non-existing post');
    end;
    #endregion

    #region InsertPost Tests
    [Test]
    procedure Test_InsertPost_Successfully_Creates_New_Post()
    var
        TTUserManagement: Codeunit "TT User Management";
        Post: Record "TT Post";
        PostID: Integer;
        Result: Boolean;
    begin
        Initialize();
        PostID := 999888;

        Result := TTUserManagement.InsertPost(PostID, Post);

        Assert.IsTrue(Result, 'InsertPost should return true for successful insertion');
    end;
    #endregion

    #region PostNewEntry Tests
    [Test]
    procedure Test_PostNewEntry_With_Negative_UserID_Returns_Error()
    var
        TTUserManagement: Codeunit "TT User Management";
    begin
        Initialize();
        asserterror TTUserManagement.PostNewEntry(-1, 'Sample Title', 'Sample Body');
    end;

    [Test]
    procedure Test_PostNewEntry_With_Empty_Title_Returns_Error()
    var
        TTUserManagement: Codeunit "TT User Management";
    begin
        Initialize();
        asserterror TTUserManagement.PostNewEntry(1, '', 'Sample Body');
    end;

    [Test]
    procedure Test_PostNewEntry_With_Empty_Body_Returns_Error()
    var
        TTUserManagement: Codeunit "TT User Management";
    begin
        Initialize();
        asserterror TTUserManagement.PostNewEntry(1, 'Sample Title', '');
    end;
    #endregion
}
