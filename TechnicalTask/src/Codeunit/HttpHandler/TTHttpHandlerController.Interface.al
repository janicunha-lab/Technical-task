interface "TT IHttpHandlerController"
{
    Access = Internal;

    procedure Get(Url: Text): Text;
    procedure Post(Url: Text; JsonText: Text): Text;
    procedure HandleHttpError(HttpStatusCode: Integer);
}