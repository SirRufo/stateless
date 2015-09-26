program PurchaseProcess;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  PurchaseProcess.Types in 'PurchaseProcess.Types.pas',
  PurchaseProcess.Resources in 'PurchaseProcess.Resources.pas',
  PurchaseProcess.MachineFactory in 'PurchaseProcess.MachineFactory.pas',
  PurchaseProcess.Bus in 'PurchaseProcess.Bus.pas';

procedure Main;
var
  Bus   : TBus;
  Site  : TSite;
  Shop  : TShop;
  Seller: TSeller;
  Sender: TSender;
begin
  Bus    := nil;
  Site   := nil;
  Shop   := nil;
  Seller := nil;
  Sender := nil;
  try

    Bus    := TBus.Create;
    Site   := TSite.Create;
    Shop   := TShop.Create;
    Seller := TSeller.Create;
    Sender := TSender.Create;

    Site.Subscribe( Bus );
    Shop.Subscribe( Bus );
    Seller.Subscribe( Bus );
    Sender.Subscribe( Bus );

    Site.EnterNewOrder( );

  finally
    Bus.Free;
    Site.Free;
    Shop.Free;
    Seller.Free;
    Sender.Free;
  end;
end;

begin
  try
    Main;
  except
    on E: Exception do
      Writeln( E.ClassName, ': ', E.Message );
  end;

end.
