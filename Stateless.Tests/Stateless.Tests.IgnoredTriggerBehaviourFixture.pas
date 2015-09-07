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
