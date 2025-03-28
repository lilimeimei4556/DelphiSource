unit Unit1Utils;
     {*------------------------------------------------------------------------------
       @author  万兴
       @version 2025/03/21 1.0 Initial revision.
       @comment   获取随机数
     -------------------------------------------------------------------------------}

interface

type
  TPublicUtils = class
    class function GetNumberWithRound(Min,Max:Integer):Integer;
  end;

implementation

{ TPublicUtils }
{*------------------------------------------------------------------------------
在指定范围获取一个随机数
  @param Min   范围起始值
  @param Max    范围的结束值
  @return      返回的随机数
-------------------------------------------------------------------------------}
class function TPublicUtils.GetNumberWithRound(Min,Max:Integer): Integer;
begin
//初始化随机种子
   Randomize ;
   //工具函数 ，获取指定范围的随机数
   Result:=Random(Max)mod(Max-Min+1)+Min;
end;

end.

