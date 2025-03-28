unit serviceunit;
    {*------------------------------------------------------------------------------
      @author  万兴
      @version 2025/03/21 1.0 Initial revision.
      @comment   游戏的业务控制
      图形移动
      1.获取当前图形的数据（四个小方格的坐标）
       2.改变每个小方格的坐标即可
       3.边界问题
       图形旋转（变形）
       1.确定中心点
       2.获取图形中每个方格的坐标
       图形的消行处理
    -------------------------------------------------------------------------------}

interface

uses
  LoggerPro, System.IOUtils, Winapi.GDIPAPI, Winapi.GDIPOBJ, Winapi.Windows,
  System.Generics.Collections, UnitData, Vcl.Dialogs;

type
  TGameService = class
  private
  //定义属性
    FHDC: HDC;
    //表示图片的编号
    FImageIndex: Integer;
    //表示当前图形
    FCurrentACt: TList<TPoint>;
    FGameMap: TGameMap;
    FGameOver: Boolean; // 游戏结束标志
    //判断该行是否可以被消除
    function IsCanRemove(Y: Integer): Boolean;
    //消行
    procedure RemoveLine(RowNum: Integer);

  public
  // 绘制图片
    procedure DrawImage(x, y: Integer; fileName: string; width, height: Integer);
    //绘制背景
    procedure DrawBackground(width, height: Integer);
    //绘制窗口
    procedure DrawWindows(x, y, w, h: Integer);
    //绘制方块
    procedure DrawACt(x, y, ActIndex: Integer);
     //方块的移动
    function Move(X, Y: Integer): Boolean;
    //图形的旋转
    procedure Rotate();

    //绘制游戏地图
    procedure DrawGameMap();
    procedure SetGameMap(X, Y: Integer);

    //游戏结束
    function IsGameOver(): Boolean;


    //方法的重载，方法名相同，参数不同
    constructor Create(hdc: HDC); overload;
    constructor Create(); overload;

    property GameHandle: HDC read FHDC write FHDC;
    property ImageIndex: Integer read FImageIndex write FImageIndex;

    property CurrentAct: TList<TPoint> read FCurrentACt write FCurrentACt;
    property GameMap: TGameMap read FGameMap;
  end;

implementation

uses
  UnitConst, System.SysUtils, MainFrm, LoggerPro.VCLListViewAppender;

{ TGameService }

constructor TGameService.Create(hdc: hdc);
begin
  FHDC := hdc;
end;

constructor TGameService.Create;
begin
  inherited;
end;

procedure TGameService.DrawACt(x, y, ActIndex: Integer);
var
//画笔
  Graphics: TGPGraphics;
  Image: TGPImage;
begin
  //载入图片文件
  Image := TGPImage.Create(UnitConst.GAME_ACT_IMAGE);
  //把图片绘制到控件上面
  Graphics := TGPGraphics.Create(GameHandle);
  //绘制图片
  Graphics.DrawImage(Image, MakeRect(x, y, UnitConst.ACT_SIZE, UnitConst.ACT_SIZE), UnitConst.ACT_SIZE * ActIndex, 0, UnitConst.ACT_SIZE, UnitConst.ACT_SIZE, UnitPixel);
  //释放对象
  Graphics.Free;
  Image.Free;
end;

procedure TGameService.DrawBackground(width, height: Integer);
var
  ImageList: TArray<string>;
begin
   //获取图片列表
   //解决硬编码问题
  ImageList := TDirectory.GetFiles(UnitConst.IMAGE_BACK_GROUND);
  if ImageIndex >= Length(ImageList) then
  begin
    ImageIndex := 0;
  end;
   //选取图片列表中的某一个图片，展示在窗口
  DrawImage(0, 0, ImageList[ImageIndex], width, height);
end;

{*------------------------------------------------------------------------------
判断该行是否可以被消除
  @param Y-表示列
  @return
-------------------------------------------------------------------------------}
function TGameService.IsCanRemove(Y: Integer): Boolean;
var
  X: Integer;
begin
  for X := 0 to UnitConst.GAME_MAP_WIDTH - 1 do
  begin
  //主要这一行这一列中为假，退出这一行
    if not GameMap[X][Y] then
    begin
      Result := False;
      Exit;
    end;

  end;
  //如果能够顺利的到达这个位置，表示全部都是true，该行可以消除
  Result := True;
end;

