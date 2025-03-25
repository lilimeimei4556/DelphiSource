unit MainFrm;

interface

uses
  serviceunit, LoggerPro, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    lv1: TListView;
    img1: TImage;
    tmr1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure lv1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tmr1Timer(Sender: TObject);

  private
    { Private declarations }
    //定义日志字段
    FLog: ILogWriter;
    // 定义游戏业务类的对象
    GameService: TGameService;
  public
    { Public declarations }
    //定义一个属性，属性提供给外界访问
    property Log: ILogWriter read FLog write FLog;
    //初始化游戏
    procedure InitGame();
  end;

var
  Form1: TForm1;

var
  RandomIndex: Integer;

implementation

uses
  Unit1Utils, UnitConst, UnitData, LoggerPro.VCLListViewAppender,
  System.Generics.Collections;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
//创建对象的方法
  FLog := BuildLogWriter([TVCLListViewAppender.Create(lv1)]);
  //TGameService.Create(img1.Canvas.Handle).DrawImage('C:\delphi\study\俄罗斯方块\bin\resources\background\bg10.jpg', img1.width, img1.Height)
   {初始化游戏业务类的对象}
  GameService := TGameService.Create();
  // 初始化方块
  RandomIndex := TPublicUtils.GetNumberWithRound(0, 7);
  GameService.CurrentAct := TGameData.Create().GetActByIndex(RandomIndex);
  //初始化游戏
  InitGame();
end;

//游戏背景的初始化
procedure TForm1.InitGame;
var
  Act: TList<TPoint>;
  MapWidth, MapHeight, I: Integer;
begin
    //设置句柄
  GameService.GameHandle := img1.Canvas.Handle;
  //绘制背景图
  GameService.DrawBackground(img1.Width, img1.Height);
  //绘制游戏主区窗口
  //游戏地图的宽度：=方格的大小*地图宽度总格子数+地图的边框宽度
  MapWidth := UnitConst.ACT_SIZE * UnitConst.GAME_MAP_WIDTH + UnitConst.GAME_WINDOW_BORDER_WIDTH;
  MapHeight := UnitConst.ACT_SIZE * UnitConst.GAME_MAP_HEIGHT + UnitConst.GAME_WINDOW_BORDER_WIDTH;
  GameService.DrawWindows(0, 0, MapWidth, MapHeight);
  //绘制图形预览窗口
  GameService.DrawWindows(MapWidth + 100, 0, 32 * 12, 32 * 8);
  //绘制下方提示窗口
  GameService.DrawWindows(MapWidth + 100, 300, 32 * 12, 32 * 8);
  GameService.DrawImage(MapWidth + 180, 370, '.\resources\about.png', 0, 0);
  //绘制预览图形
  GameService.DrawImage(MapWidth + 240, 70, '.\resources\' + RandomIndex.ToString + '.png', 0, 0);
  for I := 0 to GameService.CurrentAct.Count - 1 do
  begin
    GameService.DrawACt(7 + GameService.CurrentAct.Items[I].X * 32, 7 + GameService.CurrentAct.Items[I].Y * 32, 3);
  end;
  GameService.DrawGameMap;
end;

procedure TForm1.lv1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

  case Key of
    VK_UP:
      begin
        //Log.Info('上', 'VK_UP');
        GameService.Rotate;
      end;
    VK_DOWN:
      begin
       // Log.Info('下', ' VK_DOWN');
        GameService.Move(0, 1);
      end;
    VK_LEFT:
      begin
       // Log.Info('左', 'VK_LEFT');
        GameService.Move(-1, 0);
      end;
    VK_RIGHT:
      begin
        //Log.Info('右', ' VK_RIGHT');
        GameService.Move(1, 0);
      end;
    VK_SPACE:
      begin
       // Log.Info('空格', 'VK_SPACE');
       //实现游戏的暂停继续
        if tmr1.Interval > 0 then
        begin
          tmr1.Interval := 0;
        end
        else
        begin
          tmr1.Interval := 300;
        end;
      end;

  end;
end;

procedure TForm1.tmr1Timer(Sender: TObject);
var
  IsMove: Boolean; //判断图形是否已达到边界
  ActPoint: TPoint;
  I: Integer;
begin
  InitGame;
  IsMove := GameService.Move(0, 1);
  //实现图形到达边界的再次下落
  if not IsMove then
  begin
    //遍历我们当前已经到达边界的图形，以图形中每个方格的xy坐标作为二维数组的索引值
    for I := 0 to GameService.CurrentAct.Count - 1 do
    begin
       //获取图形中每个方格的坐标
      ActPoint := GameService.CurrentAct.Items[I];
       //设置地图的xy索引值
      GameService.SetGameMap(ActPoint.X, ActPoint.Y);
    end;
  //重新绘制图形
    RandomIndex := TPublicUtils.GetNumberWithRound(0, 7);
    GameService.CurrentAct := TGameData.Create().GetActByIndex(RandomIndex);
  end;
  //重绘
  Repaint;
end;

end.

