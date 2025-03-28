unit UnitData;
 {*------------------------------------------------------------------------------

   @author  万兴
   @version 2025/03/21 1.0 Initial revision.
   @comment   存储图形数据
   1.共有7种类型的图形，每个图形有4个方块
   数组
   array 0...3 of TPoint    动态数组 TArray<T>       array of T
   泛型  TList<T>
  2. 每个方块又有4对坐标
      TPoint 本身就包含x,y
   每个坐标又需要存储到一个容器中TList<T>
     TList<TList<TPoint>>
 -------------------------------------------------------------------------------}

interface

uses
  System.Generics.Collections, System.Types;

type
  TGameData = class
  private
    ActList: TList<TList<TPoint>>; //图形列表
    Points: TList<TPoint>;
  public
    function GetActByIndex(ActIndex: Integer): TList<TPoint>;
    constructor Create(); overload;
  end;

type
  //该数据类型表示存储已经到达边界的方格的地图数据
  TGameMap = array[0..17] of array[0..17] of Boolean;

implementation


{ TGameData }
{*------------------------------------------------------------------------------

   根据索引编号决定是哪种类型的图形
  @param ActIndex   图形编号，0..6
  @return     指定的图形数据
-------------------------------------------------------------------------------}

constructor TGameData.Create;
begin
  //创建列表对象
  ActList := TList<TList<TPoint>>.Create;
  //创建图形数据
  //一字型
  Points := TList<TPoint>.Create;
   //创建一对坐标，同时将该对坐标存储到 points中
  Points.Add(TPoint.Create(6, 0));
  Points.Add(TPoint.Create(7, 0));
  Points.Add(TPoint.Create(8, 0));
  Points.Add(TPoint.Create(9, 0));
   //将图形数据存储到列表中去
  ActList.Add(Points);
   //T字型
  Points := TList<TPoint>.Create;
   //创建一对坐标，同时将该对坐标存储到 points中
  Points.Add(TPoint.Create(6, 0));
  Points.Add(TPoint.Create(7, 0));
  Points.Add(TPoint.Create(8, 0));
  Points.Add(TPoint.Create(7, 1));
   //将图形数据存储到列表中去
  ActList.Add(Points);

     //L字型
  Points := TList<TPoint>.Create;
   //创建一对坐标，同时将该对坐标存储到 points中
  Points.Add(TPoint.Create(6, 0));
  Points.Add(TPoint.Create(7, 0));
  Points.Add(TPoint.Create(8, 0));
  Points.Add(TPoint.Create(6, 1));
   //将图形数据存储到列表中去
  ActList.Add(Points);
     //Z字型
  Points := TList<TPoint>.Create;
   //创建一对坐标，同时将该对坐标存储到 points中
  Points.Add(TPoint.Create(6, 0));
  Points.Add(TPoint.Create(7, 0));
  Points.Add(TPoint.Create(7, 1));
  Points.Add(TPoint.Create(8, 1));
   //将图形数据存储到列表中去
  ActList.Add(Points);
     //田字型
  Points := TList<TPoint>.Create;
   //创建一对坐标，同时将该对坐标存储到 points中
  Points.Add(TPoint.Create(6, 0));
  Points.Add(TPoint.Create(7, 0));
  Points.Add(TPoint.Create(6, 1));
  Points.Add(TPoint.Create(7, 1));
   //将图形数据存储到列表中去
  ActList.Add(Points);
     //反L字型
  Points := TList<TPoint>.Create;
   //创建一对坐标，同时将该对坐标存储到 points中
  Points.Add(TPoint.Create(6, 0));
  Points.Add(TPoint.Create(7, 0));
  Points.Add(TPoint.Create(8, 0));
  Points.Add(TPoint.Create(8, 1));
   //将图形数据存储到列表中去
  ActList.Add(Points);
    //反Z字型
  Points := TList<TPoint>.Create;
   //创建一对坐标，同时将该对坐标存储到 points中
  Points.Add(TPoint.Create(7, 0));
  Points.Add(TPoint.Create(8, 0));
  Points.Add(TPoint.Create(6, 1));
  Points.Add(TPoint.Create(7, 1));
   //将图形数据存储到列表中去
  ActList.Add(Points);

end;

function TGameData.GetActByIndex(ActIndex: Integer): TList<TPoint>;
begin
  result := ActList.Items[ActIndex];
end;

initialization

end.

