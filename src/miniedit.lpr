{$I codegen.inc}
program miniedit;

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, DefaultTranslator, cmdbox,
  printer4lazarus, SynEditPrintExtProcs,
  //projects unit
  umain, udmmain, Stringcostants, SupportFuncs, config, uCheckFileChange,
  udglgoto, simplemrumanager, ReplaceDialog, LazLogger, JsonTools, iconloader,
  uinfo, ucmdboxthread, udirectoryname;

{$R *.res}
begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.Scaled:=True;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TTFInfo, TFInfo);
  Application.Run;
end.

