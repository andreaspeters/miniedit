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
  Forms, DefaultTranslator, cmdbox, FrameViewer09,
  printer4lazarus, SynEditPrintExtProcs,
  //projects unit
  umain, Stringcostants, SupportFuncs, config, uCheckFileChange, udglgoto, simplemrumanager,
  ReplaceDialog, LazLogger,
  JsonTools, uinfo, ucmdboxthread, uLSP, udirectoryname,
  ushowlspmessage, usettings, uCmdBoxCustom, SynExportRTF;

{$R *.res}
begin
//  QGuiApplication_setHighDpiScaleFactorRoundingPolicy(QtHighDpiScaleFactorRoundingPolicy_PassThrough);

  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.Scaled:=True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TTFInfo, TFInfo);
  Application.CreateForm(TFLSPMessage, FLSPMessage);
  Application.CreateForm(TFCreateDirectory, FCreateDirectory);
  Application.CreateForm(TFSettings, FSettings);
  Application.Run;
end.