function TGameService.IsGameOver: Boolean;
begin
  Result := FGameOver;
end;

{*------------------------------------------------------------------------------

消行
  @param RowNum  行号
-------------------------------------------------------------------------------}

procedure TGameService.RemoveLine(RowNum: Integer);
var
  X, Y: Integer;
begin
  for X := 0 to UnitConst.GAME_MAP_WIDTH - 1 do
  begin
    for Y := RowNum downto 0 do //消除行的每一行都上移一行
    begin
      FGameMap[X][Y] := FGameMap[X][Y - 1]; //上方单元格的值赋给当前单元格，从而实现“下移”操作。
    end;
    FGameMap[X][0] := False; //在内层循环结束后，最顶部的单元格（第 0 行）需要被清空。
  end;

end;
{*------------------------------------------------------------------------------
绘制游戏地图  x-行  y-列
-------------------------------------------------------------------------------}

procedure TGameService.DrawGameMap;
var
  X, Y: Integer;
  //str: string;
begin
  //str := '';
  for X := Low(GameMap) to High(GameMap) do
  begin
    if IsCanRemove(X) then
    begin
      RemoveLine(X);
      Form1.Log.Info('该行可以消除', X.ToString);
    end;
    for Y := Low(GameMap[X]) to High(GameMap[X]) do
    begin
    //根据x,y绘制我们的方格
      if FGameMap[X][Y] then
      begin
        DrawACt(X * ACT_SIZE + GAME_WINDOW_BORDER_WIDTH, Y * ACT_SIZE + GAME_WINDOW_BORDER_WIDTH, 0);
      end;
     // str := str + BoolToStr(GameMap[X][Y]);
    end;
    //str := str + '---------' + X.ToString + #13;
  end;
  //Form1.lbl1.Caption := str;
end;

procedure TGameService.DrawImage(x, y: Integer; fileName: string; width, height: Integer);
var
//画笔
  Graphics: TGPGraphics;
  Image: TGPImage;
begin
  //载入图片文件
  Image := TGPImage.Create(fileName);
  //把图片绘制到控件上面
  Graphics := TGPGraphics.Create(GameHandle);
  if (width <= 0) or (height <= 0) then
  begin
    width := Image.GetWidth;
    height := Image.GetHeight;
  end;
  //绘制图片
  Graphics.DrawImage(Image, MakeRect(x, y, width, height));
  //释放对象
  Graphics.Free;
  Image.Free;
end;

{*------------------------------------------------------------------------------
  绘制窗口背景
  @param x  表示窗口的x坐标
  @param y   表示窗口的y坐标
  @param w   表示窗口图片的宽度
  @param h    表示窗口图片的高度
-------------------------------------------------------------------------------}
procedure TGameService.DrawWindows(x, y, w, h: Integer);
var
//画笔
  Graphics: TGPGraphics;
  Img: TGPImage;
begin
  //载入图片文件
  Img := TGPImage.Create(UnitConst.GAME_WINDOWS);
  //把图片绘制到控件上面
  Graphics := TGPGraphics.Create(GameHandle);
  //绘制图片

  //左上角
  {makeRect（x,y,绘制的矩形的宽度，绘制的矩形的高度），图片的x坐标，图片的y坐标，截取的图片宽度，截取的图片高度，数字单位}
  Graphics.DrawImage(Img, MakeRect(x, y, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH), 0, 0, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitPixel);
  // 左侧竖线    （0,7,7,264-7）（0,7,64-（64-7），64-7*2）
  Graphics.DrawImage(Img, MakeRect(x, y + UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, h - UnitConst.GAME_WINDOW_BORDER_WIDTH), 0, UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetWidth - (Img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH), Img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, UnitPixel);
   //左下角
  Graphics.DrawImage(Img, MakeRect(x, y + h, UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetHeight), 0, Img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetHeight, UnitPixel);
  //底部中线
  Graphics.DrawImage(Img, MakeRect(x + UnitConst.GAME_WINDOW_BORDER_WIDTH, y + h, w - UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetHeight), UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, Img.GetHeight, UnitPixel);
   //右下角
  Graphics.DrawImage(Img, MakeRect(x + w, y + h, Img.GetWidth, Img.GetHeight), Img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetWidth, Img.GetHeight, UnitPixel);
   //右侧竖线
  Graphics.DrawImage(Img, MakeRect(x + w, y + UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetWidth, h - UnitConst.GAME_WINDOW_BORDER_WIDTH), Img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetWidth, Img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, UnitPixel);
   //右上角
  Graphics.DrawImage(Img, MakeRect(x + w, y, Img.GetHeight, UnitConst.GAME_WINDOW_BORDER_WIDTH), Img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH, 0, Img.GetHeight, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitPixel);
   //顶部中线
  Graphics.DrawImage(Img, MakeRect(x + UnitConst.GAME_WINDOW_BORDER_WIDTH, y, w - UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH), UnitConst.GAME_WINDOW_BORDER_WIDTH, 0, Img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitPixel);
   //中间
  Graphics.DrawImage(Img, MakeRect(x + UnitConst.GAME_WINDOW_BORDER_WIDTH, y + UnitConst.GAME_WINDOW_BORDER_WIDTH, w - UnitConst.GAME_WINDOW_BORDER_WIDTH, h - UnitConst.GAME_WINDOW_BORDER_WIDTH), UnitConst.GAME_WINDOW_BORDER_WIDTH, UnitConst.GAME_WINDOW_BORDER_WIDTH, Img.GetWidth - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, Img.GetHeight - UnitConst.GAME_WINDOW_BORDER_WIDTH * 2, UnitPixel);
  //释放对象
  Graphics.Free;
  Img.Free;
