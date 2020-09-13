// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/GSN/Context.sol";

import "../../interfaces/flamincome/Vault.sol";

contract RealizerMethane is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IERC20 public token;
    mapping(address => uint256) public f;
    mapping(address => uint256) public n;

    constructor (address _token) public ERC20(
        string(abi.encodePacked("flamincome-normalized ", ERC20(Vault(_token).token()).name())),
        string(abi.encodePacked("n", ERC20(Vault(_token).token()).symbol()))
    ) {
        _setupDecimals(ERC20(_token).decimals());
        token = IERC20(_token);
    }
    function GetMaximumNToken(address _addr) public view returns (uint) {
        return f[_addr].mul(Vault(address(token)).priceE18()).div(1e18);
    }
    function DepositFToken(uint _amount) public {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        f[msg.sender] = f[msg.sender].add(_amount);
    }
    function WithdrawFToken(uint _amount) public {
        f[msg.sender] = f[msg.sender].sub(_amount);
        require(n[msg.sender] <= GetMaximumNToken(msg.sender));
        token.safeTransfer(msg.sender, _amount);
    }
    function MintNToken(uint _amount) public {
        n[msg.sender] = n[msg.sender].add(_amount);
        require(n[msg.sender] <= GetMaximumNToken(msg.sender));
        _mint(msg.sender, _amount);
    }
    function BurnNToken(uint _amount) public {
        n[msg.sender] = n[msg.sender].sub(_amount);
        _burn(msg.sender, _amount);
    }
    function RealizeFToken(uint _d, uint _m) external {
        DepositFToken(_d);
        MintNToken(_m);
    }
    function UnrealizeFToken(uint _w, uint _b) external {
        BurnNToken(_b);
        WithdrawFToken(_w);
    }
}
