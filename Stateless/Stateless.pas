unit Stateless;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Rtti,
  System.SysUtils,
  System.TypInfo;

type
  TValueArguments = TArray<TValue>;

  /// <summary>
  /// Abstract base StateMachine
  /// </summary>
  TStateMachine = class abstract
  private
    constructor Create( ); // to hide the paramless constructor
  end;

  /// <summary>
  /// Models behaviour as transitions between a finite set of states.
  /// </summary>
  /// <typeparam name="TState">The type used to represent the states.</typeparam>
  /// <typeparam name="TTrigger">The type used to represent the triggers that cause state transitions.</typeparam>
  TStateMachine<TState, TTrigger> = class( TStateMachine )
  public type
    IStateComparer   = IEqualityComparer<TState>;
    ITriggerComparer = IEqualityComparer<TTrigger>;

    /// <summary>
    /// Describes a state transition.
    /// </summary>
    TTransition = record
    private
      FStateComparer       : IStateComparer;
      FSource, FDestination: TState;
      FTrigger             : TTrigger;
      function GetIsReentry: Boolean;
    public
      /// <summary>
      /// Construct a transition.
      /// </summary>
      /// <param name="source">The state transitioned from.</param>
      /// <param name="destination">The state transitioned to.</param>
      /// <param name="trigger">The trigger that caused the transition.</param>
      /// <param name="StateComparer">The state equality comparer</param>
      constructor Create(
        const Source, Destination: TState;
        const Trigger            : TTrigger;
        const StateComparer      : IStateComparer );
      /// <summary>
      /// The state transitioned from.
      /// </summary>
      property Source: TState read FSource;
      /// <summary>
      /// The state transitioned to.
      /// </summary>
      property Destination: TState read FDestination;
      /// <summary>
      /// The trigger that caused the transition.
      /// </summary>
      property Trigger: TTrigger read FTrigger;
      /// <summary>
      /// True if the transition is a re-entry, i.e. the identity transition.
      /// </summary>
      property IsReentry: Boolean read GetIsReentry;
    end;

    TTransitionAction     = TProc<TTransition>;
    TTransitionArgsAction = TProc<TTransition, TValueArguments>;

    /// <summary>
    /// Associates configured parameters with an underlying trigger value.
    /// </summary>
    TTriggerWithParameters = class abstract
    private
      FUnderlyingTrigger: TTrigger;
      FArgumentTypes    : TArray<PTypeInfo>;
    public
      /// <summary>
      /// Create a configured trigger.
      /// </summary>
      /// <param name="underlyingTrigger">Trigger represented by this trigger configuration.</param>
      /// <param name="argumentTypes">The argument types expected by the trigger.</param>
      constructor Create(
        UnderlyingTrigger: TTrigger;
        ArgumentTypes    : TArray<PTypeInfo> );
      /// <summary>
      /// Ensure that the supplied arguments are compatible with those configured for this
      /// trigger.
      /// </summary>
      /// <param name="args"></param>
      procedure ValidateParameters( Args: TValueArguments );
      /// <summary>
      /// Gets the underlying trigger value that has been configured.
      /// </summary>
      property Trigger: TTrigger read FUnderlyingTrigger;
    end;

    /// <summary>
    /// A configured trigger with one required argument.
    /// </summary>
    /// <typeparam name="TArg0">The type of the first argument.</typeparam>
    TTriggerWithParameters<TArg0> = class( TTriggerWithParameters )
    public
      /// <summary>
      /// Create a configured trigger.
      /// </summary>
      /// <param name="underlyingTrigger">Trigger represented by this trigger configuration.</param>
      constructor Create( UnderlyingTrigger: TTrigger );
    end;

    /// <summary>
    /// A configured trigger with two required arguments.
    /// </summary>
    /// <typeparam name="TArg0">The type of the first argument.</typeparam>
    /// <typeparam name="TArg1">The type of the second argument.</typeparam>
    TTriggerWithParameters<TArg0, TArg1> = class( TTriggerWithParameters )
    public
      /// <summary>
      /// Create a configured trigger.
      /// </summary>
      /// <param name="underlyingTrigger">Trigger represented by this trigger configuration.</param>
      constructor Create( UnderlyingTrigger: TTrigger );
    end;

    /// <summary>
    /// A configured trigger with three required arguments.
    /// </summary>
    /// <typeparam name="TArg0">The type of the first argument.</typeparam>
    /// <typeparam name="TArg1">The type of the second argument.</typeparam>
    /// <typeparam name="TArg2">The type of the third argument.</typeparam>
    TTriggerWithParameters<TArg0, TArg1, TArg2> = class( TTriggerWithParameters )
    public
      /// <summary>
      /// Create a configured trigger.
      /// </summary>
      /// <param name="underlyingTrigger">Trigger represented by this trigger configuration.</param>
      constructor Create( UnderlyingTrigger: TTrigger );
    end;
{$IFDEF UNITTEST}
    { this must be } public { for the unit testing }
{$ELSE}
  private
{$ENDIF}
    type

    TTriggerBehaviour = class abstract
    private
      FTrigger: TTrigger;
      FGuard  : TFunc<Boolean>;
      function GetIsGuardConditionMet: Boolean;
    protected
      constructor Create(
        Trigger: TTrigger;
        Guard  : TFunc<Boolean> );
    public
      function ResultsInTransitionFrom(
        Source         : TState;
        Args           : TValueArguments;
        out Destination: TState ): Boolean; virtual; abstract;
      property Trigger: TTrigger read FTrigger;
      property IsGuardConditionMet: Boolean read GetIsGuardConditionMet;
    end;

    TStateRepresentation = class
    private
      FStateComparer    : IStateComparer;
      FTriggerComparer  : ITriggerComparer;
      FState            : TState;
      FSuperState       : TStateRepresentation;
      FSubstates        : TDictionary<TState, TStateRepresentation>;
      FEntryActions     : TList<TTransitionArgsAction>;
      FExitActions      : TList<TTransitionAction>;
      FTriggerBehaviours: TObjectDictionary<TTrigger, TObjectList<TTriggerBehaviour>>;
      procedure SetSuperState( Value: TStateRepresentation );
      function TryFindLocalHandler( const Trigger: TTrigger; out Handler: TTriggerBehaviour ): Boolean;
      procedure ExecuteEntryActions( const Transition: TTransition; Args: TValueArguments );
      procedure ExecuteExitActions( const Transition: TTransition );
    public
      constructor Create(
        const State          : TState;
        const StateComparer  : IStateComparer;
        const TriggerComparer: ITriggerComparer );
      destructor Destroy; override;

      procedure AddEntryAction( const Trigger: TTrigger; Action: TTransitionArgsAction ); overload;
      procedure AddEntryAction( Action: TTransitionArgsAction ); overload;

      procedure AddExitAction( Action: TTransitionAction );

      procedure AddSubstate( SubstateRepresentation: TStateRepresentation );
      procedure AddTriggerBehaviour( TriggerBehaviour: TTriggerBehaviour );

      procedure Enters(
        const Transition: TTransition;
        const Args      : TValueArguments );
      procedure Exits( const Transition: TTransition );
      function IsIncludedIn( const State: TState ): Boolean;
      function Includes( const State: TState ): Boolean;

      function CanHandle( const Trigger: TTrigger ): Boolean;
      function PermittedTriggers: TArray<TTrigger>;
      function TryFindHandler(
        const Trigger: TTrigger;
        out Handler  : TTriggerBehaviour ): Boolean;

      property SuperState: TStateRepresentation read FSuperState write SetSuperState;
      property UnderlyingState: TState read FState;
    end;

    TIgnoredTriggerBehaviour = class( TTriggerBehaviour )
    public
      constructor Create(
        Trigger: TTrigger;
        Guard  : TFunc<Boolean> );
      function ResultsInTransitionFrom(
        Source         : TState;
        Args           : TValueArguments;
        out Destination: TState ): Boolean; override;
    end;

    TTransitioningTriggerBehaviour = class( TTriggerBehaviour )
    private
      FDestination: TState;
    public
      constructor Create(
        const Trigger    : TTrigger;
        const Destination: TState;
        const Guard      : TFunc<Boolean> );
      function ResultsInTransitionFrom(
        Source         : TState;
        Args           : TValueArguments;
        out Destination: TState ): Boolean; override;
    end;

    TDynamicTriggerBehaviour = class( TTriggerBehaviour )
    private
      FDestination: TFunc<TValueArguments, TState>;
    public
      constructor Create(
        const Trigger    : TTrigger;
        const Destination: TFunc<TValueArguments, TState>;
        const Guard      : TFunc<Boolean> );
      function ResultsInTransitionFrom(
        Source         : TState;
        Args           : TValueArguments;
        out Destination: TState ): Boolean; override;
    end;
  public type
    /// <summary>
    /// The configuration for a single state value.
    /// </summary>
    TStateConfiguration = record
    private
      class var __NoGuard: TFunc<Boolean>;
      class function GetNoGuard: TFunc<Boolean>; static;
      class property _NoGuard: TFunc<Boolean> read GetNoGuard;
    private
      FStateComparer : IStateComparer;
      FRepresentation: TStateRepresentation;
      FLookup        : TFunc<TState, TStateRepresentation>;
    private
      constructor Create(
        Representation: TStateRepresentation;
        Lookup        : TFunc<TState, TStateRepresentation>;
        StateComparer : IStateComparer );

      procedure EnforceNotIdentityTransition( const Destination: TState );

      function InternalPermit(
        const Trigger         : TTrigger;
        const DestinationState: TState ): TStateConfiguration;
      function InternalPermitIf(
        const Trigger         : TTrigger;
        const DestinationState: TState;
        const Guard           : TFunc<Boolean> ): TStateConfiguration;
      // function InternalPermitDynamic(
      // const Trigger                 : TTrigger;
      // const DestinationStateSelector: TFunc<TValueArguments, TState> ): TStateConfiguration; inline;
      function InternalPermitDynamicIf(
        const Trigger                 : TTrigger;
        const DestinationStateSelector: TFunc<TValueArguments, TState>;
        const Guard                   : TFunc<Boolean> ): TStateConfiguration;
    public
      /// <summary>
      /// Ignore the specified trigger when in the configured state.
      /// </summary>
      /// <param name="trigger">The trigger to ignore.</param>
      /// <returns>The receiver.</returns>
      function Ignore( const Trigger: TTrigger ): TStateConfiguration;
      /// <summary>
      /// Ignore the specified trigger when in the configured state, if the guard
      /// returns true..
      /// </summary>
      /// <param name="trigger">The trigger to ignore.</param>
      /// <param name="guard">Function that must return true in order for the
      /// trigger to be ignored.</param>
      /// <returns>The receiver.</returns>
      function IgnoreIf(
        const Trigger: TTrigger;
        const Guard  : TFunc<Boolean> ): TStateConfiguration;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <param name="entryAction">Action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnEntry( const EntryAction: TProc ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <param name="entryAction">Action to execute, providing details of the transition.</param>
      /// <returns>The receiver.</returns>
      function OnEntry( const EntryAction: TTransitionAction ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <param name="entryAction">Action to execute.</param>
      /// <param name="trigger">The trigger by which the state must be entered in order for the action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnEntryFrom(
        const Trigger    : TTrigger;
        const EntryAction: TProc ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <param name="entryAction">Action to execute, providing details of the transition.</param>
      /// <param name="trigger">The trigger by which the state must be entered in order for the action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnEntryFrom(
        const Trigger    : TTrigger;
        const EntryAction: TTransitionAction ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <param name="entryAction">Action to execute, providing details of the transition.</param>
      /// <param name="trigger">The trigger by which the state must be entered in order for the action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnEntryFrom<TArg0>(
        const Trigger    : TTriggerWithParameters<TArg0>;
        const EntryAction: TProc<TArg0> ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <param name="entryAction">Action to execute, providing details of the transition.</param>
      /// <param name="trigger">The trigger by which the state must be entered in order for the action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnEntryFrom<TArg0>(
        const Trigger    : TTriggerWithParameters<TArg0>;
        const EntryAction: TProc<TArg0, TTransition> ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
      /// <param name="entryAction">Action to execute, providing details of the transition.</param>
      /// <param name="trigger">The trigger by which the state must be entered in order for the action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnEntryFrom<TArg0, TArg1>(
        const Trigger    : TTriggerWithParameters<TArg0, TArg1>;
        const EntryAction: TProc<TArg0, TArg1> ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
      /// <param name="entryAction">Action to execute, providing details of the transition.</param>
      /// <param name="trigger">The trigger by which the state must be entered in order for the action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnEntryFrom<TArg0, TArg1>(
        const Trigger    : TTriggerWithParameters<TArg0, TArg1>;
        const EntryAction: TProc<TArg0, TArg1, TTransition> ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
      /// <typeparam name="TArg2">Type of the third trigger argument.</typeparam>
      /// <param name="entryAction">Action to execute, providing details of the transition.</param>
      /// <param name="trigger">The trigger by which the state must be entered in order for the action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnEntryFrom<TArg0, TArg1, TArg2>(
        const Trigger    : TTriggerWithParameters<TArg0, TArg1, TArg2>;
        const EntryAction: TProc<TArg0, TArg1, TArg2> ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning into
      /// the configured state.
      /// </summary>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
      /// <typeparam name="TArg2">Type of the third trigger argument.</typeparam>
      /// <param name="entryAction">Action to execute, providing details of the transition.</param>
      /// <param name="trigger">The trigger by which the state must be entered in order for the action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnEntryFrom<TArg0, TArg1, TArg2>(
        const Trigger    : TTriggerWithParameters<TArg0, TArg1, TArg2>;
        const EntryAction: TProc<TArg0, TArg1, TArg2, TTransition> ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning from
      /// the configured state.
      /// </summary>
      /// <param name="exitAction">Action to execute.</param>
      /// <returns>The receiver.</returns>
      function OnExit( const ExitAction: TProc ): TStateConfiguration; overload;
      /// <summary>
      /// Specify an action that will execute when transitioning from
      /// the configured state.
      /// </summary>
      /// <param name="exitAction">Action to execute, providing details of the transition.</param>
      /// <returns>The receiver.</returns>
      function OnExit( const ExitAction: TTransitionAction ): TStateConfiguration; overload;

      /// <summary>
      /// Accept the specified trigger and transition to the destination state.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationState">The state that the trigger will cause a
      /// transition to.</param>
      /// <returns>The reciever.</returns>
      function Permit(
        const Trigger         : TTrigger;
        const DestinationState: TState ): TStateConfiguration;
      /// <summary>
      /// Accept the specified trigger and transition to the destination state.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationState">The state that the trigger will cause a
      /// transition to.</param>
      /// <param name="guard">Function that must return true in order for the
      /// trigger to be accepted.</param>
      /// <returns>The reciever.</returns>
      function PermitIf(
        const Trigger         : TTrigger;
        const DestinationState: TState;
        const Guard           : TFunc<Boolean> ): TStateConfiguration;
      /// <summary>
      /// Accept the specified trigger and transition to the destination state, calculated
      /// dynamically by the supplied function.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationStateSelector">Function to calculate the state
      /// that the trigger will cause a transition to.</param>
      /// <returns>The reciever.</returns>
      function PermitDynamic(
        const Trigger                 : TTrigger;
        const DestinationStateSelector: TFunc<TState> ): TStateConfiguration; overload;
      /// <summary>
      /// Accept the specified trigger and transition to the destination state, calculated
      /// dynamically by the supplied function.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationStateSelector">Function to calculate the state
      /// that the trigger will cause a transition to.</param>
      /// <returns>The reciever.</returns>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      function PermitDynamic<TArg0>(
        const Trigger                 : TTriggerWithParameters<TArg0>;
        const DestinationStateSelector: TFunc<TArg0, TState> ): TStateConfiguration; overload;
      /// <summary>
      /// Accept the specified trigger and transition to the destination state, calculated
      /// dynamically by the supplied function.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationStateSelector">Function to calculate the state
      /// that the trigger will cause a transition to.</param>
      /// <returns>The reciever.</returns>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
      function PermitDynamic<TArg0, TArg1>(
        const Trigger                 : TTriggerWithParameters<TArg0, TArg1>;
        const DestinationStateSelector: TFunc<TArg0, TArg1, TState> ): TStateConfiguration; overload;
      /// <summary>
      /// Accept the specified trigger and transition to the destination state, calculated
      /// dynamically by the supplied function.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationStateSelector">Function to calculate the state
      /// that the trigger will cause a transition to.</param>
      /// <returns>The reciever.</returns>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
      /// <typeparam name="TArg2">Type of the third trigger argument.</typeparam>
      function PermitDynamic<TArg0, TArg1, TArg2>(
        const Trigger                 : TTriggerWithParameters<TArg0, TArg1, TArg2>;
        const DestinationStateSelector: TFunc<TArg0, TArg1, TArg2, TState> ): TStateConfiguration; overload;
      /// <summary>
      /// Accept the specified trigger and transition to the destination state, calculated
      /// dynamically by the supplied function.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationStateSelector">Function to calculate the state
      /// that the trigger will cause a transition to.</param>
      /// <param name="guard">Function that must return true in order for the
      /// trigger to be accepted.</param>
      /// <returns>The reciever.</returns>
      function PermitDynamicIf(
        const Trigger                 : TTrigger;
        const DestinationStateSelector: TFunc<TState>;
        const Guard                   : TFunc<Boolean> ): TStateConfiguration; overload;
      /// <summary>
      /// Accept the specified trigger and transition to the destination state, calculated
      /// dynamically by the supplied function.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationStateSelector">Function to calculate the state
      /// that the trigger will cause a transition to.</param>
      /// <param name="guard">Function that must return true in order for the
      /// trigger to be accepted.</param>
      /// <returns>The reciever.</returns>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      function PermitDynamicIf<TArg0>(
        const Trigger                 : TTriggerWithParameters<TArg0>;
        const DestinationStateSelector: TFunc<TArg0, TState>;
        const Guard                   : TFunc<Boolean> ): TStateConfiguration; overload;
      /// <summary>
      /// Accept the specified trigger and transition to the destination state, calculated
      /// dynamically by the supplied function.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationStateSelector">Function to calculate the state
      /// that the trigger will cause a transition to.</param>
      /// <param name="guard">Function that must return true in order for the
      /// trigger to be accepted.</param>
      /// <returns>The reciever.</returns>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
      function PermitDynamicIf<TArg0, TArg1>(
        const Trigger                 : TTriggerWithParameters<TArg0, TArg1>;
        const DestinationStateSelector: TFunc<TArg0, TArg1, TState>;
        const Guard                   : TFunc<Boolean> ): TStateConfiguration; overload;
      /// <summary>
      /// Accept the specified trigger and transition to the destination state, calculated
      /// dynamically by the supplied function.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="destinationStateSelector">Function to calculate the state
      /// that the trigger will cause a transition to.</param>
      /// <returns>The reciever.</returns>
      /// <param name="guard">Function that must return true in order for the
      /// trigger to be accepted.</param>
      /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
      /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
      /// <typeparam name="TArg2">Type of the third trigger argument.</typeparam>
      function PermitDynamicIf<TArg0, TArg1, TArg2>(
        const Trigger                 : TTriggerWithParameters<TArg0, TArg1, TArg2>;
        const DestinationStateSelector: TFunc<TArg0, TArg1, TArg2, TState>;
        const Guard                   : TFunc<Boolean> ): TStateConfiguration; overload;
      /// <summary>
      /// Accept the specified trigger, execute exit actions and re-execute entry actions.
      /// Reentry behaves as though the configured state transitions to an identical sibling state.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <returns>The reciever.</returns>
      /// <remarks>
      /// Applies to the current state only. Will not re-execute superstate actions, or
      /// cause actions to execute transitioning between super- and sub-states.
      /// </remarks>
      function PermitReentry( const Trigger: TTrigger ): TStateConfiguration;
      /// <summary>
      /// Accept the specified trigger, execute exit actions and re-execute entry actions.
      /// Reentry behaves as though the configured state transitions to an identical sibling state.
      /// </summary>
      /// <param name="trigger">The accepted trigger.</param>
      /// <param name="guard">Function that must return true in order for the
      /// trigger to be accepted.</param>
      /// <returns>The reciever.</returns>
      /// <remarks>
      /// Applies to the current state only. Will not re-execute superstate actions, or
      /// cause actions to execute transitioning between super- and sub-states.
      /// </remarks>
      function PermitReentryIf(
        const Trigger: TTrigger;
        const Guard  : TFunc<Boolean> ): TStateConfiguration;
      /// <summary>
      /// Sets the superstate that the configured state is a substate of.
      /// </summary>
      /// <remarks>
      /// Substates inherit the allowed transitions of their superstate.
      /// When entering directly into a substate from outside of the superstate,
      /// entry actions for the superstate are executed.
      /// Likewise when leaving from the substate to outside the supserstate,
      /// exit actions for the superstate will execute.
      /// </remarks>
      /// <param name="superstate">The superstate.</param>
      /// <returns>The receiver.</returns>
      function SubstateOf( const SuperState: TState ): TStateConfiguration;
    end;

  private
    FStateComparer         : IStateComparer;
    FTriggerComparer       : ITriggerComparer;
    FStateAccessor         : TFunc<TState>;
    FStateMutuator         : TProc<TState>;
    FStateConfiguration    : TObjectDictionary<TState, TStateRepresentation>;
    FTriggerConfiguration  : TObjectDictionary<TTrigger, TTriggerWithParameters>;
    FUnhandledTriggerAction: TProc<TState, TTrigger>;
    FOnTransitionedActions : TList<TTransitionAction>;
    function GetState: TState;
    procedure InternalFire(
      const Trigger: TTrigger;
      const Args   : TValueArguments );
    procedure SetState( const Value: TState );
    function GetCurrentRepresentation: TStateRepresentation;
    function GetRepresentation( State: TState ): TStateRepresentation; // do not const the argument!
    function GetPermittedTriggers: TArray<TTrigger>;
    procedure SaveTriggerConfiguration( Trigger: TTriggerWithParameters );
    class procedure DefaultUnhandledTriggerAction(
      State  : TState;
      Trigger: TTrigger ); // do not const the arguments!
  protected
    property CurrentRepresentation: TStateRepresentation read GetCurrentRepresentation;
  public { Constructors / Destructors }
    /// <summary>
    /// Construct a state machine.
    /// </summary>
    /// <param name="initialState">The initial state.</param>
    constructor Create(
      const InitialState   : TState;
      const StateComparer  : IStateComparer = nil;
      const TriggerComparer: ITriggerComparer = nil ); overload;
    /// <summary>
    /// Construct a state machine with external state storage.
    /// </summary>
    /// <param name="stateAccessor">A function that will be called to read the current state value.</param>
    /// <param name="stateMutator">An action that will be called to write new state values.</param>
    constructor Create(
      StateAccessor        : TFunc<TState>;
      StateMutuator        : TProc<TState>;
      const StateComparer  : IStateComparer = nil;
      const TriggerComparer: ITriggerComparer = nil ); overload;
    destructor Destroy; override;

  public { Methods }
    /// <summary>
    /// Returns true if <paramref name="trigger"/> can be fired
    /// in the current state.
    /// </summary>
    /// <param name="trigger">Trigger to test.</param>
    /// <returns>True if the trigger can be fired, false otherwise.</returns>
    function CanFire( const Trigger: TTrigger ): Boolean;
    /// <summary>
    /// Begin configuration of the entry/exit actions and allowed transitions
    /// when the state machine is in a particular state.
    /// </summary>
    /// <param name="state">The state to configure.</param>
    /// <returns>A configuration object through which the state can be configured.</returns>
    function Configure( const State: TState ): TStateConfiguration;
    /// <summary>
    /// Transition from the current state via the specified trigger.
    /// The target state is determined by the configuration of the current state.
    /// Actions associated with leaving the current state and entering the new one
    /// will be invoked.
    /// </summary>
    /// <param name="trigger">The trigger to fire.</param>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> The current state does
    /// not allow the trigger to be fired.</exception>
    procedure Fire( const Trigger: TTrigger ); overload;
    /// <summary>
    /// Transition from the current state via the specified trigger.
    /// The target state is determined by the configuration of the current state.
    /// Actions associated with leaving the current state and entering the new one
    /// will be invoked.
    /// </summary>
    /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
    /// <param name="trigger">The trigger to fire.</param>
    /// <param name="arg0">The first argument.</param>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> The current state does
    /// not allow the trigger to be fired.</exception>
    procedure Fire<TArg0>(
      const Trigger: TTriggerWithParameters<TArg0>;
      const Arg0   : TArg0 ); overload;
    /// <summary>
    /// Transition from the current state via the specified trigger.
    /// The target state is determined by the configuration of the current state.
    /// Actions associated with leaving the current state and entering the new one
    /// will be invoked.
    /// </summary>
    /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
    /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
    /// <param name="arg0">The first argument.</param>
    /// <param name="arg1">The second argument.</param>
    /// <param name="trigger">The trigger to fire.</param>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> The current state does
    /// not allow the trigger to be fired.</exception>
    procedure Fire<TArg0, TArg1>(
      const Trigger: TTriggerWithParameters<TArg0, TArg1>;
      const Arg0   : TArg0;
      const Arg1   : TArg1 ); overload;
    /// <summary>
    /// Transition from the current state via the specified trigger.
    /// The target state is determined by the configuration of the current state.
    /// Actions associated with leaving the current state and entering the new one
    /// will be invoked.
    /// </summary>
    /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
    /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
    /// <typeparam name="TArg2">Type of the third trigger argument.</typeparam>
    /// <param name="arg0">The first argument.</param>
    /// <param name="arg1">The second argument.</param>
    /// <param name="arg2">The third argument.</param>
    /// <param name="trigger">The trigger to fire.</param>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> The current state does
    /// not allow the trigger to be fired.</exception>
    procedure Fire<TArg0, TArg1, TArg2>(
      const Trigger: TTriggerWithParameters<TArg0, TArg1, TArg2>;
      const Arg0   : TArg0;
      const Arg1   : TArg1;
      const Arg2   : TArg2 ); overload;
    /// <summary>
    /// Determine if the state machine is in the supplied state.
    /// </summary>
    /// <param name="state">The state to test for.</param>
    /// <returns>True if the current state is equal to, or a substate of,
    /// the supplied state.</returns>
    function IsInState( const State: TState ): Boolean;
    /// <summary>
    /// Registers a callback that will be invoked every time the statemachine
    /// transitions from one state into another.
    /// </summary>
    /// <param name="onTransitionAction">The action to execute, accepting the details
    /// of the transition.</param>
    procedure OnTransitioned( const OnTransitionAction: TTransitionAction );
    /// <summary>
    /// Override the default behaviour of throwing an exception when an unhandled trigger
    /// is fired.
    /// </summary>
    /// <param name="unhandledTriggerAction">An action to call when an unhandled trigger is fired.</param>
    procedure OnUnhandledTriggerAction( UnhandledTriggerAction: TProc<TState, TTrigger> );
    /// <summary>
    /// Specify the arguments that must be supplied when a specific trigger is fired.
    /// </summary>
    /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
    /// <param name="trigger">The underlying trigger value.</param>
    /// <returns>An object that can be passed to the Fire() method in order to
    /// fire the parameterised trigger.</returns>
    function SetTriggerParameters<TArg0>( const Trigger: TTrigger ): TTriggerWithParameters<TArg0>; overload;
    // <summary>
    /// Specify the arguments that must be supplied when a specific trigger is fired.
    /// </summary>
    /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
    /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
    /// <param name="trigger">The underlying trigger value.</param>
    /// <returns>An object that can be passed to the Fire() method in order to
    /// fire the parameterised trigger.</returns>
    function SetTriggerParameters<TArg0, TArg1>( const Trigger: TTrigger ): TTriggerWithParameters<TArg0, TArg1>; overload;
    /// <summary>
    /// Specify the arguments that must be supplied when a specific trigger is fired.
    /// </summary>
    /// <typeparam name="TArg0">Type of the first trigger argument.</typeparam>
    /// <typeparam name="TArg1">Type of the second trigger argument.</typeparam>
    /// <typeparam name="TArg2">Type of the third trigger argument.</typeparam>
    /// <param name="trigger">The underlying trigger value.</param>
    /// <returns>An object that can be passed to the Fire() method in order to
    /// fire the parameterised trigger.</returns>
    function SetTriggerParameters<TArg0, TArg1, TArg2>( const Trigger: TTrigger ): TTriggerWithParameters<TArg0, TArg1, TArg2>; overload;

    function ToString( ): string; override;
  public { Properties }
    /// <summary>
    /// The currently-permissible trigger values.
    /// </summary>
    property PermittedTriggers: TArray<TTrigger> read GetPermittedTriggers;
    /// <summary>
    /// The current state.
    /// </summary>
    property State: TState read GetState;
  end;

  TParameterConversion = class abstract
  public
    class function Unpack<T>( const Args: TValueArguments; const AIndex: Integer ): T;
    class procedure Validate( const Args: TValueArguments; const Expected: TArray<PTypeInfo> );
  end;

