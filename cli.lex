#---------------------------------------------
$CONF | NAME       | OptionBabyEngine
$CONF | PROMPT     | >>

#---------------------------------------------
$TOK | WORD       | \w+   | Do pretty things to baby
$TOK | FG_COLOR   | 38;5;([0-9]{1,3})[;m]  | get fg
$TOK | BG_COLOR   | 48;5;([0-9]{1,3})[;m]  | get bg