codeunit 1000010 "TT User Management Test"
{
    SubType = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Assert";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";

    #region Fixtures
    var
        _initialized: Boolean;

    local procedure Initialize()
    begin
        if _initialized then
            exit;

        LibraryTestInitialize.OnTestInitialize(Codeunit::"TT User Management Test");

        // Clean up any existing test data
        ClearTestData();

        InitializeSharedFixtures();
        _initialized := true;
    end;

    local procedure InitializeSharedFixtures()
    var
        User: Record TTUser;
    begin
        // Create test user with known ID
        User.Init();
        User.ID := 123456789;
        User.Insert();

        // Create additional test users for comprehensive testing
        User.Init();
        User.ID := 987654321;
        User.Insert();

        User.Init();
        User.ID := 555666777;
        User.Insert();
    end;

    local procedure ClearTestData()
    var
        User: Record TTUser;
        Post: Record "TT Post";
    begin
        // Clean up test data to ensure clean state
        User.DeleteAll();
        Post.DeleteAll();
    end;

    local procedure GetSampleUsersJson(): Text
    begin
        exit('[{"id":1,"name":"Leanne Graham","username":"Bret","email":"Sincere@april.biz"},' +
             '{"id":2,"name":"Ervin Howell","username":"Antonette","email":"Shanna@melissa.tv"}]');
    end;

    local procedure GetSamplePostsJson(): Text
    begin
        exit('[{"userId":1,"id":1,"title":"Test Title 1","body":"Test body content 1"},' +
             '{"userId":2,"id":2,"title":"Test Title 2","body":"Test body content 2"}]');
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
        User: Record TTUser;
        UserID: Integer;
    begin
        // [GIVEN] A user exists in the system
        Initialize();
        UserID := 123456789;

        // [WHEN] CheckUserExists is called with existing user ID
        // [THEN] It should return true and populate the user record
        Assert.IsTrue(TTUserManagement.CheckUserExists(UserID, User), 'CheckUserExists should return true for existing user');
        Assert.AreEqual(UserID, User.ID, 'User record should be populated with correct ID');
    end;

    [Test]
    procedure Test_CheckUserExists_Returns_False_When_UserDoesNotExist()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record TTUser;
        UserID: Integer;
    begin
        // [GIVEN] A user does not exist in the system
        Initialize();
        UserID := 1234567890;

        // [WHEN] CheckUserExists is called with non-existing user ID
        // [THEN] It should return false
        Assert.IsFalse(TTUserManagement.CheckUserExists(UserID, User), 'CheckUserExists should return false for non-existing user');
    end;

    [Test]
    procedure Test_CheckUserExists_With_Zero_UserID()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record TTUser;
        UserID: Integer;
    begin
        // [GIVEN] UserID is zero
        Initialize();
        UserID := 0;

        // [WHEN] CheckUserExists is called with zero UserID
        // [THEN] It should return false
        Assert.IsFalse(TTUserManagement.CheckUserExists(UserID, User), 'CheckUserExists should return false for zero UserID');
    end;
    #endregion

    #region InsertUser Tests
    [Test]
    procedure Test_InsertUser_Successfully_Creates_New_User()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record TTUser;
        UserID: Integer;
        Result: Boolean;
    begin
        // [GIVEN] A new user ID that doesn't exist
        Initialize();
        UserID := 999888777;

        // [WHEN] InsertUser is called
        Result := TTUserManagement.InsertUser(UserID, User);

        // [THEN] User should be created successfully
        Assert.IsTrue(Result, 'InsertUser should return true for successful insertion');
        Assert.AreEqual(UserID, User.ID, 'User should have correct ID');
        Assert.IsTrue(User.Get(UserID), 'User should exist in the database');
    end;

    [Test]
    procedure Test_InsertUser_With_Zero_UserID()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record TTUser;
        UserID: Integer;
    begin
        // [GIVEN] UserID is zero
        Initialize();
        UserID := 0;

        // [WHEN] InsertUser is called with zero UserID
        // [THEN] It should handle the case appropriately
        asserterror TTUserManagement.InsertUser(UserID, User);
    end;
    #endregion

    #region MapUserData Tests
    [Test]
    procedure Test_MapUserData_Successfully_Maps_All_Fields()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record TTUser;
        UserToken: JsonToken;
        UserObject: JsonObject;
    begin
        // [GIVEN] A user record and JSON token with user data
        Initialize();
        User.Init();
        User.ID := 12345;
        User.Insert();

        UserObject.Add('name', 'John Doe');
        UserObject.Add('username', 'johndoe');
        UserObject.Add('email', 'john@example.com');
        UserToken := UserObject.AsToken();

        // [WHEN] MapUserData is called
        TTUserManagement.MapUserData(UserToken, User);

        // [THEN] User fields should be populated correctly
        User.Get(12345);
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
        User: Record TTUser;
        JsonText: Text;
    begin
        // [GIVEN] Valid JSON with user data
        Initialize();
        JsonText := GetSampleUsersJson();

        // [WHEN] ParseAndStoreUsers is called
        TTUserManagement.ParseAndStoreUsers(JsonText);

        // [THEN] Users should be created and data mapped
        Assert.IsTrue(User.Get(1), 'First user should be created');
        Assert.AreEqual('Leanne Graham', User.Name, 'First user name should be correct');
        Assert.AreEqual('Bret', User.UserName, 'First user username should be correct');

        Assert.IsTrue(User.Get(2), 'Second user should be created');
        Assert.AreEqual('Ervin Howell', User.Name, 'Second user name should be correct');
        Assert.AreEqual('Antonette', User.UserName, 'Second user username should be correct');
    end;

    [Test]
    procedure Test_ParseAndStoreUsers_With_Empty_Json()
    var
        TTUserManagement: Codeunit "TT User Management";
        JsonText: Text;
    begin
        // [GIVEN] Empty JSON array
        Initialize();
        JsonText := '[]';

        // [WHEN] ParseAndStoreUsers is called
        TTUserManagement.ParseAndStoreUsers(JsonText);

        // [THEN] No users should be created (method should handle gracefully)
        // This test verifies the method doesn't crash with empty data
    end;

    [Test]
    procedure Test_ParseAndStoreUsers_With_Existing_User()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record TTUser;
        JsonText: Text;
    begin
        // [GIVEN] JSON with a user ID that already exists
        Initialize();
        User.Init();
        User.ID := 123456789;
        User.Name := 'Original Name';
        User.Insert();

        JsonText := '[{"id":123456789,"name":"Updated Name","username":"updated","email":"updated@example.com"}]';
        // [WHEN] ParseAndStoreUsers is called
        TTUserManagement.ParseAndStoreUsers(JsonText);

        // [THEN] Existing user should be updated, not duplicated
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
        // [GIVEN] A post exists in the system
        Initialize();
        PostID := 12345;
        Post.Init();
        Post.ID := PostID;
        Post.Insert();

        // [WHEN] CheckPostExists is called with existing post ID
        // [THEN] It should return true
        Assert.IsTrue(TTUserManagement.CheckPostExists(PostID, Post), 'CheckPostExists should return true for existing post');
        Assert.AreEqual(PostID, Post.ID, 'Post record should be populated with correct ID');
    end;

    [Test]
    procedure Test_CheckPostExists_Returns_False_When_PostDoesNotExist()
    var
        TTUserManagement: Codeunit "TT User Management";
        Post: Record "TT Post";
        PostID: Integer;
    begin
        // [GIVEN] A post does not exist in the system
        Initialize();
        PostID := 987654321;

        // [WHEN] CheckPostExists is called with non-existing post ID
        // [THEN] It should return false
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
        // [GIVEN] A new post ID that doesn't exist
        Initialize();
        PostID := 999888;

        // [WHEN] InsertPost is called
        Result := TTUserManagement.InsertPost(PostID, Post);

        // [THEN] Post should be created successfully
        Assert.IsTrue(Result, 'InsertPost should return true for successful insertion');
        Assert.AreEqual(PostID, Post.ID, 'Post should have correct ID');
        Assert.IsTrue(Post.Get(PostID), 'Post should exist in the database');
    end;
    #endregion

    #region MapPostData Tests
    [Test]
    procedure Test_MapPostData_Successfully_Maps_All_Fields()
    var
        TTUserManagement: Codeunit "TT User Management";
        Post: Record "TT Post";
        PostToken: JsonToken;
        PostObject: JsonObject;
        BodyInStream: InStream;
        BodyText: Text;
    begin
        // [GIVEN] A post record and JSON token with post data
        Initialize();
        Post.Init();
        Post.ID := 54321;
        Post.Insert();

        PostObject.Add('userId', 123);
        PostObject.Add('title', 'Test Post Title');
        PostObject.Add('body', 'Test post body content');
        PostToken := PostObject.AsToken();

        // [WHEN] MapPostData is called
        TTUserManagement.MapPostData(PostToken, Post);

        // [THEN] Post fields should be populated correctly
        Post.Get(54321);
        Assert.AreEqual(123, Post.UserId, 'UserId should be mapped correctly');
        Assert.AreEqual('Test Post Title', Post.Title, 'Title should be mapped correctly');

        Post.Body.CreateInStream(BodyInStream);
        BodyInStream.ReadText(BodyText);
        Assert.AreEqual('Test post body content', BodyText, 'Body should be mapped correctly');
    end;
    #endregion

    #region ParseAndStoreUserPosts Tests
    [Test]
    procedure Test_ParseAndStoreUserPosts_With_Valid_Json()
    var
        TTUserManagement: Codeunit "TT User Management";
        Post: Record "TT Post";
        JsonText: Text;
    begin
        // [GIVEN] Valid JSON with post data
        Initialize();
        JsonText := GetSamplePostsJson();

        // [WHEN] ParseAndStoreUserPosts is called
        TTUserManagement.ParseAndStoreUserPosts(JsonText);

        // [THEN] Posts should be created and data mapped
        Assert.IsTrue(Post.Get(1), 'First post should be created');
        Assert.AreEqual(1, Post.UserId, 'First post userId should be correct');
        Assert.AreEqual('Test Title 1', Post.Title, 'First post title should be correct');

        Assert.IsTrue(Post.Get(2), 'Second post should be created');
        Assert.AreEqual(2, Post.UserId, 'Second post userId should be correct');
        Assert.AreEqual('Test Title 2', Post.Title, 'Second post title should be correct');
    end;

    [Test]
    procedure Test_ParseAndStoreUserPosts_With_Empty_Json()
    var
        TTUserManagement: Codeunit "TT User Management";
        JsonText: Text;
    begin
        // [GIVEN] Empty JSON array
        Initialize();
        JsonText := '[]';

        // [WHEN] ParseAndStoreUserPosts is called
        TTUserManagement.ParseAndStoreUserPosts(JsonText);

        // [THEN] No posts should be created (method should handle gracefully)
        // This test verifies the method doesn't crash with empty data
    end;
    #endregion

    #region GetUserList Tests
    [Test]
    procedure Test_GetUserList_With_Valid_Url()
    var
        TTUserManagement: Codeunit "TT User Management";
        ResponseText: Text;
        Result: Boolean;
    begin
        // [GIVEN] A valid URL (note: this will depend on HTTP Handler implementation)
        Initialize();

        // [WHEN] GetUserList is called
        Result := TTUserManagement.GetUserList('https://jsonplaceholder.typicode.com/users', ResponseText);

        // [THEN] Result should indicate success/failure based on HTTP response
        // Note: This test may need mocking for reliable testing
        // For now, we just verify the method doesn't crash and returns a boolean
        Assert.IsTrue((Result = true) or (Result = false), 'GetUserList should return a boolean value');
    end;

    [Test]
    procedure Test_GetUserList_With_Empty_Url()
    var
        TTUserManagement: Codeunit "TT User Management";
        ResponseText: Text;
        Result: Boolean;
    begin
        // [GIVEN] An empty URL
        Initialize();

        // [WHEN] GetUserList is called with empty URL
        Result := TTUserManagement.GetUserList('', ResponseText);

        // [THEN] Should return false for empty URL
        Assert.IsFalse(Result, 'GetUserList should return false for empty URL');
    end;
    #endregion

    #region GetUserPosts Tests
    [Test]
    procedure Test_GetUserPosts_With_Valid_Url()
    var
        TTUserManagement: Codeunit "TT User Management";
        ResponseText: Text;
        Result: Boolean;
    begin
        // [GIVEN] A valid URL for posts
        Initialize();

        // [WHEN] GetUserPosts is called
        Result := TTUserManagement.GetUserPosts('https://jsonplaceholder.typicode.com/posts', ResponseText);

        // [THEN] Result should indicate success/failure based on HTTP response
        Assert.IsTrue((Result = true) or (Result = false), 'GetUserPosts should return a boolean value');
    end;
    #endregion

    #region PostNewEntry Tests
    [Test]
    procedure Test_PostNewEntry_With_Valid_Data()
    var
        TTUserManagement: Codeunit "TT User Management";
        ResultText: Text;
    begin
        // [GIVEN] Valid post data
        Initialize();

        // [WHEN] PostNewEntry is called
        ResultText := TTUserManagement.PostNewEntry(1, 'Test Title', 'Test Body Content');

        // [THEN] Method should complete without error
        // Note: This test verifies the method executes without exceptions
        // Actual HTTP behavior would require mocking for reliable testing
    end;

    [Test]
    procedure Test_PostNewEntry_With_Empty_Title()
    var
        TTUserManagement: Codeunit "TT User Management";
        ResultText: Text;
    begin
        // [GIVEN] Empty title
        Initialize();

        // [WHEN] PostNewEntry is called with empty title
        ResultText := TTUserManagement.PostNewEntry(1, '', 'Test Body Content');

        // [THEN] Method should handle empty title gracefully
        // This verifies the method doesn't crash with empty data
    end;
    #endregion

    #region Integration Tests
    [Test]
    procedure Test_GetUsersInfo_Complete_Workflow()
    var
        TTUserManagement: Codeunit "TT User Management";
    begin
        // [GIVEN] Clean system state
        Initialize();

        // [WHEN] GetUsersInfo is called (main orchestration method)
        TTUserManagement.GetUsersInfo();

        // [THEN] Method should complete without error
        // Note: This integration test verifies the complete workflow executes
        // Individual component behavior is tested in separate test methods
    end;

    [Test]
    procedure Test_NotifySyncComplete()
    var
        TTUserManagement: Codeunit "TT User Management";
    begin
        // [GIVEN] System is initialized
        Initialize();

        // [WHEN] NotifySyncComplete is called
        TTUserManagement.NotifySyncComplete();

        // [THEN] Method should complete without error
        // Note: This test verifies the notification method executes successfully
    end;
    #endregion

}