resourcestring
  ArgumentCountMismatch = 'Argument count mismatch.';
  ArgumentTypeMismatch = 'Argument type mismatch.';
  CannotReconfigureParameters = 'Cannot reconfigure parameters.';
  NoTransitionsPermitted = 'No transitions permitted.';
  MultipleTransitionsPermitted = 'Multiple transitions permitted.';
  SelfTransitionsEitherIgnoredOrReentrant = 'Self transitions either ignored or reentrant.';

implementation

uses
  Stateless.Utils;

{ TStateMachine<TState, TTrigger> }

constructor TStateMachine<TState, TTrigger>.Create(
  const InitialState   : TState;
  const StateComparer  : IStateComparer;
  const TriggerComparer: ITriggerComparer );
var
  LState: TState;
begin
  LState := InitialState;
  Create(
    function: TState
    begin
      Result := LState;
    end,
    procedure( Value: TState )
    begin
      LState := Value;
    end,
    StateComparer,
    TriggerComparer );
end;

function TStateMachine<TState, TTrigger>.CanFire( const Trigger: TTrigger ): Boolean;
begin
  Result := CurrentRepresentation.CanHandle( Trigger );
end;

function TStateMachine<TState, TTrigger>.Configure( const State: TState ): TStateConfiguration;
begin
  Result := TStateConfiguration.Create(
    GetRepresentation( State ),
    GetRepresentation,
    FStateComparer );