end;


{*------------------------------------------------------------------------------
  @param X   目标位置的X轴
  @param Y    目标位置的Y轴
  @return   可以继续移动返回true
-------------------------------------------------------------------------------}
function TGameService.Move(X, Y: Integer): Boolean;
var
  NewX, NewY, I: Integer;
begin
  for I := 0 to CurrentAct.Count - 1 do
  begin
   //获取当前图形中每个方格的坐标
    NewX := CurrentAct.Items[I].X + X;
    NewY := CurrentAct.Items[I].Y + Y;

    if (NewY >= UnitConst.GAME_MAP_HEIGHT) or (NewX >= UnitConst.GAME_MAP_WIDTH) or (NewX < 0) or FGameMap[NewX][NewY] then
    begin
      result := False;
      Exit;
    end;

  end;

  for I := 0 to CurrentAct.Count - 1 do
  begin
   //获取当前图形中每个方格的坐标
    NewX := CurrentAct.Items[I].X + X;
    NewY := CurrentAct.Items[I].Y + Y;
    //重新赋值每个方格的X Y 坐标
    CurrentAct.Items[I] := TPoint.Create(NewX, NewY);
  end;
  result := True;
end;

{*------------------------------------------------------------------------------
    图形的旋转
    笛卡尔积坐标系90度旋转公式
     o为中心点、a为当前点、b为目标点
     a.x=o.y+o.x-b.y
     a.y=o.y-o.x+b.x
-------------------------------------------------------------------------------}

procedure TGameService.Rotate;
var
  I, NewX, NewY: Integer;
begin
//边界碰撞测试
  for I := 1 to CurrentAct.Count - 1 do
  begin
   //获取当前图形中每个方格的坐标 ,按照公式计算新的坐标点
    NewX := CurrentAct.Items[0].y + CurrentAct.Items[0].x - CurrentAct.Items[I].y;
    NewY := CurrentAct.Items[0].y - CurrentAct.Items[0].x + CurrentAct.Items[I].x;
    //如果目标点在边界上或者边界外则不进行图形变换
    if (NewY >= UnitConst.GAME_MAP_HEIGHT) or (NewY < 0) or (NewX >= UnitConst.GAME_MAP_WIDTH) or (NewX < 0) or FGameMap[NewX][NewY] then
    begin
      Exit;
    end;

  end;

  for I := 1 to CurrentAct.Count - 1 do
  begin
   //获取当前图形中每个方格的坐标 ,按照公式计算新的坐标点
    NewX := CurrentAct.Items[0].y + CurrentAct.Items[0].x - CurrentAct.Items[I].y;
    NewY := CurrentAct.Items[0].y - CurrentAct.Items[0].x + CurrentAct.Items[I].x;
    //将新的坐标设置为当前图形的坐标
    CurrentAct.Items[I] := TPoint.Create(NewX, NewY);
  end;
end;

procedure TGameService.SetGameMap(X, Y: Integer);
begin
  FGameMap[X][Y] := True;   //表示该位置已经到达边界
end;

end.

