object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = #20420#32599#26031#26041#22359
  ClientHeight = 543
  ClientWidth = 884
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object img1: TImage
    Left = 3
    Top = 8
    Width = 873
    Height = 473
  end
  object lv1: TListView
    Left = -6
    Top = 479
    Width = 882
    Height = 67
    Columns = <
      item
        AutoSize = True
      end>
    OwnerDraw = True
    ReadOnly = True
    ShowColumnHeaders = False
    TabOrder = 0
    ViewStyle = vsReport
    OnKeyDown = lv1KeyDown
  end
  object tmr1: TTimer
    OnTimer = tmr1Timer
    Left = 504
    Top = 360
  end
end
