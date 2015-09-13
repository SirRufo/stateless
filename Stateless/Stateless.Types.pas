{************************************************************************
 Copyright 2015 Oliver Münzberg (aka Sir Rufo)

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 ************************************************************************}
unit Stateless.Types;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.SysUtils,
  System.Types;

{$REGION 'Tuple'}

type
  Tuple<T> = record
    Item1: T;
    class operator Equal( a, b: Tuple<T> ): Boolean;
    class operator NotEqual( a, b: Tuple<T> ): Boolean;
  end;

  Tuple<T1, T2> = record
    Item1: T1;
    Item2: T2;
    class operator Equal( a, b: Tuple<T1, T2> ): Boolean;
    class operator NotEqual( a, b: Tuple<T1, T2> ): Boolean;
  end;

  Tuple<T1, T2, T3> = record
    Item1: T1;
    Item2: T2;
    Item3: T3;
    class operator Equal( a, b: Tuple<T1, T2, T3> ): Boolean;
    class operator NotEqual( a, b: Tuple<T1, T2, T3> ): Boolean;
  end;

  Tuple<T1, T2, T3, T4> = record
    Item1: T1;
    Item2: T2;
    Item3: T3;
    Item4: T4;
    class operator Equal( a, b: Tuple<T1, T2, T3, T4> ): Boolean;
    class operator NotEqual( a, b: Tuple<T1, T2, T3, T4> ): Boolean;
  end;

  Tuple<T1, T2, T3, T4, T5> = record
    Item1: T1;
    Item2: T2;
    Item3: T3;
    Item4: T4;
    Item5: T5;
    class operator Equal( a, b: Tuple<T1, T2, T3, T4, T5> ): Boolean;
    class operator NotEqual( a, b: Tuple<T1, T2, T3, T4, T5> ): Boolean;
  end;

  Tuple<T1, T2, T3, T4, T5, T6> = record
    Item1: T1;
    Item2: T2;
    Item3: T3;
    Item4: T4;
    Item5: T5;
    Item6: T6;
    class operator Equal( a, b: Tuple<T1, T2, T3, T4, T5, T6> ): Boolean;
    class operator NotEqual( a, b: Tuple<T1, T2, T3, T4, T5, T6> ): Boolean;
  end;

  Tuple<T1, T2, T3, T4, T5, T6, T7> = record
    Item1: T1;
    Item2: T2;
    Item3: T3;
    Item4: T4;
    Item5: T5;
    Item6: T6;
    Item7: T7;
    class operator Equal( a, b: Tuple<T1, T2, T3, T4, T5, T6, T7> ): Boolean;
    class operator NotEqual( a, b: Tuple<T1, T2, T3, T4, T5, T6, T7> ): Boolean;
  end;

  Tuple<T1, T2, T3, T4, T5, T6, T7, T8> = record
    Item1: T1;
    Item2: T2;
    Item3: T3;
    Item4: T4;
    Item5: T5;
    Item6: T6;
    Item7: T7;
    Item8: T8;
    class operator Equal( a, b: Tuple<T1, T2, T3, T4, T5, T6, T7, T8> ): Boolean;
    class operator NotEqual( a, b: Tuple<T1, T2, T3, T4, T5, T6, T7, T8> ): Boolean;
  end;

  Tuple = record
    class function Create<T>( Item1: T ): Tuple<T>; overload; static;
    class function Create<T1, T2>( Item1: T1; Item2: T2 ): Tuple<T1, T2>; overload; static;
    class function Create<T1, T2, T3>( Item1: T1; Item2: T2; Item3: T3 ): Tuple<T1, T2, T3>; overload; static;
    class function Create<T1, T2, T3, T4>( Item1: T1; Item2: T2; Item3: T3; Item4: T4 ): Tuple<T1, T2, T3, T4>; overload; static;
    class function Create<T1, T2, T3, T4, T5>( Item1: T1; Item2: T2; Item3: T3; Item4: T4; Item5: T5 ): Tuple<T1, T2, T3, T4, T5>; overload; static;
    class function Create<T1, T2, T3, T4, T5, T6>( Item1: T1; Item2: T2; Item3: T3; Item4: T4; Item5: T5; Item6: T6 ): Tuple<T1, T2, T3, T4, T5, T6>;
      overload; static;
    class function Create<T1, T2, T3, T4, T5, T6, T7>( Item1: T1; Item2: T2; Item3: T3; Item4: T4; Item5: T5; Item6: T6; Item7: T7 )
      : Tuple<T1, T2, T3, T4, T5, T6, T7>; overload; static;
    class function Create<T1, T2, T3, T4, T5, T6, T7, T8>( Item1: T1; Item2: T2; Item3: T3; Item4: T4; Item5: T5; Item6: T6; Item7: T7; Item8: T8 )
      : Tuple<T1, T2, T3, T4, T5, T6, T7, T8>; overload; static;
  end;

