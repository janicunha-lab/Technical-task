codeunit 1000011 "TT Http Handler UT"
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
    begin
    end;

    #endregion

    #region HttpClient Tests
    [Test]
    procedure Get_ReturnsResponseBody_OnSuccess()
    var
        HttpHandler: Codeunit "TT Http Handler";
        MockClient: Codeunit "TT Http Handler Mock";
        Result: Text;
    begin
        MockClient.SetResponse(true, 200, '{"value": 42}');

        Result := HttpHandler.Get('http://test', MockClient);

        Assert.AreEqual(200, MockClient.GetLastStatusCode(), 'HTTP status code should be 200 OK.');
        Assert.AreEqual('{"value": 42}', Result, 'Response body should match the expected JSON.');
    end;

    [Test]
    procedure Get_ReturnsBadRequest_OnError()
    var
        HttpHandler: Codeunit "TT Http Handler";
        MockClient: Codeunit "TT Http Handler Mock";
        Result: Text;
    begin
        MockClient.SetResponse(true, 400, '{"error":"bad request"}');

        Result := HttpHandler.Get('http://test', MockClient);

        Assert.AreEqual(400, MockClient.GetLastStatusCode(), 'HTTP status code should be 400 Bad Request.');
        Assert.AreEqual('{"error":"bad request"}', Result, 'Response body should match the expected error JSON.');
    end;

    [Test]
    procedure Send_ReturnsResponseBodyCreated_OnSuccess()
    var
        HttpHandler: Codeunit "TT Http Handler";
        MockClient: Codeunit "TT Http Handler Mock";
        Result: Text;
    begin
        MockClient.SetResponse(true, 201, '{"user":1}');

        Result := HttpHandler.Post('http://test', 'DummyText', MockClient);

        Assert.AreEqual(201, MockClient.GetLastStatusCode(), 'HTTP status code should be 201 Created.');
        Assert.AreEqual('{"user":1}', Result, 'Response body should match the expected JSON.');
    end;

    [Test]
    procedure Send_ReturnsBadRequest_OnError()
    var
        HttpHandler: Codeunit "TT Http Handler";
        MockClient: Codeunit "TT Http Handler Mock";
        Result: Text;
    begin
        MockClient.SetResponse(true, 400, '{"error":"invalid"}');

        Result := HttpHandler.Post('http://test', 'DummyText', MockClient);

        Assert.AreEqual(400, MockClient.GetLastStatusCode(), 'HTTP status code should be 400 Bad Request.');
        Assert.AreEqual('{"error":"invalid"}', Result, 'Response body should match the expected error JSON.');
    end;
    #endregion
}