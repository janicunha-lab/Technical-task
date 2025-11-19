
codeunit 1000012 "TT Http Handler Mock" implements "TT IHttpClientController"
{
    Access = Internal;

    var
        ShouldSucceed: Boolean;
        LastStatusCode: Integer;
        ResponseBody: Text;

    procedure SetResponse(Success: Boolean; Status: Integer; Body: Text)
    begin
        ShouldSucceed := Success;
        LastStatusCode := Status;
        ResponseBody := Body;
    end;

    procedure GetLastStatusCode(): Integer
    begin
        exit(LastStatusCode);
    end;

    procedure Get(Url: Text; var Response: HttpResponseMessage): Boolean
    var
        BodyInStream: InStream;
        TempBlob: Codeunit "Temp Blob";
        FullHttpResponseText: Text;
    begin
        if not ShouldSucceed then
            exit(false);

        Response.Content.WriteFrom(ResponseBody);
        exit(true);
    end;

    procedure Send(Request: HttpRequestMessage; var Response: HttpResponseMessage): Boolean
    var
        BodyInStream: InStream;
        TempBlob: Codeunit "Temp Blob";
        FullHttpResponseText: Text;
    begin
        if not ShouldSucceed then
            exit(false);

        Response.Content.WriteFrom(ResponseBody);
        exit(true);
    end;
}