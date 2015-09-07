unit Stateless.Tests.StateRepresentationFixture;

interface

uses
  DUnitX.TestFramework,
  Stateless,
  Stateless.Tests.TestMachine;

type

  [ TestFixture ]
  TStateRepresentationFixture = class( TObject )
  private
    stateRepresentation     : TStateRepresentation;
    stateRepresentationOther: TStateRepresentation;
    stateComparer           : TTestMachine.IStateComparer;
    triggerComparer         : TTestMachine.ITriggerComparer;

    super, sub: TStateRepresentation;
  protected
    function CreateRepresentation( const State: TState ): TStateRepresentation;
    procedure CreateSuperSubstatePair( out super, sub: TStateRepresentation );
  public
    [ Setup ]
    procedure Setup;
    [ Teardown ]
    procedure Teardown;
    [ Test ]
    procedure UponEntering_EnteringActionsExecuted( );
    [ Test ]
    procedure UponLeaving_EnteringActionsNotExecuted( );
    [ Test ]
    procedure UponLeaving_LeavingActionsExecuted( );
    [ Test ]
    procedure UponEntering_LeavingActionsNotExecuted( );
    [ Test ]
    procedure IncludesUnderlyingState( );
    [ Test ]
    procedure DoesNotIncludeUnrelatedState( );
    [ Test ]
    procedure IncludesSubstate( );
    [ Test ]
    procedure DoesNotIncludeSuperstate( );
    [ Test ]
    procedure IsIncludedInUnderlyingState( );
    [ Test ]
    procedure IsNotIncludedInUnrelatedState( );
    [ Test ]
    procedure IsNotIncludedInSubstate( );
    [ Test ]
    procedure IsIncludedInSuperstate( );
    [ Test ]
    procedure WhenEnteringSubstate_SuperstateEntryActionsExecuteBeforeSubstate( );
    [ Test ]
    procedure WhenExitingSubstate_SubstateEntryActionsExecuteBeforeSuperstate( );
    [ Test ]
    procedure WhenEnteringSuperstateFromSubstate_SuperstateEntryActionsAreNotExecuted( );
    [ Test ]
    procedure WhenExitingSubstateToSuperstate_SuperstateExitActionsAreNotExecuted( );
  end;

implementation

uses
  System.Generics.Defaults,
  System.SysUtils,
  Stateless.Types;

{ TStateRepresentationFixture }

procedure TStateRepresentationFixture.CreateSuperSubstatePair( out super, sub: TStateRepresentation );
begin
  super := CreateRepresentation( TState.A );
  sub   := CreateRepresentation( TState.B );
  super.AddSubstate( sub );
  sub.SuperState := super;
end;

procedure TStateRepresentationFixture.DoesNotIncludeSuperstate;
begin
  stateRepresentation            := CreateRepresentation( TState.B );
  stateRepresentationOther       := CreateRepresentation( TState.A );
  stateRepresentation.SuperState := stateRepresentationOther;
  Assert.IsFalse( stateRepresentation.Includes( TState.A ) );
end;

procedure TStateRepresentationFixture.DoesNotIncludeUnrelatedState;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  Assert.IsFalse( stateRepresentation.Includes( TState.C ) );
end;

procedure TStateRepresentationFixture.IncludesSubstate;
begin
  stateRepresentation      := CreateRepresentation( TState.B );
  stateRepresentationOther := CreateRepresentation( TState.C );
  stateRepresentation.AddSubstate( stateRepresentationOther );
  Assert.IsTrue( stateRepresentation.Includes( TState.C ) );
end;

procedure TStateRepresentationFixture.IncludesUnderlyingState;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  Assert.IsTrue( stateRepresentation.Includes( TState.B ) );
end;

procedure TStateRepresentationFixture.IsIncludedInSuperstate;
begin
  stateRepresentation            := CreateRepresentation( TState.B );
  stateRepresentationOther       := CreateRepresentation( TState.C );
  stateRepresentation.SuperState := stateRepresentationOther;
  Assert.IsTrue( stateRepresentation.IsIncludedIn( TState.C ) );
end;

procedure TStateRepresentationFixture.IsIncludedInUnderlyingState;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  Assert.IsTrue( stateRepresentation.IsIncludedIn( TState.B ) );
end;

procedure TStateRepresentationFixture.IsNotIncludedInSubstate;
begin
  stateRepresentation      := CreateRepresentation( TState.B );
  stateRepresentationOther := CreateRepresentation( TState.C );
  stateRepresentation.AddSubstate( stateRepresentationOther );
  Assert.IsFalse( stateRepresentation.IsIncludedIn( TState.C ) );
end;

procedure TStateRepresentationFixture.IsNotIncludedInUnrelatedState;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  Assert.IsFalse( stateRepresentation.IsIncludedIn( TState.C ) );
end;

procedure TStateRepresentationFixture.Setup;
begin
  stateComparer   := TEqualityComparer<TState>.Default;
  triggerComparer := TEqualityComparer<TTrigger>.Default;
end;

function TStateRepresentationFixture.CreateRepresentation( const State: TState ): TStateRepresentation;
begin
  Result := TStateRepresentation.Create( State, stateComparer, triggerComparer );
end;

