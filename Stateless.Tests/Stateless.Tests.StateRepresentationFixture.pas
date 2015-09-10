{************************************************************************
 Copyright 2015 Oliver Münzberg (aka Sir Rufo)

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 Credits:

 Nicholas Blumhardt - https://github.com/nblumhardt/stateless
 ************************************************************************}
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
    procedure WhenTransitioningFromSubToSuperstate_SubstateEntryActionsExecuted( );
    [ Test ]
    procedure WhenTransitioningFromSubToSuperstate_SubstateExitActionsExecuted( );
    [ Test ]
    procedure WhenTransitioningToSuperFromSubstate_SuperEntryActionsNotExecuted( );
    [ Test ]
    procedure WhenTransitioningFromSuperToSubstate_SuperExitActionsNotExecuted( );
    [ Test ]
    procedure WhenEnteringSubstate_SuperEntryActionsExecuted( );
    [ Test ]
    procedure WhenLeavingSubstate_SuperExitActionsExecuted( );
    [ Test ]
    procedure EntryActionsExecuteInOrder( );
    [ Test ]
    procedure ExitActionsExecuteInOrder( );
    [ Test ]
    procedure WhenTransitionExists_TriggerCanBeFired( );
    [ Test ]
    procedure WhenTransitionDoesNotExist_TriggerCannotBeFired( );
    [ Test ]
    procedure WhenTransitionExistsInSupersate_TriggerCanBeFired( );
    [ Test ]
    procedure WhenEnteringSubstate_SuperstateEntryActionsExecuteBeforeSubstate( );
    [ Test ]
    procedure WhenExitingSubstate_SubstateEntryActionsExecuteBeforeSuperstate( );
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

procedure TStateRepresentationFixture.EntryActionsExecuteInOrder;
var
  actual: TArray<Integer>;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  stateRepresentation.AddEntryAction(
    procedure( const t: TTransition; const A: TValueArguments )
    begin
      actual := actual + [ 0 ];
    end );
  stateRepresentation.AddEntryAction(
    procedure( const t: TTransition; const A: TValueArguments )
    begin
      actual := actual + [ 1 ];
    end );
  stateRepresentation.Enters( TTransition.Create( TState.A, TState.B, TTrigger.X, stateComparer ), [ ] );
  Assert.AreEqual( 2, Length( actual ) );
  Assert.AreEqual( 0, actual[ 0 ] );
  Assert.AreEqual( 1, actual[ 1 ] );
end;

procedure TStateRepresentationFixture.ExitActionsExecuteInOrder;
var
  actual: TArray<Integer>;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  stateRepresentation.AddExitAction(
    procedure( const t: TTransition )
    begin
      actual := actual + [ 0 ];
    end );
  stateRepresentation.AddExitAction(
    procedure( const t: TTransition )
    begin
      actual := actual + [ 1 ];
    end );
  stateRepresentation.Exits( TTransition.Create( TState.B, TState.A, TTrigger.X, stateComparer ) );
  Assert.AreEqual( 2, Length( actual ) );
  Assert.AreEqual( 0, actual[ 0 ] );
  Assert.AreEqual( 1, actual[ 1 ] );
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
  FreeAndNil( stateRepresentationOther );
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
    procedure( const t: TTransition; const A: TValueArguments )
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
    procedure( const t: TTransition; const A: TValueArguments )
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
    procedure( const t: TTransition )
    begin
      actualTransition := t;
    end );
  stateRepresentation.Exits( Transition );
  Assert.IsTrue( actualTransition.HasValue );
  Assert.AreEqual( Transition, actualTransition.Value );
end;

procedure TStateRepresentationFixture.WhenEnteringSubstate_SuperEntryActionsExecuted;
var
  Executed  : Boolean;
  Transition: TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  Executed := False;
  super.AddEntryAction(
    procedure( const t: TTransition; const A: TValueArguments )
    begin
      Executed := True;
    end );
  Transition := TTransition.Create( TState.C, sub.UnderlyingState, TTrigger.X, stateComparer );
  sub.Enters( Transition, [ ] );
  Assert.IsTrue( Executed );
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
    procedure( const t: TTransition; const A: TValueArguments )
    begin
      Inc( order );
      superOrder := order;
    end );
  sub.AddEntryAction(
    procedure( const t: TTransition; const A: TValueArguments )
    begin
      Inc( order );
      subOrder := order;
    end );
  Transition := TTransition.Create( TState.C, sub.UnderlyingState, TTrigger.X, stateComparer );
  sub.Enters( Transition, [ ] );
  Assert.IsTrue( superOrder < subOrder );
end;

