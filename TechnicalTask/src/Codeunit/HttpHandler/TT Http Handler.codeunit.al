codeunit 1000001 "TT Http Handler" implements "TT IHttpClientController"
{
    Access = Internal;

    procedure Get(Url: Text): Text
    begin
        exit(Get(Url, this));
    end;

    procedure Get(Url: Text; Controller: Interface "TT IHttpClientController"): Text
    var
        HttpResponse: HttpResponseMessage;
        HttpStatusCode: Integer;
        ResponseText: Text;
        HttpClientError: Label 'Http request to %1 failed.';
    begin
        if not Controller.Get(Url, HttpResponse) then
            Error(HttpClientError, Url);

        if not HttpResponse.IsSuccessStatusCode() then
            HandleHttpError(HttpResponse.HttpStatusCode());

        HttpResponse.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    procedure Post(Url: Text; JsonText: Text): Text
    begin
        exit(Post(Url, JsonText, this));
    end;

    procedure Post(Url: Text; JsonText: Text; Controller: Interface "TT IHttpClientController"): Text
    var
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        ResponseText: Text;
        HttpClientError: Label 'Http request to %1 failed.';
    begin
        Request.Method('POST');
        Request.SetRequestUri(Url);
        Content.WriteFrom(JsonText);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json; charset=UTF-8');
        Request.Content(Content);

        if not Controller.Send(Request, Response) then
            Error(HttpClientError, Url);

        if not Response.IsSuccessStatusCode() then
            HandleHttpError(Response.HttpStatusCode());

        Response.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    procedure HandleHttpError(HttpStatusCode: Integer)
    var
        ErrorMessage: Text;
    begin
        case HttpStatusCode of
            400:
                ErrorMessage := 'Bad Request (400) – The request could not be understood or was missing required parameters.';
            401:
                ErrorMessage := 'Unauthorized (401) – Authentication failed or user does not have permissions.';
            403:
                ErrorMessage := 'Forbidden (403) – You do not have permission to access this resource.';
            404:
                ErrorMessage := 'Not Found (404) – The requested resource could not be found.';
            405:
                ErrorMessage := 'Method Not Allowed (405) – The HTTP method used is not allowed for this resource.';
            408:
                ErrorMessage := 'Request Timeout (408) – The request timed out.';
            409:
                ErrorMessage := 'Conflict (409) – There was a conflict with the current state of the resource.';
            500:
                ErrorMessage := 'Internal Server Error (500) – An error occurred on the server.';
            502:
                ErrorMessage := 'Bad Gateway (502) – Invalid response from the upstream server.';
            503:
                ErrorMessage := 'Service Unavailable (503) – The server is currently unavailable.';
            504:
                ErrorMessage := 'Gateway Timeout (504) – The upstream server timed out.';
            else
                ErrorMessage := StrSubstNo('HTTP Error %1 – Unknown error occurred.', HttpStatusCode);
        end;

        Error(ErrorMessage);
    end;

    procedure Get(Path: Text; var Response: HttpResponseMessage): Boolean
    var
        Client: HttpClient;
    begin
        exit(Client.Get(Path, Response));
    end;

    procedure Send(Request: HttpRequestMessage; var Response: HttpResponseMessage): Boolean
    var
        Client: HttpClient;
    begin
        exit(Client.Send(Request, Response));
    end;
}