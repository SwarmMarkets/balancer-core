// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract BPoolExtend is Proxy {
    address public immutable implementation;
    address public immutable exchangeProxy;

    bytes4 internal constant JOIN_POOL = 0x4f69c0d4; // joinPool(uint256,uint256[])
    bytes4 internal constant EXIT_POOL = 0xb02f0b73; //exitPool(uint256,uint256[])
    bytes4 internal constant SWAP_EXACT_AMOUNT_IN = 0x8201aa3f; //swapExactAmountIn(address,uint256,address,uint256,uint256)
    bytes4 internal constant SWAP_EXACT_AMOUNT_OUT = 0x7c5e9ea4; //swapExactAmountOut(address,uint256,address,uint256,uint256)
    bytes4 internal constant JOINSWAP_EXTERN_AMOUNT_IN = 0x5db34277; //joinswapExternAmountIn(address,uint256,uint256)
    bytes4 internal constant JOINSWAP_POOL_AMOUNT_OUT = 0x6d06dfa0; //joinswapPoolAmountOut(address,uint256,uint256)
    bytes4 internal constant EXITSWAP_POOL_AMOUNT_IN = 0x46ab38f1; //exitswapPoolAmountIn(address,uint256,uint256)
    bytes4 internal constant EXITSWAP_EXTERN_AMOUNT_OUT = 0x02c96748; //exitswapExternAmountOut(address,uint256,uint256)

     event LOG(
        bytes4 sig
    );

    constructor(address _poolImpl, address _exchProxy, bytes memory _data) {
        implementation = _poolImpl;
        exchangeProxy = _exchProxy;

        if(_data.length > 0) {
            Address.functionDelegateCall(_poolImpl, _data);
        }
    }

    function _implementation() internal view override returns (address) {
        return implementation;
    }

    function _beforeFallback() internal view override {
       if (
           msg.sig == JOIN_POOL ||
           msg.sig == EXIT_POOL ||
           msg.sig == SWAP_EXACT_AMOUNT_IN ||
           msg.sig == SWAP_EXACT_AMOUNT_OUT ||
           msg.sig == JOINSWAP_EXTERN_AMOUNT_IN ||
           msg.sig == JOINSWAP_POOL_AMOUNT_OUT ||
           msg.sig == EXITSWAP_POOL_AMOUNT_IN ||
           msg.sig == EXITSWAP_EXTERN_AMOUNT_OUT
        ) {
            require(msg.sender == exchangeProxy, "ERR_NOT_EXCHANGE_PROXY");
       }
    }
}
