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
unit Stateless.Utils;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  Stateless.Types;

type
  TDelegateOnDestroy = class( TInterfacedObject )
  private
    FProc: TProc;
    constructor Create( const AProc: TProc );
  public
    destructor Destroy; override;
    class function Construct( const AProc: TProc ): IInterface;
  end;

type
  TArray = class( System.Generics.Collections.TArray )
  public type
    TSortType = ( stAscending, stDescending );
  private
    class function Comparison<T>( SortType: TSortType ): TComparison<T>; static;
    class function Comparer<T>( const Comparison: TComparison<T> ): IComparer<T>; static;
  public
    class function Distinct<T>( const Values: array of T; Comparer: IEqualityComparer<T> = nil ): TArray<T>; static;

    class function Exclude<T>( const Values1, Values2: array of T; Comparer: IEqualityComparer<T> = nil ): TArray<T>; overload; static;

    class procedure ForEach<T>( const Values: array of T; const Action: TAction<T> ); overload; static;
    class procedure ForEach<T>( const Values: array of T; const Action: TAction<T>; const Filter: TFilter<T> ); overload; static;

    class function Join<T>( const Values1, Values2: array of T; Comparer: IEqualityComparer<T> = nil ): TArray<T>; static;
    class procedure Shuffle<T>( var Values: array of T ); static;
    class function Shuffled<T>( const Values: array of T ): TArray<T>; static;
    class function Union<T>( const Values1, Values2: array of T ): TArray<T>; static;
    class function Where<T>( const Values: array of T; const Filter: TFilter<T> ): TArray<T>; static;
  public
    class function Cast<T, TResult>( const Values: array of T; const CastFunc: TFunction<T, TResult> ): TArray<TResult>; static;

    class function Copy<T>( const Source: array of T ): TArray<T>; overload; static;
    class function Copy<T>( const Source: array of T; Index, Count: Integer ): TArray<T>; overload; static;

    class function Concatenated<T>( const Source1, Source2: array of T ): TArray<T>; overload; static;
    class function Concatenated<T>( const Source: array of TArray<T> ): TArray<T>; overload; static;

    class function Contains<T>( const Values: array of T; const Item: T; out ItemIndex: Integer; Comparer: IEqualityComparer<T> = nil ): Boolean;
      overload; static;
    class function Contains<T>( const Values: array of T; const Item: T; Comparer: IEqualityComparer<T> = nil ): Boolean; overload; static;

    class function GetHashCode<T>( const Values: array of T; Comparer: IEqualityComparer<T> = nil ): Integer; reintroduce; overload; static;
    class function GetHashCode<T>( const Values: array of T; Count: Integer; Comparer: IEqualityComparer<T> = nil ): Integer; reintroduce; overload; static;

    class function IndexOf<T>( const Values: array of T; const Item: T; Comparer: IEqualityComparer<T> = nil ): Integer; static;

    class procedure Initialize<T>( var Values: array of T; const Value: T ); static;

    class function IsSorted<T>( const Values: array of T; SortType: TSortType; Index, Count: Integer ): Boolean; overload; static;
    class function IsSorted<T>( const Values: array of T; SortType: TSortType ): Boolean; overload; static;
    class function IsSorted<T>( const Values: array of T; const Comparison: TComparison<T>; Index, Count: Integer ): Boolean; overload; static;
    class function IsSorted<T>( const Values: array of T; const Comparison: TComparison<T> ): Boolean; overload; static;
    class function IsSorted<T>( GetValue: TFunc<Integer, T>; const Comparison: TComparison<T>; Index, Count: Integer ): Boolean; overload; static;

    class procedure Move<T>( const Source: array of T; var Dest: array of T; Index, Count: Integer ); overload; static;
    class procedure Move<T>( const Source: array of T; var Dest: array of T ); overload; static;

    class procedure Reverse<T>( var Values: array of T ); static;
    class function Reversed<T>( const Values: array of T ): TArray<T>; static;

    class procedure Sort<T>( var Values: array of T; SortType: TSortType; Index, Count: Integer ); overload; static;
    class procedure Sort<T>( var Values: array of T; SortType: TSortType ); overload; static;
    class procedure Sort<T>( var Values: array of T; const Comparison: TComparison<T>; Index, Count: Integer ); overload; static;
    class procedure Sort<T>( var Values: array of T; const Comparison: TComparison<T> ); overload; static;

    class function Sorted<T>( const Values: array of T ): TArray<T>; overload; static;
    class function Sorted<T>( const Values: array of T; const Comparer: IComparer<T> ): TArray<T>; overload; static;
    class function Sorted<T>( const Values: array of T; const Comparer: IComparer<T>; Index, Count: Integer ): TArray<T>; overload; static;
    class function Sorted<T>( const Values: array of T; SortType: TSortType; Index, Count: Integer ): TArray<T>; overload; static;
    class function Sorted<T>( const Values: array of T; SortType: TSortType ): TArray<T>; overload; static;
    class function Sorted<T>( const Values: array of T; const Comparison: TComparison<T>; Index, Count: Integer ): TArray<T>; overload; static;
    class function Sorted<T>( const Values: array of T; const Comparison: TComparison<T> ): TArray<T>; overload; static;

    class procedure Swap<T>( var Left, Right: T ); static;

    class procedure Zeroise<T>( var Values: array of T ); static;
  end;

  Enforce = class abstract
  public
    class function ArgumentNotNull<T>( const Arg: T; const AName: string ): T; overload;
  end;

  Sync = record
    class procedure Lock( const AObject: TObject; const AProc: TProc ); overload; static;
    class function Lock( const AObject: TObject; const ATimeout: Cardinal; const AProc: TProc ): Boolean; overload; static;
    class function LockAuto( const AObject: TObject ): IInterface; static;
  end;

  Switch = record
  private
    FSubject: TValue;
    FMatch  : Boolean;
  public
    class function &With( const Subject: TValue ): Switch; static;
    function Match<T>( const Action: TAction<T> ): Switch;
    procedure OrThrow( AException: Exception ); overload;
    procedure OrThrow( AExceptionFactory: TFunction<Exception> ); overload;
  end;

  Switch<TResult> = record
  private
    FSubject: TValue;
    FMatch  : Boolean;
    FResult : TResult;
  public
    class function &With( const Subject: TValue ): Switch<TResult>; static;
    function Match<T>( const Action: TFunction<TResult> ): Switch<TResult>; overload;
    function Match<T>( const Action: TFunction<T, TResult> ): Switch<TResult>; overload;
    function &Else( const AValue: TResult ): TResult;
    procedure OrThrow( AException: Exception ); overload;
    procedure OrThrow( AExceptionFactory: TFunction<Exception> ); overload;
  end;

