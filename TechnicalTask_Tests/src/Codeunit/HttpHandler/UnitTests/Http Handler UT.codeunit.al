codeunit 1000011 "TT Http Handler Test"
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
    begin
    end;

    #endregion
}