contract C {
    function f() public {
        var implicitUint8 = 0;
        uint8 explicitUint8 = 0;
        var implicitUint16 = 256;
        uint16 explicitUint16 = 256;

        var implicitType = uint[];

        uint[][][] memory uintArr;

        (uint tuplea1, uint tuplea2) = (1, 2);

        (uint tupleb1, , uint tupleb3) = (1, 2, 3);

        (, , , , , uint tuplec6) = (1, 2, 3, 4, 5, 6);

        address ternaryInit = msg.sender.balance > 0 ? msg.sender : block.coinbase;

        uint overwritten;
        uint overwritten1 = overwritten = 10;
    }
}