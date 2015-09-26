unit PurchaseProcess.Bus;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  PurchaseProcess.Types;

type
  TBus = class( TInterfacedPersistent, IBus, IOrderChannel )
  private
    FMachines : TObjectDictionary<TOrderId, TOrderSM>;
    FOrders   : TObjectDictionary<TOrderId, TOrderMessage>;
    FResources: TDictionary<TOrderResourceType, TResource>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterResource( const AResource: TResource );
    procedure Dispatch(
      const ATransition: TOrderSM.TTransition;
      const AOrderId   : TOrderId );
    procedure SendMessage(
      const AOrderMessage: TOrderMessage;
      const AOrderEvent  : TOrderEvent );
  end;

implementation

uses
  Stateless.Utils,
  PurchaseProcess.MachineFactory;

{ TBus }

constructor TBus.Create;
begin
  inherited;
  FMachines  := TObjectDictionary<TOrderId, TOrderSM>.Create( [ doOwnsValues ] );
  FOrders    := TObjectDictionary<TOrderId, TOrderMessage>.Create( [ doOwnsValues ] );
  FResources := TDictionary<TOrderResourceType, TResource>.Create;
end;

destructor TBus.Destroy;
begin
  FResources.Free;
  FOrders.Free;
  FMachines.Free;
  inherited;
end;

procedure TBus.Dispatch(
  const ATransition: TOrderSM.TTransition;
  const AOrderId   : TOrderId );
begin
{$IFDEF DEBUG}Writeln( 'LOG ' + Self.ClassName + '.Dispatch( ', ATransition.ToString, ', ', AOrderId, ' )' ); {$ENDIF}
  case ATransition.Destination of
    osNoOrder:
      begin
        FMachines.Remove( AOrderId );
        FOrders.Remove( AOrderId );
      end;
    osEmpty:
      begin
        if not FResources.ContainsKey( ortShop )
        then
          raise EInvalidOpException.Create( 'does not contain shop' );
        FResources[ ortShop ].ReceiveMessage( FOrders[ AOrderId ] );
      end;
    osFilled:
      begin
        if not FResources.ContainsKey( ortSeller )
        then
          raise EInvalidOpException.Create( 'does not contain seller' );
        FResources[ ortSeller ].ReceiveMessage( FOrders[ AOrderId ] );
      end;
    osPaid:
      begin
        if not FResources.ContainsKey( ortSender )
        then
          raise EInvalidOpException.Create( 'does not contain sender' );
        FResources[ ortSender ].ReceiveMessage( FOrders[ AOrderId ] );
      end;
  else
    raise ENotImplemented.CreateFmt( 'Dispatch for "%s" not implemented', [ TEnum.AsString( ATransition.Destination ) ] );
  end;
end;

procedure TBus.RegisterResource( const AResource: TResource );
begin
  FResources.Add( AResource.ResourceType, AResource );
end;

procedure TBus.SendMessage(
  const AOrderMessage: TOrderMessage;
  const AOrderEvent  : TOrderEvent );
begin
{$IFDEF DEBUG}Writeln( 'LOG ' + Self.ClassName + '.SendMessage( ', AOrderMessage.OrderId, ', ', TEnum.AsString( AOrderEvent ), ' )' ); {$ENDIF}
  if AOrderEvent = oeAccess
  then
    begin
      FMachines.Add( AOrderMessage.OrderId, MachineFactory.CreateInstance( Self, AOrderMessage.OrderId ) );
      FOrders.Add( AOrderMessage.OrderId, AOrderMessage );
    end
  else
    begin
      if FOrders[ AOrderMessage.OrderId ] <> AOrderMessage
      then
        FOrders[ AOrderMessage.OrderId ] := AOrderMessage;
    end;

  if FMachines[ AOrderMessage.OrderId ].CanFire( AOrderEvent )
  then
    FMachines[ AOrderMessage.OrderId ].Fire( AOrderEvent )
  else
    raise EInvalidOperation.CreateFmt( 'Trigger "%s" is not valid in "%s" order state',
      [ TEnum.AsString( AOrderEvent ), TEnum.AsString( FMachines[ AOrderMessage.OrderId ].State ) ] );
end;

end.
