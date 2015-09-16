program TextParser;

{$APPTYPE CONSOLE}
{$R *.res}
{******************************************************************************
 Parse a string and filter all parts in round brackets.

 Brackets can be escaped with the backslash.
 ******************************************************************************}

uses
  System.SysUtils,
  Stateless;

type
  TParseState   = ( Start, Escaped, ProcessString, StartString, InString, EscapedInString, Finished, Error );
  TParseTrigger = ( ParseChar, ParseFinish );
  TParseSM      = TStateMachine<TParseState, TParseTrigger>;

  EParseStringException = class( Exception );

function ParseString( const InputString: string ): string;
const
  EscapeChar   = '\';
  OpenBracket  = '(';
  CloseBracket = ')';
var
  LParse       : TParseSM;
  LParseChar   : TParseSM.TTriggerWithParameters<Char>;
  LIdx         : Integer;
  LOutputString: string;
begin
  LParse := TParseSM.Create( TParseState.Start );
  try
{$REGION 'Configuration'}
    LParseChar := LParse.SetTriggerParameters<Char>( TParseTrigger.ParseChar );

    LParse.Configure( TParseState.Start )
    {} .Permit( TParseTrigger.ParseFinish, TParseState.Finished )
    {} .PermitDynamic<Char>( LParseChar,
      function( const c: Char ): TParseState
      begin
        case c of
          EscapeChar:
            Result := TParseState.Escaped;
          CloseBracket:
            Result := TParseState.Error;
          OpenBracket:
            Result := TParseState.StartString;
        else
          Result := TParseState.Start;
        end;
      end );

    LParse.Configure( TParseState.Escaped )
    {} .Permit( LParseChar.Trigger, TParseState.Start );

    LParse.Configure( TParseState.ProcessString )
    {} .PermitDynamic<Char>( LParseChar,
      function( const c: Char ): TParseState
      begin
        case c of
          EscapeChar:
            Result := TParseState.EscapedInString;
          CloseBracket:
            Result := TParseState.Start;
        else
          Result := TParseState.InString;
        end;
      end );

    LParse.Configure( TParseState.StartString )
    {} .SubstateOf( TParseState.ProcessString );

    LParse.Configure( TParseState.InString )
    {} .SubstateOf( TParseState.ProcessString )
    {} .OnEntryFrom<Char>( LParseChar,
      procedure( const c: Char )
      begin
        LOutputString := LOutputString + c;
      end );

    LParse.Configure( TParseState.EscapedInString )
    {} .PermitDynamic<Char>( LParseChar,
      function( const c: Char ): TParseState
      begin
        case c of
          OpenBracket, CloseBracket:
            Result := TParseState.InString
        else
          Result := TParseState.Error;
        end;
      end );
{$ENDREGION}
    LOutputString := '';
    LIdx          := low( InputString );
    while LIdx <= high( InputString ) do
      begin
        LParse.Fire<Char>( LParseChar, InputString[ LIdx ] );
        if LParse.IsInState( TParseState.Error )
        then
          raise EParseStringException.CreateFmt( '%s cannot be parsed. Error at position %d.', [ QuotedStr( InputString ), LIdx ] );
        Inc( LIdx );
      end;
    LParse.Fire( TParseTrigger.ParseFinish );

    Result := LOutputString;

  finally
    LParse.Free;
  end;
end;

procedure Main;
begin
  Writeln( ParseString( '(This is ) only (a \(simple\) ) example (text)' ) );
end;

begin
  try
    Main;
  except
    on E: Exception do
      Writeln( E.ClassName, ': ', E.Message );
  end;
  ReadLn;

end.