procedure TStateRepresentationFixture.WhenTransitioningToSuperFromSubstate_SuperEntryActionsNotExecuted;
var
  Executed  : Boolean;
  Transition: TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  Executed := False;
  super.AddEntryAction(
    procedure( const t: TTransition; const A: TValueArguments )
    begin
      Executed := True;
    end );
  Transition := TTransition.Create( sub.UnderlyingState, super.UnderlyingState, TTrigger.X, stateComparer );
  super.Enters( Transition, [ ] );
  Assert.IsFalse( Executed );
end;

procedure TStateRepresentationFixture.WhenTransitioningFromSuperToSubstate_SuperExitActionsNotExecuted;
var
  Executed  : Boolean;
  Transition: TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  Executed := False;
  super.AddExitAction(
    procedure( const t: TTransition )
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
    procedure( const t: TTransition )
    begin
      Inc( order );
      superOrder := order;
    end );
  sub.AddExitAction(
    procedure( const t: TTransition )
    begin
      Inc( order );
      subOrder := order;
    end );
  Transition := TTransition.Create( sub.UnderlyingState, TState.C, TTrigger.X, stateComparer );
  sub.Exits( Transition );
  Assert.IsTrue( subOrder < superOrder );
end;

procedure TStateRepresentationFixture.WhenLeavingSubstate_SuperExitActionsExecuted;
var
  Executed  : Boolean;
  Transition: TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  Executed := False;
  super.AddExitAction(
    procedure( const t: TTransition )
    begin
      Executed := True;
    end );
  Transition := TTransition.Create( sub.UnderlyingState, TState.C, TTrigger.X, stateComparer );
  sub.Exits( Transition );
  Assert.IsTrue( Executed );
end;

procedure TStateRepresentationFixture.WhenTransitionDoesNotExist_TriggerCannotBeFired;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  Assert.IsFalse( stateRepresentation.CanHandle( TTrigger.X ) );
end;

procedure TStateRepresentationFixture.WhenTransitionExistsInSupersate_TriggerCanBeFired;
begin
  CreateSuperSubstatePair( super, sub );
  super.AddTriggerBehaviour( TTestMachine.TIgnoredTriggerBehaviour.Create( TTrigger.X,
    function: Boolean
    begin
      Result := True;
    end ) );
  Assert.IsTrue( sub.CanHandle( TTrigger.X ) );
end;

procedure TStateRepresentationFixture.WhenTransitionExists_TriggerCanBeFired;
begin
  stateRepresentation := CreateRepresentation( TState.B );
  stateRepresentation.AddTriggerBehaviour( TTestMachine.TIgnoredTriggerBehaviour.Create( TTrigger.X,
    function: Boolean
    begin
      Result := True;
    end ) );
  Assert.IsTrue( stateRepresentation.CanHandle( TTrigger.X ) );
end;

procedure TStateRepresentationFixture.WhenTransitioningFromSubToSuperstate_SubstateEntryActionsExecuted;
var
  Executed  : Boolean;
  Transition: TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  Executed := False;
  sub.AddEntryAction(
    procedure( const t: TTransition; const A: TValueArguments )
    begin
      Executed := True;
    end );
  Transition := TTransition.Create( super.UnderlyingState, sub.UnderlyingState, TTrigger.X, stateComparer );
  sub.Enters( Transition, [ ] );
  Assert.IsTrue( Executed );
end;

procedure TStateRepresentationFixture.WhenTransitioningFromSubToSuperstate_SubstateExitActionsExecuted;
var
  Executed  : Boolean;
  Transition: TTransition;
begin
  CreateSuperSubstatePair( super, sub );
  Executed := False;
  sub.AddExitAction(
    procedure( const t: TTransition )
    begin
      Executed := True;
    end );
  Transition := TTransition.Create( sub.UnderlyingState, super.UnderlyingState, TTrigger.X, stateComparer );
  sub.Exits( Transition );
  Assert.IsTrue( Executed );
end;

procedure TStateRepresentationFixture.UponEntering_LeavingActionsNotExecuted;
var
  Transition      : TTransition;
  actualTransition: Nullable<TTransition>;
begin
  stateRepresentation := CreateRepresentation( TState.A );
  Transition          := TTransition.Create( TState.A, TState.B, TTrigger.X, stateComparer );
  stateRepresentation.AddExitAction(
    procedure( const t: TTransition )
    begin
      actualTransition := t;
    end );
  stateRepresentation.Enters( Transition, [ ] );
  Assert.IsFalse( actualTransition.HasValue );
end;

initialization

TDUnitX.RegisterTestFixture( TStateRepresentationFixture );

end.