{$ENDREGION}
{$REGION 'TVersion'}

type
  TVersion = record
  private
    FMajor   : WORD;
    FMinor   : WORD;
    FBuild   : WORD;
    FRevision: WORD;
    function GetMajorRevision: Byte;
    function GetMinorRevision: Byte;
  public
    constructor Create( Version: string ); overload;
    constructor CreateFromWinVersion( Version: DWORD ); overload;
    constructor CreateFromMSLS( VersionMS, VersionLS: DWORD );
    constructor Create( Major, Minor: WORD ); overload;
    constructor Create( Major, Minor, Build: WORD ); overload;
    constructor Create( Major, Minor, Build, Revision: WORD ); overload;

    class function Parse( const Input: string ): TVersion; static;
    class function TryParse( const Input: string; out Version: TVersion ): Boolean; static;

    class function Compare( const a, b: TVersion ): Integer; static;
    class function Comparer: IComparer<TVersion>; static;
    class function EqualityComparer: IEqualityComparer<TVersion>; static;

    class operator Equal( a, b: TVersion ): Boolean;
    class operator NotEqual( a, b: TVersion ): Boolean;
    class operator GreaterThan( a, b: TVersion ): Boolean;
    class operator GreaterThanOrEqual( a, b: TVersion ): Boolean;
    class operator LessThan( a, b: TVersion ): Boolean;
    class operator LessThanOrEqual( a, b: TVersion ): Boolean;

    property Major: WORD read FMajor;
    property Minor: WORD read FMinor;
    property Build: WORD read FBuild;
    property Revision: WORD read FRevision;
    property MajorRevision: Byte read GetMajorRevision;
    property MinorRevision: Byte read GetMinorRevision;

    function ToString( ): string;
    function GetHashCode( ): Integer;
  end;
{$ENDREGION}

type
  TAction = reference to procedure;

  TAction<T> = reference to procedure( const Arg: T );

  TAction<T1, T2> = reference to procedure( const Arg1: T1; const Arg2: T2 );

  TAction<T1, T2, T3> = reference to procedure( const Arg1: T1; const Arg2: T2; const Arg3: T3 );

  TAction<T1, T2, T3, T4> = reference to procedure( const Arg1: T1; const Arg2: T2; const Arg3: T3; const Arg4: T4 );

  TFilter<T> = reference to function( const Arg: T ): Boolean;

  TFunction<TResult> = reference to function: TResult;

  TFunction<T, TResult> = reference to function( const Arg: T ): TResult;

  TFunction<T1, T2, TResult> = reference to function( const Arg1: T1; const Arg2: T2 ): TResult;

  TFunction<T1, T2, T3, TResult> = reference to function( const Arg1: T1; const Arg2: T2; const Arg3: T3 ): TResult;

  TFunction<T1, T2, T3, T4, TResult> = reference to function( const Arg1: T1; const Arg2: T2; const Arg3: T3; const Arg4: T4 ): TResult;

type
  Nullable<T> = record
  private
    FValue   : T;
    FHasValue: string;
    function GetValue: T;
  public
    class operator implicit( const a: T ): Nullable<T>;
    class operator implicit( const a: Nullable<T> ): T;
    procedure Clear;
    function HasValue: Boolean;
    property Value: T read GetValue;
  end;

