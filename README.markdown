TreeTopper
==========

TreeTopper is a simple grammar converter from slightly modified EBNF to [TreeTop][] format. It simply rewrite the input to meet the .treetop file format.

_Note: It does not validate the input, it only helps to write TreeTop grammars faster and simpler._

Grammar syntax
--------------

Grammars accepted by TreeTopper are very similar to EBNF grammars. For now in grammars You can use comments, rule definitions and some special commands.

Comments are lines that starts with # character and these lines are skipped. TreeTopper handles only full-line comments, thus input like:

    # This is a comment.
    rule_definition # This is not a comment.

will cause an error.

Rule definition (formally a _production rule_) is a line which starts with non-terminal followed by `->` and a list of sequences, delimited by `|`. Sequence stands for an expression formed along `.treetop` format syntax rules so it is in fact a piece of TreeTop input, which will be inserted into the output. Non-terminal at the begining is the rule name, and it can be used in sequences in whole grammar.

Simple example of grammar is listed below:

    # Arithmetic grammar.
    additive -> multitive '+' additive | multitive
    multitive -> primary '*' multitive | primary
    primary -> '(' additive ')' | number
    number -> [1-9] [0-9]*

It is borrowed strictly from [TreeTop Home Page][] and TreeTopper generates output similar to one listed there.

Special commands
------------------

A command is a line which starts with `:`. Arguments are separated by a space. First argument is a command name. For now two special commands are allowed. 

### `:grammar name`
Changes the grammar name, especially useful in in-line Ruby grammars.

### `:alias rule name`
Changes the name of rule in the grammar, especially useful for long-named rules.

With commands listed above, mentioned _arithmetic grammar_ can be rewritten as follows:

    # Arithmetic grammar.
    :grammar Arithmetic
    :alias E additive
    :alias T multitive
    :alias F prime
    :alias N number
    E ->  T '+' E  | T
    T ->  F '*' T  | F
    F -> '(' E ')' | N
    N -> [1-9] [0-9]*

Usage
-----
`tott` tool converts a list of files from EBNF grammar format to Treetop format.

    $ tott file [, file ...] [options]
    Converts list of files from EBNF grammar format to Treetop format.

    Available options are:
      --nott    Deletes .treetop files after conversion. (Useful with --rb option)
      --ruby    Converts generated .treetop files into Ruby source using tt.
      --out     Prints the output to the standard output rather than a file.
      --help    Prints this help message.


[TreeTop]: http://github.com/nathansobo/treetop
[TreeTop Home Page]: http://treetop.rubyforge.org/index.html
