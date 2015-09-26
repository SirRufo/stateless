unit PurchaseProcess.MachineFactory;

interface

uses
  PurchaseProcess.Types;

type
  MachineFactory = class abstract
  public
    class function CreateInstance( const AChannel: IOrderChannel; const Id: TOrderId ): TOrderSM;
  end;

implementation

{ MachineFactory }

class function MachineFactory.CreateInstance(
  const AChannel: IOrderChannel;
  const Id      : TOrderId ): TOrderSM;
var
  LId : TOrderId;
begin
  LId := Id;

  Result := TOrderSM.Create( osNone );

  Result.Configure( osNone )
  {} .Permit( oeAccess, osEmpty )
  {} .OnEntry(
    procedure( const t: TOrderSM.TTransition )
    begin
      AChannel.Dispatch( t, LId );
    end );

  Result.Configure( osEmpty )
  {} .Permit( oeOrder, osFilled )
  {} .Permit( oeExit, osNoOrder )
  {} .OnEntry(
    procedure( const t: TOrderSM.TTransition )
    begin
      AChannel.Dispatch( t, LId );
    end );

  Result.Configure( osFilled )
  {} .Permit( oePay, osPaid )
  {} .Permit( oeModify, osEmpty )
  {} .OnEntry(
    procedure( const t: TOrderSM.TTransition )
    begin
      AChannel.Dispatch( t, LId );
    end );

  Result.Configure( osPaid )
  {} .Permit( oeExit, osNoOrder )
  {} .OnEntry(
    procedure( const t: TOrderSM.TTransition )
    begin
      AChannel.Dispatch( t, LId );
    end );
end;

end.
