program PhoneCall;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Stateless;

{$SCOPEDENUMS ON}

type
  State      = ( OffHook, Ringing, Connected, Active, OnHold, PhoneDestroyed );
  Trigger    = ( CallDialed, HungUp, CallConnected, LeftMessage, PlacedOnHold, TakenOffHold, PhoneHurledAgainstWall );
  TPhoneCall = TStateMachine<State, Trigger>;

procedure ConfigurePhoneCall( PhoneCall: TPhoneCall );
begin
  PhoneCall.Configure( State.OffHook )
  {} .Permit( Trigger.CallDialed, State.Ringing );

  PhoneCall.Configure( State.Ringing )
  {} .Permit( Trigger.HungUp, State.OffHook )
  {} .Permit( Trigger.CallConnected, State.Active );

  PhoneCall.Configure( State.Connected )
  {} .Permit( Trigger.HungUp, State.OffHook )
  {} .OnEntry(
    procedure( t: TPhoneCall.TTransition )
    begin
    end )
  {} .OnExit(
    procedure( t: TPhoneCall.TTransition )
    begin
    end );

  PhoneCall.Configure( State.Active )
  {} .SubstateOf( State.Connected )
  {} .Permit( Trigger.LeftMessage, State.OffHook )
  {} .Permit( Trigger.PlacedOnHold, State.OnHold );

  PhoneCall.Configure( State.OnHold )
  {} .SubstateOf( State.Connected )
  {} .Permit( Trigger.TakenOffHold, State.Active )
  {} .Permit( Trigger.PhoneHurledAgainstWall, State.PhoneDestroyed );
end;

procedure Test;
var
  LCall     : TPhoneCall;
  LPermitted: TArray<Trigger>;
begin
  LCall := TPhoneCall.Create( State.OffHook );
  try
    ConfigurePhoneCall( LCall );
    Writeln( LCall.ToString );

    LCall.Fire( Trigger.CallDialed );
    Writeln( LCall.ToString );

    LCall.Fire( Trigger.CallConnected );
    Writeln( LCall.ToString );

    LCall.Fire( Trigger.PlacedOnHold );
    Writeln( LCall.ToString );

    LCall.Fire( Trigger.TakenOffHold );
    Writeln( LCall.ToString );

    LCall.Fire( Trigger.PlacedOnHold );
    Writeln( LCall.ToString );

    LCall.Fire( Trigger.HungUp );
    Writeln( LCall.ToString );

  finally
    LCall.Free;
  end;
end;

begin
  try
    Test;
  except
    on E: Exception do
      Writeln( E.ClassName, ': ', E.Message );
  end;
  ReadLn;

end.
