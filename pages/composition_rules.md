# Composition Rules

Below is a brief recap of the rules for forming proper Roman numerals: these are the rules followed by the code when the `:strict` option is `true`.

## Values

The numerical values of numerals is as follows:

    I 1
    V 5
    X 10
    L 50
    C 100
    D 500
    M 1000

Any other letters are not valid numerals.

## Repetition

### In General

A given numeral can be repeated up to 3 times and the resulting value will be the sum of the individual numbers: II equals 2, XXX equals 30, but XXXX is incorrect.

### V, L, D

Numerals whose first digit is 5 (i.e. numerals for 5, 50, 500) cannot be repeated: VIV is not a valid numeral, for example.

## Combinations

### Additive Combinations

Smaller numerals can be placed after larger ones to form a combination whose value will be the sum of the numerals within the group: VI is 6, for example.

### Subtractive Combinations

A smaller numeral can be placed before a larger one if *all* the following conditions are met:

* the smaller numeral is I, X, or C: VC is not a valid representation of 95;
* the smaller numeral's value is at least 1/10 that of the larger: IX is not a valid representation of 99 (which would be represented as XCIX);
* any numeral group to the right has a value smaller than that of the smaller numeral: XIX is a valid numeral, but XCL is not (since X is being subtracted and the value of L is greater than X).

## Ordered Values

When evaluating numerals from left to right, the value should never increase. When evaluating the sequence of values, subtractive combinations are considered as a single numeral. This means that XIX is acceptable but XIM and IIV are not.
