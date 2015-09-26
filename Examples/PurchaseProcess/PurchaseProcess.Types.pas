unit PurchaseProcess.Types;

interface

uses
  System.SysUtils,
  Stateless;

type
  TOrderId = type string;

  TOrderIdHelper = record helper for TOrderId
    class function NewOrderId: TOrderId; static;
    function ToString( ): string;
  end;

type
  IBus          = interface;
  IOrderChannel = interface;
  TMutableOrder = class;
  TOrderMessage = class;
  TResource     = class;

  TOrderResourceType = ( ortShop, ortSeller, ortSender, ortSite );
  TOrderEvent        = ( oeAccess, oeOrder, oePay, oeExit, oeModify );
  TOrderState        = ( osEmpty, osFilled, osNoOrder, osPaid, osNone );

  TOrderSM = TStateMachine<TOrderState, TOrderEvent>;

  IBus = interface
    [ '{705A25C4-8217-481B-B333-C55568AF5B78}' ]
    procedure RegisterResource( const AResource: TResource );
    procedure SendMessage( const AOrderMessage: TOrderMessage; const AOrderEvent: TOrderEvent );
  end;

  IOrderChannel = interface
    [ '{AB7F47D9-6AA5-4B05-9315-E6CF57F21BE7}' ]
    procedure Dispatch( const ATransition: TOrderSM.TTransition; const AOrderId: TOrderId );
  end;

  TMutableOrder = class
  private
    FTotal   : Currency;
    FQuantity: Integer;
    FOrderId : TOrderId;
  public
    constructor Create( const AOrder: TOrderMessage );

    function CreateOrderMessage( ): TOrderMessage;

    property Total: Currency read FTotal write FTotal;
    property Quantity: Integer read FQuantity write FQuantity;
    property OrderId: TOrderId read FOrderId write FOrderId;
  end;

  TOrderMessage = class
  private
    FTotal   : Currency;
    FQuantity: Integer;
    FOrderId : TOrderId;
  public
    constructor Create( ); overload;
    constructor Create( const AOrder: TMutableOrder ); overload;
    function CreateOrder( ): TMutableOrder;

    function ToString: string; override;

    property Total: Currency read FTotal;
    property Quantity: Integer read FQuantity;
    property OrderId: TOrderId read FOrderId;
  end;

  TResource = class abstract
  protected
    FBus: IBus;
    function GetResourceType: TOrderResourceType; virtual; abstract;
  public
    procedure Subscribe( const ABus: IBus );
    procedure ReceiveMessage( const AMessage: TOrderMessage ); virtual;
    property ResourceType: TOrderResourceType read GetResourceType;
  end;

implementation

{ TResource }

procedure TResource.ReceiveMessage( const AMessage: TOrderMessage );
begin
{$IFDEF DEBUG}Writeln( 'LOG ' + Self.ClassName + '.ReceiveMessage( ', AMessage.ToString, ' )' ); {$ENDIF}
end;

procedure TResource.Subscribe( const ABus: IBus );
begin
  ABus.RegisterResource( Self );
  FBus := ABus;
end;

{ TOrderMessage }

constructor TOrderMessage.Create;
begin
  inherited;
  FOrderId := TOrderId.NewOrderId;
end;

constructor TOrderMessage.Create( const AOrder: TMutableOrder );
begin
  inherited Create;
  FTotal    := AOrder.Total;
  FQuantity := AOrder.Quantity;
  FOrderId  := AOrder.OrderId;
end;

function TOrderMessage.CreateOrder: TMutableOrder;
begin
  Result := TMutableOrder.Create( Self );
end;

function TOrderMessage.ToString: string;
begin
  if Self = nil
  then
    Result := 'OrderMessage( nil )'
  else
    Result := 'OrderMessage { OrderId:' + FOrderId.ToString + ', Quantity:' + Quantity.ToString + ', Total:' + CurrToStr( FTotal ) + '}';
end;

{ TMutableOrder }

constructor TMutableOrder.Create( const AOrder: TOrderMessage );
begin
  inherited Create;
  FTotal    := AOrder.Total;
  FQuantity := AOrder.Quantity;
  FOrderId  := AOrder.OrderId;
end;

function TMutableOrder.CreateOrderMessage: TOrderMessage;
begin
  Result := TOrderMessage.Create( Self );
end;

{ TOrderIdHelper }

class function TOrderIdHelper.NewOrderId: TOrderId;
begin
  Result := TGUID.NewGuid.ToString;
end;

function TOrderIdHelper.ToString: string;
begin
  Result := Self;
end;

end.
