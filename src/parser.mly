/* Parser for BURGer Programming Language
 * PLT Fall 2017
 * Authors:
 * Jacqueline Kong
 * Jordan Lee
 * Adrian Traviezo
 * Ashley Nguyen */

%{ open Ast %}

%token <string> ID
%token <string> STRING
%token LPAREN RPAREN SEMI LBRACE RBRACE LBRACK RBRACK COMMA
%token PLUS MINUS TIMES DIVIDE ASSIGN /* TODO: fix this precedence later in CFG */
%token EQ NEQ LEQ GEQ
%token AND OR NOT
%token IF ELSE
%token TRUE FALSE
%token INT FLOAT CHAR STRING BOOL VOID
%token FOR WHILE DEF
%token EOF

%start program
%type <Ast.program> program

%%

program:
  item_list EOF { $1 }

item_list:
    /* nothing */  { [] }
  | item_list item { ($2 :: $1) }

item:
    stmt          { Stmt($1) }
  | vdecl         { VDecl($1) }
  | fdecl         { Function($1) }

typ:
    INT    { Int }
  | FLOAT  { Float }
  | BOOL   { Bool }
  | CHAR   { Char }
  | STRING { String }
  | VOID   { Void }

stmt:
  expr SEMI { Expr $1 }

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { ($2 :: $1) }

expr:
    ID LPAREN actuals_opt RPAREN { Call($1, $3) }
  | LPAREN expr RPAREN           { $2 }
  | STRING                       { StringLit($1) }

vdecl:
  typ ID SEMI { ($1, $2) }

fdecl:
  typ ID LPAREN formals_opt RPAREN LBRACE stmt_list RBRACE
    { { typ = $1;
        fname = $2;
        formals = $4;
        locals = ;
        body = $7;
      } } /* TODO: need to re-evaluate fdecl for BURGer */

formals_opt:
    /* nothing */ { [] }
  | formal_list   { List.rev $1 }

formal_list:
    typ ID                   { [($1,$2)] }
  | formal_list COMMA typ ID { ($3,$4) :: $1 }

actuals_opt:
    /* nothing */ { [] }
  | actuals_list  { List.rev $1 }

actuals_list:
    expr                    { [$1] }
  | actuals_list COMMA expr { $3 :: $1 }

/*num: ID { Id($1) }
  | constant {}*/

/*cast_expr: char LPAREN num RPAREN {}
  | int LPAREN num RPAREN {}
  | float LPAREN num RPAREN {}*/

/*actual:
        { [] }
  | expr { [] } /* TODO: fill in action */
