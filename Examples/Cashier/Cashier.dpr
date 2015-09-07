program Cashier;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Stateless,
  Stateless.Utils;

{$SCOPEDENUMS ON}

type
  TBon = class
  public type
    TState = ( Empty, Opened, BasketMode, PayMode, Returning, Closed );
  private type
    TTrigger  = ( AddArticle, Next, Pay, ReturnMoney, Cancel );
    TBonState = TStateMachine<TState, TTrigger>;
  private { Fields }
    FState                  : TState;
    FBonState               : TBonState;
    FPayTrigger             : TBonState.TTriggerWithParameters<Currency>;
    FTotal, FPaid, FReturned: Currency;
  private { Methods }
    function GetBalance: Currency;
    function GetState: TState;
    procedure SetState( Value: TState );
  public { Constructors / Destructors }
    constructor Create;
    destructor Destroy; override;
  public { Methods }
    function ToString: string; override;

    procedure AddArticle( AValue: Currency );
    procedure Cancel( );
    procedure Next( );
    procedure Pay( AValue: Currency );
    procedure ReturnMoney( );

  public { Properties }
    property Balance: Currency read GetBalance;
    property Paid   : Currency read FPaid;
    property Total  : Currency read FTotal;
    property State  : TState read GetState write SetState;
  end;

  { TBon }

procedure TBon.AddArticle( AValue: Currency );
begin
  FBonState.Fire( TTrigger.AddArticle );
  FTotal := FTotal + AValue;
end;

procedure TBon.Cancel;
begin
  FBonState.Fire( TTrigger.Cancel );
end;

constructor TBon.Create;
begin
  inherited;
  FBonState   := TBonState.Create( GetState, SetState );
  FPayTrigger := FBonState.SetTriggerParameters<Currency>( TTrigger.Pay );

  FBonState.Configure( TState.Empty )
  {} .OnEntry(
    procedure
    begin
      FTotal := 0;
      FPaid := 0;
      FReturned := 0;
    end )
  {} .Permit( TTrigger.AddArticle, TState.BasketMode );

  FBonState.Configure( TState.Opened )
  {} .Permit( TTrigger.Cancel, TState.Empty );

  FBonState.Configure( TState.BasketMode )
  {} .SubstateOf( TState.Opened )
  {} .PermitReentry( TTrigger.AddArticle )
  {} .PermitDynamic( TTrigger.Next,
    function: TState
    begin
      if FTotal < 0
      then
        Result := TState.Returning
      else if FTotal = 0
      then
        Result := TState.Closed
      else
        Result := TState.PayMode;
    end );

  FBonState.Configure( TState.PayMode )
  {} .SubstateOf( TState.Opened )
  {} .PermitDynamic<Currency>( FPayTrigger,
    function( a0: Currency ): TState
    begin
      if FPaid + a0 >= FTotal
      then
        Result := TState.Returning
      else if FPaid + a0 = FTotal
      then
        Result := TState.Closed
      else
        Result := TState.PayMode;
    end );

  FBonState.Configure( TState.Returning )
  {} .Permit( TTrigger.ReturnMoney, TState.Closed );
end;

destructor TBon.Destroy;
begin
  FBonState.Free;
  inherited;
end;

function TBon.GetBalance: Currency;
begin
  Result := FPaid - FTotal - FReturned;
end;

function TBon.GetState: TState;
begin
  Result := FState;
end;

procedure TBon.Next;
begin
  FBonState.Fire( TTrigger.Next );
end;

procedure TBon.Pay( AValue: Currency );
begin
  FBonState.Fire<Currency>( FPayTrigger, AValue );
  FPaid := FPaid + AValue;
end;

procedure TBon.ReturnMoney;
begin
  FBonState.Fire( TTrigger.ReturnMoney );
  FReturned := FPaid - FTotal;
end;

procedure TBon.SetState( Value: TState );
begin
  FState := Value;
end;

function TBon.ToString: string;
begin
  Result := string.Format( '%-10.10s T:%4g P:%4g R:%4g B:%4g', [ TEnum.AsString( FState ), FTotal, FPaid, FReturned, Balance ] );
end;

procedure NormalRun;
var
  LBon: TBon;
  procedure Execute( AProc: TProc ); overload;
  begin
    AProc( );
    WriteLn( LBon.ToString );
  end;

  procedure Execute( AProc: TProc<Currency>; AValue: Currency ); overload;
  begin
    AProc( AValue );
    WriteLn( LBon.ToString );
  end;

