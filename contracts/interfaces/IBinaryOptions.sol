pragma solidity >=0.6.0 <0.8.0;

interface IBinaryOptions {
    function getPositive() external view returns (uint256);

    function getNegative() external view returns (uint256);

    function getTotal() external view returns (uint256);

    function getContractBalance() external view returns (uint256);

    function getContractExpiry() external view returns (uint256);

    function getCriteria() external view returns (uint256);

    function getBidPeriodLimit() external view returns (uint256);
}
