unit Stateless.Tests.TransitionFixture;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Defaults,
  Stateless;

type

  [ TestFixture ]
  TTransitionFixture = class( TObject )
  private type
    TTestMachine = TStateMachine<Integer, Integer>;
    TTransition  = TTestMachine.TTransition;
  public
    [ Setup ]
    procedure Setup;
    [ TearDown ]
    procedure TearDown;

    [ Test ]
    procedure IdentityTransitionIsNotChange( );
    [ Test ]
    procedure TransitioningTransitionIsChange( );
  end;

implementation

procedure TTransitionFixture.Setup;
begin
end;

procedure TTransitionFixture.TearDown;
begin
end;

procedure TTransitionFixture.IdentityTransitionIsNotChange;
var
  transition: TTransition;
begin
  transition := TTransition.Create( 1, 1, 0, TEqualityComparer<Integer>.Default );
  Assert.IsTrue( transition.IsReentry );
end;

procedure TTransitionFixture.TransitioningTransitionIsChange;
var
  transition: TTransition;
begin
  transition := TTransition.Create( 1, 2, 0, TEqualityComparer<Integer>.Default );
  Assert.IsFalse( transition.IsReentry );
end;

initialization

TDUnitX.RegisterTestFixture( TTransitionFixture );

end.