end;

constructor TStateMachine<TState, TTrigger>.Create(
  StateAccessor        : TFunc<TState>;
  StateMutuator        : TProc<TState>;
  const StateComparer  : IStateComparer;
  const TriggerComparer: ITriggerComparer );
begin
  inherited Create;
  FStateAccessor := StateAccessor;
  FStateMutuator := StateMutuator;

  if Assigned( StateComparer )
  then
    FStateComparer := StateComparer
  else
    FStateComparer := TEqualityComparer<TState>.Default;

  if Assigned( TriggerComparer )
  then
    FTriggerComparer := TriggerComparer
  else
    FTriggerComparer := TEqualityComparer<TTrigger>.Default;

  FStateConfiguration := TObjectDictionary<TState, TStateRepresentation>.Create(
    [ doOwnsValues ],
    FStateComparer );
  FTriggerConfiguration := TObjectDictionary<TTrigger, TTriggerWithParameters>.Create(
    [ doOwnsValues ],
    FTriggerComparer );

  FOnTransitionedActions := TList<TTransitionAction>.Create( );

  FUnhandledTriggerAction := DefaultUnhandledTriggerAction;
end;

class procedure TStateMachine<TState, TTrigger>.DefaultUnhandledTriggerAction(
  State  : TState;
  Trigger: TTrigger );
