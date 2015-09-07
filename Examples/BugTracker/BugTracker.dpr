program BugTracker;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Bug in 'Bug.pas';

procedure Test;
var
  LBug: TBug;
begin
  LBug := TBug.Create( 'Incorrect stock count' );
  try
    WriteLn( LBug.ToString );
    WriteLn( '* Assign to Joe' );
    LBug.Assign( 'Joe' );
    WriteLn( LBug.ToString );
    WriteLn( '* Defer' );
    LBug.Defer;
    WriteLn( LBug.ToString );
    WriteLn( '* Assign to Harry' );
    LBug.Assign( 'Harry' );
    WriteLn( LBug.ToString );
    WriteLn( '* Assign to Fred' );
    LBug.Assign( 'Fred' );
    WriteLn( LBug.ToString );
    WriteLn( '* Close' );
    LBug.Close;
    WriteLn( LBug.ToString );
  finally
    LBug.Free;
  end;
end;

begin
  ReportMemoryLeaksOnShutdown := true;
  try
    Test;
  except
    on E: Exception do
      WriteLn( E.ClassName, ': ', E.Message );
  end;
  ReadLn;

end.