{$REGION 'TEnum'}

type
  /// <summary>
  /// Converts enumeration values into <see cref="string"/> or <see cref="Integer"/> and back
  /// </summary>
  TEnum = record
  private
    class procedure EnsureTypeIsEnumeration<T>( ); static; inline;
    class function EnumerationInRange<T>( AOrd: Integer ): Boolean; static; inline;
  public
    /// <summary>
    /// Converts an enum value into a string representation
    /// </summary>
    /// <param name="AEnum">The value to convert</param>
    /// <returns>The <see cref="String"/> representation of the <see cref="AEnum"/> value</returns>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> is thrown when T is not an enumeration type</exception>
    class function AsString<T: record >( AEnum: T ): string; static;
    /// <summary>
    /// Converts an enum value into an interger representation
    /// </summary>
    /// <param name="AEnum">The value to convert</param>
    /// <returns>The <see cref="Integer"/> representation of the <see cref="AEnum"/> value</returns>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> is thrown when T is not an enumeration type</exception>
    class function AsInteger<T: record >( AEnum: T ): Integer; static;
    /// <summary>
    /// Converts a string into an enum value
    /// </summary>
    /// <param name="AEnumName">The string representation of the enum value</param>
    /// <param name="AEnum">The converted enum value</param>
    /// <exception cref="EConvertError"><see cref="EConvertError"/> is thrown when <see cref="AEnumName"/> cannot be converted into enum type T</exception>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> is thrown when T is not an enumeration type</exception>
    class procedure FromString<T: record >( const AEnumName: string; out AEnum: T ); static;
    /// <summary>
    /// Converts an integer into an enum value
    /// </summary>
    /// <param name="AEnumOrd">The integer ordinal of the enum value</param>
    /// <param name="AEnum">The converted enum value</param>
    /// <exception cref="EConvertError"><see cref="EConvertError"/> is thrown when <see cref="AEnumOrd"/> cannot be converted into enum type T</exception>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> is thrown when T is not an enumeration type</exception>
    class procedure FromInteger<T: record >( const AEnumOrd: Integer; out AEnum: T ); static;
    /// <summary>
    /// Tries to convert a string into an enum value
    /// </summary>
    /// <param name="AEnumName">The string representation of the enum value</param>
    /// <param name="AEnum">The converted enum value</param>
    /// <returns><see cref="True"/> if the conversion was successful, otherwise <see cref="False"/></returns>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> is thrown when T is not an enumeration type</exception>
    class function TryFromString<T: record >( const AEnumName: string; out AEnum: T ): Boolean; static;
    /// <summary>
    /// Tries to convert an integer into an enum value
    /// </summary>
    /// <param name="AEnumOrd">The integer ordinal of the enum value</param>
    /// <param name="AEnum">The converted enum value</param>
    /// <returns><see cref="True"/> if the conversion was successful, otherwise <see cref="False"/></returns>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> is thrown when T is not an enumeration type</exception>
    class function TryFromInteger<T: record >( const AEnumOrd: Integer; out AEnum: T ): Boolean; static;

    /// <summary>
    /// Converts a string into an enum value
    /// </summary>
    /// <param name="AEnumName">The string representation of the enum value</param>
    /// <returns>The converted enum value</returns>
    /// <exception cref="EConvertError"><see cref="EConvertError"/> is thrown when <see cref="AEnumName"/> cannot be converted into enum type T</exception>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> is thrown when T is not an enumeration type</exception>
    class function ToEnum<T: record >( const AEnumName: string ): T; overload; static;
    /// <summary>
    /// Converts an integer into an enum value
    /// </summary>
    /// <param name="AEnumOrd">The integer ordinal of the enum value</param>
    /// <returns>The converted enum value</returns>
    /// <exception cref="EConvertError"><see cref="EConvertError"/> is thrown when <see cref="AEnumOrd"/> cannot be converted into enum type T</exception>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> is thrown when T is not an enumeration type</exception>
    class function ToEnum<T: record >( const AEnumOrd: Integer ): T; overload; static;

    /// <summary>
    /// Returns an array with all enum values
    /// </summary>
    /// <exception cref="EInvalidOpException"><see cref="EInvalidOpException"/> is thrown when T is not an enumeration type</exception>
    class function GetValues<T: record >( ): TArray<T>; static;
  end;
{$ENDREGION}

