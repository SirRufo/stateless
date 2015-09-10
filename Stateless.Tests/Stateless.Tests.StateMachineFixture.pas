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
unit Stateless.Tests.StateMachineFixture;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Stateless,
  Stateless.Utils,
  Stateless.Tests.TestMachine;

{SCOPEDENUMS ON}
type

  [ TestFixture ]
  TStateMachineFixture = class( TObject )
  private const
    StateA   = 'A';
    StateB   = 'B';
    StateC   = 'C';
    TriggerX = 'X';
    TriggerY = 'Y';
  private
    sm: TTestMachine;
    procedure RunSimpletest<TState, TTransition>( States: TArray<TState>; Transitions: TArray<TTransition> );
  public
    [ Setup ]
    procedure Setup;
    [ TearDown ]
    procedure TearDown;

    [ Test ]
    procedure CanUseReferenceTypeMarkers( );
    [ Test ]
    procedure CanUseValueTypeMarkers( );
    [ Test ]
    procedure InitialStateIsCurrent( );
    [ Test ]
    procedure StateCanBeStoredExternally( );
    [ Test ]
    procedure SubstateIsIncludedInCurrentState( );
    [ Test ]
    procedure WhenInSubstate_TriggerIgnoredInSuperstate_RemainsInSubstate( );
    [ Test ]
    procedure PermittedTriggersIncludeSuperstatePermittedTriggers( );
    [ Test ]
    procedure PermittedTriggersAreDistinctValues( );
    [ Test ]
    procedure AcceptedTriggersRespectGuards( );
    [ Test ]
    procedure WhenDiscriminatedByGuard_ChoosePermittedTransition( );
    [ Test ]
    procedure WhenTriggerIsIgnored_ActionsNotExecuted( );
    [ Test ]
    procedure IfSelfTransitionPermitted_ActionsFire( );
    [ Test ]
    procedure ImplicitReentryIsDisallowed( );
    [ Test ]
    procedure TriggerParametersAreImmutableOnceSet( );
    [ Test ]
    procedure ParametersSuppliedToFireArePassedToEntryAction( );
    [ Test ]
    procedure WhenAnUnhandledTriggerIsFired_TheProvidedHandlerIsCalledWithStateAndTrigger( );
    [ Test ]
    procedure WhenATransitionOccurs_TheOnTransitionEventFires( );
    [ Test ]
    procedure TheOnTransitionEventFiresBeforeTheOnEntryEvent( );
  end;

implementation

procedure TStateMachineFixture.Setup;
begin
end;

procedure TStateMachineFixture.TearDown;
begin
  FreeAndNil( sm );
end;

procedure TStateMachineFixture.TheOnTransitionEventFiresBeforeTheOnEntryEvent;
const
  OnExit                           = 'OnExit';
  OnEntry                          = 'OnEntry';
  OnTransitioned                   = 'OnTransitioned';
  ExpectedOrdering: TArray<string> = [ OnExit, OnTransitioned, OnEntry ];
var
  ActualOrdering: TArray<string>;
  LIdx          : Integer;
begin
  ActualOrdering := [ ];

  sm := TTestMachine.Create( TState.B );
  sm.Configure( TState.B )
  {} .Permit( TTrigger.X, TState.A )
  {} .OnExit(
    procedure
    begin
      ActualOrdering := ActualOrdering + [ OnExit ];
    end );
  sm.Configure( TState.A )
  {} .OnEntry(
    procedure
    begin
      ActualOrdering := ActualOrdering + [ OnEntry ];
    end );
  sm.OnTransitioned(
    procedure( const t: TTestMachine.TTransition )
    begin
      ActualOrdering := ActualOrdering + [ OnTransitioned ];
    end );

  sm.Fire( TTrigger.X );

  Assert.AreEqual( Length( ExpectedOrdering ), Length( ActualOrdering ) );
  for LIdx := low( ExpectedOrdering ) to high( ExpectedOrdering ) do
    begin
      Assert.AreEqual( ExpectedOrdering[ LIdx ], ActualOrdering[ LIdx ] );
    end;
end;

procedure TStateMachineFixture.AcceptedTriggersRespectGuards;
var
  permitted: TArray<TTrigger>;
begin
  sm := TTestMachine.Create( TState.B );
  sm.Configure( TState.B ).PermitIf( TTrigger.X, TState.A,
    function: Boolean
    begin
      Result := false;
    end );
  permitted := sm.PermittedTriggers;
  Assert.AreEqual( 0, Length( permitted ) );
