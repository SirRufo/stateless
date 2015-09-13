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