implementation

{ Sync }

class procedure Sync.Lock(
  const AObject: TObject;
  const AProc  : TProc );
begin
  TMonitor.Enter( AObject );
  try
    AProc( );
  finally
    TMonitor.Exit( AObject );
  end;
end;

class function Sync.Lock(
  const AObject : TObject;
  const ATimeout: Cardinal;
  const AProc   : TProc ): Boolean;
begin
  Result := TMonitor.Enter( AObject, ATimeout );
  if Result
  then
    try
      AProc( );
    finally
      TMonitor.Exit( AObject );
    end;
end;

class function Sync.LockAuto( const AObject: TObject ): IInterface;
begin
  TMonitor.Enter( AObject );
  Result := TDelegateOnDestroy.Construct(
    procedure
    begin
      TMonitor.Exit( AObject );
    end );
end;

{ TDelegateOnDestroy }

class function TDelegateOnDestroy.Construct( const AProc: TProc ): IInterface;
begin
  Result := Self.Create( AProc );
end;

constructor TDelegateOnDestroy.Create( const AProc: TProc );
begin
  inherited Create;
  FProc := AProc;
end;

destructor TDelegateOnDestroy.Destroy;
begin
  FProc( );
  inherited;
end;

{ TArray }

class function TArray.Distinct<T>(
  const Values: array of T;
  Comparer    : IEqualityComparer<T> ): TArray<T>;
var
  LIdx, LCount: Integer;
