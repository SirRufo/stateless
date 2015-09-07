unit Stateless.Tests.TriggerWithParametersFixture;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Stateless,
  Stateless.Types,
  Stateless.Tests.TestMachine;

type

  [ TestFixture ]
  TTriggerWithParametersFixture = class( TObject )
  private type
    TTriggerWithParameters             = TTestMachine.TTriggerWithParameters;
    TTriggerWithStringParameter        = TTestMachine.TTriggerWithParameters<string>;
    TTriggerWithStringStringParameters = TTestMachine.TTriggerWithParameters<string, string>;
  private
    twp: TTriggerWithParameters;
  public
    [ Setup ]
    procedure Setup;
    [ TearDown ]
    procedure TearDown;

    [ Test ]
    procedure DescribesUnderlyingTrigger( );
    [ Test ]
    procedure ParametersOfCorrectTypeAreAccepted( );
    [ Test ]
    procedure IncompatibleParametersAreNotValid( );
    [ Test ]
    procedure TooFewParametersDetected( );
    [ Test ]
    procedure TooManyParametersDetected( );
  end;

implementation

procedure TTriggerWithParametersFixture.DescribesUnderlyingTrigger;
const
  Trigger = TTrigger.X;
begin
  twp := TTriggerWithStringParameter.Create( Trigger );
  Assert.AreEqual( Trigger, twp.Trigger );
end;

procedure TTriggerWithParametersFixture.IncompatibleParametersAreNotValid;
const
  Trigger = TTrigger.X;
begin
  twp := TTriggerWithStringParameter.Create( Trigger );
  Assert.WillRaise(
    procedure
    begin
      twp.ValidateParameters( [ 123 ] );
    end,
    EArgumentException );
end;

procedure TTriggerWithParametersFixture.ParametersOfCorrectTypeAreAccepted;
const
  Trigger = TTrigger.X;
begin
  twp := TTriggerWithStringParameter.Create( Trigger );
  twp.ValidateParameters( [ 'a' ] );
end;

procedure TTriggerWithParametersFixture.Setup;
begin
end;

procedure TTriggerWithParametersFixture.TearDown;
begin
  FreeAndNil( twp );
end;

procedure TTriggerWithParametersFixture.TooFewParametersDetected;
const
  Trigger = TTrigger.X;
begin
  twp := TTriggerWithStringStringParameters.Create( Trigger );
  Assert.WillRaise(
    procedure
    begin
      twp.ValidateParameters( [ 'a' ] );
    end,
    EArgumentException );
end;

procedure TTriggerWithParametersFixture.TooManyParametersDetected;
const
  Trigger = TTrigger.X;
begin
  twp := TTriggerWithStringStringParameters.Create( Trigger );
  Assert.WillRaise(
    procedure
    begin
      twp.ValidateParameters( [ 'a', 'a', 'a' ] );
    end,
    EArgumentException );
end;

initialization

TDUnitX.RegisterTestFixture( TTriggerWithParametersFixture );

end.
