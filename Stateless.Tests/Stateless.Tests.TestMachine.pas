unit Stateless.Tests.TestMachine;

interface

uses
  Stateless;

type
  TState                         = ( A, B, C );
  TTrigger                       = ( X, Y, Z );
  TTestMachine                   = TStateMachine<TState, TTrigger>;
  TStateRepresentation           = TTestMachine.TStateRepresentation;
  TTransition                    = TTestMachine.TTransition;
  TTransitioningTriggerBehaviour = TTestMachine.TTransitioningTriggerBehaviour;

implementation

end.