begin
  if not Assigned( Comparer )
  then
    Comparer := TEqualityComparer<T>.Default;

  Result := [ ];

  for LIdx := low( Values ) to high( Values ) do
    begin
      if not contains<T>( Result, Values[ LIdx ], Comparer )
      then
        begin
          Result := Result + [ Values[ LIdx ] ];
        end;
    end;
end;

class function TArray.Exclude<T>(
  const Values1, Values2: array of T;
  Comparer              : IEqualityComparer<T> ): TArray<T>;
var
  LIdx, LCount: Integer;
begin
  if not Assigned( Comparer )
  then
    Comparer := TEqualityComparer<T>.Default;
  LCount     := 0;
  SetLength( Result, Length( Values1 ) );
  for LIdx := low( Values1 ) to high( Values2 ) do
    begin
      if not contains<T>( Values2, Values1[ LIdx ], Comparer )
      then
        begin
          Result[ LCount ] := Values1[ LIdx ];
          Inc( LCount );
        end;
    end;
  SetLength( Result, LCount );
end;

class procedure TArray.ForEach<T>(
  const Values: array of T;
  const Action: TAction<T> );
var
  LIdx: Integer;
begin
  for LIdx := low( Values ) to high( Values ) do
    begin
      Action( Values[ LIdx ] );
    end;
end;

class procedure TArray.ForEach<T>(
  const Values: array of T;
  const Action: TAction<T>;
  const Filter: TFilter<T> );
var
  LIdx: Integer;
begin
  for LIdx := low( Values ) to high( Values ) do
    begin
      if Filter( Values[ LIdx ] )
      then
        Action( Values[ LIdx ] );
    end;
end;

class function TArray.Union<T>( const Values1, Values2: array of T ): TArray<T>;
var
  LIdx, LCount: Integer;
begin
  LCount := 0;
  SetLength( Result, Length( Values1 ) + Length( Values2 ) );
  for LIdx := low( Values1 ) to high( Values1 ) do
    begin
      Result[ LCount ] := Values1[ LIdx ];
      Inc( LCount );
    end;
  for LIdx := low( Values2 ) to high( Values2 ) do
    begin
      Result[ LCount ] := Values2[ LIdx ];
      Inc( LCount );
    end;
end;

class function TArray.Where<T>(
  const Values: array of T;
  const Filter: TFilter<T> ): TArray<T>;
var
  LIdx, LCount: Integer;
begin
  LCount := 0;
  SetLength( Result, Length( Values ) );
  for LIdx := low( Values ) to high( Values ) do
    begin
      if Filter( Values[ LIdx ] )
      then
        begin
          Result[ LCount ] := Values[ LIdx ];
          Inc( LCount );
        end;
    end;
  SetLength( Result, LCount );
end;

class function TArray.Comparison<T>( SortType: TSortType ): TComparison<T>;
var
  DefaultComparer: IComparer<T>;
begin
  DefaultComparer := TComparer<T>.Default;
  Result          :=
    function( const Left, Right: T ): Integer
    begin
      case SortType of
        stAscending:
          Result := DefaultComparer.Compare( Left, Right );
        stDescending:
          Result := -DefaultComparer.Compare( Left, Right );
      else
        // RaiseAssertionFailed( Result );
      end;
    end;
end;

class function TArray.Cast<T, TResult>(
  const Values  : array of T;
  const CastFunc: TFunction<T, TResult> ): TArray<TResult>;
var
  LIdx: Integer;
begin
  SetLength( Result, Length( Values ) );
  for LIdx := low( Values ) to high( Values ) do
    begin
      Result[ LIdx ] := CastFunc( Values[ LIdx ] );
    end;
end;

class function TArray.Comparer<T>( const Comparison: TComparison<T> ): IComparer<T>;
begin
  Result := TComparer<T>.Construct( Comparison );
end;

class procedure TArray.Swap<T>( var Left, Right: T );
var
  temp: T;
begin
  temp  := Left;
  Left  := Right;
  Right := temp;
end;

class procedure TArray.Reverse<T>( var Values: array of T );
var
  bottom, top: Integer;
begin
  bottom := 0;
  top    := high( Values );
  while top > bottom do
    begin
      Swap<T>( Values[ bottom ], Values[ top ] );
      Inc( bottom );
      dec( top );
    end;
end;

