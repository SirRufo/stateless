unit Forms.MainForm;

interface

uses
  Stateless,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.Actions,
  Vcl.ActnList, Vcl.StdCtrls;

{$SCOPEDENUMS ON}

type
  TTrafficState   = ( StartUp, Active, Red, Yellow, Green, RedYellow, Shutdown, Off );
  TTrafficTrigger = ( Step, SwitchOn, SwitchOff );
  TTrafficLight   = TStateMachine<TTrafficState, TTrafficTrigger>;

  TMainForm = class( TForm )
    RedShape: TShape;
    YellowShape: TShape;
    GreenShape: TShape;
    LightStepTimer: TTimer;
    LightActionList: TActionList;
    SwitchOnAction: TAction;
    SwitchOffAction: TAction;
    SwitchOnButton: TButton;
    SwitchOffButton: TButton;
    CountDownLabel: TLabel;
    procedure FormShow( Sender: TObject );
    procedure LightStepTimerTimer( Sender: TObject );
    procedure SwitchOnActionExecute( Sender: TObject );
    procedure SwitchOnActionUpdate( Sender: TObject );
    procedure SwitchOffActionExecute( Sender: TObject );
    procedure SwitchOffActionUpdate( Sender: TObject );
  private
    FLight    : TTrafficLight;
    FCountDown: Integer;
    procedure PresentLight;
    procedure PresentCountDown;
    procedure OnLightTransitioned( const t: TTrafficLight.TTransition );
    procedure SetCountDown( const Value: Integer );
    procedure DecreaseCountDown;
    function IsCountDownZero: Boolean;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}
{ TMainForm }

procedure TMainForm.AfterConstruction;
begin
  inherited;
  Caption := Application.Title;

  FLight := TTrafficLight.Create( TTrafficState.Off );

  FLight.Configure( TTrafficState.Off )
  {} .Permit( TTrafficTrigger.SwitchOn, TTrafficState.StartUp );

  FLight.Configure( TTrafficState.StartUp )
  {} .OnEntry(
    procedure
    begin
      SetCountDown( 3 );
    end )
  {} .PermitIf( TTrafficTrigger.Step, TTrafficState.Red, IsCountDownZero );

  FLight.Configure( TTrafficState.Active )
  {} .Permit( TTrafficTrigger.SwitchOff, TTrafficState.Shutdown );

  FLight.Configure( TTrafficState.Shutdown )
  {} .OnEntry(
    procedure
    begin
      SetCountDown( 3 );
    end )
  {} .PermitIf( TTrafficTrigger.Step, TTrafficState.Off, IsCountDownZero );

  FLight.Configure( TTrafficState.Red )
  {} .SubstateOf( TTrafficState.Active )
  {} .OnEntry(
    procedure
    begin
      SetCountDown( 10 );
    end )
  {} .PermitIf( TTrafficTrigger.Step, TTrafficState.RedYellow, IsCountDownZero );
  FLight.Configure( TTrafficState.RedYellow )
  {} .SubstateOf( TTrafficState.Active )
  {} .OnEntry(
    procedure
    begin
      SetCountDown( 2 );
    end )
  {} .PermitIf( TTrafficTrigger.Step, TTrafficState.Green, IsCountDownZero );
  FLight.Configure( TTrafficState.Green )
  {} .SubstateOf( TTrafficState.Active )
  {} .OnEntry(
    procedure
    begin
      SetCountDown( 10 );
    end )
  {} .PermitIf( TTrafficTrigger.Step, TTrafficState.Yellow, IsCountDownZero );
  FLight.Configure( TTrafficState.Yellow )
  {} .SubstateOf( TTrafficState.Active )
  {} .OnEntry(
    procedure
    begin
      SetCountDown( 3 );
    end )
  {} .PermitIf( TTrafficTrigger.Step, TTrafficState.Red, IsCountDownZero );

  FLight.OnTransitioned( OnLightTransitioned );
end;

procedure TMainForm.BeforeDestruction;
begin
  FLight.Free;
  inherited;
end;

procedure TMainForm.DecreaseCountDown;
begin
  SetCountDown( FCountDown - 1 );
end;

procedure TMainForm.FormShow( Sender: TObject );
begin
  PresentLight;
  PresentCountDown;
end;

function TMainForm.IsCountDownZero: Boolean;
begin
  Result := FCountDown = 0;
end;

procedure TMainForm.OnLightTransitioned( const t: TTrafficLight.TTransition );
begin
  PresentLight;
end;

procedure TMainForm.PresentCountDown;
begin
  CountDownLabel.Caption := IntToStr( FCountDown );
end;

procedure TMainForm.PresentLight;
begin
  if
  {} FLight.IsInState( TTrafficState.Red ) or
  {} FLight.IsInState( TTrafficState.RedYellow )
  then
    RedShape.Brush.Color := clRed
  else
    RedShape.Brush.Color := clGray;

  if
  {} FLight.IsInState( TTrafficState.Yellow ) or
  {} FLight.IsInState( TTrafficState.RedYellow ) or
  {} FLight.IsInState( TTrafficState.Shutdown ) or
  {} FLight.IsInState( TTrafficState.StartUp )
  then
    YellowShape.Brush.Color := clYellow
  else
    YellowShape.Brush.Color := clGray;

  if FLight.IsInState( TTrafficState.Green )
  then
    GreenShape.Brush.Color := clLime
  else
    GreenShape.Brush.Color := clGray;
end;

procedure TMainForm.SetCountDown( const Value: Integer );
begin
  if FCountDown <> Value
  then
    begin
      FCountDown := Value;
      PresentCountDown;
    end;
end;

procedure TMainForm.SwitchOffActionExecute( Sender: TObject );
begin
  FLight.Fire( TTrafficTrigger.SwitchOff );
end;

procedure TMainForm.SwitchOffActionUpdate( Sender: TObject );
begin
  TAction( Sender ).Enabled := FLight.CanFire( TTrafficTrigger.SwitchOff );
end;

procedure TMainForm.SwitchOnActionExecute( Sender: TObject );
begin
  FLight.Fire( TTrafficTrigger.SwitchOn );
end;

procedure TMainForm.SwitchOnActionUpdate( Sender: TObject );
begin
  TAction( Sender ).Enabled := FLight.CanFire( TTrafficTrigger.SwitchOn );
end;

procedure TMainForm.LightStepTimerTimer( Sender: TObject );
begin
  if not IsCountDownZero
  then
    DecreaseCountDown;

  if FLight.CanFire( TTrafficTrigger.Step )
  then
    FLight.Fire( TTrafficTrigger.Step );
end;

end.
