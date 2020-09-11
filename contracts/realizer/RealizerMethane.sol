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
    mapping(address => uint256) public flam;
    mapping(address => uint256) public real;

    constructor (address _token) public ERC20(
        string(abi.encodePacked("realized ", ERC20(Vault(_token).token()).name())),
        string(abi.encodePacked("real", ERC20(Vault(_token).token()).symbol()))
    ) {
        _setupDecimals(ERC20(_token).decimals());
        token = IERC20(_token);
    }
    function GetMaximumRealToken(address _addr) public view returns (uint) {
        return flam[_addr].mul(Vault(address(token)).getPricePerFullShare()).div(1e18);
    }
    function DepositFlamToken(uint _amount) public {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        flam[msg.sender] = flam[msg.sender].add(_amount);
    }
    function WithdrawFlamToken(uint _amount) public {
        flam[msg.sender] = flam[msg.sender].sub(_amount);
        require(real[msg.sender] <= GetMaximumRealToken(msg.sender));
        token.safeTransfer(msg.sender, _amount);
    }
    function MintRealToken(uint _amount) public {
        real[msg.sender] = real[msg.sender].add(_amount);
        require(real[msg.sender] <= GetMaximumRealToken(msg.sender));
        _mint(msg.sender, _amount);
    }
    function BurnRealToken(uint _amount) public {
        _burn(msg.sender, _amount);
    }
    function RealizeFLAMToken(uint _d, uint _m) external {
        DepositFlamToken(_d);
        MintRealToken(_m);
    }
    function UnrealizeFLAMToken(uint _w, uint _b) external {
        BurnRealToken(_b);
        WithdrawFlamToken(_w);
    }
}
