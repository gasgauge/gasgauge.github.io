//pragma solidity 0.5.16;
pragma solidity >=0.5 <0.7.17;

interface ICurveDepositPBTC {
    function add_liquidity(uint256[4] calldata call_data_amounts, uint256 min_mint_amount) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 _min_amount
    ) external returns (uint256);

    function token() external returns (address);
}