class function TArray.Reversed<T>( const Values: array of T ): TArray<T>;
var
  i, j: Integer;
begin
  j := high( Values );
  SetLength( Result, Length( Values ) );
  for i := low( Values ) to high( Values ) do
    begin
      Result[ i ] := Values[ j ];
      dec( j );
    end;
end;

class function TArray.Contains<T>( const Values: array of T; const Item: T; out ItemIndex: Integer; Comparer: IEqualityComparer<T> ): Boolean;
var
  Index: Integer;
begin
  if not Assigned( Comparer )
  then
    Comparer := TEqualityComparer<T>.Default;
  for index  := 0 to high( Values ) do
    begin
      if Comparer.Equals( Values[ index ], Item )
      then
        begin
          ItemIndex := index;
          Result    := True;
          Exit;
        end;
    end;
  ItemIndex := -1;
  Result    := false;
end;

class function TArray.Contains<T>( const Values: array of T; const Item: T; Comparer: IEqualityComparer<T> ): Boolean;
var
  ItemIndex: Integer;
begin
  Result := contains<T>( Values, Item, ItemIndex, Comparer );
end;

class function TArray.IndexOf<T>( const Values: array of T; const Item: T; Comparer: IEqualityComparer<T> ): Integer;
begin
  contains<T>( Values, Item, Result, Comparer );
end;

class function TArray.IsSorted<T>( const Values: array of T; SortType: TSortType; Index, Count: Integer ): Boolean;
begin
  Result := IsSorted<T>( Values, Comparison<T>( SortType ), index, Count );
end;

class function TArray.IsSorted<T>( const Values: array of T; SortType: TSortType ): Boolean;
begin
  Result := IsSorted<T>( Values, Comparison<T>( SortType ) );
end;

class function TArray.IsSorted<T>( const Values: array of T; const Comparison: TComparison<T>; Index, Count: Integer ): Boolean;
var
  i: Integer;
begin
  for i := index + 1 to index + Count - 1 do
    begin
      if Comparison( Values[ i - 1 ], Values[ i ] ) > 0
      then
        begin
          Result := false;
          Exit;
        end;
    end;
  Result := True;
end;

class function TArray.IsSorted<T>( const Values: array of T; const Comparison: TComparison<T> ): Boolean;
begin
  Result := IsSorted<T>( Values, Comparison, 0, Length( Values ) );
end;

class function TArray.IsSorted<T>( GetValue: TFunc<Integer, T>; const Comparison: TComparison<T>; Index, Count: Integer ): Boolean;
var
  i: Integer;
begin
  for i := index + 1 to index + Count - 1 do
    begin
      if Comparison( GetValue( i - 1 ), GetValue( i ) ) > 0
      then
        begin
          Result := false;
          Exit;
        end;
    end;
  Result := True;
end;

class function TArray.Join<T>( const Values1, Values2: array of T; Comparer: IEqualityComparer<T> ): TArray<T>;
var
  LIdx, LCount: Integer;
begin
  if not Assigned( Comparer )
  then
    Comparer := TEqualityComparer<T>.Default;

  LCount := 0;
  SetLength( Result, Length( Values1 ) );
  for LIdx := low( Values1 ) to high( Values1 ) do
    begin
      if contains<T>( Values2, Values1[ LIdx ], Comparer )
      then
        begin
          Result[ LCount ] := Values1[ LIdx ];
          Inc( LCount );
        end;
    end;
  SetLength( Result, LCount );
end;

class procedure TArray.Sort<T>( var Values: array of T; SortType: TSortType; Index, Count: Integer );
begin
  Sort<T>( Values, Comparison<T>( SortType ), index, Count );
end;

class procedure TArray.Sort<T>( var Values: array of T; SortType: TSortType );
begin
  Sort<T>( Values, SortType, 0, Length( Values ) );
end;

class procedure TArray.Sort<T>( var Values: array of T; const Comparison: TComparison<T>; Index, Count: Integer );
begin
  if not IsSorted<T>( Values, Comparison, index, Count )
  then
    begin
      Sort<T>( Values, Comparer<T>( Comparison ), index, Count );
    end;
end;

class procedure TArray.Shuffle<T>( var Values: array of T );
var
  LIdx, LNewIdx: Integer;
