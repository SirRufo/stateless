program Adventure;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Stateless,
  Stateless.Utils;

type
  TDirection = ( North, East, South, West );

  TAdventureSM = TStateMachine<string, TDirection>;

  {* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
   * DUNGEON MAP:
   * +---+   +---+   +---+   +---+
   * |En.|<->|C 1|<->|C 2|<->|C 3|
   * +---+   +---+   +---+   +---+
   *           ^       ^       ^
   *           v       |       v
   *         +---+   +---+   +---+
   *         |C 4|-->|C 5|   |C#6|
   *         +---+   +---+   +---+
   *                   #
   *                   v
   *                 +---+
   *                 |Ex.|
   *                 +---+
   *
   * You must first enter Chamber 6 to get the key
   * that will unlock the door in Chamber 5!
   *
   * WALKTHROUGH:
   * East, East, East, South, North, West, West, South, East, South
   * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

procedure AdventureRun;
var
  SM          : TAdventureSM;
  PlayerHasKey: Boolean;
  input       : string;
  moveto      : TDirection;
begin
  SM := TAdventureSM.Create( 'Entrance' );

  SM.Configure( 'Entrance' )
  {} .Permit( TDirection.East, 'Chamber 1' );

  SM.Configure( 'Chamber 1' )
  {} .Permit( TDirection.West, 'Entrance' )
  {} .Permit( TDirection.East, 'Chamber 2' )
  {} .Permit( TDirection.South, 'Chamber 4' );

  SM.Configure( 'Chamber 2' )
  {} .Permit( TDirection.West, 'Chamber 1' )
  {} .Permit( TDirection.East, 'Chamber 3' );

  SM.Configure( 'Chamber 3' )
  {} .Permit( TDirection.West, 'Chamber 2' )
  {} .Permit( TDirection.South, 'Chamber 6' );

  SM.Configure( 'Chamber 4' )
  {} .Permit( TDirection.North, 'Chamber 1' )
  {} .Permit( TDirection.East, 'Chamber 5' );

  SM.Configure( 'Chamber 5' )
  {} .Permit( TDirection.North, 'Chamber 2' )
  {} .PermitIf( TDirection.South, 'Exit',
    function: Boolean
    begin
      Result := PlayerHasKey;
    end );

  SM.Configure( 'Chamber 6' )
  {} .OnEntry(
    procedure
    begin
      if not PlayerHasKey
      then
        begin
          PlayerHasKey := True;
          WriteLn( 'You picked up a key.' );
        end;
    end )
  {} .Permit( TDirection.North, 'Chamber 3' );

  WriteLn( 'Welcome to the dungeon, fearless!' );
  repeat
    WriteLn( 'You are here: ', SM.State );

    while True do
      begin
        while True do
          begin
            write( 'Where do you want to go (', string.Join( ', ', TArray.Cast<TDirection, string>( SM.PermittedTriggers,
              function( const v:TDirection ):string
              begin
                Result := TEnum.AsString( v );
              end ) ), ')? ' );
            Readln( input );
            if TEnum.TryFromString<TDirection>( input, moveto )
            then
              Break;
            WriteLn( 'I do not understand ', input );
          end;

        if SM.CanFire( moveto )
        then
          Break;

        WriteLn( 'You cannot move to ', TEnum.AsString( moveto ) );
      end;

    SM.Fire( moveto );

  until SM.State = 'Exit';

  WriteLn( 'Well done!' );
end;

begin
  try
    AdventureRun;
  except
    on E: Exception do
      WriteLn( E.ClassName, ': ', E.Message );
  end;
  Readln;

end.
