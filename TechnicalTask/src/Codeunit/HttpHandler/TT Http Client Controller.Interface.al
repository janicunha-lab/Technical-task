interface "TT IHttpClientController"
{
    Access = Internal;

    procedure Get(Path: Text; var Response: HttpResponseMessage): Boolean;
    procedure Send(Request: HttpRequestMessage; var Response: HttpResponseMessage): Boolean;
}