implementation

uses
  System.Classes,
  System.TypInfo;

{$REGION 'Tuple Implementation'}
{ Tuple }

class function Tuple.Create<T1, T2, T3, T4, T5, T6, T7, T8>( Item1: T1; Item2: T2; Item3: T3; Item4: T4; Item5: T5; Item6: T6; Item7: T7; Item8: T8 )
  : Tuple<T1, T2, T3, T4, T5, T6, T7, T8>;
begin
  Result.Item1 := Item1;
  Result.Item2 := Item2;
  Result.Item3 := Item3;
  Result.Item4 := Item4;
  Result.Item5 := Item5;
  Result.Item6 := Item6;
  Result.Item7 := Item7;
  Result.Item8 := Item8;
end;

class function Tuple.Create<T1, T2, T3, T4, T5, T6, T7>( Item1: T1; Item2: T2; Item3: T3; Item4: T4; Item5: T5; Item6: T6; Item7: T7 )
  : Tuple<T1, T2, T3, T4, T5, T6, T7>;
begin
  Result.Item1 := Item1;
  Result.Item2 := Item2;
  Result.Item3 := Item3;
  Result.Item4 := Item4;
  Result.Item5 := Item5;
  Result.Item6 := Item6;
  Result.Item7 := Item7;
end;

class function Tuple.Create<T1, T2, T3, T4, T5, T6>( Item1: T1; Item2: T2; Item3: T3; Item4: T4; Item5: T5; Item6: T6 ): Tuple<T1, T2, T3, T4, T5, T6>;
begin
  Result.Item1 := Item1;
  Result.Item2 := Item2;
  Result.Item3 := Item3;
  Result.Item4 := Item4;
  Result.Item5 := Item5;
  Result.Item6 := Item6;
end;

class function Tuple.Create<T1, T2, T3, T4, T5>( Item1: T1; Item2: T2; Item3: T3; Item4: T4; Item5: T5 ): Tuple<T1, T2, T3, T4, T5>;
begin
  Result.Item1 := Item1;
  Result.Item2 := Item2;
  Result.Item3 := Item3;
  Result.Item4 := Item4;
  Result.Item5 := Item5;
end;

class function Tuple.Create<T1, T2, T3, T4>( Item1: T1; Item2: T2; Item3: T3; Item4: T4 ): Tuple<T1, T2, T3, T4>;
begin
  Result.Item1 := Item1;
  Result.Item2 := Item2;
  Result.Item3 := Item3;
  Result.Item4 := Item4;
end;

class function Tuple.Create<T1, T2, T3>( Item1: T1; Item2: T2; Item3: T3 ): Tuple<T1, T2, T3>;
begin
  Result.Item1 := Item1;
  Result.Item2 := Item2;
  Result.Item3 := Item3;
end;

class function Tuple.Create<T1, T2>( Item1: T1; Item2: T2 ): Tuple<T1, T2>;
begin
  Result.Item1 := Item1;
  Result.Item2 := Item2;
end;

class function Tuple.Create<T>( Item1: T ): Tuple<T>;
begin
  Result.Item1 := Item1;
end;

{ Tuple<T> }

class operator Tuple<T>.Equal( a, b: Tuple<T> ): Boolean;
begin
  Result := TEqualityComparer<T>.Default.Equals( a.Item1, b.Item1 );
end;

class operator Tuple<T>.NotEqual( a, b: Tuple<T> ): Boolean;
begin
  Result := not( a = b );
end;

{ Tuple<T1, T2> }

class operator Tuple<T1, T2>.Equal( a, b: Tuple<T1, T2> ): Boolean;
begin
  Result := true
  {T1} and TEqualityComparer<T1>.Default.Equals( a.Item1, b.Item1 )
  {T2} and TEqualityComparer<T2>.Default.Equals( a.Item2, b.Item2 )
end;

class operator Tuple<T1, T2>.NotEqual( a, b: Tuple<T1, T2> ): Boolean;
begin
  Result := not( a = b );
