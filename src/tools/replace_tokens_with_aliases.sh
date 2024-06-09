#!/bin/bash

# replace_tokens_with_aliases.sh

# replaces each token symbol in bison grammar .y file with easier to read string alias

awk '

# map each token to alias

/^%token/ && NF >= 3 {
  if($2 ~ /^</) {
# token with type has alias in $4
# %token <string> NAME
    if(NF == 4) {
      aliases[$3] = $4
    }
  } else {
# untyped token alias is $3
# %token AND "&"
    if(NF == 3) {
      aliases[$2] = $3
    }
  }
  print
  next
}

# track rules section to restrict changes to

/^%%/ {
  if(in_rules) {
    in_rules = 0
  } else {
    in_rules = 1
  }
}

# change any field that is a token to its string alias
# tokens are allcaps so slight optimization to not bother with lines without allcaps symbols

in_rules && /\<[A-Z_]+\>/ {
  for(i = 1; i <= NF; ++i) {
    if($i in aliases) {
      $i = aliases[$i]
    }
  }
}

# print all lines
{
  print
}

'