end;

procedure TStateMachineFixture.CanUseReferenceTypeMarkers;
begin
  RunSimpletest<string, string>(
    [ StateA, StateB, StateC ],
    [ TriggerX, TriggerY ] );
end;

procedure TStateMachineFixture.CanUseValueTypeMarkers;
begin
  RunSimpletest<TState, TTrigger>(
    TEnum.GetValues<TState>( ),
    TEnum.GetValues<TTrigger>( ) );
end;

procedure TStateMachineFixture.IfSelfTransitionPermitted_ActionsFire;
var
  fired: Boolean;
begin
  sm    := TTestMachine.Create( TState.B );
  fired := false;

  sm.Configure( TState.B )
  {} .OnEntry(
    procedure
    begin
      fired := true;
    end )
  {} .PermitReentry( TTrigger.X );

  sm.Fire( TTrigger.X );

  Assert.IsTrue( fired );
end;

procedure TStateMachineFixture.ImplicitReentryIsDisallowed;
begin
  sm := TTestMachine.Create( TState.B );
  Assert.WillRaise(
    procedure
    begin
      sm.Configure( TState.B ).Permit( TTrigger.X, TState.B );
    end,
    EArgumentException );
end;

procedure TStateMachineFixture.InitialStateIsCurrent;
var
  Initial: TState;
begin
  Initial := TState.B;
  sm      := TTestMachine.Create( Initial );
  Assert.AreEqual( Initial, sm.State );
end;

procedure TStateMachineFixture.ParametersSuppliedToFireArePassedToEntryAction;
const
  suppliedArg0 = 'something';
  suppliedArg1 = 42;
var
  X        : TTestMachine.TTriggerWithParameters<string, Integer>;
  entryArg0: string;
  entryArg1: Integer;
begin
  sm := TTestMachine.Create( TState.B );
  X  := sm.SetTriggerParameters<string, Integer>( TTrigger.X );

  sm.Configure( TState.B )
  {} .Permit( TTrigger.X, TState.C );

  entryArg0 := '';
  entryArg1 := 0;

  sm.Configure( TState.C )
  {} .OnEntryFrom<string, Integer>( X,
    procedure( const Arg0: string; const Arg1: Integer )
    begin
      entryArg0 := Arg0;
      entryArg1 := Arg1;
    end );

  sm.Fire<string, Integer>( X, suppliedArg0, suppliedArg1 );

  Assert.AreEqual( suppliedArg0, entryArg0 );
  Assert.AreEqual( suppliedArg1, entryArg1 );
end;

procedure TStateMachineFixture.PermittedTriggersAreDistinctValues;
var
  permitted: TArray<TTrigger>;
begin
  sm := TTestMachine.Create( TState.B );
  sm.Configure( TState.B ).SubstateOf( TState.C ).Permit( TTrigger.X, TState.A );
  sm.Configure( TState.C ).Permit( TTrigger.X, TState.B );

  permitted := sm.PermittedTriggers;

  Assert.AreEqual( 1, Length( permitted ) );
  Assert.AreEqual( TTrigger.X, permitted[ 0 ] );
end;

procedure TStateMachineFixture.PermittedTriggersIncludeSuperstatePermittedTriggers;
var
  permitted: TArray<TTrigger>;
begin
  sm := TTestMachine.Create( TState.B );
  sm.Configure( TState.A ).Permit( TTrigger.Z, TState.B );
  sm.Configure( TState.B ).SubstateOf( TState.C ).Permit( TTrigger.X, TState.A );
  sm.Configure( TState.C ).Permit( TTrigger.Y, TState.A );

  permitted := sm.PermittedTriggers;
  Assert.Contains( permitted, TTrigger.X );
  Assert.Contains( permitted, TTrigger.Y );
  Assert.DoesNotContain( permitted, TTrigger.Z );
end;

procedure TStateMachineFixture.RunSimpletest<TState, TTransition>(
  States     : TArray<TState>;
  Transitions: TArray<TTransition> );
var
  A, B: TState;
  X   : TTransition;
  sm  : TStateMachine<TState, TTransition>;
begin
  A  := States[ 0 ];
  B  := States[ 1 ];
  X  := Transitions[ 0 ];
  sm := TStateMachine<TState, TTransition>.Create( A );
  try
    sm.Configure( A ).Permit( X, B );
    sm.Fire( X );
    Assert.AreEqual( B, sm.State );
  finally
    sm.Free;
  end;
end;

