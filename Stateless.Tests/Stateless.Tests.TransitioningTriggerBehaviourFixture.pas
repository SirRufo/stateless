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
unit Stateless.Tests.TransitioningTriggerBehaviourFixture;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Stateless,
  Stateless.Types,
  Stateless.Tests.TestMachine;

type

  [ TestFixture ]
  TTransitioningTriggerBehaviourFixture = class( TObject )
  private
    transitioning: TTransitioningTriggerBehaviour;
  public
    [ Setup ]
    procedure Setup;
    [ TearDown ]
    procedure TearDown;

    [ Test ]
    procedure ExposesCorrectUnderlyingTrigger( );
    [ Test ]
    procedure TransitionsToDestinationState( );
    [ Test ]
    procedure WhenGuardConditionFalse_IsGuardConditionMetIsFalse( );
    [ Test ]
    procedure WhenGuardConditionTrue_IsGuardConditionMetIsTrue( );
  end;

implementation

procedure TTransitioningTriggerBehaviourFixture.ExposesCorrectUnderlyingTrigger;
const
  Trigger = TTrigger.X;
  State   = TState.C;
begin
  transitioning := TTransitioningTriggerBehaviour.Create( Trigger, State,
    function: Boolean
    begin
      Result := True;
    end );
  Assert.AreEqual( Trigger, transitioning.Trigger );
end;

procedure TTransitioningTriggerBehaviourFixture.Setup;
begin
end;

procedure TTransitioningTriggerBehaviourFixture.TearDown;
begin
  FreeAndNil( transitioning );
end;

procedure TTransitioningTriggerBehaviourFixture.TransitionsToDestinationState;
const
  Trigger          = TTrigger.X;
  sourceState      = TState.B;
  destinationState = TState.C;
var
  destination: TState;
begin
  transitioning := TTransitioningTriggerBehaviour.Create(
    Trigger,
    destinationState,
    function: Boolean
    begin
      Result := True;
    end );
  Assert.IsTrue( transitioning.ResultsInTransitionFrom( sourceState, [ ], destination ) );
  Assert.AreEqual( destinationState, destination );
end;

procedure TTransitioningTriggerBehaviourFixture.WhenGuardConditionFalse_IsGuardConditionMetIsFalse;
const
  Trigger   = TTrigger.X;
  State     = TState.C;
  Condition = False;
begin
  transitioning := TTransitioningTriggerBehaviour.Create( Trigger, State,
    function: Boolean
    begin
      Result := Condition;
    end );
  Assert.IsFalse( transitioning.IsGuardConditionMet );
end;

procedure TTransitioningTriggerBehaviourFixture.WhenGuardConditionTrue_IsGuardConditionMetIsTrue;
const
  Trigger   = TTrigger.X;
  State     = TState.C;
  Condition = True;
begin
  transitioning := TTransitioningTriggerBehaviour.Create( Trigger, State,
    function: Boolean
    begin
      Result := Condition;
    end );
  Assert.IsTrue( transitioning.IsGuardConditionMet );
end;

initialization

TDUnitX.RegisterTestFixture( TTransitioningTriggerBehaviourFixture );

end.
