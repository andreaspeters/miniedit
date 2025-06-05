{$I codegen.inc}
program miniedit;

uses
  {$IFDEF UNIX}
  cthreads, printer4lazarus, SynEditPrintExtProcs,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, DefaultTranslator, cmdbox, indylaz, FrameViewer09,
  //projects unit
  umain, Stringcostants, SupportFuncs, config, uCheckFileChange, udglgoto, simplemrumanager,
  ReplaceDialog, LazLogger,
  JsonTools, uinfo, ucmdboxthread, uLSP, udirectoryname,
  ushowlspmessage, usettings, uCmdBoxCustom, SynExportRTF, uai;

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
  Application.CreateForm(TfAI, fAI);
  Application.Run;
end.