end;

{ Tuple<T1, T2, T3> }

class operator Tuple<T1, T2, T3>.Equal( a, b: Tuple<T1, T2, T3> ): Boolean;
begin
  Result := true
  {T1} and TEqualityComparer<T1>.Default.Equals( a.Item1, b.Item1 )
  {T2} and TEqualityComparer<T2>.Default.Equals( a.Item2, b.Item2 )
  {T3} and TEqualityComparer<T3>.Default.Equals( a.Item3, b.Item3 )
end;

class operator Tuple<T1, T2, T3>.NotEqual( a, b: Tuple<T1, T2, T3> ): Boolean;
begin
  Result := not( a = b );
end;

{ Tuple<T1, T2, T3, T4> }

class operator Tuple<T1, T2, T3, T4>.Equal( a, b: Tuple<T1, T2, T3, T4> ): Boolean;
begin
  Result := true
  {T1} and TEqualityComparer<T1>.Default.Equals( a.Item1, b.Item1 )
  {T2} and TEqualityComparer<T2>.Default.Equals( a.Item2, b.Item2 )
  {T3} and TEqualityComparer<T3>.Default.Equals( a.Item3, b.Item3 )
  {T4} and TEqualityComparer<T4>.Default.Equals( a.Item4, b.Item4 )
end;

class operator Tuple<T1, T2, T3, T4>.NotEqual( a, b: Tuple<T1, T2, T3, T4> ): Boolean;
begin
  Result := not( a = b );
end;

{ Tuple<T1, T2, T3, T4, T5> }

class operator Tuple<T1, T2, T3, T4, T5>.Equal( a, b: Tuple<T1, T2, T3, T4, T5> ): Boolean;
begin
  Result := true
  {T1} and TEqualityComparer<T1>.Default.Equals( a.Item1, b.Item1 )
  {T2} and TEqualityComparer<T2>.Default.Equals( a.Item2, b.Item2 )
  {T3} and TEqualityComparer<T3>.Default.Equals( a.Item3, b.Item3 )
  {T4} and TEqualityComparer<T4>.Default.Equals( a.Item4, b.Item4 )
  {T5} and TEqualityComparer<T5>.Default.Equals( a.Item5, b.Item5 )
end;

class operator Tuple<T1, T2, T3, T4, T5>.NotEqual( a, b: Tuple<T1, T2, T3, T4, T5> ): Boolean;
begin
  Result := not( a = b );
end;

{ Tuple<T1, T2, T3, T4, T5, T6> }

class operator Tuple<T1, T2, T3, T4, T5, T6>.Equal( a, b: Tuple<T1, T2, T3, T4, T5, T6> ): Boolean;
begin
  Result := true
  {T1} and TEqualityComparer<T1>.Default.Equals( a.Item1, b.Item1 )
  {T2} and TEqualityComparer<T2>.Default.Equals( a.Item2, b.Item2 )
  {T3} and TEqualityComparer<T3>.Default.Equals( a.Item3, b.Item3 )
  {T4} and TEqualityComparer<T4>.Default.Equals( a.Item4, b.Item4 )
  {T5} and TEqualityComparer<T5>.Default.Equals( a.Item5, b.Item5 )
  {T6} and TEqualityComparer<T6>.Default.Equals( a.Item6, b.Item6 )
end;

class operator Tuple<T1, T2, T3, T4, T5, T6>.NotEqual( a, b: Tuple<T1, T2, T3, T4, T5, T6> ): Boolean;
begin
  Result := not( a = b );
end;

{ Tuple<T1, T2, T3, T4, T5, T6, T7> }