begin
  WriteLn( '* Normal Run' );
  LBon := TBon.Create;
  try
    WriteLn( LBon.ToString );
    Execute( LBon.AddArticle, 10 );
    Execute( LBon.AddArticle, 20 );
    Execute( LBon.Next );
    if LBon.State = TBon.TState.PayMode
    then
      Execute( LBon.Pay, 50 );
    if LBon.State = TBon.TState.Returning
    then
      Execute( LBon.ReturnMoney );
  finally
    LBon.Free;
  end;
end;

procedure ReturningArticle;
var
  LBon: TBon;
  procedure Execute( AProc: TProc ); overload;
  begin
    AProc( );
    WriteLn( LBon.ToString );
  end;

  procedure Execute( AProc: TProc<Currency>; AValue: Currency ); overload;
  begin
    AProc( AValue );
    WriteLn( LBon.ToString );
  end;

begin
  WriteLn( '* Returning Article' );
  LBon := TBon.Create;
  try
    WriteLn( LBon.ToString );
    Execute( LBon.AddArticle, -10 );
    Execute( LBon.Next );
    if LBon.State = TBon.TState.PayMode
    then
      Execute( LBon.Pay, 50 );
    if LBon.State = TBon.TState.Returning
    then
      Execute( LBon.ReturnMoney );
  finally
    LBon.Free;
  end;
end;

procedure ChangeArticle;
var
  LBon: TBon;
  procedure Execute( AProc: TProc ); overload;
  begin
    AProc( );
    WriteLn( LBon.ToString );
  end;

  procedure Execute( AProc: TProc<Currency>; AValue: Currency ); overload;
  begin
    AProc( AValue );
    WriteLn( LBon.ToString );
  end;

begin
  WriteLn( '* Change Article' );
  LBon := TBon.Create;
  try
    WriteLn( LBon.ToString );
    Execute( LBon.AddArticle, -10 );
    Execute( LBon.AddArticle, 10 );
    Execute( LBon.Next );
    if LBon.State = TBon.TState.PayMode
    then
      Execute( LBon.Pay, 50 );
    if LBon.State = TBon.TState.Returning
    then
      Execute( LBon.ReturnMoney );
  finally
    LBon.Free;
  end;
end;

procedure ChangeArticleLowerPrice;
var
  LBon: TBon;
  procedure Execute( AProc: TProc ); overload;
  begin
    AProc( );
    WriteLn( LBon.ToString );
  end;

  procedure Execute( AProc: TProc<Currency>; AValue: Currency ); overload;
  begin
    AProc( AValue );
    WriteLn( LBon.ToString );
  end;

begin
  WriteLn( '* Change Article Lower Price' );
  LBon := TBon.Create;
  try
    WriteLn( LBon.ToString );
    Execute( LBon.AddArticle, -20 );
    Execute( LBon.AddArticle, 10 );
    Execute( LBon.Next );
    if LBon.State = TBon.TState.PayMode
    then
      Execute( LBon.Pay, 50 );
    if LBon.State = TBon.TState.Returning
    then
      Execute( LBon.ReturnMoney );
  finally
    LBon.Free;
  end;
end;

procedure ChangeArticleHigherPrice;
var
  LBon: TBon;
  procedure Execute( AProc: TProc ); overload;
  begin
    AProc( );
    WriteLn( LBon.ToString );
  end;

  procedure Execute( AProc: TProc<Currency>; AValue: Currency ); overload;
  begin
    AProc( AValue );
    WriteLn( LBon.ToString );
  end;

begin
  WriteLn( '* Change Article Higher Price' );
  LBon := TBon.Create;
  try
    WriteLn( LBon.ToString );
    Execute( LBon.AddArticle, -10 );
    Execute( LBon.AddArticle, 20 );
    Execute( LBon.Next );
    if LBon.State = TBon.TState.PayMode
    then
      Execute( LBon.Pay, 50 );
    if LBon.State = TBon.TState.Returning
    then
      Execute( LBon.ReturnMoney );
  finally
    LBon.Free;
  end;
end;

begin
  try
    NormalRun;
    ReturningArticle;
    ChangeArticle;
    ChangeArticleLowerPrice;
    ChangeArticleHigherPrice;
  except
    on E: Exception do
      WriteLn( E.ClassName, ': ', E.Message );
  end;
  ReadLn;

end.