procedure TStateRepresentationFixture.Teardown;
begin
  FreeAndNil( stateRepresentation );
  FreeAndNil( super );
  FreeAndNil( sub );
end;

procedure TStateRepresentationFixture.UponEntering_EnteringActionsExecuted;
var
  Transition      : TTransition;
  actualTransition: Nullable<TTransition>;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  Transition          := TTransition.Create( TState.A, TState.B, TTrigger.X, stateComparer );
  stateRepresentation.AddEntryAction(
    procedure( t: TTransition; A: TValueArguments )
    begin
      actualTransition := t;
    end );
  stateRepresentation.Enters( Transition, [ ] );
  Assert.IsTrue( actualTransition.HasValue );
  Assert.AreEqual( Transition, actualTransition.Value );
end;

procedure TStateRepresentationFixture.UponLeaving_EnteringActionsNotExecuted;
var
  Transition      : TTransition;
  actualTransition: Nullable<TTransition>;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  Transition          := TTransition.Create( TState.A, TState.B, TTrigger.X, stateComparer );
  stateRepresentation.AddEntryAction(
    procedure( t: TTransition; A: TValueArguments )
    begin
      actualTransition := t;
    end );
  stateRepresentation.Exits( Transition );
  Assert.IsFalse( actualTransition.HasValue );
end;

procedure TStateRepresentationFixture.UponLeaving_LeavingActionsExecuted;
var
  Transition      : TTransition;
  actualTransition: Nullable<TTransition>;
begin
  stateRepresentation := CreateRepresentation( TState.A );
  Transition          := TTransition.Create( TState.A, TState.B, TTrigger.X, stateComparer );
  stateRepresentation.AddExitAction(
    procedure( t: TTransition )
    begin
      actualTransition := t;
    end );
  stateRepresentation.Exits( Transition );
  Assert.IsTrue( actualTransition.HasValue );
  Assert.AreEqual( Transition, actualTransition.Value );
end;

procedure TStateRepresentationFixture.WhenEnteringSubstate_SuperstateEntryActionsExecuteBeforeSubstate;
var
  order, subOrder, superOrder: Integer;
  Transition                 : TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  order      := 0;
  subOrder   := 0;
  superOrder := 0;
  super.AddEntryAction(
    procedure( t: TTransition; A: TValueArguments )
    begin
      Inc( order );
      superOrder := order;
    end );
  sub.AddEntryAction(
    procedure( t: TTransition; A: TValueArguments )
    begin
      Inc( order );
      subOrder := order;
    end );
  Transition := TTransition.Create( TState.C, sub.UnderlyingState, TTrigger.X, stateComparer );
  sub.Enters( Transition, [ ] );
  Assert.IsTrue( superOrder < subOrder );
end;

procedure TStateRepresentationFixture.WhenEnteringSuperstateFromSubstate_SuperstateEntryActionsAreNotExecuted;
var
  Executed  : Boolean;
  Transition: TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  Executed := False;
  super.AddEntryAction(
    procedure( t: TTransition; A: TValueArguments )
    begin
      Executed := True;
    end );
  Transition := TTransition.Create( sub.UnderlyingState, super.UnderlyingState, TTrigger.X, stateComparer );
  super.Enters( Transition, [ ] );
  Assert.IsFalse( Executed );
end;

procedure TStateRepresentationFixture.WhenExitingSubstateToSuperstate_SuperstateExitActionsAreNotExecuted;
var
  Executed  : Boolean;
  Transition: TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  Executed := False;
  super.AddExitAction(
    procedure( t: TTransition )
    begin
      Executed := True;
    end );
  Transition := TTransition.Create( sub.UnderlyingState, super.UnderlyingState, TTrigger.X, stateComparer );
  sub.Exits( Transition );
  Assert.IsFalse( Executed );
end;

procedure TStateRepresentationFixture.WhenExitingSubstate_SubstateEntryActionsExecuteBeforeSuperstate;
var
  order, subOrder, superOrder: Integer;
  Transition                 : TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  order      := 0;
  subOrder   := 0;
  superOrder := 0;
  super.AddExitAction(
    procedure( t: TTransition )
    begin
      Inc( order );
      superOrder := order;
    end );
  sub.AddExitAction(
    procedure( t: TTransition )
    begin
      Inc( order );
      subOrder := order;
    end );
  Transition := TTransition.Create( sub.UnderlyingState, TState.C, TTrigger.X, stateComparer );
  sub.Exits( Transition );
  Assert.IsTrue( subOrder < superOrder );
end;

procedure TStateRepresentationFixture.UponEntering_LeavingActionsNotExecuted;
var
  Transition      : TTransition;
  actualTransition: Nullable<TTransition>;
begin
  stateRepresentation := CreateRepresentation( TState.A );
  Transition          := TTransition.Create( TState.A, TState.B, TTrigger.X, stateComparer );
  stateRepresentation.AddExitAction(
    procedure( t: TTransition )
    begin
      actualTransition := t;
    end );
  stateRepresentation.Enters( Transition, [ ] );
  Assert.IsFalse( actualTransition.HasValue );
end;

initialization

TDUnitX.RegisterTestFixture( TStateRepresentationFixture );

end.
