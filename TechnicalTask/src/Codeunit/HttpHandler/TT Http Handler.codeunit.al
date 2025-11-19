codeunit 1000001 "TT Http Handler" implements "TT IHttpClientController"
{
    Access = Internal;

    var
        HttpClientErr: Label 'Http request to %1 failed.';
        EmptyUrlErr: Label 'URL cannot be empty.';
        EmptyJsonErr: Label 'JSON content cannot be empty.';
        JsonContentType: Label 'application/json; charset=UTF-8', Locked = true;

    procedure Get(Url: Text): Text
    begin
        exit(Get(Url, this));
    end;

    procedure Get(Url: Text; Controller: Interface "TT IHttpClientController"): Text
    var
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
    begin
        VerifyEmptyUrl(Url);

        if not Controller.Get(Url, HttpResponse) then
            Error(HttpClientErr, Url);

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
        Content: HttpContent;
        Headers: HttpHeaders;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseText: Text;
    begin
        VerifyEmptyUrl(Url);

        if JsonText = '' then
            Error(EmptyJsonErr);

        Request.Method('POST');
        Request.SetRequestUri(Url);
        Content.WriteFrom(JsonText);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', JsonContentType);
        Request.Content(Content);

        if not Controller.Send(Request, Response) then
            Error(HttpClientErr, Url);

        if not Response.IsSuccessStatusCode() then
            HandleHttpError(Response.HttpStatusCode());

        Response.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    procedure VerifyEmptyUrl(Url: Text)
    begin
        if Url = '' then
            Error(EmptyUrlErr);
    end;

    procedure HandleHttpError(HttpStatusCode: Integer)
    var
        ErrorMessage: Text;
        BadRequestErr: Label 'Bad Request (400) – The request could not be understood or was missing required parameters.';
        UnauthorizedErr: Label 'Unauthorized (401) – Authentication failed or user does not have permissions.';
        ForbiddenErr: Label 'Forbidden (403) – You do not have permission to access this resource.';
        NotFoundErr: Label 'Not Found (404) – The requested resource could not be found.';
        MethodNotAllowedErr: Label 'Method Not Allowed (405) – The HTTP method used is not allowed for this resource.';
        RequestTimeoutErr: Label 'Request Timeout (408) – The request timed out.';
        ConflictErr: Label 'Conflict (409) – There was a conflict with the current state of the resource.';
        InternalServerErr: Label 'Internal Server Error (500) – An error occurred on the server.';
        BadGatewayErr: Label 'Bad Gateway (502) – Invalid response from the upstream server.';
        ServiceUnavailableErr: Label 'Service Unavailable (503) – The server is currently unavailable.';
        GatewayTimeoutErr: Label 'Gateway Timeout (504) – The upstream server timed out.';
        UnknownHttpErr: Label 'HTTP Error %1 – Unknown error occurred.';
    begin
        case HttpStatusCode of
            400:
                ErrorMessage := BadRequestErr;
            401:
                ErrorMessage := UnauthorizedErr;
            403:
                ErrorMessage := ForbiddenErr;
            404:
                ErrorMessage := NotFoundErr;
            405:
                ErrorMessage := MethodNotAllowedErr;
            408:
                ErrorMessage := RequestTimeoutErr;
            409:
                ErrorMessage := ConflictErr;
            500:
                ErrorMessage := InternalServerErr;
            502:
                ErrorMessage := BadGatewayErr;
            503:
                ErrorMessage := ServiceUnavailableErr;
            504:
                ErrorMessage := GatewayTimeoutErr;
            else
                ErrorMessage := StrSubstNo(UnknownHttpErr, HttpStatusCode);
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