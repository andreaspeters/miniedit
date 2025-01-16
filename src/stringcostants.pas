{$I codegen.inc}
unit Stringcostants;

interface

uses
  LCLVersion;

const
  DisplayAppName = 'MiniEdit';
  AppVersion = {$i version.inc};
  BuildDate = {$I %DATE%};
  lazVersion  = lcl_version;         // Lazarus version (major.minor.micro)
  fpcVersion  = {$I %FPCVERSION%};   // FPC version (major.minor.micro)
  TargetCPU   = {$I %FPCTARGETCPU%}; // Target CPU of FPC
  TargetOS    = {$I %FPCTARGETOS%};  // Target Operating System of FPC
  AppName = 'miniedit';

resourcestring
  RSNormalText = 'Normal text file';
  RSAllFile = 'All files';
  RSError = 'Error';
  RSReload = 'Reload';
  RSNewFile = '<new   %d>';
  RSStatusBarPos = 'Line: %d  Col:%d';
  RSStatusBarSel = 'Sel: %d';
  RSStatusBarInsMode = 'INS';
  RSStatusBarOvrMode = 'OVR';
  RSAdministrativeRights = 'Warning, you are using the root account, you may harm your system!';
  //-- Files
  RSSaveChanges = 'Save changes to'+LineEnding+
                  ' "%s"?';
  RSCannotSave = 'Can not save changes to'+LineEnding+
                 ' "%s" '+LineEnding+
                 ' Error: %d - %s';

  RSCannotOpen = 'Cannot open file '+LineEnding+
                 ' "%s" '+LineEnding+
                 ' Error: %d - %s';

  RSAskFileCreation = '"%s"'+LineEnding+
                      'does not exists. Do you want to create it?';
  RSCannotCreate = 'Can not create'+LineEnding+
                 ' "%s"';
  RSReloadSimple = '%s' +LineEnding+LineEnding+
                   'This file has been modified by another application.'+LineEnding+
                   'Do you want to reload it?';

  RSReloadModified = '%s' +LineEnding+LineEnding+
                     'This file has been modified by another application.'+LineEnding+
                     'Do you want to reload it and lose changes?';

  RSReloadFile     = '%s' +LineEnding+LineEnding+
                     'This file has been modified.'+LineEnding+
                     'Do you want to reload it and lose changes?';

  RSKeepDeleted = '%s' +LineEnding+LineEnding+
                     'This file has been deleted by another application.'+LineEnding+
                     'Do you want to keep it in the editor?';

  //--
  RSTextNotFound = 'Text not found:'+LineEnding+'"%s"';

  RSMacro        = 'Macro';
  RSMacroDefaultName = 'Current recorded macro';
  RSMacroSaving = 'Select a name for macro';
  RSMacroNewName = 'Select a new name for macro';

  RSMacroDelete  = 'Delete macro "%s" ?';



implementation

end.
