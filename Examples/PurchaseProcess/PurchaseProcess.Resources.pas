unit PurchaseProcess.Resources;

interface

uses
  System.SysUtils,
  PurchaseProcess.Types;

type
  TSeller = class( TResource )
  protected
    function GetResourceType: TOrderResourceType; override;
  public
    procedure ReceiveMessage( const AMessage: TOrderMessage ); override;
  end;

  TSender = class( TResource )
  protected
    function GetResourceType: TOrderResourceType; override;
  public
    procedure ReceiveMessage( const AMessage: TOrderMessage ); override;
  end;

  TShop = class( TResource )
  protected
    function GetResourceType: TOrderResourceType; override;
  public
    procedure ReceiveMessage( const AMessage: TOrderMessage ); override;
  end;

  TSite = class( TResource )
  protected
    function GetResourceType: TOrderResourceType; override;
  public
    procedure ReceiveMessage( const AMessage: TOrderMessage ); override;
    procedure EnterNewOrder( );
  end;

implementation

{ TSeller }

function TSeller.GetResourceType: TOrderResourceType;
begin
  Result := ortSeller;
end;

procedure TSeller.ReceiveMessage( const AMessage: TOrderMessage );
var
  LKey: Char;
begin
  inherited;
  WriteLn( 'Total to pay: ', CurrToStr( AMessage.Total ) );
  while True do
    begin
      write( 'Enter P to pay or M to modify the product quantity ' );
      ReadLn( LKey );
      case LKey of
        'p', 'P':
          begin
            FBus.SendMessage( AMessage, oePay );
            Break;
          end;
        'm', 'M':
          begin
            FBus.SendMessage( AMessage, oeModify );
            Break;
          end;
      else
        WriteLn( 'Input not valid' );
      end;
    end;
end;

{ TSender }

function TSender.GetResourceType: TOrderResourceType;
begin
  Result := ortSender;
end;

procedure TSender.ReceiveMessage( const AMessage: TOrderMessage );
var
  LKey: Char;
begin
  inherited;
  WriteLn( 'You have bought a quantity of ', AMessage.Quantity, ' and paid ', CurrToStr( AMessage.Total ) );
  WriteLn( 'The products will be shipped soon' );
  WriteLn( 'Thank you for your purchase' );
  while True do
    begin
      write( 'Enter O to place a new order or E to exit ' );
      ReadLn( LKey );
      case LKey of
        'e', 'E':
          begin
            FBus.SendMessage( AMessage, oeExit );
            WriteLn( 'Bye!' );
            ReadLn;
            Break;
          end;
        'o', 'O':
          begin
            WriteLn( '-----------------------------------------------' );
            WriteLn;
            FBus.SendMessage( TOrderMessage.Create, oeAccess );
            Break;
          end;
      else
        WriteLn( 'Input not valid' );
      end;
    end;
end;

{ TShop }

function TShop.GetResourceType: TOrderResourceType;
begin
  Result := ortShop;
end;

procedure TShop.ReceiveMessage( const AMessage: TOrderMessage );
var
  LInput    : string;
  LQuantity : Integer;
  LProvisory: TMutableOrder;
begin
  inherited;
  WriteLn( 'Welcome to the shop' );
  WriteLn( 'The unit price is 34' );
  WriteLn( 'You have ', AMessage.Quantity, ' products in your basket' );
  while True do
    begin
      WriteLn( 'Enter product quantity to order or E to exit' );
      ReadLn( LInput );
      if LInput.Trim.ToUpper = 'E'
      then
        begin
          FBus.SendMessage( AMessage, oeExit );
          WriteLn( 'You have exited without buying' );
          ReadLn;
          Break;
        end
      else if TryStrToInt( LInput, LQuantity )
      then
        begin
          LProvisory := AMessage.CreateOrder;
          try
            LProvisory.Quantity := LQuantity;
            LProvisory.Total    := LQuantity * 34;
            FBus.SendMessage( LProvisory.CreateOrderMessage, oeOrder );
          finally
            LProvisory.Free;
          end;
          Break;
        end
      else
        begin
          WriteLn( 'Input not valid' );
        end;
    end;
end;

{ TSite }

procedure TSite.EnterNewOrder;
begin
  FBus.SendMessage( TOrderMessage.Create, oeAccess );
end;

function TSite.GetResourceType: TOrderResourceType;
begin
  Result := ortSite;
end;

procedure TSite.ReceiveMessage( const AMessage: TOrderMessage );
begin
  inherited;
  raise ENotImplemented.CreateFmt( '%s.ReceiveMessage', [ Self.ClassName ] );
end;

end.
