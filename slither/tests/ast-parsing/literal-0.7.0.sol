contract C {
    function f() public {
        true;
        false;

        123;
        123.456;
        123.456e7;
        123.456e0;
        123.456e-7;
        1_2_3;
        0xabc;
        0xa_b_c;

        1 wei;
        1 ether;
        1 seconds;
        1 minutes;
        1 hours;
        1 days;
        1 weeks;

        hex"abcd";
        hex'abcd' hex"abab";

        "abc";
        'def';

        unicode"💩";
    }
}