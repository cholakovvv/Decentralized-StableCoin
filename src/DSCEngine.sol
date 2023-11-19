// SPDX  License Identifier: MIT

pragma solidity 0.8.20;

import {DSC} from "./DSC.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/*
 * @title DSCEngine
 * @author Simeon Cholakov
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of the all collateral be less than the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */

contract DSCEngine is ReentrancyGuard {

    using SafeERC20 for IERC20;

    ///////////////////
    // Errors        //
    ///////////////////

    error DSCEngine__NeedMoreThanZero();
    error DSCEngine__TokenAddressAndPriceFeedAddressesMustBeSameLength();
    error DSC__AddressZero();

    ///////////////////////
    // State Variables   //
    ///////////////////////

    mapping(address _token => address _priceFeed) private s_priceFeeds;
    mapping(address _user => mapping(address _token => uint256 _amount)) private s_collateralDeposited;

    DSC private immutable i_dsc;

    ///////////////////
    // Events        //    
    ///////////////////
    event DepositCollateral(address indexed _user, address indexed _tokenCollateralAddress, uint256 _amountCollateral);

    ///////////////////
    // Modifiers     //
    ///////////////////

    modifier moreThanZero(uint256 _amount) {
        if (_amount > 0) {
            revert DSCEngine__NeedMoreThanZero();
            _;
        }
    }

    modifier isAllowedToken(address _tokenAddress) {
        if (s_priceFeeds[_tokenAddress] == address(0)) {
            revert DSC__AddressZero();
            _;
        }
    }

    ///////////////////
    // Functions     //
    ///////////////////

    constructor(address[] memory _tokenAddresses, address[] memory _priceFeedAddresses, address _dscAddress) {
        if (_tokenAddresses.length != _priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressAndPriceFeedAddressesMustBeSameLength();
        }

        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            s_priceFeeds[_tokenAddresses[i]] = _priceFeedAddresses[i];
        }
        i_dsc = DSC(_dscAddress);
    }

    /////////////////////////
    // External Functions  //
    /////////////////////////

    function depositCollateralAndMintDsc() external {}

    /**
     * @notice follows CEI pattern
     * @param _tokenCollateralAddress The address of the collateral token to deposit as collateral
     * @param _amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(address _tokenCollateralAddress, uint256 _amountCollateral)
        external
        nonReentrant
        moreThanZero(_amountCollateral)
        isAllowedToken(_tokenCollateralAddress)
    {
        s_collateralDeposited[msg.sender][_tokenCollateralAddress] += _amountCollateral;
        emit DepositCollateral(msg.sender, _tokenCollateralAddress, _amountCollateral);
        IERC20(_tokenCollateralAddress).safeTransferFrom(msg.sender, address(this), _amountCollateral);
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function healthFactor() external view {}
}