procedure TStateMachineFixture.StateCanBeStoredExternally;
var
  State: TState;
begin
  State := TState.B;
  sm    := TTestMachine.Create(
    function: TState
    begin
      Result := State;
    end,
    procedure( const s: TState )
    begin
      State := s;
    end );
  sm.Configure( TState.B ).Permit( TTrigger.X, TState.C );
  Assert.AreEqual( TState.B, sm.State );
  Assert.AreEqual( TState.B, State );
  sm.Fire( TTrigger.X );
  Assert.AreEqual( TState.C, sm.State );
  Assert.AreEqual( TState.C, State );
end;

procedure TStateMachineFixture.SubstateIsIncludedInCurrentState;
begin
  sm := TTestMachine.Create( TState.B );
  sm.Configure( TState.B ).SubstateOf( TState.C );
  Assert.AreEqual( TState.B, sm.State );
  Assert.IsTrue( sm.IsInState( TState.C ) );
end;

procedure TStateMachineFixture.TriggerParametersAreImmutableOnceSet;
begin
  sm := TTestMachine.Create( TState.B );
  sm.SetTriggerParameters<string, Integer>( TTrigger.X );
  Assert.WillRaise(
    procedure
    begin
      sm.SetTriggerParameters<string>( TTrigger.X );
    end,
    EInvalidOpException );
end;

procedure TStateMachineFixture.WhenAnUnhandledTriggerIsFired_TheProvidedHandlerIsCalledWithStateAndTrigger;
const
  InitialState = TState.B;
  FiredTrigger = TTrigger.Z;
var
  State  : TState;
  Trigger: TTrigger;
begin
  sm := TTestMachine.Create( InitialState );

  State   := default ( TState );
  Trigger := default ( TTrigger );

  Assert.AreNotEqual( InitialState, State );
  Assert.AreNotEqual( FiredTrigger, Trigger );

  sm.OnUnhandledTriggerAction(
    procedure( const s: TState; const t: TTrigger )
    begin
      State := s;
      Trigger := t;
    end );

  sm.Fire( FiredTrigger );

  Assert.AreEqual( InitialState, State );
  Assert.AreEqual( FiredTrigger, Trigger );
end;

procedure TStateMachineFixture.WhenATransitionOccurs_TheOnTransitionEventFires;
const
  InitialState     = TState.B;
  FiredTrigger     = TTrigger.X;
  DestinationState = TState.A;
var
  Transition: TTestMachine.TTransition;
begin
  sm := TTestMachine.Create( InitialState );
  sm.Configure( InitialState )
  {} .Permit( FiredTrigger, DestinationState );

  sm.OnTransitioned(
    procedure( const t: TTestMachine.TTransition )
    begin
      Transition := t;
    end );

  sm.Fire( FiredTrigger );

  Assert.AreEqual( FiredTrigger, Transition.Trigger );
  Assert.AreEqual( InitialState, Transition.Source );
  Assert.AreEqual( DestinationState, Transition.Destination );
end;

procedure TStateMachineFixture.WhenDiscriminatedByGuard_ChoosePermittedTransition;
begin
  sm := TTestMachine.Create( TState.B );
  sm.Configure( TState.B )
  {} .PermitIf( TTrigger.X, TState.A,
    function: Boolean
    begin
      Result := false;
    end )
  {} .PermitIf( TTrigger.X, TState.C,
    function: Boolean
    begin
      Result := true;
    end );

  sm.Fire( TTrigger.X );

  Assert.AreEqual( TState.C, sm.State );
end;

procedure TStateMachineFixture.WhenInSubstate_TriggerIgnoredInSuperstate_RemainsInSubstate;
begin
  sm := TTestMachine.Create( TState.B );
  sm.Configure( TState.B ).SubstateOf( TState.C );
  sm.Configure( TState.C ).Ignore( TTrigger.X );
  sm.Fire( TTrigger.X );
  Assert.AreEqual( TState.B, sm.State );
end;

procedure TStateMachineFixture.WhenTriggerIsIgnored_ActionsNotExecuted;
var
  fired: Boolean;
begin
  sm    := TTestMachine.Create( TState.B );
  fired := false;

  sm.Configure( TState.B )
  {} .OnEntry(
    procedure
    begin
      fired := true;
    end )
  {} .Ignore( TTrigger.X );

  sm.Fire( TTrigger.X );

  Assert.IsFalse( fired );
end;

initialization

TDUnitX.RegisterTestFixture( TStateMachineFixture );

end.