class operator Tuple<T1, T2, T3, T4, T5, T6, T7>.Equal( a, b: Tuple<T1, T2, T3, T4, T5, T6, T7> ): Boolean;
begin
  Result := true
  {T1} and TEqualityComparer<T1>.Default.Equals( a.Item1, b.Item1 )
  {T2} and TEqualityComparer<T2>.Default.Equals( a.Item2, b.Item2 )
  {T3} and TEqualityComparer<T3>.Default.Equals( a.Item3, b.Item3 )
  {T4} and TEqualityComparer<T4>.Default.Equals( a.Item4, b.Item4 )
  {T5} and TEqualityComparer<T5>.Default.Equals( a.Item5, b.Item5 )
  {T6} and TEqualityComparer<T6>.Default.Equals( a.Item6, b.Item6 )
  {T7} and TEqualityComparer<T7>.Default.Equals( a.Item7, b.Item7 )
end;

class operator Tuple<T1, T2, T3, T4, T5, T6, T7>.NotEqual( a, b: Tuple<T1, T2, T3, T4, T5, T6, T7> ): Boolean;
begin
  Result := not( a = b );
end;

{ Tuple<T1, T2, T3, T4, T5, T6, T7, T8> }

class operator Tuple<T1, T2, T3, T4, T5, T6, T7, T8>.Equal( a, b: Tuple<T1, T2, T3, T4, T5, T6, T7, T8> ): Boolean;
begin
  Result := true
  {T1} and TEqualityComparer<T1>.Default.Equals( a.Item1, b.Item1 )
  {T2} and TEqualityComparer<T2>.Default.Equals( a.Item2, b.Item2 )
  {T3} and TEqualityComparer<T3>.Default.Equals( a.Item3, b.Item3 )
  {T4} and TEqualityComparer<T4>.Default.Equals( a.Item4, b.Item4 )
  {T5} and TEqualityComparer<T5>.Default.Equals( a.Item5, b.Item5 )
  {T6} and TEqualityComparer<T6>.Default.Equals( a.Item6, b.Item6 )
  {T7} and TEqualityComparer<T7>.Default.Equals( a.Item7, b.Item7 )
  {T8} and TEqualityComparer<T8>.Default.Equals( a.Item8, b.Item8 )
end;

class operator Tuple<T1, T2, T3, T4, T5, T6, T7, T8>.NotEqual( a, b: Tuple<T1, T2, T3, T4, T5, T6, T7, T8> ): Boolean;
begin
  Result := not( a = b );
end;

{$ENDREGION}
{$REGION 'TVersion Implementation'}
{ TVersion }

constructor TVersion.Create( Major, Minor: WORD );
begin
  Create( Major, Minor, 0, 0 );
end;

constructor TVersion.Create( Version: string );
var
  LParts: TArray<string>;
begin
  LParts := Version.Split( [ '.' ] );
  case Length( LParts ) of
    2:
      Create( StrToInt( LParts[ 0 ] ), StrToInt( LParts[ 1 ] ) );
    3:
      Create( StrToInt( LParts[ 0 ] ), StrToInt( LParts[ 1 ] ), StrToInt( LParts[ 2 ] ) );
    4:
      Create( StrToInt( LParts[ 0 ] ), StrToInt( LParts[ 1 ] ), StrToInt( LParts[ 2 ] ), StrToInt( LParts[ 3 ] ) );
  else
    raise EArgumentException.CreateFmt( '"%s" is not a valid version string', [ Version ] );
  end;
end;

class function TVersion.Compare( const a, b: TVersion ): Integer;
begin
  if a.Major <> b.Major
  then
    Result := a.Major - b.Major
  else if a.Minor <> b.Minor
  then
    Result := a.Minor - b.Minor
  else if a.Build <> b.Build
  then
    Result := a.Build - b.Build
  else
    Result := a.Revision - b.Revision;
end;

class function TVersion.Comparer: IComparer<TVersion>;
begin
  Result := TComparer<TVersion>.Construct( Compare );
end;

constructor TVersion.Create( Major, Minor, Build, Revision: WORD );
begin
  FMajor    := Major;
  FMinor    := Minor;
  FBuild    := Build;
  FRevision := Revision;
end;

constructor TVersion.CreateFromMSLS( VersionMS, VersionLS: DWORD );
begin
  Create(
    ( VersionMS and $FFFF0000 ) shr 16,
    ( VersionMS and $0000FFFF ),
    ( VersionLS and $FFFF0000 ) shr 16,
    ( VersionLS and $0000FFFF ) );
