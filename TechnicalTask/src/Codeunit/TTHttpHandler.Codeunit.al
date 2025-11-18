codeunit 1000001 "TT Http Handler"
{

    trigger OnRun()
    begin
    end;

    internal procedure Get(Url: Text): Text
    var
        Client: HttpClient;
        HttpResponse: HttpResponseMessage;
        HttpStatusCode: Integer;
        ResponseText: Text;
        HttpClientError: Label 'Http request to %1 failed.';
    begin
        if not Client.Get(Url, HttpResponse) then
            Error(HttpClientError, Url);

        if not HttpResponse.IsSuccessStatusCode() then begin
            HandleHttpError(HttpResponse.HttpStatusCode());
            exit('');
        end;

        HttpResponse.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    internal procedure Post(Url: Text; JsonText: Text): Text
    var
        Client: HttpClient;
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

        if not Client.Send(Request, Response) then
            Error(HttpClientError, Url);

        if not Response.IsSuccessStatusCode() then begin
            HandleHttpError(Response.HttpStatusCode());
            exit('');
        end;

        Response.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    local procedure HandleHttpError(HttpStatusCode: Integer)
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



}