begin
  raise EInvalidOpException.Create( NoTransitionsPermitted );
end;

destructor TStateMachine<TState, TTrigger>.Destroy;
begin
  FStateConfiguration.Free;
  FTriggerConfiguration.Free;
  FOnTransitionedActions.Free;
  inherited;
end;

function TStateMachine<TState, TTrigger>.GetCurrentRepresentation: TStateRepresentation;
begin
  Result := GetRepresentation( State );
end;

function TStateMachine<TState, TTrigger>.GetPermittedTriggers: TArray<TTrigger>;
begin
  Result := CurrentRepresentation.PermittedTriggers;
end;

function TStateMachine<TState, TTrigger>.GetRepresentation( State: TState ): TStateRepresentation;
begin
  if not FStateConfiguration.TryGetValue( State, Result )
  then
    begin
      Result := TStateRepresentation.Create(
        State,
        FStateComparer,
        FTriggerComparer );
      FStateConfiguration.Add( State, Result );
    end;
end;

function TStateMachine<TState, TTrigger>.GetState: TState;
begin
  Result := FStateAccessor( );
end;

function TStateMachine<TState, TTrigger>.IsInState( const State: TState ): Boolean;
begin
  Result := CurrentRepresentation.IsIncludedIn( State );
end;

procedure TStateMachine<TState, TTrigger>.OnTransitioned( const OnTransitionAction: TTransitionAction );
begin
  FOnTransitionedActions.Add( OnTransitionAction );