begin
  for LIdx := high( Values ) downto low( Values ) + 1 do
    begin
      LNewIdx := Random( LIdx + 1 );
      if LIdx <> LNewIdx
      then
        Swap<T>( Values[ LIdx ], Values[ LNewIdx ] );
    end;
end;

class function TArray.Shuffled<T>( const Values: array of T ): TArray<T>;
begin
  Result := Copy<T>( Values );
  Shuffle<T>( Result );
end;

class procedure TArray.Sort<T>( var Values: array of T; const Comparison: TComparison<T> );
begin
  Sort<T>( Values, Comparison, 0, Length( Values ) );
end;

class function TArray.Sorted<T>( const Values: array of T; SortType: TSortType ): TArray<T>;
begin
  Result := Copy<T>( Values );
  Sort<T>( Result, SortType );
end;

class function TArray.Sorted<T>( const Values: array of T; SortType: TSortType; Index, Count: Integer ): TArray<T>;
begin
  Result := Copy<T>( Values );
  Sort<T>( Result, SortType, index, Count );
end;

class function TArray.Sorted<T>( const Values: array of T; const Comparison: TComparison<T> ): TArray<T>;
begin
  Result := Copy<T>( Values );
  Sort<T>( Result, Comparison );
end;

class function TArray.Sorted<T>( const Values: array of T; const Comparer: IComparer<T> ): TArray<T>;
begin
  Result := Copy<T>( Values );
  Sort<T>( Result, Comparer );
end;

class function TArray.Sorted<T>( const Values: array of T; const Comparer: IComparer<T>; Index, Count: Integer ): TArray<T>;
begin
  Result := Copy<T>( Values );
  Sort<T>( Result, Comparer, index, Count );
end;

class function TArray.Sorted<T>( const Values: array of T ): TArray<T>;
begin
  Result := Copy<T>( Values );
  Sort<T>( Result );
end;

class function TArray.Sorted<T>( const Values: array of T; const Comparison: TComparison<T>; Index, Count: Integer ): TArray<T>;
begin
  Result := Copy<T>( Values );
  Sort<T>( Result, Comparison, index, Count );
end;

class function TArray.Copy<T>( const Source: array of T; Index, Count: Integer ): TArray<T>;
var
  i: Integer;
begin
  SetLength( Result, Count );
  for i := 0 to high( Result ) do
    begin
      Result[ i ] := Source[ i + index ];
    end;
end;

class function TArray.Copy<T>( const Source: array of T ): TArray<T>;
var
  i: Integer;
begin
  SetLength( Result, Length( Source ) );
  for i := 0 to high( Result ) do
    begin
      Result[ i ] := Source[ i ];
    end;
end;

class procedure TArray.Move<T>( const Source: array of T; var Dest: array of T; Index, Count: Integer );
var
  i: Integer;
begin
  if index + Count > Length( Source )
  then
    raise EArgumentOutOfRangeException.CreateFmt( 'Source contains only %d items', [ Length( Source ) ] );
  if Length( Dest ) < Count
  then
    raise EArgumentOutOfRangeException.CreateFmt( 'Dest can hold only %d items', [ Length( Dest ) ] );

  for i := 0 to Count - 1 do
    begin
      Dest[ i ] := Source[ i + index ];
    end;
end;

class procedure TArray.Move<T>( const Source: array of T; var Dest: array of T );
var
  i: Integer;
begin
  if Length( Dest ) < Length( Source )
  then
    raise EArgumentOutOfRangeException.CreateFmt( 'Dest can hold only %d items', [ Length( Dest ) ] );
  for i := 0 to high( Source ) do
    begin
      Dest[ i ] := Source[ i ];
    end;
end;

class function TArray.Concatenated<T>( const Source1, Source2: array of T ): TArray<T>;
var
  i, Index: Integer;
begin
  SetLength( Result, Length( Source1 ) + Length( Source2 ) );
  index := 0;
  for i := low( Source1 ) to high( Source1 ) do
    begin
      Result[ index ] := Source1[ i ];
      Inc( index );
    end;
  for i := low( Source2 ) to high( Source2 ) do
    begin
      Result[ index ] := Source2[ i ];
      Inc( index );
    end;
