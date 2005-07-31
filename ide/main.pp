{  $Id$  }
{
 /***************************************************************************
                    main.pp  -  the "integrated" in IDE
                    -----------------------------------
  TMainIDE is the main controlling and instance of the IDE, which connects the
  various parts of the IDE.

  main.pp      - TMainIDE = class(TMainIDEBase)
                   The highest manager/boss of the IDE. Only lazarus.pp uses
                   this unit.
  mainbase.pas - TMainIDEBase = class(TMainIDEInterface)
                   The ancestor class used by (and only by) the other
                   bosses/managers like debugmanager, pkgmanager.
  mainintf.pas - TMainIDEInterface = class(TLazIDEInterface)
                   The interface class of the top level functions of the IDE.
                   TMainIDEInterface is used by functions/units, that uses
                   several different parts of the IDE (designer, source editor,
                   codetools), so they can't be added to a specific boss and
                   which are yet too small to become a boss of their own.
  lazideintf.pas - TLazIDEInterface = class(TComponent)
                   For designtime packages, this is the interface class of the
                   top level functions of the IDE.


                 Initial Revision : Sun Mar 28 23:15:32 CST 1999


 ***************************************************************************/

 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.        *
 *                                                                         *
 ***************************************************************************
}
unit Main;

{$mode objfpc}{$H+}

interface

{$I ide.inc}

uses
{$IFDEF IDE_MEM_CHECK}
  MemCheck,
{$ENDIF}
  // fpc packages
  Classes, SysUtils, Process, TypInfo,
  // lcl
  LCLProc, LCLMemManager, LCLType, LCLIntf, LMessages, LResources, StdCtrls,
  Forms, Buttons, Menus, FileUtil, Controls, GraphType, Graphics, ExtCtrls,
  Dialogs, InterfaceBase,
  // codetools
  {$IFNDEF VER1_0}AVL_Tree{$ELSE}OldAvLTree{$ENDIF}, Laz_XMLCfg,
  CodeToolsStructs, CodeToolManager, CodeCache, DefineTemplates,
  // IDE interface
  AllIDEIntf, ObjectInspector, PropEdits, MacroIntf, IDECommands, SrcEditorIntf,
  NewItemIntf, PackageIntf, ProjectIntf, MenuIntf, LazIDEIntf,
  // synedit
  SynEditKeyCmds,
  // protocol
  IDEProtocol,
  // compile
  Compiler, CompilerOptions, CompilerOptionsDlg, CheckCompilerOpts,
  ImExportCompilerOpts,
  // projects
  Project, ProjectDefs, NewProjectDlg, ProjectOpts,
  PublishProjectDlg, ProjectInspector,
  // help manager
  HelpManager,
  // designer
  ComponentPalette, ComponentReg, ObjInspExt,
  Designer, FormEditor, CustomFormEditor,
  ControlSelection, AnchorEditor,
  {$DEFINE UseNewMenuEditor}
  {$IFDEF UseNewMenuEditor}
  MenuEditorForm,
  {$ELSE}
  MenuPropEdit,
  {$ENDIF}
  {$IFDEF TRANSLATESTRING}
  //LRT stuff
  LrtPoTools,
  {$ENDIF}
  // debugger
  RunParamsOpts, BaseDebugManager, DebugManager,
  // packager
  PkgManager, BasePkgManager,
  // source editing
  UnitEditor, CodeToolsOptions, IDEOptionDefs, CheckLFMDlg,
  CodeToolsDefines, DiffDialog, DiskDiffsDialog, UnitInfoDlg, EditorOptions,
  ViewUnit_dlg,
  // rest of the ide
  Splash, IDEDefs, LazarusIDEStrConsts, LazConf, MsgView, SearchResultView,
  PublishModule, EnvironmentOpts, TransferMacros, KeyMapping, Translations,
  IDEProcs, ExtToolDialog, ExtToolEditDlg, MacroPromptDlg, OutputFilter,
  BuildLazDialog, MiscOptions, InputHistory, UnitDependencies, ClipBoardHistory,
  ProcessList, InitialSetupDlgs, NewDialog, MakeResStrDlg, ToDoList,
  DialogProcs, FindReplaceDialog, FindInFilesDlg, CodeExplorer, BuildFileDlg,
  ExtractProcDlg, FindRenameIdentifier, DelphiUnit2Laz, CleanDirDlg,
  // main ide
  MainBar, MainIntf, MainBase;

type

  { TMainIDE }

  TMainIDE = class(TMainIDEBase)
    // event handlers

    //procedure FormShow(Sender: TObject);
    procedure MainIDEFormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure MainIDEFormCloseQuery(Sender: TObject; var CanClose: boolean);
    //procedure FormPaint(Sender: TObject);
    procedure OnApplicationUserInput(Sender: TObject; Msg: Cardinal);
    procedure OnApplicationIdle(Sender: TObject);
    procedure OnScreenRemoveForm(Sender: TObject; AForm: TCustomForm);

    // file menu
    procedure mnuNewUnitClicked(Sender: TObject);
    procedure mnuNewFormClicked(Sender: TObject);
    procedure mnuNewOtherClicked(Sender: TObject);
    procedure mnuOpenClicked(Sender: TObject);
    procedure mnuOpenRecentClicked(Sender: TObject);
    procedure mnuRevertClicked(Sender: TObject);
    procedure mnuSaveClicked(Sender: TObject);
    procedure mnuSaveAsClicked(Sender: TObject);
    procedure mnuSaveAllClicked(Sender: TObject);
    procedure mnuCloseClicked(Sender: TObject);
    procedure mnuCloseAllClicked(Sender: TObject);
    procedure mnuCleanDirectoryClicked(Sender: TObject);
    procedure mnuRestartClicked(Sender: TObject);
    procedure mnuQuitClicked(Sender: TObject);

    // edit menu
    procedure mnuEditUndoClicked(Sender: TObject);
    procedure mnuEditRedoClicked(Sender: TObject);
    procedure mnuEditCutClicked(Sender: TObject);
    procedure mnuEditCopyClicked(Sender: TObject);
    procedure mnuEditPasteClicked(Sender: TObject);
    procedure mnuEditIndentBlockClicked(Sender: TObject);
    procedure mnuEditUnindentBlockClicked(Sender: TObject);
    procedure mnuEditEncloseBlockClicked(Sender: TObject);
    procedure mnuEditUpperCaseBlockClicked(Sender: TObject);
    procedure mnuEditLowerCaseBlockClicked(Sender: TObject);
    procedure mnuEditTabsToSpacesBlockClicked(Sender: TObject);
    procedure mnuEditCommentBlockClicked(Sender: TObject);
    procedure mnuEditUncommentBlockClicked(Sender: TObject);
    procedure mnuEditConditionalBlockClicked(Sender: TObject);
    procedure mnuEditSortBlockClicked(Sender: TObject);
    procedure mnuEditSelectionBreakLinesClicked(Sender: TObject);
    procedure mnuEditSelectAllClick(Sender: TObject);
    procedure mnuEditSelectCodeBlockClick(Sender: TObject);
    procedure mnuEditSelectToBraceClick(Sender: TObject);
    procedure mnuEditSelectLineClick(Sender: TObject);
    procedure mnuEditSelectParagraphClick(Sender: TObject);
    procedure mnuEditCompleteCodeClicked(Sender: TObject);
    procedure mnuEditExtractProcClicked(Sender: TObject);
    procedure mnuEditInsertCharacterClicked(Sender: TObject);

    // edit->insert text->CVS keyword
    procedure mnuEditInsertCVSAuthorClick(Sender: TObject);
    procedure mnuEditInsertCVSDateClick(Sender: TObject);
    procedure mnuEditInsertCVSHeaderClick(Sender: TObject);
    procedure mnuEditInsertCVSIDClick(Sender: TObject);
    procedure mnuEditInsertCVSLogClick(Sender: TObject);
    procedure mnuEditInsertCVSNameClick(Sender: TObject);
    procedure mnuEditInsertCVSRevisionClick(Sender: TObject);
    procedure mnuEditInsertCVSSourceClick(Sender: TObject);

    // edit->insert text->general
    procedure mnuEditInsertGPLNoticeClick(Sender: TObject);
    procedure mnuEditInsertLGPLNoticeClick(Sender: TObject);
    procedure mnuEditInsertUsernameClick(Sender: TObject);
    procedure mnuEditInsertDateTimeClick(Sender: TObject);
    procedure mnuEditInsertChangeLogEntryClick(Sender: TObject);

    // search menu
    procedure mnuSearchFindInFiles(Sender: TObject);
    procedure mnuSearchFindIdentifierRefsClicked(Sender: TObject);
    procedure mnuSearchRenameIdentifierClicked(Sender: TObject);
    procedure mnuSearchFindBlockOtherEnd(Sender: TObject);
    procedure mnuSearchFindBlockStart(Sender: TObject);
    procedure mnuSearchFindDeclaration(Sender: TObject);
    procedure mnuFindDeclarationClicked(Sender: TObject);
    procedure mnuOpenFileAtCursorClicked(Sender: TObject);
    procedure mnuGotoIncludeDirectiveClicked(Sender: TObject);

    // view menu
    procedure mnuViewInspectorClicked(Sender: TObject);
    procedure mnuViewSourceEditorClicked(Sender: TObject);
    procedure mnuViewUnitsClicked(Sender: TObject);
    procedure mnuViewFormsClicked(Sender: TObject);
    procedure mnuViewUnitDependenciesClicked(Sender: TObject);
    procedure mnuViewUnitInfoClicked(Sender: TObject);
    procedure mnuViewCodeExplorerClick(Sender: TObject);
    procedure mnuViewMessagesClick(Sender: TObject);
    procedure mnuViewSearchResultsClick(Sender: TObject);
    procedure mnuToggleFormUnitClicked(Sender: TObject);
    procedure mnuViewAnchorEditorClicked(Sender: TObject);

    // project menu
    procedure mnuNewProjectClicked(Sender: TObject);
    procedure mnuNewProjectFromFileClicked(Sender: TObject);
    procedure mnuOpenProjectClicked(Sender: TObject);
    procedure mnuSaveProjectClicked(Sender: TObject);
    procedure mnuSaveProjectAsClicked(Sender: TObject);
    procedure mnuPublishProjectClicked(Sender: TObject);
    procedure mnuProjectInspectorClicked(Sender: TObject);
    procedure mnuAddToProjectClicked(Sender: TObject);
    procedure mnuRemoveFromProjectClicked(Sender: TObject);
    procedure mnuViewProjectSourceClicked(Sender: TObject);
    procedure mnuViewProjectTodosClicked(Sender: TObject);
    procedure mnuProjectOptionsClicked(Sender: TObject);
    {$IFDEF TRANSLATESTRING}
    procedure mnuProjectCreatePoFilesClicked(Sender : TObject);
    procedure mnuProjectCollectPoFilesClicked(Sender : TObject);
    {$ENDIF}

    // run menu
    procedure mnuBuildProjectClicked(Sender: TObject);
    procedure mnuBuildAllProjectClicked(Sender: TObject);
    procedure mnuAbortBuildProjectClicked(Sender: TObject);
    procedure mnuRunProjectClicked(Sender: TObject);
    procedure mnuPauseProjectClicked(Sender: TObject);
    procedure mnuStepIntoProjectClicked(Sender: TObject);
    procedure mnuStepOverProjectClicked(Sender: TObject);
    procedure mnuRunToCursorProjectClicked(Sender: TObject);
    procedure mnuStopProjectClicked(Sender: TObject);
    procedure mnuRunParametersClicked(Sender: TObject);
    procedure mnuProjectCompilerSettingsClicked(Sender: TObject);
    procedure mnuBuildFileClicked(Sender: TObject);
    procedure mnuRunFileClicked(Sender: TObject);
    procedure mnuConfigBuildFileClicked(Sender: TObject);

    // components menu
    // see pkgmanager.pas

    // tools menu
    procedure mnuToolConfigureClicked(Sender: TObject);
    procedure mnuToolSyntaxCheckClicked(Sender: TObject);
    procedure mnuToolGuessUnclosedBlockClicked(Sender: TObject);
    procedure mnuToolGuessMisplacedIFDEFClicked(Sender: TObject);
    procedure mnuToolMakeResourceStringClicked(Sender: TObject);
    procedure mnuToolDiffClicked(Sender: TObject);
    procedure mnuToolConvertDFMtoLFMClicked(Sender: TObject);
    procedure mnuToolCheckLFMClicked(Sender: TObject);
    procedure mnuToolConvertDelphiUnitClicked(Sender: TObject);
    procedure mnuToolConvertDelphiProjectClicked(Sender: TObject);
    procedure mnuToolBuildLazarusClicked(Sender: TObject);
    procedure mnuToolConfigBuildLazClicked(Sender: TObject);
    procedure mnuCustomExtToolClick(Sender: TObject);

    // environment menu
    procedure mnuEnvGeneralOptionsClicked(Sender: TObject);
    procedure mnuEnvEditorOptionsClicked(Sender: TObject);
    procedure mnuEnvCodeToolsOptionsClicked(Sender: TObject);
    procedure mnuEnvCodeToolsDefinesEditorClicked(Sender: TObject);
    procedure mnuEnvRescanFPCSrcDirClicked(Sender: TObject);

    // windows menu

    // help menu
    // see helpmanager.pas
    
    procedure OpenFileDownArrowClicked(Sender: TObject);
    procedure mnuOpenFilePopupClick(Sender: TObject);

  public
    // Global IDE events
    procedure OnProcessIDECommand(Sender: TObject; Command: word;
                                  var Handled: boolean);
    procedure OnExecuteIDEShortCut(Sender: TObject;
                       var Key: word; Shift: TShiftState; Areas: TCommandAreas);
    procedure OnExecuteIDECommand(Sender: TObject; Command: word);

    // Environment options dialog events
    procedure OnLoadEnvironmentSettings(Sender: TObject;
      TheEnvironmentOptions: TEnvironmentOptions);
    procedure OnSaveEnvironmentSettings(Sender: TObject;
      TheEnvironmentOptions: TEnvironmentOptions);
    procedure DoShowEnvGeneralOptions(StartPage: TEnvOptsDialogPage);

    // SourceNotebook events
    procedure OnSrcNoteBookActivated(Sender: TObject);
    procedure OnSrcNoteBookAddJumpPoint(ACaretXY: TPoint; ATopLine: integer;
      APageIndex: integer; DeleteForwardHistory: boolean);
    procedure OnSrcNoteBookCtrlMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftstate; X, Y: Integer);
    procedure OnSrcNotebookDeleteLastJumPoint(Sender: TObject);
    procedure OnSrcNotebookEditorVisibleChanged(Sender: TObject);
    procedure OnSrcNotebookEditorChanged(Sender: TObject);
    procedure OnSrcNotebookCurCodeBufferChanged(Sender: TObject);
    procedure OnSrcNotebookFileNew(Sender: TObject);
    procedure OnSrcNotebookFileOpen(Sender: TObject);
    procedure OnSrcNotebookFileOpenAtCursor(Sender: TObject);
    procedure OnSrcNotebookFileSave(Sender: TObject);
    procedure OnSrcNotebookFileSaveAs(Sender: TObject);
    procedure OnSrcNotebookFileClose(Sender: TObject);
    procedure OnSrcNotebookFindDeclaration(Sender: TObject);
    procedure OnSrcNotebookInitIdentCompletion(Sender: TObject;
      var Handled, Abort: boolean);
    procedure OnSrcNotebookJumpToHistoryPoint(var NewCaretXY: TPoint;
      var NewTopLine, NewPageIndex: integer; JumpAction: TJumpHistoryAction);
    procedure OnSrcNotebookMovingPage(Sender: TObject;
      OldPageIndex, NewPageIndex: integer);
    procedure OnSrcNotebookReadOnlyChanged(Sender: TObject);
    procedure OnSrcNotebookSaveAll(Sender: TObject);
    procedure OnSrcNotebookShowHintForSource(SrcEdit: TSourceEditor;
                                           ClientPos: TPoint; CaretPos: TPoint);
    procedure OnSrcNoteBookShowUnitInfo(Sender: TObject);
    procedure OnSrcNotebookToggleFormUnit(Sender: TObject);
    procedure OnSrcNotebookToggleObjectInsp(Sender: TObject);
    procedure OnSrcNotebookViewJumpHistory(Sender: TObject);
    procedure OnSrcNotebookShowSearchResultsView(Sender: TObject);
    procedure OnSrcNoteBookPopupMenu(AddMenuItemProc: TAddMenuItemProc);

    // ObjectInspector + PropertyEditorHook events
    procedure OIOnSelectPersistents(Sender: TObject);
    procedure OIOnShowOptions(Sender: TObject);
    procedure OIRemainingKeyUp(Sender: TObject; var Key: Word;
       Shift: TShiftState);
    procedure OIOnAddToFavourites(Sender: TObject);
    procedure OIOnRemoveFromFavourites(Sender: TObject);
    procedure OnPropHookGetMethods(TypeData: PTypeData; Proc:TGetStringProc);
    function OnPropHookMethodExists(const AMethodName: ShortString;
                                    TypeData: PTypeData;
                                    var MethodIsCompatible, MethodIsPublished,
                                    IdentIsMethod: boolean): boolean;
    function OnPropHookCreateMethod(const AMethodName:ShortString;
                                    ATypeInfo:PTypeInfo): TMethod;
    procedure OnPropHookShowMethod(const AMethodName:ShortString);
    procedure OnPropHookRenameMethod(const CurName, NewName:ShortString);
    function OnPropHookBeforeAddPersistent(Sender: TObject;
                                           APersistentClass: TPersistentClass;
                                           AParent: TPersistent): boolean;
    procedure OnPropHookComponentRenamed(AComponent: TComponent);
    procedure OnPropHookPersistentAdded(APersistent: TPersistent;
                                        Select: boolean);
    procedure OnPropHookDeletePersistent(APersistent: TPersistent);

    // designer events
    procedure OnDesignerGetSelectedComponentClass(Sender: TObject;
                                 var RegisteredComponent: TRegisteredComponent);
    procedure OnDesignerUnselectComponentClass(Sender: TObject);
    procedure OnDesignerSetDesigning(Sender: TObject; Component: TComponent;
                                     Value: boolean);
    procedure OnDesignerShowOptions(Sender: TObject);
    procedure OnDesignerPasteComponent(Sender: TObject; LookupRoot: TComponent;
                            TxtCompStream: TStream; ParentControl: TWinControl;
                            var NewComponent: TComponent);
    procedure OnDesignerPropertiesChanged(Sender: TObject);
    procedure OnDesignerPersistentAdded(Sender: TObject; APersistent: TPersistent;
                                        AComponentClass: TRegisteredComponent);
    procedure OnDesignerPersistentDeleted(Sender: TObject;
                                          APersistent: TPersistent);
    procedure OnDesignerRemovePersistent(Sender: TObject;
                                         APersistent: TPersistent);
    procedure OnDesignerModified(Sender: TObject);
    procedure OnDesignerActivated(Sender: TObject);
    procedure OnDesignerCloseQuery(Sender: TObject);
    procedure OnDesignerRenameComponent(ADesigner: TDesigner;
                                 AComponent: TComponent; const NewName: string);

    // control selection
    procedure OnControlSelectionChanged(Sender: TObject);
    procedure OnControlSelectionPropsChanged(Sender: TObject);
    procedure OnControlSelectionFormChanged(Sender: TObject; OldForm,
                                            NewForm: TCustomForm);

    // project inspector
    procedure ProjInspectorOpen(Sender: TObject);
    function ProjInspectorAddUnitToProject(Sender: TObject;
                                           AnUnitInfo: TUnitInfo): TModalresult;
    function ProjInspectorRemoveFile(Sender: TObject;
                                     AnUnitInfo: TUnitInfo): TModalresult;

    // compiler options dialog events
    procedure OnCompilerOptionsDialogTest(Sender: TObject);
    procedure OnCompilerOptionsImExport(Sender: TObject);

    // unit dependencies events
    procedure UnitDependenciesViewAccessingSources(Sender: TObject);
    function UnitDependenciesViewGetProjectMainFilename(
        Sender: TObject): string;
    procedure UnitDependenciesViewOpenFile(Sender: TObject;
        const Filename: string);

    // code explorer events
    procedure OnCodeExplorerGetCodeTree(Sender: TObject;
                                        var ACodeTool: TCodeTool);
    procedure OnCodeExplorerJumpToCode(Sender: TObject; const Filename: string;
                                       const Caret: TPoint; TopLine: integer);

    // view project ToDo list events
    procedure ViewProjectTodosOpenFile(Sender: TObject;
      const Filename: string; const LineNumber: integer);

    // CodeToolBoss events
    procedure OnCodeToolNeedsExternalChanges(Manager: TCodeToolManager;
                                             var Abort: boolean);
    procedure OnBeforeCodeToolBossApplyChanges(Manager: TCodeToolManager;
                                    var Abort: boolean);
    procedure OnAfterCodeToolBossApplyChanges(Manager: TCodeToolManager);
    function OnCodeToolBossSearchUsedUnit(const SrcFilename: string;
                     const TheUnitName, TheUnitInFilename: string): TCodeBuffer;
    function OnCodeToolBossCheckAbort: boolean;
    procedure CodeToolBossGetVirtualDirectoryAlias(Sender: TObject;
                                                   var RealDir: string);
    procedure CodeToolBossGetVirtualDirectoryDefines(DefTree: TDefineTree;
                                                     DirDef: TDirectoryDefines);
    procedure OnCodeToolBossFindDefineProperty(Sender: TObject;
               const PersistentClassName, AncestorClassName, Identifier: string;
               var IsDefined: boolean);
    function MacroFunctionProject(Data: Pointer): boolean;
    procedure OnCompilerGraphStampIncreased;

    // MessagesView events
    procedure MessagesViewSelectionChanged(sender: TObject);

    //SearchResultsView events
    procedure SearchResultsViewSelectionChanged(sender: TObject);

    // External Tools events
    procedure OnExtToolNeedsOutputFilter(var OutputFilter: TOutputFilter;
                                         var Abort: boolean);
    procedure OnExtToolFreeOutputFilter(OutputFilter: TOutputFilter;
                                        ErrorOccurred: boolean);
  private
    FDisplayState: TDisplayState;
    FLastFormActivated: TCustomForm;// used to find the last form so you can
                                    // display the correct tab
    FOpenEditorsOnCodeToolChange: boolean;

    FRunProcess: TProcess; // temp solution, will be replaced by dummydebugger

  protected
    procedure SetToolStatus(const AValue: TIDEToolStatus); override;
    function DoResetToolStatus(Interactive: boolean): boolean;
    procedure Notification(AComponent: TComponent;
                           Operation: TOperation); override;

    procedure OnApplyWindowLayout(ALayout: TIDEWindowLayout);
    procedure AddRecentProjectFileToEnvironment(const AFilename: string);

    // methods for start
    procedure StartProtocol;
    procedure LoadGlobalOptions;
    procedure SetupMainMenu; override;
    procedure SetupStandardIDEMenuItems;
    procedure SetupStandardProjectTypes;
    procedure SetRecentFilesMenu;
    procedure SetRecentProjectFilesMenu;
    procedure SetupFileMenu; override;
    procedure SetupEditMenu; override;
    procedure SetupSearchMenu; override;
    procedure SetupViewMenu; override;
    procedure SetupProjectMenu; override;
    procedure SetupRunMenu; override;
    procedure SetupComponentsMenu; override;
    procedure SetupToolsMenu; override;
    procedure SetupEnvironmentMenu; override;
    procedure SetupWindowsMenu; override;
    procedure SetupHelpMenu; override;
    procedure LoadMenuShortCuts; override;
    procedure ConnectMainBarEvents;
    procedure SetupSpeedButtons;
    procedure SetupComponentNoteBook;
    procedure SetupHints;
    procedure SetupOutputFilter;
    procedure SetupObjectInspector;
    procedure SetupCompilerInterface;
    procedure SetupFormEditor;
    procedure SetupSourceNotebook;
    procedure SetupTransferMacros;
    procedure SetupControlSelection;
    procedure SetupIDEInterface;
    procedure SetupStartProject;
    procedure ReOpenIDEWindows;

    // methods for 'new unit'
    function CreateNewCodeBuffer(Descriptor: TProjectFileDescriptor;
        NewOwner: TObject; NewFilename: string; var NewCodeBuffer: TCodeBuffer;
        var NewUnitName: string): TModalResult;
    function CreateNewForm(NewUnitInfo: TUnitInfo;
        AncestorType: TPersistentClass; ResourceCode: TCodeBuffer): TModalResult;

    // methods for 'save unit'
    function DoLoadResourceFile(AnUnitInfo: TUnitInfo;
        var LFMCode, ResourceCode: TCodeBuffer;
        IgnoreSourceErrors: boolean): TModalResult;
    function DoShowSaveFileAsDialog(AnUnitInfo: TUnitInfo;
        var ResourceCode: TCodeBuffer): TModalResult;
    function DoSaveFileResources(AnUnitInfo: TUnitInfo;
        ResourceCode, LFMCode: TCodeBuffer; Flags: TSaveFlags): TModalResult;
    function DoRenameUnit(AnUnitInfo: TUnitInfo;
        NewFilename, NewUnitName: string;
        var ResourceCode: TCodeBuffer): TModalresult;

    // methods for 'open unit' and 'open main unit'
    function DoOpenNotExistingFile(const AFileName:string;
        Flags: TOpenFlags): TModalResult;
    function DoOpenUnknownFile(const AFileName:string; Flags: TOpenFlags;
        var NewUnitInfo: TUnitInfo; var Handled: boolean): TModalResult;
    procedure DoRestoreBookMarks(AnUnitInfo: TUnitInfo; ASrcEdit:TSourceEditor);
    function DoOpenFileInSourceEditor(AnUnitInfo: TUnitInfo;
        PageIndex: integer; Flags: TOpenFlags): TModalResult;
    function DoLoadLFM(AnUnitInfo: TUnitInfo; Flags: TOpenFlags): TModalResult;
    function DoLoadLFM(AnUnitInfo: TUnitInfo; LFMBuf: TCodeBuffer;
                       Flags: TOpenFlags; CloseDsgnForm: boolean): TModalResult;

    // methods for 'close unit'
    function CloseDesignerForm(AnUnitInfo: TUnitInfo): TModalResult;

    // methods for creating a project
    function CreateProjectObject(ProjectDesc,
                             FallbackProjectDesc: TProjectDescriptor): TProject;
    procedure OnLoadProjectInfoFromXMLConfig(TheProject: TProject;
                                             XMLConfig: TXMLConfig);
    procedure OnSaveProjectInfoToXMLConfig(TheProject: TProject;
                         XMLConfig: TXMLConfig; WriteFlags: TProjectWriteFlags);

    // methods for 'save project'
    procedure GetMainUnit(var MainUnitInfo: TUnitInfo;
        var MainUnitSrcEdit: TSourceEditor; UpdateModified: boolean);
    procedure SaveSrcEditorProjectSpecificSettings(AnUnitInfo: TUnitInfo);
    procedure SaveSourceEditorProjectSpecificSettings;
    function DoShowSaveProjectAsDialog: TModalResult;
    function DoUpdateLRSFromLFM(const LRSFilename: string): TModalResult;

    // methods for open project, create project from source
    function DoCompleteLoadingProjectInfo: TModalResult;

    // methods for publish project
    procedure OnCopyFile(const Filename: string; var Copy: boolean;
        Data: TObject);
    procedure OnCopyError(const ErrorData: TCopyErrorData;
        var Handled: boolean; Data: TObject);

  public
    CustomExtToolMenuSeparator: TMenuItem;
    CurDefinesCompilerFilename: String;
    CurDefinesCompilerOptions: String;
    class procedure ParseCmdLineOptions;

    constructor Create(TheOwner: TComponent); override;
    procedure StartIDE; override;
    destructor Destroy; override;
    procedure CreateOftenUsedForms; override;
    procedure CreateSearchResultWindow;
    procedure UpdateDefaultPascalFileExtensions;

    // files/units
    function DoNewFile(NewFileDescriptor: TProjectFileDescriptor;
        var NewFilename: string; const NewSource: string;
        NewFlags: TNewFlags; NewOwner: TObject): TModalResult; override;
    function DoNewOther: TModalResult;
    function DoSaveEditorFile(PageIndex:integer;
        Flags: TSaveFlags): TModalResult;
    function DoCloseEditorFile(PageIndex:integer;
        Flags: TCloseFlags):TModalResult;
    function DoCloseEditorFile(const Filename: string;
        Flags: TCloseFlags): TModalResult;
    function DoOpenEditorFile(AFileName: string; PageIndex: integer;
        Flags: TOpenFlags): TModalResult; override;
    function DoOpenFileAtCursor(Sender: TObject): TModalResult;
    function DoOpenFileAndJumpToIdentifier(const AFilename, AnIdentifier: string;
        PageIndex: integer; Flags: TOpenFlags): TModalResult; override;
    function DoSaveAll(Flags: TSaveFlags): TModalResult;
    procedure DoRestart;
    function DoOpenMainUnit(ProjectLoading: boolean): TModalResult;
    function DoRevertMainUnit: TModalResult;
    function DoViewUnitsAndForms(OnlyForms: boolean): TModalResult;
    procedure DoViewUnitDependencies;
    procedure DoViewUnitInfo;
    procedure DoShowCodeExplorer;
    function CreateNewUniqueFilename(const Prefix, Ext: string;
       NewOwner: TObject; Flags: TSearchIDEFileFlags; TryWithoutNumber: boolean
       ): string; override;

    // project(s)
    function DoNewProject(ProjectDesc: TProjectDescriptor): TModalResult; override;
    function DoSaveProject(Flags: TSaveFlags): TModalResult; override;
    function DoCloseProject: TModalResult; override;
    function DoOpenProjectFile(AFileName: string;
                               Flags: TOpenFlags): TModalResult; override;
    function DoPublishProject(Flags: TSaveFlags;
                              ShowDialog: boolean): TModalResult; override;
    function DoImExportCompilerOptions(Sender: TObject): TModalResult; override;
    function DoShowProjectInspector: TModalResult; override;
    function DoAddActiveUnitToProject: TModalResult;
    function DoRemoveFromProjectDialog: TModalResult;
    procedure DoWarnAmbiguousFiles;
    procedure DoUpdateProjectResourceInfo;
    function DoUpdateProjectAutomaticFiles: TModalResult;
    function DoSaveForBuild: TModalResult; override;
    function DoBuildProject(const AReason: TCompileReason): TModalResult;
    function DoAbortBuild: TModalResult;
    function DoInitProjectRun: TModalResult; override;
    function DoRunProject: TModalResult;
    function SomethingOfProjectIsModified: boolean;
    function DoCreateProjectForProgram(ProgramBuf: TCodeBuffer): TModalResult;
    function DoSaveProjectIfChanged: TModalResult;
    function DoSaveProjectToTestDirectory: TModalResult;
    function DoShowToDoList: TModalResult;
    function DoTestCompilerSettings(
                            TheCompilerOptions: TCompilerOptions): TModalResult;

    // edit menu
    procedure DoCommand(EditorCommand: integer); override;
    procedure DoSourceEditorCommand(EditorCommand: integer);

    // Delphi conversion
    function DoConvertDFMtoLFM: TModalResult;
    function DoCheckLFMInEditor: TModalResult;
    function DoConvertDelphiUnit(const DelphiFilename: string): TModalResult;
    function DoConvertDelphiProject(const DelphiFilename: string): TModalResult;
    procedure UpdateCustomToolsInMenu;

    // external tools
    function PrepareForCompile: TModalResult; override;
    function DoRunExternalTool(Index: integer): TModalResult;
    function DoSaveBuildIDEConfigs(Flags: TBuildLazarusFlags): TModalResult; override;
    function DoBuildLazarus(Flags: TBuildLazarusFlags): TModalResult; override;
    function DoExecuteCompilationTool(Tool: TCompilationTool;
                                      const WorkingDir, ToolTitle: string
                                      ): TModalResult; override;
    function DoBuildFile: TModalResult;
    function DoRunFile: TModalResult;
    function DoConfigBuildFile: TModalResult;
    function GetIDEDirectives(AnUnitInfo: TUnitInfo;
                              DirectiveList: TStrings): TModalResult;

    // useful information methods
    procedure GetCurrentUnit(var ActiveSourceEditor: TSourceEditor;
                             var ActiveUnitInfo: TUnitInfo); override;
    procedure GetUnitWithPageIndex(PageIndex: integer;
          var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo); override;
    procedure GetDesignerUnit(ADesigner: TDesigner;
          var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo); override;
    procedure GetObjectInspectorUnit(
          var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo); override;
    procedure GetUnitWithForm(AForm: TCustomForm;
          var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo); override;
    procedure GetUnitWithPersistent(APersistent: TPersistent;
          var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo); override;
    function GetSourceEditorForUnitInfo(AnUnitInfo: TUnitInfo): TSourceEditor; override;
    function CreateSrcEditPageName(const AnUnitName, AFilename: string;
      IgnorePageIndex: integer): string;

    // useful file methods
    function FindUnitFile(const AFilename: string): string; override;
    function FindSourceFile(const AFilename, BaseDirectory: string;
                            Flags: TFindSourceFlags): string; override;
    function FileExistsInIDE(const Filename: string;
                             SearchFlags: TProjectFileSearchFlags): boolean;
    function DoSaveStreamToFile(AStream:TStream; const Filename:string;
                                IsPartOfProject:boolean): TModalResult;
    function DoSaveStringToFile(const Filename, Src,
                               FileDescription: string): TModalResult; override;
    function LoadIDECodeBuffer(var ACodeBuffer: TCodeBuffer;
                               const AFilename: string;
                               Flags: TLoadBufferFlags): TModalResult;
    function DoLoadMemoryStreamFromFile(MemStream: TMemoryStream;
                                        const AFilename:string): TModalResult;
    function DoSaveCodeBufferToFile(ABuffer: TCodeBuffer;
                                    const AFilename: string;
                                    IsPartOfProject:boolean): TModalResult; override;
    function DoBackupFile(const Filename:string;
                          IsPartOfProject:boolean): TModalResult; override;
    function DoRenameUnitLowerCase(AnUnitInfo: TUnitInfo;
                                   AskUser: boolean): TModalresult;
    function DoCheckFilesOnDisk: TModalResult; override;
    function DoPublishModule(Options: TPublishModuleOptions;
                             const SrcDirectory, DestDirectory: string
                             ): TModalResult; override;

    // useful frontend methods
    procedure DoSwitchToFormSrc(var ActiveSourceEditor:TSourceEditor;
      var ActiveUnitInfo:TUnitInfo);
    procedure DoSwitchToFormSrc(ADesigner: TDesigner;
      var ActiveSourceEditor:TSourceEditor; var ActiveUnitInfo:TUnitInfo);
    function GetFormOfSource(AnUnitInfo: TUnitInfo;
      LoadForm: boolean): TCustomForm;
    procedure UpdateCaption; override;
    procedure HideIDE; override;
    procedure HideUnmodifiedDesigners;
    procedure UnhideIDE; override;

    // methods for codetools
    procedure InitCodeToolBoss;
    procedure RescanCompilerDefines(OnlyIfCompilerChanged: boolean);
    procedure UpdateEnglishErrorMsgFilename;
    procedure ActivateCodeToolAbortableMode;
    function BeginCodeTool(var ActiveSrcEdit: TSourceEditor;
                           var ActiveUnitInfo: TUnitInfo;
                           Flags: TCodeToolsFlags): boolean;
    function BeginCodeTool(ADesigner: TDesigner;
                           var ActiveSrcEdit: TSourceEditor;
                           var ActiveUnitInfo: TUnitInfo;
                           Flags: TCodeToolsFlags): boolean;
    function DoJumpToSourcePosition(const Filename: string;
                               NewX, NewY, NewTopLine: integer;
                               AddJumpPoint: boolean): TModalResult; override;
    function DoJumpToCodePos(
                        ActiveSrcEdit: TSourceEditor;
                        ActiveUnitInfo: TUnitInfo;
                        NewSource: TCodeBuffer; NewX, NewY, NewTopLine: integer;
                        AddJumpPoint: boolean): TModalResult; override;
    procedure DoJumpToCodeToolBossError; override;
    procedure UpdateSourceNames;
    procedure SaveSourceEditorChangesToCodeCache(PageIndex: integer); override;
    procedure ApplyCodeToolChanges;
    procedure DoJumpToProcedureSection;
    procedure DoFindDeclarationAtCursor;
    procedure DoFindDeclarationAtCaret(const LogCaretXY: TPoint);
    function DoFindRenameIdentifier(Rename: boolean): TModalResult;
    function DoInitIdentCompletion: boolean;
    procedure DoCompleteCodeAtCursor;
    procedure DoExtractProcFromSelection;
    function DoCheckSyntax: TModalResult;
    procedure DoGoToPascalBlockOtherEnd;
    procedure DoGoToPascalBlockStart;
    procedure DoJumpToGuessedUnclosedBlock(FindNext: boolean);
    procedure DoJumpToGuessedMisplacedIFDEF(FindNext: boolean);

    procedure DoGotoIncludeDirective;
    procedure SaveIncludeLinks;

    // tools
    function DoMakeResourceString: TModalResult;
    function DoDiff: TModalResult;
    function DoFindInFiles: TModalResult;

    // message view
    function DoJumpToCompilerMessage(Index:integer;
      FocusEditor: boolean): boolean;
    procedure DoJumpToNextError(DirectionDown: boolean);
    procedure DoShowMessagesView;
    procedure DoArrangeSourceEditorAndMessageView(PutOnTop: boolean);
    
    // methods for debugging, compiling and external tools
    function GetTestBuildDir: string; override;
    function GetProjectTargetFilename: string;
    function GetTargetOS: string;
    function GetTestProjectFilename: string;
    function GetTestUnitFilename(AnUnitInfo: TUnitInfo): string; override;
    function GetTargetUnitFilename(AnUnitInfo: TUnitInfo): string;
    function IsTestUnitFilename(const AFilename: string): boolean; override;
    function GetRunCommandLine: string; override;
    function GetProjPublishDir: string;
    procedure OnMacroSubstitution(TheMacro: TTransferMacro; var s:string;
                                  var Handled, Abort: boolean);
    function OnSubstituteCompilerOption(Options: TParsedCompilerOptions;
                                        const UnparsedValue: string): string;
    function OnMacroPromptFunction(const s:string; var Abort: boolean):string;
    function OnMacroFuncMakeExe(const Filename:string; var Abort: boolean):string;
    procedure OnCmdLineCreate(var CmdLine: string; var Abort:boolean);
    procedure GetIDEFileState(Sender: TObject; const AFilename: string;
      NeededFlags: TIDEFileStateFlags; var ResultFlags: TIDEFileStateFlags); override;

    // search results
    function DoJumpToSearchResult(FocusEditor: boolean): boolean;
    procedure DoShowSearchResultsView;

    // form editor and designer
    procedure DoBringToFrontFormOrUnit;
    procedure DoBringToFrontFormOrInspector(ForceInspector: boolean);
    procedure DoShowDesignerFormOfCurrentSrc;
    procedure DoShowSourceOfActiveDesignerForm;
    procedure SetDesigning(AComponent: TComponent; Value: Boolean);
    procedure CreateDesignerForComponent(AComponent: TComponent);
    procedure InvalidateAllDesignerForms;
    procedure UpdateIDEComponentPalette;
    procedure ShowDesignerForm(AForm: TCustomForm);
    procedure DoViewAnchorEditor;

    // editor and environment options
    procedure SaveEnvironment; override;
    procedure LoadDesktopSettings(TheEnvironmentOptions: TEnvironmentOptions);
    procedure SaveDesktopSettings(TheEnvironmentOptions: TEnvironmentOptions);
  end;


const
  CodeToolsIncludeLinkFile = 'includelinks.xml';

var
  ShowSplashScreen: boolean;

implementation

uses
  Math;
  
var
  SkipAutoLoadingLastProject: boolean;
  StartedByStartLazarus: boolean;

//==============================================================================


{ TMainIDE }

{-------------------------------------------------------------------------------
  procedure TMainIDE.ParseCmdLineOptions;

  Parses the command line for the IDE.
-------------------------------------------------------------------------------}
procedure TMainIDE.ParseCmdLineOptions;
const
  PrimaryConfPathOptLong='--primary-config-path=';
  PrimaryConfPathOptShort='--pcp=';
  SecondaryConfPathOptLong='--secondary-config-path=';
  SecondaryConfPathOptShort='--scp=';
  NoSplashScreenOptLong='--no-splash-screen';
  NoSplashScreenOptShort='--nsc';
  StartedByStartLazarusOpt='--started-by-startlazarus';
  SkipLastProjectOpt='--skip-last-project';
  DebugLogOpt='--debug-log=';
  LanguageOpt='--language=';

  function ParamIsOption(ParamIndex: integer;
    const Option: string): boolean;
  begin
    Result:=AnsiCompareText(ParamStr(ParamIndex),Option)=0;
  end;

  function ParamIsOptionPlusValue(ParamIndex: integer;
    const Option: string; var AValue: string): boolean;
  var
    p: String;
  begin
    p:=ParamStr(ParamIndex);
    Result:=AnsiCompareText(LeftStr(p,length(Option)),Option)=0;
    if Result then
      AValue:=copy(p,length(Option)+1,length(p))
    else
      AValue:='';
  end;

const
  space = '                      ';
var
  i: integer;
  AValue: string;
begin
  StartedByStartLazarus:=false;
  SkipAutoLoadingLastProject:=false;
  if (ParamCount>0)
  and ((AnsiCompareText(ParamStr(1),'--help')=0)
    or (AnsiCompareText(ParamStr(1),'-help')=0)
    or (AnsiCompareText(ParamStr(1),'-?')=0)
    or (AnsiCompareText(ParamStr(1),'-h')=0)) then
  begin
    TranslateResourceStrings(ProgramDirectory,'');
    writeln(lislazarusOptionsProjectFilename);
    writeln('');
    writeln(lisIDEOptions);
    writeln('');
    writeln('--help or -?             ', listhisHelpMessage);
    writeln('');
    writeln(PrimaryConfPathOptLong,' <path>');
    writeln('or ',PrimaryConfPathOptShort,' <path>');
    writeln(BreakString(space+lisprimaryConfigDirectoryWhereLazarusStoresItsConfig,
                        75, 22), LazConf.GetPrimaryConfigPath);
    writeln('');
    writeln(SecondaryConfPathOptLong,' <path>');
    writeln('or ',SecondaryConfPathOptShort,' <path>');
    writeln(BreakString(space+lissecondaryConfigDirectoryWhereLazarusSearchesFor,
                        75, 22), LazConf.GetSecondaryConfigPath);
    writeln('');
    writeln(DebugLogOpt,' <file>');
    writeln(BreakString(space+lisFileWhereDebugOutputIsWritten, 75, 22));
    writeln('');
    writeln(NoSplashScreenOptLong);
    writeln('or ',NoSplashScreenOptShort);
    writeln(BreakString(space+lisDoNotShowSplashScreen,75, 22));
    writeln('');
    writeln(SkipLastProjectOpt);
    writeln(BreakString(space+lisSkipLoadingLastProject, 75, 22));
    writeln('');
    writeln(LanguageOpt);
    writeln(BreakString(space+lisOverrideLanguage,75, 22));
    writeln('');
    writeln('');
    writeln('');
    writeln(lisCmdLineLCLInterfaceSpecificOptions);
    writeln('');
    writeln(GetCmdLineParamDescForInterface);
    Application.Terminate;
    Halt;
  end;
  for i:=1 to ParamCount do begin
    if ParamIsOptionPlusValue(i,PrimaryConfPathOptLong,AValue) then begin
      SetPrimaryConfigPath(AValue);
    end;
    if ParamIsOptionPlusValue(i,PrimaryConfPathOptShort,AValue) then begin
      SetPrimaryConfigPath(AValue);
    end;
    if ParamIsOptionPlusValue(i,SecondaryConfPathOptLong,AValue) then begin
      SetSecondaryConfigPath(AValue);
    end;
    if ParamIsOptionPlusValue(i,SecondaryConfPathOptShort,AValue) then begin
      SetSecondaryConfigPath(AValue);
    end;
    if ParamIsOption(i,NoSplashScreenOptLong)
    or ParamIsOption(i,NoSplashScreenOptShort) then begin
      ShowSplashScreen:=false;
    end;
    if ParamIsOption(i,SkipLastProjectOpt) then
      SkipAutoLoadingLastProject:=true;
    if ParamIsOption(i,StartedByStartLazarusOpt) then
      StartedByStartLazarus:=true;
  end;
end;

procedure TMainIDE.LoadGlobalOptions;
// load environment, miscellaneous, editor and codetools options
var
  InteractiveSetup: boolean;
begin
  InteractiveSetup:=true;

  EnvironmentOptions:=TEnvironmentOptions.Create;
  with EnvironmentOptions do begin
    SetLazarusDefaultFilename;
    Load(false);
    if Application.HasOption('language') then begin
      debugln('TMainIDE.LoadGlobalOptions overriding language from command line: ',
        Application.GetOptionValue('language'));
      EnvironmentOptions.LanguageID:=Application.GetOptionValue('language');
    end;
    TranslateResourceStrings(EnvironmentOptions.LazarusDirectory,
                             EnvironmentOptions.LanguageID);

    SetupCompilerFilename(InteractiveSetup);
    SetupFPCSourceDirectory(InteractiveSetup);
    SetupLazarusDirectory(InteractiveSetup);

    ExternalTools.OnNeedsOutputFilter:=@OnExtToolNeedsOutputFilter;
    ExternalTools.OnFreeOutputFilter:=@OnExtToolFreeOutputFilter;
    OnApplyWindowLayout:=@Self.OnApplyWindowLayout;
  end;
  UpdateDefaultPascalFileExtensions;

  EditorOpts:=TEditorOptions.Create;
  EditorOpts.Load;

  EnvironmentOptions.ExternalTools.LoadShortCuts(EditorOpts.KeyMap);

  MiscellaneousOptions:=TMiscellaneousOptions.Create;
  MiscellaneousOptions.Load;

  CodeToolsOpts:=TCodeToolsOptions.Create;
  with CodeToolsOpts do begin
    SetLazarusDefaultFilename;
    Load;
  end;

  InputHistories:=TInputHistories.Create;
  with InputHistories do begin
    SetLazarusDefaultFilename;
    Load;
  end;
end;

constructor TMainIDE.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  
  // load options
  CreatePrimaryConfigPath;
  StartProtocol;
  LoadGlobalOptions;

  // set the IDE mode to none (= editing mode)
  ToolStatus:=itNone;

  // setup macros
  SetupTransferMacros;

  // setup the code tools
  InitCodeToolBoss;

  // build and position the MainIDE form
  Application.CreateForm(TMainIDEBar,MainIDEBar);
  MainIDEBar.OnDestroy:=@OnMainBarDestroy;
  MainIDEBar.Constraints.MaxHeight:=100;
  MainIDEBar.Name := NonModalIDEWindowNames[nmiwMainIDEName];
  EnvironmentOptions.IDEWindowLayoutList.Apply(MainIDEBar,MainIDEBar.Name);
  HiddenWindowsOnRun:=TList.Create;

  // menu
  SetupStandardIDEMenuItems;
  SetupMainMenu;
  SetupSpeedButtons;
  SetupComponentNoteBook;
  ConnectMainBarEvents;
  
  // create main IDE register items
  NewIDEItems:=TNewLazIDEItemCategories.Create;
  SetupStandardProjectTypes;

  // initialize the other IDE managers
  DebugBoss:=TDebugManager.Create(nil);
  DebugBoss.ConnectMainBarEvents;
  PkgBoss:=TPkgManager.Create(nil);
  PkgBoss.ConnectMainBarEvents;
  HelpBoss:=THelpManager.Create(nil);
  HelpBoss.ConnectMainBarEvents;
  // setup the IDE components
  LoadMenuShortCuts;
  SetupOutputFilter;
  SetupCompilerInterface;
  SetupObjectInspector;
  SetupFormEditor;
  SetupSourceNotebook;
  SetupControlSelection;
  SetupIDEInterface;

  // Main IDE bar created and setup completed -> Show it
  MainIDEBar.Show;

  // load installed packages
  PkgBoss.LoadInstalledPackages;
  
  // load package configs
  HelpBoss.LoadHelpOptions;

  UpdateWindowsMenu;
end;

procedure TMainIDE.StartIDE;
begin
  // set OnIdle handlers
  Application.AddOnUserInputHandler(@OnApplicationUserInput,true);
  Application.AddOnIdleHandler(@OnApplicationIdle,true);
  Screen.AddHandlerRemoveForm(@OnScreenRemoveForm,true);
  SetupHints;

  // Now load a project
  SetupStartProject;

  // reopen extra windows
  ReOpenIDEWindows;
end;

destructor TMainIDE.Destroy;
begin
  ToolStatus:=itExiting;

  DebugLn('[TMainIDE.Destroy] A ');
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.Destroy A ');{$ENDIF}
  FreeThenNil(ProjInspector);
  FreeThenNil(CodeExplorerView);

  if DebugBoss<>nil then DebugBoss.EndDebugging;

  // free control selection
  if TheControlSelection<>nil then begin
    TheControlSelection.OnChange:=nil;
    TheControlSelection.OnSelectionFormChanged:=nil;
    FreeThenNil(TheControlSelection);
  end;

  // disconnect handlers
  Application.RemoveOnUserInputHandler(@OnApplicationUserInput);
  Application.RemoveOnIdleHandler(@OnApplicationIdle);
  Screen.RemoveHandlerRemoveForm(@OnScreenRemoveForm);
  IDECommands.OnExecuteIDECommand:=nil;

  // free project, if it is still there
  FreeThenNil(Project1);

  // free IDE parts
  FreeFormEditor;
  FreeAndNil(FindReplaceDlg);
  FreeAndNil(MessagesView);
  FreeThenNil(AnchorDesigner);
  FreeThenNil(ObjectInspector1);
  FreeThenNil(GlobalDesignHook);
  FreeThenNil(PkgBoss);
  FreeThenNil(HelpBoss);
  FreeThenNil(DebugBoss);
  FreeThenNil(TheCompiler);
  FreeThenNil(HiddenWindowsOnRun);
  FreeThenNil(TheOutputFilter);
  FreeThenNil(MacroList);
  FreeThenNil(IDEMacros);
  FreeThenNil(LazProjectFileDescriptors);
  FreeThenNil(LazProjectDescriptors);
  FreeThenNil(NewIDEItems);
  FreeThenNil(IDEMenuRoots);
  // IDE options objects
  FreeThenNil(CodeToolsOpts);
  FreeThenNil(MiscellaneousOptions);
  FreeThenNil(EditorOpts);
  FreeThenNil(EnvironmentOptions);
  FreeThenNil(InputHistories);

  DebugLn('[TMainIDE.Destroy] B  -> inherited Destroy... ',ClassName);
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.Destroy B ');{$ENDIF}
  FreeThenNil(SourceNotebook);
  inherited Destroy;
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.Destroy C ');{$ENDIF}

  FreeThenNil(IDEProtocolOpts);
  DebugLn('[TMainIDE.Destroy] END');
end;

procedure TMainIDE.CreateOftenUsedForms;
begin
  MessagesView:=TMessagesView.Create(nil);
  FindReplaceDlg:=TLazFindReplaceDialog.Create(nil);
end;

procedure TMainIDE.CreateSearchResultWindow;
begin
  if SearchResultsView<>nil then exit;
  Application.CreateForm(TSearchResultsView, SearchResultsView);
  with SearchResultsView do begin
    OnSelectionChanged:= @SearchResultsViewSelectionChanged;
  end;
end;

procedure TMainIDE.OIOnSelectPersistents(Sender: TObject);
begin
  TheControlSelection.AssignSelection(ObjectInspector1.Selection);
  GlobalDesignHook.SetSelection(ObjectInspector1.Selection);
end;

procedure TMainIDE.OIOnShowOptions(Sender: TObject);
begin
  DoShowEnvGeneralOptions(eodpObjectInspector);
end;

procedure TMainIDE.OIRemainingKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  OnExecuteIDEShortCut(Sender,Key,Shift,caDesign);
end;

procedure TMainIDE.OIOnAddToFavourites(Sender: TObject);
begin
  ShowAddRemoveFavouriteDialog(ObjectInspector1,true);
end;

procedure TMainIDE.OIOnRemoveFromFavourites(Sender: TObject);
begin
  ShowAddRemoveFavouriteDialog(ObjectInspector1,false);
end;

procedure TMainIDE.OnPropHookGetMethods(TypeData:PTypeData;
  Proc:TGetStringProc);
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[ctfSwitchToFormSource])
  then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.OnPropHookGetMethods] ************');
  {$ENDIF}
  if not CodeToolBoss.GetCompatiblePublishedMethods(ActiveUnitInfo.Source,
    ActiveUnitInfo.Component.ClassName,TypeData,Proc) then
  begin
    DoJumpToCodeToolBossError;
  end;
end;

{------------------------------------------------------------------------------}
procedure TMainIDE.MainIDEFormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  SaveEnvironment;
  SaveIncludeLinks;
  InputHistories.Save;
  PkgBoss.SaveSettings;
  if TheControlSelection<>nil then TheControlSelection.Clear;
  if SourceNoteBook<>nil then SourceNoteBook.ClearUnUsedEditorComponents(true);
end;

procedure TMainIDE.MainIDEFormCloseQuery(Sender: TObject;
  var CanClose: boolean);
var
  MsgResult: integer;
begin
  // stop debugging/compiling/...
  if not DoResetToolStatus(true) then begin
    CanClose:=false;
    exit;
  end;

  // check packages
  if (PkgBoss.DoSaveAllPackages([psfAskBeforeSaving])<>mrOk)
  or (PkgBoss.DoCloseAllPackageEditors<>mrOk) then begin
    CanClose:=false;
    exit;
  end;

  // check project
  if SomethingOfProjectIsModified then begin
    MsgResult:=MessageDlg(lisProjectChanged, Format(lisSaveChangesToProject,
      [Project1.Title]), mtConfirmation, [mbYes, mbNo, mbAbort], 0);
    case MsgResult of

    mrYes:
      begin
        CanClose := DoSaveProject([]) <> mrAbort;
        if not CanClose then exit;
      end;

    mrCancel, mrAbort:
      begin
        CanClose:= false;
        Exit;
      end;
    end;
  end;

  CanClose:=(DoCloseProject <> mrAbort);
end;

{------------------------------------------------------------------------------}
type
  TMoveFlags = set of (mfTop, mfLeft);

procedure TMainIDE.SetupSpeedButtons;

  function CreateButton(const AName, APixName: String; ANumGlyphs: Integer;
    var ALeft, ATop: Integer; const AMoveFlags: TMoveFlags;
    const AOnClick: TNotifyEvent; const AHint: String): TSpeedButton;
  begin
    Result := TSpeedButton.Create(OwningComponent);
    with Result do
    begin
      Name := AName;
      Parent := MainIDEBar.pnlSpeedButtons;
      Enabled := True;
      Top := ATop;
      Left := ALeft;
      OnClick := AOnClick;
      Glyph.LoadFromLazarusResource(APixName);
      NumGlyphs := ANumGlyphs;
      Flat := True;
      //Transparent:=True;
      if mfTop in AMoveFlags then Inc(ATop, Height);
      if mfLeft in AMoveFlags then Inc(ALeft, Width);
      Hint := AHint;
    end;
  end;

var
  ButtonTop, ButtonLeft, n: Integer;
begin
  MainIDEBar.pnlSpeedButtons := TPanel.Create(OwningComponent);
  with MainIDEBar.pnlSpeedButtons do begin
    Name := 'pnlSpeedButtons';
    Parent:= MainIDEBar;
    Align := alLeft;
    Top := 0;
    Left:= 0;
    Caption:= '';
    BevelWidth:=1;
    BevelOuter:=bvRaised;
  end;


  ButtonTop := 2;
  ButtonLeft := 2;
  MainIDEBar.NewUnitSpeedBtn       := CreateButton('NewUnitSpeedBtn'      , 'btn_newunit'   , 1, ButtonLeft, ButtonTop, [mfLeft], @mnuNewUnitClicked, lisHintNewUnit);

  MainIDEBar.OpenFileSpeedBtn      := CreateButton('OpenFileSpeedBtn'     , 'btn_openfile'  , 1, ButtonLeft, ButtonTop, [mfLeft], @mnuOpenClicked, lisHintOpen);

  // store left
  n := ButtonLeft;
  MainIDEBar.OpenFileArrowSpeedBtn := CreateButton('OpenFileArrowSpeedBtn', 'btn_downarrow' , 1, ButtonLeft, ButtonTop, [mfLeft], @OpenFileDownArrowClicked, '');
  MainIDEBar.OpenFileArrowSpeedBtn.Width := 12;
  ButtonLeft := n+12+1;

  MainIDEBar.SaveSpeedBtn          := CreateButton('SaveSpeedBtn'         , 'btn_save'      , 2, ButtonLeft, ButtonTop, [mfLeft], @mnuSaveClicked, lisHintSave);
  MainIDEBar.SaveAllSpeedBtn       := CreateButton('SaveAllSpeedBtn'      , 'btn_saveall'   , 1, ButtonLeft, ButtonTop, [mfLeft], @mnuSaveAllClicked, lisHintSaveAll);
  MainIDEBar.NewFormSpeedBtn       := CreateButton('NewFormSpeedBtn'      , 'btn_newform'   , 1, ButtonLeft, ButtonTop, [mfLeft], @mnuNewFormClicked, lisHintNewForm);
  MainIDEBar.ToggleFormSpeedBtn    := CreateButton('ToggleFormSpeedBtn'   , 'btn_toggleform', 2, ButtonLeft, ButtonTop, [mfLeft, mfTop], @mnuToggleFormUnitCLicked, lisHintToggleFormUnit);

  // new row
  ButtonLeft := 2;
  MainIDEBar.ViewUnitsSpeedBtn     := CreateButton('ViewUnitsSpeedBtn'    , 'btn_viewunits' , 1, ButtonLeft, ButtonTop, [mfLeft], @mnuViewUnitsClicked, lisHintViewUnits);
  MainIDEBar.ViewFormsSpeedBtn     := CreateButton('ViewFormsSpeedBtn'    , 'btn_viewforms' , 1, ButtonLeft, ButtonTop, [mfLeft], @mnuViewFormsClicked, lisHintViewForms);
  inc(ButtonLeft,13);
  MainIDEBar.RunSpeedButton        := CreateButton('RunSpeedButton'       , 'btn_run'       , 2, ButtonLeft, ButtonTop, [mfLeft], @mnuRunProjectClicked, lisHintRun);
  MainIDEBar.PauseSpeedButton      := CreateButton('PauseSpeedButton'     , 'btn_pause'       , 2, ButtonLeft, ButtonTop, [mfLeft], @mnuPauseProjectClicked, lisHintPause);
  MainIDEBar.PauseSpeedButton.Enabled:=false;
  MainIDEBar.StepIntoSpeedButton   := CreateButton('StepIntoSpeedButton'  , 'btn_stepinto'       , 1, ButtonLeft, ButtonTop, [mfLeft], @mnuStepIntoProjectClicked, lisHintStepInto);
  MainIDEBar.StepOverSpeedButton   := CreateButton('StepOverpeedButton'   , 'btn_stepover'       , 1, ButtonLeft, ButtonTop, [mfLeft, mfTop], @mnuStepOverProjectClicked, lisHintStepOver);

  MainIDEBar.pnlSpeedButtons.Width := ButtonLeft+3;
  MainIDEBar.pnlSpeedButtons.Height := ButtonTop+3;


  // create the popupmenu for the OpenFileArrowSpeedBtn
  MainIDEBar.OpenFilePopUpMenu := TPopupMenu.Create(OwningComponent);
  MainIDEBar.OpenFilePopupMenu.Name:='OpenFilePopupMenu';
  MainIDEBar.OpenFilePopupMenu.AutoPopup := False;
end;

procedure TMainIDE.SetupComponentNoteBook;
begin
  // Component Notebook
  MainIDEBar.ComponentNotebook := TNotebook.Create(OwningComponent);
  with MainIDEBar.ComponentNotebook do begin
    Parent := MainIDEBar;
    Name := 'ComponentNotebook';
    Align := alClient;
    Left := MainIDEBar.pnlSpeedButtons.Left + MainIDEBar.pnlSpeedButtons.Width;
    Top := 0;
    Width := MainIDEBar.ClientWidth - Left;
    Height := 60; //Self.ClientHeight - ComponentNotebook.Top;
  end;
end;

procedure TMainIDE.SetupHints;
var
  CurShowHint: boolean;
  AControl: TControl;
  i, j: integer;
begin
  if EnvironmentOptions=nil then exit;
  // update all hints in the component palette
  CurShowHint:=EnvironmentOptions.ShowHintsForComponentPalette;
  for i:=0 to MainIDEBar.ComponentNotebook.PageCount-1 do begin
    for j:=0 to MainIDEBar.ComponentNotebook.Page[i].ControlCount-1 do begin
      AControl:=MainIDEBar.ComponentNotebook.Page[i].Controls[j];
      AControl.ShowHint:=CurShowHint;
    end;
  end;
  // update all hints in main ide toolbars
  CurShowHint:=EnvironmentOptions.ShowHintsForMainSpeedButtons;
  for i:=0 to MainIDEBar.pnlSpeedButtons.ControlCount-1 do begin
    AControl:=MainIDEBar.pnlSpeedButtons.Controls[i];
    AControl.ShowHint:=CurShowHint;
  end;
end;

procedure TMainIDE.SetupOutputFilter;
begin
  TheOutputFilter:=TOutputFilter.Create;
  TheOutputFilter.OnGetIncludePath:=@CodeToolBoss.GetIncludePathForDirectory;
end;

procedure TMainIDE.SetupObjectInspector;
begin
  ObjectInspector1 := TObjectInspector.Create(OwningComponent);
  ObjectInspector1.OnSelectPersistentsInOI:=@OIOnSelectPersistents;
  ObjectInspector1.OnShowOptions:=@OIOnShowOptions;
  ObjectInspector1.OnRemainingKeyUp:=@OIRemainingKeyUp;
  ObjectInspector1.ShowFavouritePage:=true;
  ObjectInspector1.Favourites:=LoadOIFavouriteProperties;
  ObjectInspector1.OnAddToFavourites:=@OIOnAddToFavourites;
  ObjectInspector1.OnRemoveFromFavourites:=@OIOnRemoveFromFavourites;

  GlobalDesignHook:=TPropertyEditorHook.Create;
  GlobalDesignHook.GetPrivateDirectory:=AppendPathDelim(GetPrimaryConfigPath);
  GlobalDesignHook.AddHandlerGetMethods(@OnPropHookGetMethods);
  GlobalDesignHook.AddHandlerMethodExists(@OnPropHookMethodExists);
  GlobalDesignHook.AddHandlerCreateMethod(@OnPropHookCreateMethod);
  GlobalDesignHook.AddHandlerShowMethod(@OnPropHookShowMethod);
  GlobalDesignHook.AddHandlerRenameMethod(@OnPropHookRenameMethod);
  GlobalDesignHook.AddHandlerBeforeAddPersistent(@OnPropHookBeforeAddPersistent);
  GlobalDesignHook.AddHandlerComponentRenamed(@OnPropHookComponentRenamed);
  GlobalDesignHook.AddHandlerPersistentAdded(@OnPropHookPersistentAdded);

  ObjectInspector1.PropertyEditorHook:=GlobalDesignHook;
  EnvironmentOptions.IDEWindowLayoutList.Apply(ObjectInspector1,
                                               DefaultObjectInspectorName);
  with EnvironmentOptions do begin
    ObjectInspectorOptions.AssignTo(ObjectInspector1);
  end;
  
  ShowAnchorDesigner:=@mnuViewAnchorEditorClicked;
end;

procedure TMainIDE.SetupCompilerInterface;
begin
  TheCompiler := TCompiler.Create;
  with TheCompiler do begin
    OnCommandLineCreate:=@OnCmdLineCreate;
    OutputFilter:=TheOutputFilter;
  end;
end;

procedure TMainIDE.SetupFormEditor;
begin
  FormEditor1 := TFormEditor.Create;
  FormEditor1.Obj_Inspector := ObjectInspector1;
end;

procedure TMainIDE.SetupSourceNotebook;
begin
  SourceNotebook := TSourceNotebook.Create(OwningComponent);
  SourceNotebook.OnActivate := @OnSrcNoteBookActivated;
  SourceNotebook.OnAddJumpPoint := @OnSrcNoteBookAddJumpPoint;
  SourceNotebook.OnCloseClicked := @OnSrcNotebookFileClose;
  SourceNotebook.OnCtrlMouseUp := @OnSrcNoteBookCtrlMouseUp;
  SourceNotebook.OnCurrentCodeBufferChanged:=@OnSrcNotebookCurCodeBufferChanged;
  SourceNotebook.OnDeleteLastJumpPoint := @OnSrcNotebookDeleteLastJumPoint;
  SourceNotebook.OnEditorVisibleChanged := @OnSrcNotebookEditorVisibleChanged;
  SourceNotebook.OnEditorChanged := @OnSrcNotebookEditorChanged;
  SourceNotebook.OnEditorPropertiesClicked := @mnuEnvEditorOptionsClicked;
  SourceNotebook.OnFindDeclarationClicked := @OnSrcNotebookFindDeclaration;
  SourceNotebook.OnInitIdentCompletion :=@OnSrcNotebookInitIdentCompletion;
  SourceNotebook.OnJumpToHistoryPoint := @OnSrcNotebookJumpToHistoryPoint;
  SourceNotebook.OnMovingPage := @OnSrcNotebookMovingPage;
  SourceNotebook.OnOpenFileAtCursorClicked := @OnSrcNotebookFileOpenAtCursor;
  SourceNotebook.OnProcessUserCommand := @OnProcessIDECommand;
  SourceNotebook.OnReadOnlyChanged := @OnSrcNotebookReadOnlyChanged;
  SourceNotebook.OnShowHintForSource :=@OnSrcNotebookShowHintForSource;
  SourceNotebook.OnShowUnitInfo := @OnSrcNoteBookShowUnitInfo;
  SourceNotebook.OnToggleFormUnitClicked := @OnSrcNotebookToggleFormUnit;
  SourceNotebook.OnToggleObjectInspClicked:= @OnSrcNotebookToggleObjectInsp;
  SourceNotebook.OnViewJumpHistory := @OnSrcNotebookViewJumpHistory;
  SourceNotebook.OnShowSearchResultsView := @OnSrcNotebookShowSearchResultsView;
  SourceNotebook.OnPopupMenu := @OnSrcNoteBookPopupMenu;
  DebugBoss.ConnectSourceNotebookEvents;

  // connect search menu to sourcenotebook
  MainIDEBar.itmSearchFind.OnClick := @SourceNotebook.FindClicked;
  MainIDEBar.itmSearchFindNext.OnClick := @SourceNotebook.FindNextClicked;
  MainIDEBar.itmSearchFindPrevious.OnClick := @SourceNotebook.FindPreviousClicked;
  MainIDEBar.itmSearchFindInFiles.OnClick := @mnuSearchFindInFiles;
  MainIDEBar.itmSearchReplace.OnClick := @SourceNotebook.ReplaceClicked;
  MainIDEBar.itmIncrementalFind.OnClick := @SourceNotebook.IncrementalFindClicked;
  MainIDEBar.itmGotoLine.OnClick := @SourceNotebook.GotoLineClicked;
  MainIDEBar.itmJumpBack.OnClick := @SourceNotebook.JumpBackClicked;
  MainIDEBar.itmJumpForward.OnClick := @SourceNotebook.JumpForwardClicked;
  MainIDEBar.itmAddJumpPoint.OnClick := @SourceNotebook.AddJumpPointClicked;
  MainIDEBar.itmJumpHistory.OnClick := @SourceNotebook.ViewJumpHistoryClicked;
  MainIDEBar.itmFindBlockStart.OnClick:=@mnuSearchFindBlockStart;
  MainIDEBar.itmFindBlockOtherEnd.OnClick:=@mnuSearchFindBlockOtherEnd;
  MainIDEBar.itmFindDeclaration.OnClick:=@mnuSearchFindDeclaration;
  MainIDEBar.itmOpenFileAtCursor.OnClick:=@mnuOpenFileAtCursorClicked;
end;

procedure TMainIDE.SetupTransferMacros;
begin
  MacroList:=TTransferMacroList.Create;
  IDEMacros:=TLazIDEMacros.Create;
  
  MacroList.Add(TTransferMacro.Create('Col','',
                    lisCursorColumnInCurrentEditor,nil,[]));
  MacroList.Add(TTransferMacro.Create('Row','',
                    lisCursorRowInCUrrentEditor,nil,[]));
  MacroList.Add(TTransferMacro.Create('CompPath','',
                    lisCompilerFilename,nil,[]));
  MacroList.Add(TTransferMacro.Create('CurToken','',
                    lisWordAtCursorInCurrentEditor,nil,[]));
  MacroList.Add(TTransferMacro.Create('EdFile','',
                    lisExpandedFilenameOfCurrentEditor,nil,[]));
  MacroList.Add(TTransferMacro.Create('FPCSrcDir','',
                    lisFreePascalSourceDirectory,nil,[]));
  MacroList.Add(TTransferMacro.Create('LazarusDir','',
                    lisLazarusDirectory,nil,[]));
  MacroList.Add(TTransferMacro.Create('LCLWidgetType','',
                    lisLCLWidgetType,nil,[]));
  MacroList.Add(TTransferMacro.Create('TargetCPU','',
                    lisTargetCPU,nil,[]));
  MacroList.Add(TTransferMacro.Create('TargetOS','',
                    lisTargetOS,nil,[]));
  MacroList.Add(TTransferMacro.Create('Params','',
                    lisCommandLineParamsOfProgram,nil,[]));
  MacroList.Add(TTransferMacro.Create('Prompt','',
                    lisPromptForValue,@OnMacroPromptFunction,[tmfInteractive]));
  MacroList.Add(TTransferMacro.Create('ProjFile','',
                    lisProjectFilename,nil,[]));
  MacroList.Add(TTransferMacro.Create('ProjPath','',
                    lisProjectDirectory,nil,[]));
  MacroList.Add(TTransferMacro.Create('Save','',
                    lisSaveCurrentEditorFile,nil,[tmfInteractive]));
  MacroList.Add(TTransferMacro.Create('SaveAll','',
                    lisSaveAllModified,nil,[tmfInteractive]));
  MacroList.Add(TTransferMacro.Create('TargetFile','',
                    lisTargetFilenameOfProject,nil,[]));
  MacroList.Add(TTransferMacro.Create('TargetCmdLine','',
                    lisTargetFilenamePlusParams,nil,[]));
  MacroList.Add(TTransferMacro.Create('TestDir','',
                    lisTestDirectory,nil,[]));
  MacroList.Add(TTransferMacro.Create('RunCmdLine','',
                    lisLaunchingCmdLine,nil,[]));
  MacroList.Add(TTransferMacro.Create('ProjPublishDir','',
                    lisPublishProjDir,nil,[]));
  MacroList.Add(TTransferMacro.Create('ProjUnitPath','',
                    lisProjectUnitPath,nil,[]));
  MacroList.Add(TTransferMacro.Create('ProjIncPath','',
                    lisProjectIncPath,nil,[]));
  MacroList.Add(TTransferMacro.Create('ProjSrcPath','',
                    lisProjectSrcPath,nil,[]));
  MacroList.Add(TTransferMacro.Create('ConfDir','',
                    lisProjectSrcPath,nil,[]));
  MacroList.Add(TTransferMacro.Create('MakeExe','',
                    lisMakeExe,@OnMacroFuncMakeExe,[]));

  MacroList.OnSubstitution:=@OnMacroSubstitution;
  CompilerOptions.OnParseString:=@OnSubstituteCompilerOption;
end;

procedure TMainIDE.SetupControlSelection;
begin
  TheControlSelection:=TControlSelection.Create;
  TheControlSelection.OnChange:=@OnControlSelectionChanged;
  TheControlSelection.OnPropertiesChanged:=@OnControlSelectionPropsChanged;
  TheControlSelection.OnSelectionFormChanged:=@OnControlSelectionFormChanged;
end;

procedure TMainIDE.SetupIDEInterface;
begin
  IDECommands.OnExecuteIDECommand:=@OnExecuteIDECommand;
  IDECommands.OnExecuteIDEShortCut:=@OnExecuteIDEShortCut;
end;

procedure TMainIDE.SetupStartProject;

  function ExtractCmdLineFilenames: TStrings;
  var
    i: LongInt;
    Filename: String;
  begin
    Result:=nil;
    i:=ParamCount;
    while (i>0) do begin
      Filename:=ParamStr(i);
      if (Filename='') or (Filename[1]='-') then break;
      if Result=nil then Result:=TStringList.Create;
      Result.Insert(0,Filename);
      dec(i);
    end;
  end;
  
  function AskIfLoadLastFailingProject: boolean;
  begin
    Result:=MessageDlg('An error occured at last startup while loading '
      +EnvironmentOptions.LastSavedProjectFile+ '!'#13
      +#13
      +'Load this project again?', mtWarning, [mbYes,mbNo],0)=mrYes;
  end;

var
  ProjectLoaded: Boolean;
  AProjectFilename: String;
  CmdLineFiles: TStrings;
  i: Integer;
  OpenFlags: TOpenFlags;
  AFilename: String;
begin
  {$IFDEF IDE_DEBUG}
  writeln('TMainIDE.SetupStartProject A ***********');
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.SetupStartProject A');{$ENDIF}
  // load command line project or last project or create a new project
  CmdLineFiles:=ExtractCmdLineFilenames;
  try
    ProjectLoaded:=false;

    // try command line project
    if (CmdLineFiles<>nil) and (CmdLineFiles.Count>0) then begin
      AProjectFilename:=CmdLineFiles[0];
      if (CompareFileExt(AProjectFilename,'.lpr',false)<>0) then
        AProjectFilename:=ChangeFileExt(AProjectFilename,'.lpi');
      AProjectFilename:=CleanAndExpandFilename(AProjectFilename);
      if FileExists(AProjectFilename) then begin
        CmdLineFiles.Delete(0);
        ProjectLoaded:=(DoOpenProjectFile(AProjectFilename,[])=mrOk);
      end;
    end;

    // try loading last project if lazarus didn't fail last time
    if (not ProjectLoaded)
    and (not SkipAutoLoadingLastProject)
    and (EnvironmentOptions.OpenLastProjectAtStart)
    and (FileExists(EnvironmentOptions.LastSavedProjectFile)) then begin
      if (not IDEProtocolOpts.LastProjectLoadingCrashed)
      or AskIfLoadLastFailingProject then begin
        // protocol that the IDE is trying to load the last project and did not
        // yet succeed
        IDEProtocolOpts.LastProjectLoadingCrashed := True;
        IDEProtocolOpts.Save;
        // try loading the project
        ProjectLoaded:=
          (DoOpenProjectFile(EnvironmentOptions.LastSavedProjectFile,[])=mrOk);
        // protocol that the IDE was able to open the project without crashing
        IDEProtocolOpts.LastProjectLoadingCrashed := false;
        IDEProtocolOpts.Save;
      end;
    end;
    {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.SetupStartProject B');{$ENDIF}

    if not ProjectLoaded then
      // create new project
      DoNewProject(ProjectDescriptorApplication);

    UpdateWindowsMenu;
    
    // load the cmd line files
    if CmdLineFiles<>nil then begin
      for i:=0 to CmdLineFiles.Count-1 do
        Begin
          AFilename:=CleanAndExpandFilename(CmdLineFiles.Strings[i]);
          if CompareFileExt(AFilename,'.lpk',false)=0 then begin
            if PkgBoss.DoOpenPackageFile(AFilename,[pofAddToRecent])=mrAbort
            then
              break;
          end else begin
            OpenFlags:=[ofAddToRecent,ofRegularFile];
            if i<CmdLineFiles.Count then
              Include(OpenFlags,ofMultiOpen);
            if DoOpenEditorFile(AFilename,-1,OpenFlags)=mrAbort then begin
              break;
            end;
          end;
        end;
    end;

    {$IFDEF IDE_DEBUG}
    writeln('TMainIDE.Create B');
    {$ENDIF}
    {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.SetupStartProject C');{$ENDIF}
  finally
    CmdLineFiles.Free;
  end;
end;

procedure TMainIDE.ReOpenIDEWindows;
var
  i: Integer;
  ALayout: TIDEWindowLayout;
  FormEnum: TNonModalIDEWindow;
begin
  for i:=0 to EnvironmentOptions.IDEWindowLayoutList.Count-1 do begin
    ALayout:=EnvironmentOptions.IDEWindowLayoutList[i];
    if not ALayout.Visible then continue;
    FormEnum:=NonModalIDEFormIDToEnum(ALayout.FormID);
    if FormEnum in NonModalIDEWindowManualOpen then continue;
    case FormEnum of
    nmiwUnitDependenciesName:
      DoViewUnitDependencies;
    nmiwProjectInspector:
      DoShowProjectInspector;
    nmiwCodeExplorerName:
      DoShowCodeExplorer;
    nmiwAnchorEditor:
      DoViewAnchorEditor;
    nmiwMessagesViewName:
      DoShowMessagesView;
    nmiwBreakPoints:
      ;//itmViewBreakPoints.OnClick(Self);
    nmiwWatches:
      ;//itmViewWatches.OnClick(Self);
    nmiwLocals:
      ;//itmViewLocals.OnClick(Self);
    nmiwCallStack:
      ;//itmViewCallStack.OnClick(Self);
    end;
  end;
end;

{------------------------------------------------------------------------------}
procedure TMainIDE.SetupMainMenu;
begin
  inherited SetupMainMenu;
  SetupFileMenu;
  SetupEditMenu;
  SetupSearchMenu;
  SetupViewMenu;
  SetupProjectMenu;
  SetupRunMenu;
  SetupComponentsMenu;
  SetupToolsMenu;
  SetupEnvironmentMenu;
  SetupWindowsMenu;
  SetupHelpMenu;
end;

procedure TMainIDE.SetupStandardIDEMenuItems;
begin
  IDEMenuRoots:=TIDEMenuRoots.Create;
  RegisterStandardSourceEditorMenuItems;
  RegisterStandardMessagesViewMenuItems;
  RegisterStandardCodeExplorerMenuItems;
end;

procedure TMainIDE.SetupStandardProjectTypes;
begin
  NewIDEItems.Add(TNewLazIDEItemCategoryFile.Create(FileDescGroupName));
  NewIDEItems.Add(TNewLazIDEItemCategoryProject.Create(ProjDescGroupName));

  // file descriptors
  LazProjectFileDescriptors:=TLazProjectFileDescriptors.Create;
  RegisterProjectFileDescriptor(TFileDescPascalUnit.Create);
  RegisterProjectFileDescriptor(TFileDescPascalUnitWithForm.Create);
  RegisterProjectFileDescriptor(TFileDescPascalUnitWithDataModule.Create);
  RegisterProjectFileDescriptor(TFileDescSimplePascalProgram.Create);
  RegisterProjectFileDescriptor(TFileDescText.Create);

  // project descriptors
  LazProjectDescriptors:=TLazProjectDescriptors.Create;
  RegisterProjectDescriptor(TProjectApplicationDescriptor.Create);
  RegisterProjectDescriptor(TProjectProgramDescriptor.Create);
  RegisterProjectDescriptor(TProjectManualProgramDescriptor.Create);
end;

procedure TMainIDE.SetRecentFilesMenu;
begin
  SetRecentSubMenu(MainIDEBar.itmFileRecentOpen,
                   EnvironmentOptions.RecentOpenFiles,
                   @mnuOpenRecentClicked);
end;

procedure TMainIDE.SetRecentProjectFilesMenu;
begin
  SetRecentSubMenu(MainIDEBar.itmProjectRecentOpen,
                   EnvironmentOptions.RecentProjectFiles,
                   @mnuOpenProjectClicked);
end;

procedure TMainIDE.SetupFileMenu;
begin
  inherited SetupFileMenu;
  with MainIDEBar do begin
    itmFileNewUnit.OnClick := @mnuNewUnitClicked;
    itmFileNewForm.OnClick := @mnuNewFormClicked;
    itmFileNewOther.OnClick := @mnuNewOtherClicked;
    itmFileOpen.OnClick := @mnuOpenClicked;
    itmFileRevert.OnClick := @mnuRevertClicked;
    SetRecentFilesMenu;
    itmFileSave.OnClick := @mnuSaveClicked;
    itmFileSaveAs.OnClick := @mnuSaveAsClicked;
    itmFileSaveAll.OnClick := @mnuSaveAllClicked;
    itmFileClose.Enabled := False;
    itmFileClose.OnClick := @mnuCloseClicked;
    itmFileCloseAll.Enabled := False;
    itmFileCloseAll.OnClick := @mnuCloseAllClicked;
    itmFileCleanDirectory.OnClick := @mnuCleanDirectoryClicked;
    itmFileRestart.OnClick := @mnuRestartClicked;
    itmFileQuit.OnClick := @mnuQuitClicked;
  end;
end;

procedure TMainIDE.SetupEditMenu;
begin
  inherited SetupEditMenu;
  with MainIDEBar do begin
    itmEditUndo.OnClick:=@mnuEditUndoClicked;
    itmEditRedo.OnClick:=@mnuEditRedoClicked;
    itmEditCut.OnClick:=@mnuEditCutClicked;
    itmEditCopy.OnClick:=@mnuEditCopyClicked;
    itmEditPaste.OnClick:=@mnuEditPasteClicked;
    itmEditIndentBlock.OnClick:=@mnuEditIndentBlockClicked;
    itmEditUnindentBlock.OnClick:=@mnuEditUnindentBlockClicked;
    itmEditEncloseBlock.OnClick:=@mnuEditEncloseBlockClicked;
    itmEditUpperCaseBlock.OnClick:=@mnuEditUpperCaseBlockClicked;
    itmEditLowerCaseBlock.OnClick:=@mnuEditLowerCaseBlockClicked;
    itmEditTabsToSpacesBlock.OnClick:=@mnuEditTabsToSpacesBlockClicked;
    itmEditCommentBlock.OnClick:=@mnuEditCommentBlockClicked;
    itmEditUncommentBlock.OnClick:=@mnuEditUncommentBlockClicked;
    itmEditConditionalBlock.OnClick:=@mnuEditConditionalBlockClicked;
    itmEditSortBlock.OnClick:=@mnuEditSortBlockClicked;
    itmEditSelectionBreakLines.OnClick:=@mnuEditSelectionBreakLinesClicked;
    itmEditSelectAll.OnClick:=@mnuEditSelectAllClick;
    itmEditSelectToBrace.OnClick:=@mnuEditSelectToBraceClick;
    itmEditSelectCodeBlock.OnClick:=@mnuEditSelectCodeBlockClick;
    itmEditSelectLine.OnClick:=@mnuEditSelectLineClick;
    itmEditSelectParagraph.OnClick:=@mnuEditSelectParagraphClick;
    itmEditCompleteCode.OnClick:=@mnuEditCompleteCodeClicked;
    itmEditExtractProc.OnClick:=@mnuEditExtractProcClicked;
    itmEditInsertCharacter.OnClick:=@mnuEditInsertCharacterClicked;

    // insert text->CVS keyword
    itmEditInsertCVSAuthor.OnClick:=@mnuEditInsertCVSAuthorClick;
    itmEditInsertCVSDate.OnClick:=@mnuEditInsertCVSDateClick;
    itmEditInsertCVSHeader.OnClick:=@mnuEditInsertCVSHeaderClick;
    itmEditInsertCVSID.OnClick:=@mnuEditInsertCVSIDClick;
    itmEditInsertCVSLog.OnClick:=@mnuEditInsertCVSLogClick;
    itmEditInsertCVSName.OnClick:=@mnuEditInsertCVSNameClick;
    itmEditInsertCVSRevision.OnClick:=@mnuEditInsertCVSRevisionClick;
    itmEditInsertCVSSource.OnClick:=@mnuEditInsertCVSSourceClick;

    // insert text->general
    itmEditInsertGPLNotice.OnClick:=@mnuEditInsertGPLNoticeClick;
    itmEditInsertLGPLNotice.OnClick:=@mnuEditInsertLGPLNoticeClick;
    itmEditInsertUsername.OnClick:=@mnuEditInsertUsernameClick;
    itmEditInsertDateTime.OnClick:=@mnuEditInsertDateTimeClick;
    itmEditInsertChangeLogEntry.OnClick:=@mnuEditInsertChangeLogEntryClick;
  end;
end;

procedure TMainIDE.SetupSearchMenu;
begin
  inherited SetupSearchMenu;
  with MainIDEBar do begin
    itmSearchFindIdentifierRefs.OnClick:=@mnuSearchFindIdentifierRefsClicked;
    itmSearchRenameIdentifier.OnClick:=@mnuSearchRenameIdentifierClicked;
    itmGotoIncludeDirective.OnClick:=@mnuGotoIncludeDirectiveClicked;
  end;
end;

procedure TMainIDE.SetupViewMenu;
begin
  inherited SetupViewMenu;
  with MainIDEBar do begin
    itmViewInspector.OnClick := @mnuViewInspectorClicked;
    itmViewSourceEditor.OnClick := @mnuViewSourceEditorClicked;
    itmViewCodeExplorer.OnClick := @mnuViewCodeExplorerClick;
    itmViewUnits.OnClick := @mnuViewUnitsClicked;
    itmViewForms.OnClick := @mnuViewFormsClicked;
    itmViewUnitDependencies.OnClick := @mnuViewUnitDependenciesClicked;
    itmViewUnitInfo.OnClick := @mnuViewUnitInfoClicked;
    itmViewToggleFormUnit.OnClick := @mnuToggleFormUnitClicked;
    itmViewMessage.OnClick := @mnuViewMessagesClick;
    itmViewSearchResults.OnClick := @mnuViewSearchResultsClick;
    itmViewAnchorEditor.OnClick := @mnuViewAnchorEditorClicked;
  end;
end;

procedure TMainIDE.SetupProjectMenu;
begin
  inherited SetupProjectMenu;
  with MainIDEBar do begin
    itmProjectNew.OnClick := @mnuNewProjectClicked;
    itmProjectNewFromFile.OnClick := @mnuNewProjectFromFileClicked;
    itmProjectOpen.OnClick := @mnuOpenProjectClicked;
    SetRecentProjectFilesMenu;
    itmProjectSave.OnClick := @mnuSaveProjectClicked;
    itmProjectSaveAs.OnClick := @mnuSaveProjectAsClicked;
    itmProjectPublish.OnClick := @mnuPublishProjectClicked;
    itmProjectInspector.OnClick := @mnuProjectInspectorClicked;
    itmProjectOptions.OnClick := @mnuProjectOptionsClicked;
    itmProjectCompilerOptions.OnClick := @mnuProjectCompilerSettingsClicked;
    itmProjectAddTo.OnClick := @mnuAddToProjectClicked;
    itmProjectRemoveFrom.OnClick := @mnuRemoveFromProjectClicked;
    itmProjectViewSource.OnClick := @mnuViewProjectSourceClicked;
    itmProjectViewToDos.OnClick := @mnuViewProjectTodosClicked;
    {$IFDEF TRANSLATESTRING}
    itmProjectCreatePoFiles.OnClick:=@mnuProjectCreatePoFilesClicked;
    itmProjectCollectPoFiles.OnClick:=@mnuProjectCollectPoFilesClicked;
    {$ENDIF}
  end;
end;

procedure TMainIDE.SetupRunMenu;
begin
  inherited SetupRunMenu;
  with MainIDEBar do begin
    itmRunMenuBuild.OnClick := @mnuBuildProjectClicked;
    itmRunMenuBuildAll.OnClick := @mnuBuildAllProjectClicked;
    itmRunMenuAbortBuild.OnClick := @mnuAbortBuildProjectClicked;
    itmRunMenuRun.OnClick := @mnuRunProjectClicked;
    itmRunMenuPause.Enabled := false;
    itmRunMenuPause.OnClick := @mnuPauseProjectClicked;
    itmRunMenuStepInto.OnClick := @mnuStepIntoProjectClicked;
    itmRunMenuStepOver.OnClick := @mnuStepOverProjectClicked;
    itmRunMenuRunToCursor.OnClick := @mnuRunToCursorProjectClicked;
    itmRunMenuStop.OnClick := @mnuStopProjectClicked;
    itmRunMenuRunParameters.OnClick := @mnuRunParametersClicked;
    itmRunMenuBuildFile.OnClick := @mnuBuildFileClicked;
    itmRunMenuRunFile.OnClick := @mnuRunFileClicked;
    itmRunMenuConfigBuildFile.OnClick := @mnuConfigBuildFileClicked;
  end;
end;

procedure TMainIDE.SetupComponentsMenu;
begin
  inherited SetupComponentsMenu;
end;

procedure TMainIDE.SetupToolsMenu;
begin
  inherited SetupToolsMenu;
  with MainIDEBar do begin
    itmToolConfigure.OnClick := @mnuToolConfigureClicked;
    itmToolSyntaxCheck.OnClick := @mnuToolSyntaxCheckClicked;
    itmToolGuessUnclosedBlock.OnClick := @mnuToolGuessUnclosedBlockClicked;
    itmToolGuessMisplacedIFDEF.OnClick := @mnuToolGuessMisplacedIFDEFClicked;
    itmToolMakeResourceString.OnClick := @mnuToolMakeResourceStringClicked;
    itmToolDiff.OnClick := @mnuToolDiffClicked;
    itmToolConvertDFMtoLFM.OnClick := @mnuToolConvertDFMtoLFMClicked;
    itmToolConvertDelphiUnit.OnClick := @mnuToolConvertDelphiUnitClicked;
    itmToolConvertDelphiProject.OnClick := @mnuToolConvertDelphiProjectClicked;
    itmToolBuildLazarus.OnClick := @mnuToolBuildLazarusClicked;
    itmToolConfigureBuildLazarus.OnClick := @mnuToolConfigBuildLazClicked;
  end;
  CustomExtToolMenuSeparator:=nil;
  UpdateCustomToolsInMenu;
end;

procedure TMainIDE.SetupEnvironmentMenu;
begin
  inherited SetupEnvironmentMenu;
  with MainIDEBar do begin
    itmEnvGeneralOptions.OnClick := @mnuEnvGeneralOptionsClicked;
    itmEnvEditorOptions.OnClick := @mnuEnvEditorOptionsClicked;
    itmEnvCodeToolsOptions.OnClick := @mnuEnvCodeToolsOptionsClicked;
    itmEnvCodeToolsDefinesEditor.OnClick := @mnuEnvCodeToolsDefinesEditorClicked;
    itmEnvRescanFPCSrcDir.OnClick := @mnuEnvRescanFPCSrcDirClicked;
  end;
end;

procedure TMainIDE.SetupWindowsMenu;
begin
  inherited SetupWindowsMenu;
end;

procedure TMainIDE.SetupHelpMenu;
begin
  inherited SetupHelpMenu;
end;

procedure TMainIDE.LoadMenuShortCuts;
begin
  inherited LoadMenuShortCuts;
  DebugBoss.SetupMainBarShortCuts;
end;

procedure TMainIDE.ConnectMainBarEvents;
begin
  MainIDEBar.OnClose := @MainIDEFormClose;
  MainIDEBar.OnCloseQuery := @MainIDEFormCloseQuery;
end;

{------------------------------------------------------------------------------}

procedure TMainIDE.mnuToggleFormUnitClicked(Sender: TObject);
begin
  DoBringToFrontFormOrUnit;
end;

procedure TMainIDE.mnuViewAnchorEditorClicked(Sender: TObject);
begin
  DoViewAnchorEditor;
end;

Procedure TMainIDE.SetDesigning(AComponent: TComponent; Value: Boolean);
Begin
  AComponent.SetDesigning(Value);
  if Value then InterfaceObject.SetDesigning(AComponent);
end;

{------------------------------------------------------------------------------}
procedure TMainIDE.mnuFindDeclarationClicked(Sender: TObject);
begin
  if SourceNoteBook.NoteBook=nil then exit;
  DoFindDeclarationAtCursor;
end;

procedure TMainIDE.mnuNewUnitClicked(Sender: TObject);
begin
  DoNewEditorFile(FileDescriptorUnit,'','',[nfOpenInEditor,nfCreateDefaultSrc]);
end;

procedure TMainIDE.mnuNewFormClicked(Sender: TObject);
begin
  DoNewEditorFile(FileDescriptorForm,'','',[nfOpenInEditor,nfCreateDefaultSrc]);
end;

procedure TMainIDE.mnuNewOtherClicked(Sender: TObject);
begin
  DoNewOther;
end;

procedure TMainIDE.mnuOpenClicked(Sender: TObject);

  procedure UpdateEnvironment;
  begin
    SetRecentFilesMenu;
    SaveEnvironment;
  end;

var
  OpenDialog: TOpenDialog;
  AFilename: string;
  I: Integer;
  OpenFlags: TOpenFlags;
begin
  OpenDialog:=TOpenDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(OpenDialog);
    OpenDialog.Title:=lisOpenFile;
    OpenDialog.Options:=OpenDialog.Options+[ofAllowMultiSelect];
    OpenDialog.Filter:=dlgAllFiles+' ('+GetAllFilesMask+')|'+GetAllFilesMask
                 +'|'+lisLazarusUnit+' (*.pas;*.pp)|*.pas;*.pp'
                 +'|'+lisLazarusProject+' (*.lpi)|*.lpi'
                 +'|'+lisLazarusForm+' (*.lfm)|*.lfm'
                 +'|'+lisLazarusPackage+' (*.lpk)|*.lpk'
                 +'|'+lisLazarusProjectSource+' (*.lpr)|*.lpr';
    if OpenDialog.Execute and (OpenDialog.Files.Count>0) then begin
      OpenFlags:=[ofAddToRecent];
      //debugln('TMainIDE.mnuOpenClicked OpenDialog.Files.Count=',dbgs(OpenDialog.Files.Count));
      if OpenDialog.Files.Count>1 then
        Include(OpenFlags,ofRegularFile);
      For I := 0 to OpenDialog.Files.Count-1 do
        Begin
          AFilename:=CleanAndExpandFilename(OpenDialog.Files.Strings[i]);
          if i<OpenDialog.Files.Count then
            Include(OpenFlags,ofMultiOpen)
          else
            Exclude(OpenFlags,ofMultiOpen);
          if DoOpenEditorFile(AFilename,-1,OpenFlags)=mrAbort then begin
            break;
          end;
        end;
      UpdateEnvironment;
    end;
    InputHistories.StoreFileDialogSettings(OpenDialog);
  finally
    OpenDialog.Free;
  end;
end;

procedure TMainIDE.mnuOpenRecentClicked(Sender: TObject);

  procedure UpdateEnvironment;
  begin
    SetRecentFilesMenu;
    SaveEnvironment;
  end;

var
  AFilename: string;
begin
  AFileName:=ExpandFilename(TMenuItem(Sender).Caption);
  if DoOpenEditorFile(AFilename,-1,[ofAddToRecent])=mrOk then begin
    UpdateEnvironment;
  end else begin
    // open failed
    if not FileExists(AFilename) then begin
      // file does not exist -> delete it from recent file list
      EnvironmentOptions.RemoveFromRecentOpenFiles(AFilename);
      UpdateEnvironment;
    end;
  end;
end;

procedure TMainIDE.mnuRevertClicked(Sender: TObject);
begin
  if SourceNoteBook.NoteBook=nil then exit;
  DoOpenEditorFile('',SourceNoteBook.NoteBook.PageIndex,[ofRevert]);
end;

procedure TMainIDE.mnuOpenFileAtCursorClicked(Sender: TObject);
begin
  if SourceNoteBook.NoteBook=nil then exit;
  DoOpenFileAtCursor(Sender);
end;

procedure TMainIDE.mnuGotoIncludeDirectiveClicked(Sender: TObject);
begin
  DoGotoIncludeDirective;
end;

procedure TMainIDE.mnuSaveClicked(Sender: TObject);
begin
  if SourceNoteBook.NoteBook=nil then exit;
  DoSaveEditorFile(SourceNoteBook.NoteBook.PageIndex,[sfCheckAmbiguousFiles]);
end;

procedure TMainIDE.mnuSaveAsClicked(Sender: TObject);
begin
  if SourceNoteBook.NoteBook=nil then exit;
  DoSaveEditorFile(SourceNoteBook.NoteBook.PageIndex,
                   [sfSaveAs,sfCheckAmbiguousFiles]);
end;

procedure TMainIDE.mnuSaveAllClicked(Sender: TObject);
begin
  DoSaveAll([sfCheckAmbiguousFiles]);
end;

procedure TMainIDE.mnuCloseClicked(Sender: TObject);
var PageIndex: integer;
begin
  if SourceNoteBook.NoteBook=nil then exit;
  if Sender is TPage then begin
    PageIndex:=SourceNoteBook.NoteBook.Pages.IndexOfObject(Sender);
    if PageIndex<0 then
      PageIndex:=SourceNoteBook.NoteBook.PageIndex;
  end else begin
    PageIndex:=SourceNoteBook.NoteBook.PageIndex;
  end;
  DoCloseEditorFile(PageIndex,[cfSaveFirst]);
end;

procedure TMainIDE.mnuCloseAllClicked(Sender: TObject);
begin
  DoSaveAll([]);
  while (SourceNoteBook.NoteBook<>nil)
  and (DoCloseEditorFile(SourceNoteBook.NoteBook.PageIndex,
       [cfSaveFirst])=mrOk) do ;
end;

procedure TMainIDE.mnuCleanDirectoryClicked(Sender: TObject);
begin
  ShowCleanDirectoryDialog(Project1.ProjectDirectory,MacroList);
end;

Procedure TMainIDE.OnSrcNotebookFileNew(Sender: TObject);
begin
  mnuNewFormClicked(Sender);
end;

Procedure TMainIDE.OnSrcNotebookFileClose(Sender: TObject);
begin
  mnuCloseClicked(Sender);
end;

Procedure TMainIDE.OnSrcNotebookFileOpen(Sender: TObject);
begin
  mnuOpenClicked(Sender);
end;

Procedure TMainIDE.OnSrcNoteBookFileOpenAtCursor(Sender: TObject);
begin
  mnuOpenFileAtCursorClicked(Sender);
end;

Procedure TMainIDE.OnSrcNotebookFileSave(Sender: TObject);
begin
  mnuSaveClicked(Sender);
end;

Procedure TMainIDE.OnSrcNotebookFileSaveAs(Sender: TObject);
begin
  mnuSaveAsClicked(Sender);
end;

Procedure TMainIDE.OnSrcNoteBookFindDeclaration(Sender: TObject);
begin
  mnuFindDeclarationClicked(Sender);
end;

procedure TMainIDE.OnSrcNotebookInitIdentCompletion(Sender: TObject;
  var Handled, Abort: boolean);
begin
  Handled:=true;
  Abort:=not DoInitIdentCompletion;
end;

Procedure TMainIDE.OnSrcNotebookSaveAll(Sender: TObject);
begin
  mnuSaveAllClicked(Sender);
end;

procedure TMainIDE.OnSrcNotebookToggleFormUnit(Sender: TObject);
begin
  mnuToggleFormUnitClicked(Sender);
end;

procedure TMainIDE.OnSrcNotebookToggleObjectInsp(Sender: TObject);
begin
  mnuViewInspectorClicked(Sender);
end;

procedure TMainIDE.OnProcessIDECommand(Sender: TObject;
  Command: word;  var Handled: boolean);
var
  ASrcEdit: TSourceEditor;
  AnUnitInfo: TUnitInfo;
begin
  //debugln('TMainIDE.OnProcessIDECommand ',dbgs(Command));

  Handled:=true;

  case Command of
  
  ecContextHelp:
    if Sender=MessagesView then
      HelpBoss.ShowHelpForMessage(-1);

  ecSave:
    if (Sender is TDesigner) then begin
      GetDesignerUnit(TDesigner(Sender),ASrcEdit,AnUnitInfo);
      if (AnUnitInfo<>nil) and (AnUnitInfo.EditorIndex>=0) then
        DoSaveEditorFile(AnUnitInfo.EditorIndex,[sfCheckAmbiguousFiles]);
    end else if (Sender is TObjectInspector) then begin
      GetObjectInspectorUnit(ASrcEdit,AnUnitInfo);
      if (AnUnitInfo<>nil) and (AnUnitInfo.EditorIndex>=0) then
        DoSaveEditorFile(AnUnitInfo.EditorIndex,[sfCheckAmbiguousFiles]);
    end else if Sender is TSourceNotebook then
      mnuSaveClicked(Self);

  ecOpen:
    mnuOpenClicked(Self);

  ecSaveAll:
    DoSaveAll([sfCheckAmbiguousFiles]);
    
  ecQuit:
    mnuQuitClicked(Self);

  ecBuild:
    begin
      GetCurrentUnit(ASrcEdit,AnUnitInfo);
      if (AnUnitInfo<>nil)
      and AnUnitInfo.BuildFileIfActive then
        DoBuildFile
      else
        DoBuildProject(crCompile);
    end;

  ecBuildAll:    DoBuildProject(crBuild);
  ecAbortBuild:  DoAbortBuild;

  ecRun:
    begin
      GetCurrentUnit(ASrcEdit,AnUnitInfo);
      if (AnUnitInfo<>nil)
      and AnUnitInfo.RunFileIfActive then
        DoRunFile
      else
        DoRunProject;
    end;

  ecJumpToPrevError:
    DoJumpToNextError(true);

  ecJumpToNextError:
    DoJumpToNextError(false);
    
  ecFindInFiles:
    DoFindInFiles;

  ecFindProcedureDefinition,
  ecFindProcedureMethod:
    DoJumpToProcedureSection;

  ecFindDeclaration:
    DoFindDeclarationAtCursor;

  ecFindIdentifierRefs:
    DoFindRenameIdentifier(false);

  ecRenameIdentifier:
    DoFindRenameIdentifier(true);

  ecFindBlockOtherEnd:
    DoGoToPascalBlockOtherEnd;

  ecFindBlockStart:
    DoGoToPascalBlockStart;
    
  ecGotoIncludeDirective:
    DoGotoIncludeDirective;

  ecCompleteCode:
    DoCompleteCodeAtCursor;

  ecExtractProc:
    DoExtractProcFromSelection;

  ecToggleMessages:
    DoShowMessagesView;
    
  ecToggleCodeExpl:
    DoShowCodeExplorer;

  ecViewUnits:
    DoViewUnitsAndForms(false);

  ecViewForms:
    DoViewUnitsAndForms(true);

  ecConfigCustomComps:
    PkgBoss.ShowConfigureCustomComponents;

  ecExtToolFirst..ecExtToolLast:
    DoRunExternalTool(Command-ecExtToolFirst);

  ecSyntaxCheck:
    DoCheckSyntax;

  ecGuessUnclosedBlock:
    DoJumpToGuessedUnclosedBlock(true);

  ecGuessMisplacedIFDEF:
    DoJumpToGuessedMisplacedIFDEF(true);

  ecMakeResourceString:
    DoMakeResourceString;

  ecDiff:
    DoDiff;

  ecConvertDFM2LFM:
    DoConvertDFMtoLFM;

  ecBuildLazarus:
    DoBuildLazarus([]);

  ecConfigBuildLazarus:
    mnuToolConfigBuildLazClicked(Self);

  ecToggleFormUnit:
    mnuToggleFormUnitClicked(Self);

  ecToggleObjectInsp:
    mnuViewInspectorClicked(Self);

  ecAboutLazarus:
    MainIDEBar.itmHelpAboutLazarus.Click;
    
  ecAddBreakPoint:
    SourceNotebook.AddBreakpointClicked(Self);

  ecRemoveBreakPoint:
    SourceNotebook.DeleteBreakpointClicked(Self);

  else
    Handled:=false;
    DebugBoss.ProcessCommand(Command,Handled);
    if Handled then exit;
    PkgBoss.ProcessCommand(Command,Handled);
  end;
end;

procedure TMainIDE.OnExecuteIDECommand(Sender: TObject; Command: word);
var
  Handled: Boolean;
begin
  Handled:=false;
  OnProcessIDECommand(Sender,Command,Handled);
end;

procedure TMainIDE.OnExecuteIDEShortCut(Sender: TObject; var Key: word;
  Shift: TShiftState; Areas: TCommandAreas);
var
//  CommandRelation: TKeyCommandRelation;
//  Handled: Boolean;
  Command: Word;
  Handled: Boolean;
begin
//  CommandRelation:=EditorOpts.KeyMap.Find(Key,Shift,Areas);
//  if (CommandRelation=nil) or (CommandRelation.Command=ecNone) then exit;
//  Handled:=false;
//  OnProcessIDECommand(Sender,CommandRelation.Command,Handled);
//  if Handled then Key:=VK_UNKNOWN;
  //debugln('TMainIDE.OnExecuteIDEShortCut Key '+dbgs(Key)+' pressed');
  Command := EditorOpts.KeyMap.TranslateKey(Key,Shift,Areas);
  if (Command = ecNone) then exit;
  Handled := false;
  OnProcessIDECommand(Sender, Command, Handled);
  if Handled then
    Key := VK_UNKNOWN;
end;

procedure TMainIDE.OnSrcNoteBookCtrlMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftstate; X, Y: Integer);
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
begin
  GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
  if ActiveSrcEdit=nil then exit;
  DoFindDeclarationAtCaret(
    ActiveSrcEdit.EditorComponent.PixelsToRowColumn(Point(X,Y)));
end;

procedure TMainIDE.OnSrcNoteBookShowUnitInfo(Sender: TObject);
begin
  DoViewUnitInfo;
end;

{------------------------------------------------------------------------------}

Procedure TMainIDE.OpenFileDownArrowClicked(Sender: TObject);
var
  CurIndex: integer;
  PopupPos: TPoint;
  OpenMenuItem: TPopupMenu;

  procedure AddFile(const Filename: string);
  var
    AMenuItem: TMenuItem;
  begin
    if MainIDEBar.OpenFilePopupMenu.Items.Count>CurIndex then
      AMenuItem:=MainIDEBar.OpenFilePopupMenu.Items[CurIndex]
    else begin
      AMenuItem:=TMenuItem.Create(OwningComponent);
      AMenuItem.Name:=MainIDEBar.OpenFilePopupMenu.Name+'Recent'+IntToStr(CurIndex);
      AMenuItem.OnClick:=@mnuOpenFilePopupClick;
      MainIDEBar.OpenFilePopupMenu.Items.Add(AMenuItem);
    end;
    AMenuItem.Caption:=Filename;
    inc(CurIndex);
  end;

  procedure AddFiles(List: TStringList; MaxCount: integer);
  var i: integer;
  begin
    i:=0;
    while (i<List.Count) and (i<MaxCount) do begin
      AddFile(List[i]);
      inc(i);
    end;
  end;

Begin
  // fill the PopupMenu:
  CurIndex:=0;
  // first add 8 recent projects
  AddFiles(EnvironmentOptions.RecentProjectFiles,8);
  // add a separator
  AddFile('-');
  // add 12 recent files
  AddFiles(EnvironmentOptions.RecentOpenFiles,12);
  OpenMenuItem:=MainIDEBar.OpenFilePopupMenu;
  // remove unused menuitems
  while OpenMenuItem.Items.Count>CurIndex do
    OpenMenuItem.Items[OpenMenuItem.Items.Count-1].Free;
  // calculate screen position to show menu
  PopupPos := MainIDEBar.OpenFileSpeedBtn.ClientToScreen(
                                  Point(0, MainIDEBar.OpenFileSpeedBtn.Height));
  // display the PopupMenu
  if OpenMenuItem.Items.Count > 0 then
    OpenMenuItem.Popup(PopupPos.X, PopupPos.Y);
end;

procedure TMainIDE.mnuOpenFilePopupClick(Sender: TObject);
var
  TheMenuItem: TMenuItem;
  Index, SeparatorIndex: integer;
  AFilename: string;
begin
  TheMenuItem:=TMenuItem(Sender);
  if TheMenuItem.Caption='-' then exit;
  Index:=TheMenuItem.MenuIndex;
  SeparatorIndex:=0;
  while SeparatorIndex<MainIDEBar.OpenFilePopupMenu.Items.Count do begin
    if MainIDEBar.OpenFilePopupMenu.Items[SeparatorIndex].Caption='-' then
      break;
    inc(SeparatorIndex);
  end;
  if Index=SeparatorIndex then exit;
  if Index<SeparatorIndex then begin
    // open recent project
    AFilename:=EnvironmentOptions.RecentProjectFiles[Index];
    DoOpenProjectFile(AFileName,[ofAddToRecent]);
  end else begin
    // open recent file
    dec(Index, SeparatorIndex+1);
    if DoOpenEditorFile(EnvironmentOptions.RecentOpenFiles[Index],-1,
      [ofAddToRecent])=mrOk then
    begin
      SetRecentFilesMenu;
      SaveEnvironment;
    end;
  end;
end;

Procedure TMainIDE.CreateDesignerForComponent(AComponent: TComponent);
var
  DesignerForm: TCustomForm;
Begin
  {$IFDEF IDE_DEBUG}
  writeln('[TMainIDE.CreateDesignerForComponent] A ',AComponent.Name,':',AComponent.ClassName);
  {$ENDIF}
  // create designer form
  if (AComponent is TCustomForm) then
    DesignerForm:=TCustomForm(AComponent)
  else
    DesignerForm:=FormEditor1.CreateNonControlForm(AComponent);
  // create designer
  DesignerForm.Designer := TDesigner.Create(DesignerForm, TheControlSelection);
  {$IFDEF IDE_DEBUG}
  writeln('[TMainIDE.CreateDesignerForComponent] B');
  {$ENDIF}
  with TDesigner(DesignerForm.Designer) do begin
    TheFormEditor := FormEditor1;
    OnActivated:=@OnDesignerActivated;
    OnCloseQuery:=@OnDesignerCloseQuery;
    OnPersistentAdded:=@OnDesignerPersistentAdded;
    OnPersistentDeleted:=@OnDesignerPersistentDeleted;
    OnGetNonVisualCompIcon:=
           @TComponentPalette(IDEComponentPalette).OnGetNonVisualCompIcon;
    OnGetSelectedComponentClass:=@OnDesignerGetSelectedComponentClass;
    OnModified:=@OnDesignerModified;
    OnPasteComponent:=@OnDesignerPasteComponent;
    OnProcessCommand:=@OnProcessIDECommand;
    OnPropertiesChanged:=@OnDesignerPropertiesChanged;
    OnRemovePersistent:=@OnDesignerRemovePersistent;
    OnRenameComponent:=@OnDesignerRenameComponent;
    OnSetDesigning:=@OnDesignerSetDesigning;
    OnShowOptions:=@OnDesignerShowOptions;
    OnUnselectComponentClass:=@OnDesignerUnselectComponentClass;
    ShowEditorHints:=EnvironmentOptions.ShowEditorHints;
    ShowComponentCaptionHints:=EnvironmentOptions.ShowComponentCaptions;
  end;
  // set component and designer form into design mode (csDesigning)
  SetDesigning(AComponent,True);
  if AComponent<>DesignerForm then
    SetDesigning(DesignerForm,True);
end;

{-------------------------------------------------------------------------------
  procedure TMainIDE.InvalidateAllDesignerForms
  Params: none
  Result: none

  Calls 'Invalidate' in all designer forms.
-------------------------------------------------------------------------------}
procedure TMainIDE.InvalidateAllDesignerForms;
var
  AnUnitInfo: TUnitInfo;
  CurDesignerForm: TCustomForm;
begin
  AnUnitInfo:=Project1.FirstUnitWithComponent;
  while AnUnitInfo<>nil do begin
    if AnUnitInfo.Component<>nil then begin
      CurDesignerForm:=FormEditor1.GetDesignerForm(AnUnitInfo.Component);
      if CurDesignerForm<>nil then
        CurDesignerForm.Invalidate;
    end;
    AnUnitInfo:=AnUnitInfo.NextUnitWithComponent;
  end;
end;

procedure TMainIDE.UpdateIDEComponentPalette;
var
  ShowControlsInComponentalette: Boolean;
begin
  ShowControlsInComponentalette:=(FLastFormActivated=nil)
    or (TDesigner(FLastFormActivated.Designer).LookupRoot is TControl);
  IDEComponentPalette.ShowHideControls(ShowControlsInComponentalette);
end;

procedure TMainIDE.ShowDesignerForm(AForm: TCustomForm);
begin
  // do not call 'AForm.Show', because it will set Visible to true
  AForm.BringToFront;
  LCLIntf.ShowWindow(AForm.Handle,SW_SHOWNORMAL);
end;

procedure TMainIDE.DoViewAnchorEditor;
var
  WasVisible: boolean;
begin
  if AnchorDesigner=nil then begin
    AnchorDesigner:=TAnchorDesigner.Create(OwningComponent);
    WasVisible:=false;
  end else
    WasVisible:=AnchorDesigner.Visible;

  AnchorDesigner.Show;
  if not WasVisible then
    AnchorDesigner.ShowOnTop;
end;

procedure TMainIDE.SetToolStatus(const AValue: TIDEToolStatus);
begin
  inherited SetToolStatus(AValue);
  if DebugBoss<>nil then
    DebugBoss.UpdateButtonsAndMenuItems;
end;

function TMainIDE.DoResetToolStatus(Interactive: boolean): boolean;
begin
  Result:=false;
  case ToolStatus of

  itDebugger:
    begin
      if Interactive
      and (MessageDlg(lisStopDebugging,
          lisStopTheDebugging, mtConfirmation, [mbYes, mbCancel], 0)<>mrYes)
      then exit;
      DebugBoss.DoStopProject;
    end;

  end;
  Result:=true;
end;

procedure TMainIDE.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;


{------------------------------------------------------------------------------}

procedure TMainIDE.mnuRestartClicked(Sender: TObject);
begin
  DoRestart;
end;

procedure TMainIDE.mnuQuitClicked(Sender: TObject);
var CanClose: boolean;
begin
  CanClose:=true;
  MainIDEBar.OnCloseQuery(Sender, CanClose);
  {$IFDEF IDE_DEBUG}
  writeln('TMainIDE.mnuQuitClicked 1');
  {$ENDIF}
  if CanClose then MainIDEBar.Close;
  {$IFDEF IDE_DEBUG}
  writeln('TMainIDE.mnuQuitClicked 2');
  {$ENDIF}
end;

{------------------------------------------------------------------------------}
procedure TMainIDE.mnuViewInspectorClicked(Sender: TObject);
begin
  DoBringToFrontFormOrInspector(true);
end;

procedure TMainIDE.mnuViewSourceEditorClicked(Sender: TObject);
begin
  SourceNotebook.ShowOnTop;
end;

{------------------------------------------------------------------------------}

Procedure TMainIDE.mnuViewUnitsClicked(Sender: TObject);
begin
  DoViewUnitsAndForms(false);
end;

Procedure TMainIDE.mnuViewFormsClicked(Sender: TObject);
Begin
  DoViewUnitsAndForms(true);
end;

Procedure TMainIDE.mnuViewUnitDependenciesClicked(Sender: TObject);
begin
  DoViewUnitDependencies;
end;

procedure TMainIDE.mnuViewUnitInfoClicked(Sender: TObject);
begin
  DoViewUnitInfo;
end;

Procedure TMainIDE.mnuViewCodeExplorerClick(Sender: TObject);
begin
  DoShowCodeExplorer;
end;

Procedure TMainIDE.mnuViewMessagesClick(Sender: TObject);
Begin
  MessagesView.ShowOnTop;
End;

Procedure TMainIDE.mnuViewSearchResultsClick(Sender: TObject);
Begin
  CreateSearchResultWindow;
  SearchResultsView.ShowOnTop;
End;



{------------------------------------------------------------------------------}

Procedure TMainIDE.mnuNewProjectClicked(Sender: TObject);
var
  NewProjectDesc: TProjectDescriptor;
Begin
  NewProjectDesc:=nil;
  if ChooseNewProject(NewProjectDesc)<>mrOk then exit;
  debugln('TMainIDE.mnuNewProjectClicked ',dbgsName(NewProjectDesc));
  DoNewProject(NewProjectDesc);
end;

procedure TMainIDE.mnuNewProjectFromFileClicked(Sender: TObject);
var
  OpenDialog:TOpenDialog;
  AFilename: string;
  PreReadBuf: TCodeBuffer;
Begin
  OpenDialog:=TOpenDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(OpenDialog);
    OpenDialog.Title:=lisChooseProgramSourcePpPasLpr;
    OpenDialog.Options:=OpenDialog.Options+[ofPathMustExist,ofFileMustExist];
    if OpenDialog.Execute then begin
      AFilename:=ExpandFilename(OpenDialog.Filename);
      if not FilenameIsPascalSource(AFilename) then begin
        MessageDlg(lisPkgMangInvalidFileExtension,
          lisProgramSourceMustHaveAPascalExtensionLikePasPpOrLp,
          mtError,[mbOk],0);
        exit;
      end;
      if mrOk<>LoadCodeBuffer(PreReadBuf,AFileName,
                              [lbfCheckIfText,lbfUpdateFromDisk,lbfRevert])
      then
        exit;
      if DoCreateProjectForProgram(PreReadBuf)=mrOk then begin
        exit;
      end;
    end;
  finally
    InputHistories.StoreFileDialogSettings(OpenDialog);
    OpenDialog.Free;
  end;
end;

Procedure TMainIDE.mnuOpenProjectClicked(Sender: TObject);
var
  OpenDialog:TOpenDialog;
  AFileName: string;
begin
  if Sender=MainIDEBar.itmProjectOpen then begin
    OpenDialog:=TOpenDialog.Create(nil);
    try
      InputHistories.ApplyFileDialogSettings(OpenDialog);
      OpenDialog.Title:=lisOpenProjectFile+' (*.lpi)';
      OpenDialog.Filter := lisLazarusProjectInfoFile+' (*.lpi)|*.lpi|'
                          +lisAllFiles+'|'+GetAllFilesMask;
      if OpenDialog.Execute then begin
        AFilename:=ExpandFilename(OpenDialog.Filename);
        DoOpenProjectFile(AFilename,[ofAddToRecent]);
      end;
      InputHistories.StoreFileDialogSettings(OpenDialog);
    finally
      OpenDialog.Free;
    end;
  end else if Sender is TMenuItem then begin
    AFileName:=ExpandFilename(TMenuItem(Sender).Caption);
    if DoOpenProjectFile(AFilename,[ofAddToRecent])=mrOk then begin
      AddRecentProjectFileToEnvironment(AFilename);
    end else begin
      // open failed
      if not FileExists(AFilename) then begin
        EnvironmentOptions.RemoveFromRecentProjectFiles(AFilename);
      end else
        AddRecentProjectFileToEnvironment(AFilename);
    end;
  end;
end;

Procedure TMainIDE.mnuSaveProjectClicked(Sender: TObject);
Begin
  DoSaveProject([]);
end;

procedure TMainIDE.mnuSaveProjectAsClicked(Sender: TObject);
begin
  DoSaveProject([sfSaveAs]);
end;

procedure TMainIDE.mnuPublishProjectClicked(Sender: TObject);
begin
  DoPublishProject([],true);
end;

procedure TMainIDE.mnuProjectInspectorClicked(Sender: TObject);
begin
  DoShowProjectInspector;
end;

procedure TMainIDE.mnuAddToProjectClicked(Sender: TObject);
begin
  DoAddActiveUnitToProject;
end;

procedure TMainIDE.mnuRemoveFromProjectClicked(Sender: TObject);
begin
  DoRemoveFromProjectDialog;
end;

procedure TMainIDE.mnuViewProjectSourceClicked(Sender: TObject);
begin
  DoOpenMainUnit(false);
end;

procedure TMainIDE.mnuViewProjectTodosClicked(Sender: TObject);
begin
  DoShowToDoList;
end;

procedure TMainIDE.mnuProjectOptionsClicked(Sender: TObject);
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
begin
  BeginCodeTool(ActiveSrcEdit, ActiveUnitInfo, []);
  if ShowProjectOptionsDialog(Project1)=mrOk then begin

  end;
end;

{$IFDEF TRANSLATESTRING}
procedure TMainIDE.mnuProjectCreatePoFilesClicked(Sender: TObject);
var
  i: Integer;
begin
  //Ensure the project is saved
  if DoSaveAll([sfCheckAmbiguousFiles])<>mrOk then exit;
  //Ensure the project is compiled, so all rst files are present
  if DoBuildProject(crBuild)<>mrOk then exit;
  for i:=0 to Project1.FileCount-1 do
  begin
    if FileExists(ChangeFileExt(Project1.Files[i].Filename,'.lrt'))
     or FileExists(ChangeFileExt(Project1.Files[i].Filename,'.rst')) then
      Lrt2Po(ChangeFileExt(Project1.Files[i].Filename,'.lrt'),postStandard);
      //TODO: Style must be in options
  end;
end;

procedure TMainIDE.mnuProjectCollectPoFilesClicked(Sender: TObject);
var
  SL: TStringList;
  LNG: String;
  ext: String;
  i: Integer;
begin
  if DoSaveAll([sfCheckAmbiguousFiles])<>mrOk then exit;
  LNG:=InputBox(lisEnterTransla, lisLeaveEmptyFo, '');
  SL:=TStringList.Create;
  if LNG='' then ext:='.po' else ext:='.'+LNG+'.po';
  for i:=0 to Project1.FileCount-1 do
  begin
    if not Project1.Files[i].IsPartOfProject then continue;
    if ChangeFileExt(Project1.Files[i].Filename,'.po')=ChangeFileExt(Project1.MainFilename,'.po')
      then continue;
    if FileExists(ChangeFileExt(Project1.Files[i].Filename,ext)) then
    SL.Add(ChangeFileExt(Project1.Files[i].Filename,ext));
  end;
  try//If I haven't made mistake, this try is not needed
    CombinePoFiles(SL,ChangeFileExt(Project1.MainFilename,ext));
  finally
    SL.Free;
  end;
end;
{$ENDIF}

Procedure TMainIDE.mnuBuildProjectClicked(Sender: TObject);
Begin
  DoBuildProject(crCompile);
end;

Procedure TMainIDE.mnuBuildAllProjectClicked(Sender: TObject);
Begin
  DoBuildProject(crBuild);
end;

Procedure TMainIDE.mnuAbortBuildProjectClicked(Sender: TObject);
Begin
  DoAbortBuild;
end;

Procedure TMainIDE.mnuRunProjectClicked(Sender: TObject);
begin
  DoRunProject;
end;

Procedure TMainIDE.mnuPauseProjectClicked(Sender: TObject);
begin
  DebugBoss.DoPauseProject;
end;

Procedure TMainIDE.mnuStepIntoProjectClicked(Sender: TObject);
begin
  DebugBoss.DoStepIntoProject;
end;

Procedure TMainIDE.mnuStepOverProjectClicked(Sender: TObject);
begin
  DebugBoss.DoStepOverProject;
end;

Procedure TMainIDE.mnuRunToCursorProjectClicked(Sender: TObject);
begin
  DebugBoss.DoRunToCursor;
end;

Procedure TMainIDE.mnuStopProjectClicked(Sender: TObject);
begin
  DebugBoss.DoStopProject;
end;

procedure TMainIDE.mnuProjectCompilerSettingsClicked(Sender: TObject);
var
  frmCompilerOptions: TfrmCompilerOptions;
  NewCaption: String;
begin
  frmCompilerOptions:=TfrmCompilerOptions.Create(nil);
  try
    NewCaption:=Project1.Title;
    if NewCaption='' then
      NewCaption:=ExtractFilenameOnly(Project1.ProjectInfoFile);
    frmCompilerOptions.Caption:=Format(lisCompilerOptionsForProject, [NewCaption
      ]);
    frmCompilerOptions.CompilerOpts:=Project1.CompilerOptions;
    frmCompilerOptions.GetCompilerOptions;
    frmCompilerOptions.OnTest:=@OnCompilerOptionsDialogTest;
    frmCompilerOptions.OnImExportCompilerOptions:=@OnCompilerOptionsImExport;
    if frmCompilerOptions.ShowModal=mrOk then begin
      RescanCompilerDefines(true);
      Project1.DefineTemplates.AllChanged;
    end;
  finally
    frmCompilerOptions.Free;
  end;
end;

procedure TMainIDE.mnuBuildFileClicked(Sender: TObject);
begin
  DoBuildFile;
end;

procedure TMainIDE.mnuRunFileClicked(Sender: TObject);
begin
  DoRunFile;
end;

procedure TMainIDE.mnuConfigBuildFileClicked(Sender: TObject);
begin
  DoConfigBuildFile;
end;

procedure TMainIDE.mnuRunParametersClicked(Sender: TObject);
begin
  ShowRunParamsOptsDlg(Project1.RunParameterOptions);
end;

//------------------------------------------------------------------------------

procedure TMainIDE.mnuToolConfigureClicked(Sender: TObject);
begin
  if ShowExtToolDialog(EnvironmentOptions.ExternalTools,MacroList)=mrOk then
  begin
    // save to enviroment options
    SaveDesktopSettings(EnvironmentOptions);
    EnvironmentOptions.Save(false);
    // save shortcuts to editor options
    EnvironmentOptions.ExternalTools.SaveShortCuts(EditorOpts.KeyMap);
    EditorOpts.Save;
    SourceNotebook.ReloadEditorOptions;
    UpdateCustomToolsInMenu;
  end;
end;

procedure TMainIDE.mnuToolSyntaxCheckClicked(Sender: TObject);
begin
  DoCheckSyntax;
end;

procedure TMainIDE.mnuToolGuessUnclosedBlockClicked(Sender: TObject);
begin
  DoJumpToGuessedUnclosedBlock(true);
end;

procedure TMainIDE.mnuToolGuessMisplacedIFDEFClicked(Sender: TObject);
begin
  DoJumpToGuessedMisplacedIFDEF(true);
end;

procedure TMainIDE.mnuToolMakeResourceStringClicked(Sender: TObject);
begin
  DoMakeResourceString;
end;

procedure TMainIDE.mnuToolDiffClicked(Sender: TObject);
begin
  DoDiff;
end;

procedure TMainIDE.mnuToolConvertDFMtoLFMClicked(Sender: TObject);
begin
  DoConvertDFMtoLFM;
end;

procedure TMainIDE.mnuToolCheckLFMClicked(Sender: TObject);
begin
  DoCheckLFMInEditor;
end;

procedure TMainIDE.mnuToolConvertDelphiUnitClicked(Sender: TObject);

  procedure UpdateEnvironment;
  begin
    SetRecentFilesMenu;
    SaveEnvironment;
  end;

var
  OpenDialog: TOpenDialog;
  AFilename: string;
  i: Integer;
begin
  OpenDialog:=TOpenDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(OpenDialog);
    OpenDialog.Title:=lisChooseDelphiUnit;
    OpenDialog.Options:=OpenDialog.Options+[ofAllowMultiSelect];
    if OpenDialog.Execute and (OpenDialog.Files.Count>0) then begin
      for i := 0 to OpenDialog.Files.Count-1 do begin
        AFilename:=CleanAndExpandFilename(OpenDialog.Files.Strings[i]);
        if FileExists(AFilename)
        and (DoConvertDelphiUnit(AFilename)=mrAbort) then
          break;
      end;
      UpdateEnvironment;
    end;
    InputHistories.StoreFileDialogSettings(OpenDialog);
  finally
    OpenDialog.Free;
  end;
end;

procedure TMainIDE.mnuToolConvertDelphiProjectClicked(Sender: TObject);

  procedure UpdateEnvironment;
  begin
    SetRecentFilesMenu;
    SaveEnvironment;
  end;

var
  OpenDialog: TOpenDialog;
  AFilename: string;
begin
  //MessageDlg('ConvertDelphiProject','Under construction',mtInformation,[mbCancel],0); exit;

  OpenDialog:=TOpenDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(OpenDialog);
    OpenDialog.Title:=lisChooseDelphiProject;
    OpenDialog.Options:=OpenDialog.Options;
    OpenDialog.Filter:=lisDelphiProject+' (*.dpr)|*.dpr|'+dlgAllFiles+' (*.*)|*'
      +'.*';
    if OpenDialog.Execute then begin
      AFilename:=CleanAndExpandFilename(OpenDialog.Filename);
      //debugln('TMainIDE.mnuToolConvertDelphiProjectClicked A ',AFilename);
      if FileExists(AFilename) then
        DoConvertDelphiProject(AFilename);
      UpdateEnvironment;
    end;
    InputHistories.StoreFileDialogSettings(OpenDialog);
  finally
    OpenDialog.Free;
  end;
end;

procedure TMainIDE.mnuToolBuildLazarusClicked(Sender: TObject);
begin
  DoBuildLazarus([]);
end;

procedure TMainIDE.mnuToolConfigBuildLazClicked(Sender: TObject);
var
  CmdLineDefines: TDefineTemplate;
  LazSrcTemplate: TDefineTemplate;
  LazSrcDirTemplate: TDefineTemplate;
begin
  if ShowConfigureBuildLazarusDlg(MiscellaneousOptions.BuildLazOpts)=mrOk then
  begin
    MiscellaneousOptions.Save;
    LazSrcTemplate:=CodeToolBoss.DefineTree.FindDefineTemplateByName(
                                                StdDefTemplLazarusSources,true);
    if LazSrcTemplate<>nil then begin
      LazSrcDirTemplate:=LazSrcTemplate.FindChildByName(
                                                      StdDefTemplLazarusSrcDir);
      if LazSrcDirTemplate<>nil then begin
        CmdLineDefines:=CodeToolBoss.DefinePool.CreateFPCCommandLineDefines(
                                StdDefTemplLazarusBuildOpts,
                                MiscellaneousOptions.BuildLazOpts.ExtraOptions,
                                true,CodeToolsOpts);
        CodeToolBoss.DefineTree.ReplaceChild(LazSrcDirTemplate,CmdLineDefines,
                                             StdDefTemplLazarusBuildOpts);
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  procedure TMainIDE.mnuCustomExtToolClick(Sender: TObject);

  Handler for clicking on a menuitem for a custom external tool.
-------------------------------------------------------------------------------}
procedure TMainIDE.mnuCustomExtToolClick(Sender: TObject);
var
  Index: integer;
begin
  if CustomExtToolMenuSeparator=nil then exit;
  Index:=TMenuItem(Sender).MenuIndex-CustomExtToolMenuSeparator.MenuIndex-1;
  if (Index<0) or (Index>=EnvironmentOptions.ExternalTools.Count) then exit;
  DoRunExternalTool(Index);
end;

procedure TMainIDE.mnuEnvGeneralOptionsClicked(Sender: TObject);
begin
  DoShowEnvGeneralOptions(eodpFiles);
end;

//------------------------------------------------------------------------------

procedure TMainIDE.SaveDesktopSettings(
  TheEnvironmentOptions: TEnvironmentOptions);
begin
  with TheEnvironmentOptions do begin
    IDEWindowLayoutList.StoreWindowPositions;
    ObjectInspectorOptions.Assign(ObjectInspector1);
  end;
end;

procedure TMainIDE.LoadDesktopSettings(
  TheEnvironmentOptions: TEnvironmentOptions);
begin
  with TheEnvironmentOptions do begin
    ObjectInspectorOptions.AssignTo(ObjectInspector1);
  end;
end;

procedure TMainIDE.UpdateDefaultPascalFileExtensions;
var
  DefPasExt: string;
begin
  // change default pascal file extensions
  DefPasExt:=PascalExtension[EnvironmentOptions.PascalFileExtension];
  if LazProjectFileDescriptors<>nil then
    LazProjectFileDescriptors.DefaultPascalFileExt:=DefPasExt;
end;

function TMainIDE.CreateSrcEditPageName(const AnUnitName, AFilename: string;
  IgnorePageIndex: integer): string;
begin
  Result:=AnUnitName;
  if Result='' then
    Result:=AFilename;
  if FilenameIsPascalUnit(Result) then
    Result:=ExtractFileNameOnly(Result)
  else
    Result:=ExtractFileName(Result);
  Result:=SourceNoteBook.FindUniquePageName(Result,IgnorePageIndex);
end;

procedure TMainIDE.OnLoadEnvironmentSettings(Sender: TObject;
  TheEnvironmentOptions: TEnvironmentOptions);
begin
  LoadDesktopSettings(TheEnvironmentOptions);
end;

procedure TMainIDE.OnSaveEnvironmentSettings(Sender: TObject;
  TheEnvironmentOptions: TEnvironmentOptions);
begin
  SaveDesktopSettings(TheEnvironmentOptions);
end;

procedure TMainIDE.DoShowEnvGeneralOptions(StartPage: TEnvOptsDialogPage);
var
  EnvironmentOptionsDialog: TEnvironmentOptionsDialog;
  MacroValueChanged, FPCSrcDirChanged, FPCCompilerChanged: boolean;
  OldCompilerFilename: string;

  procedure ChangeMacroValue(const MacroName, NewValue: string);
  begin
    with CodeToolBoss.GlobalValues do begin
      if Variables[ExternalMacroStart+MacroName]=NewValue then exit;
      FPCSrcDirChanged:=FPCSrcDirChanged or (Macroname='FPCSrcDir');
      Variables[ExternalMacroStart+MacroName]:=NewValue;
    end;
    MacroValueChanged:=true;
  end;

  procedure UpdateDesigners;
  var
    AForm: TCustomForm;
    AnUnitInfo: TUnitInfo;
    ADesigner: TDesigner;
  begin
    AnUnitInfo:=Project1.FirstUnitWithComponent;
    while AnUnitInfo<>nil do begin
      if (AnUnitInfo.Component<>nil)
      then begin
        AForm:=FormEditor1.GetDesignerForm(AnUnitInfo.Component);
        ADesigner:=TDesigner(AForm.Designer);
        if ADesigner<>nil then begin
          ADesigner.ShowEditorHints:=EnvironmentOptions.ShowEditorHints;
          ADesigner.ShowComponentCaptionHints:=
            EnvironmentOptions.ShowComponentCaptions;
        end;
      end;
      AnUnitInfo:=AnUnitInfo.NextUnitWithComponent;
    end;
    InvalidateAllDesignerForms;
  end;

  procedure UpdateObjectInspector;
  begin
    EnvironmentOptions.ObjectInspectorOptions.AssignTo(ObjectInspector1);
  end;

Begin
  EnvironmentOptionsDialog:=TEnvironmentOptionsDialog.Create(nil);
  try
    EnvironmentOptionsDialog.CategoryPage:=StartPage;
    // update EnvironmentOptions (save current window positions)
    SaveDesktopSettings(EnvironmentOptions);
    with EnvironmentOptionsDialog do begin
      OnLoadEnvironmentSettings:=@Self.OnLoadEnvironmentSettings;
      OnSaveEnvironmentSettings:=@Self.OnSaveEnvironmentSettings;
      // load settings from EnvironmentOptions to EnvironmentOptionsDialog
      ReadSettings(EnvironmentOptions);
    end;
    if EnvironmentOptionsDialog.ShowModal=mrOk then begin
      // invalidate cached substituted macros
      IncreaseCompilerParseStamp;

      // load settings from EnvironmentOptionsDialog to EnvironmentOptions
      OldCompilerFilename:=EnvironmentOptions.CompilerFilename;
      EnvironmentOptionsDialog.WriteSettings(EnvironmentOptions);
      UpdateDefaultPascalFileExtensions;

      // set global variables
      UpdateEnglishErrorMsgFilename;
      MacroValueChanged:=false;
      FPCSrcDirChanged:=false;
      FPCCompilerChanged:=
        OldCompilerFilename<>EnvironmentOptions.CompilerFilename;
      ChangeMacroValue('LazarusDir',EnvironmentOptions.LazarusDirectory);
      ChangeMacroValue('FPCSrcDir',EnvironmentOptions.FPCSourceDirectory);

      if MacroValueChanged then CodeToolBoss.DefineTree.ClearCache;
      if FPCCompilerChanged or FPCSrcDirChanged then begin
        RescanCompilerDefines(false);
      end;

      // save to disk
      EnvironmentOptions.Save(false);

      // update environment
      UpdateDesigners;
      UpdateObjectInspector;
      SetupHints;
    end;
  finally
    EnvironmentOptionsDialog.Free;
  end;
End;

procedure TMainIDE.mnuEnvEditorOptionsClicked(Sender: TObject);
var EditorOptionsForm: TEditorOptionsForm;
Begin
  EditorOptionsForm:=TEditorOptionsForm.Create(nil);
  try
    if EditorOptionsForm.ShowModal=mrOk then begin
      SourceNotebook.ReloadEditorOptions;
      LoadMenuShortCuts;
    end;
  finally
    EditorOptionsForm.Free;
  end;
End;

procedure TMainIDE.mnuEnvCodeToolsOptionsClicked(Sender: TObject);
begin
  ShowCodeToolsOptions(CodeToolsOpts,@SourceNoteBook.GetSynEditPreviewSettings);
end;

procedure TMainIDE.mnuEnvCodeToolsDefinesEditorClicked(Sender: TObject);
begin
  ShowCodeToolsDefinesEditor(CodeToolBoss,CodeToolsOpts,MacroList);
end;

procedure TMainIDE.mnuEnvRescanFPCSrcDirClicked(Sender: TObject);
begin
  RescanCompilerDefines(false);
end;

procedure TMainIDE.SaveEnvironment;
begin
  SaveDesktopSettings(EnvironmentOptions);
  EnvironmentOptions.Save(false);
  //debugln('TMainIDE.SaveEnvironment A ',dbgsName(ObjectInspector1.Favourites));
  if (ObjectInspector1<>nil) and (ObjectInspector1.Favourites<>nil) then
    SaveOIFavouriteProperties(ObjectInspector1.Favourites);
end;

//==============================================================================

function TMainIDE.CreateNewCodeBuffer(Descriptor: TProjectFileDescriptor;
  NewOwner: TObject; NewFilename: string;
  var NewCodeBuffer: TCodeBuffer; var NewUnitName: string): TModalResult;
var
  NewShortFilename: String;
  NewFileExt: String;
  SearchFlags: TSearchIDEFileFlags;
begin
  //debugln('TMainIDE.CreateNewCodeBuffer START NewFilename=',NewFilename,' ',Descriptor.DefaultFilename,' ',Descriptor.ClassName);
  NewUnitName:='';
  if NewFilename='' then begin
    // create a new unique filename
    SearchFlags:=[siffCheckAllProjects];
    if Descriptor.IsPascalUnit then begin
      if NewUnitName='' then
        NewUnitName:=Descriptor.DefaultSourceName;
      NewShortFilename:=lowercase(NewUnitName);
      NewFileExt:=Descriptor.DefaultFileExt;
      SearchFlags:=SearchFlags+[siffIgnoreExtension];
    end else begin
      NewFilename:=ExtractFilename(Descriptor.DefaultFilename);
      NewShortFilename:=ExtractFilenameOnly(NewFilename);
      NewFileExt:=ExtractFileExt(NewFilename);
      SearchFlags:=[];
    end;
    NewFilename:=CreateNewUniqueFilename(NewShortFilename,NewFileExt,NewOwner,
                                         SearchFlags,true);
    if NewFilename='' then
      RaiseException('');
    NewShortFilename:=ExtractFilenameOnly(NewFilename);
    // use as unitname the NewShortFilename, but with the case of the
    // original unitname. e.g. 'unit12.pas' becomes 'Unit12.pas'
    NewUnitName:=ChompEndNumber(NewUnitName);
    NewUnitName:=NewUnitName+copy(NewShortFilename,length(NewUnitName)+1,
                                  length(NewShortFilename));
  end;
  //debugln('TMainIDE.CreateNewCodeBuffer NewFilename=',NewFilename,' NewUnitName=',NewUnitName);

  if FilenameIsPascalUnit(NewFilename) then begin
    if NewUnitName='' then
      NewUnitName:=ExtractFileNameOnly(NewFilename);
    if EnvironmentOptions.CharcaseFileAction in [ccfaAsk, ccfaAutoRename] then
      NewFilename:=ExtractFilePath(NewFilename)
                   +lowercase(ExtractFileName(NewFilename));
  end;

  NewCodeBuffer:=CodeToolBoss.CreateFile(NewFilename);
  if NewCodeBuffer<>nil then
    Result:=mrOk
  else
    Result:=mrCancel;
end;

function TMainIDE.CreateNewForm(NewUnitInfo: TUnitInfo;
  AncestorType: TPersistentClass; ResourceCode: TCodeBuffer): TModalResult;
var
  CInterface: TComponentInterface;
  NewComponent: TComponent;
  new_x, new_y: integer;
begin
  if not AncestorType.InheritsFrom(TComponent) then
    RaiseException('TMainIDE.CreateNewForm invalid AncestorType');

  //debugln('TMainIDE.CreateNewForm START ',NewUnitInfo.Filename,' ',AncestorType.ClassName,' ',dbgs(ResourceCode<>nil));
  // create a buffer for the new resource file and for the LFM file
  if ResourceCode=nil then begin
    ResourceCode:=
      CodeToolBoss.CreateFile(ChangeFileExt(NewUnitInfo.Filename,
                              ResourceFileExt));
  end;
  //debugln('TMainIDE.CreateNewForm B ',ResourceCode.Filename);
  ResourceCode.Source:='{ '+lisResourceFileComment+' }';
  CodeToolBoss.CreateFile(ChangeFileExt(NewUnitInfo.Filename,'.lfm'));

  // clear formeditor
  if not Assigned(FormEditor1) then
    FormEditor1 := TFormEditor.Create;
  FormEditor1.ClearSelection;

  // Figure out where we want to put the new form
  // if there is more place left of the OI put it left, otherwise right
  new_x:=ObjectInspector1.Left+ObjectInspector1.Width; //+60;
  new_y:=MainIDEBar.Top+MainIDEBar.Height; //+80;
  if screen.width-new_x>=ObjectInspector1.left then inc(new_x, 60) else new_x:=16;
  if screen.height-new_y>=MainIDEBar.top then inc(new_y, 80) else new_y:=24;
  
  // create jit component
  CInterface := TComponentInterface(
    FormEditor1.CreateComponent(nil,TComponentClass(AncestorType),
      new_x, new_y, 400,300));
  FormEditor1.SetComponentNameAndClass(CInterface,
    NewUnitInfo.ComponentName,'T'+NewUnitInfo.ComponentName);
  NewComponent:=CInterface.Component;
  if NewComponent is TControl then
    TControl(NewComponent).Visible:=false;
  NewUnitInfo.Component:=NewComponent;
  CreateDesignerForComponent(NewComponent);

  NewUnitInfo.ComponentName:=NewComponent.Name;
  NewUnitInfo.ComponentResourceName:=NewUnitInfo.ComponentName;
  if NewUnitInfo.IsPartOfProject and Project1.AutoCreateForms then begin
    Project1.AddCreateFormToProjectFile(NewComponent.ClassName,
                                        NewComponent.Name);
  end;

  Result:=mrOk;
end;

function TMainIDE.DoLoadResourceFile(AnUnitInfo: TUnitInfo;
  var LFMCode, ResourceCode: TCodeBuffer;
  IgnoreSourceErrors: boolean): TModalResult;
var LinkIndex: integer;
  LFMFilename, MsgTxt: string;
begin
  LFMCode:=nil;
  ResourceCode:=nil;
  if AnUnitInfo.HasResources then begin
    //writeln('TMainIDE.DoLoadResourceFile A "',AnUnitInfo.Filename,'" "',AnUnitInfo.ResourceFileName,'"');
    // first try to find the resource file (.lrs) via the unit source
    LinkIndex:=-1;
    ResourceCode:=CodeToolBoss.FindNextResourceFile(
      AnUnitInfo.Source,LinkIndex);
    // if unit source has errors, then show the error and try the last resource
    // file (.lrs)
    if (ResourceCode=nil) and (CodeToolBoss.ErrorMessage<>'') then begin
      if not IgnoreSourceErrors then
        DoJumpToCodeToolBossError;
      if (AnUnitInfo.ResourceFileName<>'') then begin
        Result:=LoadCodeBuffer(ResourceCode,AnUnitInfo.ResourceFileName,
                               [lbfCheckIfText]);
        if Result=mrAbort then exit;
      end;
    end;
    // if no resource file found (i.e. normally the .lrs file)
    // then tell the user
    if (ResourceCode=nil) and (not IgnoreSourceErrors) then begin
      MsgTxt:=Format(lisUnableToLoadOldResourceFileTheResourceFileIs, [#13,
        #13, #13, AnUnitInfo.UnitName, #13]);
      Result:=MessageDlg(lisResourceLoadError, MsgTxt, mtWarning,
                         [mbIgnore,mbAbort],0);
      if Result=mrAbort then exit;
    end;

    // then load the lfm file (without parsing)
    if (not AnUnitInfo.IsVirtual) and (AnUnitInfo.Component<>nil) then begin
      LFMFilename:=ChangeFileExt(AnUnitInfo.Filename,'.lfm');
      if (FileExists(LFMFilename)) then begin
        Result:=LoadCodeBuffer(LFMCode,LFMFilename,[lbfCheckIfText]);
        if not (Result in [mrOk,mrIgnore]) then exit;
      end;
    end;
  end;
  Result:=mrOk;
end;

function TMainIDE.DoShowSaveFileAsDialog(AnUnitInfo: TUnitInfo;
  var ResourceCode: TCodeBuffer): TModalResult;
var
  SaveDialog: TSaveDialog;
  SaveAsFilename, SaveAsFileExt, NewFilename, NewUnitName, NewFilePath,
  AlternativeUnitName: string;
  ACaption, AText: string;
  SrcEdit: TSourceEditor;
  FileWithoutPath: String;
  PkgDefaultDirectory: String;
begin
  SrcEdit:=GetSourceEditorForUnitInfo(AnUnitInfo);

  // try to keep the old filename and extension
  SaveAsFileExt:=ExtractFileExt(AnUnitInfo.FileName);
  if SaveAsFileExt='' then begin
    if SrcEdit.SyntaxHighlighterType in [lshFreePascal, lshDelphi]
    then
      SaveAsFileExt:=PascalExtension[EnvironmentOptions.PascalFileExtension]
    else
      SaveAsFileExt:=EditorOpts.HighlighterList.GetDefaultFilextension(
                         SrcEdit.SyntaxHighlighterType);
  end;
  AnUnitInfo.ReadUnitNameFromSource(true);
  SaveAsFilename:=AnUnitInfo.UnitName;
  if SaveAsFilename='' then
    SaveAsFilename:=ExtractFileNameOnly(AnUnitInfo.Filename);
  if SaveAsFilename='' then
    SaveAsFilename:=lisnoname;

  // let user choose a filename
  SaveDialog:=TSaveDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(SaveDialog);
    SaveDialog.Title:=lisSaveSpace+SaveAsFilename+' (*'+SaveAsFileExt+')';
    SaveDialog.FileName:=SaveAsFilename+SaveAsFileExt;
    // if this is a project file, start in project directory
    if AnUnitInfo.IsPartOfProject and (not Project1.IsVirtual)
    and (not FileIsInPath(SaveDialog.InitialDir,Project1.ProjectDirectory)) then
      SaveDialog.InitialDir:=Project1.ProjectDirectory;
    // if this is a package file, then start in package directory
    if (not AnUnitInfo.IsVirtual) then begin
      PkgDefaultDirectory:=
        PkgBoss.GetDefaultSaveDirectoryForFile(AnUnitInfo.Filename);
      if (PkgDefaultDirectory<>'')
      and (not FileIsInPath(SaveDialog.InitialDir,PkgDefaultDirectory)) then
        SaveDialog.InitialDir:=PkgDefaultDirectory;
    end;
    // show save dialog
    if (not SaveDialog.Execute) or (ExtractFileName(SaveDialog.Filename)='')
    then begin
      // user cancels
      Result:=mrCancel;
      exit;
    end;
    NewFilename:=ExpandFilename(SaveDialog.Filename);
  finally
    InputHistories.StoreFileDialogSettings(SaveDialog);
    SaveDialog.Free;
  end;

  // check file extension
  if ExtractFileExt(NewFilename)='' then begin
    NewFilename:=NewFilename+SaveAsFileExt;
  end;

  // check file path
  NewFilePath:=ExtractFilePath(NewFilename);
  if not DirPathExists(NewFilePath) then begin
    ACaption:=lisEnvOptDlgDirectoryNotFound;
    AText:=Format(lisTheDestinationDirectoryDoesNotExist, [#13, '"',
      NewFilePath, '"']);
    MessageDlg(ACaption, AText, mtConfirmation,[mbCancel],0);
    Result:=mrCancel;
    exit;
  end;

  // check unitname
  if FilenameIsPascalUnit(NewFilename) then begin
    NewUnitName:=ExtractFileNameOnly(NewFilename);
    if NewUnitName='' then begin
      Result:=mrCancel;
      exit;
    end;
    if not IsValidIdent(NewUnitName) then begin
      AlternativeUnitName:=NameToValidIdentifier(NewUnitName);
      Result:=MessageDlg(lisInvalidPascalIdentifierCap,
        Format(lisInvalidPascalIdentifierText,[NewUnitName,AlternativeUnitName]),
        mtWarning,[mbIgnore,mbCancel],0);
      if Result=mrCancel then exit;
      NewUnitName:=AlternativeUnitName;
      Result:=mrCancel;
    end;
    if Project1.IndexOfUnitWithName(NewUnitName,true,AnUnitInfo)>=0 then
    begin
      Result:=MessageDlg(lisUnitNameAlreadyExistsCap,
         Format(lisTheUnitAlreadyExistsIgnoreWillForceTheRenaming, ['"',
           NewUnitName, '"', #13, #13, #13]),
          mtConfirmation,[mbIgnore,mbCancel,mbAbort],0);
      if Result=mrIgnore then
        Result:=mrCancel
      else
        exit;
    end;
  end else begin
    NewUnitName:='';
  end;

  // check filename
  if FilenameIsPascalUnit(NewFilename) then begin
    FileWithoutPath:=ExtractFileName(NewFilename);
    // check if file should be auto renamed


    if EnvironmentOptions.CharcaseFileAction = ccfaAsk then begin
      if lowercase(FileWithoutPath)<>FileWithoutPath
      then begin
        Result:=MessageDlg(lisRenameFile,
           Format(lisThisLooksLikeAPascalFileFpc10XExpectsPascalFiles, [#13, #13]),
          mtWarning,[mbYes,mbNo],0);
        if Result=mrYes then
          NewFileName:=ExtractFilePath(NewFilename)+lowercase(FileWithoutPath);
        Result:=mrOk;
      end;
    end else begin

      if EnvironmentOptions.CharcaseFileAction = ccfaAutoRename then
        NewFileName:=ExtractFilePath(NewFilename)+lowercase(FileWithoutPath);
    end;
  end;
  if (AnUnitInfo.IsVirtual
      or (CompareFilenames(NewFilename,AnUnitInfo.Filename)<>0))
  and FileExists(NewFilename) then begin
    ACaption:=lisOverwriteFile;
    AText:=Format(lisAFileAlreadyExistsReplaceIt, ['"', NewFilename, '"', #13]);
    Result:=MessageDlg(ACaption, AText, mtConfirmation,[mbok,mbCancel],0);
    if Result=mrCancel then exit;
  end;

  Result:=DoRenameUnit(AnUnitInfo,NewFilename,NewUnitName,ResourceCode);
end;

{$IFDEF TRANSLATESTRING}
{ TLRTGrubber }
type
  TLRTGrubber=class(TObject)
     private
       FGrubbed: TStrings;
     public
       constructor Create;
       destructor Destroy;override;
       procedure Grub(Sender:TObject; const Instance: TPersistent; PropInfo: PPropInfo; var Content:string);
       property Grubbed:TStrings read FGrubbed;
     end;


constructor TLRTGrubber.Create;
begin
  inherited Create;
  FGrubbed:=TStringList.Create;
end;

destructor TLRTGrubber.Destroy;
begin
  FGrubbed.Free;
  inherited Destroy;
end;

procedure TLRTGrubber.Grub(Sender: TObject; const Instance: TPersistent;
  PropInfo: PPropInfo; var Content: string);
begin
  if not Assigned(Instance) then exit;
  if not Assigned(PropInfo) then exit;
  if (AnsiUpperCase(PropInfo^.PropType^.Name)<>'TTRANSLATESTRING')
  and not (Instance is TMenuItem) then exit;
  FGrubbed.Add(AnsiUpperCase(Instance.ClassName+'.'+PropInfo^.Name)+'='+Content);
end;
{$ENDIF}

function TMainIDE.DoSaveFileResources(AnUnitInfo: TUnitInfo;
  ResourceCode, LFMCode: TCodeBuffer; Flags: TSaveFlags): TModalResult;
const
  BufSize = 4096; // allocating mem in 4k chunks helps many mem managers
var
  ComponentSavingOk: boolean;
  MemStream, BinCompStream, TxtCompStream: TExtMemoryStream;
  DestroyDriver: Boolean;
  Writer: TWriter;
  ACaption, AText: string;
  CompResourceCode, LFMFilename, TestFilename, ResTestFilename: string;
  UnitSaveFilename: String;
  {$IFDEF TRANSLATESTRING}Grubber:TLRTGrubber;{$ENDIF}
begin
  Result:=mrCancel;

  // save lrs - lazarus resource file and lfm - lazarus form text file
  // Note: When there is a bug in the source, the include directive of the
  //       resource code can not be found, therefore the LFM file should always
  //       be saved first.
  //       And therefore each TUnitInfo stores the resource filename (.lrs).

  // the lfm file is saved before the lrs file, because the IDE only needs the
  // lfm file to recreate the lrs file.
  // by VVI - now a LRT file is saved in addition to LFM and LRS
  // LRT file format (in present) are lines
  // <ClassName>.<PropertyName>=<PropertyValue>

  if (AnUnitInfo.Component<>nil) then begin
    // stream component to resource code and to lfm file
    ComponentSavingOk:=true;

    // save designer form properties to the component
    FormEditor1.SaveHiddenDesignerFormProperties(AnUnitInfo.Component);

    // stream component to binary stream
    BinCompStream:=TExtMemoryStream.Create;
    if AnUnitInfo.ComponentLastBinStreamSize>0 then
      BinCompStream.Capacity:=AnUnitInfo.ComponentLastBinStreamSize+BufSize;
    Writer:=nil;
    DestroyDriver:=false;
    try
      Result:=mrOk;
      repeat
        try
          BinCompStream.Position:=0;
          Writer:=CreateLRSWriter(BinCompStream,DestroyDriver);
          {$IFDEF TRANSLATESTRING}
          //The original idea was make a callback just in IDE
          //There is a theoretical possibility that in unusual situation
          //we will grub two components simultaneously. How?
          //I don't know, now this is not possible.
          Grubber:=TLRTGrubber.Create;
          Writer.OnWriteStringProperty:=@Grubber.Grub;
          {$ENDIF}
          Writer.WriteDescendent(AnUnitInfo.Component,nil);
          if DestroyDriver then Writer.Driver.Free;
          Writer.Free;
          Writer:=nil;
          AnUnitInfo.ComponentLastBinStreamSize:=BinCompStream.Size;
        except
          on E: Exception do begin
            ACaption:=lisStreamingError;
            AText:=Format(lisUnableToStreamT, [AnUnitInfo.ComponentName,
                          AnUnitInfo.ComponentName])+#13
                          +E.Message;
            Result:=MessageDlg(ACaption, AText, mtError,
                       [mbAbort, mbRetry, mbIgnore], 0);
            if Result=mrAbort then exit;
            if Result=mrIgnore then Result:=mrOk;
            ComponentSavingOk:=false;
          end;
        end;
      until Result<>mrRetry;

      // create lazarus form resource code
      if ComponentSavingOk then begin
        if ResourceCode=nil then begin
          if (sfSaveToTestDir in Flags) then
            UnitSaveFilename:=GetTestUnitFilename(AnUnitInfo)
          else
            UnitSaveFilename:=AnUnitInfo.Filename;
          ResTestFilename:=ChangeFileExt(UnitSaveFilename,ResourceFileExt);
          ResourceCode:=CodeToolBoss.CreateFile(ResTestFilename);
          ComponentSavingOk:=(ResourceCode<>nil);
        end;
        if ComponentSavingOk then begin
          // there is no bug in the source, so the resource code should be
          // changed too
          MemStream:=TExtMemoryStream.Create;
          if AnUnitInfo.ComponentLastLRSStreamSize>0 then
            MemStream.Capacity:=AnUnitInfo.ComponentLastLRSStreamSize+BufSize;
          try
            BinCompStream.Position:=0;
            BinaryToLazarusResourceCode(BinCompStream,MemStream
              ,'T'+AnUnitInfo.ComponentName,'FORMDATA');
            AnUnitInfo.ComponentLastLRSStreamSize:=MemStream.Size;
            MemStream.Position:=0;
            SetLength(CompResourceCode,MemStream.Size);
            MemStream.Read(CompResourceCode[1],length(CompResourceCode));
          finally
            MemStream.Free;
          end;
        end;
        if ComponentSavingOk then begin
          {$IFDEF IDE_DEBUG}
          writeln('TMainIDE.SaveFileResources E ',CompResourceCode);
          {$ENDIF}
          // replace lazarus form resource code in include file (.lrs)
          if not (sfSaveToTestDir in Flags) then begin
            // if resource name has changed, delete old resource
            if (AnUnitInfo.ComponentName<>AnUnitInfo.ComponentResourceName)
            and (AnUnitInfo.ComponentResourceName<>'') then begin
              CodeToolBoss.RemoveLazarusResource(ResourceCode,
                                          'T'+AnUnitInfo.ComponentResourceName);
            end;
            // add comment to resource file (if not already exists)
            if (not CodeToolBoss.AddLazarusResourceHeaderComment(ResourceCode,
               lisResourceFileComment)) then
            begin
              ACaption:=lisResourceSaveError;
              AText:=Format(lisUnableToAddResourceHeaderCommentToResourceFile, [
                #13, '"', ResourceCode.FileName, '"', #13]);
              Result:=MessageDlg(ACaption,AText,mtError,[mbIgnore,mbAbort],0);
              if Result<>mrIgnore then exit;
            end;
            // add resource to resource file
            if (not CodeToolBoss.AddLazarusResource(ResourceCode,
               'T'+AnUnitInfo.ComponentName,CompResourceCode)) then
            begin
              ACaption:=lisResourceSaveError;
              AText:=Format(
                lisUnableToAddResourceTFORMDATAToResourceFileProbably, [
                AnUnitInfo.ComponentName,
                #13, '"', ResourceCode.FileName, '"', #13]
                );
              Result:=MessageDlg(ACaption, AText, mtError, [mbIgnore, mbAbort],0);
              if Result<>mrIgnore then exit;
            end else begin
              AnUnitInfo.ResourceFileName:=ResourceCode.Filename;
              AnUnitInfo.ComponentResourceName:=AnUnitInfo.ComponentName;
            end;
          end else begin
            ResourceCode.Source:=CompResourceCode;
          end;
        end;
        if (not (sfSaveToTestDir in Flags)) then begin
          // save lfm file
          LFMFilename:=ChangeFileExt(AnUnitInfo.Filename,'.lfm');
          if LFMCode=nil then begin
            LFMCode:=CodeToolBoss.CreateFile(LFMFilename);
            if LFMCode=nil then begin
              Result:=MessageDlg(lisUnableToCreateFile,
                Format(lisUnableToCreateFile2, ['"', LFMFilename, '"']),
                mtWarning,[mbIgnore,mbCancel,mbAbort],0);
              if Result<>mrIgnore then exit;
            end;
          end;
          if LFMCode<>nil then begin
            {$IFDEF IDE_DEBUG}
            writeln('TMainIDE.SaveFileResources E2 LFM=',LFMCode.Filename);
            {$ENDIF}
            Result:=mrOk;
            repeat
              try
                // transform binary to text
                TxtCompStream:=TExtMemoryStream.Create;
                if AnUnitInfo.ComponentLastLFMStreamSize>0 then
                  TxtCompStream.Capacity:=AnUnitInfo.ComponentLastLFMStreamSize
                                          +BufSize;
                try
                  BinCompStream.Position:=0;
                  LRSObjectBinaryToText(BinCompStream,TxtCompStream);
                  AnUnitInfo.ComponentLastLFMStreamSize:=TxtCompStream.Size;
                  // stream text to file
                  TxtCompStream.Position:=0;
                  LFMCode.LoadFromStream(TxtCompStream);
                  Result:=DoSaveCodeBufferToFile(LFMCode,LFMCode.Filename,
                                   AnUnitInfo.IsPartOfProject);
                  if not Result=mrOk then exit;
                  Result:=mrCancel;
                finally
                  TxtCompStream.Free;
                end;
              except
                on E: Exception do begin
                  ACaption:=lisStreamingError;
                  AText:=Format(
                    lisUnableToTransformBinaryComponentStreamOfTIntoText, [
                    AnUnitInfo.ComponentName, AnUnitInfo.ComponentName])
                    +#13+E.Message;
                  Result:=MessageDlg(ACaption, AText, mtError,
                                     [mbAbort, mbRetry, mbIgnore], 0);
                  if Result=mrAbort then exit;
                  if Result=mrIgnore then Result:=mrOk;
                end;
              end;
            until Result<>mrRetry;
          end;
        end;
      end;
      // Now the most important file (.lfm) is saved.
      // Now save the secondary files
      {$IFDEF TRANSLATESTRING}
      // save the .lrt file containing the list of all translatable strings of
      // the component
      if ComponentSavingOk and (Grubber.Grubbed.Count>0)
      and not (sfSaveToTestDir in Flags) then begin
        // TODO: Add to project or environment options making .po files
        Result:=SaveStringToFile(ChangeFileExt(AnUnitInfo.Filename,'.lrt'),
                                 Grubber.Grubbed.Text,[mbIgnore,mbAbort]);
        if (Result<>mrOk) and (Result<>mrIgnore) then exit;
      end;
      {$ENDIF}
    finally
      try
        BinCompStream.Free;
        if DestroyDriver and (Writer<>nil) then Writer.Driver.Free;
        Writer.Free;
        {$IFDEF TRANSLATESTRING}
        Grubber.Free;
        {$ENDIF}
      except
        on E: Exception do begin
          debugln('TMainIDE.SaveFileResources Error cleaning up: ',E.Message);
        end;
      end;
    end;
  end;
  {$IFDEF IDE_DEBUG}
  if ResourceCode<>nil then
    writeln('TMainIDE.SaveFileResources F ',ResourceCode.Modified);
  {$ENDIF}
  // save binary stream (.lrs)
  if ResourceCode<>nil then begin
    if not (sfSaveToTestDir in Flags) then begin
      if (ResourceCode.Modified) then begin
        Result:=DoSaveCodeBufferToFile(ResourceCode,ResourceCode.Filename,
                                       AnUnitInfo.IsPartOfProject);
        if not Result=mrOk then exit;
      end;
    end else begin
      TestFilename:=GetTestUnitFilename(AnUnitInfo);
      Result:=DoSaveCodeBufferToFile(ResourceCode,
                 ChangeFileExt(TestFilename,
                               ExtractFileExt(ResourceCode.Filename)),
                 false);
      if not Result=mrOk then exit;
    end;
  end;
  Result:=mrOk;
  {$IFDEF IDE_DEBUG}
  writeln('TMainIDE.SaveFileResources G ',LFMCode<>nil);
  {$ENDIF}
end;

function TMainIDE.DoRenameUnit(AnUnitInfo: TUnitInfo;
  NewFilename, NewUnitName: string;
  var ResourceCode: TCodeBuffer): TModalresult;
var
  NewLFMFilename: String;
  OldSource: String;
  NewSource: TCodeBuffer;
  NewFilePath: String;
  NewResFilePath: String;
  OldFilePath: String;
  OldResFilePath: String;
  SrcEdit: TSourceEditor;
  OldFilename: String;
  NewResFilename: String;
  NewHighlighter: TLazSyntaxHighlighter;
  AmbiguousFiles: TStringList;
  AmbiguousText: string;
  i: Integer;
  AmbiguousFilename: String;
begin
  OldFilename:=AnUnitInfo.Filename;
  OldFilePath:=ExtractFilePath(OldFilename);
  SrcEdit:=GetSourceEditorForUnitInfo(AnUnitInfo);
  if NewUnitName='' then
    NewUnitName:=AnUnitInfo.UnitName;

  // check new resource file
  if AnUnitInfo.ComponentName='' then begin
    // unit has no component
    // -> remove lfm file, so that it will not be auto loaded on next open
    NewLFMFilename:=ChangeFileExt(NewFilename,'.lfm');
    if (FileExists(NewLFMFilename))
    and (not DeleteFile(NewLFMFilename))
    and (MessageDlg(lisPkgMangDeleteFailed, Format(lisDeletingOfFileFailed, [
      '"', NewLFMFilename, '"']), mtError, [mbIgnore, mbCancel], 0)=mrCancel)
      then
    begin
      Result:=mrCancel;
      exit;
    end;
  end;

  // check new resource file
  if AnUnitInfo.ComponentName='' then begin
    // unit has no component
    // -> remove lfm file, so that it will not be auto loaded on next open
    NewLFMFilename:=ChangeFileExt(NewFilename,'.lfm');
    if (FileExists(NewLFMFilename))
    and (not DeleteFile(NewLFMFilename))
    and (MessageDlg(lisPkgMangDeleteFailed, Format(lisDeletingOfFileFailed, [
      '"', NewLFMFilename, '"']), mtError, [mbIgnore, mbCancel], 0)=mrCancel)
      then
    begin
      Result:=mrCancel;
      exit;
    end;
  end;

  // create new source with the new filename
  OldSource:=AnUnitInfo.Source.Source;
  NewSource:=CodeToolBoss.CreateFile(NewFilename);
  NewSource.Source:=OldSource;
  if NewSource=nil then begin
    Result:=MessageDlg(lisUnableToCreateFile,
      Format(lisCanNotCreateFile, ['"', NewFilename, '"']),
      mtError,[mbCancel,mbAbort],0);
    exit;
  end;
  // get final filename
  NewFilename:=NewSource.Filename;
  NewFilePath:=ExtractFilePath(NewFilename);
  EnvironmentOptions.AddToRecentOpenFiles(NewFilename);
  SetRecentFilesMenu;

  // rename Resource file
  if (ResourceCode<>nil) then begin
    // the resource include line in the code will be changed later after
    // changing the unitname
    OldResFilePath:=ExtractFilePath(ResourceCode.Filename);
    NewResFilePath:=OldResFilePath;
    if FilenameIsAbsolute(OldFilePath)
    and FileIsInPath(OldResFilePath,OldFilePath) then begin
      // resource code was in the same or in a sub directory of source
      // -> try to keep this relationship
      NewResFilePath:=NewFilePath
                       +copy(ResourceCode.Filename,length(OldFilePath)+1,
                         length(ResourceCode.Filename));
      if not DirPathExists(NewResFilePath) then
        NewResFilePath:=NewFilePath;
    end else begin
      // resource code was not in the same or in a sub dircetoy of source
      // copy resource into the same directory as the source
      NewResFilePath:=NewFilePath;
    end;
    NewResFilename:=NewResFilePath
                    +ExtractFileNameOnly(NewFilename)+ResourceFileExt;
    CodeToolBoss.SaveBufferAs(ResourceCode,NewResFilename,ResourceCode);
    if ResourceCode<>nil then
      AnUnitInfo.ResourceFileName:=ResourceCode.Filename;

    {$IFDEF IDE_DEBUG}
    writeln('TMainIDE.DoRenameUnit C ',ResourceCode<>nil);
    writeln('   NewResFilePath="',NewResFilePath,'" NewResFilename="',NewResFilename,'"');
    if ResourceCode<>nil then writeln('*** ResourceFileName ',ResourceCode.Filename);
    {$ENDIF}
  end else begin
    NewResFilename:='';
  end;
  {$IFDEF IDE_DEBUG}
  writeln('TMainIDE.DoRenameUnit D ',ResourceCode<>nil);
  {$ENDIF}

  // set new codebuffer in unitinfo and sourceeditor
  AnUnitInfo.Source:=NewSource;
  AnUnitInfo.Modified:=false;
  if SrcEdit<>nil then
    SrcEdit.CodeBuffer:=NewSource; // the code is not changed,
                                   // therefore the marks are kept

  // change unitname in project and in source
  AnUnitInfo.UnitName:=NewUnitName;
  if ResourceCode<>nil then begin
    // change resource filename in the source include directive
    CodeToolBoss.RenameMainInclude(AnUnitInfo.Source,
      ExtractRelativePath(NewFilePath,NewResFilename),false);
  end;

  // change unitname on SourceNotebook
  if SrcEdit<>nil then
    UpdateSourceNames;

  // change syntax highlighter
  if not AnUnitInfo.CustomHighlighter then begin
    NewHighlighter:=
      ExtensionToLazSyntaxHighlighter(ExtractFileExt(NewFilename));
    if NewHighlighter<>AnUnitInfo.SyntaxHighlighter then begin
      AnUnitInfo.SyntaxHighlighter:=NewHighlighter;
      if SrcEdit<>nil then
        SrcEdit.SyntaxHighlighterType:=AnUnitInfo.SyntaxHighlighter;
    end;
  end;

  // save file
  Result:=DoSaveCodeBufferToFile(NewSource,NewSource.Filename,
                                 AnUnitInfo.IsPartOfProject);
  if Result<>mrOk then exit;

  // change packages containing the file
  Result:=PkgBoss.OnRenameFile(OldFilename,AnUnitInfo.Filename,
                               AnUnitInfo.IsPartOfProject);
  if Result=mrAbort then exit;

  // delete ambiguous files
  NewFilePath:=ExtractFilePath(NewFilename);
  AmbiguousFiles:=
    FindFilesCaseInsensitive(NewFilePath,ExtractFilename(NewFilename),true);
  if AmbiguousFiles<>nil then begin
    try
      if (AmbiguousFiles.Count=1)
      and (CompareFilenames(OldFilePath,NewFilePath)=0)
      and (CompareFilenames(AmbiguousFiles[0],ExtractFilename(OldFilename))=0)
      then
        AmbiguousText:=Format(lisDeleteOldFile, ['"', ExtractFilename(
          OldFilename), '"'])
      else
        AmbiguousText:=
          Format(lisThereAreOtherFilesInTheDirectoryWithTheSameName,
                 [#13, #13, AmbiguousFiles.Text, #13]);
      Result:=MessageDlg(lisAmbiguousFilesFound, AmbiguousText,
        mtWarning,[mbYes,mbNo,mbAbort],0);
      if Result=mrAbort then exit;
      if Result=mrYes then begin
        NewFilePath:=AppendPathDelim(ExtractFilePath(NewFilename));
        for i:=0 to AmbiguousFiles.Count-1 do begin
          AmbiguousFilename:=NewFilePath+AmbiguousFiles[i];
          if (FileExists(AmbiguousFilename))
          and (not DeleteFile(AmbiguousFilename))
          and (MessageDlg(lisPkgMangDeleteFailed, Format(lisDeletingOfFileFailed,
            ['"', AmbiguousFilename, '"']), mtError, [mbIgnore, mbCancel], 0)=
            mrCancel) then
          begin
            Result:=mrCancel;
            exit;
          end;
        end;
      end;
    finally
      AmbiguousFiles.Free;
    end;
  end;

  Result:=mrOk;
end;

function TMainIDE.DoOpenNotExistingFile(const AFileName: string;
  Flags: TOpenFlags): TModalResult;
var
  NewFlags: TNewFlags;
begin
  if ofProjectLoading in Flags then begin
    // this is a file, that was loaded last time, but was removed from disk
    Result:=MessageDlg(lisFileNotFound,
      Format(lisTheFileWasNotFoundIgnoreWillGoOnLoadingTheProject, ['"',
        AFilename, '"', #13, #13, #13]),
      mtError, [mbIgnore, mbAbort], 0);
    exit;
  end;

  // Default to cancel
  Result:=mrCancel;
  if ofQuiet in Flags then Exit;

  if ofOnlyIfExists in Flags
  then begin
    MessageDlg(lisFileNotFound, Format(lisFileNotFound2, ['"', AFilename, '"',
      #13]),
               mtInformation,[mbCancel],0);
    // cancel loading file
    Exit;
  end;

  if MessageDlg(lisFileNotFound,
    Format(lisFileNotFoundDoYouWantToCreateIt, ['"', AFilename, '"', #13, #13])
    ,mtInformation,[mbYes,mbNo],0)=mrYes then
  begin
    // create new file
    NewFlags:=[nfOpenInEditor,nfCreateDefaultSrc];
    if ofAddToProject in Flags then
      Include(NewFlags,nfIsPartOfProject);
    if FilenameIsPascalSource(AFilename) then
      Result:=DoNewEditorFile(FileDescriptorUnit,AFilename,'',NewFlags)
    else
      Result:=DoNewEditorFile(FileDescriptorText,AFilename,'',NewFlags);
  end;
end;

function TMainIDE.DoOpenUnknownFile(const AFileName: string; Flags: TOpenFlags;
  var NewUnitInfo: TUnitInfo; var Handled: boolean): TModalResult;
var
  Ext, NewProgramName, LPIFilename, ACaption, AText: string;
  PreReadBuf: TCodeBuffer;
  LoadFlags: TLoadBufferFlags;
begin
  Handled:=false;
  Ext:=lowercase(ExtractFileExt(AFilename));

  if ([ofProjectLoading,ofRegularFile]*Flags<>[]) and (ToolStatus=itNone)
  and (Ext='.lpi') then begin
    // this is a project info file -> load whole project
    Result:=DoOpenProjectFile(AFilename,[ofAddToRecent]);
    Handled:=true;
    exit;
  end;

  // load the source
  LoadFlags := [lbfCheckIfText,lbfUpdateFromDisk,lbfRevert];
  if ofQuiet in Flags then Include(LoadFlags, lbfQuiet);
  Result:=LoadCodeBuffer(PreReadBuf,AFileName,LoadFlags);
  if Result<>mrOk then exit;
  NewUnitInfo:=nil;

  // check if unit is a program
  if ([ofProjectLoading,ofRegularFile]*Flags=[])
  and FilenameIsPascalSource(AFilename)
  and (CodeToolBoss.GetSourceType(PreReadBuf,false)='PROGRAM') then begin
    NewProgramName:=CodeToolBoss.GetSourceName(PreReadBuf,false);
    if NewProgramName<>'' then begin
      // source is a program
      // either this is a lazarus project
      // or it is not yet a lazarus project ;)
      LPIFilename:=ChangeFileExt(AFilename,'.lpi');
      if FileExists(LPIFilename) then begin
        AText:=Format(lisTheFileSeemsToBeTheProgramFileOfAnExistingLazarus, [
          '"', AFilename, '"', #13, #13, #13]);
        ACaption:=lisProjectInfoFileDetected;
        if MessageDlg(ACaption, AText, mtconfirmation,
             [mbok, mbcancel], 0)=mrOk then
        begin
          Result:=DoOpenProjectFile(LPIFilename,[]);
          Handled:=true;
          exit;
        end;
      end else begin
        AText:=Format(lisTheFileSeemsToBeAProgramCloseCurrentProject, ['"',
          AFilename, '"', #13, #13]);
        ACaption:=lisProgramDetected;
        if MessageDlg(ACaption, AText, mtConfirmation,
            [mbYes, mbNo], 0)=mrYes then
        begin
          Result:=DoCreateProjectForProgram(PreReadBuf);
          Handled:=true;
          exit;
        end;
      end;
    end;
  end;
  NewUnitInfo:=TUnitInfo.Create(PreReadBuf);
  if FilenameIsPascalSource(NewUnitInfo.Filename) then
    NewUnitInfo.ReadUnitNameFromSource(true);
  Project1.AddFile(NewUnitInfo,false);
  if (ofAddToProject in Flags) and (not NewUnitInfo.IsPartOfProject) then
  begin
    NewUnitInfo.IsPartOfProject:=true;
    Project1.Modified:=true;
  end;
  
  Result:=mrOk;
end;

procedure TMainIDE.DoRestoreBookMarks(AnUnitInfo: TUnitInfo;
  ASrcEdit: TSourceEditor);
var
  BookmarkID, i: integer;
begin
  Project1.MergeBookmarks(AnUnitInfo);
  for BookmarkID:=0 to 9 do begin
    i:=Project1.Bookmarks.IndexOfID(BookmarkID);
    if i<0 then continue;
    if (Project1.Bookmarks[i].EditorIndex=AnUnitInfo.EditorIndex) then begin
      //writeln('TMainIDE.DoRestoreBookMarks ',BookmarkID,' ',
      //   Project1.Bookmarks[i].CursorPos.X,' ',Project1.Bookmarks[i].CursorPos.Y);
      ASrcEdit.EditorComponent.SetBookmark(BookmarkID,
         Project1.Bookmarks[i].CursorPos.X,Project1.Bookmarks[i].CursorPos.Y);
    end;
  end;
end;

function TMainIDE.DoLoadLFM(AnUnitInfo: TUnitInfo;
  Flags: TOpenFlags): TModalResult;
// if there is a .lfm file, open the resource
var
  LFMFilename: string;
  LFMBuf: TCodeBuffer;
begin
  CloseDesignerForm(AnUnitInfo);

  // Note: think about virtual and normal .lfm files.
  LFMFilename:=ChangeFileExt(AnUnitInfo.Filename,'.lfm');
  LFMBuf:=nil;
  if not FileExistsInIDE(LFMFilename,[pfsfOnlyEditorFiles]) then begin
    // there is no LFM file -> ok
    debugln('TMainIDE.DoLoadLFM there is no LFM file for "',AnUnitInfo.Filename,'"');
    Result:=mrOk;
    exit;
  end;

  // there is a lazarus form text file -> load it
  Result:=LoadIDECodeBuffer(LFMBuf,LFMFilename,[lbfUpdateFromDisk]);
  if Result<>mrOk then exit;
  
  Result:=DoLoadLFM(AnUnitInfo,LFMBuf,Flags,false);
end;

function TMainIDE.DoLoadLFM(AnUnitInfo: TUnitInfo; LFMBuf: TCodeBuffer;
  Flags: TOpenFlags; CloseDsgnForm: boolean): TModalResult;
const
  BufSize = 4096; // allocating mem in 4k chunks helps many mem managers
var
  ComponentLoadingOk: boolean;
  TxtLFMStream, BinLFMStream: TExtMemoryStream;
  CInterface: TComponentInterface;
  NewComponent: TComponent;
  AncestorType: TComponentClass;
  DesignerForm: TCustomForm;
  NewClassName: String;
  NewAncestorName: String;
  APersistentClass: TPersistentClass;
  ACaption, AText: String;
begin
  // check installed packages
  debugln('TMainIDE.DoLoadLFM A ',AnUnitInfo.Filename,' ',dbgs(AnUnitInfo.IsPartOfProject),' ');
  if (Flags*[ofProjectLoading,ofMultiOpen]=[]) and AnUnitInfo.IsPartOfProject
  then begin
    debugln('TMainIDE.DoLoadLFM B ');
    // opening a single form of the project -> check installed packages
    Result:=PkgBoss.CheckProjectHasInstalledPackages(Project1);
    if not (Result in [mrOk,mrIgnore]) then exit;
  end;

  // close old designer form
  if CloseDsgnForm then
    CloseDesignerForm(AnUnitInfo);

  //debugln('TMainIDE.DoLoadLFM LFM file loaded, parsing "',LFMBuf.Filename,'" ...');

  if not AnUnitInfo.HasResources then begin
    // someone created a .lfm file -> Update HasResources
    AnUnitInfo.HasResources:=true;
  end;
  
  //debugln('TMainIDE.DoLoadLFM LFM="',LFMBuf.Source,'"');

  ComponentLoadingOk:=true;

  BinLFMStream:=TExtMemoryStream.Create;
  try
    TxtLFMStream:=TExtMemoryStream.Create;
    try
      LFMBuf.SaveToStream(TxtLFMStream);
      AnUnitInfo.ComponentLastLFMStreamSize:=TxtLFMStream.Size;
      TxtLFMStream.Position:=0;

      // find the classname of the LFM
      NewClassName:=FindLFMClassName(TxtLFMStream);
      if NewClassName='' then begin
        Result:=MessageDlg(lisLFMFileCorrupt,
          Format(lisUnableToFindAValidClassnameIn, ['"', LFMBuf.Filename, '"']),
          mtError,[mbIgnore,mbCancel,mbAbort],0);
        exit;
      end;

      // find the ancestor type in the source
      NewAncestorName:='';
      AncestorType:=TForm;
      CodeToolBoss.FindFormAncestor(AnUnitInfo.Source,NewClassName,
                                    NewAncestorName,true);
      if NewAncestorName<>'' then begin
        if AnsiCompareText(NewAncestorName,'TDataModule')=0 then begin
          // use our TDataModule
          // (some fpc versions have non designable TDataModule)
          AncestorType:=TDataModule;
        end else begin
          APersistentClass:=Classes.GetClass(NewAncestorName);
          if (APersistentClass<>nil)
          and (APersistentClass.InheritsFrom(TComponent)) then begin
            // ancestor type is a registered component class
            AncestorType:=TComponentClass(APersistentClass);
          end;
        end;
      end;
      DebugLn('TMainIDE.DoLoadLFM AncestorClassName=',NewAncestorName,' AncestorType=',AncestorType.ClassName);

      // convert text to binary format
      try
        if AnUnitInfo.ComponentLastBinStreamSize>0 then
          BinLFMStream.Capacity:=AnUnitInfo.ComponentLastBinStreamSize+BufSize;
        LRSObjectTextToBinary(TxtLFMStream,BinLFMStream);
        AnUnitInfo.ComponentLastBinStreamSize:=BinLFMStream.Size;
        BinLFMStream.Position:=0;
        Result:=mrOk;
      except
        on E: Exception do begin
          DumpExceptionBackTrace;
          ACaption:=lisFormatError;
          AText:=Format(lisUnableToConvertTextFormDataOfFileIntoBinaryStream,
            [#13, '"', LFMBuf.Filename, '"', #13, E.Message]);
          Result:=MessageDlg(ACaption, AText, mtError, [mbOk, mbCancel], 0);
          if Result=mrCancel then Result:=mrAbort;
          if Result<>mrOk then exit;
          ComponentLoadingOk:=false;
        end;
      end;
    finally
      TxtLFMStream.Free;
    end;
    if ComponentLoadingOk then begin
      if not Assigned(FormEditor1) then
        FormEditor1 := TFormEditor.Create;
      if not (ofProjectLoading in Flags) then FormEditor1.ClearSelection;

      // create JIT component
      CInterface := TComponentInterface(
                      FormEditor1.CreateComponentFromStream(BinLFMStream,
                            AncestorType,copy(AnUnitInfo.UnitName,1,255),true));
      if CInterface=nil then begin
        // error streaming component -> examine lfm file
        DebugLn('ERROR: streaming failed lfm="',LFMBuf.Filename,'"');
        NewComponent:=nil;
        AnUnitInfo.Component:=NewComponent;
        // open lfm file in editor
        Result:=DoOpenEditorFile(LFMBuf.Filename,AnUnitInfo.EditorIndex+1,
          Flags+[ofOnlyIfExists,ofQuiet,ofRegularFile]);
        if Result<>mrOk then exit;
        Result:=DoCheckLFMInEditor;
        if Result=mrOk then Result:=mrCancel;
        exit;
      end else begin
        NewComponent:=CInterface.Component;
        AnUnitInfo.Component:=NewComponent;
        CreateDesignerForComponent(NewComponent);
        AnUnitInfo.ComponentName:=NewComponent.Name;
        AnUnitInfo.ComponentResourceName:=AnUnitInfo.ComponentName;

        if not (ofProjectLoading in Flags) then begin
          FDisplayState:= dsForm;
        end;

        // select the new form (object inspector, formeditor, control selection)
        DesignerForm:=FormEditor1.GetDesignerForm(NewComponent);
        if not (ofProjectLoading in Flags) then begin
          GlobalDesignHook.LookupRoot := NewComponent;
          TheControlSelection.AssignPersistent(NewComponent);
        end;
        FLastFormActivated:=DesignerForm;
      end;
    end;
    {$IFDEF IDE_DEBUG}
    writeln('[TMainIDE.DoLoadLFM] LFM end');
    {$ENDIF}
  finally
    BinLFMStream.Free;
  end;
  Result:=mrOk;
end;

{-------------------------------------------------------------------------------
  function TMainIDE.CloseDesignerForm

  Params: AnUnitInfo: TUnitInfo
  Result: TModalResult;

  Free the designer form of a unit.
-------------------------------------------------------------------------------}
function TMainIDE.CloseDesignerForm(AnUnitInfo: TUnitInfo): TModalResult;
var
  AForm: TCustomForm;
  i: integer;
  OldDesigner: TDesigner;
  LookupRoot: TComponent;
begin
  Result:=mrOk;
  LookupRoot:=AnUnitInfo.Component;
  if LookupRoot=nil then exit;
  AForm:=FormEditor1.GetDesignerForm(LookupRoot);
  if AForm=nil then
    RaiseException('TMainIDE.CloseDesignerForm '+AnUnitInfo.Filename);
  if (AForm=nil) then exit;
  if FLastFormActivated=AForm then
    FLastFormActivated:=nil;
  // unselect components
  for i:=LookupRoot.ComponentCount-1 downto 0 do
    TheControlSelection.Remove(LookupRoot.Components[i]);
  TheControlSelection.Remove(LookupRoot);
  // free designer and design form
  OldDesigner:=TDesigner(AForm.Designer);
  OldDesigner.DeleteFormAndFree;
  AnUnitInfo.Component:=nil;

  Result:=mrOk;
end;

function TMainIDE.CreateProjectObject(ProjectDesc,
  FallbackProjectDesc: TProjectDescriptor): TProject;
begin
  Result:=TProject.Create(ProjectDesc);
  // custom initialization
  if ProjectDesc.InitProject(Result)<>mrOk then begin
    Result.Free;
    Result:=nil;
    if FallbackProjectDesc=nil then exit;
    Result:=TProject.Create(FallbackProjectDesc);
    FallbackProjectDesc.InitProject(Result);
  end;

  Result.OnFileBackup:=@DoBackupFile;
  Result.OnLoadProjectInfo:=@OnLoadProjectInfoFromXMLConfig;
  Result.OnSaveProjectInfo:=@OnSaveProjectInfoToXMLConfig;
end;

procedure TMainIDE.OnLoadProjectInfoFromXMLConfig(TheProject: TProject;
  XMLConfig: TXMLConfig);
begin
  if TheProject=Project1 then
    DebugBoss.LoadProjectSpecificInfo(XMLConfig);
end;

procedure TMainIDE.OnSaveProjectInfoToXMLConfig(TheProject: TProject;
  XMLConfig: TXMLConfig; WriteFlags: TProjectWriteFlags);
begin
  if (TheProject=Project1) and (not (pwfSkipDebuggerSettings in WriteFlags))
  then
    DebugBoss.SaveProjectSpecificInfo(XMLConfig);
end;

procedure TMainIDE.GetMainUnit(var MainUnitInfo: TUnitInfo;
  var MainUnitSrcEdit: TSourceEditor; UpdateModified: boolean);
begin
  MainUnitSrcEdit:=nil;
  if Project1.MainUnitID>=0 then begin
    MainUnitInfo:=Project1.MainUnitInfo;
    if MainUnitInfo.Loaded then begin
      MainUnitSrcEdit:=SourceNoteBook.FindSourceEditorWithPageIndex(
        MainUnitInfo.EditorIndex);
      if UpdateModified and MainUnitSrcEdit.Modified then begin
        MainUnitSrcEdit.UpdateCodeBuffer;
        MainUnitInfo.Modified:=true;
      end;
    end;
  end else
    MainUnitInfo:=nil;
end;

procedure TMainIDE.SaveSrcEditorProjectSpecificSettings(AnUnitInfo: TUnitInfo);
var
  BookmarkID, BookmarkX, BookmarkY: integer;
  ASrcEdit: TSourceEditor;
begin
  Project1.Bookmarks.DeleteAllWithEditorIndex(AnUnitInfo.EditorIndex);
  ASrcEdit:=
    SourceNoteBook.FindSourceEditorWithPageIndex(AnUnitInfo.EditorIndex);
  if ASrcEdit=nil then exit;
  AnUnitInfo.TopLine:=ASrcEdit.EditorComponent.TopLine;
  AnUnitInfo.CursorPos:=ASrcEdit.EditorComponent.CaretXY;
  // bookmarks
  AnUnitInfo.Bookmarks.Clear;
  for BookmarkID:=0 to 9 do begin
    if (ASrcEdit.EditorComponent.GetBookMark(BookmarkID,BookmarkX,BookmarkY))
    then begin
      Project1.SetBookmark(AnUnitInfo,BookmarkX,BookmarkY,BookmarkID);
    end;
  end;
end;

procedure TMainIDE.SaveSourceEditorProjectSpecificSettings;
var
  AnUnitInfo: TUnitInfo;
begin
  Project1.Bookmarks.Clear;
  AnUnitInfo:=Project1.FirstUnitWithEditorIndex;
  while AnUnitInfo<>nil do begin
    if (not AnUnitInfo.Loaded) then continue;
    SaveSrcEditorProjectSpecificSettings(AnUnitInfo);
    AnUnitInfo:=AnUnitInfo.NextUnitWithEditorIndex;
  end;
end;

function TMainIDE.DoShowSaveProjectAsDialog: TModalResult;
var
  MainUnitSrcEdit: TSourceEditor;
  MainUnitInfo: TUnitInfo;
  SaveDialog: TSaveDialog;
  NewFilename, NewProgramFilename, NewProgramName, AText, ACaption,
  Ext: string;
  NewBuf: TCodeBuffer;
  OldProjectPath: string;
begin
  OldProjectPath:=Project1.ProjectDirectory;

  SaveDialog:=TSaveDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(SaveDialog);
    SaveDialog.Title:=Format(lisSaveProjectLpi, [Project1.Title]);

    // build a nice project info filename suggestion
    NewFilename:='';
    if (Project1.MainUnitID>=0) then
      NewFileName:=Project1.MainUnitInfo.UnitName;
    if NewFilename='' then
      NewFilename:=ExtractFileName(Project1.ProjectInfoFile);
    if NewFilename='' then
      NewFilename:=ExtractFileName(Project1.MainFilename);
    if NewFilename='' then
      NewFilename:=Trim(Project1.Title);
    if NewFilename='' then
      NewFilename:='project1';
    Ext:=lowercase(ExtractFileExt(NewFilename));
    if (Ext='') or FilenameIsPascalSource(NewFilename) then
      NewFilename:=ChangeFileExt(NewFilename,'.lpi');
    SaveDialog.FileName:=NewFilename;

    NewProgramName:='';     // the pascal program identifier
    NewProgramFilename:=''; // the program source filename
    repeat
      Result:=mrCancel;

      if not SaveDialog.Execute then begin
        // user cancels
        Result:=mrCancel;
        exit;
      end;
      NewFilename:=ExpandFilename(SaveDialog.Filename);
      NewProgramName:=ExtractFileNameOnly(NewFilename);

      // check programname
      if (NewProgramName='') or (not IsValidIdent(NewProgramName)) then begin
        Result:=MessageDlg(lisInvalidProjectFilename,
          Format(lisisAnInvalidProjectNamePleaseChooseAnotherEGProject, ['"',
            SaveDialog.Filename, '"', #13]),
          mtInformation,[mbRetry,mbAbort],0);
        if Result=mrAbort then exit;
        continue; // try again
      end;

      // append default extension
      Ext:=ExtractFileExt(NewFilename);
      if Ext='' then begin
        NewFilename:=NewFilename+'.lpi';
        Ext:='.lpi';
      end;

      // check pascal identifier
      if FilenameIsPascalSource(NewFilename) then begin
        if not IsValidIdent(NewProgramName) then begin
          Result:=MessageDlg(lisInvalidPascalIdentifierCap,
            Format(lisTheNameIsNotAValidPascalIdentifier, ['"', NewProgramName,
              '"'])
            ,mtWarning,[mbIgnore,mbCancel],0);
          if Result=mrCancel then exit;
          Result:=mrCancel;
        end;
      end;

      // apply naming conventions
      NewProgramName:=ExtractFileNameOnly(NewFilename);

      if EnvironmentOptions.CharcaseFileAction = ccfaAutoRename then
        NewFileName:=ExtractFilePath(NewFilename)
                    +lowercase(ExtractFileName(NewFilename));

      if Project1.MainUnitID>=0 then begin
        // check mainunit filename
        Ext:=ExtractFileExt(Project1.MainUnitInfo.Filename);
        if Ext='' then Ext:='.pas';
        NewProgramFilename:=ChangeFileExt(NewFilename,Ext);
        if CompareFilenames(NewFilename,NewProgramFilename)=0 then begin
          ACaption:=lisChooseADifferentName;
          AText:=Format(lisTheProjectInfoFileIsEqualToTheProjectMainSource, [
            '"', NewFilename, '"', #13]);
          Result:=MessageDlg(ACaption, AText, mtError, [mbAbort,mbRetry],0);
          if Result=mrAbort then exit;
          continue; // try again
        end;
        // check programname
        if FilenameIsPascalUnit(NewProgramFilename)
        and (Project1.IndexOfUnitWithName(NewProgramName,true,
                                       Project1.MainUnitInfo)>=0) then
        begin
          ACaption:=lisUnitIdentifierExists;
          AText:=Format(lisThereIsAUnitWithTheNameInTheProjectPlzChoose, ['"',
            NewProgramName, '"', #13]);
          Result:=MessageDlg(ACaption,AText,mtError,[mbRetry,mbAbort],0);
          if Result=mrAbort then exit;
          continue; // try again
        end;
        Result:=mrOk;
      end else begin
        NewProgramFilename:='';
        Result:=mrOk;
      end;
    until Result<>mrRetry;
  finally
    InputHistories.StoreFileDialogSettings(SaveDialog);
    SaveDialog.Free;
  end;

  // check if info file or source file already exists
  if FileExists(NewFilename) then begin
    ACaption:=lisOverwriteFile;
    AText:=Format(lisAFileAlreadyExistsReplaceIt, ['"', NewFilename, '"', #13]);
    Result:=MessageDlg(ACaption, AText, mtConfirmation, [mbOk, mbCancel], 0);
    if Result=mrCancel then exit;
  end
  else begin
    if FileExists(NewProgramFilename) then begin
      ACaption:=lisOverwriteFile;
      AText:=Format(lisAFileAlreadyExistsReplaceIt, ['"', NewProgramFilename,
        '"', #13]);
      Result:=MessageDlg(ACaption, AText, mtConfirmation,[mbOk,mbCancel],0);
      if Result=mrCancel then exit;
    end;
  end;

  // set new project filename
  Project1.ProjectInfoFile:=NewFilename;
  EnvironmentOptions.AddToRecentProjectFiles(NewFilename);
  SetRecentProjectFilesMenu;

  // set new project directory
  if OldProjectPath<>Project1.ProjectDirectory then begin
    CodeToolBoss.GlobalValues.Variables[ExternalMacroStart+'ProjPath']:=
      Project1.ProjectDirectory;
    CodeToolBoss.DefineTree.ClearCache;
  end;

  // change main source
  if (Project1.MainUnitID>=0) then begin
    GetMainUnit(MainUnitInfo,MainUnitSrcEdit,true);

    // switch MainUnitInfo.Source to new code
    NewBuf:=CodeToolBoss.CreateFile(NewProgramFilename);
    if NewBuf=nil then begin
      Result:=MessageDlg(lisErrorCreatingFile, Format(lisUnableToCreateFile3, [
        #13, '"', NewProgramFilename, '"']), mtError, [mbCancel], 0);
      exit;
    end;

    // copy the source to the new buffer
    NewBuf.Source:=MainUnitInfo.Source.Source;

    // assign the new buffer to the MainUnit
    MainUnitInfo.Source:=NewBuf;
    if MainUnitSrcEdit<>nil then
      MainUnitSrcEdit.CodeBuffer:=NewBuf;

    // change program name
    MainUnitInfo.UnitName:=NewProgramName;
    MainUnitInfo.Modified:=true;

    // TODO: rename resource include directive

    // update source notebook page names
    UpdateSourceNames;
  end;

  // invalidate cached substituted macros
  IncreaseCompilerParseStamp;

  Result:=mrOk;
end;

function TMainIDE.DoUpdateLRSFromLFM(const LRSFilename: string): TModalResult;
var
  LFMFilename: String;
begin
  Result:=mrOk;
  // check if there is a .lrs file
  if LRSFilename='' then exit;
  if not FilenameIsAbsolute(LRSFilename) then exit;
  LFMFilename:=ChangeFileExt(LRSFilename,'.lfm');
  if LRSFilename=LFMFilename then exit;
  // check if there is a .lfm file
  if not FileExists(LFMFilename) then exit;
  // check if .lrs file is newer than .lfm file
  if FileExists(LRSFilename) and (FileAge(LFMFilename)<=FileAge(LRSFilename))
  then exit;
  debugln('TMainIDE.DoUpdateLRSFromLFM ',LRSFilename,' ',dbgs(FileAge(LFMFilename)),' ',dbgs(FileAge(LRSFilename)));
  // the .lrs file does not exist, or is older than the .lfm file
  // -> update .lrs file
  Result:=ConvertLFMToLRSFileInteractive(LFMFilename,LRSFilename);
end;

function TMainIDE.DoCompleteLoadingProjectInfo: TModalResult;
begin
  UpdateCaption;
  EnvironmentOptions.LastSavedProjectFile:=Project1.ProjectInfoFile;
  EnvironmentOptions.Save(false);
  RescanCompilerDefines(true);

  // load required packages
  PkgBoss.OpenProjectDependencies(Project1,true);

  Project1.DefineTemplates.AllChanged;
  Result:=mrOk;
end;

procedure TMainIDE.OnCopyFile(const Filename: string; var Copy: boolean;
  Data: TObject);
begin
  if Data=nil then exit;
  if Data is TPublishModuleOptions then begin
    Copy:=TPublishModuleOptions(Data).FileCanBePublished(Filename);
    //writeln('TMainIDE.OnCopyFile "',Filename,'" ',Copy);
  end;
end;

procedure TMainIDE.OnCopyError(const ErrorData: TCopyErrorData;
  var Handled: boolean; Data: TObject);
begin
  case ErrorData.Error of
    ceSrcDirDoesNotExists:
      MessageDlg(lisCopyError2,
        Format(lisSourceDirectoryDoesNotExist, ['"', ErrorData.Param1, '"']),
        mtError,[mbCancel],0);
    ceCreatingDirectory:
      MessageDlg(lisCopyError2,
        Format(lisUnableToCreateDirectory, ['"', ErrorData.Param1, '"']),
        mtError,[mbCancel],0);
    ceCopyFileError:
      MessageDlg(lisCopyError2,
        Format(lisUnableToCopyFileTo, ['"', ErrorData.Param1, '"', #13, '"',
          ErrorData.Param1, '"']),
        mtError,[mbCancel],0);
  end;
end;

function TMainIDE.DoOpenFileInSourceEditor(AnUnitInfo: TUnitInfo;
  PageIndex: integer; Flags: TOpenFlags): TModalResult;
var NewSrcEdit: TSourceEditor;
  AFilename: string;
  NewSrcEditorCreated: boolean;
begin
  AFilename:=AnUnitInfo.Filename;

  // get syntax highlighter type
  if not AnUnitInfo.CustomHighlighter then
    AnUnitInfo.SyntaxHighlighter:=
      ExtensionToLazSyntaxHighlighter(ExtractFileExt(AFilename));

  NewSrcEditorCreated:=false;
  if (not (ofRevert in Flags)) or (PageIndex<0) then begin
    // create a new source editor

    // update marks and cursor positions in Project1, so that merging the old
    // settings during restoration will work
    SaveSourceEditorProjectSpecificSettings;
    SourceNotebook.NewFile(CreateSrcEditPageName(AnUnitInfo.UnitName,
      AFilename,-1),AnUnitInfo.Source,false);
    NewSrcEdit:=SourceNotebook.GetActiveSE;
    NewSrcEdit.EditorComponent.BeginUpdate;
    NewSrcEditorCreated:=true;
    MainIDEBar.itmFileClose.Enabled:=True;
    MainIDEBar.itmFileCloseAll.Enabled:=True;
  end else begin
    // revert code in existing source editor
    NewSrcEdit:=SourceNotebook.FindSourceEditorWithPageIndex(PageIndex);
    NewSrcEdit.EditorComponent.BeginUpdate;
    NewSrcEdit.CodeBuffer:=AnUnitInfo.Source;
    NewSrcEdit.Modified:=false;
    AnUnitInfo.Modified:=false;
  end;

  // update editor indices in project
  if (not (ofProjectLoading in Flags)) and NewSrcEditorCreated then
    Project1.InsertEditorIndex(SourceNotebook.NoteBook.PageIndex);
  AnUnitInfo.EditorIndex:=SourceNotebook.FindPageWithEditor(NewSrcEdit);

  // restore source editor settings
  DoRestoreBookMarks(AnUnitInfo,NewSrcEdit);
  DebugBoss.DoRestoreDebuggerMarks(AnUnitInfo);
  NewSrcEdit.SyntaxHighlighterType:=AnUnitInfo.SyntaxHighlighter;
  NewSrcEdit.EditorComponent.CaretXY:=AnUnitInfo.CursorPos;
  NewSrcEdit.EditorComponent.TopLine:=AnUnitInfo.TopLine;
  NewSrcEdit.EditorComponent.LeftChar:=1;
  NewSrcEdit.ReadOnly:=AnUnitInfo.ReadOnly;

  // mark unit as loaded
  NewSrcEdit.EditorComponent.EndUpdate;
  AnUnitInfo.Loaded:=true;

  // update statusbar and focus editor
  if (not (ofProjectLoading in Flags)) then
    SourceNotebook.FocusEditor;
  SourceNoteBook.UpdateStatusBar;

  Result:=mrOk;
end;

function TMainIDE.DoNewFile(NewFileDescriptor: TProjectFileDescriptor;
  var NewFilename: string; const NewSource: string;
  NewFlags: TNewFlags; NewOwner: TObject): TModalResult;

  function BeautifySrc(const s: string): string;
  begin
    Result:=CodeToolBoss.SourceChangeCache.BeautifyCodeOptions.
                  BeautifyStatement(s,0);
  end;

var
  NewUnitInfo:TUnitInfo;
  NewSrcEdit: TSourceEditor;
  NewUnitName: string;
  NewBuffer: TCodeBuffer;
  OldUnitIndex: Integer;
  AncestorType: TPersistentClass;
  LFMFilename: String;
  SearchFlags: TProjectFileSearchFlags;
  LFMSourceText: String;
  LFMCode: TCodeBuffer;
  AProject: TProject;
begin
  debugln('TMainIDE.DoNewEditorFile A NewFilename=',NewFilename);
  SaveSourceEditorChangesToCodeCache(-1);

  // convert macros in filename
  if nfConvertMacros in NewFlags then begin
    if not MacroList.SubstituteStr(NewFilename) then begin
      Result:=mrCancel;
      exit;
    end;
  end;
  
  if NewOwner is TProject then
    AProject:=TProject(NewOwner)
  else
    AProject:=Project1;

  // create new codebuffer and apply naming conventions
  Result:=CreateNewCodeBuffer(NewFileDescriptor,NewOwner,NewFilename,NewBuffer,
                              NewUnitName);
  if Result<>mrOk then exit;

  NewFilename:=NewBuffer.Filename;
  OldUnitIndex:=AProject.IndexOfFilename(NewFilename);
  if OldUnitIndex>=0 then begin
    // the file is not really new
    NewUnitInfo:=AProject.Units[OldUnitIndex];
    // close form
    CloseDesignerForm(NewUnitInfo);
    // assign source
    NewUnitInfo.Source:=NewBuffer;
  end else
    NewUnitInfo:=TUnitInfo.Create(NewBuffer);
  NewUnitInfo.ImproveUnitNameCache(NewUnitName);

  // create source code
  //debugln('TMainIDE.DoNewEditorFile A nfCreateDefaultSrc=',nfCreateDefaultSrc in NewFlags,' ResourceClass=',dbgs(NewFileDescriptor.ResourceClass));
  if nfCreateDefaultSrc in NewFlags then begin
    if (NewFileDescriptor.ResourceClass<>nil) then begin
      NewUnitInfo.ComponentName:=
        AProject.NewUniqueComponentName(NewFileDescriptor.DefaultResourceName);
      NewUnitInfo.ComponentResourceName:='';
    end;
    NewUnitInfo.CreateStartCode(NewFileDescriptor,NewUnitName);
  end else begin
    if nfBeautifySrc in NewFlags then
      NewBuffer.Source:=BeautifySrc(NewSource)
    else
      NewBuffer.Source:=NewSource;
    NewUnitInfo.Modified:=true;
  end;
  
  // add to project
  with NewUnitInfo do begin
    Loaded:=true;
    IsPartOfProject:=(nfIsPartOfProject in NewFlags)
                     or (NewOwner is TProject)
                     or (AProject.FileIsInProjectDir(NewFilename)
                         and (not (nfIsNotPartOfProject in NewFlags)));
  end;
  if OldUnitIndex<0 then begin
    Project1.AddFile(NewUnitInfo,
                     NewFileDescriptor.AddToProject
                     and NewUnitInfo.IsPartOfProject);
  end;

  // syntax highlighter type
  NewUnitInfo.SyntaxHighlighter:=
    ExtensionToLazSyntaxHighlighter(ExtractFileExt(NewFilename));

  if nfOpenInEditor in NewFlags then begin
    // open a new sourceeditor
    SourceNotebook.NewFile(CreateSrcEditPageName(NewUnitInfo.UnitName,
                                                 NewUnitInfo.Filename,-1),
                           NewUnitInfo.Source,true);
    MainIDEBar.itmFileClose.Enabled:=True;
    MainIDEBar.itmFileCloseAll.Enabled:=True;
    NewSrcEdit:=SourceNotebook.GetActiveSE;
    NewSrcEdit.SyntaxHighlighterType:=NewUnitInfo.SyntaxHighlighter;
    Project1.InsertEditorIndex(SourceNotebook.NoteBook.PageIndex);
    NewUnitInfo.EditorIndex:=SourceNotebook.NoteBook.PageIndex;

    // create component
    AncestorType:=NewFileDescriptor.ResourceClass;
    if AncestorType<>nil then begin
      LFMSourceText:=NewFileDescriptor.GetResourceSource;
      if LFMSourceText<>'' then begin
        // the NewFileDescriptor provides a custom .lfm source
        // -> put it into a new .lfm buffer and load it
        LFMFilename:=ChangeFileExt(NewUnitInfo.Filename,'.lfm');
        LFMCode:=CodeToolBoss.CreateFile(LFMFilename);
        LFMCode.Source:=LFMSourceText;
        //debugln('TMainIDE.DoNewEditorFile A ',LFMFilename);
        Result:=DoLoadLFM(NewUnitInfo,LFMCode,[],false);
      end else begin
        // create a default form/datamodule
        Result:=CreateNewForm(NewUnitInfo,AncestorType,nil);
      end;
      if Result<>mrOk then exit;
    end;

    // show form and select form
    if NewUnitInfo.Component<>nil then begin
      // show form
      DoShowDesignerFormOfCurrentSrc;
    end else begin
      FDisplayState:= dsSource;
    end;

    if nfSave in NewFlags then begin
      NewUnitInfo.Modified:=true;
      Result:=DoSaveEditorFile(NewUnitInfo.EditorIndex,[sfCheckAmbiguousFiles]);
      if Result<>mrOk then exit;
    end;
  end else begin
    // do not open in editor
    if nfSave in NewFlags then begin
      NewBuffer.Save;
    end;
  end;
  
  // Update HasResources property (if the .lfm file was created separately)
  if (not NewUnitInfo.HasResources)
  and FilenameIsPascalUnit(NewUnitInfo.Filename) then begin
    //debugln('TMainIDE.DoNewEditorFile no HasResources ',NewUnitInfo.Filename);
    LFMFilename:=ChangeFileExt(NewUnitInfo.Filename,'.lfm');
    SearchFlags:=[];
    if NewUnitInfo.IsPartOfProject then
      Include(SearchFlags,pfsfOnlyProjectFiles);
    if NewUnitInfo.IsVirtual then
      Include(SearchFlags,pfsfOnlyVirtualFiles);
    if (AProject.UnitInfoWithFilename(LFMFilename,SearchFlags)<>nil) then begin
      //debugln('TMainIDE.DoNewEditorFile no HasResources ',NewUnitInfo.Filename,' ResourceFile exists');
      NewUnitInfo.ResourceFileName:=ChangeFileExt(NewUnitInfo.Filename,'.lrs');
      NewUnitInfo.HasResources:=true;
    end;
  end;

  Result:=mrOk;
  DebugLn('TMainIDE.DoNewEditorFile end ',NewUnitInfo.Filename);
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoNewUnit end');{$ENDIF}
end;

function TMainIDE.DoNewOther: TModalResult;
var
  NewIDEItem: TNewIDEItemTemplate;
begin
  Result:=ShowNewIDEItemDialog(NewIDEItem);
  if Result<>mrOk then exit;
  if NewIDEItem is TNewItemProjectFile then begin
    // file
    Result:=DoNewEditorFile(TNewItemProjectFile(NewIDEItem).Descriptor,
                                   '','',[nfOpenInEditor,nfCreateDefaultSrc]);
  end else if NewIDEItem is TNewItemProject then begin
    // project
    //debugln('TMainIDE.DoNewOther ',dbgsName(TNewItemProject(NewIDEItem).Descriptor));
    Result:=DoNewProject(TNewItemProject(NewIDEItem).Descriptor);
  end else if NewIDEItem is TNewItemPackage then begin
    // packages
    PkgBoss.DoNewPackage;
  end else begin
    MessageDlg(ueNotImplCap,
               lisSorryThisTypeIsNotYetImplemented,
      mtInformation,[mbOk],0);
  end;
end;

function TMainIDE.DoSaveEditorFile(PageIndex:integer;
  Flags: TSaveFlags):TModalResult;
var ActiveSrcEdit:TSourceEditor;
  ActiveUnitInfo:TUnitInfo;
  TestFilename, DestFilename: string;
  ResourceCode, LFMCode: TCodeBuffer;
begin
  {$IFDEF IDE_VERBOSE}
  writeln('TMainIDE.DoSaveEditorFile A PageIndex=',PageIndex,' Flags=',SaveFlagsToString(Flags));
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoSaveEditorFile A');{$ENDIF}
  Result:=mrCancel;
  if not (ToolStatus in [itNone,itDebugger]) then begin
    Result:=mrAbort;
    exit;
  end;
  GetUnitWithPageIndex(PageIndex,ActiveSrcEdit,ActiveUnitInfo);
  if ActiveUnitInfo=nil then exit;

  // check if file is writable on disk
  if (not ActiveUnitInfo.IsVirtual)
  and FileExists(ActiveUnitInfo.Filename) then
    ActiveUnitInfo.FileReadOnly:=not FileIsWritable(ActiveUnitInfo.Filename)
  else
    ActiveUnitInfo.FileReadOnly:=false;

  // if this file is part of the project and the project is virtual then save
  // project first
  if (not (sfProjectSaving in Flags)) and Project1.IsVirtual
  and ActiveUnitInfo.IsPartOfProject then
  begin
    Result:=DoSaveProject(Flags*[sfSaveToTestDir]);
    exit;
  end;

  // update codetools cache and collect Modified flags
  if not (sfProjectSaving in Flags) then
    SaveSourceEditorChangesToCodeCache(-1);

  // if this is a new unit then a simple Save becomes a SaveAs
  if (not (sfSaveToTestDir in Flags)) and (ActiveUnitInfo.IsVirtual) then
    Include(Flags,sfSaveAs);

  // update source notebook page names
  if (not (sfProjectSaving in Flags)) then
    UpdateSourceNames;

  // if file is readonly then a simple Save is skipped
  if (ActiveUnitInfo.ReadOnly) and ([sfSaveToTestDir,sfSaveAs]*Flags=[]) then
  begin
    Result:=mrOk;
    exit;
  end;

  // if nothing modified then a simple Save can be skipped
  //writeln('TMainIDE.DoSaveEditorFile A ',ActiveUnitInfo.Filename,' ',ActiveUnitInfo.NeedsSaveToDisk);
  if ([sfSaveToTestDir,sfSaveAs]*Flags=[])
  and (not ActiveUnitInfo.NeedsSaveToDisk) then begin
    Result:=mrOk;
    exit;
  end;

  // load old resource file
  Result:=DoLoadResourceFile(ActiveUnitInfo,LFMCode,ResourceCode,
                             not (sfSaveAs in Flags));
  if Result in [mrIgnore,mrOk] then
    Result:=mrCancel
  else
    exit;

  if [sfSaveAs,sfSaveToTestDir]*Flags=[sfSaveAs] then begin
    // let user choose a filename
    Result:=DoShowSaveFileAsDialog(ActiveUnitInfo,ResourceCode);
    if Result in [mrIgnore,mrOk] then
      Result:=mrCancel
    else
      exit;
    LFMCode:=nil;
  end;

  // save source
  if not (sfSaveToTestDir in Flags) then begin
    if ActiveUnitInfo.Modified or ActiveUnitInfo.NeedsSaveToDisk then begin
      // save source to file
      Result:=ActiveUnitInfo.WriteUnitSource;
      if Result=mrAbort then exit;
      DestFilename:=ActiveUnitInfo.Filename;
    end;
  end else begin
    // save source to test directory
    TestFilename:=GetTestUnitFilename(ActiveUnitInfo);
    if TestFilename<>'' then begin
      Result:=ActiveUnitInfo.WriteUnitSourceToFile(TestFilename);
      if Result<>mrOk then exit;
      DestFilename:=TestFilename;
    end else
      exit;
  end;

  if sfCheckAmbiguousFiles in Flags then
    DoCheckAmbiguousSources(DestFilename,false);

  {$IFDEF IDE_DEBUG}
  writeln('*** HasResources=',ActiveUnitInfo.HasResources);
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoSaveEditorFile B');{$ENDIF}
  // save resource file and lfm file
  if (ResourceCode<>nil) or (ActiveUnitInfo.Component<>nil) then begin
    Result:=DoSaveFileResources(ActiveUnitInfo,ResourceCode,LFMCode,Flags);
    if Result in [mrIgnore, mrOk] then
      Result:=mrCancel
    else
      exit;
  end;

  // unset all modified flags
  if not (sfSaveToTestDir in Flags) then begin
    ActiveUnitInfo.Modified:=false;
    ActiveSrcEdit.Modified:=false;
    MainIDEBar.SaveSpeedBtn.Enabled := SourceNotebook.GetActiveSe.Modified;
  end;
  SourceNoteBook.UpdateStatusBar;

  {$IFDEF IDE_VERBOSE}
  writeln('TMainIDE.DoSaveEditorFile END');
  {$ENDIF}
  Result:=mrOk;
end;

function TMainIDE.DoCloseEditorFile(PageIndex:integer;
  Flags: TCloseFlags):TModalResult;
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  ACaption,AText: string;
  i:integer;
begin
  debugln('TMainIDE.DoCloseEditorFile A PageIndex=',IntToStr(PageIndex));
  Result:=mrCancel;
  GetUnitWithPageIndex(PageIndex,ActiveSrcEdit,ActiveUnitInfo);
  if ActiveUnitInfo=nil then exit;
  if ActiveUnitInfo.Component=FLastFormActivated then
    FLastFormActivated:=nil;

  // save some meta data of the source
  SaveSrcEditorProjectSpecificSettings(ActiveUnitInfo);

  // if SaveFirst then save the source
  if (cfSaveFirst in Flags) and (not ActiveUnitInfo.ReadOnly)
  and ((ActiveSrcEdit.Modified) or (ActiveUnitInfo.Modified)) then begin
    if ActiveUnitInfo.Filename<>'' then
      AText:=Format(lisFileHasChangedSave, ['"', ActiveUnitInfo.Filename, '"'])
    else if ActiveUnitInfo.UnitName<>'' then
      AText:=Format(lisUnitHasChangedSave, ['"', ActiveUnitInfo.Unitname, '"'])
    else
      AText:=Format(lisSourceOfPageHasChangedSave, ['"',
        ActiveSrcEdit.PageName, '"']);
    ACaption:=lisSourceModified;
    Result:=Messagedlg(ACaption, AText,
                       mtConfirmation, [mbYes, mbNo, mbAbort], 0);
    if Result=mrYes then begin
      Result:=DoSaveEditorFile(PageIndex,[sfCheckAmbiguousFiles]);
    end;
    if Result=mrAbort then exit;
    Result:=mrOk;
  end;

  // close form
  CloseDesignerForm(ActiveUnitInfo);

  // close source editor
  SourceNoteBook.CloseFile(PageIndex);
  MainIDEBar.itmFileClose.Enabled:=SourceNoteBook.NoteBook<>nil;
  MainIDEBar.itmFileCloseAll.Enabled:=MainIDEBar.itmFileClose.Enabled;

  // close file in project
  Project1.CloseEditorIndex(ActiveUnitInfo.EditorIndex);
  ActiveUnitInfo.Loaded:=false;
  i:=Project1.IndexOf(ActiveUnitInfo);
  if (i<>Project1.MainUnitID) and (ActiveUnitInfo.IsVirtual) then begin
    Project1.RemoveUnit(i);
  end;

  DebugLn('TMainIDE.DoCloseEditorFile end');
  Result:=mrOk;
end;

function TMainIDE.DoCloseEditorFile(const Filename: string; Flags: TCloseFlags
  ): TModalResult;
var
  UnitIndex: Integer;
  AnUnitInfo: TUnitInfo;
begin
  Result:=mrOk;
  if Filename='' then exit;
  UnitIndex:=Project1.IndexOfFilename(TrimFilename(Filename),
                                    [pfsfOnlyEditorFiles,pfsfResolveFileLinks]);
  if UnitIndex<0 then exit;
  AnUnitInfo:=Project1.Units[UnitIndex];
  if AnUnitInfo.EditorIndex>=0 then
    Result:=DoCloseEditorFile(AnUnitInfo.EditorIndex,Flags)
  else
    Result:=mrOk;
end;

function TMainIDE.DoOpenEditorFile(AFileName:string;
  PageIndex: integer; Flags: TOpenFlags):TModalResult;
var
  UnitIndex: integer;
  ReOpen, Handled:boolean;
  NewUnitInfo:TUnitInfo;
  NewBuf: TCodeBuffer;
  OtherUnitIndex: Integer;
  FilenameNoPath: String;
  LoadBufferFlags: TLoadBufferFlags;
begin
  {$IFDEF IDE_VERBOSE}
  writeln('');
  writeln('*** TMainIDE.DoOpenEditorFile START "',AFilename,'" ',OpenFlagsToString(Flags));
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoOpenEditorFile START');{$ENDIF}
  Result:=mrCancel;

  // replace macros
  if ofConvertMacros in Flags then begin
    if not MacroList.SubstituteStr(AFilename) then exit;
    AFilename:=ExpandFilename(AFilename);
  end;

  // normalize filename
  AFilename:=TrimFilename(AFilename);
  FilenameNoPath:=ExtractFilename(AFilename);

  // check to not open directories
  if (not (ofRevert in Flags))
  and ((FilenameNoPath='') or (FilenameNoPath='.') or (FilenameNoPath='..'))
  then
    exit;

  if ([ofAddToRecent,ofRevert,ofVirtualFile]*Flags=[ofAddToRecent])
  and (AFilename<>'') and FilenameIsAbsolute(AFilename) then
    EnvironmentOptions.AddToRecentOpenFiles(AFilename);

  // check if this is a hidden unit:
  // if this is the main unit, it is already
  // loaded and needs only to be shown in the sourceeditor/formeditor
  if (not (ofRevert in Flags))
  and (CompareFilenames(Project1.MainFilename,AFilename,
       not (ofVirtualFile in Flags))=0)
  then begin
    Result:=DoOpenMainUnit(ofProjectLoading in Flags);
    exit;
  end;

  // check for special files
  if ([ofRegularFile,ofRevert,ofProjectLoading]*Flags=[])
  and FilenameIsAbsolute(AFilename) and FileExists(AFilename) then begin
    // check if file is a lazarus project (.lpi)
    if (CompareFileExt(AFilename,'.lpi',false)=0) then begin
      if MessageDlg(lisOpenProject,
        Format(lisOpenTheProjectAnswerNoToLoadItAsXmlFile, [AFilename, #13]),
        mtConfirmation,[mbYes,mbNo],0)=mrYes
      then begin
        Result:=DoOpenProjectFile(AFilename,[ofAddToRecent]);
        exit;
      end;
    end;
    // check if file is a lazarus package (.lpk)
    if (CompareFileExt(AFilename,'.lpk',false)=0) then begin
      if MessageDlg(lisOpenPackage,
        Format(lisOpenThePackageAnswerNoToLoadItAsXmlFile, [AFilename, #13]),
        mtConfirmation,[mbYes,mbNo],0)=mrYes
      then begin
        Result:=PkgBoss.DoOpenPackageFile(AFilename,[pofAddToRecent]);
        exit;
      end;
    end;
  end;

  // check if the project knows this file
  if (not (ofRevert in Flags)) then begin
    UnitIndex:=Project1.IndexOfFilename(AFilename);
    ReOpen:=(UnitIndex>=0);
    // check if there is already a symlinked file open in the editor
    OtherUnitIndex:=Project1.IndexOfFilename(AFilename,
                                    [pfsfOnlyEditorFiles,pfsfResolveFileLinks]);
    if (OtherUnitIndex>=0) and (OtherUnitIndex<>UnitIndex) then begin
      // There is another file open in the editor symlinked to the same file
      // ToDo
    end;
    if ReOpen then begin
      NewUnitInfo:=Project1.Units[UnitIndex];
      if (ofAddToProject in Flags) and (not NewUnitInfo.IsPartOfProject) then
      begin
        NewUnitInfo.IsPartOfProject:=true;
        Project1.Modified:=true;
      end;
      if (not (ofProjectLoading in Flags)) and NewUnitInfo.Loaded then begin
        // file already open -> change source notebook page
        SourceNoteBook.NoteBook.PageIndex:=NewUnitInfo.EditorIndex;
        Result:=mrOk;
        exit;
      end;
    end;
  end else begin
    // revert
    NewUnitInfo:=Project1.UnitWithEditorIndex(PageIndex);
    UnitIndex:=Project1.IndexOf(NewUnitInfo);
    AFilename:=NewUnitInfo.Filename;
    if NewUnitInfo.IsVirtual then begin
      if (not (ofQuiet in Flags)) then begin
        MessageDlg(lisRevertFailed, Format(lisFileIsVirtual, ['"', AFilename,
          '"']),
          mtInformation,[mbCancel],0);
      end;
      Result:=mrCancel;
      exit;
    end;
    ReOpen:=true;
    if (ofAddToProject in Flags) and (not NewUnitInfo.IsPartOfProject) then
    begin
      NewUnitInfo.IsPartOfProject:=true;
      Project1.Modified:=true;
    end;
  end;

  // check if file exists
  if FilenameIsAbsolute(AFilename) and (not FileExists(AFilename)) then begin
    // file does not exist
    if (ofRevert in Flags) then begin
      // revert failed, due to missing file
      if not (ofQuiet in Flags) then begin
        MessageDlg(lisRevertFailed, Format(lisPkgMangFileNotFound, ['"',
          AFilename, '"']),
          mtError,[mbCancel],0);
      end;
      Result:=mrCancel;
      exit;
    end else begin
      Result:=DoOpenNotExistingFile(AFilename,Flags);
      exit;
    end;
  end;

  // load the source
  if ReOpen then begin
    // project knows this file => all the meta data is known
    // -> just load the source
    NewUnitInfo:=Project1.Units[UnitIndex];
    LoadBufferFlags:=[lbfCheckIfText];
    if FilenameIsAbsolute(AFilename) then begin
      if (not (ofUseCache in Flags)) then
        Include(LoadBufferFlags,lbfUpdateFromDisk);
      if ofRevert in Flags then
        Include(LoadBufferFlags,lbfRevert);
    end;
    Result:=LoadCodeBuffer(NewBuf,AFileName,LoadBufferFlags);
    if Result<>mrOk then exit;
    NewUnitInfo.Source:=NewBuf;
    NewUnitInfo.Modified:=NewUnitInfo.Source.FileOnDiskNeedsUpdate;
    if FilenameIsPascalUnit(NewUnitInfo.Filename) then
      NewUnitInfo.ReadUnitNameFromSource(false);
  end else begin
    // open unknown file
    Handled:=false;
    Result:=DoOpenUnknownFile(AFilename,Flags,NewUnitInfo,Handled);
    if Result<>mrOk then exit;
    if Handled then exit;
  end;

  // check readonly
  NewUnitInfo.FileReadOnly:=FileExists(NewUnitInfo.Filename)
                            and (not FileIsWritable(NewUnitInfo.Filename));

  {$IFDEF IDE_DEBUG}
  writeln('[TMainIDE.DoOpenEditorFile] B');
  {$ENDIF}
  // open file in source notebook
  Result:=DoOpenFileInSourceEditor(NewUnitInfo,PageIndex,Flags);
  if Result<>mrOk then exit;

  {$IFDEF IDE_DEBUG}
  writeln('[TMainIDE.DoOpenEditorFile] C');
  {$ENDIF}

  // read form data
  if FilenameIsPascalUnit(AFilename) then begin
    // this could be a unit with a form
    if (not Project1.AutoOpenDesignerFormsDisabled)
    and (not (ofDoNotLoadResource in Flags))
    and (EnvironmentOptions.AutoCreateFormsOnOpen
         or (NewUnitInfo.Component<>nil))
    then begin
      // -> try to (re)load the lfm file
      Result:=DoLoadLFM(NewUnitInfo,Flags);
      if Result<>mrOk then exit;
    end;
  end else if NewUnitInfo.Component<>nil then begin
    // this is no pascal source and there is a designer form
    // This can be the case, when the file is renamed and reverted
    // -> close form
    CloseDesignerForm(NewUnitInfo);
  end;

  Result:=mrOk;
  //writeln('TMainIDE.DoOpenEditorFile END "',AFilename,'"');
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoOpenEditorFile END');{$ENDIF}
end;

function TMainIDE.DoOpenMainUnit(ProjectLoading: boolean): TModalResult;
var MainUnitInfo: TUnitInfo;
  OpenFlags: TOpenFlags;
begin
  {$IFDEF IDE_VERBOSE}
  debugln('[TMainIDE.DoOpenMainUnit] A ProjectLoading=',BoolToStr(ProjectLoading),' MainUnitID=',IntToStr(Project1.MainUnitID));
  {$ENDIF}
  Result:=mrCancel;
  if Project1.MainUnitID<0 then exit;
  MainUnitInfo:=Project1.MainUnitInfo;

  // check if main unit is already open in source editor
  if (MainUnitInfo.EditorIndex>=0) and (not ProjectLoading) then begin
    // already loaded -> switch to source editor
    SourceNotebook.NoteBook.PageIndex:=MainUnitInfo.EditorIndex;
    Result:=mrOk;
    exit;
  end;

  // open file in source notebook
  OpenFlags:=[];
  if ProjectLoading then Include(OpenFlags,ofProjectLoading);
  Result:=DoOpenFileInSourceEditor(MainUnitInfo,-1,OpenFlags);
  if Result<>mrOk then exit;

  Result:=mrOk;
  {$IFDEF IDE_VERBOSE}
  writeln('[TMainIDE.DoOpenMainUnit] END');
  {$ENDIF}
end;

function TMainIDE.DoRevertMainUnit: TModalResult;
begin
  Result:=mrOk;
  if Project1.MainUnitID<0 then exit;
  if Project1.MainUnitInfo.EditorIndex>=0 then
    // main unit is loaded, so we can just revert
    Result:=DoOpenEditorFile('',Project1.MainUnitInfo.EditorIndex,[ofRevert])
  else begin
    // main unit is only loaded in background
    // -> just reload the source and update the source name
    Result:=Project1.MainUnitInfo.ReadUnitSource(true,true);
  end;
end;

function TMainIDE.DoViewUnitsAndForms(OnlyForms: boolean): TModalResult;
var UnitList: TList;
  i: integer;
  MainUnitName, DlgCaption: string;
  MainUnitInfo, AnUnitInfo: TUnitInfo;
  ActiveSourceEditor: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  AForm: TCustomForm;
Begin
  GetCurrentUnit(ActiveSourceEditor,ActiveUnitInfo);
  UnitList:=TList.Create;
  try
    for i:=0 to Project1.UnitCount-1 do begin
      if not Project1.Units[i].IsPartOfProject then continue;
      //debugln('TMainIDE.DoViewUnitsAndForms OnlyForms=',dbgs(OnlyForms),' CompName=',Project1.Units[i].ComponentName,' UnitName=',Project1.Units[i].UnitName);
      if OnlyForms then begin
        // add all form names of project
        if Project1.Units[i].ComponentName<>'' then begin
          UnitList.Add(TViewUnitsEntry.Create(
            Project1.Units[i].ComponentName,i,Project1.Units[i]=ActiveUnitInfo));
        end;
      end else begin
        // add all unit names of project
        if (Project1.Units[i].UnitName<>'') then begin
          UnitList.Add(TViewUnitsEntry.Create(
            Project1.Units[i].UnitName,i,Project1.Units[i]=ActiveUnitInfo));
        end else if Project1.MainUnitID=i then begin
          MainUnitInfo:=Project1.MainUnitInfo;
          if pfMainUnitIsPascalSource in Project1.Flags then begin
            MainUnitName:=CreateSrcEditPageName('',
              MainUnitInfo.Filename,MainUnitInfo.EditorIndex);
            if MainUnitName<>'' then begin
              UnitList.Add(TViewUnitsEntry.Create(
                MainUnitName,i,MainUnitInfo=ActiveUnitInfo));
            end;
          end;
        end;
      end;
    end;
    if OnlyForms then
      DlgCaption:=dlgMainViewForms
    else
      DlgCaption:=dlgMainViewUnits ;
    if ShowViewUnitsDlg(UnitList,true,DlgCaption)=mrOk then begin
      AnUnitInfo:=nil;
      for i:=0 to UnitList.Count-1 do begin
        if TViewUnitsEntry(UnitList[i]).Selected then begin
          AnUnitInfo:=Project1.Units[TViewUnitsEntry(UnitList[i]).ID];
          if AnUnitInfo.EditorIndex>=0 then begin
            SourceNoteBook.NoteBook.PageIndex:=AnUnitInfo.EditorIndex;
          end else begin
            if Project1.MainUnitInfo=AnUnitInfo then
              Result:=DoOpenMainUnit(false)
            else
              Result:=DoOpenEditorFile(AnUnitInfo.Filename,-1,[ofOnlyIfExists]);
            if Result=mrAbort then exit;
          end;
          if OnlyForms and (AnUnitInfo.ComponentName<>'') then begin
            AForm:=GetFormOfSource(AnUnitInfo,true);
            if AForm<>nil then
              ShowDesignerForm(AForm);
          end;
        end;
      end;
      if (AnUnitInfo<>nil) and (not OnlyForms) then begin
        SourceNotebook.ShowOnTop;
      end;
    end;
  finally
    for i:=0 to UnitList.Count-1 do
      TViewUnitsEntry(UnitList[i]).Free;
    UnitList.Free;
  end;
  Result:=mrOk;
end;

procedure TMainIDE.DoViewUnitDependencies;
var
  WasVisible: boolean;
  ALayout: TIDEWindowLayout;
begin
  if UnitDependenciesView=nil then begin
    UnitDependenciesView:=TUnitDependenciesView.Create(OwningComponent);
    UnitDependenciesView.OnAccessingSources:=
      @UnitDependenciesViewAccessingSources;
    UnitDependenciesView.OnGetProjectMainFilename:=
      @UnitDependenciesViewGetProjectMainFilename;
    UnitDependenciesView.OnOpenFile:=@UnitDependenciesViewOpenFile;
    WasVisible:=false;
  end else
    WasVisible:=UnitDependenciesView.Visible;

  if not UnitDependenciesView.RootValid then begin
    if Project1.MainUnitID>=0 then begin
      UnitDependenciesView.RootFilename:=Project1.MainUnitInfo.Filename;
      UnitDependenciesView.RootShortFilename:=
        ExtractFilename(Project1.MainUnitInfo.Filename);
    end;
  end;

  UnitDependenciesView.Show;
  ALayout:=EnvironmentOptions.IDEWindowLayoutList.
    ItemByEnum(nmiwUnitDependenciesName);
  ALayout.Apply;
  if not WasVisible then
    UnitDependenciesView.ShowOnTop;
end;

procedure TMainIDE.DoViewUnitInfo;
var ActiveSrcEdit:TSourceEditor;
  ActiveUnitInfo:TUnitInfo;
  ShortUnitName, AFilename, FileDir: string;
  ClearIncludedByFile: boolean;
begin
  GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
  if (ActiveSrcEdit=nil) or (ActiveUnitInfo=nil) then exit;
  ShortUnitName:=ActiveSrcEdit.PageName;
  AFilename:=ActiveUnitInfo.Filename;
  FileDir:=ExtractFilePath(AFilename);
  ShowUnitInfoDlg(ShortUnitName,
    LazSyntaxHighlighterNames[ActiveUnitInfo.SyntaxHighlighter],
    ActiveUnitInfo.IsPartOfProject, length(ActiveSrcEdit.Source.Text),
    ActiveSrcEdit.Source.Count,
    Project1.RemoveProjectPathFromFilename(AFilename),
    Project1.RemoveProjectPathFromFilename(ActiveUnitInfo.Source.LastIncludedByFile),
    ClearIncludedByFile,
    TrimSearchPath(CodeToolBoss.GetUnitPathForDirectory(FileDir),FileDir),
    TrimSearchPath(CodeToolBoss.GetIncludePathForDirectory(FileDir),FileDir),
    TrimSearchPath(CodeToolBoss.GetSrcPathForDirectory(FileDir),FileDir)
    );
  if ClearIncludedByFile then
    ActiveUnitInfo.Source.LastIncludedByFile:='';
end;

procedure TMainIDE.DoShowCodeExplorer;
begin
  if CodeExplorerView=nil then begin
    CodeExplorerView:=TCodeExplorerView.Create(OwningComponent);
    CodeExplorerView.OnGetCodeTree:=@OnCodeExplorerGetCodeTree;
    CodeExplorerView.OnJumpToCode:=@OnCodeExplorerJumpToCode;
  end;

  EnvironmentOptions.IDEWindowLayoutList.ItemByEnum(nmiwCodeExplorerName).Apply;
  CodeExplorerView.ShowOnTop;
  CodeExplorerView.Refresh;
end;

function TMainIDE.CreateNewUniqueFilename(const Prefix, Ext: string;
  NewOwner: TObject; Flags: TSearchIDEFileFlags; TryWithoutNumber: boolean): string;
  
  function FileIsUnique(const ShortFilename: string): boolean;
  begin
    Result:=false;

    // search in NewOwner
    if NewOwner<>nil then begin
      if (NewOwner is TProject) then begin
        if TProject(NewOwner).SearchFile(ShortFilename,Flags)<>nil then exit;
      end;
    end;
    
    // search in all packages
    if PkgBoss.SearchFile(ShortFilename,Flags,NewOwner)<>nil then exit;
    
    // search in current project
    if (NewOwner<>Project1)
    and (Project1.SearchFile(ShortFilename,Flags)<>nil) then exit;

    // search file in all loaded projects
    if (siffCheckAllProjects in Flags) then begin
    end;

    Result:=true;
  end;
  
var
  i: Integer;
  WorkingPrefix: String;
begin
  if TryWithoutNumber then begin
    Result:=Prefix+Ext;
    if FileIsUnique(Result) then exit;
  end;
  // remove number at end of Prefix
  WorkingPrefix:=ChompEndNumber(Prefix);
  i:=0;
  repeat
    inc(i);
    Result:=WorkingPrefix+IntToStr(i)+Ext;
  until FileIsUnique(Result);
end;

function TMainIDE.DoSaveStringToFile(const Filename, Src,
  FileDescription: string): TModalResult;
var
  fs: TFileStream;
begin
  try
    ClearFile(Filename,true);
    InvalidateFileStateCache;
    fs:=TFileStream.Create(Filename,fmCreate);
    try
      if Src<>'' then
        fs.Write(Src[1],length(Src));
    finally
      fs.Free;
    end;
  except
    on E: Exception do begin
      Result:=MessageDlg(lisPkgMangErrorWritingFile,
        Format(lisUnableToWrite, [FileDescription, #13, '"', Filename, '"']),
        mtError,[mbCancel,mbAbort],0);
      exit;
    end;
  end;
  Result:=mrOk;
end;

function TMainIDE.LoadIDECodeBuffer(var ACodeBuffer: TCodeBuffer;
  const AFilename: string; Flags: TLoadBufferFlags): TModalResult;
begin
  if Project1.UnitInfoWithFilename(AFilename,[pfsfOnlyEditorFiles])<>nil then
    Exclude(Flags,lbfUpdateFromDisk);
  Result:=LoadCodeBuffer(ACodeBuffer,AFilename,Flags);
end;

function TMainIDE.DoOpenFileAtCursor(Sender: TObject):TModalResult;
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  FName,SPath: String;

  function FindFile(var FName: String; SPath: String): Boolean;
  //  Searches for FName in SPath
  //  If FName is not found, we'll check extensions pp and pas too
  //  Returns true if found. FName contains the full file+path in that case
  var TempFile,TempPath,CurPath,FinalFile, Ext: String;
      i,p,c: Integer;
  begin
    if SPath='' then SPath:='.';
    Result:=true;
    TempPath:=SPath;
    while TempPath<>'' do begin
      p:=pos(';',TempPath);
      if p=0 then p:=length(TempPath)+1;
      CurPath:=copy(TempPath,1,p-1);
      Delete(TempPath,1,p);
      if CurPath='' then continue;
      CurPath:=AppendPathDelim(CurPath);
      if not FilenameIsAbsolute(CurPath) then begin
        if ActiveUnitInfo.IsVirtual then
          CurPath:=AppendPathDelim(Project1.ProjectDirectory)+CurPath
        else
          CurPath:=AppendPathDelim(ExtractFilePath(ActiveUnitInfo.Filename))
                   +CurPath;
      end;
      for c:=0 to 2 do begin
        // FPC searches first lowercase, then keeping case, then uppercase
        case c of
          0: TempFile:=LowerCase(FName);
          1: TempFile:=FName;
          2: TempFile:=UpperCase(FName);
        end;
        if ExtractFileExt(TempFile)='' then begin
          for i:=0 to 2 do begin
            case i of
              1: Ext:='.pp';
              2: Ext:='.pas';
              else Ext:='';
            end;
            FinalFile:=ExpandFileName(CurPath+TempFile+Ext);
            if FileExists(FinalFile) then begin
              FName:=FinalFile;
              exit;
            end;
          end;
        end else begin
          FinalFile:=ExpandFileName(CurPath+TempFile);
          if FileExists(FinalFile) then begin
            FName:=FinalFile;
            exit;
          end;
        end;
      end;
    end;
    Result:=false;
  end;

  function CheckIfIncludeDirectiveInFront(const Line: string;
    X: integer): boolean;
  var
    DirectiveEnd, DirectiveStart: integer;
    Directive: string;
  begin
    Result:=false;
    DirectiveEnd:=X;
    while (DirectiveEnd>1) and (Line[DirectiveEnd-1] in [' ',#9]) do
      dec(DirectiveEnd);
    DirectiveStart:=DirectiveEnd-1;
    while (DirectiveStart>0) and (Line[DirectiveStart]<>'$') do
      dec(DirectiveStart);
    Directive:=uppercase(copy(Line,DirectiveStart,DirectiveEnd-DirectiveStart));
    if (Directive='$INCLUDE') or (Directive='$I') then begin
      if ((DirectiveStart>1) and (Line[DirectiveStart-1]='{'))
      or ((DirectiveStart>2)
        and (Line[DirectiveStart-2]='(') and (Line[DirectiveStart-1]='*'))
      then begin
        Result:=true;
      end;
    end;
  end;

  function GetFilenameAtRowCol(XY: TPoint;
    var IsIncludeDirective: boolean): string;
  var
    Line: string;
    Len, Stop: integer;
    StopChars: set of char;
  begin
    Result := '';
    IsIncludeDirective:=false;
    if (XY.Y >= 1) and (XY.Y <= ActiveSrcEdit.EditorComponent.Lines.Count) then
    begin
      Line := ActiveSrcEdit.EditorComponent.Lines.Strings[XY.Y - 1];
      Len := Length(Line);
      if (XY.X >= 1) and (XY.X <= Len + 1) then begin
        StopChars := [',',';',':','[',']','{','}','(',')',' ','''','"','`'
                     ,'#','%','=','>'];
        Stop := XY.X;
        while (Stop <= Len) and (not (Line[Stop] in StopChars)) do
          Inc(Stop);
        while (XY.X > 1) and (not (Line[XY.X - 1] in StopChars)) do
          Dec(XY.X);
        if Stop > XY.X then begin
          Result := Copy(Line, XY.X, Stop - XY.X);
          IsIncludeDirective:=CheckIfIncludeDirectiveInFront(Line,XY.X);
        end;
      end;
    end;
  end;

var IsIncludeDirective: boolean;
begin
  Result:=mrCancel;
  GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
  if (ActiveSrcEdit=nil) or (ActiveUnitInfo=nil) then exit;

  // parse filename at cursor
  IsIncludeDirective:=false;
  FName:=GetFilenameAtRowCol(ActiveSrcEdit.EditorComponent.LogicalCaretXY,
                             IsIncludeDirective);
  if FName='' then exit;

  // get searchpath for directory of current file
  if ActiveUnitInfo.IsVirtual then
    SPath:='.'
  else begin
    if IsIncludeDirective then
      SPath:='.;'+CodeToolBoss.DefineTree.GetIncludePathForDirectory(
                            ExtractFilePath(ActiveUnitInfo.Filename))
    else
      SPath:='.;'+CodeToolBoss.DefineTree.GetUnitPathForDirectory(
                            ExtractFilePath(ActiveUnitInfo.Filename))
             +';'+CodeToolBoss.DefineTree.GetSrcPathForDirectory(
                            ExtractFilePath(ActiveUnitInfo.Filename));
  end;

  // search file in path (search especially for pascal files)
  if FindFile(FName,SPath) then begin
    Result:=mrOk;
    InputHistories.FileDialogSettings.InitialDir:=ExtractFilePath(FName);
    if DoOpenEditorFile(FName,-1,[ofAddToRecent])=mrOk then begin
    end;
  end;
end;

function TMainIDE.DoOpenFileAndJumpToIdentifier(const AFilename,
  AnIdentifier: string; PageIndex: integer; Flags: TOpenFlags): TModalResult;
var
  ActiveUnitInfo: TUnitInfo;
  ActiveSrcEdit: TSourceEditor;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
begin
  Result:=DoOpenEditorFile(AFilename, PageIndex, Flags);
  if Result<>mrOk then exit;
  Result:=mrCancel;
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  if CodeToolBoss.FindDeclarationInInterface(ActiveUnitInfo.Source,
    AnIdentifier,NewSource, NewX, NewY, NewTopLine)
  then begin
    DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
                    NewSource, NewX, NewY, NewTopLine, true);
    Result:=mrOk;
  end else
    DoJumpToCodeToolBossError;
end;

function TMainIDE.DoNewProject(ProjectDesc: TProjectDescriptor):TModalResult;
var i:integer;
Begin
  DebugLn('TMainIDE.DoNewProject A');
  
  // init the descriptor (it can now ask the user for options)
  Result:=ProjectDesc.InitDescriptor;
  if Result<>mrOk then exit;

  // invalidate cached substituted macros
  IncreaseCompilerParseStamp;

  // close current project first
  If Project1<>nil then begin
    if SomethingOfProjectIsModified then begin
      Result:=MessageDlg(lisProjectChanged, Format(lisSaveChangesToProject,
       [Project1.Title]),
        mtconfirmation, [mbYes, mbNo, mbAbort], 0);
      if Result=mrYes then begin
        Result:=DoSaveProject([]);
        if Result=mrAbort then exit;
      end else if Result in [mrCancel,mrAbort] then
        exit;
    end;
    Result:=DoCloseProject;
    if Result=mrAbort then exit;
  end;

  // create a virtual project (i.e. unsaved and without real project directory)

  // switch codetools to virtual project directory
  CodeToolBoss.GlobalValues.Variables[ExternalMacroStart+'ProjPath']:=
    VirtualDirectory;

  // create new project (TProject will automatically create the mainunit)

  Project1:=CreateProjectObject(ProjectDesc,ProjectDescriptorProgram);
  Project1.BeginUpdate(true);
  try
    Project1.CompilerOptions.CompilerPath:='$(CompPath)';
    UpdateCaption;
    if ProjInspector<>nil then ProjInspector.LazProject:=Project1;

    // add and load default required packages
    PkgBoss.AddDefaultDependencies(Project1);

    if ProjectDesc.CreateStartFiles(Project1)<>mrOk then begin
      debugln('TMainIDE.DoNewProject ProjectDesc.CreateStartFiles failed');
    end;

    // rebuild codetools defines
    RescanCompilerDefines(true);
    // (i.e. remove old project specific things and create new)
    IncreaseCompilerParseStamp;
    Project1.DefineTemplates.AllChanged;
  finally
    Project1.EndUpdate;
  end;

  // set all modified to false
  for i:=0 to Project1.UnitCount-1 do
    Project1.Units[i].Modified:=false;
  Project1.Modified:=false;

  DebugLn('TMainIDE.DoNewProject end ');
  Result:=mrOk;
end;

function TMainIDE.DoSaveProject(Flags: TSaveFlags):TModalResult;
var
  MainUnitSrcEdit: TSourceEditor;
  MainUnitInfo: TUnitInfo;
  i: integer;
  DestFilename: string;
  SkipSavingMainSource: Boolean;
  AnUnitInfo: TUnitInfo;
begin
  Result:=mrCancel;
  if not (ToolStatus in [itNone,itDebugger]) then begin
    Result:=mrAbort;
    exit;
  end;
  SaveSourceEditorChangesToCodeCache(-1);
  SkipSavingMainSource:=false;


  {$IFDEF IDE_DEBUG}
  writeln('TMainIDE.DoSaveProject A SaveAs=',sfSaveAs in Flags,' SaveToTestDir=',sfSaveToTestDir in Flags,' ProjectInfoFile=',Project1.ProjectInfoFile);
  {$ENDIF}
  
  // check that all new units are saved first to get valid filenames
  // (this can alter the mainunit: e.g. used unit names)
  for i:=0 to Project1.UnitCount-1 do begin
    AnUnitInfo:=Project1.Units[i];
    if (AnUnitInfo.Loaded) and (AnUnitInfo.IsVirtual)
    and (Project1.MainUnitID<>i) then begin
      Result:=DoSaveEditorFile(AnUnitInfo.EditorIndex,
           [sfSaveAs,sfProjectSaving]
           +[sfSaveToTestDir,sfCheckAmbiguousFiles]*Flags);
      if (Result=mrAbort) or (Result=mrCancel) then exit;
    end;
  end;

  if SourceNotebook.Notebook=nil then
    Project1.ActiveEditorIndexAtStart:=-1
  else
    Project1.ActiveEditorIndexAtStart:=SourceNotebook.Notebook.PageIndex;

  // update source notebook page names
  UpdateSourceNames;

  // find mainunit
  GetMainUnit(MainUnitInfo,MainUnitSrcEdit,true);

  // save project specific settings of the source editor
  SaveSourceEditorProjectSpecificSettings;

  if Project1.IsVirtual then Include(Flags,sfSaveAs);
  if ([sfSaveAs,sfSaveToTestDir]*Flags=[sfSaveAs]) then begin
    // let user choose a filename
    Result:=DoShowSaveProjectAsDialog;
    if Result<>mrOk then exit;
  end;
  
  // update HasResources information
  DoUpdateProjectResourceInfo;

  // save project info file
  if not (sfSaveToTestDir in Flags) then begin
    Result:=Project1.WriteProject([],'');
    if Result=mrAbort then exit;
    EnvironmentOptions.LastSavedProjectFile:=Project1.ProjectInfoFile;
    IDEProtocolOpts.LastProjectLoadingCrashed := False;
    AddRecentProjectFileToEnvironment(Project1.ProjectInfoFile);
    SaveIncludeLinks;
    UpdateCaption;
    if Result=mrAbort then exit;
  end;

  // save main source
  if MainUnitInfo<>nil then begin
    if MainUnitInfo.Loaded then begin
      // loaded in source editor
      Result:=DoSaveEditorFile(MainUnitInfo.EditorIndex,
               [sfProjectSaving]+[sfSaveToTestDir,sfCheckAmbiguousFiles]*Flags);
      if Result=mrAbort then exit;
    end else begin
      // not loaded in source editor (hidden)
      if not (sfSaveToTestDir in Flags) then begin
        DestFilename:=MainUnitInfo.Filename;
        if not MainUnitInfo.NeedsSaveToDisk then
          SkipSavingMainSource:=true;
      end else
        DestFilename:=GetTestUnitFilename(MainUnitInfo);
      if not SkipSavingMainSource then begin
        Result:=DoSaveCodeBufferToFile(MainUnitInfo.Source, DestFilename,
                                       not (sfSaveToTestDir in Flags));
        if Result=mrAbort then exit;
      end;
    end;
    // clear modified flags
    if not (sfSaveToTestDir in Flags) then begin
      if (Result=mrOk) then begin
        if MainUnitInfo<>nil then MainUnitInfo.Modified:=false;
        if MainUnitSrcEdit<>nil then MainUnitSrcEdit.Modified:=false;
      end;
    end;
  end;

  // save all editor files
  if (SourceNoteBook.Notebook<>nil) and (not (sfSaveToTestDir in Flags)) then
  begin
    for i:=0 to SourceNoteBook.Notebook.PageCount-1 do begin
      if (Project1.MainUnitID<0)
      or (Project1.MainUnitInfo.EditorIndex<>i) then begin
        Result:=DoSaveEditorFile(i,[sfProjectSaving]
                                +[sfSaveToTestDir,sfCheckAmbiguousFiles]*Flags);
        if Result=mrAbort then exit;
      end;
    end;
  end;
  
  // update all lrs files
  DoUpdateProjectAutomaticFiles;

  DebugLn('TMainIDE.DoSaveProject End');
end;

function TMainIDE.DoCloseProject: TModalResult;
begin
  {$IFDEF IDE_VERBOSE}
  writeln('TMainIDE.DoCloseProject A');
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoCloseProject A');{$ENDIF}
  Result:=DebugBoss.DoStopProject;
  if Result<>mrOk then begin
    debugln('TMainIDE.DoCloseProject DebugBoss.DoStopProject failed');
    exit;
  end;
  // close all loaded files
  while SourceNotebook.NoteBook<>nil do begin
    Result:=DoCloseEditorFile(SourceNotebook.Notebook.PageCount-1,
                              [cfProjectClosing]);
    if Result=mrAbort then exit;
  end;
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoCloseProject B');{$ENDIF}
  IncreaseCompilerParseStamp;
  // close Project
  if ProjInspector<>nil then ProjInspector.LazProject:=nil;
  FreeThenNil(Project1);
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoCloseProject C');{$ENDIF}
  Result:=mrOk;
  {$IFDEF IDE_VERBOSE}
  writeln('TMainIDE.DoCloseProject end ',CodeToolBoss.ConsistencyCheck);
  {$ENDIF}
end;

function TMainIDE.DoOpenProjectFile(AFileName: string;
  Flags: TOpenFlags): TModalResult;
var Ext,AText,ACaption: string;
  LowestEditorIndex,LowestUnitIndex,LastEditorIndex,i: integer;
  NewBuf: TCodeBuffer;
  LastDesigner: TDesigner;
  AnUnitInfo: TUnitInfo;
begin
  {$IFDEF IDE_VERBOSE}
  writeln('TMainIDE.DoOpenProjectFile A "'+AFileName+'"');
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoOpenProjectFile A');{$ENDIF}
  Result:=mrCancel;
  if ExtractFileNameOnly(AFileName)='' then exit;

  AFilename:=ExpandFileName(TrimFilename(AFilename));
  Ext:=lowercase(ExtractFileExt(AFilename));

  // check if file exists
  if not FileExists(AFilename) then begin
    ACaption:=lisFileNotFound;
    AText:=Format(lisPkgMangFileNotFound, ['"', AFilename, '"']);
    Result:=MessageDlg(ACaption, AText, mtError, [mbAbort], 0);
    exit;
  end;

  // if there is a project info file, load that instead
  if (Ext<>'.lpi') and (FileExists(ChangeFileExt(AFileName,'.lpi'))) then begin
    // load instead of program file the project info file
    AFileName:=ChangeFileExt(AFileName,'.lpi');
    Ext:='.lpi';
  end;

  if (not FileIsText(AFilename)) then begin
    ACaption:=lisFileNotText;
    AText:=Format(lisFileDoesNotLookLikeATextFileOpenItAnyway, ['"', AFilename,
      '"', #13, #13]);
    Result:=MessageDlg(ACaption, AText, mtConfirmation, [mbYes, mbAbort], 0);
    if Result=mrAbort then exit;
  end;

  if ofAddToRecent in Flags then
    AddRecentProjectFileToEnvironment(AFileName);

  // close the old project
  if SomethingOfProjectIsModified then begin
    if MessageDlg(lisProjectChanged,
      Format(lisSaveChangesToProject, [Project1.Title]),
      mtconfirmation,[mbYes, mbNo, mbCancel],0) = mrYes then
    begin
      if DoSaveProject([])=mrAbort then begin
        Result:=mrAbort;
        exit;
      end;
    end;
  end;
  Result:=DoCloseProject;
  if Result=mrAbort then exit;

  // create a new project
  {$IFDEF IDE_VERBOSE}
  writeln('TMainIDE.DoOpenProjectFile B');
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoOpenProjectFile B');{$ENDIF}
  Project1:=CreateProjectObject(ProjectDescriptorProgram,
                                ProjectDescriptorProgram);
  Project1.BeginUpdate(true);
  try
    if ProjInspector<>nil then ProjInspector.LazProject:=Project1;

    // read project info file
    {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoOpenProjectFile B3');{$ENDIF}
    Project1.ReadProject(AFilename);
    {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoOpenProjectFile B4');{$ENDIF}
    Result:=DoCompleteLoadingProjectInfo;
  finally
    Project1.EndUpdate;
  end;
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoOpenProjectFile B5');{$ENDIF}
  if Result<>mrOk then exit;

  if Project1.MainUnitID>=0 then begin
    // read MainUnit Source
    Result:=LoadCodeBuffer(NewBuf,Project1.MainFilename,
                             [lbfUpdateFromDisk,lbfRevert,lbfCheckIfText]);
    if Result=mrIgnore then Result:=mrAbort;
    if Result=mrAbort then exit;
    Project1.MainUnitInfo.Source:=NewBuf;
  end;
  {$IFDEF IDE_DEBUG}
  writeln('TMainIDE.DoOpenProjectFile C');
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoOpenProjectFile C');{$ENDIF}
  IncreaseCompilerParseStamp;

  // restore files
  LastEditorIndex:=-1;
  repeat
    // find the unit which was loaded last time and has the lowest editor index
    // of all not opened units
    LowestUnitIndex:=-1;
    LowestEditorIndex:=-1;
    for i:=0 to Project1.UnitCount-1 do begin
      AnUnitInfo:=Project1.Units[i];
      if (AnUnitInfo.Loaded)
      and (SourceNotebook.FindSourceEditorWithFilename(AnUnitInfo.Filename)=nil)
      then begin
        if (AnUnitInfo.EditorIndex>LastEditorIndex)
        and ((AnUnitInfo.EditorIndex<LowestEditorIndex)
             or (LowestEditorIndex<0)) then
        begin
          LowestEditorIndex:=AnUnitInfo.EditorIndex;
          LowestUnitIndex:=i;
        end;
      end;
    end;
    if LowestEditorIndex<0 then break;

    // reopen file
    Result:=DoOpenEditorFile(Project1.Units[LowestUnitIndex].Filename,-1,
                  [ofProjectLoading,ofMultiOpen,ofOnlyIfExists]);
    if Result=mrAbort then begin
      // mark all files, that are left to open as unloaded:
      for i:=0 to Project1.UnitCount-1 do begin
        AnUnitInfo:=Project1.Units[i];
        if AnUnitInfo.Loaded
        and (AnUnitInfo.EditorIndex>LastEditorIndex) then begin
          AnUnitInfo.Loaded:=false;
          AnUnitInfo.EditorIndex:=-1;
          Project1.ActiveEditorIndexAtStart:=-1;
        end;
      end;
      exit;
    end;
    AnUnitInfo:=Project1.Units[LowestUnitIndex];
    if ((AnUnitInfo.Filename<>'')
    and (SourceNotebook.FindSourceEditorWithFilename(AnUnitInfo.Filename)<>nil))
    then begin
      // open source was successful (at least the source)
      if Project1.ActiveEditorIndexAtStart=LowestEditorIndex then
        Project1.ActiveEditorIndexAtStart:=SourceNoteBook.NoteBook.PageIndex;
      LastEditorIndex:=LowestEditorIndex;
    end else begin
      // failed to open entirely -> mark as unloaded, so that next time
      // it will not be tried again
      AnUnitInfo.EditorIndex:=-1;
      AnUnitInfo.Loaded:=false;
      if Project1.ActiveEditorIndexAtStart=LowestEditorIndex then
        Project1.ActiveEditorIndexAtStart:=-1;
    end;
  until LowestEditorIndex<0;
  Result:=mrCancel;
  {$IFDEF IDE_DEBUG}
  writeln('TMainIDE.DoOpenProjectFile D');
  {$ENDIF}

  // set active editor source editor
  if (SourceNoteBook.NoteBook<>nil) and (Project1.ActiveEditorIndexAtStart>=0)
  and (Project1.ActiveEditorIndexAtStart<SourceNoteBook.NoteBook.PageCount)
  then
    SourceNoteBook.Notebook.PageIndex:=Project1.ActiveEditorIndexAtStart;

  // select a form (object inspector, formeditor, control selection)
  if FLastFormActivated<>nil then begin
    LastDesigner:=TDesigner(FLastFormActivated.Designer);
    LastDesigner.SelectOnlyThisComponent(LastDesigner.LookupRoot);
  end;

  // set all modified to false
  for i:=0 to Project1.UnitCount-1 do begin
    Project1.Units[i].Modified:=false;
  end;
  Project1.Modified:=false;

  IncreaseCompilerParseStamp;
  IDEProtocolOpts.LastProjectLoadingCrashed := False;
  Result:=mrOk;
  {$IFDEF IDE_VERBOSE}
  debugln('TMainIDE.DoOpenProjectFile end  CodeToolBoss.ConsistencyCheck=',CodeToolBoss.ConsistencyCheck);
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoOpenProjectFile end');{$ENDIF}
end;

function TMainIDE.DoPublishProject(Flags: TSaveFlags;
  ShowDialog: boolean): TModalResult;
begin
  // show the publish project dialog
  if ShowDialog then begin
    Result:=ShowPublishProjectDialog(Project1.PublishOptions);
    Project1.Modified:=Project1.PublishOptions.Modified;
    if Result<>mrOk then exit;
    IncreaseCompilerParseStamp;
  end;

  //debugln('TMainIDE.DoPublishProject A');
  // save project
  Result:=DoSaveProject(Flags);
  if Result<>mrOk then exit;

  // publish project
  //debugln('TMainIDE.DoPublishProject B');
  Result:=DoPublishModule(Project1.PublishOptions,Project1.ProjectDirectory,
                          GetProjPublishDir);
end;

function TMainIDE.DoImExportCompilerOptions(Sender: TObject): TModalResult;
var
  CompOptsDialog: TfrmCompilerOptions;
  ImExportResult: TImExportCompOptsResult;
  Filename: string;
begin
  Result:=mrOk;
  if not (Sender is TfrmCompilerOptions) then
    RaiseException('TMainIDE.OnCompilerOptionsImExport');
  CompOptsDialog:=TfrmCompilerOptions(Sender);
  ImExportResult:=ShowImExportCompilerOptionsDialog(
                                          CompOptsDialog.CompilerOpts,Filename);
  if (ImExportResult=iecorCancel) or (Filename='') then exit;
  if ImExportResult=iecorImport then
    Result:=DoImportComilerOptions(CompOptsDialog,CompOptsDialog.CompilerOpts,
                                   Filename)
  else if ImExportResult=iecorExport then
    Result:=DoExportComilerOptions(CompOptsDialog,CompOptsDialog.CompilerOpts,
                                   Filename);
end;

function TMainIDE.DoShowProjectInspector: TModalResult;
begin
  if ProjInspector=nil then begin
    ProjInspector:=TProjectInspectorForm.Create(OwningComponent);
    ProjInspector.OnOpen:=@ProjInspectorOpen;
    ProjInspector.OnShowOptions:=@mnuProjectOptionsClicked;
    ProjInspector.OnAddUnitToProject:=@ProjInspectorAddUnitToProject;
    ProjInspector.OnAddDependency:=@PkgBoss.OnProjectInspectorAddDependency;
    ProjInspector.OnRemoveFile:=@ProjInspectorRemoveFile;
    ProjInspector.OnRemoveDependency:=
                                    @PkgBoss.OnProjectInspectorRemoveDependency;
    ProjInspector.OnReAddDependency:=
                                    @PkgBoss.OnProjectInspectorReAddDependency;

    ProjInspector.LazProject:=Project1;
  end;
  ProjInspector.ShowOnTop;
  Result:=mrOk;
end;

function TMainIDE.DoCreateProjectForProgram(
  ProgramBuf: TCodeBuffer): TModalResult;
var
  NewProjectDesc: TProjectDescriptor;
  MainUnitInfo: TUnitInfo;
begin
  {$IFDEF IDE_VERBOSE}
  writeln('[TMainIDE.DoCreateProjectForProgram] A ',ProgramBuf.Filename);
  {$ENDIF}
  Result:=DoSaveProjectIfChanged;
  if Result=mrAbort then exit;

  // let user choose the program type
  NewProjectDesc:=nil;
  if ChooseNewProject(NewProjectDesc)<>mrOk then exit;

  // close old project
  If Project1<>nil then begin
    if DoCloseProject=mrAbort then begin
      Result:=mrAbort;
      exit;
    end;
  end;

  // switch codetools to new project directory
  CodeToolBoss.GlobalValues.Variables[ExternalMacroStart+'ProjPath']:=
    ExpandFilename(ExtractFilePath(ProgramBuf.Filename));

  // create a new project
  Project1:=CreateProjectObject(NewProjectDesc,ProjectDescriptorProgram);
  Project1.BeginUpdate(true);
  try
    if ProjInspector<>nil then ProjInspector.LazProject:=Project1;
    MainUnitInfo:=Project1.MainUnitInfo;
    MainUnitInfo.Source:=ProgramBuf;
    Project1.ProjectInfoFile:=ChangeFileExt(ProgramBuf.Filename,'.lpi');
    Project1.CompilerOptions.CompilerPath:='$(CompPath)';
    UpdateCaption;
    IncreaseCompilerParseStamp;

    // add and load default required packages
    PkgBoss.AddDefaultDependencies(Project1);
  finally
    Project1.EndUpdate;
  end;

  // show program unit
  Result:=DoOpenEditorFile(ProgramBuf.Filename,-1,
                           [ofAddToRecent,ofRegularFile]);
  if Result=mrAbort then exit;

  {$IFDEF IDE_VERBOSE}
  writeln('[TMainIDE.DoCreateProjectForProgram] END');
  {$ENDIF}
  Result:=mrOk;
end;

function TMainIDE.DoSaveProjectIfChanged: TModalResult;
begin
  if SomethingOfProjectIsModified then begin
    if MessageDlg(lisProjectChanged, Format(lisSaveChangesToProject,
      [Project1.Title]),
      mtconfirmation, [mbYes, mbNo, mbCancel], 0)=mrYes then
    begin
      if DoSaveProject([])=mrAbort then begin
        Result:=mrAbort;
        exit;
      end;
    end;
  end;
  Result:=mrOk;
end;

function TMainIDE.DoAddActiveUnitToProject: TModalResult;
var
  ActiveSourceEditor: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  s, ShortUnitName: string;
begin
  Result:=mrCancel;
  BeginCodeTool(ActiveSourceEditor,ActiveUnitInfo,[]);
  if ActiveUnitInfo<>nil then begin
    if ActiveUnitInfo.IsPartOfProject=false then begin
      if not ActiveUnitInfo.IsVirtual then
        s:='"'+ActiveUnitInfo.Filename+'"'
      else
        s:='"'+ActiveSourceEditor.PageName+'"';
      if (ActiveUnitInfo.UnitName<>'')
      and (Project1.IndexOfUnitWithName(ActiveUnitInfo.UnitName,
          true,ActiveUnitInfo)>=0) then
      begin
        MessageDlg(Format(
          lisUnableToAddToProjectBecauseThereIsAlreadyAUnitWith, [s]),
          mtInformation, [mbOk], 0);
      end else begin
        if MessageDlg(Format(lisAddToProject, [s]), mtConfirmation, [mbYes,
          mbCancel], 0) in [mrOk,mrYes]
        then begin
          Result:=DoRenameUnitLowerCase(ActiveUnitInfo,true);
          if Result=mrIgnore then Result:=mrOk;
          if Result<>mrOk then begin
            debugln('TMainIDE.DoAddActiveUnitToProject A DoRenameUnitLowerCase failed ',ActiveUnitInfo.Filename);
            exit;
          end;
          ActiveUnitInfo.IsPartOfProject:=true;
          if (FilenameIsPascalUnit(ActiveUnitInfo.Filename))
          and (pfMainUnitHasUsesSectionForAllUnits in Project1.Flags)
          then begin
            ActiveUnitInfo.ReadUnitNameFromSource(false);
            ShortUnitName:=ActiveUnitInfo.CreateUnitName;
            if (ShortUnitName<>'') then begin
              if CodeToolBoss.AddUnitToMainUsesSection(
                Project1.MainUnitInfo.Source,ShortUnitName,'')
              then
                Project1.MainUnitInfo.Modified:=true;
            end;
          end;
          Project1.Modified:=true;
        end;
      end;
    end else begin
      if not ActiveUnitInfo.IsVirtual then
        s:=Format(lisTheFile, ['"', ActiveUnitInfo.Filename, '"'])
      else
        s:=Format(lisTheFile, ['"', ActiveSourceEditor.PageName, '"']);
      s:=Format(lisisAlreadyPartOfTheProject, [s]);
      MessageDlg(s,mtInformation,[mbOk],0);
    end;
  end else begin
    Result:=mrOk;
  end;
end;

function TMainIDE.DoRemoveFromProjectDialog: TModalResult;
var UnitList: TList;
  i:integer;
  AName: string;
  AnUnitInfo: TUnitInfo;
Begin
  UnitList:=TList.Create;
  try
    for i:=0 to Project1.UnitCount-1 do begin
      AnUnitInfo:=Project1.Units[i];
      if (AnUnitInfo.IsPartOfProject) and (i<>Project1.MainUnitID) then begin
        AName:=Project1.RemoveProjectPathFromFilename(AnUnitInfo.FileName);
        UnitList.Add(TViewUnitsEntry.Create(AName,i,false));
      end;
    end;
    if ShowViewUnitsDlg(UnitList, true, lisRemoveFromProject)=mrOk then begin
      for i:=0 to UnitList.Count-1 do begin
        if TViewUnitsEntry(UnitList[i]).Selected then begin
          AnUnitInfo:=Project1.Units[TViewUnitsEntry(UnitList[i]).ID];
          AnUnitInfo.IsPartOfProject:=false;
          if (Project1.MainUnitID>=0)
          and (pfMainUnitHasUsesSectionForAllUnits in Project1.Flags)
          then begin
            if (AnUnitInfo.UnitName<>'') then begin
              if CodeToolBoss.RemoveUnitFromAllUsesSections(
                Project1.MainUnitInfo.Source,AnUnitInfo.UnitName)
              then
                Project1.MainUnitInfo.Modified:=true;
            end;
            if (AnUnitInfo.ComponentName<>'') then begin
              Project1.RemoveCreateFormFromProjectFile(
                  'T'+AnUnitInfo.ComponentName,AnUnitInfo.ComponentName);
            end;
          end;
        end;
      end;
    end;
  finally
    for i:=0 to UnitList.Count-1 do TViewUnitsEntry(UnitList[i]).Free;
    UnitList.Free;
  end;
  Result:=mrOk;
end;

procedure TMainIDE.DoWarnAmbiguousFiles;
var
  AnUnitInfo: TUnitInfo;
  i: integer;
  DestFilename: string;
begin
  for i:=0 to Project1.UnitCount-1 do begin
    AnUnitInfo:=Project1.Units[i];
    if (AnUnitInfo.IsPartOfProject) and (not AnUnitInfo.IsVirtual) then begin
      DestFilename:=GetTargetUnitFilename(AnUnitInfo);
      DoCheckAmbiguousSources(DestFilename,true);
    end;
  end;
end;

procedure TMainIDE.DoUpdateProjectResourceInfo;
var
  AnUnitInfo: TUnitInfo;
  LFMFilename: String;
begin
  AnUnitInfo:=Project1.FirstPartOfProject;
  while AnUnitInfo<>nil do begin
    if (not AnUnitInfo.HasResources)
    and (not AnUnitInfo.IsVirtual) and FilenameIsPascalUnit(AnUnitInfo.Filename)
    then begin
      LFMFilename:=ChangeFileExt(AnUnitInfo.Filename,'.lfm');
      if FileExists(LFMFilename) then begin
        AnUnitInfo.HasResources:=true;
        AnUnitInfo.ResourceFileName:=ChangeFileExt(LFMFilename,'.lrs');
      end else begin
        AnUnitInfo.HasResources:=false;
      end;
    end;
    if AnUnitInfo.HasResources and (not AnUnitInfo.IsVirtual) then begin
      if (AnUnitInfo.ResourceFileName='')
      or (not FilenameIsAbsolute(AnUnitInfo.ResourceFileName)) then begin
        AnUnitInfo.ResourceFileName:=ChangeFileExt(AnUnitInfo.Filename,'.lrs');
      end;
    end;
    AnUnitInfo:=AnUnitInfo.NextPartOfProject;
  end;
end;

function TMainIDE.DoUpdateProjectAutomaticFiles: TModalResult;
var
  AnUnitInfo: TUnitInfo;
begin
  AnUnitInfo:=Project1.FirstPartOfProject;
  while AnUnitInfo<>nil do begin
    if AnUnitInfo.HasResources then begin
      Result:=DoUpdateLRSFromLFM(AnUnitInfo.ResourceFileName);
      if Result=mrIgnore then Result:=mrOk;
      if Result<>mrOk then exit;
    end;
    AnUnitInfo:=AnUnitInfo.NextPartOfProject;
  end;
end;

function TMainIDE.DoSaveForBuild: TModalResult;
begin
  Result:=mrCancel;
  if not (ToolStatus in [itNone,itDebugger]) then begin
    Result:=mrAbort;
    exit;
  end;
  if Project1=nil then Begin
    MessageDlg(lisCreateAProjectFirst, mterror, [mbok], 0);
    Exit;
  end;

  // check for a main file to compile
  if Project1.MainFilename='' then exit;

  // save all files
  if not Project1.IsVirtual then
    Result:=DoSaveAll([sfCheckAmbiguousFiles])
  else
    Result:=DoSaveProjectToTestDirectory;
  if Result<>mrOk then exit;

  Result:=PkgBoss.DoSaveAllPackages([]);
end;

function TMainIDE.DoSaveProjectToTestDirectory: TModalResult;
begin
  Result:=mrCancel;
  if (EnvironmentOptions.TestBuildDirectory='')
  or (not DirPathExists(EnvironmentOptions.TestBuildDirectory)) then begin
    if (EnvironmentOptions.TestBuildDirectory<>'') then begin
      MessageDlg(Format(lisTheTestDirectoryCouldNotBeFoundSeeEnvironmentOpt, [
        #13, '"', EnvironmentOptions.TestBuildDirectory, '"', #13]), mtError, [
        mbCancel], 0);
      Result:=mrCancel;
      exit;
    end;
    Result:=MessageDlg(lisBuildNewProject,
       Format(lisTheProjectMustBeSavedBeforeBuildingIfYouSetTheTest, [#13, #13,
         #13]), mtInformation, [mbYes, mbNo], 0);
    if Result<>mrYes then exit;
    Result:=DoSaveAll([sfCheckAmbiguousFiles]);
    exit;
  end;
  Result:=DoSaveProject([sfSaveToTestDir,sfCheckAmbiguousFiles]);
end;

function TMainIDE.DoShowToDoList: TModalResult;
begin
  if not Assigned(frmToDo) then begin
    frmToDo:=TfrmToDo.Create(OwningComponent);
    frmToDo.OnOpenFile:=@ViewProjectTodosOpenFile;
  end;

  frmToDo.FileName:=Project1.MainUnitInfo.Filename;

  frmToDo.ShowOnTop;
  Result:=mrOk;
end;

function TMainIDE.DoTestCompilerSettings(
  TheCompilerOptions: TCompilerOptions): TModalResult;
begin
  Result:=mrCancel;
  if (Project1=nil) or (ToolStatus<>itNone) then exit;

  // change tool status
  CheckCompilerOptsDlg:=TCheckCompilerOptsDlg.Create(nil);
  try
    CheckCompilerOptsDlg.Options:=TheCompilerOptions;
    CheckCompilerOptsDlg.MacroList:=MacroList;
    Result:=CheckCompilerOptsDlg.ShowModal;
  finally
    FreeThenNil(CheckCompilerOptsDlg);
  end;
end;

function TMainIDE.DoBuildProject(const AReason: TCompileReason): TModalResult;
var
  DefaultFilename: string;
  ToolBefore: TProjectCompilationTool;
  ToolAfter: TProjectCompilationTool;
begin
  Result:=PrepareForCompile;
  if Result<>mrOk then exit;

  Result:=DoSaveForBuild;
  if Result<>mrOk then exit;

  // show messages
  MessagesView.Clear;
  MessagesView.BeginBlock;
  try
    // compile required packages
    Result:=PkgBoss.DoCompileProjectDependencies(Project1,
                                                 [pcfDoNotSaveEditorFiles]);
    if Result<>mrOk then exit;
    
    // get main source filename
    if not Project1.IsVirtual then
      DefaultFilename:=''
    else
      DefaultFilename:=GetTestUnitFilename(Project1.MainUnitInfo);

    // clear old error lines
    SourceNotebook.ClearErrorLines;

    DoArrangeSourceEditorAndMessageView(false);

    // warn ambiguous files
    DoWarnAmbiguousFiles;
    
    // execute compilation tool 'Before'
    ToolBefore:=TProjectCompilationTool(Project1.CompilerOptions.ExecuteBefore);
    if (AReason in ToolBefore.CompileReasons) then begin
      Result:=DoExecuteCompilationTool(Project1.CompilerOptions.ExecuteBefore,
                                       Project1.ProjectDirectory,
                                       lisExecutingCommandBefore);
      if Result<>mrOk then exit;
    end;

    if (AReason in Project1.CompilerOptions.CompileReasons) then begin
      try
        // change tool status
        ToolStatus:=itBuilder;

        TheOutputFilter.OnAddFilteredLine:=@MessagesView.AddMsg;
        TheOutputFilter.OnReadLine:=@MessagesView.AddProgress;

        // compile
        Result:=TheCompiler.Compile(Project1, AReason = crBuild, DefaultFilename);
        if Result<>mrOk then begin
          DoJumpToCompilerMessage(-1,true);
          exit;
        end;
      finally
        ToolStatus:=itNone;
      end;
    end;

    // execute compilation tool 'After'
    ToolAfter:=TProjectCompilationTool(Project1.CompilerOptions.ExecuteAfter);
    if  (Result = mrOk) and (AReason in ToolAfter.CompileReasons) then begin
      Result:=DoExecuteCompilationTool(Project1.CompilerOptions.ExecuteAfter,
                                       Project1.ProjectDirectory,
                                       lisExecutingCommandAfter);
      if Result<>mrOk then exit;
    end;

    // add success message
    MessagesView.AddMsg(
         Format(lisProjectSuccessfullyBuilt, ['"', Project1.Title, '"']),'',-1);

  finally
    // check sources
    DoCheckFilesOnDisk;
    
    MessagesView.EndBlock;
  end;
end;

function TMainIDE.DoAbortBuild: TModalResult;
begin
  Result:=mrOk;
  if ToolStatus<>itBuilder then exit;
  TheOutputFilter.StopExecute:=true;
end;

function TMainIDE.DoInitProjectRun: TModalResult;
var
  ProgramFilename, WorkingDir: String;
begin
  if ToolStatus <> itNone
  then begin
    // already running so no initialization needed
    Result := mrOk;
    Exit;
  end;

  Result := mrCancel;

  // Check if we can run this project
  debugln('TMainIDE.DoInitProjectRun A ',dbgs(pfRunnable in Project1.Flags),' ',dbgs(Project1.MainUnitID));
  if (not (pfRunnable in Project1.Flags))
  or (Project1.MainUnitID < 0)
  then Exit;

  debugln('TMainIDE.DoInitProjectRun B');
  // Build project first
  if DoBuildProject(crRun) <> mrOk
  then Exit;

  // Check project build
  ProgramFilename := GetProjectTargetFilename;
  if not FileExists(ProgramFilename)
  then begin
    MessageDlg(lisFileNotFound,
      Format(lisNoProgramFileSFound, ['"', ProgramFilename, '"']),
      mtError,[mbCancel], 0);
    Exit;
  end;

  // Setup debugger
  if EnvironmentOptions.DebuggerClass <> ''
  then begin
    if not DebugBoss.InitDebugger
    then Exit;
  end
  else begin
    // Temp solution, in future it will be run by dummy debugger
    try
      CheckIfFileIsExecutable(ProgramFilename);
      FRunProcess := TProcess.Create(nil);
      FRunProcess.CommandLine := GetRunCommandLine;
      WorkingDir:=Project1.RunParameterOptions.WorkingDirectory;
      if WorkingDir='' then
        WorkingDir:=ExtractFilePath(GetProjectTargetFilename);
      if not MacroList.SubstituteStr(WorkingDir) then begin
        Result:=mrCancel;
        exit;
      end;
      FRunProcess.CurrentDirectory:=ExpandFilename(WorkingDir);
      Project1.RunParameterOptions.AssignEnvironmentTo(FRunProcess.Environment);
      // Console applications in win32 need a new console
      if (GetTargetOS='win32') and
        not Project1.CompilerOptions.Win32GraphicApp then
        FRunProcess.Options:= [poNewConsole]
      else
        FRunProcess.Options:= [poNoConsole];
      FRunProcess.ShowWindow := swoShowNormal;
    except
      on e: Exception do
        MessageDlg(Format(lisErrorInitializingProgramSErrorS,
          [#13, '"', ProgramFilename, '"', #13, e.Message]), mterror,[mbok], 0);
    end;
  end;

  Result := mrOK;
  ToolStatus := itDebugger;
end;

function TMainIDE.DoRunProject: TModalResult;
begin
  DebugLn('[TMainIDE.DoRunProject] A');

  if (DoInitProjectRun <> mrOK)
  or (ToolStatus <> itDebugger)
  then begin
    Result := mrAbort;
    Exit;
  end;
  debugln('[TMainIDE.DoRunProject] B ',EnvironmentOptions.DebuggerClass);

  Result := mrCancel;

  if not EnvironmentOptions.DebuggerClassIsDefined then begin
    Result := DebugBoss.RunDebugger;
    if Result<>mrOk then exit;
  end else begin
    DebugLn('NOTE: No debugger defined. Starting program without debugging ...');
    // no debugger, just start the program
    try
      if FRunProcess = nil then Exit;
      try
        DebugLn('  EXECUTING "',FRunProcess.CommandLine,'"');
        DebugLn('    WorkingDir "',FRunProcess.CurrentDirectory,'"');
        // just run the program and don't care (no watch, no debugging)
        // just check from time to time, if it has terminated and clean up
        GetDefaultProcessList.Add(FRunProcess);
        FRunProcess.Execute;
        Result := mrOk;
      except
        on e: Exception do
          MessageDlg(Format(lisErrorInitializingProgramSErrorS,
            [#13, '"', FRunProcess.CommandLine, '"', #13, e.Message]),
            mtError, [mbOk], 0);
      end;
    finally
      ToolStatus:=itNone;
    end;
  end;
  DebugLn('[TMainIDE.DoRunProject] END');
end;

function TMainIDE.SomethingOfProjectIsModified: boolean;
begin
  Result:=(Project1<>nil)
      and (Project1.SomethingModified or SourceNotebook.SomethingModified);
end;

function TMainIDE.DoSaveAll(Flags: TSaveFlags): TModalResult;
begin
  DebugLn('TMainIDE.DoSaveAll');
  Result:=DoSaveProject(Flags);
  SaveEnvironment;
  SaveIncludeLinks;
  InputHistories.Save;
  // ToDo: save open packages, cvs settings, ...
end;

procedure TMainIDE.DoRestart;
  procedure StartStarter;
  var
    StartLazProcess: TProcess;
    ExeName: string;
  begin
{$IFNDEF VER1_0}
    StartLazProcess := TProcess.Create(nil);
    try
      // TODO: use the target directory, where the new startlazarus is
      StartLazProcess.CurrentDirectory := ExtractFileDir(ParamStr(0));
      ExeName := AppendPathDelim(StartLazProcess.CurrentDirectory) +
        'startlazarus' + GetDefaultExecutableExt;
      if not FileExists(ExeName) then begin
        ShowMessage(format(lisCannotFindLazarusStarter,
          [LineEnding, ExeName]));
        exit;
      end;
      StartLazProcess.CommandLine := format('%s --lazarus-pid=%d',
        [ExeName, GetProcessID]);
      StartLazProcess.Execute;
    finally
      StartLazProcess.Free;
    end;
{$ENDIF}
  end;

var CanClose: boolean;
begin
{$IFDEF VER1_0}
  if not StartedByStartLazarus then begin
    DebugLn('Restarting Lazarus not supported, if compiled with fpc 1.0.x');
    exit;
  end;
{$ENDIF}
  CanClose:=true;
  MainIDEBar.OnCloseQuery(Self, CanClose);
  if not CanClose then exit;
  MainIDEBar.Close;
  if Application.Terminated then begin
    if StartedByStartLazarus then
      ExitCode := ExitCodeRestartLazarus
    else
      StartStarter;
  end;
end;

//-----------------------------------------------------------------------------

function TMainIDE.DoRunExternalTool(Index: integer): TModalResult;
begin
  SourceNotebook.ClearErrorLines;
  Result:=EnvironmentOptions.ExternalTools.Run(Index,MacroList);
  DoCheckFilesOnDisk;
end;

function TMainIDE.DoSaveBuildIDEConfigs(Flags: TBuildLazarusFlags
  ): TModalResult;
var
  PkgOptions: string;
  InheritedOptionStrings: TInheritedCompOptsStrings;
  FPCVersion, FPCRelease, FPCPatch: integer;
  IDEBuildFlags: TBuildLazarusFlags;
begin
  // create uses section addition for lazarus.pp
  Result:=PkgBoss.DoSaveAutoInstallConfig;
  if Result<>mrOk then exit;
  
  // prepare static auto install packages
  PkgOptions:='';
  if (blfWithStaticPackages in Flags)
  or MiscellaneousOptions.BuildLazOpts.WithStaticPackages then begin
    // create inherited compiler options
    PkgOptions:=PkgBoss.DoGetIDEInstallPackageOptions(InheritedOptionStrings);

    // check ambiguous units
    CodeToolBoss.GetFPCVersionForDirectory(
                               EnvironmentOptions.LazarusDirectory,
                               FPCVersion,FPCRelease,FPCPatch);
  end;

  // save extra options
  IDEBuildFlags:=Flags+[blfOnlyIDE];
  Result:=SaveIDEMakeOptions(MiscellaneousOptions.BuildLazOpts,
                             MacroList,PkgOptions,IDEBuildFlags);
  if Result<>mrOk then exit;
end;

function TMainIDE.DoBuildLazarus(Flags: TBuildLazarusFlags): TModalResult;
var
  PkgOptions: string;
  IDEBuildFlags: TBuildLazarusFlags;
  InheritedOptionStrings: TInheritedCompOptsStrings;
  CompiledUnitExt: String;
  FPCVersion, FPCRelease, FPCPatch: integer;
begin
  if ToolStatus<>itNone then begin
    MessageDlg(lisNotNow,
      lisYouCanNotBuildLazarusWhileDebuggingOrCompiling,
      mtError,[mbCancel],0);
    Result:=mrCancel;
    exit;
  end;
  MessagesView.BeginBlock;
  try
    // first compile all lazarus components (LCL, SynEdit, CodeTools, ...)
    SourceNotebook.ClearErrorLines;
    Result:=BuildLazarus(MiscellaneousOptions.BuildLazOpts,
                         EnvironmentOptions.ExternalTools,MacroList,
                         '',EnvironmentOptions.CompilerFilename,
                         EnvironmentOptions.MakeFilename,
                         Flags+[blfWithoutLinkingIDE]);
    if Result<>mrOk then exit;

    // then compile the IDE
    if ([blfWithStaticPackages,blfOnlyIDE]*Flags=[])
    and (MiscellaneousOptions.BuildLazOpts.ItemIDE.MakeMode=mmNone) then exit;

    // prepare static auto install packages
    PkgOptions:='';
    if (blfWithStaticPackages in Flags)
    or MiscellaneousOptions.BuildLazOpts.WithStaticPackages then begin
      // compile auto install static packages
      Result:=PkgBoss.DoCompileAutoInstallPackages([]);
      if Result<>mrOk then exit;

      // create uses section addition for lazarus.pp
      Result:=PkgBoss.DoSaveAutoInstallConfig;
      if Result<>mrOk then exit;

      // create inherited compiler options
      PkgOptions:=PkgBoss.DoGetIDEInstallPackageOptions(InheritedOptionStrings);

      // check ambiguous units
      CodeToolBoss.GetFPCVersionForDirectory(
                                 EnvironmentOptions.LazarusDirectory,
                                 FPCVersion,FPCRelease,FPCPatch);
      CompiledUnitExt:=MiscellaneousOptions.BuildLazOpts.CompiledUnitExt(
                         FPCVersion,FPCRelease);
      Result:=DoCheckUnitPathForAmbiguousPascalFiles(
                       EnvironmentOptions.LazarusDirectory,
                       InheritedOptionStrings[icoUnitPath],
                       CompiledUnitExt,'IDE');
      if Result<>mrOk then exit;
    end;

    // save extra options
    IDEBuildFlags:=Flags+[blfOnlyIDE];
    Result:=SaveIDEMakeOptions(MiscellaneousOptions.BuildLazOpts,
                               MacroList,PkgOptions,IDEBuildFlags);
    if Result<>mrOk then exit;

    // make ide
    SourceNotebook.ClearErrorLines;
    Result:=BuildLazarus(MiscellaneousOptions.BuildLazOpts,
                         EnvironmentOptions.ExternalTools,MacroList,
                         PkgOptions,EnvironmentOptions.CompilerFilename,
                         EnvironmentOptions.MakeFilename,
                         IDEBuildFlags+[blfUseMakeIDECfg,blfDontClean]);
    if Result<>mrOk then exit;
    
  finally
    DoCheckFilesOnDisk;
    MessagesView.EndBlock;
  end;
  if (Result=mrOK) and MiscellaneousOptions.BuildLazOpts.RestartAfterBuild then
     mnuRestartClicked(nil);
end;

function TMainIDE.DoExecuteCompilationTool(Tool: TCompilationTool;
  const WorkingDir, ToolTitle: string): TModalResult;
var
  ProgramFilename, Params: string;
  ExtTool: TExternalToolOptions;
  Filename: String;
begin
  if Tool.Command='' then begin
    Result:=mrOk;
    exit;
  end;

  SourceNotebook.ClearErrorLines;

  SplitCmdLine(Tool.Command,ProgramFilename,Params);
  if not FilenameIsAbsolute(ProgramFilename) then begin
    Filename:=FindProgram(ProgramFilename,WorkingDir,true);
    if Filename<>'' then ProgramFilename:=Filename;
  end;

  ExtTool:=TExternalToolOptions.Create;
  try
    ExtTool.Filename:=ProgramFilename;
    ExtTool.ScanOutputForFPCMessages:=Tool.ScanForFPCMessages;
    ExtTool.ScanOutputForMakeMessages:=Tool.ScanForMakeMessages;
    ExtTool.ScanOutput:=true;
    ExtTool.ShowAllOutput:=Tool.ShowAllMessages;
    ExtTool.Title:=ToolTitle;
    ExtTool.WorkingDirectory:=WorkingDir;
    ExtTool.CmdLineParams:=Params;

    // run
    Result:=EnvironmentOptions.ExternalTools.Run(ExtTool,MacroList);
  finally
    // clean up
    ExtTool.Free;
  end;
end;

function TMainIDE.DoBuildFile: TModalResult;
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  DirectiveList: TStringList;
  BuildWorkingDir: String;
  BuildCommand: String;
  BuildScan: TIDEDirBuildScanFlags;
  ProgramFilename: string;
  Params: string;
  ExtTool: TExternalToolOptions;
  Filename: String;
begin
  Result:=mrCancel;
  if ToolStatus<>itNone then exit;
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  Result:=DoSaveEditorFile(ActiveUnitInfo.EditorIndex,[sfCheckAmbiguousFiles]);
  if Result<>mrOk then exit;
  DirectiveList:=TStringList.Create;
  try
    Result:=GetIDEDirectives(ActiveUnitInfo,DirectiveList);
    if Result<>mrOk then exit;

    // get values form directive list
    // build
    BuildWorkingDir:=GetIDEStringDirective(DirectiveList,
                                         IDEDirectiveNames[idedBuildWorkingDir],
                                         '');
    if BuildWorkingDir='' then
      BuildWorkingDir:=ExtractFilePath(ActiveUnitInfo.Filename);
    if not MacroList.SubstituteStr(BuildWorkingDir) then begin
      Result:=mrCancel;
      exit;
    end;
    BuildCommand:=GetIDEStringDirective(DirectiveList,
                                      IDEDirectiveNames[idedBuildCommand],
                                      IDEDirDefaultBuildCommand);
    if (not MacroList.SubstituteStr(BuildCommand))
    or (BuildCommand='') then begin
      Result:=mrCancel;
      exit;
    end;
    BuildScan:=GetIDEDirBuildScanFromString(GetIDEStringDirective(DirectiveList,
                                   IDEDirectiveNames[idedBuildScan],''));

    SourceNotebook.ClearErrorLines;

    SplitCmdLine(BuildCommand,ProgramFilename,Params);
    if not FilenameIsAbsolute(ProgramFilename) then begin
      Filename:=FindProgram(ProgramFilename,BuildWorkingDir,true);
      if Filename<>'' then ProgramFilename:=Filename;
    end;
    if ProgramFilename='' then begin
      Result:=mrCancel;
      exit;
    end;

    ExtTool:=TExternalToolOptions.Create;
    try
      ExtTool.Filename:=ProgramFilename;
      ExtTool.ScanOutputForFPCMessages:=idedbsfFPC in BuildScan;
      ExtTool.ScanOutputForMakeMessages:=idedbsfMake in BuildScan;
      ExtTool.ScanOutput:=true;
      ExtTool.Title:='Build File '+ActiveUnitInfo.Filename;
      ExtTool.WorkingDirectory:=BuildWorkingDir;
      ExtTool.CmdLineParams:=Params;

      // run
      Result:=EnvironmentOptions.ExternalTools.Run(ExtTool,MacroList);
    finally
      // clean up
      ExtTool.Free;
    end;
  finally
    DirectiveList.Free;
  end;
  Result:=mrOk;
end;

function TMainIDE.DoRunFile: TModalResult;
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  RunFlags: TIDEDirRunFlags;
  AlwaysBuildBeforeRun: boolean;
  RunWorkingDir: String;
  RunCommand: String;
  ProgramFilename: string;
  Params: string;
  ExtTool: TExternalToolOptions;
  Filename: String;
  DirectiveList: TStringList;
begin
  Result:=mrCancel;
  if ToolStatus<>itNone then exit;
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  if not FilenameIsAbsolute(ActiveUnitInfo.Filename) then begin
    Result:=DoSaveEditorFile(ActiveUnitInfo.EditorIndex,[sfCheckAmbiguousFiles]);
    if Result<>mrOk then exit;
  end;
  DirectiveList:=TStringList.Create;
  try
    Result:=GetIDEDirectives(ActiveUnitInfo,DirectiveList);
    if Result<>mrOk then exit;

    RunFlags:=GetIDEDirRunFlagFromString(
                 GetIDEStringDirective(DirectiveList,
                                       IDEDirectiveNames[idedRunFlags],''));
    AlwaysBuildBeforeRun:=idedrfBuildBeforeRun in RunFlags;
    if AlwaysBuildBeforeRun then begin
      Result:=DoBuildFile;
      if Result<>mrOk then exit;
    end;
    RunWorkingDir:=GetIDEStringDirective(DirectiveList,
                                       IDEDirectiveNames[idedRunWorkingDir],'');
    if RunWorkingDir='' then
      RunWorkingDir:=ExtractFilePath(ActiveUnitInfo.Filename);
    if not MacroList.SubstituteStr(RunWorkingDir) then begin
      Result:=mrCancel;
      exit;
    end;
    RunCommand:=GetIDEStringDirective(DirectiveList,
                                    IDEDirectiveNames[idedRunCommand],
                                    IDEDirDefaultRunCommand);
    if (not MacroList.SubstituteStr(RunCommand))
    or (RunCommand='') then begin
      Result:=mrCancel;
      exit;
    end;

    SourceNotebook.ClearErrorLines;

    SplitCmdLine(RunCommand,ProgramFilename,Params);
    if not FilenameIsAbsolute(ProgramFilename) then begin
      Filename:=FindProgram(ProgramFilename,RunWorkingDir,true);
      if Filename<>'' then ProgramFilename:=Filename;
    end;
    if ProgramFilename='' then begin
      Result:=mrCancel;
      exit;
    end;

    ExtTool:=TExternalToolOptions.Create;
    try
      ExtTool.Filename:=ProgramFilename;
      ExtTool.Title:='Run File '+ActiveUnitInfo.Filename;
      ExtTool.WorkingDirectory:=RunWorkingDir;
      ExtTool.CmdLineParams:=Params;

      // run
      Result:=EnvironmentOptions.ExternalTools.Run(ExtTool,MacroList);
    finally
      // clean up
      ExtTool.Free;
    end;
  finally
    DirectiveList.Free;
  end;
  Result:=mrOk;
end;

function TMainIDE.DoConfigBuildFile: TModalResult;
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  DirectiveList: TStringList;
  CodeResult: Boolean;
  BuildFileDialog: TBuildFileDialog;
begin
  Result:=mrCancel;
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  if not FilenameIsAbsolute(ActiveUnitInfo.Filename) then begin
    Result:=DoSaveEditorFile(ActiveUnitInfo.EditorIndex,[sfCheckAmbiguousFiles]);
    if Result<>mrOk then exit;
  end;
  DirectiveList:=TStringList.Create;
  try
    Result:=GetIDEDirectives(ActiveUnitInfo,DirectiveList);
    if Result<>mrOk then exit;

    BuildFileDialog:=TBuildFileDialog.Create(nil);
    try
      BuildFileDialog.DirectiveList:=DirectiveList;
      BuildFileDialog.BuildFileIfActive:=ActiveUnitInfo.BuildFileIfActive;
      BuildFileDialog.RunFileIfActive:=ActiveUnitInfo.RunFileIfActive;
      BuildFileDialog.MacroList:=MacroList;
      BuildFileDialog.Filename:=
        CreateRelativePath(ActiveUnitInfo.Filename,Project1.ProjectDirectory);
      if BuildFileDialog.ShowModal<>mrOk then begin
        Result:=mrCancel;
        exit;
      end;
      ActiveUnitInfo.BuildFileIfActive:=BuildFileDialog.BuildFileIfActive;
      ActiveUnitInfo.RunFileIfActive:=BuildFileDialog.RunFileIfActive;
    finally
      BuildFileDialog.Free;
    end;

    // save IDE directives
    if FilenameIsPascalSource(ActiveUnitInfo.Filename) then begin
      // parse source for IDE directives (i.e. % comments)
      CodeResult:=CodeToolBoss.SetIDEDirectives(ActiveUnitInfo.Source,
                                                DirectiveList);
      ApplyCodeToolChanges;
      if not CodeResult then begin
        DoJumpToCodeToolBossError;
        exit;
      end;

    end else begin
      // ToDo: load .lfi file
      exit;
    end;

  finally
    DirectiveList.Free;
  end;

  Result:=mrOk;
end;

function TMainIDE.GetIDEDirectives(AnUnitInfo: TUnitInfo;
  DirectiveList: TStrings): TModalResult;
var
  CodeResult: Boolean;
begin
  Result:=mrCancel;
  if FilenameIsPascalSource(AnUnitInfo.Filename) then begin
    // parse source for IDE directives (i.e. % comments)
    CodeResult:=CodeToolBoss.GetIDEDirectives(AnUnitInfo.Source,DirectiveList);
    if not CodeResult then begin
      DoJumpToCodeToolBossError;
      exit;
    end;

  end else begin
    // ToDo: load .lfi file
    MessageDlg('Not implemented',
      'Sorry, IDE directives are only implemented for pascal sources',
      mtInformation,[mbCancel],0);
    exit;
  end;
  Result:=mrOk;
end;

function TMainIDE.DoConvertDFMtoLFM: TModalResult;
var
  OpenDialog: TOpenDialog;
  i: integer;
  AFilename: string;
begin
  Result:=mrOk;
  OpenDialog:=TOpenDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(OpenDialog);
    OpenDialog.Title:=lisSelectDFMFiles;
    OpenDialog.Options:=OpenDialog.Options+[ofAllowMultiSelect];
    if OpenDialog.Execute and (OpenDialog.Files.Count>0) then begin
      For I := 0 to OpenDialog.Files.Count-1 do begin
        AFilename:=ExpandFilename(OpenDialog.Files.Strings[i]);
        if ConvertDFMFileToLFMFile(AFilename)=mrAbort then begin
          Result:=mrAbort;
          break;
        end else
          Result:=mrOk;
      end;
      SaveEnvironment;
    end;
    InputHistories.StoreFileDialogSettings(OpenDialog);
  finally
    OpenDialog.Free;
  end;
  DoCheckFilesOnDisk;
end;

function TMainIDE.DoCheckLFMInEditor: TModalResult;
var
  LFMSrcEdit: TSourceEditor;
  LFMUnitInfo: TUnitInfo;
  UnitFilename: String;
  PascalBuf: TCodeBuffer;
begin
  // check, if a .lfm file is opened in the source editor
  GetCurrentUnit(LFMSrcEdit,LFMUnitInfo);
  if (LFMUnitInfo=nil)
  or (CompareFileExt(LFMUnitInfo.Filename,'.lfm',false)<>0) then begin
    MessageDlg('No LFM file',
      'This function needs an open .lfm file in the source editor.',
      mtError,[mbCancel],0);
    Result:=mrCancel;
    exit;
  end;
  // try to find the pascal unit
  UnitFilename:=ChangeFileExt(LFMUnitInfo.Filename,'.pas');
  if not FileExists(UnitFilename) then begin
    UnitFilename:=ChangeFileExt(LFMUnitInfo.Filename,'.pp');
    if not FileExists(UnitFilename) then begin
      MessageDlg('No pascal file',
        'Unable to find pascal unit (.pas,.pp) for .lfm file'#13
        +'"'+LFMUnitInfo.Filename+'"',
        mtError,[mbCancel],0);
      Result:=mrCancel;
      exit;
    end;
  end;

  if ToolStatus<>itNone then begin
    Result:=mrCancel;
    exit;
  end;
  // load the pascal unit
  SaveSourceEditorChangesToCodeCache(-1);
  Result:=LoadCodeBuffer(PascalBuf,UnitFilename,[]);
  if Result<>mrOk then exit;

  // open messages window
  SourceNotebook.ClearErrorLines;
  if MessagesView<>nil then
    MessagesView.Clear;
  DoArrangeSourceEditorAndMessageView(false);

  // parse the LFM file and the pascal unit
  if CheckLFMBuffer(PascalBuf,LFMUnitInfo.Source,@MessagesView.AddMsg,
                        true,true)<>mrOk
  then begin
    DoJumpToCompilerMessage(-1,true);
  end;

  Result:=mrOk;
end;

function TMainIDE.DoConvertDelphiUnit(const DelphiFilename: string
  ): TModalResult;
var
  DFMFilename: String;
  LazarusUnitFilename: String;
  LRSFilename: String;
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  UnitCode, LFMCode: TCodeBuffer;
  HasDFMFile: boolean;
  LFMFilename: String;
  OldOpenEditorsOnCodeToolChange: Boolean;
begin
  // check file and directory
  DebugLn('TMainIDE.DoConvertDelphiUnit A ',DelphiFilename);
  Result:=CheckDelphiFileExt(DelphiFilename);
  if Result<>mrOk then exit;
  Result:=CheckFileIsWritable(DelphiFilename,[mbAbort]);
  if Result<>mrOk then exit;
  Result:=CheckFilenameForLCLPaths(DelphiFilename);
  if Result<>mrOk then exit;
  // close Delphi files in editor
  DebugLn('TMainIDE.DoConvertDelphiUnit Close files in editor .pas/.dfm');
  Result:=DoCloseEditorFile(DelphiFilename,[cfSaveFirst]);
  if Result<>mrOk then exit;
  DFMFilename:=FindDFMFileForDelphiUnit(DelphiFilename);
  DebugLn('TMainIDE.DoConvertDelphiUnit DFM file="',DFMFilename,'"');
  HasDFMFile:=DFMFilename<>'';
  if HasDFMFile then begin
    Result:=DoCloseEditorFile(DFMFilename,[cfSaveFirst]);
    if Result<>mrOk then exit;
  end;
  // rename files (.pas,.dfm) lowercase
  // TODO: rename files in project
  DebugLn('TMainIDE.DoConvertDelphiUnit Rename files');
  LazarusUnitFilename:='';
  LFMFilename:='';
  Result:=RenameDelphiUnitToLazarusUnit(DelphiFilename,true,
                       LazarusUnitFilename,LFMFilename);
  if Result<>mrOk then exit;
  if LFMFilename='' then LFMFilename:=ChangeFIleExt(LazarusUnitFilename,'.lfm');
  HasDFMFile:=FileExists(LFMFilename);
  // convert .dfm file to .lfm file
  if HasDFMFile then begin
    DebugLn('TMainIDE.DoConvertDelphiUnit Convert dfm format to lfm "',LFMFilename,'"');
    Result:=ConvertDFMFileToLFMFile(LFMFilename);
    if Result<>mrOk then exit;
  end;
  // create empty .lrs file
  DebugLn('TMainIDE.DoConvertDelphiUnit Create empty lrs');
  if HasDFMFile then begin
    LRSFilename:=ChangeFileExt(LazarusUnitFilename,'.lrs');
    DebugLn('TMainIDE.DoConvertDelphiUnit Create ',LRSFilename);
    Result:=CreateEmptyFile(LRSFilename,[mbAbort,mbRetry]);
    if Result<>mrOk then exit;
  end else
    LRSFilename:='';

  DebugLn('TMainIDE.DoConvertDelphiUnit Convert delphi source');
  OldOpenEditorsOnCodeToolChange:=FOpenEditorsOnCodeToolChange;
  FOpenEditorsOnCodeToolChange:=true;
  try
    if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then begin
      Result:=mrCancel;
      exit;
    end;

    // add {$mode delphi} directive
    // remove windows unit and add LResources, LCLIntf
    // remove {$R *.dfm} or {$R *.xfm} directive
    // add initialization
    // add {$i unit.lrs} directive
    // TODO: fix delphi ambiguousities like incomplete proc implementation headers
    Result:=ConvertDelphiSourceToLazarusSource(LazarusUnitFilename,
                                               LRSFilename<>'');
    if Result<>mrOk then begin
      DoJumpToCodeToolBossError;
      exit;
    end;

    // comment missing units
    DebugLn('TMainIDE.DoConvertDelphiUnit FixMissingUnits');
    Result:=FixMissingUnits(LazarusUnitFilename);
    if Result<>mrOk then begin
      DoJumpToCodeToolBossError;
      exit;
    end;
    
    // check the LFM file and the pascal unit
    DebugLn('TMainIDE.DoConvertDelphiUnit Check new .lfm and .pas file');
    Result:=LoadUnitAndLFMFile(LazarusUnitFilename,UnitCode,LFMCode,HasDFMFile);
    if Result<>mrOk then exit;
    if HasDFMFile and (LFMCode=nil) then
      DebugLn('WARNING: TMainIDE.DoConvertDelphiUnit unable to load LFMCode');
    if (LFMCode<>nil)
    and (CheckLFMBuffer(UnitCode,LFMCode,@MessagesView.AddMsg,true,true)<>mrOk)
    then begin
      DoJumpToCompilerMessage(-1,true);
      exit;
    end;

    // save LFM file
    DebugLn('TMainIDE.DoConvertDelphiUnit Save LFM');
    Result:=DoSaveCodeBufferToFile(LFMCode,LFMCode.Filename,false);
    if Result<>mrOk then exit;

    // convert lfm to lrs
    DebugLn('TMainIDE.DoConvertDelphiUnit Convert lfm to lrs');
    Result:=ConvertLFMtoLRSfile(LFMCode.Filename);
    if Result<>mrOk then exit;
  finally
    FOpenEditorsOnCodeToolChange:=OldOpenEditorsOnCodeToolChange;
  end;

  Result:=mrOk;
end;

function TMainIDE.DoConvertDelphiProject(const DelphiFilename: string
  ): TModalResult;
var
  DPRCode: TCodeBuffer;
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  FoundInUnits, MissingInUnits, NormalUnits: TStrings;
  NotFoundUnits: String;
  LPRCode: TCodeBuffer;
  NewProjectDesc: TProjectEmptyProgramDescriptor;
  i: Integer;
  CurUnitInfo: TUnitInfo;
  MainUnitInfo: TUnitInfo;
begin
  debugln('TMainIDE.DoConvertDelphiProject DelphiFilename="',DelphiFilename,'"');
  if MessagesView<>nil then MessagesView.Clear;
  // check Delphi project file
  Result:=CheckDelphiProjectExt(DelphiFilename);
  if Result<>mrOk then exit;
  // close Delphi file in editor
  debugln('TMainIDE.DoConvertDelphiProject closing in editor dpr ...');
  Result:=DoCloseEditorFile(DelphiFilename,[cfSaveFirst]);
  if Result<>mrOk then exit;
  // commit source editor changes to codetools
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then begin
    Result:=mrCancel;
    exit;
  end;
  // load Delphi project file .dpr
  debugln('TMainIDE.DoConvertDelphiProject loading dpr ...');
  Result:=LoadCodeBuffer(DPRCode,DelphiFilename,
                         [lbfCheckIfText,lbfUpdateFromDisk]);
  if Result<>mrOk then exit;
  // create .lpr file
  debugln('TMainIDE.DoConvertDelphiProject creating lpr ...');
  Result:=CreateLPRFileForDPRFile(DelphiFilename,false,LPRCode);
  if Result<>mrOk then begin
    if CodeToolBoss.ErrorMessage<>'' then DoJumpToCodeToolBossError;
    exit;
  end;

  // close old project
  debugln('TMainIDE.DoConvertDelphiProject closing current project ...');
  If Project1<>nil then begin
    if DoCloseProject=mrAbort then begin
      Result:=mrAbort;
      exit;
    end;
  end;

  // TODO: get all compiler options from .dpr
  // TODO: read .dof file
  // TODO: read .cfg file
  // TODO: get all search paths
  // TODO: get all needed packages

  // switch codetools to new project directory
  CodeToolBoss.GlobalValues.Variables[ExternalMacroStart+'ProjPath']:=
    ExpandFilename(ExtractFilePath(LPRCode.Filename));

  // create a new project
  debugln('TMainIDE.DoConvertDelphiProject creating new project ...');
  NewProjectDesc:=TProjectEmptyProgramDescriptor.Create;
  Project1:=CreateProjectObject(NewProjectDesc,ProjectDescriptorApplication);
  Project1.BeginUpdate(true);
  try
    if ProjInspector<>nil then ProjInspector.LazProject:=Project1;
    MainUnitInfo:=TUnitInfo.Create(LPRCode);
    MainUnitInfo.SyntaxHighlighter:=
              ExtensionToLazSyntaxHighlighter(ExtractFileExt(LPRCode.Filename));
    MainUnitInfo.IsPartOfProject:=true;
    Project1.AddFile(MainUnitInfo,false);
    Project1.MainFileID:=0;
    Project1.ProjectInfoFile:=ChangeFileExt(LPRCode.Filename,'.lpi');
    Project1.CompilerOptions.CompilerPath:='$(CompPath)';
    UpdateCaption;
    IncreaseCompilerParseStamp;

    // add and load default required packages
    // TODO: add packages
    // WORKAROUND: add LCL
    // add lcl pp/pas dirs to source search path
    Project1.AddSrcPath('$(LazarusDir)/lcl;'
                 +'$(LazarusDir)/lcl/interfaces/$(LCLWidgetType)');
    Project1.AddPackageDependency('LCL');
    Project1.LazCompilerOptions.Win32GraphicApp:=true;
    PkgBoss.AddDefaultDependencies(Project1);
  finally
    Project1.EndUpdate;
    NewProjectDesc.Free;
  end;

  // show program unit
  debugln('TMainIDE.DoConvertDelphiProject open lpr in editor ...');
  Result:=DoOpenEditorFile(LPRCode.Filename,-1,[ofAddToRecent,ofRegularFile]);
  if Result=mrAbort then exit;

  // find all project files
  FoundInUnits:=nil;
  MissingInUnits:=nil;
  NormalUnits:=nil;
  try
    debugln('TMainIDE.DoConvertDelphiProject gathering all project units ...');
    if not CodeToolBoss.FindDelphiProjectUnits(LPRCode,FoundInUnits,
                                               MissingInUnits, NormalUnits) then
    begin
      DoJumpToCodeToolBossError;
      exit;
    end;
    debugln('TMainIDE.DoConvertDelphiProject FoundInUnits=[',FoundInUnits.Text,']',
      ' MissingInUnits=[',MissingInUnits.Text,']',
      ' NormalUnits=[',NormalUnits.Text,']');
    // warn about missing units
    if (MissingInUnits<>nil) and (MissingInUnits.Count>0) then begin
      NotFoundUnits:=MissingInUnits.Text;
      Result:=MessageDlg('Units not found',
        'Some units of the delphi project were not found:'#13
        +NotFoundUnits,mtWarning,[mbIgnore,mbAbort],0);
      if Result<>mrIgnore then exit;
    end;

    // add all units to the project
    debugln('TMainIDE.DoConvertDelphiProject adding all project units to project ...');
    for i:=0 to FoundInUnits.Count-1 do begin
      CurUnitInfo:=TUnitInfo.Create(nil);
      TUnitInfo(CurUnitInfo).Filename:=FoundInUnits[i];
      Project1.AddFile(CurUnitInfo,false);
    end;
    
    // save project
    debugln('TMainIDE.DoConvertDelphiProject Saving new project ...');
    Result:=DoSaveProject([]);
    if Result<>mrOk then exit;

    // convert all units
    i:=0;
    while i<Project1.UnitCount do begin
      CurUnitInfo:=Project1.Units[i];
      if CurUnitInfo.IsPartOfProject and not (CurUnitInfo.IsMainUnit) then begin
        Result:=DoConvertDelphiUnit(CurUnitInfo.Filename);
        if Result=mrAbort then exit;
      end;
      inc(i);
    end;

  finally
    FoundInUnits.Free;
    MissingInUnits.Free;
    NormalUnits.Free;
  end;

  debugln('TMainIDE.DoConvertDelphiProject Done');
  Result:=mrOk;
end;

{-------------------------------------------------------------------------------
  procedure TMainIDE.UpdateCustomToolsInMenu;

  Creates a TMenuItem for each custom external tool.
-------------------------------------------------------------------------------}
procedure TMainIDE.UpdateCustomToolsInMenu;
var
  ToolCount: integer;

  procedure CreateToolMenuItems;
  var
    CurMenuItem: TMenuItem;
    LastIndex, FirstIndex, ExistingCount: integer;
  begin
    // add separator
    if (ToolCount>0) and (CustomExtToolMenuSeparator=nil) then begin
      CustomExtToolMenuSeparator:=CreateMenuSeparator;
      MainIDEBar.mnuTools.Add(CustomExtToolMenuSeparator);
    end;
    // add enough menuitems
    if CustomExtToolMenuSeparator=nil then exit;
    FirstIndex:=CustomExtToolMenuSeparator.MenuIndex+1;
    LastIndex:=FirstIndex;
    while (LastIndex<MainIDEBar.mnuTools.Count)
    and (MainIDEBar.mnuTools[LastIndex].Caption<>'-') do
      inc(LastIndex);
    ExistingCount:=LastIndex-FirstIndex;
    while ExistingCount<ToolCount do begin
      CurMenuItem := TMenuItem.Create(OwningComponent);
      CurMenuItem.Name:='itmToolCustomExt'+IntToStr(ExistingCount);
      CurMenuItem.Caption:=CurMenuItem.Name;
      MainIDEBar.mnuTools.Insert(LastIndex,CurMenuItem);
      inc(LastIndex);
      inc(ExistingCount);
    end;
    // delete unneeded menuitems
    while ExistingCount>ToolCount do begin
      MainIDEBar.mnuTools[LastIndex-1].Free;
      dec(LastIndex);
      dec(ExistingCount);
    end;
  end;

  procedure SetToolMenuItems;
  var
    CurMenuItem: TMenuItem;
    i, Index: integer;
    ExtTool: TExternalToolOptions;
  begin
    if CustomExtToolMenuSeparator=nil then exit;
    i:=CustomExtToolMenuSeparator.MenuIndex+1;
    Index:=0;
    while (i<MainIDEBar.mnuTools.Count) do begin
      CurMenuItem:=MainIDEBar.mnuTools[i];
      if CurMenuItem.Caption='-' then break;
      ExtTool:=EnvironmentOptions.ExternalTools[Index];
      CurMenuItem.Caption:=ExtTool.Title;
      CurMenuItem.ShortCut:=ShortCut(ExtTool.Key,ExtTool.Shift);
      CurMenuItem.OnClick:=@mnuCustomExtToolClick;
      inc(i);
      inc(Index);
    end;
  end;

begin
  ToolCount:=EnvironmentOptions.ExternalTools.Count;
  CreateToolMenuItems;
  SetToolMenuItems;
end;

function TMainIDE.PrepareForCompile: TModalResult;
begin
  Result:=mrOk;
  if ToolStatus=itDebugger then begin
    Result:=MessageDlg('Stop debugging?',
      'Stop current debugging and rebuild project?',
      mtConfirmation,[mbYes,mbNo,mbAbort],0);
    if Result=mrNo then Result:=mrCancel;
    if Result<>mrYes then exit;

    Result:=DebugBoss.DoStopProject;
    if Result<>mrOk then exit;
  end;
end;

function TMainIDE.DoCheckSyntax: TModalResult;
var
  ActiveUnitInfo:TUnitInfo;
  ActiveSrcEdit:TSourceEditor;
  NewCode: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
  ErrorMsg: string;
begin
  Result:=mrOk;
  GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
  if (ActiveUnitInfo=nil) or (ActiveUnitInfo.Source=nil)
  or (ActiveSrcEdit=nil) then exit;
  SaveSourceEditorChangesToCodeCache(-1);
  CodeToolBoss.VisibleEditorLines:=ActiveSrcEdit.EditorComponent.LinesInWindow;
  if not CodeToolBoss.CheckSyntax(ActiveUnitInfo.Source,NewCode,NewX,NewY,
    NewTopLine,ErrorMsg) then
  begin
    DoJumpToCodeToolBossError;
  end;
end;

//-----------------------------------------------------------------------------

procedure TMainIDE.GetCurrentUnit(var ActiveSourceEditor:TSourceEditor;
  var ActiveUnitInfo:TUnitInfo);
begin
  if SourceNoteBook.NoteBook=nil then begin
    ActiveSourceEditor:=nil;
    ActiveUnitInfo:=nil;
  end else begin
    GetUnitWithPageIndex(SourceNotebook.NoteBook.PageIndex,ActiveSourceEditor,
       ActiveUnitInfo);
  end;
end;

procedure TMainIDE.GetUnitWithPageIndex(PageIndex:integer;
  var ActiveSourceEditor:TSourceEditor; var ActiveUnitInfo:TUnitInfo);
begin
  if SourceNoteBook.NoteBook=nil then begin
    ActiveSourceEditor:=nil;
    ActiveUnitInfo:=nil;
  end else begin
    ActiveSourceEditor:=SourceNoteBook.FindSourceEditorWithPageIndex(PageIndex);
    if ActiveSourceEditor=nil then
      ActiveUnitInfo:=nil
    else
      ActiveUnitInfo:=Project1.UnitWithEditorIndex(PageIndex);
  end;
end;

procedure TMainIDE.GetDesignerUnit(ADesigner: TDesigner;
  var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo);
begin
  if ADesigner<>nil then begin
    GetUnitWithForm(ADesigner.Form,ActiveSourceEditor,ActiveUnitInfo);
  end else begin
    ActiveSourceEditor:=nil;
    ActiveUnitInfo:=nil;
  end;
end;

procedure TMainIDE.GetObjectInspectorUnit(
  var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo);
begin
  ActiveSourceEditor:=nil;
  ActiveUnitInfo:=nil;
  if (ObjectInspector1=nil) or (ObjectInspector1.PropertyEditorHook=nil)
  or (ObjectInspector1.PropertyEditorHook.LookupRoot=nil)
  then exit;
  GetUnitWithPersistent(ObjectInspector1.PropertyEditorHook.LookupRoot,
    ActiveSourceEditor,ActiveUnitInfo);
end;

procedure TMainIDE.GetUnitWithForm(AForm: TCustomForm;
  var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo);
var
  AComponent: TComponent;
begin
  if AForm<>nil then begin
    if (AForm.Designer=nil) then
      RaiseException('TMainIDE.GetUnitWithForm AForm.Designer');
    AComponent:=TDesigner(AForm.Designer).LookupRoot;
    if AComponent=nil then
      RaiseException('TMainIDE.GetUnitWithForm AComponent=nil');
    GetUnitWithPersistent(AComponent,ActiveSourceEditor,ActiveUnitInfo);
  end else begin
    ActiveSourceEditor:=nil;
    ActiveUnitInfo:=nil;
  end;
end;

procedure TMainIDE.GetUnitWithPersistent(APersistent: TPersistent;
  var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo);
begin
  if APersistent<>nil then begin
    ActiveUnitInfo:=Project1.FirstUnitWithComponent;
    while ActiveUnitInfo<>nil do begin
      if ActiveUnitInfo.Component=APersistent then begin
        ActiveSourceEditor:=SourceNoteBook.FindSourceEditorWithPageIndex(
                                                    ActiveUnitInfo.EditorIndex);
        exit;
      end;
      ActiveUnitInfo:=ActiveUnitInfo.NextUnitWithComponent;
    end;
  end;
  ActiveSourceEditor:=nil;
  ActiveUnitInfo:=nil;
end;

function TMainIDE.GetSourceEditorForUnitInfo(AnUnitInfo: TUnitInfo
  ): TSourceEditor;
begin
  Result:=SourceNoteBook.FindSourceEditorWithPageIndex(AnUnitInfo.EditorIndex);
end;

function TMainIDE.DoSaveStreamToFile(AStream:TStream;
  const Filename:string; IsPartOfProject:boolean):TModalResult;
// save to file with backup and user interaction
var AText,ACaption:string;
  NewBuf: TCodeBuffer;
begin
  Result:=DoBackupFile(Filename,IsPartOfProject);
  if Result<>mrOk then exit;
  repeat
    NewBuf:=CodeToolBoss.CreateFile(FileName);
    if (NewBuf<>nil) or (not NewBuf.SaveToFile(Filename)) then begin
      ACaption:=lisCodeToolsDefsWriteError;
      AText:=Format(lisUnableToSaveFile, ['"', Filename, '"']);
      Result:=MessageDlg(ACaption,AText,mterror, [mbabort, mbretry, mbignore],0);
      if Result=mrIgnore then Result:=mrOk;
      if Result=mrAbort then exit;
    end;
  until Result<>mrRetry;
end;

function TMainIDE.DoLoadMemoryStreamFromFile(MemStream: TMemoryStream;
  const AFilename:string): TModalResult;
var FileStream: TFileStream;
  ACaption,AText:string;
begin
  repeat
    try
      FileStream:=TFileStream.Create(AFilename,fmOpenRead);
      try
        FileStream.Position:=0;
        MemStream.CopyFrom(FileStream,FileStream.Size);
        MemStream.Position:=0;
      finally
        FileStream.Free;
      end;
      Result:=mrOk;
    except
      ACaption:=lisReadError;
      AText:=Format(lisUnableToReadFile2, ['"', AFilename, '"']);
      result := Application.MessageBox(PChar(aText),pChar(aCaption),mb_IconError+mb_AbortRetryIgnore);
      if Result=mrAbort then exit;
    end;
  until Result<>mrRetry;
end;

function TMainIDE.DoSaveCodeBufferToFile(ABuffer: TCodeBuffer;
  const AFilename: string; IsPartOfProject:boolean): TModalResult;
var
  ACaption,AText:string;
begin
  Result:=DoBackupFile(AFilename,IsPartOfProject);
  if Result<>mrOk then exit;
  repeat
    if ABuffer.SaveToFile(AFilename) then begin
      Result:=mrOk;
    end else begin
      ACaption:=lisWriteError;
      AText:=Format(lisUnableToWriteToFile, ['"', AFilename, '"']);
      Result:=MessageDlg(ACaption,AText,mtError,[mbAbort, mbRetry, mbIgnore],0);
      if Result=mrAbort then exit;
      if Result=mrIgnore then Result:=mrOk;
    end;
  until Result<>mrRetry;
end;

{-------------------------------------------------------------------------------
  TMainIDE DoBackupFile

  Params:  const Filename:string;
           IsPartOfProject:boolean
  Returns: TModalResult

  Rename existing file to backup file.
-------------------------------------------------------------------------------}
function TMainIDE.DoBackupFile(const Filename:string;
  IsPartOfProject:boolean): TModalResult;
var BackupFilename, CounterFilename: string;
  AText,ACaption:string;
  BackupInfo: TBackupInfo;
  FilePath, FileNameOnly, FileExt, SubDir: string;
  i: integer;
begin
  Result:=mrOk;
  if not (FileExists(Filename)) then exit;
  if IsPartOfProject then
    BackupInfo:=EnvironmentOptions.BackupInfoProjectFiles
  else
    BackupInfo:=EnvironmentOptions.BackupInfoOtherFiles;
  if (BackupInfo.BackupType=bakNone)
  or ((BackupInfo.BackupType=bakSameName) and (BackupInfo.SubDirectory='')) then
    exit;
  FilePath:=ExtractFilePath(Filename);
  FileExt:=ExtractFileExt(Filename);
  FileNameOnly:=ExtractFilenameOnly(Filename);
  if BackupInfo.SubDirectory<>'' then begin
    SubDir:=FilePath+BackupInfo.SubDirectory;
    repeat
      if not DirPathExists(SubDir) then begin
        if not CreateDir(SubDir) then begin
          Result:=MessageDlg(Format(lisUnableToCreateBackupDirectory, ['"',
            SubDir, '"'])
                ,mtWarning,[mbAbort,mbRetry,mbIgnore],0);
          if Result=mrAbort then exit;
          if Result=mrIgnore then Result:=mrOk;
        end;
      end;
    until Result<>mrRetry;
  end;
  if BackupInfo.BackupType in
     [bakSymbolInFront,bakSymbolBehind,bakUserDefinedAddExt,bakSameName] then
  begin
    case BackupInfo.BackupType of
      bakSymbolInFront:
        BackupFilename:=FileNameOnly+'.~'+copy(FileExt,2,length(FileExt)-1);
      bakSymbolBehind:
        BackupFilename:=FileNameOnly+FileExt+'~';
      bakUserDefinedAddExt:
        BackupFilename:=FileNameOnly+FileExt+'.'+BackupInfo.AdditionalExtension;
      bakSameName:
        BackupFilename:=FileNameOnly+FileExt;
    end;
    if BackupInfo.SubDirectory<>'' then
      BackupFilename:=SubDir+PathDelim+BackupFilename
    else
      BackupFilename:=FilePath+BackupFilename;
    // remove old backup file
    repeat
      if FileExists(BackupFilename) then begin
        if not DeleteFile(BackupFilename) then begin
          ACaption:=lisDeleteFileFailed;
          AText:=Format(lisUnableToRemoveOldBackupFile, ['"', BackupFilename,
            '"']);
          Result:=MessageDlg(ACaption,AText,mtError,[mbAbort,mbRetry,mbIgnore],
                             0);
          if Result=mrAbort then exit;
          if Result=mrIgnore then Result:=mrOk;
        end;
      end;
    until Result<>mrRetry;
  end else begin
    // backup with counter
    if BackupInfo.SubDirectory<>'' then
      BackupFilename:=SubDir+PathDelim+FileNameOnly+FileExt+';'
    else
      BackupFilename:=Filename+';';
    if BackupInfo.MaxCounter<=0 then begin
      // search first non existing backup filename
      i:=1;
      while FileExists(BackupFilename+IntToStr(i)) do inc(i);
      BackupFilename:=BackupFilename+IntToStr(i);
    end else begin
      // rename all backup files (increase number)
      i:=1;
      while FileExists(BackupFilename+IntToStr(i))
      and (i<=BackupInfo.MaxCounter) do inc(i);
      if i>BackupInfo.MaxCounter then begin
        dec(i);
        CounterFilename:=BackupFilename+IntToStr(BackupInfo.MaxCounter);
        // remove old backup file
        repeat
          if FileExists(CounterFilename) then begin
            if not DeleteFile(CounterFilename) then begin
              ACaption:=lisDeleteFileFailed;
              AText:=Format(lisUnableToRemoveOldBackupFile, ['"',
                CounterFilename, '"']);
              Result:=MessageDlg(ACaption,AText,mtError,
                                 [mbAbort,mbRetry,mbIgnore],0);
              if Result=mrAbort then exit;
              if Result=mrIgnore then Result:=mrOk;
            end;
          end;
        until Result<>mrRetry;
      end;
      // rename all old backup files
      dec(i);
      while i>=1 do begin
        repeat
          if not RenameFile(BackupFilename+IntToStr(i),
             BackupFilename+IntToStr(i+1)) then
          begin
            ACaption:=lisRenameFileFailed;
            AText:=Format(lisUnableToRenameFileTo, ['"', BackupFilename+IntToStr
              (i), '"', '"', BackupFilename+IntToStr(i+1), '"']);
            Result:=MessageDlg(ACaption,AText,mtError,
                               [mbAbort,mbRetry,mbIgnore],0);
            if Result=mrAbort then exit;
            if Result=mrIgnore then Result:=mrOk;
          end;
        until Result<>mrRetry;
        dec(i);
      end;
      BackupFilename:=BackupFilename+'1';
    end;
  end;
  // backup file
  repeat
    if not BackupFile(Filename,BackupFilename) then begin
      ACaption:=lisBackupFileFailed;
      AText:=Format(lisUnableToBackupFileTo, ['"', Filename, '"', '"',
        BackupFilename, '"']);
      Result:=MessageDlg(ACaption,AText,mterror,[mbabort,mbretry,mbignore],0);
      if Result=mrAbort then exit;
      if Result=mrIgnore then Result:=mrOk;
    end;
  until Result<>mrRetry;
end;

function TMainIDE.DoRenameUnitLowerCase(AnUnitInfo: TUnitInfo;
  AskUser: boolean): TModalresult;
var
  OldFilename: String;
  OldShortFilename: String;
  NewFilename: String;
  NewShortFilename: String;
  ResourceCode: TCodeBuffer;
  NewUnitName: String;
begin
  Result:=mrOk;
  OldFilename:=AnUnitInfo.Filename;
  // check if file is unit
  if not FilenameIsPascalUnit(OldFilename) then exit;
  // check if file is already lowercase (or it does not matter in current OS)
  OldShortFilename:=ExtractFilename(OldFilename);
  NewShortFilename:=lowercase(OldShortFilename);
  if CompareFilenames(OldShortFilename,NewShortFilename)=0 then exit;
  // create new filename
  NewFilename:=ExtractFilePath(OldFilename)+NewShortFilename;

  // rename unit
  if AskUser then begin
    Result:=MessageDlg(lisFileNotLowercase,
      Format(lisTheUnitIsNotLowercaseTheFreePascalCompiler10XNeeds, ['"',
        OldFilename, '"', #13, #13, #13]),
      mtConfirmation,[mbYes,mbNo,mbAbort],0);
    if Result=mrNo then Result:=mrIgnore;
    if Result<>mrYes then exit;
  end;
  NewUnitName:=AnUnitInfo.UnitName;
  if NewUnitName='' then begin
    AnUnitInfo.ReadUnitNameFromSource(false);
    NewUnitName:=AnUnitInfo.CreateUnitName;
  end;
  ResourceCode:=nil;
  Result:=DoRenameUnit(AnUnitInfo,NewFilename,NewUnitName,ResourceCode);
end;

function TMainIDE.DoCheckFilesOnDisk: TModalResult;
var
  AnUnitList: TList; // list of TUnitInfo
  i: integer;
  CurUnit: TUnitInfo;
begin
  Result:=mrOk;
  if Project1=nil then exit;
  InvalidateFileStateCache;
  Project1.GetUnitsChangedOnDisk(AnUnitList);
  if AnUnitList=nil then exit;
  Result:=ShowDiskDiffsDialog(AnUnitList);
  if Result in [mrYesToAll] then
    Result:=mrOk;
  for i:=0 to AnUnitList.Count-1 do begin
    CurUnit:=TUnitInfo(AnUnitList[i]);
    if Result=mrOk then begin
      if CurUnit.EditorIndex>=0 then begin
        Result:=DoOpenEditorFile('',CurUnit.EditorIndex,[ofRevert]);
      end else if CurUnit.IsMainUnit then begin
        Result:=DoRevertMainUnit;
      end else
        Result:=mrIgnore;
      if Result=mrAbort then exit;
    end else begin
      CurUnit.IgnoreCurrentFileDateOnDisk;
    end;
    Result:=mrOk;
  end;
  AnUnitList.Free;
end;

function TMainIDE.DoPublishModule(Options: TPublishModuleOptions;
  const SrcDirectory, DestDirectory: string): TModalResult;
var
  SrcDir, DestDir: string;
  NewProjectFilename: string;
  Tool: TExternalToolOptions;
  CommandAfter, CmdAfterExe, CmdAfterParams: string;
  CurProject: TProject;

  procedure ShowErrorForCommandAfter;
  begin
    MessageDlg(lisInvalidCommand,
      Format(lisTheCommandAfterIsNotExecutable, ['"', CmdAfterExe, '"']),
      mtError,[mbCancel],0);
  end;

begin
  //DebugLn('TMainIDE.DoPublishModule A');
  Result:=mrCancel;

  // to not delete project files
  DestDir:=TrimFilename(AppendPathDelim(DestDirectory));
  SrcDir:=TrimFilename(AppendPathDelim(SrcDirectory));
  if (DestDir='') then begin
    MessageDlg('Invalid publishing Directory',
      'Destination directory for publishing is empty.',mtError,
      [mbCancel],0);
    Result:=mrCancel;
    exit;
  end;
  //DebugLn('TMainIDE.DoPublishModule A SrcDir="',SrcDir,'" DestDir="',DestDir,'"');
  if CompareFilenames(CleanAndExpandDirectory(SrcDir),
                      CleanAndExpandDirectory(DestDir))=0
  then begin
    MessageDlg('Invalid publishing Directory',
      'Source directory "'+SrcDir+'"'#13
      +'and destination directory "'+DestDir+'"'#13
      +'are the same.'#13
      +#13
      +'Maybe you misunderstand this feature.'#13
      +'It will clean/recreate the destination directory'#13
      +'and copies the package/project into it.',mtError,[mbCancel],0);
    Result:=mrCancel;
    exit;
  end;
  
  // check command after
  CommandAfter:=Options.CommandAfter;
  if not MacroList.SubstituteStr(CommandAfter) then begin
    Result:=mrCancel;
    exit;
  end;
  SplitCmdLine(CommandAfter,CmdAfterExe,CmdAfterParams);
  if (CmdAfterExe<>'') then begin
    //DebugLn('TMainIDE.DoPublishModule A CmdAfterExe="',CmdAfterExe,'"');
    CmdAfterExe:=FindDefaultExecutablePath(CmdAfterExe);
    if not FileIsExecutableCached(CmdAfterExe) then begin
      MessageDlg(lisCommandAfterInvalid,
        Format(lisTheCommandAfterPublishingIsInvalid, [#13, '"', CmdAfterExe,
          '"']), mtError, [mbCancel], 0);
      Result:=mrCancel;
      exit;
    end;
  end;

  // clear destination directory
  if DirPathExists(DestDir) then begin
    if (not DeleteDirectory(ChompPathDelim(DestDir),true)) then begin
      MessageDlg(lisUnableToCleanUpDestinationDirectory,
        Format(lisUnableToCleanUpPleaseCheckPermissions, ['"', DestDir, '"', #13]
          ),
        mtError,[mbOk],0);
      Result:=mrCancel;
      exit;
    end;
  end;

  // copy the directory
  if not CopyDirectoryWithMethods(SrcDir,DestDir,
    @OnCopyFile,@OnCopyError,Options) then
  begin
    debugln('TMainIDE.DoPublishModule CopyDirectoryWithMethods failed');
    Result:=mrCancel;
    exit;
  end;

  // write a filtered .lpi file
  if Options is TPublishProjectOptions then begin
    CurProject:=TProject(TPublishProjectOptions(Options).Owner);
    NewProjectFilename:=DestDir+ExtractFilename(CurProject.ProjectInfoFile);
    DeleteFile(NewProjectFilename);
    Result:=CurProject.WriteProject(CurProject.PublishOptions.WriteFlags
                                   +[pwfSkipDebuggerSettings,pwfSkipJumpPoints],
                                   NewProjectFilename);
    if Result<>mrOk then begin
      debugln('TMainIDE.DoPublishModule CurProject.WriteProject failed');
      exit;
    end;
  end;

  // execute 'CommandAfter'
  if (CmdAfterExe<>'') then begin
    if FileIsExecutableCached(CmdAfterExe) then begin
      Tool:=TExternalToolOptions.Create;
      Tool.Filename:=CmdAfterExe;
      Tool.Title:=lisCommandAfterPublishingModule;
      Tool.WorkingDirectory:=DestDir;
      Tool.CmdLineParams:=CmdAfterParams;
      Result:=EnvironmentOptions.ExternalTools.Run(Tool,MacroList);
      if Result<>mrOk then exit;
    end else begin
      ShowErrorForCommandAfter;
      Result:=mrCancel;
      exit;
    end;
  end;
end;

procedure TMainIDE.UpdateCaption;
var NewCaption: string;
begin
  if MainIDEBar=nil then exit;
  NewCaption := Format(lisLazarusEditorV, [lisLazarusVersionString]);
  if Project1<>nil then begin
    if Project1.Title<>'' then
      NewCaption:=NewCaption +' - '+Project1.Title
    else if Project1.ProjectInfoFile<>'' then
      NewCaption:=NewCaption+' - '+ExtractFileName(Project1.ProjectInfoFile)
    else
      NewCaption:=Format(lisnewProject, [NewCaption])
  end;
  case ToolStatus of
  itBuilder:  NewCaption:=Format(liscompiling, [NewCaption]);
  itDebugger: NewCaption:=Format(lisdebugging, [NewCaption]);
  end;
  MainIDEBar.Caption:=NewCaption;
end;

procedure TMainIDE.HideIDE;
var
  i: Integer;
  AForm: TCustomForm;
begin
  // hide hints
  Application.HideHint;
  SourceNotebook.HideHint;

  // hide designer forms
  HideUnmodifiedDesigners;

  // collect all windows except the main bar
  for i:=0 to Screen.CustomFormCount-1 do begin
    AForm:=Screen.CustomForms[i];
    if (AForm<>MainIDEBar)                    // ignore the main bar
    and (AForm.Designer=nil)                  // ignore designer forms
    and (AForm.Visible)                       // ignore hidden forms
    and (not (fsModal in AForm.FormState))    // ignore modal forms
    and (HiddenWindowsOnRun.IndexOf(AForm)<0) // ignore already collected forms
    then
      HiddenWindowsOnRun.Add(AForm);
  end;

  // hide all collected windows
  for i:=0 to HiddenWindowsOnRun.Count-1 do begin
    AForm:=TCustomForm(HiddenWindowsOnRun[i]);
    if not (csDesigning in ComponentState) then
      AForm.Hide;
  end;
  
  // minimize IDE
  MainIDEBar.HideIDE;
end;

procedure TMainIDE.HideUnmodifiedDesigners;
var
  AnUnitInfo: TUnitInfo;
  NextUnitInfo: TUnitInfo;
begin
  AnUnitInfo:=Project1.FirstUnitWithComponent;
  while AnUnitInfo<>nil do begin
    NextUnitInfo:=AnUnitInfo.NextUnitWithComponent;
    if not AnUnitInfo.NeedsSaveToDisk then
      CloseDesignerForm(AnUnitInfo);
    AnUnitInfo:=NextUnitInfo;
  end;
end;

procedure TMainIDE.UnhideIDE;
var
  AForm: TCustomForm;
begin
  // unminimize IDE
  MainIDEBar.UnhideIDE;

  // show other windows
  while HiddenWindowsOnRun.Count>0 do begin
    AForm:=TCustomForm(HiddenWindowsOnRun[0]);
    if (csDesigning in ComponentState) then
      ShowDesignerForm(AForm)
    else
      AForm.Show;
    HiddenWindowsOnRun.Delete(0);
  end;
end;

procedure TMainIDE.DoBringToFrontFormOrUnit;
begin
  if FDisplayState = dsSource then begin
    DoShowDesignerFormOfCurrentSrc;
  end else begin
    DoShowSourceOfActiveDesignerForm;
  end;
end;

procedure TMainIDE.DoBringToFrontFormOrInspector(ForceInspector: boolean);

  procedure ShowInspector;
  begin
    if ObjectInspector1=nil then exit;
    ObjectInspector1.ShowOnTop;
    FDisplayState:= Succ(FDisplayState);
  end;

begin
  if ForceInspector then begin
    ShowInspector;
    exit;
  end;
  case FDisplayState of

    dsInspector:
      DoShowDesignerFormOfCurrentSrc;

    dsInspector2:
      DoShowSourceOfActiveDesignerForm;

    else
      ShowInspector;
  end;
end;

procedure TMainIDE.DoShowDesignerFormOfCurrentSrc;
var
  ActiveSourceEditor: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  AForm: TCustomForm;
begin
  GetCurrentUnit(ActiveSourceEditor,ActiveUnitInfo);
  if (ActiveUnitInfo = nil) then exit;
  // load the form, if not already done
  AForm:=GetFormOfSource(ActiveUnitInfo,true);
  if AForm=nil then exit;
  FDisplayState:= dsForm;
  FLastFormActivated:=AForm;
  ShowDesignerForm(AForm);
  if TheControlSelection.SelectionForm<>AForm then begin
    // select the new form (object inspector, formeditor, control selection)
    TheControlSelection.AssignPersistent(ActiveUnitInfo.Component);
  end;
end;

procedure TMainIDE.DoShowSourceOfActiveDesignerForm;
var
  ActiveUnitInfo: TUnitInfo;
begin
  if SourceNoteBook.NoteBook = nil then exit;
  if FLastFormActivated <> nil then begin
    ActiveUnitInfo:= Project1.UnitWithComponent(FLastFormActivated);
    if (ActiveUnitInfo <> nil) and (ActiveUnitInfo.EditorIndex >= 0) then
    begin
      SourceNotebook.Notebook.PageIndex:= ActiveUnitInfo.EditorIndex;
    end;
  end;
  SourceNoteBook.ShowOnTop;
  FDisplayState:= dsSource;
end;

procedure TMainIDE.OnMacroSubstitution(TheMacro: TTransferMacro; var s:string;
  var Handled, Abort: boolean);
var MacroName:string;
begin
  if TheMacro=nil then begin
    DebugLn('WARNING: Macro not defined: "'+s+'".');
    s:='';
    //MessageDlg('Unknown Macro','Macro not defined: "'+s+'".',mtError,[mbAbort],0);
    Handled:=true;
    exit;
  end;
  MacroName:=lowercase(TheMacro.Name);
  Handled:=true;
  if MacroName='save' then begin
    if (SourceNoteBook<>nil) and (SourceNoteBook.NoteBook<>nil) then
      Abort:=(DoSaveEditorFile(SourceNoteBook.NoteBook.PageIndex,
              [sfCheckAmbiguousFiles])<>mrOk);
    s:='';
  end else if MacroName='saveall' then begin
    Abort:=(DoSaveAll([sfCheckAmbiguousFiles])<>mrOk);
    s:='';
  end else if MacroName='edfile' then begin
    if (SourceNoteBook<>nil) and (SourceNoteBook.NoteBook<>nil) then
      s:=Project1.UnitWithEditorIndex(SourceNoteBook.NoteBook.PageIndex).Filename
    else
      s:='';
  end else if MacroName='col' then begin
    if (SourceNoteBook<>nil) and (SourceNoteBook.NoteBook<>nil) then
      s:=IntToStr(SourceNoteBook.GetActiveSE.EditorComponent.CaretX);
  end else if MacroName='row' then begin
    if (SourceNoteBook<>nil) and (SourceNoteBook.NoteBook<>nil) then
      s:=IntToStr(SourceNoteBook.GetActiveSE.EditorComponent.CaretY);
  end else if MacroName='projfile' then begin
    if Project1<>nil then
      s:=Project1.MainFilename
    else
      s:='';
  end else if MacroName='projpath' then begin
    if Project1<>nil then
      s:=Project1.ProjectDirectory
    else
      s:='';
  end else if MacroName='projunitpath' then begin
    if Project1<>nil then
      s:=Project1.CompilerOptions.GetUnitPath(false)
    else
      s:='';
  end else if MacroName='projincpath' then begin
    if Project1<>nil then
      s:=Project1.CompilerOptions.GetIncludePath(false)
    else
      s:='';
  end else if MacroName='projsrcpath' then begin
    if Project1<>nil then
      s:=Project1.CompilerOptions.GetSrcPath(false)
    else
      s:='';
  end else if MacroName='projpublishdir' then begin
    if Project1<>nil then
      s:=Project1.PublishOptions.DestinationDirectory
    else
      s:='';
  end else if MacroName='curtoken' then begin
    if (SourceNoteBook<>nil) and (SourceNoteBook.NoteBook<>nil) then
      with SourceNoteBook.GetActiveSE.EditorComponent do
        s:=GetWordAtRowCol(LogicalCaretXY);
  end else if MacroName='lazarusdir' then begin
    s:=EnvironmentOptions.LazarusDirectory;
  end else if MacroName='lclwidgettype' then begin
    if Project1<>nil then
      s:=Project1.CompilerOptions.LCLWidgetType
    else
      s:='';
    if (s='') or (s='default') then s:=GetDefaultLCLWidgetType;
  end else if MacroName='targetcpu' then begin
    if Project1<>nil then
      s:=lowercase(Project1.CompilerOptions.TargetCPU)
    else
      s:='';
    if (s='') or (s='default') then s:=GetDefaultTargetCPU;
  end else if MacroName='targetos' then begin
    if Project1<>nil then
      s:=lowercase(Project1.CompilerOptions.TargetOS)
    else
      s:='';
    if (s='') or (s='default') then s:=GetDefaultTargetOS;
  end else if MacroName='fpcsrcdir' then begin
    s:=EnvironmentOptions.FPCSourceDirectory;
  end else if MacroName='comppath' then begin
    s:=EnvironmentOptions.CompilerFilename;
  end else if MacroName='params' then begin
    if Project1<>nil then
      s:=Project1.RunParameterOptions.CmdLineParams
    else
      s:='';
  end else if MacroName='targetfile' then begin
    if Project1<>nil then
      s:=GetProjectTargetFilename
    else
      s:='';
  end else if MacroName='targetcmdline' then begin
    if Project1<>nil then begin
      s:=Project1.RunParameterOptions.CmdLineParams;
      if s='' then
        s:=GetProjectTargetFilename
      else
        s:=GetProjectTargetFilename+' '+s;
    end else
      s:='';
  end else if MacroName='testdir' then begin
    if Project1<>nil then
      s:=GetTestBuildDir
    else
      s:='';
  end else if MacroName='runcmdline' then begin
    if Project1<>nil then
      s:=GetRunCommandLine
    else
      s:='';
  end else if MacroName='projpublishdir' then begin
    if Project1<>nil then
      s:=GetProjPublishDir
    else
      s:='';
  end else if MacroName='confdir' then begin
    s:=GetPrimaryConfigPath;
  end else
    Handled:=false;
end;

function TMainIDE.OnSubstituteCompilerOption(Options: TParsedCompilerOptions;
  const UnparsedValue: string): string;
begin
  CurrentParsedCompilerOption:=Options;
  Result:=UnparsedValue;
  MacroList.SubstituteStr(Result);
end;

function TMainIDE.OnMacroPromptFunction(const s:string;
  var Abort: boolean):string;
begin
  Result:=s;
  Abort:=(ShowMacroPromptDialog(Result)<>mrOk);
end;

function TMainIDE.OnMacroFuncMakeExe(const Filename: string; var Abort: boolean
  ): string;
var
  OldExt: String;
  ExeExt: String;
begin
  Result:=Filename;
  OldExt:=ExtractFileExt(Filename);
  ExeExt:=LazConf.GetDefaultExecutableExt;
  if OldExt<>ExeExt then
    Result:=copy(Result,1,length(Result)-length(OldExt))+ExeExt;
  DebugLn('TMainIDE.OnMacroFuncMakeExe A ',Filename,' ',Result);
end;

procedure TMainIDE.OnCmdLineCreate(var CmdLine: string; var Abort:boolean);
// replace all transfer macros in command line
begin
  Abort:=not MacroList.SubstituteStr(CmdLine);
end;

procedure TMainIDE.GetIDEFileState(Sender: TObject; const AFilename: string;
  NeededFlags: TIDEFileStateFlags; var ResultFlags: TIDEFileStateFlags);
var
  AnUnitInfo: TUnitInfo;
begin
  ResultFlags:=[];
  AnUnitInfo:=Project1.UnitInfoWithFilename(AFilename);
  if AnUnitInfo<>nil then begin
    // readonly
    if (ifsReadOnly in NeededFlags) and AnUnitInfo.ReadOnly then
      Include(ResultFlags,ifsReadOnly);
    // part of project
    if (ifsPartOfProject in NeededFlags) and AnUnitInfo.IsPartOfProject then
      Include(ResultFlags,ifsPartOfProject);
    // open in editor
    if (ifsOpenInEditor in NeededFlags) and (AnUnitInfo.EditorIndex>=0) then
      Include(ResultFlags,ifsOpenInEditor);
  end else if FileExists(AFilename) then begin
    // readonly
    if (ifsReadOnly in NeededFlags) and (not FileIsWritable(AFilename)) then
      Include(ResultFlags,ifsReadOnly);
  end;
end;

function TMainIDE.DoJumpToCompilerMessage(Index:integer;
  FocusEditor: boolean): boolean;
var MaxMessages: integer;
  Filename, SearchedFilename: string;
  LogCaretXY: TPoint;
  TopLine: integer;
  MsgType: TErrorType;
  SrcEdit: TSourceEditor;
  OpenFlags: TOpenFlags;
  CurMsg, CurDir: string;
  NewFilename: String;
begin
  Result:=false;
  MaxMessages:=MessagesView.VisibleItemCount;
  if Index>=MaxMessages then exit;
  if (Index<0) then begin
    // search relevant message (first error, first fatal)
    Index:=0;
    while (Index<MaxMessages) do begin
      CurMsg:=MessagesView.VisibleItems[Index].Msg;
      if (TheOutputFilter.GetSourcePosition(
        CurMsg,Filename,LogCaretXY,MsgType)) then
      begin
        if MsgType in [etError,etFatal,etPanic] then break;
      end;
      inc(Index);
    end;
    if Index>=MaxMessages then exit;
    MessagesView.SelectedMessageIndex:=Index;
  end;
  MessagesView.GetVisibleMessageAt(Index,CurMsg,CurDir);
  if TheOutputFilter.GetSourcePosition(CurMsg,Filename,LogCaretXY,MsgType)
  then begin
    if (not FilenameIsAbsolute(Filename)) and (CurDir<>'') then begin
      // the directory was just hidden, re-append it
      NewFilename:=AppendPathDelim(CurDir)+Filename;
      if FileExists(NewFilename) then
        Filename:=NewFilename;
    end;

    OpenFlags:=[ofOnlyIfExists,ofRegularFile];
    if IsTestUnitFilename(Filename) then begin
      SearchedFilename := ExtractFileName(Filename);
      Include(OpenFlags,ofVirtualFile);
    end else begin
      SearchedFilename := FindUnitFile(Filename);
      if not FilenameIsAbsolute(SearchedFilename) then
        Include(OpenFlags,ofVirtualFile);
    end;

    if SearchedFilename<>'' then begin
      // open the file in the source editor
      Result:=(DoOpenEditorFile(SearchedFilename,-1,OpenFlags)=mrOk);
      if Result then begin
        // set caret position
        SourceNotebook.AddJumpPointClicked(Self);
        SrcEdit:=SourceNoteBook.GetActiveSE;
        if LogCaretXY.Y>SrcEdit.EditorComponent.Lines.Count then
          LogCaretXY.Y:=SrcEdit.EditorComponent.Lines.Count;
        TopLine:=LogCaretXY.Y-(SrcEdit.EditorComponent.LinesInWindow div 2);
        if TopLine<1 then TopLine:=1;
        if FocusEditor then begin
          //SourceNotebook.BringToFront;
          MessagesView.ShowOnTop;
          SourceNoteBook.ShowOnTop;
          SourceNotebook.FocusEditor;
        end;
        SrcEdit.EditorComponent.LogicalCaretXY:=LogCaretXY;
        SrcEdit.EditorComponent.TopLine:=TopLine;
        with SrcEdit.EditorComponent do begin
          BlockBegin:=LogCaretXY;
          BlockEnd:=LogCaretXY;
          LeftChar:=Max(LogCaretXY.X-CharsInWindow,1);
        end;
        SrcEdit.ErrorLine:=LogCaretXY.Y;
      end;
    end else begin
      if FilenameIsAbsolute(Filename) then begin
        MessageDlg(Format(lisUnableToFindFile, ['"', Filename, '"']),
           mtInformation,[mbOk],0)
      end else begin
        MessageDlg(Format(
          lisUnableToFindFileCheckSearchPathInProjectCompilerOption, ['"',
          Filename, '"', #13, #13]),
           mtInformation,[mbOk],0);
      end;
    end;
  end;
end;

procedure TMainIDE.DoJumpToNextError(DirectionDown: boolean);
var
  Index: integer;
  MaxMessages: integer;
  CurMsg: String;
  Filename: string;
  LogCaretXY: TPoint;
  MsgType: TErrorType;
  OldIndex: integer;
  RoundCount: Integer;
begin
  // search relevant message (next error, fatal or panic)
  MaxMessages:=MessagesView.VisibleItemCount;
  OldIndex:=MessagesView.SelectedMessageIndex;
  Index:=OldIndex;
  RoundCount:=0;
  while (Index>=0) and (Index<MaxMessages) do begin
    // goto to next message
    if DirectionDown then begin
      inc(Index);
      if Index>=MaxMessages then begin
        inc(RoundCount);
        Index:=0;
      end;
    end else begin
      dec(Index);
      if Index<0 then begin
        inc(RoundCount);
        Index:=MaxMessages-1;
      end;
    end;
    if(Index=OldIndex) or (RoundCount>1) then exit;

    // check if it is an error
    CurMsg:=MessagesView.VisibleItems[Index].Msg;
    if (TheOutputFilter.GetSourcePosition(
      CurMsg,Filename,LogCaretXY,MsgType)) then
    begin
      if MsgType in [etError,etFatal,etPanic] then break;
    end;
  end;
  MessagesView.SelectedMessageIndex:=Index;
  DoJumpToCompilerMessage(Index,true);
end;

function TMainIDE.DoJumpToSearchResult(FocusEditor: boolean): boolean;
var
  AFileName: string;
  SearchedFilename: string;
  LogCaretXY: TPoint;
  TopLine: integer;
  OpenFlags: TOpenFlags;
  SrcEdit: TSourceEditor;
begin
  Result:=false;
  CreateSearchResultWindow;
  if pos('(',SearchResultsView.GetSelectedText) > 0 then
  begin
    AFileName:= SearchResultsView.GetSourceFileName;
    if AFilename='' then exit;
    LogCaretXY:= SearchResultsView.GetSourcePositon;
    OpenFlags:=[ofOnlyIfExists,ofRegularFile];
    if IsTestUnitFilename(AFilename) then begin
      SearchedFilename := ExtractFileName(AFilename);
      Include(OpenFlags,ofVirtualFile);
    end else begin
      SearchedFilename := FindUnitFile(AFilename);
    end;
    if SearchedFilename<>'' then begin
      // open the file in the source editor
      Result:=(DoOpenEditorFile(SearchedFilename,-1,OpenFlags)=mrOk);
      if Result then begin
        // set caret position
        SourceNotebook.AddJumpPointClicked(Self);
        SrcEdit:=SourceNoteBook.GetActiveSE;
        if LogCaretXY.Y>SrcEdit.EditorComponent.Lines.Count then
          LogCaretXY.Y:=SrcEdit.EditorComponent.Lines.Count;
        TopLine:=LogCaretXY.Y-(SrcEdit.EditorComponent.LinesInWindow div 2);
        if TopLine<1 then TopLine:=1;
        if FocusEditor then begin
          //SourceNotebook.BringToFront;
          SearchResultsView.ShowOnTop;
          SourceNoteBook.ShowOnTop;
          SourceNotebook.FocusEditor;
        end;
        SrcEdit.EditorComponent.LogicalCaretXY:=LogCaretXY;
        SrcEdit.EditorComponent.TopLine:=TopLine;
        with SrcEdit.EditorComponent do begin
          BlockBegin:=LogCaretXY;
          BlockEnd:=LogCaretXY;
          LeftChar:= Math.Max(LogCaretXY.X-CharsInWindow,1);
        end;
        SrcEdit.ErrorLine:=LogCaretXY.Y;
      end;
    end else if AFilename<>'' then begin
      if FilenameIsAbsolute(AFilename) then begin
        MessageDlg(Format(lisUnableToFindFile, ['"', AFilename, '"']),
           mtInformation,[mbOk],0)
      end else begin
        MessageDlg(Format(
          lisUnableToFindFileCheckSearchPathInProjectCompilerOption, ['"',
          AFilename, '"', #13, #13]),
           mtInformation,[mbOk],0);
      end;
    end;
  end;//if
end;


procedure TMainIDE.DoShowMessagesView;
var
  WasVisible: boolean;
  ALayout: TIDEWindowLayout;
begin
  //debugln('TMainIDE.DoShowMessagesView');
  WasVisible:=MessagesView.Visible;
  MessagesView.Visible:=true;
  ALayout:=EnvironmentOptions.IDEWindowLayoutList.
                                               ItemByEnum(nmiwMessagesViewName);
  ALayout.Apply;
  if not WasVisible then
    // the sourcenotebook is more interesting than the messages
    // TODO: don't do this when messages content intersect the editor content
    SourceNotebook.ShowOnTop;

  //set the event here for the selectionchanged event
  if not assigned(MessagesView.OnSelectionChanged) then
    MessagesView.OnSelectionChanged := @MessagesViewSelectionChanged;
end;

procedure TMainIDE.DoShowSearchResultsView;
var
  WasVisible: boolean;
  ALayout: TIDEWindowLayout;
begin
  CreateSearchResultWindow;
  WasVisible := SearchResultsView.Visible;
  SearchResultsView.Visible:=true;
  ALayout:=EnvironmentOptions.IDEWindowLayoutList.
    ItemByEnum(nmiwSearchResultsViewName);
  ALayout.Apply;
  if not WasVisible then
    // the sourcenotebook is more interesting than the messages
    SourceNotebook.ShowOnTop;

  //set the event here for the selectionchanged event
  if not assigned(SearchresultsView.OnSelectionChanged) then
    SearchresultsView.OnSelectionChanged := @SearchresultsViewSelectionChanged;
end;

procedure TMainIDE.DoArrangeSourceEditorAndMessageView(PutOnTop: boolean);
begin
  DoShowMessagesView;

  if (iwpDefault=EnvironmentOptions.IDEWindowLayoutList.ItemByEnum(
                                        nmiwSourceNoteBookName).WindowPlacement)
  and ((SourceNotebook.Top+SourceNotebook.Height) > MessagesView.Top) then
    SourceNotebook.Height := Max(50,Min(SourceNotebook.Height,
       MessagesView.Top-SourceNotebook.Top));
  if PutOnTop then begin
    MessagesView.ShowOnTop;
    SourceNotebook.ShowOnTop;
  end;
end;

function TMainIDE.GetTestBuildDir: string;
begin
  Result:=EnvironmentOptions.TestBuildDirectory;
  if (Result='') then exit;
  Result:=AppendPathDelim(Result);
end;

function TMainIDE.GetProjectTargetFilename: string;
begin
  Result:='';
  if Project1=nil then exit;
  Result:=Project1.RunParameterOptions.HostApplicationFilename;
  if Result='' then begin
    if Project1.IsVirtual then
      Result:=GetTestProjectFilename
    else begin
      if Project1.MainUnitID>=0 then begin
        Result:=
          Project1.CompilerOptions.CreateTargetFilename(Project1.MainFilename)
      end;
    end;
  end;
end;

function TMainIDE.GetTargetOS: string;
begin
  result := '';
  if (Project1<>nil) then
    result := lowercase(Project1.CompilerOptions.TargetOS);
  if (result='') or (result='default') then
    result := GetDefaultTargetOS;
end;

function TMainIDE.GetTestProjectFilename: string;
begin
  Result:='';
  if (Project1.MainUnitID<0) then exit;
  Result:=GetTestUnitFilename(Project1.MainUnitInfo);
  if Result='' then exit;
  Result:=Project1.CompilerOptions.CreateTargetFilename(Result);
end;

function TMainIDE.GetTestUnitFilename(AnUnitInfo: TUnitInfo): string;
var TestDir: string;
begin
  Result:='';
  if AnUnitInfo=nil then exit;
  TestDir:=GetTestBuildDir;
  if TestDir='' then exit;
  Result:=ExtractFilename(AnUnitInfo.Filename);
  if Result='' then exit;
  Result:=TestDir+Result;
end;

function TMainIDE.GetTargetUnitFilename(AnUnitInfo: TUnitInfo): string;
begin
  if Project1.IsVirtual then
    Result:=GetTestUnitFilename(AnUnitInfo)
  else
    Result:=AnUnitInfo.Filename;
end;

function TMainIDE.IsTestUnitFilename(const AFilename: string): boolean;
var
  TestDir: string;
begin
  Result:=false;
  if Project1.IsVirtual then begin
    TestDir:=GetTestBuildDir;
    Result:=CompareFileNames(TestDir,ExtractFilePath(AFilename))=0;
  end;
end;

function TMainIDE.GetRunCommandLine: string;
var
  TargetFileName: string;
begin
  if Project1.RunParameterOptions.UseLaunchingApplication then
    Result := Project1.RunParameterOptions.LaunchingApplicationPathPlusParams
  else
    Result := '';

  if Result=''
  then begin
    Result:=Project1.RunParameterOptions.CmdLineParams;
    if MacroList.SubstituteStr(Result) then begin
      TargetFileName:='"'+GetProjectTargetFilename+'"';
      if Result='' then
        Result:=TargetFileName
      else
        Result:=TargetFilename+' '+Result;
    end else
      Result:='';
  end else begin
    if not MacroList.SubstituteStr(Result) then Result:='';
  end;
end;

function TMainIDE.GetProjPublishDir: string;
begin
  Result:=Project1.PublishOptions.DestinationDirectory;
  if MacroList.SubstituteStr(Result) then begin
    if FilenameIsAbsolute(Result) then begin
      Result:=AppendPathDelim(TrimFilename(Result));
    end else begin
      Result:='';
    end;
  end else begin
    Result:='';
  end;
end;

function TMainIDE.FindUnitFile(const AFilename: string): string;
var
  SearchPath, ProjectDir: string;
  AnUnitInfo: TUnitInfo;
begin
  if FilenameIsAbsolute(AFilename) then begin
    Result:=AFilename;
    exit;
  end;
  Result:='';
  if not Project1.IsVirtual then begin
    // ToDo: use the CodeTools way to find the pascal source
    ProjectDir:=Project1.ProjectDirectory;
    SearchPath:=CodeToolBoss.DefineTree.GetUnitPathForDirectory(ProjectDir)
              +';'+CodeToolBoss.DefineTree.GetSrcPathForDirectory(ProjectDir);
    Result:=SearchFileInPath(AFilename,ProjectDir,SearchPath,';',[]);
    if Result<>'' then exit;
  end;
  // search in virtual (unsaved) files
  AnUnitInfo:=Project1.UnitInfoWithFilename(AFilename,
                                   [pfsfOnlyProjectFiles,pfsfOnlyVirtualFiles]);
  if AnUnitInfo<>nil then
    Result:=AnUnitInfo.Filename;
end;

{------------------------------------------------------------------------------
  function TMainIDE.FindSourceFile(const AFilename, BaseDirectory: string;
    Flags: TFindSourceFlags): string;

  AFilename can be an absolute or relative filename, of a source file or a
  compiled unit (.ppu, .ppw).
  Find the source filename (pascal source or include file) and returns
  the absolute path.

  First it searches in the current projects src path, then its unit path, then
  its include path. Then all used package source directories are searched.
  Finally the fpc sources are searched.
------------------------------------------------------------------------------}
function TMainIDE.FindSourceFile(const AFilename, BaseDirectory: string;
  Flags: TFindSourceFlags): string;
var
  CompiledSrcExt: String;
  CompiledFilename: String;
  CurBaseDir: String;
  BaseDir: String;
  AlreadySearchedPaths: string;
  StartUnitPath: String;

  procedure MarkPathAsSearched(const AddSearchPath: string);
  begin
    AlreadySearchedPaths:=MergeSearchPaths(AlreadySearchedPaths,AddSearchPath);
  end;

  function SearchIndirectIncludeFile: string;
  var
    UnitPath: String;
    CurDir: String;
    AlreadySearchedUnitDirs: String;
    CompiledUnitPath: String;
    AllSrcPaths: String;
    CurSrcPath: String;
    CurIncPath: String;
    PathPos: Integer;
    AllIncPaths: String;
    SearchPath: String;
    SearchFile: String;
  begin
    if CompiledSrcExt='' then exit;
    // get unit path for compiled units
    UnitPath:=BaseDir+';'+StartUnitPath;
    UnitPath:=TrimSearchPath(UnitPath,BaseDir);

    // Extract all directories with compiled units
    CompiledUnitPath:='';
    AlreadySearchedUnitDirs:='';
    PathPos:=1;
    while PathPos<=length(UnitPath) do begin
      CurDir:=GetNextDirectoryInSearchPath(UnitPath,PathPos);
      // check if directory is already tested
      if SearchDirectoryInSearchPath(AlreadySearchedUnitDirs,CurDir,1)>0 then
        continue;
      AlreadySearchedUnitDirs:=MergeSearchPaths(AlreadySearchedUnitDirs,CurDir);
      // check if directory contains a compiled unit
      if FindFirstFileWithExt(CurDir,CompiledSrcExt)<>'' then
        CompiledUnitPath:=CompiledUnitPath+';'+CurDir;
    end;
    {$IFDEF VerboseFindSourceFile}
    writeln('TMainIDE.SearchIndirectIncludeFile CompiledUnitPath="',CompiledUnitPath,'"');
    {$ENDIF}

    // collect all src paths for the compiled units
    AllSrcPaths:=CompiledUnitPath;
    PathPos:=1;
    while PathPos<=length(CompiledUnitPath) do begin
      CurDir:=GetNextDirectoryInSearchPath(CompiledUnitPath,PathPos);
      CurSrcPath:=CodeToolBoss.GetCompiledSrcPathForDirectory(CurDir);
      CurSrcPath:=TrimSearchPath(CurSrcPath,CurDir);
      AllSrcPaths:=MergeSearchPaths(AllSrcPaths,CurSrcPath);
    end;
    {$IFDEF VerboseFindSourceFile}
    writeln('TMainIDE.SearchIndirectIncludeFile AllSrcPaths="',AllSrcPaths,'"');
    {$ENDIF}

    // add fpc src directories
    // ToDo

    // collect all include paths
    AllIncPaths:=AllSrcPaths;
    PathPos:=1;
    while PathPos<=length(AllSrcPaths) do begin
      CurDir:=GetNextDirectoryInSearchPath(AllSrcPaths,PathPos);
      CurIncPath:=CodeToolBoss.GetIncludePathForDirectory(CurDir);
      CurIncPath:=TrimSearchPath(CurIncPath,CurDir);
      AllIncPaths:=MergeSearchPaths(AllIncPaths,CurIncPath);
    end;
    {$IFDEF VerboseFindSourceFile}
    writeln('TMainIDE.SearchIndirectIncludeFile AllIncPaths="',AllIncPaths,'"');
    {$ENDIF}

    SearchFile:=AFilename;
    SearchPath:=AllIncPaths;
    Result:=SearchFileInPath(SearchFile,BaseDir,SearchPath,';',[]);
    {$IFDEF VerboseFindSourceFile}
    writeln('TMainIDE.SearchIndirectIncludeFile Result="',Result,'"');
    {$ENDIF}
    MarkPathAsSearched(SearchPath);
  end;
  
  function SearchInPath(const TheSearchPath, SearchFile: string;
    var Filename: string): boolean;
  var
    SearchPath: String;
  begin
    Filename:='';
    SearchPath:=RemoveSearchPaths(TheSearchPath,AlreadySearchedPaths);
    if SearchPath<>'' then begin
      Filename:=SearchFileInPath(SearchFile,BaseDir,SearchPath,';',[]);
      {$IFDEF VerboseFindSourceFile}
      writeln('TMainIDE.FindSourceFile trying "',SearchPath,'" Result=',Result);
      {$ENDIF}
      MarkPathAsSearched(SearchPath);
    end;
    Result:=Filename<>'';
  end;

var
  SearchPath: String;
  SearchFile: String;
begin
  {$IFDEF VerboseFindSourceFile}
  writeln('TMainIDE.FindSourceFile Filename="',AFilename,'" BaseDirectory="',BaseDirectory,'"');
  {$ENDIF}
  if FilenameIsAbsolute(AFilename) then begin
    if FileExists(AFilename) then
      Result:=AFilename
    else
      Result:='';
    exit;
  end;

  AlreadySearchedPaths:='';
  BaseDir:=AppendPathDelim(TrimFilename(BaseDirectory));

  // search file in base directory
  Result:=TrimFilename(BaseDir+AFilename);
  {$IFDEF VerboseFindSourceFile}
  writeln('TMainIDE.FindSourceFile trying Base "',Result,'"');
  {$ENDIF}
  if FileExists(Result) then exit;
  MarkPathAsSearched(BaseDir);

  // search file in debug path
  if fsfUseDebugPath in Flags then begin
    SearchPath:=MergeSearchPaths(Project1.CompilerOptions.DebugPath,
                                 EnvironmentOptions.DebuggerSearchPath);
    SearchPath:=TrimSearchPath(SearchPath,Project1.ProjectDirectory);
    if SearchInPath(SearchPath,AFilename,Result) then exit;
  end;

  CompiledSrcExt:=CodeToolBoss.GetCompiledSrcExtForDirectory(BaseDir);
  if (fsfSearchForProject in Flags)
  and (CompareFilenames(BaseDir,TrimFilename(Project1.ProjectDirectory))=0)
  then
    StartUnitPath:=Project1.CompilerOptions.GetUnitPath(false)
  else
    StartUnitPath:=CodeToolBoss.GetUnitPathForDirectory(BaseDir);
  StartUnitPath:=TrimSearchPath(StartUnitPath,BaseDir);

  // if file is a pascal unit, search via unit and src paths
  if FilenameIsPascalUnit(AFilename) then begin
    // first search file in unit path
    if SearchInPath(StartUnitPath,AFilename,Result) then exit;

    // then search file in SrcPath
    if (fsfSearchForProject in Flags)
    and (CompareFilenames(BaseDir,TrimFilename(Project1.ProjectDirectory))=0)
    then
      SearchPath:=Project1.CompilerOptions.GetSrcPath(false)
    else
      SearchPath:=CodeToolBoss.GetSrcPathForDirectory(BaseDir);
    SearchPath:=TrimSearchPath(SearchPath,BaseDir);
    if SearchInPath(StartUnitPath,AFilename,Result) then exit;

    // search for the compiled version in the
    // unit path and all inherited unit paths
    if CompiledSrcExt<>'' then begin
      SearchFile:=ChangeFileExt(LowerCase(ExtractFilename(AFilename)),
                                CompiledSrcExt);
      SearchPath:=StartUnitPath;
      CompiledFilename:=SearchFileInPath(SearchFile,BaseDir,SearchPath,';',[]);
      {$IFDEF VerboseFindSourceFile}
      writeln('TMainIDE.FindSourceFile trying compiled units in "',SearchPath,'" CompiledFilename=',CompiledFilename);
      {$ENDIF}
      if CompiledFilename<>'' then begin
        // compiled version found -> search for source in CompiledSrcPath
        CurBaseDir:=ExtractFilePath(CompiledFilename);
        SearchPath:=CodeToolBoss.GetCompiledSrcPathForDirectory(CurBaseDir);
        SearchFile:=ExtractFilename(AFilename);
        Result:=SearchFileInPath(SearchFile,CurBaseDir,SearchPath,';',[]);
        {$IFDEF VerboseFindSourceFile}
        writeln('TMainIDE.FindSourceFile trying indirect path "',SearchPath,'" Result=',Result);
        {$ENDIF}
        if Result<>'' then exit;
      end;
    end;

    // search unit in fpc source directory
    Result:=CodeToolBoss.FindUnitInUnitLinks(BaseDir,
                                             ExtractFilenameOnly(AFilename));
    {$IFDEF VerboseFindSourceFile}
    writeln('TMainIDE.FindSourceFile trying unit links Result=',Result);
    {$ENDIF}
    if Result<>'' then exit;
  end;

  if fsfUseIncludePaths in Flags then begin
    // search in include path
    if (fsfSearchForProject in Flags) then
      SearchPath:=Project1.CompilerOptions.GetIncludePath(false)
    else
      SearchPath:=CodeToolBoss.GetIncludePathForDirectory(BaseDir);
    SearchPath:=TrimSearchPath(SearchPath,BaseDir);
    if SearchInPath(StartUnitPath,AFilename,Result) then exit;

    // search include file in source directories of all required packages
    SearchFile:=AFilename;
    Result:=PkgBoss.FindIncludeFileInProjectDependencies(Project1,SearchFile);
    {$IFDEF VerboseFindSourceFile}
    writeln('TMainIDE.FindSourceFile trying packages "',SearchPath,'" Result=',Result);
    {$ENDIF}
    if Result<>'' then exit;

    Result:=SearchIndirectIncludeFile;
    if Result<>'' then exit;
  end;

  Result:='';
end;

function TMainIDE.FileExistsInIDE(const Filename: string;
  SearchFlags: TProjectFileSearchFlags): boolean;
begin
  Result:=FileExists(Filename)
          or (Project1.UnitInfoWithFilename(Filename,SearchFlags)<>nil);
end;

//------------------------------------------------------------------------------

procedure TMainIDE.OnDesignerGetSelectedComponentClass(Sender: TObject;
  var RegisteredComponent: TRegisteredComponent);
begin
  RegisteredComponent:=TComponentPalette(IDEComponentPalette).Selected;
end;

procedure TMainIDE.OnDesignerUnselectComponentClass(Sender: TObject);
begin
  TComponentPalette(IDEComponentPalette).Selected:=nil;
end;

procedure TMainIDE.OnDesignerSetDesigning(Sender: TObject;
  Component: TComponent;  Value: boolean);
begin
  SetDesigning(Component,Value);
end;

procedure TMainIDE.OnDesignerShowOptions(Sender: TObject);
begin
  DoShowEnvGeneralOptions(eodpFormEditor);
end;

procedure TMainIDE.OnDesignerPasteComponent(Sender: TObject;
  LookupRoot: TComponent; TxtCompStream: TStream; ParentControl: TWinControl;
  var NewComponent: TComponent);
var
  NewClassName: String;
  ARegComp: TRegisteredComponent;
  BinCompStream: TMemoryStream;
  CInterface: TComponentInterface;
begin
  DebugLn('TMainIDE.OnDesignerPasteComponent A');
  NewComponent:=nil;

  // check the class of the new component
  NewClassName:=FindLFMClassName(TxtCompStream);

  // check if component class is registered
  ARegComp:=IDEComponentPalette.FindComponent(NewClassName);
  if ARegComp=nil then begin
    MessageDlg(lisClassNotFound,
      Format(lisClassIsNotARegisteredComponentClassUnableToPaste, ['"',
        NewClassName, '"', #13]),
      mtError,[mbCancel],0);
    exit;
  end;

  // check if there is a valid parent
  if (ParentControl=nil) and ARegComp.IsTControl then begin
    MessageDlg(lisControlNeedsParent,
      Format(lisTheClassIsATControlAndCanNotBePastedOntoANonContro, ['"',
        NewClassName, '"', #13]),
      mtError,[mbCancel],0);
    exit;
  end;

  // convert text to binary format
  BinCompStream:=TMemoryStream.Create;
  try
    try
      LRSObjectTextToBinary(TxtCompStream,BinCompStream);
    except
      on E: Exception do begin
        MessageDlg(lisConversionError,
          Format(lisUnableToConvertComponentTextIntoBinaryFormat, [#13,
            E.Message]),
          mtError,[mbCancel],0);
        exit;
      end;
    end;

    BinCompStream.Position:=0;

    // create the component
    CInterface := TComponentInterface(
                     FormEditor1.CreateChildComponentFromStream(BinCompStream,
                     ARegComp.ComponentClass,LookupRoot,ParentControl));
    if CInterface=nil then begin
      DebugLn('TMainIDE.OnDesignerPasteComponent FAILED');
      exit;
    end;
    NewComponent:=CInterface.Component;

  finally
    BinCompStream.Free;
  end;
end;

procedure TMainIDE.OnDesignerPropertiesChanged(Sender: TObject);
begin
  ObjectInspector1.RefreshPropertyValues;
end;

procedure TMainIDE.OnDesignerPersistentAdded(Sender: TObject;
  APersistent: TPersistent; AComponentClass: TRegisteredComponent);
var
  ActiveUnitInfo: TUnitInfo;
  ActiveSrcEdit: TSourceEditor;
  ADesigner: TDesigner;
begin
  if not (Sender is TDesigner) then begin
    DebugLn('TMainIDE.OnDesignerPersistentAdded ERROR: Sender.ClassName=',
            Sender.ClassName);
    exit;
  end;
  if AComponentClass=nil then
    AComponentClass:=IDEComponentPalette.FindComponent(APersistent.ClassName);
  ADesigner:=TDesigner(Sender);
  if not BeginCodeTool(ADesigner,ActiveSrcEdit,ActiveUnitInfo,
    [ctfSwitchToFormSource])
  then exit;

  if AComponentClass<>nil then begin
  // add needed package to required packages
    PkgBoss.AddProjectRegCompDependency(Project1,AComponentClass);
    // add needed unit to source
    CodeToolBoss.AddUnitToMainUsesSection(ActiveUnitInfo.Source,
                                          AComponentClass.GetUnitName,'');
    ActiveUnitInfo.Modified:=true;
    
    // add component definitions to form source
    CodeToolBoss.CompleteComponent(ActiveUnitInfo.Source,ADesigner.LookupRoot);
  end;

  ObjectInspector1.FillPersistentComboBox;
end;

procedure TMainIDE.OnDesignerPersistentDeleted(Sender: TObject;
  APersistent: TPersistent);
var
  CurDesigner: TDesigner;
begin
  CurDesigner:=TDesigner(Sender);
  if dfDestroyingForm in CurDesigner.Flags then exit;
  ObjectInspector1.FillPersistentComboBox;
end;

procedure TMainIDE.OnDesignerRemovePersistent(Sender: TObject;
  APersistent: TPersistent);
var
  ActiveForm: TCustomForm;
  ActiveUnitInfo: TUnitInfo;
  ActiveSrcEdit: TSourceEditor;
  OwnerClassName: string;
  CurDesigner: TDesigner;
begin
  CurDesigner:=TDesigner(Sender);
  if dfDestroyingForm in CurDesigner.Flags then exit;

  if not BeginCodeTool(CurDesigner,ActiveSrcEdit,ActiveUnitInfo,
                [ctfSwitchToFormSource]) then exit;
  ActiveForm:=CurDesigner.Form;
  if ActiveForm=nil then
    RaiseException('[TMainIDE.OnDesignerAddComponent] Error: TDesigner without a form');
  // find source for form
  ActiveUnitInfo:=Project1.UnitWithComponent(CurDesigner.LookupRoot);
  if ActiveUnitInfo=nil then begin
    RaiseException('[TMainIDE.OnDesignerAddComponent] Error: form without source');
  end;
  if APersistent is TComponent then begin
    // remove component definition from owner source
    OwnerClassName:=CurDesigner.LookupRoot.ClassName;
    CodeToolBoss.RemovePublishedVariable(ActiveUnitInfo.Source,OwnerClassName,
                                         TComponent(APersistent).Name,false);
  end;
end;

procedure TMainIDE.OnDesignerModified(Sender: TObject);
var
  SrcEdit: TSourceEditor;
  CurDesigner: TDesigner;
  AnUnitInfo: TUnitInfo;
begin
  CurDesigner:=TDesigner(Sender);
  if dfDestroyingForm in CurDesigner.Flags then exit;
  AnUnitInfo:=Project1.UnitWithComponent(CurDesigner.LookupRoot);
  if AnUnitInfo<>nil then begin
    AnUnitInfo.Modified:=true;
    if AnUnitInfo.Loaded then
      SrcEdit:=SourceNotebook.FindSourceEditorWithPageIndex(
                                                        AnUnitInfo.EditorIndex);
    if SrcEdit<>nil then begin
      SrcEdit.Modified:=true;
      SourceNotebook.UpdateStatusBar;
    end;
  end;
end;

procedure TMainIDE.OnControlSelectionChanged(Sender: TObject);
var
  NewSelection: TPersistentSelectionList;
  i: integer;
begin
  {$IFDEF IDE_DEBUG}
  writeln('[TMainIDE.OnControlSelectionChanged]');
  {$ENDIF}
  if (TheControlSelection=nil) or (FormEditor1=nil) then exit;

  NewSelection:=TPersistentSelectionList.Create;
  for i:=0 to TheControlSelection.Count-1 do
    NewSelection.Add(TheControlSelection[i].Persistent);
  FormEditor1.Selection:=NewSelection;
  NewSelection.Free;
  {$IFDEF IDE_DEBUG}
  writeln('[TMainIDE.OnControlSelectionChanged] END');
  {$ENDIF}
end;

procedure TMainIDE.OnControlSelectionPropsChanged(Sender: TObject);
begin
  if (TheControlSelection=nil) or (FormEditor1=nil) then exit;
  ObjectInspector1.RefreshPropertyValues;
end;

procedure TMainIDE.OnControlSelectionFormChanged(Sender: TObject; OldForm,
  NewForm: TCustomForm);
begin
  if (TheControlSelection=nil) or (FormEditor1=nil) then exit;
  if OldForm<>nil then
    OldForm.Invalidate;
  if NewForm<>nil then
    NewForm.Invalidate;
  UpdateIDEComponentPalette;
end;


// -----------------------------------------------------------------------------

procedure TMainIDE.UnitDependenciesViewAccessingSources(Sender: TObject);
begin
  SaveSourceEditorChangesToCodeCache(-1);
end;

function TMainIDE.UnitDependenciesViewGetProjectMainFilename(Sender: TObject
  ): string;
begin
  if Project1.MainUnitID>=0 then
    Result:=Project1.MainUnitInfo.Filename;
end;

procedure TMainIDE.UnitDependenciesViewOpenFile(Sender: TObject;
  const Filename: string);
begin
  DoOpenEditorFile(Filename,-1,[]);
end;

procedure TMainIDE.OnCodeExplorerGetCodeTree(Sender: TObject;
  var ACodeTool: TCodeTool);
var
  ActiveUnitInfo: TUnitInfo;
  ActiveSrcEdit: TSourceEditor;
begin
  ACodeTool:=nil;
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  CodeToolBoss.Explore(ActiveUnitInfo.Source,ACodeTool,false);
end;

procedure TMainIDE.OnCodeExplorerJumpToCode(Sender: TObject;
  const Filename: string; const Caret: TPoint; TopLine: integer);
begin
  DoJumpToSourcePosition(Filename,Caret.X,Caret.Y,TopLine,true);
end;

procedure TMainIDE.ViewProjectTodosOpenFile(Sender: TObject;
  const Filename: string; const LineNumber: integer);
begin
  DoJumpToSourcePosition(Filename,1,LineNumber,-1,true);
end;

procedure TMainIDE.OnCodeToolNeedsExternalChanges(Manager: TCodeToolManager;
  var Abort: boolean);
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
begin
  Abort:=not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]);
end;

// -----------------------------------------------------------------------------

procedure TMainIDE.InitCodeToolBoss;
// initialize the CodeToolBoss, which is the frontend for the codetools.
//  - sets a basic set of compiler macros

  procedure AddTemplate(ADefTempl: TDefineTemplate; AddToPool: boolean;
    const ErrorMsg: string);
  begin
    if ADefTempl=nil then begin
      DebugLn('');
      DebugLn(ErrorMsg);
    end else begin;
      if AddToPool then
        CodeToolBoss.DefinePool.Add(ADefTempl.CreateCopy(false,true,true));
      CodeToolBoss.DefineTree.Add(ADefTempl);
    end;
  end;

var CompilerUnitSearchPath, CompilerUnitLinks: string;
  ADefTempl: TDefineTemplate;
  c: integer;
  AFilename: string;
  UnitLinksChanged: boolean;
  TargetOS, TargetProcessor: string;
begin
  FOpenEditorsOnCodeToolChange:=false;

  CodeToolBoss.SourceCache.ExpirationTimeInDays:=365;
  CodeToolBoss.DefineTree.OnGetVirtualDirectoryAlias:=
    @CodeToolBossGetVirtualDirectoryAlias;
  CodeToolBoss.DefineTree.OnGetVirtualDirectoryDefines:=
    @CodeToolBossGetVirtualDirectoryDefines;

  CodeToolBoss.DefineTree.MacroFunctions.AddExtended(
    'PROJECT',nil,@MacroFunctionProject);

  CodeToolsOpts.AssignTo(CodeToolBoss);
  if (not FileExists(EnvironmentOptions.CompilerFilename)) then begin
    DebugLn('');
    DebugLn('NOTE: Compiler Filename not set! (see Environment Options)');
  end;

  if (EnvironmentOptions.LazarusDirectory='')
  or not DirPathExists(EnvironmentOptions.LazarusDirectory) then begin
    DebugLn('');
    DebugLn(
      'NOTE: Lazarus Source Directory not set!  (see Environment Options)');
  end;
  if (EnvironmentOptions.FPCSourceDirectory='')
  or not DirPathExists(EnvironmentOptions.FPCSourceDirectory) then begin
    DebugLn('');
    DebugLn('NOTE: FPC Source Directory not set! (see Environment Options)');
  end;

  // set global variables
  with CodeToolBoss.GlobalValues do begin
    Variables[ExternalMacroStart+'LazarusDir']:=
      EnvironmentOptions.LazarusDirectory;
    Variables[ExternalMacroStart+'FPCSrcDir']:=
      EnvironmentOptions.FPCSourceDirectory;
    Variables[ExternalMacroStart+'LCLWidgetType']:=GetDefaultLCLWidgetType;
    Variables[ExternalMacroStart+'ProjPath']:=VirtualDirectory;
  end;

  // build DefinePool and Define Tree
  UpdateEnglishErrorMsgFilename;
  with CodeToolBoss.DefinePool do begin
    // start the compiler and ask for his settings
    TargetOS:='';
    TargetProcessor:='';
    ADefTempl:=CreateFPCTemplate(EnvironmentOptions.CompilerFilename,'',
                       CreateCompilerTestPascalFilename,CompilerUnitSearchPath,
                       TargetOS,TargetProcessor,CodeToolsOpts);
    AddTemplate(ADefTempl,false,
      'NOTE: Could not create Define Template for Free Pascal Compiler');
    CurDefinesCompilerFilename:=EnvironmentOptions.CompilerFilename;
    CurDefinesCompilerOptions:='';

    // create compiler macros to simulate the Makefiles of the FPC sources
    InputHistories.FPCConfigCache.CompilerPath:=
                                            EnvironmentOptions.CompilerFilename;
    CompilerUnitLinks:=InputHistories.FPCConfigCache.GetUnitLinks('');
    UnitLinksChanged:=InputHistories.LastFPCUnitLinksNeedsUpdate('',
                  CompilerUnitSearchPath,EnvironmentOptions.FPCSourceDirectory);
    ADefTempl:=CreateFPCSrcTemplate(
            CodeToolBoss.GlobalValues.Variables[ExternalMacroStart+'FPCSrcDir'],
            CompilerUnitSearchPath,
            CodeToolBoss.GetCompiledSrcExtForDirectory(''),
            TargetOS,TargetProcessor,
            not UnitLinksChanged,CompilerUnitLinks,
            CodeToolsOpts);

    // save unitlinks
    if UnitLinksChanged
    or (CompilerUnitLinks<>InputHistories.FPCConfigCache.GetUnitLinks(''))
    then begin
      InputHistories.SetLastFPCUnitLinks(EnvironmentOptions.CompilerFilename,
                                         '', // default options ''
                                         CompilerUnitSearchPath,
                                         EnvironmentOptions.FPCSourceDirectory,
                                         CompilerUnitLinks);
      InputHistories.Save;
    end;
    AddTemplate(ADefTempl,false,
      lisNOTECouldNotCreateDefineTemplateForFreePascal);

    // create compiler macros for the lazarus sources
    ADefTempl:=CreateLazarusSrcTemplate(
      '$('+ExternalMacroStart+'LazarusDir)',
      '$('+ExternalMacroStart+'LCLWidgetType)',
      MiscellaneousOptions.BuildLazOpts.ExtraOptions,CodeToolsOpts);
    AddTemplate(ADefTempl,true,
      lisNOTECouldNotCreateDefineTemplateForLazarusSources);
  end;

  // load include file relationships
  AFilename:=AppendPathDelim(GetPrimaryConfigPath)+CodeToolsIncludeLinkFile;
  if FileExists(AFilename) then
    CodeToolBoss.SourceCache.LoadIncludeLinksFromFile(AFilename);


  with CodeToolBoss do begin
    WriteExceptions:=true;
    CatchExceptions:=true;
    OnGatherExternalChanges:=@OnCodeToolNeedsExternalChanges;
    OnBeforeApplyChanges:=@OnBeforeCodeToolBossApplyChanges;
    OnAfterApplyChanges:=@OnAfterCodeToolBossApplyChanges;
    OnSearchUsedUnit:=@OnCodeToolBossSearchUsedUnit;
    OnFindDefineProperty:=@OnCodeToolBossFindDefineProperty;
  end;

  CodeToolsOpts.AssignGlobalDefineTemplatesToTree(CodeToolBoss.DefineTree);

  CompilerGraphStampIncreased:=@OnCompilerGraphStampIncreased;

  // codetools consistency check
  c:=CodeToolBoss.ConsistencyCheck;
  if c<>0 then begin
    RaiseException('CodeToolBoss.ConsistencyCheck='+IntToStr(c));
  end;
end;

procedure TMainIDE.RescanCompilerDefines(OnlyIfCompilerChanged: boolean);
var
  CompilerTemplate, FPCSrcTemplate: TDefineTemplate;
  CompilerUnitSearchPath, CompilerUnitLinks: string;
  CurOptions: String;
  TargetOS, TargetProcessor: string;
  UnitLinksValid: boolean;
  i: Integer;
begin
  if Project1.CompilerOptions.TargetOS<>'' then
    CurOptions:='-T'+Project1.CompilerOptions.TargetOS
  else
    CurOptions:='';
  {$IFDEF VerboseFPCSrcScan}
  writeln('TMainIDE.RescanCompilerDefines A ',CurOptions,
    ' OnlyIfCompilerChanged=',OnlyIfCompilerChanged,
    ' Valid=',InputHistories.FPCConfigCache.Valid(true),
    ' ID=',InputHistories.FPCConfigCache.FindItem(CurOptions),
    ' CurDefinesCompilerFilename=',CurDefinesCompilerFilename,
    ' EnvCompilerFilename=',EnvironmentOptions.CompilerFilename,
    ' CurDefinesCompilerOptions="',CurDefinesCompilerOptions,'"',
    ' CurOptions="',CurOptions,'"',
    '');
  {$ENDIF}
  // rescan compiler defines
  // ask the compiler for its settings
  if OnlyIfCompilerChanged
  and (CurDefinesCompilerFilename=EnvironmentOptions.CompilerFilename)
  and (CurDefinesCompilerOptions=CurOptions) then
    exit;
  {$IFDEF VerboseFPCSrcScan}
  writeln('TMainIDE.RescanCompilerDefines B rebuilding FPC templates');
  {$ENDIF}
  CompilerTemplate:=CodeToolBoss.DefinePool.CreateFPCTemplate(
                    EnvironmentOptions.CompilerFilename,CurOptions,
                    CreateCompilerTestPascalFilename,CompilerUnitSearchPath,
                    TargetOS,TargetProcessor,CodeToolsOpts);

  if CompilerTemplate<>nil then begin
    CurDefinesCompilerFilename:=EnvironmentOptions.CompilerFilename;
    CurDefinesCompilerOptions:=CurOptions;
    CodeToolBoss.DefineTree.ReplaceRootSameNameAddFirst(CompilerTemplate);
    UnitLinksValid:=OnlyIfCompilerChanged
                    and InputHistories.FPCConfigCache.Valid(true);
    if UnitLinksValid then begin
      i:=InputHistories.FPCConfigCache.FindItem(CurOptions);
      if i<0 then begin
        UnitLinksValid:=false;
      end else begin
        if CompareFilenames(InputHistories.FPCConfigCache.Items[i].FPCSrcDir,
          EnvironmentOptions.FPCSourceDirectory)<>0 then
        begin
          UnitLinksValid:=false;
        end;
      end;
    end;
    {$IFDEF VerboseFPCSrcScan}
    writeln('TMainIDE.RescanCompilerDefines B rescanning FPC sources  UnitLinksValid=',UnitLinksValid);
    {$ENDIF}

    // create compiler macros to simulate the Makefiles of the FPC sources
    CompilerUnitLinks:='';
    if UnitLinksValid then
      CompilerUnitLinks:=InputHistories.FPCConfigCache.GetUnitLinks(CurOptions);
    FPCSrcTemplate:=CodeToolBoss.DefinePool.CreateFPCSrcTemplate(
      CodeToolBoss.GlobalValues.Variables[ExternalMacroStart+'FPCSrcDir'],
      CompilerUnitSearchPath,
      CodeToolBoss.GetCompiledSrcExtForDirectory(''),
      TargetOS,TargetProcessor,
      UnitLinksValid, CompilerUnitLinks, CodeToolsOpts);
    {$IFDEF VerboseFPCSrcScan}
    writeln('TMainIDE.RescanCompilerDefines C UnitLinks=',copy(CompilerUnitLinks,1,100));
    {$ENDIF}
    if FPCSrcTemplate<>nil then begin
      CodeToolBoss.DefineTree.RemoveRootDefineTemplateByName(
                                                           FPCSrcTemplate.Name);
      FPCSrcTemplate.InsertBehind(CompilerTemplate);
      CodeToolBoss.DefineTree.ClearCache;
      // save unitlinks
      InputHistories.SetLastFPCUnitLinks(EnvironmentOptions.CompilerFilename,
                                         CurOptions,CompilerUnitSearchPath,
                                         EnvironmentOptions.FPCSourceDirectory,
                                         CompilerUnitLinks);
      InputHistories.Save;
    end else begin
      MessageDlg(lisFPCSourceDirectoryError,
        lisPlzCheckTheFPCSourceDirectory,
        mtError,[mbOk],0);
    end;
  end else begin
    MessageDlg(lisCompilerError,lisPlzCheckTheCompilerName,
      mtError,[mbOk],0);
  end;
end;

procedure TMainIDE.UpdateEnglishErrorMsgFilename;
begin
  if EnvironmentOptions.LazarusDirectory<>'' then
    CodeToolBoss.DefinePool.EnglishErrorMsgFilename:=
      AppendPathDelim(EnvironmentOptions.LazarusDirectory)+
      'components'+PathDelim+'codetools'+PathDelim+'fpc.errore.msg';
end;

procedure TMainIDE.ActivateCodeToolAbortableMode;
begin
  if ToolStatus=itNone then
    RaiseException('TMainIDE.ActivateCodeToolAbortableMode Error 1');
  ToolStatus:=itCodeTools;
  CodeToolBoss.OnCheckAbort:=@OnCodeToolBossCheckAbort;
  CodeToolBoss.Abortable:=true;
end;

procedure TMainIDE.OnBeforeCodeToolBossApplyChanges(Manager: TCodeToolManager;
  var Abort: boolean);
// the CodeToolBoss built a list of Sources that will be modified
// 1. open all of them in the source notebook
// 2. lock the editors to reduce repaints and undo steps
var i: integer;
begin
  if FOpenEditorsOnCodeToolChange then begin
    // open all sources in editor
    for i:=0 to Manager.SourceChangeCache.BuffersToModifyCount-1 do begin
      if DoOpenEditorFile(Manager.SourceChangeCache.BuffersToModify[i].Filename,
        -1,[ofOnlyIfExists,ofDoNotLoadResource])<>mrOk then
      begin
        Abort:=true;
        exit;
      end;
    end;
  end;
  // lock all editors
  SourceNoteBook.LockAllEditorsInSourceChangeCache;
end;

procedure TMainIDE.OnAfterCodeToolBossApplyChanges(Manager: TCodeToolManager);
var
  i: Integer;
  SrcBuf: TCodeBuffer;
  AnUnitInfo: TUnitInfo;
begin
  for i:=0 to CodeToolBoss.SourceChangeCache.BuffersToModifyCount-1 do begin
    SrcBuf:=CodeToolBoss.SourceChangeCache.BuffersToModify[i];
    AnUnitInfo:=Project1.UnitInfoWithFilename(SrcBuf.Filename);
    if AnUnitInfo<>nil then
      AnUnitInfo.Modified:=true;
  end;
  SourceNoteBook.UnlockAllEditorsInSourceChangeCache;
end;

function TMainIDE.OnCodeToolBossSearchUsedUnit(const SrcFilename: string;
  const TheUnitName, TheUnitInFilename: string): TCodeBuffer;
var
  AnUnitInfo: TUnitInfo;
begin
  Result:=nil;
  // check if SrcFilename is project file
  AnUnitInfo:=Project1.ProjectUnitWithFilename(SrcFilename);
  if AnUnitInfo=nil then exit;
  // SrcFilename is a project file
  // -> search virtual project files
  AnUnitInfo:=Project1.ProjectUnitWithUnitname(TheUnitName);
  if AnUnitInfo=nil then exit;
  // virtual unit found
  Result:=AnUnitInfo.Source;
end;

function TMainIDE.OnCodeToolBossCheckAbort: boolean;
begin
  Result:=true;
  if ToolStatus<>itCodeTools then exit;
  Application.ProcessMessages;
  Result:=ToolStatus<>itCodeTools;
end;

procedure TMainIDE.CodeToolBossGetVirtualDirectoryAlias(Sender: TObject;
  var RealDir: string);
begin
  if (Project1<>nil) and (Project1.ProjectDirectory<>'') then
    RealDir:=Project1.ProjectDirectory;
end;

procedure TMainIDE.CodeToolBossGetVirtualDirectoryDefines(DefTree: TDefineTree;
  DirDef: TDirectoryDefines);
begin
  if (Project1<>nil) and Project1.IsVirtual then
    Project1.GetVirtualDefines(DefTree,DirDef);
end;

procedure TMainIDE.OnCodeToolBossFindDefineProperty(Sender: TObject;
  const PersistentClassName, AncestorClassName, Identifier: string;
  var IsDefined: boolean);
begin
  FormEditor1.FindDefineProperty(PersistentClassName,AncestorClassName,
                                 Identifier,IsDefined);
end;

function TMainIDE.MacroFunctionProject(Data: Pointer): boolean;
var
  FuncData: PReadFunctionData;
  Param: String;
begin
  Result:=true;
  if Project1=nil then exit;
  FuncData:=PReadFunctionData(Data);
  Param:=FuncData^.Param;
  if AnsiCompareText(Param,'SrcPath')=0 then
    FuncData^.Result:=Project1.CompilerOptions.GetSrcPath(false)
  else if AnsiCompareText(Param,'IncPath')=0 then
    FuncData^.Result:=Project1.CompilerOptions.GetIncludePath(false)
  else if AnsiCompareText(Param,'UnitPath')=0 then
    FuncData^.Result:=Project1.CompilerOptions.GetUnitPath(false)
  else
    FuncData^.Result:='';
end;

procedure TMainIDE.OnCompilerGraphStampIncreased;
begin
  CodeToolBoss.DefineTree.ClearCache;
end;

procedure TMainIDE.SaveSourceEditorChangesToCodeCache(PageIndex: integer);
// save all open sources to code tools cache
var i: integer;

  procedure SaveChanges(APageIndex: integer);
  var
    SrcEdit: TSourceEditor;
    AnUnitInfo: TUnitInfo;
  begin
    GetUnitWithPageIndex(APageIndex,SrcEdit,AnUnitInfo);
    if (SrcEdit<>nil) and (AnUnitInfo<>nil) and (SrcEdit.Modified) then begin
      SrcEdit.UpdateCodeBuffer;
      AnUnitInfo.Modified:=true;
    end;
  end;

begin
  if PageIndex<0 then begin
    if (SourceNotebook.NoteBook<>nil) then begin
      for i:=0 to SourceNotebook.NoteBook.PageCount-1 do
        SaveChanges(i);
    end;
  end else begin
    SaveChanges(PageIndex);
  end;
end;

function TMainIDE.BeginCodeTool(var ActiveSrcEdit: TSourceEditor;
  var ActiveUnitInfo: TUnitInfo; Flags: TCodeToolsFlags): boolean;
begin
  Result:=BeginCodeTool(nil,ActiveSrcEdit,ActiveUnitInfo,Flags);
end;

function TMainIDE.BeginCodeTool(ADesigner: TDesigner;
  var ActiveSrcEdit: TSourceEditor; var ActiveUnitInfo: TUnitInfo;
  Flags: TCodeToolsFlags): boolean;
begin
  Result:=false;
  if (SourceNoteBook.NoteBook=nil)
  or (ToolStatus in [itCodeTools,itCodeToolAborting]) then begin
    debugln('TMainIDE.BeginCodeTool impossible ',dbgs(ord(ToolStatus)));
    exit;
  end;
  if ctfSwitchToFormSource in Flags then
    DoSwitchToFormSrc(ADesigner,ActiveSrcEdit,ActiveUnitInfo)
  else if ADesigner<>nil then
    GetDesignerUnit(ADesigner,ActiveSrcEdit,ActiveUnitInfo)
  else
    GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
  if (ActiveSrcEdit=nil) or (ActiveUnitInfo=nil) then exit;
  SaveSourceEditorChangesToCodeCache(-1);
  CodeToolBoss.VisibleEditorLines:=ActiveSrcEdit.EditorComponent.LinesInWindow;
  CodeToolBoss.TabWidth:=ActiveSrcEdit.EditorComponent.TabWidth;
  CodeToolBoss.IndentSize:=ActiveSrcEdit.EditorComponent.BlockIndent;

  if ctfActivateAbortMode in Flags then
    ActivateCodeToolAbortableMode;

  Result:=true;
end;

function TMainIDE.DoJumpToSourcePosition(const Filename: string; NewX, NewY,
  NewTopLine: integer; AddJumpPoint: boolean): TModalResult;
var
  CodeBuffer: TCodeBuffer;
begin
  Result:=mrCancel;
  CodeBuffer:=CodeToolBoss.LoadFile(CleanAndExpandFilename(Filename),true,false);
  if CodeBuffer=nil then exit;
  Result:=DoJumpToCodePos(nil,nil,CodeBuffer,NewX,NewY,NewTopLine,AddJumpPoint);
end;

function TMainIDE.DoJumpToCodePos(
  ActiveSrcEdit: TSourceEditor; ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer; NewX, NewY, NewTopLine: integer;
  AddJumpPoint: boolean): TModalResult;
var
  NewSrcEdit: TSourceEditor;
  NewUnitInfo: TUnitInfo;
begin
  Result:=mrCancel;
  if (ActiveSrcEdit=nil) or (ActiveUnitInfo=nil) then
    GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
  if AddJumpPoint then begin
    if (NewSource<>ActiveUnitInfo.Source)
    or (ActiveSrcEdit.EditorComponent.CaretX<>NewX)
    or (ActiveSrcEdit.EditorComponent.CaretY<>NewY) then
      SourceNotebook.AddJumpPointClicked(Self);
  end;
  if NewSource<>ActiveUnitInfo.Source then begin
    // jump to other file -> open it
    Result:=DoOpenEditorFile(NewSource.Filename,-1,[ofOnlyIfExists,ofRegularFile]);
    if Result<>mrOk then begin
      UpdateSourceNames;
      exit;
    end;
    GetUnitWithPageIndex(SourceNoteBook.NoteBook.PageIndex,NewSrcEdit,
      NewUnitInfo);
  end else begin
    NewSrcEdit:=ActiveSrcEdit;
  end;
  if NewX<1 then NewX:=1;
  if NewY<1 then NewY:=1;
  if NewTopLine<1 then
    NewTopLine:=Max(1,NewY-(NewSrcEdit.EditorComponent.LinesInWindow div 2));
  //writeln('[TMainIDE.DoJumpToCodePos] ',NewX,',',NewY,',',NewTopLine);
  with NewSrcEdit.EditorComponent do begin
    LogicalCaretXY:=Point(NewX,NewY);
    BlockBegin:=LogicalCaretXY;
    BlockEnd:=BlockBegin;
    TopLine:=NewTopLine;
    LeftChar:=Max(NewX-CharsInWindow,1);
  end;
  SourceNoteBook.ShowOnTop;
  SourceNotebook.FocusEditor;
  UpdateSourceNames;
  Result:=mrOk;
end;

{-------------------------------------------------------------------------------
  procedure TMainIDE.UpdateSourceNames
  Params: none

  Check every unit in sourceeditor if the source name has changed and updates
  the notebook page names.
-------------------------------------------------------------------------------}
procedure TMainIDE.UpdateSourceNames;
var
  PageIndex: integer;
  AnUnitInfo: TUnitInfo;
  SourceName, PageName: string;
begin
  if SourceNotebook.NoteBook=nil then exit;
  for PageIndex:=0 to SourceNotebook.NoteBook.PageCount-1 do begin
    AnUnitInfo:=Project1.UnitWithEditorIndex(PageIndex);
    if AnUnitInfo=nil then continue;
    if FilenameIsPascalUnit(AnUnitInfo.Filename) then begin
      SourceName:=CodeToolBoss.GetCachedSourceName(AnUnitInfo.Source);
      if SourceName<>'' then
        AnUnitInfo.ReadUnitNameFromSource(true);
    end else
      SourceName:='';
    PageName:=CreateSrcEditPageName(SourceName,AnUnitInfo.Filename,PageIndex);
    SourceNotebook.FindSourceEditorWithPageIndex(PageIndex).PageName:=PageName;
  end;
end;

procedure TMainIDE.ApplyCodeToolChanges;
begin
  // all changes were handled automatically by events
  // just clear the logs
  CodeToolBoss.SourceCache.ClearAllSourceLogEntries;
end;

procedure TMainIDE.DoJumpToProcedureSection;
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
  RevertableJump: boolean;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.DoJumpToProcedureSection] ************');
  {$ENDIF}
  if CodeToolBoss.JumpToMethod(ActiveUnitInfo.Source,
    ActiveSrcEdit.EditorComponent.CaretX,
    ActiveSrcEdit.EditorComponent.CaretY,
    NewSource,NewX,NewY,NewTopLine,RevertableJump) then
  begin
    DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
      NewSource, NewX, NewY, NewTopLine, not RevertableJump);
  end else
    DoJumpToCodeToolBossError;
end;

procedure TMainIDE.DoJumpToCodeToolBossError;
var
  ActiveSrcEdit:TSourceEditor;
  ErrorCaret: TPoint;
  OpenFlags: TOpenFlags;
  ErrorFilename: string;
  ErrorTopLine: integer;
begin
  if CodeToolBoss.ErrorMessage='' then begin
    UpdateSourceNames;
    debugln('TMainIDE.DoJumpToCodeToolBossError No errormessage');
    exit;
  end;
  // syntax error -> show error and jump
  // show error in message view
  DoArrangeSourceEditorAndMessageView(false);
  MessagesView.ClearTillLastSeparator;
  MessagesView.AddSeparator;
  if CodeToolBoss.ErrorCode<>nil then begin
    MessagesView.AddMsg(Project1.RemoveProjectPathFromFilename(
       CodeToolBoss.ErrorCode.Filename)
      +'('+IntToStr(CodeToolBoss.ErrorLine)
      +','+IntToStr(CodeToolBoss.ErrorColumn)
      +') Error: '+CodeToolBoss.ErrorMessage,
      Project1.ProjectDirectory,-1);
  end else
    MessagesView.AddMsg(CodeToolBoss.ErrorMessage,Project1.ProjectDirectory,-1);
  MessagesView.SelectedMessageIndex:=MessagesView.MsgCount-1;

  // jump to error in source editor
  if CodeToolBoss.ErrorCode<>nil then begin
    SourceNotebook.AddJumpPointClicked(Self);
    ErrorCaret:=Point(CodeToolBoss.ErrorColumn,CodeToolBoss.ErrorLine);
    ErrorFilename:=CodeToolBoss.ErrorCode.Filename;
    ErrorTopLine:=CodeToolBoss.ErrorTopLine;
    OpenFlags:=[ofOnlyIfExists,ofUseCache];
    if CodeToolBoss.ErrorCode.IsVirtual then
      Include(OpenFlags,ofVirtualFile);
    if DoOpenEditorFile(ErrorFilename,-1,OpenFlags)=mrOk
    then begin
      ActiveSrcEdit:=SourceNoteBook.GetActiveSE;
      MessagesView.ShowOnTop;
      SourceNoteBook.ShowOnTop;
      with ActiveSrcEdit.EditorComponent do begin
        LogicalCaretXY:=ErrorCaret;
        BlockBegin:=ErrorCaret;
        BlockEnd:=ErrorCaret;
        if ErrorTopLine>0 then
          TopLine:=ErrorTopLine;
      end;
      SourceNotebook.FocusEditor;
      SourceNotebook.ClearErrorLines;
      ActiveSrcEdit.ErrorLine:=ErrorCaret.Y;
    end;
  end;
  UpdateSourceNames;
end;

procedure TMainIDE.DoFindDeclarationAtCursor;
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
begin
  GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
  if ActiveSrcEdit=nil then exit;
  DoFindDeclarationAtCaret(ActiveSrcEdit.EditorComponent.LogicalCaretXY);
end;

procedure TMainIDE.DoFindDeclarationAtCaret(const LogCaretXY: TPoint);
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.DoFindDeclarationAtCaret] ************');
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoFindDeclarationAtCaret A');{$ENDIF}
  if CodeToolBoss.FindDeclaration(ActiveUnitInfo.Source,
    LogCaretXY.X,LogCaretXY.Y,
    NewSource,NewX,NewY,NewTopLine) then
  begin
    DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
      NewSource, NewX, NewY, NewTopLine, true);
  end else begin
    DoJumpToCodeToolBossError;
  end;
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoFindDeclarationAtCaret B');{$ENDIF}
end;

{-------------------------------------------------------------------------------
  function TMainIDE.DoFindRenameIdentifier(Rename: boolean): TModalResult;

-------------------------------------------------------------------------------}
function TMainIDE.DoFindRenameIdentifier(Rename: boolean): TModalResult;
var
  Options: TFindRenameIdentifierOptions;

  // TODO: replace Files: TStringsList with a AVL tree
  
  function AddExtraFiles(Files: TStrings): TModalResult;
  var
    i: Integer;
    CurFileMask: string;
    FileInfo: TSearchRec;
    CurDirectory: String;
    CurFilename: String;
  begin
    Result:=mrCancel;
    if (Options.ExtraFiles=nil) then begin
      for i:=0 to Options.ExtraFiles.Count-1 do begin
        CurFileMask:=Options.ExtraFiles[i];
        if not MacroList.SubstituteStr(CurFileMask) then exit;
        if SysUtils.FindFirst(CurFileMask,faAnyFile,FileInfo)=0
        then begin
          CurDirectory:=AppendPathDelim(ExtractFilePath(CurFileMask));
          if not FilenameIsAbsolute(CurDirectory) then begin
            CurDirectory:=AppendPathDelim(Project1.ProjectDirectory)
                          +CurDirectory;
          end;
          repeat
            // check if special file
            if (FileInfo.Name='.') or (FileInfo.Name='..') then continue;
            CurFilename:=CurDirectory+FileInfo.Name;
            if FileIsText(CurFilename) then
              Files.Add(CurFilename);
          until SysUtils.FindNext(FileInfo)<>0;
        end;
        SysUtils.FindClose(FileInfo);
      end;
    end;
    Result:=mrOk;
  end;

var
  TargetSrcEdit, DeclarationSrcEdit: TSourceEditor;
  TargetUnitInfo, DeclarationUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
  LogCaretXY, DeclarationCaretXY: TPoint;
  OwnerList: TList;
  ExtraFiles: TStrings;
  Files: TStringList;
  Identifier: string;
  TreeOfPCodeXYPosition: TAVLTree;
begin
  Result:=mrCancel;
  if not BeginCodeTool(TargetSrcEdit,TargetUnitInfo,[]) then exit;
  
  // find the main declaration
  LogCaretXY:=TargetSrcEdit.EditorComponent.LogicalCaretXY;
  if not CodeToolBoss.FindMainDeclaration(TargetUnitInfo.Source,
    LogCaretXY.X,LogCaretXY.Y,
    NewSource,NewX,NewY,NewTopLine) then
  begin
    DoJumpToCodeToolBossError;
    exit;
  end;
  DoJumpToCodePos(TargetSrcEdit, TargetUnitInfo,
    NewSource, NewX, NewY, NewTopLine, true);
  CodeToolBoss.GetIdentifierAt(NewSource,NewX,NewY,Identifier);

  GetCurrentUnit(DeclarationSrcEdit,DeclarationUnitInfo);
  DeclarationCaretXY:=DeclarationSrcEdit.EditorComponent.LogicalCaretXY;
  debugln('TMainIDE.DoFindRenameIdentifier A DeclarationCaretXY=x=',dbgs(DeclarationCaretXY.X),' y=',dbgs(DeclarationCaretXY.Y));

  // let user choose the search scope
  Result:=ShowFindRenameIdentifierDialog(DeclarationUnitInfo.Source.Filename,
    DeclarationCaretXY,Rename,Rename,nil);
  if Result<>mrOk then exit;
  
  Files:=nil;
  OwnerList:=nil;
  TreeOfPCodeXYPosition:=nil;
  try
    // create the file list
    Files:=TStringList.Create;
    Files.Add(TargetUnitInfo.Filename);

    Options:=MiscellaneousOptions.FindRenameIdentifierOptions;
    
    // add packages, projects
    case Options.Scope of
    frProject:
      begin
        OwnerList:=TList.Create;
        OwnerList.Add(Project1);
      end;
    frOwnerProjectPackage,frAllOpenProjectsAndPackages:
      begin
        OwnerList:=PkgBoss.GetOwnersOfUnit(TargetUnitInfo.Filename);
        if (OwnerList<>nil)
        and (Options.Scope=frAllOpenProjectsAndPackages) then begin
          PkgBoss.ExtendOwnerListWithUsedByOwners(OwnerList);
          ReverseList(OwnerList);
        end;
      end;
    end;

    // get source files of packages and projects
    if OwnerList<>nil then begin
      ExtraFiles:=PkgBoss.GetSourceFilesOfOwners(OwnerList);
      try
        if ExtraFiles<>nil then
          Files.AddStrings(ExtraFiles);
      finally
        ExtraFiles.Free;
      end;
    end;

    // add user defined extra files
    Result:=AddExtraFiles(Files);
    if Result<>mrOk then exit;

    // gather identifiers
    Result:=GatherIdentifierReferences(Files,DeclarationUnitInfo.Source,
      DeclarationCaretXY,Options.SearchInComments,TreeOfPCodeXYPosition);
    if CodeToolBoss.ErrorMessage<>'' then
      DoJumpToCodeToolBossError;
    if Result<>mrOk then exit;

    // show result
    if (not Options.Rename) or (not Rename) then begin
      CreateSearchResultWindow;
      Result:=ShowIdentifierReferences(DeclarationUnitInfo.Source,
        DeclarationCaretXY,TreeOfPCodeXYPosition);
      if Result<>mrOk then exit;
    end;
    
    // rename identifier
    if Options.Rename and Rename then begin
      if not CodeToolBoss.RenameIdentifier(TreeOfPCodeXYPosition,
        Identifier,Options.RenameTo)
      then begin
        DoJumpToCodeToolBossError;
        Result:=mrCancel;
        exit;
      end;
    end;

  finally
    Files.Free;
    OwnerList.Free;
    CodeToolBoss.FreeTreeOfPCodeXYPosition(TreeOfPCodeXYPosition);
  end;
end;

{-------------------------------------------------------------------------------
  function TMainIDE.DoInitIdentCompletion: boolean;
-------------------------------------------------------------------------------}
function TMainIDE.DoInitIdentCompletion: boolean;
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  LogCaretXY: TPoint;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.DoInitIdentCompletion] ************');
  {$ENDIF}
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoInitIdentCompletion A');{$ENDIF}
  LogCaretXY:=ActiveSrcEdit.EditorComponent.LogicalCaretXY;
  Result:=CodeToolBoss.GatherIdentifiers(ActiveUnitInfo.Source,
                                         LogCaretXY.X,LogCaretXY.Y);
  if not Result then begin
    DoJumpToCodeToolBossError;
    exit;
  end;
  {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.DoInitIdentCompletion B');{$ENDIF}
end;

procedure TMainIDE.DoGoToPascalBlockOtherEnd;
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.DoGoToPascalBlockOtherEnd] ************');
  {$ENDIF}
  if CodeToolBoss.FindBlockCounterPart(ActiveUnitInfo.Source,
    ActiveSrcEdit.EditorComponent.CaretX,
    ActiveSrcEdit.EditorComponent.CaretY,
    NewSource,NewX,NewY,NewTopLine) then
  begin
    DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
      NewSource, NewX, NewY, NewTopLine, false);
  end else
    DoJumpToCodeToolBossError;
end;

procedure TMainIDE.DoGoToPascalBlockStart;
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.DoGoToPascalBlockStart] ************');
  {$ENDIF}
  if CodeToolBoss.FindBlockStart(ActiveUnitInfo.Source,
    ActiveSrcEdit.EditorComponent.CaretX,
    ActiveSrcEdit.EditorComponent.CaretY,
    NewSource,NewX,NewY,NewTopLine) then
  begin
    DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
      NewSource, NewX, NewY, NewTopLine, false);
  end else
    DoJumpToCodeToolBossError;
end;

procedure TMainIDE.DoJumpToGuessedUnclosedBlock(FindNext: boolean);
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  StartX, StartY, NewX, NewY, NewTopLine: integer;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.DoJumpToGuessedUnclosedBlock] ************');
  {$ENDIF}
  if FindNext then begin
    StartX:=ActiveSrcEdit.EditorComponent.CaretX;
    StartY:=ActiveSrcEdit.EditorComponent.CaretY;
  end else begin
    StartX:=1;
    StartY:=1;
  end;
  if CodeToolBoss.GuessUnclosedBlock(ActiveUnitInfo.Source,
    StartX,StartY,NewSource,NewX,NewY,NewTopLine) then
  begin
    DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
      NewSource, NewX, NewY, NewTopLine, true);
  end else
    DoJumpToCodeToolBossError;
end;

procedure TMainIDE.DoJumpToGuessedMisplacedIFDEF(FindNext: boolean);
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  StartX, StartY, NewX, NewY, NewTopLine: integer;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.DoJumpToGuessedMisplacedIFDEF] ************');
  {$ENDIF}
  if FindNext then begin
    StartX:=ActiveSrcEdit.EditorComponent.CaretX;
    StartY:=ActiveSrcEdit.EditorComponent.CaretY;
  end else begin
    StartX:=1;
    StartY:=1;
  end;
  if CodeToolBoss.GuessMisplacedIfdefEndif(ActiveUnitInfo.Source,
    StartX,StartY,NewSource,NewX,NewY,NewTopLine) then
  begin
    DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
      NewSource, NewX, NewY, NewTopLine, true);
  end else
    DoJumpToCodeToolBossError;
end;

procedure TMainIDE.DoGotoIncludeDirective;
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.DoGotoIncludeDirective] ************');
  {$ENDIF}
  if CodeToolBoss.FindEnclosingIncludeDirective(ActiveUnitInfo.Source,
    ActiveSrcEdit.EditorComponent.CaretX,
    ActiveSrcEdit.EditorComponent.CaretY,
    NewSource,NewX,NewY,NewTopLine) then
  begin
    DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
      NewSource, NewX, NewY, NewTopLine, false);
  end else
    DoJumpToCodeToolBossError;
end;

procedure TMainIDE.SaveIncludeLinks;
var AFilename: string;
begin
  // save include file relationships
  AFilename:=AppendPathDelim(GetPrimaryConfigPath)+CodeToolsIncludeLinkFile;
  CodeToolBoss.SourceCache.SaveIncludeLinksToFile(AFilename,true);
end;

function TMainIDE.DoMakeResourceString: TModalResult;
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  StartPos, EndPos: TPoint;
  StartCode, EndCode: TCodeBuffer;
  NewIdentifier, NewIdentValue: string;
  NewSourceLines: string;
  InsertPolicy: TResourcestringInsertPolicy;
  SectionCode: TCodeBuffer;
  SectionCaretXY: TPoint;
  DummyResult: Boolean;
  SelectedStartPos: TPoint;
  SelectedEndPos: TPoint;
  CursorCode: TCodeBuffer;
  CursorXY: TPoint;
begin
  FOpenEditorsOnCodeToolChange:=true;
  try
    Result:=mrCancel;
    if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
    {$IFDEF IDE_DEBUG}
    debugln('');
    debugln('[TMainIDE.DoMakeResourceString] ************');
    {$ENDIF}
    // calculate start and end of expression in source
    CursorCode:=ActiveUnitInfo.Source;
    CursorXY:=ActiveSrcEdit.EditorComponent.LogicalCaretXY;
    if not CodeToolBoss.GetStringConstBounds(
      CursorCode,CursorXY.X,CursorXY.Y,
      StartCode,StartPos.X,StartPos.Y,
      EndCode,EndPos.X,EndPos.Y,
      true) then
    begin
      DoJumpToCodeToolBossError;
      exit;
    end;

    // the codetools have calculated the maximum bounds
    if (StartCode=EndCode) and (CompareCaret(StartPos,EndPos)=0) then begin
      MessageDlg(lisNoStringConstantFound,
      Format(lisHintTheMakeResourcestringFunctionExpectsAStringCon, [#13]),
      mtError,[mbCancel],0);
      exit;
    end;
    // the user can shorten this range by selecting text
    if (ActiveSrcEdit.EditorComponent.SelText='') then begin
      // the user has not selected text
      // -> check if the string constant is in single file
      // (replacing code that contains an $include directive is ambiguous)
      //debugln('TMainIDE.DoMakeResourceString user has not selected text');
      if (StartCode<>ActiveUnitInfo.Source)
      or (EndCode<>ActiveUnitInfo.Source)
      then begin
        MessageDlg(lisNoStringConstantFound, Format(
          lisInvalidExpressionHintTheMakeResourcestringFunction, [#13]),
        mtError,[mbCancel],0);
        exit;
      end;
    end else begin
      // the user has selected text
      // -> check if the selection is only part of the maximum bounds
      SelectedStartPos:=ActiveSrcEdit.EditorComponent.BlockBegin;
      SelectedEndPos:=ActiveSrcEdit.EditorComponent.BlockEnd;
      CodeToolBoss.ImproveStringConstantStart(
                      ActiveSrcEdit.EditorComponent.Lines[SelectedStartPos.Y-1],
                      SelectedStartPos.X);
      CodeToolBoss.ImproveStringConstantEnd(
                        ActiveSrcEdit.EditorComponent.Lines[SelectedEndPos.Y-1],
                        SelectedEndPos.X);
      //debugln('TMainIDE.DoMakeResourceString user has selected text: Selected=',dbgs(SelectedStartPos),'-',dbgs(SelectedEndPos),' Maximum=',dbgs(StartPos),'-',dbgs(EndPos));
      if (CompareCaret(SelectedStartPos,StartPos)>0)
      or (CompareCaret(SelectedEndPos,EndPos)<0)
      then begin
        MessageDlg(lisSelectionExceedsStringConstant,
        Format(lisHintTheMakeResourcestringFunctionExpectsAStringCon2, [#13]),
        mtError,[mbCancel],0);
        exit;
      end;
      StartPos:=SelectedStartPos;
      EndPos:=SelectedEndPos;
    end;

    // gather all reachable resourcestring sections
    //debugln('TMainIDE.DoMakeResourceString gather all reachable resourcestring sections ...');
    if not CodeToolBoss.GatherResourceStringSections(
      CursorCode,CursorXY.X,CursorXY.Y,nil)
    then begin
      DoJumpToCodeToolBossError;
      exit;
    end;
    if CodeToolBoss.Positions.Count=0 then begin
      MessageDlg(lisNoResourceStringSectionFound,
        lisUnableToFindAResourceStringSectionInThisOrAnyOfThe,
        mtError,[mbCancel],0);
      exit;
    end;

    // show make resourcestring dialog
    Result:=ShowMakeResStrDialog(StartPos,EndPos,StartCode,
                                 CodeToolBoss.Positions,
                                 NewIdentifier,NewIdentValue,NewSourceLines,
                                 SectionCode,SectionCaretXY,InsertPolicy);
    if (Result<>mrOk) then exit;

    // replace source
    ActiveSrcEdit.ReplaceLines(StartPos.Y,EndPos.Y,NewSourceLines);

    // add new resourcestring to resourcestring section
    if (InsertPolicy<>rsipNone) then
      DummyResult:=CodeToolBoss.AddResourcestring(
                       CursorCode,CursorXY.X,CursorXY.Y,
                       SectionCode,SectionCaretXY.X,SectionCaretXY.Y,
                       NewIdentifier,''''+NewIdentValue+'''',InsertPolicy)
    else
      DummyResult:=true;
    ApplyCodeToolChanges;
    if not DummyResult then begin
      DoJumpToCodeToolBossError;
      exit;
    end;

    // switch back to source
    ActiveSrcEdit.Activate;

    Result:=mrOk;
  finally
    FOpenEditorsOnCodeToolChange:=false;
  end;
end;

function TMainIDE.DoDiff: TModalResult;
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  OpenDiffInEditor: boolean;
  DiffText: string;
  Files: TDiffFiles;
  NewDiffFilename: String;
begin
  Result:=mrCancel;
  GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
  if ActiveSrcEdit=nil then exit;

  Files:=SourceNoteBook.GetDiffFiles;
  Result:=ShowDiffDialog(Files,ActiveSrcEdit.PageIndex,
                         @SourceNotebook.GetSourceText,
                         OpenDiffInEditor,DiffText);
  Files.Free;
  if OpenDiffInEditor then begin
    NewDiffFilename:=CreateSrcEditPageName('','diff.txt',-1);
    Result:=DoNewEditorFile(FileDescriptorText,NewDiffFilename,DiffText,
                            [nfOpenInEditor]);
    GetCurrentUnit(ActiveSrcEdit,ActiveUnitInfo);
    if ActiveSrcEdit=nil then exit;
  end;
end;

function TMainIDE.DoFindInFiles: TModalResult;
begin
  Result:=mrOk;
  DoArrangeSourceEditorAndMessageView(true);
  SourceNotebook.FindInFilesPerDialog(Project1);
end;

procedure TMainIDE.DoCompleteCodeAtCursor;
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
begin
  FOpenEditorsOnCodeToolChange:=true;
  try
    if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
    {$IFDEF IDE_DEBUG}
    writeln('');
    writeln('[TMainIDE.DoCompleteCodeAtCursor] ************');
    {$ENDIF}
    if CodeToolBoss.CompleteCode(ActiveUnitInfo.Source,
      ActiveSrcEdit.EditorComponent.CaretX,
      ActiveSrcEdit.EditorComponent.CaretY,
      ActiveSrcEdit.EditorComponent.TopLine,
      NewSource,NewX,NewY,NewTopLine) then
    begin
      ApplyCodeToolChanges;
      DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
        NewSource, NewX, NewY, NewTopLine, true);
    end else begin
      // error: probably a syntax error or just not in a procedure head/body
      // or not in a class
      // -> there are enough events to handle everything, so it can be ignored here
      ApplyCodeToolChanges;
      DoJumpToCodeToolBossError;
    end;
  finally
    FOpenEditorsOnCodeToolChange:=false;
  end;
end;

procedure TMainIDE.DoExtractProcFromSelection;
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  BlockBegin: TPoint;
  BlockEnd: TPoint;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
  CTResult: boolean;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[]) then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.DoExtractProcFromSelection] ************');
  {$ENDIF}
  BlockBegin:=ActiveSrcEdit.EditorComponent.BlockBegin;
  BlockEnd:=ActiveSrcEdit.EditorComponent.BlockEnd;

  FOpenEditorsOnCodeToolChange:=true;
  try
    CTResult:=ShowExtractProcDialog(ActiveUnitInfo.Source,BlockBegin,BlockEnd,
      NewSource,NewX,NewY,NewTopLine)=mrOk;
    ApplyCodeToolChanges;
    if CodeToolBoss.ErrorMessage<>'' then begin
      DoJumpToCodeToolBossError;
    end else if CTResult then begin
      DoJumpToCodePos(ActiveSrcEdit,ActiveUnitInfo,
        NewSource,NewX,NewY,NewTopLine,true);
    end;
  finally
    FOpenEditorsOnCodeToolChange:=false;
  end;
end;

//-----------------------------------------------------------------------------

procedure TMainIDE.MessagesViewSelectionChanged(sender: TObject);
begin
  DoJumpToCompilerMessage(TMessagesView(Sender).SelectedMessageIndex,True);
end;

procedure TMainIDE.SearchResultsViewSelectionChanged(sender: TObject);
begin
  DoJumpToSearchResult(True);
end;

Procedure TMainIDE.OnSrcNotebookEditorVisibleChanged(Sender: TObject);
var
  ActiveUnitInfo: TUnitInfo;
begin
  if SourceNotebook.Notebook = nil then Exit;

  ActiveUnitInfo :=
    Project1.UnitWithEditorIndex(SourceNotebook.Notebook.PageIndex);
  if ActiveUnitInfo = nil then Exit;

  MainIDEBar.SaveSpeedBtn.Enabled := SourceNotebook.GetActiveSe.Modified;
  MainIDEBar.ToggleFormSpeedBtn.Enabled := Assigned(ActiveUnitInfo.Component)
                                          or (ActiveUnitInfo.ComponentName<>'');
end;

//this is fired when the editor is focused, changed, ?.  Anything that causes the status change
Procedure TMainIDE.OnSrcNotebookEditorChanged(Sender: TObject);
begin
  if SourceNotebook.Notebook = nil then Exit;
  MainIDEBar.SaveSpeedBtn.Enabled := SourceNotebook.GetActiveSE.Modified;
end;

procedure TMainIDE.OnSrcNotebookCurCodeBufferChanged(Sender: TObject);
begin
  if SourceNotebook.Notebook = nil then Exit;
  if CodeExplorerView<>nil then CodeExplorerView.CurrentCodeBufferChanged;
end;

procedure TMainIDE.OnSrcNotebookShowHintForSource(SrcEdit: TSourceEditor;
  ClientPos: TPoint; CaretPos: TPoint);
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  Identifier, SmartHintStr: string;
  Expression, DebugEval: string;
begin
  if (SrcEdit=nil) then exit;

  // check if there is an identifier
  case ToolStatus of
    itNone: begin
      Identifier := SrcEdit.GetWordFromCaret(CaretPos);
      if (Identifier='') or (not IsValidIdent(Identifier)) then exit;
    end;
    itDebugger: begin
//      Identifier := SrcEdit.GetWordFromCaretEx(CaretPos,
//        ['A'..'Z', 'a'..'z', '0'..'9', '(', '[', '.', ''''],
//        ['A'..'Z', 'a'..'z', '0'..'9', ')', ']', '^', '''']);
      Identifier := SrcEdit.GetWordFromCaret(CaretPos);
      if Identifier = '' then Exit;
    end;
  else
    Exit;
  end;
  SourceNotebook.SetActiveSE(SrcEdit);

  if not BeginCodeTool(ActiveSrcEdit, ActiveUnitInfo,
    [{ctfActivateAbortMode}]) then exit;

  case ToolStatus of
    itNone: begin
      {$IFDEF IDE_DEBUG}
      writeln('');
      writeln('[TMainIDE.OnSrcNotebookShowHintForSource] ************ ',ActiveUnitInfo.Source.Filename,' X=',CaretPos.X,' Y=',CaretPos.Y);
      {$ENDIF}
      {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.OnSrcNotebookShowHintForSource A');{$ENDIF}
      SmartHintStr:=CodeToolBoss.FindSmartHint(ActiveUnitInfo.Source,
        CaretPos.X,CaretPos.Y);
      CodeToolBoss.Abortable:=false;
      {$IFDEF IDE_MEM_CHECK}CheckHeapWrtMemCnt('TMainIDE.OnSrcNotebookShowHintForSource B');{$ENDIF}
    end;
    itDebugger: begin
      if SrcEdit.SelectionAvailable
      and SrcEdit.CaretInSelection(CaretPos)
      then Expression := SrcEdit.GetText(True)
      else Expression := Identifier;
      if not DebugBoss.Evaluate(Expression, DebugEval)
      or (DebugEval = '')
      then DebugEval := '???';
      SmartHintStr := Expression + ' = ' + DebugEval;
    end;
  else
    Exit;
  end;

  if SmartHintStr<>'' then
    SrcEdit.ActivateHint(ClientPos,SmartHintStr);
end;

procedure TMainIDE.OnSrcNoteBookActivated(Sender: TObject);
begin
  FDisplayState:= dsSource;
  DoCheckFilesOnDisk;
end;

Procedure TMainIDE.OnDesignerActivated(Sender: TObject);
begin
  FDisplayState:= dsForm;
  FLastFormActivated := TDesigner(Sender).Form;
  UpdateIDEComponentPalette;
end;

procedure TMainIDE.OnDesignerCloseQuery(Sender: TObject);
var
  ADesigner: TDesigner;
  ASrcEdit: TSourceEditor;
  AnUnitInfo: TUnitInfo;
begin
  ADesigner:=TDesigner(Sender);
  GetDesignerUnit(ADesigner,ASrcEdit,AnUnitInfo);
  if AnUnitInfo.NeedsSaveToDisk
  then begin
    case MessageDlg(lisSaveChanges,
                    Format(lisSaveFileBeforeClosingForm, ['"',
                      AnUnitInfo.Filename, '"', #13, '"',
                      ADesigner.LookupRoot.Name, '"']),
                   mtConfirmation,[mbYes,mbNo,mbCancel],0) of
      mrYes: begin
        if DoSaveEditorFile(AnUnitInfo.EditorIndex,[sfCheckAmbiguousFiles])<>mrOk
        then Exit;
      end;
      mrNo:;
    else
      Exit;
    end;
  end;
  CloseDesignerForm(AnUnitInfo);
end;

procedure TMainIDE.OnDesignerRenameComponent(ADesigner: TDesigner;
  AComponent: TComponent; const NewName: string);
var
  ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  i: integer;
  NewClassName: string;
  BossResult: boolean;

  procedure ApplyBossResult(const ErrorMsg: string);
  var
    CodeToolBossErrMsg: String;
  begin
    ApplyCodeToolChanges;
    if not BossResult then begin
      CodeToolBossErrMsg:=CodeToolBoss.ErrorMessage;
      DoJumpToCodeToolBossError;
      raise Exception.Create(ErrorMsg+#13#13+lisError+CodeToolBossErrMsg
                             +#13#13+lisSeeMessages);
    end;
  end;
  
  procedure CheckInterfaceName(const AName: string);
  begin
    if CompareText(ActiveUnitInfo.UnitName,AName)=0 then
      raise Exception.Create(Format(
        lisTheUnitItselfHasAlreadyTheNamePascalIdentifiersMus, ['"', AName, '"']
        ));
    if ActiveUnitInfo.IsPartOfProject then begin
      // check if component name already exists in project
      i:=Project1.IndexOfUnitWithComponentName(AName,true,ActiveUnitInfo);
      if i>=0 then
        raise Exception.Create(
                           Format(lisThereIsAlreadyAFormWithTheName, ['"',
                             AName, '"']));
      // check if pascal identifier already exists in the units
      i:=Project1.IndexOfUnitWithName(AName,true,nil);
      if i>=0 then
        raise Exception.Create(Format(
          lisThereIsAlreadyAUnitWithTheNamePascalIdentifiersMus, ['"', AName,
          '"']));
    end;

  end;

begin
  DebugLn('TMainIDE.OnDesignerRenameComponent Old=',AComponent.Name,':',AComponent.ClassName,' New=',NewName);
  if (not IsValidIdent(NewName)) or (NewName='') then
    raise Exception.Create(Format(lisComponentNameIsNotAValidIdentifier, ['"',
      Newname, '"']));
  if AComponent.Name='' then begin
    // this component was never added to the source. It is a new component.
    exit;
  end;
  BeginCodeTool(ADesigner,ActiveSrcEdit,ActiveUnitInfo,[ctfSwitchToFormSource]);
  ActiveUnitInfo:=Project1.UnitWithComponent(ADesigner.LookupRoot);
  if CodeToolBoss.IsKeyWord(ActiveUnitInfo.Source,NewName) then
    raise Exception.Create(Format(lisComponentNameIsKeyword, ['"', Newname, '"']
      ));

  if AComponent=ADesigner.LookupRoot then begin
    // rename owner component (e.g. the form)
    
    CheckInterfaceName(NewName);
    NewClassName:='T'+NewName;
    CheckInterfaceName(NewClassName);

    // rename form component in source
    BossResult:=CodeToolBoss.RenameForm(ActiveUnitInfo.Source,
      AComponent.Name,AComponent.ClassName,
      NewName,NewClassName);
    ApplyBossResult(Format(lisUnableToRenameFormInSource, [#13]));
    ActiveUnitInfo.ComponentName:=NewName;

    // rename form component class
    FormEditor1.RenameJITComponent(AComponent,NewClassName);

    // change createform statement
    if ActiveUnitInfo.IsPartOfProject and (Project1.MainUnitID>=0)
    then begin
      BossResult:=CodeToolBoss.ChangeCreateFormStatement(
        Project1.MainUnitInfo.Source,
        AComponent.ClassName,AComponent.Name,
        NewClassName,NewName,true);
      Project1.MainUnitInfo.Modified:=true;
      ApplyBossResult(lisUnableToUpdateCreateFormStatementInProjectSource);
    end;
  end else if ADesigner.LookupRoot<>nil then begin
    // rename published variable in form source
    BossResult:=CodeToolBoss.RenamePublishedVariable(ActiveUnitInfo.Source,
      ADesigner.LookupRoot.ClassName,
      AComponent.Name,NewName,AComponent.ClassName,true);
    ApplyBossResult(Format(lisUnableToRenameVariableInSource, [#13])
      );
  end else begin
    RaiseException('TMainIDE.OnDesignerRenameComponent internal error:'+AComponent.Name+':'+AComponent.ClassName);
  end;
end;

Procedure TMainIDE.OnSrcNoteBookAddJumpPoint(ACaretXY: TPoint;
  ATopLine: integer; APageIndex: integer; DeleteForwardHistory: boolean);
{off $DEFINE VerboseJumpHistory}
var
  ActiveUnitInfo: TUnitInfo;
  NewJumpPoint: TProjectJumpHistoryPosition;
begin
  {$IFDEF VerboseJumpHistory}
  writeln('');
  writeln('[TMainIDE.OnSrcNoteBookAddJumpPoint] A Line=',ACaretXY.Y,' Col=',ACaretXY.X,' DeleteForwardHistory=',DeleteForwardHistory,' Count=',Project1.JumpHistory.Count,',HistoryIndex=',Project1.JumpHistory.HistoryIndex);
  {$ENDIF}
  ActiveUnitInfo:=Project1.UnitWithEditorIndex(APageIndex);
  if (ActiveUnitInfo=nil) then exit;
  NewJumpPoint:=TProjectJumpHistoryPosition.Create(ActiveUnitInfo.Filename,
    ACaretXY,ATopLine);
  {$IFDEF VerboseJumpHistory}
  //Project1.JumpHistory.WriteDebugReport;
  {$ENDIF}
  Project1.JumpHistory.InsertSmart(Project1.JumpHistory.HistoryIndex+1,
                                   NewJumpPoint);
  {$IFDEF VerboseJumpHistory}
  writeln('[TMainIDE.OnSrcNoteBookAddJumpPoint] B INSERTED');
  Project1.JumpHistory.WriteDebugReport;
  {$ENDIF}
  if DeleteForwardHistory then Project1.JumpHistory.DeleteForwardHistory;
  {$IFDEF VerboseJumpHistory}
  writeln('[TMainIDE.OnSrcNoteBookAddJumpPoint] END Line=',ACaretXY.Y,',DeleteForwardHistory=',DeleteForwardHistory,' Count=',Project1.JumpHistory.Count,',HistoryIndex=',Project1.JumpHistory.HistoryIndex);
  Project1.JumpHistory.WriteDebugReport;
  {$ENDIF}
end;

Procedure TMainIDE.OnSrcNotebookDeleteLastJumPoint(Sender: TObject);
begin
  Project1.JumpHistory.DeleteLast;
end;

Procedure TMainIDE.OnSrcNotebookJumpToHistoryPoint(var NewCaretXY: TPoint;
  var NewTopLine, NewPageIndex: integer;  JumpAction: TJumpHistoryAction);
{ How the HistoryIndex works:

  When the user jumps around each time an item is added to the history list
  and the HistoryIndex points to the last added item (i.e. Count-1).

  Jumping back:
    The sourceditor will be repositioned to the item with the HistoryIndex.
    Then the historyindex is moved to the previous item.
    If HistoryIndex is the last item in the history, then this is the first
    back jump and the current sourceeditor position is smart added to the
    history list. Smart means that if the added Item is similar to the last
    item then the last item will be replaced else a new item is added.

  Jumping forward:

}
var DestIndex, UnitIndex: integer;
  ASrcEdit: TSourceEditor;
  AnUnitInfo: TUnitInfo;
  DestJumpPoint: TProjectJumpHistoryPosition;
  CursorPoint, NewJumpPoint: TProjectJumpHistoryPosition;
begin
  NewPageIndex:=-1;
  NewCaretXY.Y:=-1;

  {$IFDEF VerboseJumpHistory}
  writeln('');
  writeln('[TMainIDE.OnSrcNotebookJumpToHistoryPoint] A Back=',JumpAction=jhaBack);
  Project1.JumpHistory.WriteDebugReport;
  {$ENDIF}

  // update jump history (e.g. delete jumps to closed editors)
  Project1.JumpHistory.DeleteInvalidPositions;

  // get destination jump point
  DestIndex:=Project1.JumpHistory.HistoryIndex;
  if JumpAction=jhaForward then
    inc(DestIndex);
  if (DestIndex<0) or (DestIndex>=Project1.JumpHistory.Count) then exit;

  CursorPoint:=nil;
  if (SourceNoteBook<>nil) then begin
    // get current cursor position
    GetCurrentUnit(ASrcEdit,AnUnitInfo);
    if (ASrcEdit<>nil) and (AnUnitInfo<>nil) then begin
      CursorPoint:=TProjectJumpHistoryPosition.Create(AnUnitInfo.Filename,
        ASrcEdit.EditorComponent.LogicalCaretXY,
        ASrcEdit.EditorComponent.TopLine);
      {$IFDEF VerboseJumpHistory}
      writeln('  Current Position: ',CursorPoint.Filename,
              ' ',CursorPoint.CaretXY.X,',',CursorPoint.CaretXY.Y);
      {$ENDIF}
    end;
  end;

  if (JumpAction=jhaBack) and (Project1.JumpHistory.Count=DestIndex+1)
  and (CursorPoint<>nil) then begin
    // this is the first back jump
    // -> insert current source position into history
    {$IFDEF VerboseJumpHistory}
    writeln('  First back jump -> add current cursor position');
    {$ENDIF}
    NewJumpPoint:=TProjectJumpHistoryPosition.Create(CursorPoint);
    Project1.JumpHistory.InsertSmart(Project1.JumpHistory.HistoryIndex+1,
                                     NewJumpPoint);
  end;

  // find the next jump point that is not where the cursor is
  DestIndex:=Project1.JumpHistory.HistoryIndex;
  if JumpAction=jhaForward then
    inc(DestIndex);
  while (DestIndex>=0) and (DestIndex<Project1.JumpHistory.Count) do begin
    DestJumpPoint:=Project1.JumpHistory[DestIndex];
    UnitIndex:=Project1.IndexOfFilename(DestJumpPoint.Filename);
    {$IFDEF VerboseJumpHistory}
    writeln(' DestIndex=',DestIndex,' UnitIndex=',UnitIndex);
    {$ENDIF}
    if (UnitIndex>=0) and (Project1.Units[UnitIndex].EditorIndex>=0)
    and ((CursorPoint=nil) or not DestJumpPoint.IsSimilar(CursorPoint)) then
    begin
      if JumpAction=jhaBack then
        dec(DestIndex);
      Project1.JumpHistory.HistoryIndex:=DestIndex;
      NewCaretXY:=DestJumpPoint.CaretXY;
      NewTopLine:=DestJumpPoint.TopLine;
      NewPageIndex:=Project1.Units[UnitIndex].EditorIndex;
      {$IFDEF VerboseJumpHistory}
      writeln('[TMainIDE.OnSrcNotebookJumpToHistoryPoint] Result Line=',NewCaretXY.Y,' Col=',NewCaretXY.X);
      {$ENDIF}
      break;
    end;
    if JumpAction=jhaBack then
      dec(DestIndex)
    else
      inc(DestIndex);
  end;

  CursorPoint.Free;

  {$IFDEF VerboseJumpHistory}
  writeln('[TMainIDE.OnSrcNotebookJumpToHistoryPoint] END Count=',Project1.JumpHistory.Count,',HistoryIndex=',Project1.JumpHistory.HistoryIndex);
  Project1.JumpHistory.WriteDebugReport;
  writeln('');
  {$ENDIF}
end;

procedure TMainIDE.OnSrcNotebookMovingPage(Sender: TObject; OldPageIndex,
  NewPageIndex: integer);
begin
  Project1.MoveEditorIndex(OldPageIndex,NewPageIndex);
end;

procedure TMainIDE.OnSrcNotebookReadOnlyChanged(Sender: TObject);
var
  ActiveSourceEditor: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
begin
  GetCurrentUnit(ActiveSourceEditor,ActiveUnitInfo);
  ActiveUnitInfo.UserReadOnly:=ActiveSourceEditor.ReadOnly;
end;

Procedure TMainIDE.OnSrcNotebookViewJumpHistory(Sender: TObject);
begin
  // ToDo
  MessageDlg(ueNotImplCap, lisSorryNotImplementedYet, mtInformation,
     [mbOk],0);
end;

procedure TMainIDE.OnSrcNotebookShowSearchResultsView(Sender: TObject);
begin
  CreateSearchResultWindow;
end;

procedure TMainIDE.OnSrcNoteBookPopupMenu(AddMenuItemProc: TAddMenuItemProc);
begin
  PkgBoss.OnSourceEditorPopupMenu(AddMenuItemProc);
end;

procedure TMainIDE.OnApplicationUserInput(Sender: TObject; Msg: Cardinal);
begin
  if ToolStatus=itCodeTools then begin
    // abort codetools
    ToolStatus:=itCodeToolAborting;
  end;
end;

procedure TMainIDE.OnApplicationIdle(Sender: TObject);
var
  SrcEdit: TSourceEditor;
begin
  UpdateWindowsMenu;
  GetDefaultProcessList.FreeStoppedProcesses;
  EnvironmentOptions.ExternalTools.FreeStoppedProcesses;
  if (SplashForm<>nil) then FreeThenNil(SplashForm);
  FormEditor1.PaintAllDesignerItems;
  SrcEdit:=SourceNotebook.GetActiveSe;
  MainIDEBar.SaveSpeedBtn.Enabled := (SrcEdit<>nil)
                                        and SourceNotebook.GetActiveSe.Modified;
end;

procedure TMainIDE.OnScreenRemoveForm(Sender: TObject; AForm: TCustomForm);
begin
  HiddenWindowsOnRun.Remove(AForm);
  EnvironmentOptions.IDEWindowLayoutList.CloseForm(AForm);
end;

function TMainIDE.ProjInspectorAddUnitToProject(Sender: TObject;
  AnUnitInfo: TUnitInfo): TModalresult;
var
  ActiveSourceEditor: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  ShortUnitName: String;
  Dummy: Boolean;
begin
  Result:=mrOk;
  BeginCodeTool(ActiveSourceEditor,ActiveUnitInfo,[]);
  AnUnitInfo.IsPartOfProject:=true;
  if FilenameIsPascalUnit(AnUnitInfo.Filename)
  and (pfMainUnitHasUsesSectionForAllUnits in Project1.Flags)
  then begin
    AnUnitInfo.ReadUnitNameFromSource(false);
    ShortUnitName:=AnUnitInfo.UnitName;
    if (ShortUnitName<>'') then begin
      Dummy:=CodeToolBoss.AddUnitToMainUsesSection(
                                 Project1.MainUnitInfo.Source,ShortUnitName,'');
      ApplyCodeToolChanges;
      if Dummy then begin
        Project1.MainUnitInfo.Modified:=true;
      end else begin
        DoJumpToCodeToolBossError;
        Result:=mrCancel;
      end;
    end;
  end;
  Project1.Modified:=true;
end;

function TMainIDE.ProjInspectorRemoveFile(Sender: TObject; AnUnitInfo: TUnitInfo
  ): TModalresult;
var
  ActiveSourceEditor: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  ShortUnitName: String;
  Dummy: Boolean;
begin
  Result:=mrOk;
  AnUnitInfo.IsPartOfProject:=false;
  if (Project1.MainUnitID>=0)
  and (pfMainUnitHasUsesSectionForAllUnits in Project1.Flags)
  then begin
    BeginCodeTool(ActiveSourceEditor,ActiveUnitInfo,[]);
    ShortUnitName:=AnUnitInfo.UnitName;
    if (ShortUnitName<>'') then begin
      Dummy:=CodeToolBoss.RemoveUnitFromAllUsesSections(
                                    Project1.MainUnitInfo.Source,ShortUnitName);
      if Dummy then
        Project1.MainUnitInfo.Modified:=true
      else begin
        ApplyCodeToolChanges;
        DoJumpToCodeToolBossError;
        Result:=mrCancel;
        exit;
      end;
    end;
    if (AnUnitInfo.ComponentName<>'') then begin
      Dummy:=Project1.RemoveCreateFormFromProjectFile(
          'T'+AnUnitInfo.ComponentName,AnUnitInfo.ComponentName);
      if not Dummy then begin
        ApplyCodeToolChanges;
        DoJumpToCodeToolBossError;
        Result:=mrCancel;
        exit;
      end;
    end;
    ApplyCodeToolChanges;
  end;
  Project1.Modified:=true;
end;

procedure TMainIDE.OnCompilerOptionsDialogTest(Sender: TObject);
begin
  DoTestCompilerSettings(Sender as TCompilerOptions);
end;

procedure TMainIDE.OnCompilerOptionsImExport(Sender: TObject);
begin
  DoImExportCompilerOptions(Sender);
end;

procedure TMainIDE.ProjInspectorOpen(Sender: TObject);
var
  CurUnitInfo: TUnitInfo;
begin
  CurUnitInfo:=ProjInspector.GetSelectedFile;
  if CurUnitInfo<>nil then begin
    DoOpenEditorFile(CurUnitInfo.Filename,-1,[ofRegularFile]);
    exit;
  end;
  if PkgBoss.OnProjectInspectorOpen(Sender) then exit;
end;

procedure TMainIDE.OnExtToolNeedsOutputFilter(var OutputFilter: TOutputFilter;
  var Abort: boolean);
begin
  OutputFilter:=TheOutputFilter;
  if ToolStatus<>itNone then begin
    Abort:=true;
    exit;
  end;
  SourceNotebook.ClearErrorLines;

  ToolStatus:=itBuilder;
  if CheckCompilerOptsDlg<>nil then begin
    TheOutputFilter.OnAddFilteredLine:=@CheckCompilerOptsDlg.AddMsg;
    TheOutputFilter.OnReadLine:=@CheckCompilerOptsDlg.AddProgress;
  end else begin
    MessagesView.Clear;
    DoArrangeSourceEditorAndMessageView(false);

    TheOutputFilter.OnAddFilteredLine:=@MessagesView.AddMsg;
    TheOutputFilter.OnReadLine:=@MessagesView.AddProgress;
  end;
end;

procedure TMainIDE.OnExtToolFreeOutputFilter(OutputFilter: TOutputFilter;
  ErrorOccurred: boolean);
begin
  if ToolStatus=itBuilder then
    ToolStatus:=itNone;
  if ErrorOccurred then
    DoJumpToCompilerMessage(-1,true);
end;

procedure TMainIDE.DoSwitchToFormSrc(var ActiveSourceEditor: TSourceEditor;
  var ActiveUnitInfo: TUnitInfo);
begin
  DoSwitchToFormSrc(nil,ActiveSourceEditor,ActiveUnitInfo);
end;

procedure TMainIDE.DoSwitchToFormSrc(ADesigner: TDesigner;
  var ActiveSourceEditor: TSourceEditor; var ActiveUnitInfo: TUnitInfo);
var i: integer;
begin
  ActiveSourceEditor:=nil;
  ActiveUnitInfo:=nil;
  if (ADesigner<>nil) then
    ActiveUnitInfo:=Project1.UnitWithComponent(ADesigner.LookupRoot)
  else if (GlobalDesignHook.LookupRoot<>nil)
  and (GlobalDesignHook.LookupRoot is TComponent) then
    ActiveUnitInfo:=
      Project1.UnitWithComponent(TComponent(GlobalDesignHook.LookupRoot))
  else
    ActiveUnitInfo:=nil;
  if (ActiveUnitInfo<>nil) then begin
    i:=ActiveUnitInfo.EditorIndex;
    if (i>=0) then begin
      SourceNoteBook.NoteBook.PageIndex:=i;
      GetCurrentUnit(ActiveSourceEditor,ActiveUnitInfo);
      exit;
    end;
  end;
end;

function TMainIDE.GetFormOfSource(AnUnitInfo: TUnitInfo; LoadForm: boolean
  ): TCustomForm;
begin
  Result:=nil;
  if (AnUnitInfo.Component=nil) and LoadForm
  and FilenameIsPascalSource(AnUnitInfo.Filename) then begin
    DoLoadLFM(AnUnitInfo,[]);
  end;
  if AnUnitInfo.Component<>nil then
    Result:=FormEditor1.GetDesignerForm(AnUnitInfo.Component);
end;

function TMainIDE.OnPropHookMethodExists(const AMethodName: ShortString;
  TypeData: PTypeData;
  var MethodIsCompatible,MethodIsPublished,IdentIsMethod: boolean): boolean;
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[ctfSwitchToFormSource])
  then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.OnPropHookMethodExists] ************ ',AMethodName);
  {$ENDIF}
  Result:=CodeToolBoss.PublishedMethodExists(ActiveUnitInfo.Source,
                        ActiveUnitInfo.Component.ClassName,AMethodName,TypeData,
                        MethodIsCompatible,MethodIsPublished,IdentIsMethod);
  if CodeToolBoss.ErrorMessage<>'' then begin
    DoJumpToCodeToolBossError;
    raise Exception.Create(lisUnableToFindMethodPlzFixTheErrorShownInTheMessage
      );
  end;
end;

function TMainIDE.OnPropHookCreateMethod(const AMethodName: ShortString;
  ATypeInfo: PTypeInfo): TMethod;
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  r: boolean;
begin
  Result.Code:=nil;
  Result.Data:=nil;
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[ctfSwitchToFormSource])
  then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.OnPropHookCreateMethod] ************ ',AMethodName);
  {$ENDIF}
  FOpenEditorsOnCodeToolChange:=true;
  try
    // create published method
    r:=CodeToolBoss.CreatePublishedMethod(ActiveUnitInfo.Source,
                ActiveUnitInfo.Component.ClassName,AMethodName,ATypeInfo);
    {$IFDEF IDE_DEBUG}
    writeln('');
    writeln('[TMainIDE.OnPropHookCreateMethod] ************2 ',r,' ',AMethodName);
    {$ENDIF}
    ApplyCodeToolChanges;
    if r then begin
      Result:=FormEditor1.CreateNewJITMethod(ActiveUnitInfo.Component,
                                             AMethodName);
    end else begin
      DoJumpToCodeToolBossError;
      raise Exception.Create(lisUnableToCreateNewMethodPlzFixTheErrorShownIn);
    end;
  finally
    FOpenEditorsOnCodeToolChange:=false;
  end;
end;

procedure TMainIDE.OnPropHookShowMethod(const AMethodName: ShortString);
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  NewSource: TCodeBuffer;
  NewX, NewY, NewTopLine: integer;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[ctfSwitchToFormSource])
  then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.OnPropHookShowMethod] ************ "',AMethodName,'" ',ActiveUnitInfo.Filename);
  {$ENDIF}

  if CodeToolBoss.JumpToPublishedMethodBody(ActiveUnitInfo.Source,
    ActiveUnitInfo.Component.ClassName,AMethodName,
    NewSource,NewX,NewY,NewTopLine) then
  begin
    DoJumpToCodePos(ActiveSrcEdit, ActiveUnitInfo,
      NewSource, NewX, NewY, NewTopLine, true);
  end else begin
    DoJumpToCodeToolBossError;
    raise Exception.Create(lisUnableToShowMethodPlzFixTheErrorShownInTheMessage
      );
  end;
end;

procedure TMainIDE.OnPropHookRenameMethod(const CurName, NewName: ShortString);
var ActiveSrcEdit: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
  BossResult: boolean;
  ErrorMsg: String;
begin
  if not BeginCodeTool(ActiveSrcEdit,ActiveUnitInfo,[ctfSwitchToFormSource])
  then exit;
  {$IFDEF IDE_DEBUG}
  writeln('');
  writeln('[TMainIDE.OnPropHookRenameMethod] ************');
  {$ENDIF}
  FOpenEditorsOnCodeToolChange:=true;
  try
    // create published method
    BossResult:=CodeToolBoss.RenamePublishedMethod(ActiveUnitInfo.Source,
                            ActiveUnitInfo.Component.ClassName,CurName,NewName);
    {$IFDEF IDE_DEBUG}
    writeln('');
    writeln('[TMainIDE.OnPropHookRenameMethod] ************2 ',r);
    {$ENDIF}
    ApplyCodeToolChanges;
    if BossResult then begin
      FormEditor1.RenameJITMethod(ActiveUnitInfo.Component,CurName,NewName);
    end else begin
      ErrorMsg:=CodeToolBoss.ErrorMessage;
      DoJumpToCodeToolBossError;
      raise Exception.Create(
        lisUnableToRenameMethodPlzFixTheErrorShownInTheMessag
        +#13#13+lisError+ErrorMsg);
    end;
  finally
    FOpenEditorsOnCodeToolChange:=false;
  end;
end;

function TMainIDE.OnPropHookBeforeAddPersistent(Sender: TObject;
  APersistentClass: TPersistentClass; AParent: TPersistent): boolean;
begin
  Result:=false;
  if (not (AParent is TControl))
  and (APersistentClass.InheritsFrom(TControl)) then begin
    MessageDlg(lisCodeToolsDefsInvalidParent,
      Format(lisACanNotHoldTControlsYouCanOnlyPutNonVisualComponen, [
        AParent.ClassName, #13]),
      mtError,[mbCancel],0);
    UpdateIDEComponentPalette;
    exit;
  end;
  Result:=true;
end;

procedure TMainIDE.OnPropHookComponentRenamed(AComponent: TComponent);
begin
  if (AComponent.Owner=nil) then
    FormEditor1.UpdateDesignerFormName(AComponent);
  ObjectInspector1.FillPersistentComboBox;
end;

{-------------------------------------------------------------------------------
  procedure TMainIDE.OnPropHookPersistentAdded(APersistent: TPersistent;
    Select: boolean);

  This handler is called whenever a new component was added to a designed form
  and should be added to form source
-------------------------------------------------------------------------------}
procedure TMainIDE.OnPropHookPersistentAdded(APersistent: TPersistent;
  Select: boolean);
var
  ComponentClass: TRegisteredComponent;
  ADesigner: TIDesigner;
  AComponent: TComponent;
begin
  DebugLn('TMainIDE.OnPropHookPersistentAdded A ',dbgsName(APersistent));
  if APersistent is TComponent then
    AComponent:=TComponent(APersistent)
  else
    AComponent:=nil;
  ComponentClass:=IDEComponentPalette.FindComponent(APersistent.ClassName);
  if (ComponentClass=nil) and (AComponent<>nil) then begin
    DebugLn('TMainIDE.OnPropHookPersistentAdded ',APersistent.ClassName,
            ' not registered');
    exit;
  end;
  if AComponent<>nil then begin
    // create unique name
    if AComponent.Name='' then
      AComponent.Name:=FormEditor1.CreateUniqueComponentName(AComponent);
    //writeln('TMainIDE.OnPropHookPersistentAdded B ',AComponent.Name,':',AComponent.ClassName);
    // create component interface
    if FormEditor1.FindComponent(AComponent)=nil then
      FormEditor1.CreateComponentInterface(AComponent);
    // set component into design mode
    SetDesigning(AComponent,true);
    //writeln('TMainIDE.OnPropHookPersistentAdded C ',AComponent.Name,':',AComponent.ClassName);
    // add to source
    ADesigner:=FindRootDesigner(AComponent);
  end;
  OnDesignerPersistentAdded(ADesigner,APersistent,ComponentClass);
  //writeln('TMainIDE.OnPropHookPersistentAdded D ',AComponent.Name,':',AComponent.ClassName,' ',Select);
  // select component
  if Select then begin
    TheControlSelection.AssignPersistent(APersistent);
  end;
  {$IFDEF IDE_DEBUG}
  writeln('TMainIDE.OnPropHookPersistentAdded END ',dbgsName(APersistent),' Select=',Select);
  {$ENDIF}
end;

procedure TMainIDE.OnPropHookDeletePersistent(APersistent: TPersistent);
var
  ADesigner: TDesigner;
  AComponent: TComponent;
begin
  DebugLn('TMainIDE.OnPropHookDeletePersistent A ',dbgsName(APersistent));
  if APersistent is TComponent then begin
    AComponent:=TComponent(APersistent);
    ADesigner:=TDesigner(FindRootDesigner(AComponent));
    if ADesigner=nil then exit;
    ADesigner.RemovePersistentAndChilds(AComponent);
  end;
end;

procedure TMainIDE.mnuEditCopyClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecCopy);
end;

procedure TMainIDE.mnuEditCutClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecCut);
end;

procedure TMainIDE.mnuEditPasteClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecPaste);
end;

procedure TMainIDE.mnuEditRedoClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecRedo);
end;

procedure TMainIDE.mnuEditUndoClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecUndo);
end;

procedure TMainIDE.mnuEditIndentBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecBlockIndent);
end;

procedure TMainIDE.mnuEditUnindentBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecBlockUnindent);
end;

procedure TMainIDE.mnuEditEncloseBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectionEnclose);
end;

procedure TMainIDE.mnuEditUpperCaseBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectionUpperCase);
end;

procedure TMainIDE.mnuEditLowerCaseBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectionLowerCase);
end;

procedure TMainIDE.mnuEditTabsToSpacesBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectionTabs2Spaces);
end;

procedure TMainIDE.mnuEditCommentBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectionComment);
end;

procedure TMainIDE.mnuEditUncommentBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectionUncomment);
end;

procedure TMainIDE.mnuEditConditionalBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectionConditional);
end;

procedure TMainIDE.mnuEditSortBlockClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectionSort);
end;

procedure TMainIDE.mnuEditSelectionBreakLinesClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectionBreakLines);
end;

procedure TMainIDE.mnuEditSelectAllClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectAll);
end;

procedure TMainIDE.mnuEditSelectCodeBlockClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectCodeBlock);
end;

procedure TMainIDE.mnuEditSelectToBraceClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectToBrace);
end;

procedure TMainIDE.mnuEditSelectLineClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectLine);
end;

procedure TMainIDE.mnuEditSelectParagraphClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecSelectParagraph);
end;

procedure TMainIDE.mnuEditInsertGPLNoticeClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertGPLNotice);
end;

procedure TMainIDE.mnuEditInsertLGPLNoticeClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertLGPLNotice);
end;

procedure TMainIDE.mnuEditInsertUsernameClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertUserName);
end;

procedure TMainIDE.mnuEditInsertDateTimeClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertDateTime);
end;

procedure TMainIDE.mnuEditInsertChangeLogEntryClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertChangeLogEntry);
end;

procedure TMainIDE.mnuSearchFindInFiles(Sender: TObject);
begin
  DoFindInFiles;
end;

procedure TMainIDE.mnuSearchFindIdentifierRefsClicked(Sender: TObject);
begin
  DoFindRenameIdentifier(false);
end;

procedure TMainIDE.mnuSearchRenameIdentifierClicked(Sender: TObject);
begin
  DoFindRenameIdentifier(true);
end;

procedure TMainIDE.mnuEditCompleteCodeClicked(Sender: TObject);
begin
  DoCompleteCodeAtCursor;
end;

procedure TMainIDE.mnuEditExtractProcClicked(Sender: TObject);
begin
  DoExtractProcFromSelection;
end;

procedure TMainIDE.mnuEditInsertCharacterClicked(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertCharacter);
end;

procedure TMainIDE.mnuEditInsertCVSAuthorClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertCVSAuthor);
end;

procedure TMainIDE.mnuEditInsertCVSDateClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertCVSDate);
end;

procedure TMainIDE.mnuEditInsertCVSHeaderClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertCVSHeader);
end;

procedure TMainIDE.mnuEditInsertCVSIDClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertCVSID);
end;

procedure TMainIDE.mnuEditInsertCVSLogClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertCVSLog);
end;

procedure TMainIDE.mnuEditInsertCVSNameClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertCVSName);
end;

procedure TMainIDE.mnuEditInsertCVSRevisionClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertCVSRevision);
end;

procedure TMainIDE.mnuEditInsertCVSSourceClick(Sender: TObject);
begin
  DoSourceEditorCommand(ecInsertCVSSource);
end;

procedure TMainIDE.DoCommand(EditorCommand: integer);
var
  ActiveSourceEditor: TSourceEditor;
  ActiveUnitInfo: TUnitInfo;
begin
  GetCurrentUnit(ActiveSourceEditor,ActiveUnitInfo);
  if FDisplayState = dsSource then begin
    // send command to source editor
    if (ActiveSourceEditor=nil) then exit;
    ActiveSourceEditor.DoEditorExecuteCommand(EditorCommand);
  end else begin
    // send command to form editor
    if ActiveUnitInfo=nil then exit;

    // ToDo: send command to form editor/designer

  end;
end;

procedure TMainIDE.DoSourceEditorCommand(EditorCommand: integer);
var
  CurFocusControl: TWinControl;
begin
  // check that the currently focus is on the MainIDEBar or on the SourceEditor
  CurFocusControl:=FindOwnerControl(GetFocus);
  if (CurFocusControl<>nil) then begin
    CurFocusControl:=GetParentForm(CurFocusControl);
    if (CurFocusControl<>MainIDEBar) and (CurFocusControl<>SourceNotebook) then
      exit;
  end;
  DoCommand(EditorCommand);
end;

procedure TMainIDE.OnApplyWindowLayout(ALayout: TIDEWindowLayout);
var
  l: TNonModalIDEWindow;
  BarBottom: Integer;
begin
  if (ALayout=nil) or (ALayout.Form=nil) then exit;
  // writeln('AAA TMainIDE.OnApplyWindowLayout ',ALayout.Form.Name,' ',ALayout.Form.Classname,' ',IDEWindowPlacementNames[ALayout.WindowPlacement],' ',ALayout.CustomCoordinatesAreValid,' ',ALayout.Left,' ',ALayout.Top,' ',ALayout.Width,' ',ALayout.Height);
  if (ALayout.WindowPlacement in [iwpCustomPosition,iwpRestoreWindowGeometry])
  then begin
    case ALayout.WindowState of
    iwsMinimized: ALayout.Form.WindowState:=wsMinimized;
    iwsMaximized: ALayout.Form.WindowState:=wsMaximized;
    end;

    if (ALayout.CustomCoordinatesAreValid) then begin
      // explicit position
      ALayout.Form.SetRestoredBounds(
        ALayout.Left,ALayout.Top,ALayout.Width,ALayout.Height);
      exit;
    end;

    if ALayout.WindowState in [iwsMinimized, iwsMaximized] then
      exit;
  end else if ALayout.WindowPlacement in [iwpDocked,iwpUseWindowManagerSetting]
  then begin
    exit;
  end;
  // no layout found => use default
  BarBottom:=MainIDEBar.Top+MainIDEBar.Height;
  // default window positions
  l:=NonModalIDEFormIDToEnum(ALayout.FormID);
  case l of
  nmiwMainIDEName:
    ALayout.Form.SetBounds(0,0,Screen.Width-10,95);
  nmiwSourceNoteBookName:
    ALayout.Form.SetBounds(250,BarBottom+30,Max(50,Screen.Width-300),
      Max(50,Screen.Height-200-BarBottom));
  nmiwUnitDependenciesName:
    ALayout.Form.SetBounds(200,200,400,300);
  nmiwCodeExplorerName:
    ALayout.Form.SetBounds(Screen.Width-200,130,170,Max(50,Screen.Height-230));
  nmiwClipbrdHistoryName:
    ALayout.Form.SetBounds(250,Screen.Height-400,400,300);
  nmiwPkgGraphExplorer:
    ALayout.Form.SetBounds(250,150,500,350);
  nmiwProjectInspector:
    ALayout.Form.SetBounds(210,150,400,300);
  nmiwMessagesViewName:
    ALayout.Form.SetBounds(260,SourceNotebook.Top+SourceNotebook.Height+30,
      Max(50,Screen.Width-300),80);
  else
    if ALayout.FormID=DefaultObjectInspectorName then begin
      ALayout.Form.SetBounds(
        MainIDEBar.Left,BarBottom+30,230,Max(Screen.Height-BarBottom-120,50));
    end;
  end;
end;

procedure TMainIDE.AddRecentProjectFileToEnvironment(const AFilename: string);
begin
  EnvironmentOptions.AddToRecentProjectFiles(AFilename);
  SetRecentProjectFilesMenu;
  SaveEnvironment;
end;

procedure TMainIDE.StartProtocol;
begin
  IDEProtocolOpts:=TIDEProtocol.Create;
  IDEProtocolOpts.Load;
end;

procedure TMainIDE.mnuSearchFindBlockOtherEnd(Sender: TObject);
begin
  DoGoToPascalBlockOtherEnd;
end;

procedure TMainIDE.mnuSearchFindBlockStart(Sender: TObject);
begin
  DoGoToPascalBlockStart;
end;

procedure TMainIDE.mnuSearchFindDeclaration(Sender: TObject);
begin
  DoFindDeclarationAtCursor;
end;


//-----------------------------------------------------------------------------

initialization
  {$I ../images/laz_images.lrs}
  {$I ../images/mainicon.lrs}
  ShowSplashScreen:=true;

end.