end;

procedure TStateMachine<TState, TTrigger>.OnUnhandledTriggerAction( UnhandledTriggerAction: TProc<TState, TTrigger> );
begin
  FUnhandledTriggerAction := Enforce.ArgumentNotNull < TProc < TState, TTrigger >> ( UnhandledTriggerAction, 'UnhandledTriggerAction' );
end;

procedure TStateMachine<TState, TTrigger>.SaveTriggerConfiguration( Trigger: TTriggerWithParameters );
begin
  if FTriggerConfiguration.ContainsKey( Trigger.Trigger )
  then
    begin
      raise EInvalidOpException.Create( CannotReconfigureParameters );
    end;

  FTriggerConfiguration.Add( Trigger.Trigger, Trigger );
end;

procedure TStateMachine<TState, TTrigger>.SetState( const Value: TState );
begin
  FStateMutuator( Value );
end;

function TStateMachine<TState, TTrigger>.SetTriggerParameters<TArg0, TArg1, TArg2>( const Trigger: TTrigger ): TTriggerWithParameters<TArg0, TArg1, TArg2>;
var
  LConfig: TTriggerWithParameters<TArg0, TArg1, TArg2>;
begin
  LConfig := TTriggerWithParameters<TArg0, TArg1, TArg2>.Create( Trigger );
  try
    SaveTriggerConfiguration( LConfig );
    Result  := LConfig;
    LConfig := nil;
  finally
    LConfig.Free;
  end;
end;

function TStateMachine<TState, TTrigger>.SetTriggerParameters<TArg0, TArg1>( const Trigger: TTrigger ): TTriggerWithParameters<TArg0, TArg1>;
var
  LConfig: TTriggerWithParameters<TArg0, TArg1>;
begin
  LConfig := TTriggerWithParameters<TArg0, TArg1>.Create( Trigger );
  try
    SaveTriggerConfiguration( LConfig );
    Result  := LConfig;
    LConfig := nil;
  finally
    LConfig.Free;
  end;
end;

function TStateMachine<TState, TTrigger>.SetTriggerParameters<TArg0>( const Trigger: TTrigger ): TTriggerWithParameters<TArg0>;
var
  LConfig: TTriggerWithParameters<TArg0>;
begin
  LConfig := TTriggerWithParameters<TArg0>.Create( Trigger );
  try
    SaveTriggerConfiguration( LConfig );
    Result  := LConfig;
    LConfig := nil;
  finally
    LConfig.Free;
  end;
end;

function TStateMachine<TState, TTrigger>.ToString: string;
begin
  Result := string.Format( 'StateMachine { State = %s, PermittedTriggers = { %s } }',
    [ TValue.From<TState>( State ).ToString, string.Join( ', ', TArray.Cast<TTrigger, string>( PermittedTriggers,
    function( const Trigger: TTrigger ): string
    begin
      Result := TValue.From<TTrigger>( Trigger ).ToString;
    end ) ) ] );
end;

{ TStateMachine<TState, TTrigger>.TStateRepresentation }

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.AddEntryAction( Action: TTransitionArgsAction );
begin
  FEntryActions.Add( Enforce.ArgumentNotNull<TTransitionArgsAction>( Action, 'Action' ) );
end;

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.AddEntryAction(
  const Trigger: TTrigger;
  Action       : TTransitionArgsAction );
begin
  Enforce.ArgumentNotNull<TTransitionArgsAction>( Action, 'Action' );
  AddEntryAction(
    procedure( T: TTransition; a: TValueArguments )
    begin
      if FTriggerComparer.Equals( T.Trigger, Trigger )
      then
        Action( T, a );
    end );
end;

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.AddExitAction( Action: TTransitionAction );
begin
  FExitActions.Add( Enforce.ArgumentNotNull<TTransitionAction>( Action, 'Action' ) );
end;

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.AddSubstate( SubstateRepresentation: TStateRepresentation );
begin
  FSubstates.Add( SubstateRepresentation.UnderlyingState, SubstateRepresentation );
end;

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.AddTriggerBehaviour( TriggerBehaviour: TTriggerBehaviour );
var
  LAllowed: TObjectList<TTriggerBehaviour>;
begin
  if not FTriggerBehaviours.TryGetValue( TriggerBehaviour.Trigger, LAllowed )
  then
    begin
      LAllowed := TObjectList<TTriggerBehaviour>.Create( True );
      FTriggerBehaviours.Add( TriggerBehaviour.Trigger, LAllowed );
    end;
  LAllowed.Add( TriggerBehaviour );
end;

function TStateMachine<TState, TTrigger>.TStateRepresentation.CanHandle( const Trigger: TTrigger ): Boolean;
var
  LBehaviour: TTriggerBehaviour;
begin
  Result := TryFindHandler( Trigger, LBehaviour );
end;

constructor TStateMachine<TState, TTrigger>.TStateRepresentation.Create(
  const State          : TState;
  const StateComparer  : IStateComparer;
  const TriggerComparer: ITriggerComparer );
begin
  inherited Create;
  FState             := State;
  FStateComparer     := StateComparer;
  FTriggerComparer   := TriggerComparer;
  FSubstates         := TDictionary<TState, TStateRepresentation>.Create( StateComparer );
  FEntryActions      := TList<TTransitionArgsAction>.Create( );
  FExitActions       := TList<TTransitionAction>.Create( );
  FTriggerBehaviours := TObjectDictionary < TTrigger, TObjectList < TTriggerBehaviour >>.Create( [ doOwnsValues ], FTriggerComparer );
end;

destructor TStateMachine<TState, TTrigger>.TStateRepresentation.Destroy;
begin
  FSubstates.Free;
  FEntryActions.Free;
  FExitActions.Free;
  FTriggerBehaviours.Free;
  inherited;
end;

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.Enters( const Transition: TTransition; const Args: TValueArguments );
begin
  if Transition.IsReentry
  then
    ExecuteEntryActions( Transition, Args )
  else if not Includes( Transition.Source )
  then
    begin
      if Assigned( FSuperState )
      then
        FSuperState.Enters( Transition, Args );
      ExecuteEntryActions( Transition, Args );
    end;
