object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'MainForm'
  ClientHeight = 213
  ClientWidth = 169
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object RedShape: TShape
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 65
    Height = 65
    Brush.Color = clMaroon
    Shape = stCircle
  end
  object YellowShape: TShape
    AlignWithMargins = True
    Left = 3
    Top = 74
    Width = 65
    Height = 65
    Brush.Color = clOlive
    Shape = stCircle
  end
  object GreenShape: TShape
    AlignWithMargins = True
    Left = 3
    Top = 145
    Width = 65
    Height = 65
    Brush.Color = clGreen
    Shape = stCircle
  end
  object CountDownLabel: TLabel
    Left = 91
    Top = 74
    Width = 70
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'CountDown'
  end
  object SwitchOnButton: TButton
    AlignWithMargins = True
    Left = 91
    Top = 3
    Width = 75
    Height = 25
    Action = SwitchOnAction
    TabOrder = 0
  end
  object SwitchOffButton: TButton
    AlignWithMargins = True
    Left = 91
    Top = 34
    Width = 75
    Height = 25
    Action = SwitchOffAction
    TabOrder = 1
  end
  object LightStepTimer: TTimer
    OnTimer = LightStepTimerTimer
    Left = 112
    Top = 144
  end
  object LightActionList: TActionList
    Left = 112
    Top = 88
    object SwitchOnAction: TAction
      Caption = 'On'
      OnExecute = SwitchOnActionExecute
      OnUpdate = SwitchOnActionUpdate
    end
    object SwitchOffAction: TAction
      Caption = 'Off'
      OnExecute = SwitchOffActionExecute
      OnUpdate = SwitchOffActionUpdate
    end
  end
end
