codeunit 1000010 "TT User Management Test"
{
    SubType = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

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
        User: Record TTUser;
    begin
        User.ID := 123456789;
        User.Insert();

    end;
    #endregion

    [Test]
    procedure Test_CheckUserExists_Returns_True_When_UserExists()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record TTUser;
        UserID: Integer;
    begin
        Initialize();
        UserID := 123456789;
        Assert.IsTrue((TTUserManagement.CheckUserExists(UserID, User)), 'CheckUserExists should return true for existing user');
    end;

    [Test]
    procedure Test_CheckUserExists_Returns_False_When_UserDoesNotExist()
    var
        TTUserManagement: Codeunit "TT User Management";
        User: Record TTUser;
        UserID: Integer;
    begin
        Initialize();
        UserID := 1234567890;
        Assert.IsFalse((TTUserManagement.CheckUserExists(UserID, User)), 'CheckUserExists should return false for non-existing user');
    end;

}