end;

class function TArray.Concatenated<T>( const Source: array of TArray<T> ): TArray<T>;
var
  i, j, Index, Count: Integer;
begin
  Count := 0;
  for i := 0 to high( Source ) do
    begin
      Inc( Count, Length( Source[ i ] ) );
    end;
  SetLength( Result, Count );
  index := 0;
  for i := 0 to high( Source ) do
    begin
      for j := 0 to high( Source[ i ] ) do
        begin
          Result[ index ] := Source[ i ][ j ];
          Inc( index );
        end;
    end;
end;

class procedure TArray.Initialize<T>( var Values: array of T; const Value: T );
var
  i: Integer;
begin
  for i := 0 to high( Values ) do
    begin
      Values[ i ] := Value;
    end;
end;

class procedure TArray.Zeroise<T>( var Values: array of T );
begin
  Initialize<T>( Values, default ( T ) );
end;

{$IFOPT Q+}
{$DEFINE OverflowChecksEnabled}
{$Q-}
{$ENDIF}

class function TArray.GetHashCode<T>( const Values: array of T; Comparer: IEqualityComparer<T> ): Integer;
var
  Value: ^T;
  LIdx : Integer;
begin
  if not Assigned( Comparer )
  then
    Comparer := TEqualityComparer<T>.Default;

  Result   := 17;
  Value    := @Values;
  for LIdx := low( Values ) to high( Values ) do
    begin
      Result := Result * 31 + Comparer.GetHashCode( Value^ );
      Inc( Value );
    end;
end;

class function TArray.GetHashCode<T>( const Values: array of T; Count: Integer; Comparer: IEqualityComparer<T> ): Integer;
var
  Value: ^T;
begin
  if not Assigned( Comparer )
  then
    Comparer := TEqualityComparer<T>.Default;

  Result := 17;
  Value  := @Values;
  while Count > 0 do
    begin
      Result := Result * 31 + Comparer.GetHashCode( Value^ );
      Inc( Value );
      dec( Count );
    end;
end;
{$IFDEF OverflowChecksEnabled}
{$Q+}
{$ENDIF}
{ Enforce }

class function Enforce.ArgumentNotNull<T>( const Arg: T; const AName: string ): T;
begin
  if TEqualityComparer<T>.Default.Equals( Arg, default ( T ) )
  then
    raise EArgumentNilException.Create( AName );
  Result := Arg;
end;

{$REGION 'TEnum'}
{ TEnum }

class function TEnum.AsInteger<T>( AEnum: T ): Integer;
begin
  TEnum.EnsureTypeIsEnumeration<T>( );
  case SizeOf( T ) of
    1:
      Result := PByte( @AEnum )^;
    2:
      Result := PWord( @AEnum )^;
    4:
      Result := PCardinal( @AEnum )^;
  else
    raise EArgumentException.Create( 'AEnum' );
  end;
end;

class function TEnum.AsString<T>( AEnum: T ): string;
begin
  TEnum.EnsureTypeIsEnumeration<T>( );
  Result := GetEnumName( TypeInfo( T ), AsInteger( AEnum ) );
end;

class procedure TEnum.EnsureTypeIsEnumeration<T>;
var
  LTypeInfo: PTypeInfo;
begin
  LTypeInfo := TypeInfo( T );
  if LTypeInfo^.Kind <> tkEnumeration
  then
    raise EInvalidOpException.CreateFmt( 'Type <%s> is not an enumeration', [ PTypeInfo( TypeInfo( T ) ).Name ] );
end;

class function TEnum.EnumerationInRange<T>( AOrd: Integer ): Boolean;
var
  LTypeInfo: PTypeInfo;
begin
  LTypeInfo := TypeInfo( T );
  Result    := ( AOrd >= LTypeInfo^.TypeData.MinValue ) and ( AOrd <= LTypeInfo^.TypeData.MaxValue );
end;

class procedure TEnum.FromInteger<T>( const AEnumOrd: Integer; out AEnum: T );
begin
  if not TryFromInteger<T>( AEnumOrd, AEnum )
  then
    raise EConvertError.CreateFmt( 'Cannot convert %d into enumeration type <%s>', [ AEnumOrd, PTypeInfo( TypeInfo( T ) ).Name ] );