end;

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.ExecuteEntryActions( const Transition: TTransition; Args: TValueArguments );
var
  LAction: TTransitionArgsAction;
begin
  for LAction in FEntryActions do
    begin
      LAction( Transition, Args );
    end;
end;

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.ExecuteExitActions( const Transition: TTransition );
var
  LAction: TTransitionAction;
begin
  for LAction in FExitActions do
    begin
      LAction( Transition );
    end;
end;

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.Exits( const Transition: TTransition );
begin
  if Transition.IsReentry
  then
    ExecuteExitActions( Transition )
  else if not Includes( Transition.Destination )
  then
    begin
      ExecuteExitActions( Transition );
      if Assigned( FSuperState )
      then
        FSuperState.Exits( Transition );
    end;
end;

function TStateMachine<TState, TTrigger>.TStateRepresentation.Includes( const State: TState ): Boolean;
var
  LSubstate: TStateRepresentation;
begin
  if FStateComparer.Equals( FState, State )
  then
    Exit( True );

  for LSubstate in FSubstates.Values do
    begin
      if LSubstate.Includes( State )
      then
        Exit( True );
    end;
  Result := False;
end;

function TStateMachine<TState, TTrigger>.TStateRepresentation.IsIncludedIn( const State: TState ): Boolean;
begin
  Result := FStateComparer.Equals( FState, State ) or Assigned( FSuperState ) and FSuperState.IsIncludedIn( State );
end;

function TStateMachine<TState, TTrigger>.TStateRepresentation.PermittedTriggers: TArray<TTrigger>;
var
  LItem     : TPair<TTrigger, TObjectList<TTriggerBehaviour>>;
  LBehaviour: TTriggerBehaviour;
  LTrigger  : TTrigger;
begin
  Result := [ ];
  for LItem in FTriggerBehaviours do
    begin
      for LBehaviour in LItem.Value do
        begin
          if LBehaviour.IsGuardConditionMet
          then
            begin
              Result := Result + [ LItem.Key ];
              Break;
            end;
        end;
    end;

  if Assigned( FSuperState )
  then
    begin
      Result := TArray.Distinct<TTrigger>(
        TArray.Union<TTrigger>( Result, FSuperState.PermittedTriggers ),
        FTriggerComparer );
    end;
end;

procedure TStateMachine<TState, TTrigger>.TStateRepresentation.SetSuperState( Value: TStateRepresentation );
begin
  FSuperState := Value;
end;

function TStateMachine<TState, TTrigger>.TStateRepresentation.TryFindHandler( const Trigger: TTrigger; out Handler: TTriggerBehaviour ): Boolean;
begin
  Result := TryFindLocalHandler( Trigger, Handler ) or Assigned( FSuperState ) and FSuperState.TryFindHandler( Trigger, Handler );
end;

function TStateMachine<TState, TTrigger>.TStateRepresentation.TryFindLocalHandler( const Trigger: TTrigger; out Handler: TTriggerBehaviour ): Boolean;
var
  LPossible : TObjectList<TTriggerBehaviour>;
  LBehaviour: TTriggerBehaviour;
  LActual   : TTriggerBehaviour;
begin
  if not FTriggerBehaviours.TryGetValue( Trigger, LPossible )
  then
    begin
      Handler := nil;
      Exit( False );
    end;

  LActual := nil;

  for LBehaviour in LPossible do
    begin
      if LBehaviour.GetIsGuardConditionMet
      then
        begin
          if Assigned( LActual )
          then
            raise EInvalidOpException.Create( MultipleTransitionsPermitted );
          LActual := LBehaviour;
        end;
    end;

  Handler := LActual;
  Result  := Assigned( Handler );
end;

{ TStateMachine<TState, TTrigger>.TStateConfiguration }

constructor TStateMachine<TState, TTrigger>.TStateConfiguration.Create(
  Representation: TStateRepresentation;
  Lookup        : TFunc<TState, TStateRepresentation>;
  StateComparer : IStateComparer );
begin
  FRepresentation := Enforce.ArgumentNotNull( Representation, 'Representation' );
  FLookup         := Enforce.ArgumentNotNull < TFunc < TState, TStateRepresentation >> ( Lookup, 'Lookup' );
  FStateComparer  := StateComparer;
end;

procedure TStateMachine<TState, TTrigger>.TStateConfiguration.EnforceNotIdentityTransition( const Destination: TState );
begin
  if FStateComparer.Equals( FRepresentation.UnderlyingState, Destination )
  then
    begin
      // Logger.Fatal( SelfTransitionsEitherIgnoredOrReentrant );
      raise EArgumentException.Create( SelfTransitionsEitherIgnoredOrReentrant );
    end;
end;

procedure TStateMachine<TState, TTrigger>.Fire( const Trigger: TTrigger );
begin
  InternalFire( Trigger, [ ] );
end;

procedure TStateMachine<TState, TTrigger>.Fire<TArg0, TArg1, TArg2>( const Trigger: TTriggerWithParameters<TArg0, TArg1, TArg2>; const Arg0: TArg0;
  const Arg1: TArg1; const Arg2: TArg2 );
begin
  InternalFire( Trigger.Trigger, [ TValue.From<TArg0>( Arg0 ), TValue.From<TArg1>( Arg1 ), TValue.From<TArg2>( Arg2 ) ] );
end;

procedure TStateMachine<TState, TTrigger>.Fire<TArg0, TArg1>( const Trigger: TTriggerWithParameters<TArg0, TArg1>; const Arg0: TArg0; const Arg1: TArg1 );
begin
  InternalFire( Trigger.Trigger, [ TValue.From<TArg0>( Arg0 ), TValue.From<TArg1>( Arg1 ) ] );
end;

procedure TStateMachine<TState, TTrigger>.Fire<TArg0>( const Trigger: TTriggerWithParameters<TArg0>; const Arg0: TArg0 );
begin
  InternalFire( Trigger.Trigger, [ TValue.From<TArg0>( Arg0 ) ] );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.Ignore( const Trigger: TTrigger ): TStateConfiguration;
begin
  Result := IgnoreIf( Trigger, _NoGuard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.IgnoreIf( const Trigger: TTrigger; const Guard: TFunc<Boolean> ): TStateConfiguration;
begin
  Result := Self;
  FRepresentation.AddTriggerBehaviour( TIgnoredTriggerBehaviour.Create( Trigger, Guard ) );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.InternalPermit( const Trigger: TTrigger; const DestinationState: TState ): TStateConfiguration;
begin
  Result := InternalPermitIf(
    Trigger,
    DestinationState,
    _NoGuard );
end;

// function TStateMachine<TState, TTrigger>.TStateConfiguration.InternalPermitDynamic(
// const Trigger                 : TTrigger;
// const DestinationStateSelector: TFunc<TValueArguments, TState> ): TStateConfiguration;
// begin
// Result := InternalPermitDynamicIf( Trigger, DestinationStateSelector, _NoGuard );
// end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.InternalPermitDynamicIf(
  const Trigger                 : TTrigger;
  const DestinationStateSelector: TFunc<TValueArguments, TState>;
  const Guard                   : TFunc<Boolean> ): TStateConfiguration;
begin
  Result := Self;
  FRepresentation.AddTriggerBehaviour( TDynamicTriggerBehaviour.Create( Trigger, DestinationStateSelector, Guard ) );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.InternalPermitIf(
  const Trigger         : TTrigger;
  const DestinationState: TState;
  const Guard           : TFunc<Boolean> ): TStateConfiguration;
begin
  Result := Self;
  FRepresentation.AddTriggerBehaviour( TTransitioningTriggerBehaviour.Create( Trigger, DestinationState, Guard ) );
end;

procedure TStateMachine<TState, TTrigger>.InternalFire(
  const Trigger: TTrigger;
  const Args   : TValueArguments );
var
  LConfiguration       : TTriggerWithParameters;
  LTriggerBehaviour    : TTriggerBehaviour;
  LSource, LDestination: TState;
  LTransition          : TTransition;
  LAction              : TTransitionAction;
