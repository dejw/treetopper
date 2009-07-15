TreeTopper
==========

TreeTopper is a simple grammar converter from slightly modified EBNF to [TreeTop][] format. It simply rewrite the input to meet the .treetop file format.

_Note: It does not validate the input, it only helps to write TreeTop grammars faster and simpler._

Grammar syntax
--------------

Grammars accepted by TreeTopper are very similar to EBNF grammars. For now in grammars You can use only comments and rule definitions (this will change in the future).

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

As a library
------------

TreeTopper can be used also as a library. It redefines some standard classes, adding a piece of code for easier work with grammar parser. I

Features to implement / Ideas
-----------------------------

There are a lot things to do and some of them are listed below:

* __Define whole TreeTop syntax as a pure Ruby code__ (as a patch to TreeTop maybe?).
* Some command line options.
* Special directives which can extend grammar functionality:
  * Grammar name change.
  * Aliases (for long named rules).
  * Inlining (for short productions).
  * Including (handle feature of TreeTop).
* Removal of similar productions (?)
* Simple left recursion prevention.
* Write it using TreeTop itself.
* Validate the input. (?)


[TreeTop]: http://github.com/nathansobo/treetop
[TreeTop Home Page]: http://treetop.rubyforge.org/index.html
