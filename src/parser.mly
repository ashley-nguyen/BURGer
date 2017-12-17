/* Parser for BURGer Programming Language
 * PLT Fall 2017
 * Authors:
 * Jacqueline Kong
 * Jordan Lee
 * Adrian Traviezo
 * Ashley Nguyen */

%{ open Ast %}

%token <string> ID
%token <string> STRINGLIT
%token <int> INTLIT
%token <bool> BOOLLIT
%token LPAREN RPAREN SEMI LBRACE RBRACE LBRACK RBRACK COMMA
%token PLUS MINUS TIMES DIVIDE ASSIGN NEG
%token EQ NEQ LEQ GEQ LT GT
%token AND OR NOT
%token IF ELSE
%token TRUE FALSE
%token INT CHAR STRING BOOL NULL
%token FOR WHILE DEF RETURN
%token EOF

%nonassoc NOELSE

%start program
%type <Ast.program> program

%%

/*** Top Level ***/

program:
   item_list EOF { List.rev $1 }

item_list:
   /*nothing */ { [] }
  | item_list item { ($2 :: $1) }

item:
    stmt      { Stmt($1) }
  | fdecl     { Function($1) }

typ:
    INT    { Int }
  | BOOL   { Bool }
  | CHAR   { Char }
  | STRING { String }
  | NULL   { Null }

/*** Statements ***/

stmt:
    expr SEMI        { Expr($1) }
  | vdecl SEMI       { VDecl($1) }
  | RETURN expr SEMI { Return($2) }
  | RETURN SEMI      { Return(NoExpr)}
  | LBRACE stmt_list RBRACE { Block(List.rev $2) }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
  /*| FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
     { For($3, $5, $7, $9) }*/
  | WHILE LPAREN expr RPAREN stmt { While($3, $5) }

stmt_list:
    stmt { [$1] }
  | stmt_list stmt { ($2 :: $1) }

/*** Expressions ***/

expr:
    arith_expr                   { $1 }
  | NEG arith_expr               { Unop(Neg, $2) }
  | bool_expr                    { $1 }
  | NOT bool_expr                { Unop(Not, $2) }
  | ID ASSIGN expr               { Assign($1, $3) }

/*** Boolean Expressions ***/

bool_expr:
    bool_expr  AND   bool_term { Binop($1, And,   $3) }
  | bool_expr  OR    bool_term { Binop($1, Or,    $3) }
  | bool_term                  { $1 }

bool_term:
    bool_lit                      { $1 }
  | arith_expr bool_op arith_expr { Binop($1, $2, $3) }

bool_op:
    EQ    { Equal }
  | NEQ   { Neq }
  | LT    { Less }
  | LEQ   { Leq }
  | GT    { Greater }
  | GEQ   { Geq }

bool_lit:
    TRUE  { BoolLit(true) }
  | FALSE { BoolLit(false) }

/*** Arithmetic Expressions ***/

arith_expr:
    arith_term                   { $1 }
  | arith_expr PLUS  arith_term  { Binop($1, Add, $3) }
  | arith_expr MINUS arith_term  { Binop($1, Sub, $3) }

arith_term:
    atom                     { $1 }
  | arith_term TIMES  atom   { Binop($1, Mult, $3) }
  | arith_term DIVIDE atom   { Binop($1, Div, $3) }

atom:
    INTLIT                       { IntLit($1) }
  | ID                           { Id($1) }
  | STRINGLIT                    { StringLit($1) }
  | LPAREN expr RPAREN           { $2 }
  | ID LPAREN actuals_opt RPAREN { Call($1, $3) }
  /* | LBRACK atom_list RBRACK      { [] } */

/*** Lists ***/
/* atom_list:
    atom COMMA atom { [] }
  | atom_list COMMA atom { [] } */

/*** Variable Declarations ***/

vdecl:
  typ ID { ($1, $2) }
 /*| typ assign_expr { $1, $2 }*/

/*** Function Declarations ***/

fdecl:
  DEF typ ID LPAREN formals_opt RPAREN LBRACE stmt_list RBRACE
    { { typ = $2;
        fname = $3;
        formals = $5;
        body = List.rev $8;
      } }

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
