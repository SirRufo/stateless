unit Bug;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  StateLess;

type
  TBug = class
  public type
    TState = ( Open, Assigned, Deferred, Resolved, Closed );
  private type
    TTrigger         = ( Assign, Defer, Resolve, Close );
    TBugStateMachine = TStateMachine<TState, TTrigger>;
  private { Fields }
    FAssignee     : string;
    FState        : TState;
    FTitle        : string;
    FMachine      : TBugStateMachine;
    FAssignTrigger: TBugStateMachine.TTriggerWithParameters<string>;
  private { Methods }
    function GetState: TState;
    procedure SetState( Value: TState );
    procedure OnAssigned( Assignee: string );
    procedure OnDeassigned( );
    procedure OnDeferred( );
    function GetCanAssign: Boolean;
    procedure SendEmailToAssignee( const AMessage: string );
  public { Constructors / Destructors }
    constructor Create(
      const Title   : string;
      const State   : TState = TState.Open;
      const Assignee: string = '' );
    destructor Destroy; override;
  public { Methods }
    procedure Assign( const Assignee: string );
    procedure Close( );
    procedure Defer( );
    function ToString: string; override;
  public { Properties }
    property Assignee : string read FAssignee;
    property CanAssign: Boolean read GetCanAssign;
    property State    : TState read GetState;
    property Title    : string read FTitle;
  end;

implementation

uses
  System.Rtti;

{ TBug }

procedure TBug.Assign( const Assignee: string );
begin
  FMachine.Fire<string>( FAssignTrigger, Assignee );
end;

procedure TBug.Close;
begin
  FMachine.Fire( TTrigger.Close );
end;

constructor TBug.Create(
  const Title   : string;
  const State   : TState;
  const Assignee: string );
begin
  inherited Create;
  FTitle         := Title;
  FState         := State;
  FAssignee      := Assignee;
  FMachine       := TBugStateMachine.Create( GetState, SetState );
  FAssignTrigger := FMachine.SetTriggerParameters<string>( TTrigger.Assign );

  FMachine.Configure( TState.Open )
  {} .Permit( TTrigger.Assign, TState.Assigned );

  FMachine.Configure( TState.Assigned )
  {} .SubstateOf( TState.Open )
  {} .OnEntryFrom<string>( FAssignTrigger, OnAssigned )
  {} .PermitReentry( TTrigger.Assign )
  {} .Permit( TTrigger.Close, TState.Closed )
  {} .Permit( TTrigger.Defer, TState.Deferred )
  {} .OnExit( OnDeassigned );

  FMachine.Configure( TState.Deferred )
  {} .SubstateOf( TState.Open )
  {} .OnEntry( OnDeferred )
  {} .Permit( TTrigger.Assign, TState.Assigned );
end;

procedure TBug.Defer;
begin
  FMachine.Fire( TTrigger.Defer );
end;

destructor TBug.Destroy;
begin
  FMachine.Free;
  inherited;
end;

function TBug.GetCanAssign: Boolean;
begin
  Result := FMachine.CanFire( TTrigger.Assign );
end;

function TBug.GetState: TState;
begin
  Result := FState;
end;

procedure TBug.OnAssigned( Assignee: string );
begin
  if not string.IsNullOrEmpty( FAssignee ) and not FAssignee.Equals( Assignee )
  then
    begin
      SendEmailToAssignee( 'Don''t forget to help the new guy' );
    end;

  FAssignee := Assignee;
  SendEmailToAssignee( 'You own it.' );
end;

procedure TBug.OnDeassigned;
begin
  SendEmailToAssignee( 'You are off the hook.' );
end;

procedure TBug.OnDeferred;
begin
  FAssignee := '';
end;

procedure TBug.SendEmailToAssignee( const AMessage: string );
begin
  WriteLn( string.Format( '%s, RE %s: %s ', [ FAssignee, FTitle, AMessage ] ) );
end;

procedure TBug.SetState( Value: TState );
begin
  FState := Value;
end;

function TBug.ToString: string;
begin
  Result := string.Format( 'Bug { Title = "%s", Assignee = "%s", State = %s }', [ FTitle, FAssignee, TValue.From<TState>( FState ).ToString ] );
end;

end.
