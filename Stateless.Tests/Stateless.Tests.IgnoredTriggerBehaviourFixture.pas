unit Stateless.Tests.IgnoredTriggerBehaviourFixture;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Stateless,
  Stateless.Tests.TestMachine;

type

  [ TestFixture ]
  TIgnoredTriggerBehaviourFixture = class( TObject )
  private
    ignored: TTestMachine.TIgnoredTriggerBehaviour;
  public
    [ Setup ]
    procedure Setup;
    [ TearDown ]
    procedure TearDown;

    [ Test ]
    procedure StateRemainsUnchanged( );
    [ Test ]
    procedure ExposesCorrectUnderlyingTrigger( );
    [ Test ]
    procedure WhenGuardConditionFalse_IsGuardConditionMetIsFalse( );
    [ Test ]
    procedure WhenGuardConditionTrue_IsGuardConditionMetIsTrue( );
  end;

implementation

procedure TIgnoredTriggerBehaviourFixture.Setup;
begin
end;

procedure TIgnoredTriggerBehaviourFixture.TearDown;
begin
  FreeAndNil( ignored );
end;

procedure TIgnoredTriggerBehaviourFixture.WhenGuardConditionFalse_IsGuardConditionMetIsFalse;
const
  Trigger = TTrigger.X;
begin
  ignored := TTestMachine.TIgnoredTriggerBehaviour.Create( Trigger,
    function: Boolean
    begin
      Result := False;
    end );
  Assert.IsFalse( ignored.IsGuardConditionMet );
end;

procedure TIgnoredTriggerBehaviourFixture.WhenGuardConditionTrue_IsGuardConditionMetIsTrue;
const
  Trigger = TTrigger.X;
begin
  ignored := TTestMachine.TIgnoredTriggerBehaviour.Create( Trigger,
    function: Boolean
    begin
      Result := True;
    end );
  Assert.IsTrue( ignored.IsGuardConditionMet );
end;

procedure TIgnoredTriggerBehaviourFixture.ExposesCorrectUnderlyingTrigger;
const
  Trigger = TTrigger.X;
begin
  ignored := TTestMachine.TIgnoredTriggerBehaviour.Create( Trigger,
    function: Boolean
    begin
      Result := true;
    end );

  Assert.AreEqual( Trigger, ignored.Trigger );
end;

procedure TIgnoredTriggerBehaviourFixture.StateRemainsUnchanged;
const
  Source  = TState.B;
  Trigger = TTrigger.X;
var
  Destination: TState;
begin
  ignored := TTestMachine.TIgnoredTriggerBehaviour.Create( Trigger,
    function: Boolean
    begin
      Result := False;
    end );
  Assert.IsFalse( ignored.ResultsInTransitionFrom( Source, [ ], Destination ) );
end;

initialization

TDUnitX.RegisterTestFixture( TIgnoredTriggerBehaviourFixture );

end.
