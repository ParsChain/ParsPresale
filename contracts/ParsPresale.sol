pragma solidity ^0.4.21;

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";

/**
 * @title ParsPresale
 *
 */

contract ParsPresale is TimedCrowdsale, FinalizableCrowdsale {
    uint256 public cap;
    uint256 public tokensRaised;

    event RateChanged(uint256 value);

    /**
    * @param _rate Pars per Ethereum
    * @param _wallet Address where collected funds will be forwarded to
    * @param _cap Amount of pars available in presale
    * @param _token Token address
    */
    function ParsPresale(
        uint256 _openingTime,
        uint256 _closingTime,
        
        uint256 _rate,
        address _wallet,
        address _token,
        uint256 _cap
    )
    public
    Crowdsale(_rate, _wallet, ERC20(_token))
    
    TimedCrowdsale(_openingTime, _closingTime)
    FinalizableCrowdsale()
    {
        require(_cap > 0);
        cap = _cap;

        owner = _wallet;
    }

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(rate).div(10**18);
    }

    function getTokenAmount(uint256 _weiAmount) public view returns (uint256) {
        return _getTokenAmount(_weiAmount);
    }

    function changeRate(uint256 _rate) public onlyOwner {
        rate = _rate;

        emit RateChanged(rate);
    }

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        tokensRaised = tokensRaised.add(_tokenAmount);

        super._processPurchase(_beneficiary, _tokenAmount);
    }

    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
        internal
    {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        require(tokensRaised.add(_getTokenAmount(_weiAmount)) <= cap);
    }

    function finalization() internal {
        if(tokensRaised < cap)
            token.transfer(wallet, cap.sub(tokensRaised));
    }
}