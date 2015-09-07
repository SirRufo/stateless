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
unit Stateless.Tests.DynamicTriggerBehaviourFixture;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Stateless,
  Stateless.Tests.TestMachine;

type

  [ TestFixture ]
  TDynamicTriggerBehaviourFixture = class( TObject )
  private
    sm: TTestMachine;
  public
    [ Setup ]
    procedure Setup;
    [ TearDown ]
    procedure TearDown;

    [ Test ]
    procedure DestinationStateIsDynamic( );
    [ Test ]
    procedure DestinationStateIsCalculatedBasedOnTriggerParameters( );
  end;

implementation

procedure TDynamicTriggerBehaviourFixture.Setup;
begin
end;

procedure TDynamicTriggerBehaviourFixture.TearDown;
begin
  FreeAndNil( sm );
end;

procedure TDynamicTriggerBehaviourFixture.DestinationStateIsCalculatedBasedOnTriggerParameters;
const
  InitialState = TState.A;
  DynamicState = TState.B;
  FiredTrigger = TTrigger.X;
begin
  sm := TTestMachine.Create( InitialState );
  sm.Configure( InitialState )
  {} .PermitDynamic( FiredTrigger,
    function: TState
    begin
      Result := DynamicState;
    end );

  sm.Fire( FiredTrigger );

  Assert.AreEqual( DynamicState, sm.State );
end;

procedure TDynamicTriggerBehaviourFixture.DestinationStateIsDynamic;
const
  InitialState     = TState.A;
  DynamicState1    = TState.B;
  DynamicStateElse = TState.C;
  FiredTrigger     = TTrigger.X;
var
  TriggerX: TTestMachine.TTriggerWithParameters<Integer>;
begin
  sm       := TTestMachine.Create( InitialState );
  TriggerX := sm.SetTriggerParameters<Integer>( FiredTrigger );
  sm.Configure( InitialState )
  {} .PermitDynamic<Integer>( TriggerX,
    function( a0: Integer ): TState
    begin
      if a0 = 1
      then
        Result := DynamicState1
      else
        Result := DynamicStateElse;
    end );

  sm.Fire<Integer>( TriggerX, 1 );

  Assert.AreEqual( DynamicState1, sm.State );
end;

initialization

TDUnitX.RegisterTestFixture( TDynamicTriggerBehaviourFixture );

end.
