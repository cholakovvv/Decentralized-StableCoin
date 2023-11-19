// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

pragma solidity 0.8.20;

import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC20Burnable} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/*
 * @title DSC
 * @author Simeon Cholakov
 * Collateral: Exogenous
 * Minting (Stability Mechanism): Decentralized (Algorithmic)
 * Value (Relative Stability): Anchored (Pegged to USD)
 * Collateral Type: Crypto
 *
 * This is the contract meant to be owned by DSCEngine. It is a ERC20 token that can be minted and burned by the DSCEngine smart contract.
 */
 
contract DSC is ERC20, ERC20Burnable, Ownable {
    using SafeERC20 for IERC20;
    
    error DSC__MustBeGreaterThanZero();
    error DSC__BurnedAmountExceedsBalance();
    error DSC__AddressZero();
    error DecentralizedStableCoin__BlockFunction();

   constructor(string memory name_, string memory symbol_, address initialOwner)
        ERC20(name_, symbol_)
        Ownable(initialOwner)
    {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        
        if(_amount <= 0) {
            revert DSC__MustBeGreaterThanZero();
        }
        if(balance < _amount) {
            revert DSC__BurnedAmountExceedsBalance();
        }

        super.burn(_amount);
    }

    //The burnFrom function is blocked, because anyone can burn DSC tokens with burnFrom function inherited of OZ ERC20Burnable contract
    function burnFrom(address, uint256) public pure override {
        revert DecentralizedStableCoin__BlockFunction();
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns(bool) {
        if(_to == address(0)){
            revert DSC__AddressZero();
        }
         if(_amount <= 0) {
            revert DSC__MustBeGreaterThanZero();
        }

        _mint(_to, _amount);
        
        return true;
    }
}