begin
  if FTriggerConfiguration.TryGetValue( Trigger, LConfiguration )
  then
    LConfiguration.ValidateParameters( Args );

  LSource := State;

  if not CurrentRepresentation.TryFindHandler( Trigger, LTriggerBehaviour )
  then
    begin
      FUnhandledTriggerAction( LSource, Trigger );
      Exit;
    end;

  if LTriggerBehaviour.ResultsInTransitionFrom( LSource, Args, LDestination )
  then
    begin
      LTransition := TTransition.Create(
        LSource,
        LDestination,
        Trigger,
        FStateComparer );
      CurrentRepresentation.Exits( LTransition );
      SetState( LTransition.Destination );

      for LAction in FOnTransitionedActions do
        begin
          LAction( LTransition );
        end;

      CurrentRepresentation.Enters(
        LTransition,
        Args );
    end;
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntry( const EntryAction: TTransitionAction ): TStateConfiguration;
begin
  Result := Self;
  FRepresentation.AddEntryAction(
    procedure( T: TTransition; a: TValueArguments )
    begin
      EntryAction( T );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntry( const EntryAction: TProc ): TStateConfiguration;
begin
  Result := OnEntry(
    procedure( T: TTransition )
    begin
      EntryAction( );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntryFrom(
  const Trigger    : TTrigger;
  const EntryAction: TProc ): TStateConfiguration;
begin
  Result := OnEntryFrom( Trigger,
    procedure( T: TTransition )
    begin
      EntryAction( );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntryFrom(
  const Trigger    : TTrigger;
  const EntryAction: TTransitionAction ): TStateConfiguration;
begin
  Result := Self;
  FRepresentation.AddEntryAction( Trigger,
    procedure( T: TTransition; a: TValueArguments )
    begin
      EntryAction( T );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntryFrom<TArg0, TArg1, TArg2>( const Trigger: TTriggerWithParameters<TArg0, TArg1, TArg2>;
  const EntryAction: TProc<TArg0, TArg1, TArg2> ): TStateConfiguration;
begin
  Result := OnEntryFrom<TArg0, TArg1, TArg2>( Trigger,
    procedure( a0: TArg0; a1: TArg1; a2: TArg2; T: TTransition )
    begin
      EntryAction(
        a0,
        a1,
        a2 );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntryFrom<TArg0, TArg1, TArg2>( const Trigger: TTriggerWithParameters<TArg0, TArg1, TArg2>;
  const EntryAction: TProc<TArg0, TArg1, TArg2, TTransition> ): TStateConfiguration;
begin
  Result := Self;
  FRepresentation.AddEntryAction( Trigger.Trigger,
    procedure( T: TTransition; a: TValueArguments )
    begin
      EntryAction(
        TParameterConversion.Unpack<TArg0>( a, 0 ),
        TParameterConversion.Unpack<TArg1>( a, 1 ),
        TParameterConversion.Unpack<TArg2>( a, 2 ),
        T );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntryFrom<TArg0, TArg1>( const Trigger: TTriggerWithParameters<TArg0, TArg1>;
  const EntryAction: TProc<TArg0, TArg1, TTransition> ): TStateConfiguration;
begin
  Result := Self;
  FRepresentation.AddEntryAction( Trigger.Trigger,
    procedure( T: TTransition; a: TValueArguments )
    begin
      EntryAction(
        TParameterConversion.Unpack<TArg0>( a, 0 ),
        TParameterConversion.Unpack<TArg1>( a, 1 ),
        T );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntryFrom<TArg0, TArg1>(
  const Trigger    : TTriggerWithParameters<TArg0, TArg1>;
  const EntryAction: TProc<TArg0, TArg1> ): TStateConfiguration;
begin
  Result := OnEntryFrom<TArg0, TArg1>( Trigger,
    procedure( a0: TArg0; a1: TArg1; T: TTransition )
    begin
      EntryAction(
        a0,
        a1 );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntryFrom<TArg0>(
  const Trigger    : TTriggerWithParameters<TArg0>;
  const EntryAction: TProc<TArg0, TTransition> ): TStateConfiguration;
begin
  Result := Self;
  FRepresentation.AddEntryAction( Trigger.Trigger,
    procedure( T: TTransition; a: TValueArguments )
    begin
      EntryAction(
        TParameterConversion.Unpack<TArg0>( a, 0 ),
        T );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnEntryFrom<TArg0>(
  const Trigger    : TTriggerWithParameters<TArg0>;
  const EntryAction: TProc<TArg0> ): TStateConfiguration;
begin
  Result := OnEntryFrom<TArg0>( Trigger,
    procedure( a0: TArg0; T: TTransition )
    begin
      EntryAction( a0 );
    end );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnExit( const ExitAction: TTransitionAction ): TStateConfiguration;
begin
  Result := Self;
  FRepresentation.AddExitAction( ExitAction );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.Permit(
  const Trigger         : TTrigger;
  const DestinationState: TState ): TStateConfiguration;
begin
  EnforceNotIdentityTransition( DestinationState );
  Result := InternalPermit(
    Trigger,
    DestinationState );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitDynamic(
  const Trigger                 : TTrigger;
  const DestinationStateSelector: TFunc<TState> ): TStateConfiguration;
begin
  Result := PermitDynamicIf(
    Trigger,
    DestinationStateSelector,
    _NoGuard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitDynamic<TArg0, TArg1, TArg2>(
  const Trigger                 : TTriggerWithParameters<TArg0, TArg1, TArg2>;
  const DestinationStateSelector: TFunc<TArg0, TArg1, TArg2, TState> ): TStateConfiguration;
begin
  Result := PermitDynamicIf<TArg0, TArg1, TArg2>(
    Trigger,
    DestinationStateSelector,
    _NoGuard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitDynamicIf<TArg0, TArg1, TArg2>(
  const Trigger                 : TTriggerWithParameters<TArg0, TArg1, TArg2>;
  const DestinationStateSelector: TFunc<TArg0, TArg1, TArg2, TState>;
  const Guard                   : TFunc<Boolean> ): TStateConfiguration;
begin
  Result := InternalPermitDynamicIf( Trigger.Trigger,
    function( a: TValueArguments ): TState
    begin
      Result := DestinationStateSelector(
        TParameterConversion.Unpack<TArg0>( a, 0 ),
        TParameterConversion.Unpack<TArg1>( a, 1 ),
        TParameterConversion.Unpack<TArg2>( a, 2 ) );
    end, Guard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitDynamicIf<TArg0, TArg1>( const Trigger: TTriggerWithParameters<TArg0, TArg1>;
  const DestinationStateSelector: TFunc<TArg0, TArg1, TState>; const Guard: TFunc<Boolean> ): TStateConfiguration;
begin
  Result := InternalPermitDynamicIf( Trigger.Trigger,
    function( a: TValueArguments ): TState
    begin
      Result := DestinationStateSelector(
        TParameterConversion.Unpack<TArg0>( a, 0 ),
        TParameterConversion.Unpack<TArg1>( a, 1 ) );
    end, Guard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitDynamic<TArg0, TArg1>( const Trigger: TTriggerWithParameters<TArg0, TArg1>;
  const DestinationStateSelector: TFunc<TArg0, TArg1, TState> ): TStateConfiguration;
begin
  Result := PermitDynamicIf<TArg0, TArg1>( Trigger, DestinationStateSelector, _NoGuard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitDynamic<TArg0>( const Trigger: TTriggerWithParameters<TArg0>;
  const DestinationStateSelector: TFunc<TArg0, TState> ): TStateConfiguration;
begin
  Result := PermitDynamicIf<TArg0>( Trigger, DestinationStateSelector, _NoGuard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitDynamicIf( const Trigger: TTrigger; const DestinationStateSelector: TFunc<TState>;
  const Guard: TFunc<Boolean> ): TStateConfiguration;
begin
  Result := InternalPermitDynamicIf( Trigger,
    function( a: TValueArguments ): TState
    begin
      Result := DestinationStateSelector( );
    end, Guard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitDynamicIf<TArg0>( const Trigger: TTriggerWithParameters<TArg0>;
  const DestinationStateSelector: TFunc<TArg0, TState>; const Guard: TFunc<Boolean> ): TStateConfiguration;
begin
  Result := InternalPermitDynamicIf( Trigger.Trigger,
    function( a: TValueArguments ): TState
    begin
      Result := DestinationStateSelector( TParameterConversion.Unpack<TArg0>( a, 0 ) );
    end, Guard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitIf( const Trigger: TTrigger; const DestinationState: TState;
  const Guard: TFunc<Boolean> ): TStateConfiguration;
begin
  EnforceNotIdentityTransition( DestinationState );
  Result := InternalPermitIf( Trigger, DestinationState, Guard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitReentry( const Trigger: TTrigger ): TStateConfiguration;
begin
  Result := InternalPermit( Trigger, FRepresentation.UnderlyingState );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.PermitReentryIf( const Trigger: TTrigger; const Guard: TFunc<Boolean> ): TStateConfiguration;
begin
  Result := InternalPermitIf( Trigger, FRepresentation.UnderlyingState, Guard );
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.SubstateOf( const SuperState: TState ): TStateConfiguration;
var
  SuperRepresentation: TStateRepresentation;
begin
  Result                     := Self;
  SuperRepresentation        := FLookup( SuperState );
  FRepresentation.SuperState := SuperRepresentation;
  SuperRepresentation.AddSubstate( FRepresentation );
end;

class function TStateMachine<TState, TTrigger>.TStateConfiguration.GetNoGuard: TFunc<Boolean>;
begin
  if not Assigned( __NoGuard )
  then
    __NoGuard := (
      function: Boolean
      begin
        Result := True;
      end );
  Result := __NoGuard;
end;

function TStateMachine<TState, TTrigger>.TStateConfiguration.OnExit( const ExitAction: TProc ): TStateConfiguration;
begin
  Result := OnExit(
    procedure( T: TTransition )
    begin
      ExitAction( );
    end );
end;

{ TStateMachine<TState, TTrigger>.TTransition }

constructor TStateMachine<TState, TTrigger>.TTransition.Create(
  const Source, Destination: TState;
  const Trigger            : TTrigger;
  const StateComparer      : IStateComparer );
begin
  FSource        := Source;
  FDestination   := Destination;
  FTrigger       := Trigger;
  FStateComparer := StateComparer
end;

function TStateMachine<TState, TTrigger>.TTransition.GetIsReentry: Boolean;
begin
  Result := FStateComparer.Equals( FSource, FDestination );
end;

{ TStateMachine<TState, TTrigger>.TTriggerBehaviour }

constructor TStateMachine<TState, TTrigger>.TTriggerBehaviour.Create( Trigger: TTrigger; Guard: TFunc<Boolean> );
begin
  inherited Create;
  FTrigger := Trigger;
  FGuard   := Enforce.ArgumentNotNull < TFunc < Boolean >> ( Guard, 'Guard' );
end;

function TStateMachine<TState, TTrigger>.TTriggerBehaviour.GetIsGuardConditionMet: Boolean;
begin
  Result := FGuard( );
end;

{ TStateMachine<TState, TTrigger>.TIgnoredTriggerBehaviour }

constructor TStateMachine<TState, TTrigger>.TIgnoredTriggerBehaviour.Create( Trigger: TTrigger; Guard: TFunc<Boolean> );
begin
  inherited;
end;

function TStateMachine<TState, TTrigger>.TIgnoredTriggerBehaviour.ResultsInTransitionFrom( Source: TState; Args: TValueArguments;
  out Destination: TState ): Boolean;
begin
  Destination := default ( TState );
  Result      := False;
end;

{ TStateMachine<TState, TTrigger>.TTriggerWithParameters }

constructor TStateMachine<TState, TTrigger>.TTriggerWithParameters.Create( UnderlyingTrigger: TTrigger; ArgumentTypes: TArray<PTypeInfo> );
begin
  inherited Create;
  FUnderlyingTrigger := UnderlyingTrigger;
  FArgumentTypes     := ArgumentTypes;
end;

procedure TStateMachine<TState, TTrigger>.TTriggerWithParameters.ValidateParameters( Args: TValueArguments );
begin
  TParameterConversion.Validate( Args, FArgumentTypes );
end;

{ TStateMachine<TState, TTrigger>.TTriggerWithParameters<TArg0> }

constructor TStateMachine<TState, TTrigger>.TTriggerWithParameters<TArg0>.Create( UnderlyingTrigger: TTrigger );
begin
  inherited Create( UnderlyingTrigger, [ TypeInfo( TArg0 ) ] );
end;

{ TStateMachine<TState, TTrigger>.TTriggerWithParameters<TArg0, TArg1> }

constructor TStateMachine<TState, TTrigger>.TTriggerWithParameters<TArg0, TArg1>.Create( UnderlyingTrigger: TTrigger );
begin
  inherited Create( UnderlyingTrigger, [ TypeInfo( TArg0 ), TypeInfo( TArg1 ) ] );
end;

{ TStateMachine<TState, TTrigger>.TTriggerWithParameters<TArg0, TArg1, TArg2> }

constructor TStateMachine<TState, TTrigger>.TTriggerWithParameters<TArg0, TArg1, TArg2>.Create( UnderlyingTrigger: TTrigger );
begin
  inherited Create( UnderlyingTrigger, [ TypeInfo( TArg0 ), TypeInfo( TArg1 ), TypeInfo( TArg2 ) ] );
end;

{ TStateMachine<TState, TTrigger>.TTransitioningTriggerBehaviour }

constructor TStateMachine<TState, TTrigger>.TTransitioningTriggerBehaviour.Create( const Trigger: TTrigger; const Destination: TState;
  const Guard: TFunc<Boolean> );
begin
  inherited Create( Trigger, Guard );
  FDestination := Destination;
end;

function TStateMachine<TState, TTrigger>.TTransitioningTriggerBehaviour.ResultsInTransitionFrom( Source: TState; Args: TValueArguments;
  out Destination: TState ): Boolean;
begin
  Destination := FDestination;
  Result      := True;
end;

{ TStateMachine<TState, TTrigger>.TDynamicTriggerBehaviour }

constructor TStateMachine<TState, TTrigger>.TDynamicTriggerBehaviour.Create( const Trigger: TTrigger; const Destination: TFunc<TValueArguments, TState>;
  const Guard: TFunc<Boolean> );
begin
  inherited Create( Trigger, Guard );
  FDestination := Destination;
end;

function TStateMachine<TState, TTrigger>.TDynamicTriggerBehaviour.ResultsInTransitionFrom( Source: TState; Args: TValueArguments;
  out Destination: TState ): Boolean;
begin
  Destination := FDestination( Args );
  Result      := True;
end;

{ TParameterConversion }

class function TParameterConversion.Unpack<T>( const Args: TValueArguments; const AIndex: Integer ): T;
var
  Arg: TValue;
begin
  if Length( Args ) <= AIndex
  then
    raise EArgumentException.Create( ArgumentCountMismatch );
  Arg := Args[ AIndex ];
  if not Arg.IsType<T>
  then
    raise EArgumentException.Create( ArgumentTypeMismatch );
  Result := Arg.AsType<T>;
end;

class procedure TParameterConversion.Validate( const Args: TValueArguments; const Expected: TArray<PTypeInfo> );
var
  LIdx: Integer;
begin
  if Length( Args ) <> Length( Expected )
  then
    raise EArgumentException.Create( ArgumentCountMismatch );

  for LIdx := low( Args ) to high( Args ) do
    begin
      if Args[ LIdx ].TypeInfo <> Expected[ LIdx ]
      then
        raise EArgumentException.Create( ArgumentTypeMismatch );
    end;
end;

{ TStateMachine }

constructor TStateMachine.Create;
begin
  inherited;
end;

end.