end;

constructor TVersion.CreateFromWinVersion( Version: DWORD );
begin
  Create(
    ( Version and $000000FF ),
    ( Version and $0000FF00 ) shr 8,
    ( Version and $FFFF0000 ) shr 16 );
end;

class operator TVersion.Equal( a, b: TVersion ): Boolean;
begin
  Result := true
  {Major} and ( a.Major = b.Major )
  {Minor} and ( a.Minor = b.Minor )
  {Build} and ( a.Build = b.Build )
  {Revision} and ( a.Revision = b.Revision );
end;

class function TVersion.EqualityComparer: IEqualityComparer<TVersion>;
begin
  Result := TEqualityComparer<TVersion>.Construct(
    function( const L, R: TVersion ): Boolean
    begin
      Result := ( L = R );
    end,
    function( const Item: TVersion ): Integer
    begin
      Result := Item.GetHashCode( );
    end );
end;

function TVersion.GetHashCode: Integer;
begin
  Result := ToString( ).GetHashCode( );
end;

function TVersion.GetMajorRevision: Byte;
begin
  Result := ( FRevision and $FF00 ) shr 8;
end;

function TVersion.GetMinorRevision: Byte;
begin
  Result := FRevision and $00FF;
end;

class operator TVersion.GreaterThan( a, b: TVersion ): Boolean;
begin
  Result := false
  {Major} or ( ( a.Major > b.Major ) )
  {Minor} or ( ( a.Major = b.Major ) and ( a.Minor > b.Minor ) )
  {Build} or ( ( a.Major = b.Major ) and ( a.Minor = b.Minor ) and ( a.Build > b.Build ) )
  {Revision} or ( ( a.Major = b.Major ) and ( a.Minor = b.Minor ) and ( a.Build = b.Build ) and ( a.Revision > b.Revision ) )
end;

class operator TVersion.GreaterThanOrEqual( a, b: TVersion ): Boolean;
begin
  Result := ( a = b ) or ( a > b );
end;

class operator TVersion.LessThan( a, b: TVersion ): Boolean;
begin
  Result := ( b > a );
end;

class operator TVersion.LessThanOrEqual( a, b: TVersion ): Boolean;
begin
  Result := ( b >= a );
end;

class operator TVersion.NotEqual( a, b: TVersion ): Boolean;
begin
  Result := not( a = b );
end;

class function TVersion.Parse( const Input: string ): TVersion;
begin
  Result := TVersion.Create( Input );
end;

function TVersion.ToString: string;
var
  LFmtStr: string;
begin
  if Revision <> 0
  then
    LFmtStr := '%d.%d.%d.%d'
  else if Build <> 0
  then
    LFmtStr := '%d.%d.%d'
  else
    LFmtStr := '%d.%d';
  Result    := Format( LFmtStr, [ Major, Minor, Build, Revision ] );
end;

class function TVersion.TryParse( const Input: string; out Version: TVersion ): Boolean;
begin
  try
    Version := Parse( Input );
    Result  := true;
  except
    Result := false;
  end;
end;

constructor TVersion.Create( Major, Minor, Build: WORD );
begin
  Create( Major, Minor, Build, 0 );
end;
{$ENDREGION}

{ Nullable<T> }

procedure Nullable<T>.Clear;
begin
  FValue    := default ( T );
  FHasValue := string.Empty;
end;

function Nullable<T>.GetValue: T;
begin
  if not HasValue
  then
    raise EInvalidOpException.Create( 'Value is NULL' );
  Result := FValue;
end;

function Nullable<T>.HasValue: Boolean;
begin
  Result := FHasValue <> string.Empty;
end;

class operator Nullable<T>.implicit( const a: Nullable<T> ): T;
begin
  Result := a.Value;
end;

class operator Nullable<T>.implicit( const a: T ): Nullable<T>;
begin
  Result.FValue    := a;
  Result.FHasValue := '*';
end;

end.
