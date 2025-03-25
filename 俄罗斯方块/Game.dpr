program Game;

uses
  Vcl.Forms,
  MainFrm in 'MainFrm.pas' {Form1},
  serviceunit in 'service\serviceunit.pas',
  UnitConst in 'const\UnitConst.pas',
  UnitData in 'domain\UnitData.pas',
  Unit1Utils in 'utils\Unit1Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