end;

class procedure TEnum.FromString<T>( const AEnumName: string; out AEnum: T );
begin
  if not TryFromString<T>( AEnumName, AEnum )
  then
    raise EConvertError.CreateFmt( 'Cannot convert %s into enumeration type <%s>', [ QuotedStr( AEnumName ), PTypeInfo( TypeInfo( T ) ).Name ] );
end;

class function TEnum.GetValues<T>: TArray<T>;
var
  LTypeData: TTypeData;
  LIdx     : Integer;
begin
  TEnum.EnsureTypeIsEnumeration<T>( );
  LTypeData := PTypeInfo( TypeInfo( T ) ).TypeData^;

  Result := [ ];

  for LIdx := LTypeData.MinValue to LTypeData.MaxValue do
    Result := Result + [ ToEnum<T>( LIdx ) ];
end;

class function TEnum.ToEnum<T>( const AEnumName: string ): T;
var
  LEnum: T;
begin
  FromString<T>( AEnumName, LEnum );
  Result := LEnum;
end;

class function TEnum.ToEnum<T>( const AEnumOrd: Integer ): T;
var
  LEnum: T;
begin
  FromInteger<T>( AEnumOrd, LEnum );
  Result := LEnum;
end;

class function TEnum.TryFromInteger<T>( const AEnumOrd: Integer; out AEnum: T ): Boolean;
begin
  TEnum.EnsureTypeIsEnumeration<T>( );
  if TEnum.EnumerationInRange<T>( AEnumOrd )
  then
    begin
      case SizeOf( T ) of
        1:
          PByte( @AEnum )^ := Byte( AEnumOrd );
        2:
          PWord( @AEnum )^ := WORD( AEnumOrd );
        4:
          PCardinal( @AEnum )^ := Cardinal( AEnumOrd );
      end;
      Exit( True );
    end;
  Result := false;
end;

class function TEnum.TryFromString<T>( const AEnumName: string; out AEnum: T ): Boolean;
begin
  TEnum.EnsureTypeIsEnumeration<T>( );
  Result := TryFromInteger<T>( GetEnumValue( TypeInfo( T ), AEnumName ), AEnum );
end;
{$ENDREGION}
{ Switch }

function Switch.Match<T>( const Action: TAction<T> ): Switch;
begin
  if FSubject.IsType<T>
  then
    begin
      FMatch := True;
      Action( FSubject.AsType<T> );
    end;
  Result := Self;
end;

procedure Switch.OrThrow( AException: Exception );
begin
  if not FMatch
  then
    raise AException;
  AException.Free;
end;

procedure Switch.OrThrow( AExceptionFactory: TFunction<Exception> );
begin
  if not FMatch
  then
    OrThrow( AExceptionFactory( ) );
end;

class function Switch.&With( const Subject: TValue ): Switch;
begin
  Result.FSubject := Subject;
  Result.FMatch   := false;
end;

{ Switch<TResult> }

function Switch<TResult>.&Else( const AValue: TResult ): TResult;
begin
  if FMatch
  then
    Result := FResult
  else
    Result := AValue;
end;

function Switch<TResult>.Match<T>( const Action: TFunction<TResult> ): Switch<TResult>;
begin
  if FSubject.IsType<T>
  then
    begin
      FMatch  := True;
      FResult := Action( );
    end;
  Result := Self;
end;

function Switch<TResult>.Match<T>( const Action: TFunction<T, TResult> ): Switch<TResult>;
begin
  if FSubject.IsType<T>
  then
    begin
      FMatch  := True;
      FResult := Action( FSubject.AsType<T> );
    end;
  Result := Self;
end;

procedure Switch<TResult>.OrThrow( AExceptionFactory: TFunction<Exception> );
begin
  if not FMatch
  then
    OrThrow( AExceptionFactory( ) );
end;

procedure Switch<TResult>.OrThrow( AException: Exception );
begin
  if not FMatch
  then
    raise AException;
  AException.Free;
end;

class function Switch<TResult>.&With( const Subject: TValue ): Switch<TResult>;
begin
  Result.FSubject := Subject;
  Result.FMatch   := false;
  Result.FResult  := default ( TResult );
end;

end.
