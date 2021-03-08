pragma solidity ^0.7.0;

interface IBPool {
    function getCurrentTokens() external view returns (address[] memory tokens);

    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;

    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;

    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);

    function swapExactAmountOut(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);

    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);

    function joinswapPoolAmountOut(
        address tokenIn,
        uint256 poolAmountOut,
        uint256 maxAmountIn
    ) external returns (uint256 tokenAmountIn);

    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);

    function exitswapExternAmountOut(
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);
}

interface IERC20Min {
    function balanceOf(address whom) external view returns (uint);
    function approve(address dst, uint amt) external returns (bool);
    function transfer(address dst, uint amt) external returns (bool);
    function transferFrom(
        address src, address dst, uint amt
    ) external returns (bool);
}


contract ExchangeProxyMock {
   event LOG_SWAP(
      address indexed caller,
      address indexed tokenIn,
      address indexed tokenOut,
      uint256         tokenAmountIn,
      uint256         tokenAmountOut
  );

  function joinPool(address pool, uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external {
    address[] memory tokens = IBPool(pool).getCurrentTokens();

    for (uint i = 0; i < tokens.length; i++) {
      IERC20Min(tokens[i]).transferFrom(msg.sender, address(this), IERC20Min(tokens[i]).balanceOf(msg.sender));
      IERC20Min(tokens[i]).approve(pool, maxAmountsIn[i]);
    }

    IBPool(pool).joinPool(poolAmountOut, maxAmountsIn);

    for (uint i = 0; i < tokens.length; i++) {
      uint256 balance = IERC20Min(tokens[i]).balanceOf(address(this));
      IERC20Min(tokens[i]).transfer(msg.sender, balance);
    }

    IERC20Min(pool).transfer(msg.sender, IERC20Min(pool).balanceOf(address(this)));
  }

  function exitPool(address pool, uint256 poolAmountIn, uint256[] calldata minAmountsOut) external {
    IERC20Min(pool).transferFrom(msg.sender, address(this), IERC20Min(pool).balanceOf(msg.sender));
    IBPool(pool).exitPool(poolAmountIn, minAmountsOut);

    address[] memory tokens = IBPool(pool).getCurrentTokens();
    for (uint i = 0; i < tokens.length; i++) {
      uint256 balance = IERC20Min(tokens[i]).balanceOf(address(this));
      IERC20Min(tokens[i]).transfer(msg.sender, balance);
    }
  }

  function swapExactAmountIn(
      address pool,
      address tokenIn,
      uint256 tokenAmountIn,
      address tokenOut,
      uint256 minAmountOut,
      uint256 maxPrice
  ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter) {
    IERC20Min(tokenIn).transferFrom(msg.sender, address(this), IERC20Min(tokenIn).balanceOf(msg.sender));
    IERC20Min(tokenIn).approve(pool, tokenAmountIn);

    (tokenAmountOut, spotPriceAfter) = IBPool(pool).swapExactAmountIn(
      tokenIn,
      tokenAmountIn,
      tokenOut,
      minAmountOut,
      maxPrice
    );

    IERC20Min(tokenIn).transfer(msg.sender, IERC20Min(tokenIn).balanceOf(address(this)));
    IERC20Min(tokenOut).transfer(msg.sender, IERC20Min(tokenOut).balanceOf(address(this)));

    emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountIn, tokenAmountOut);
  }

  function swapExactAmountOut(
      address pool,
      address tokenIn,
      uint256 maxAmountIn,
      address tokenOut,
      uint256 tokenAmountOut,
      uint256 maxPrice
  ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter) {
    IERC20Min(tokenIn).transferFrom(msg.sender, address(this), IERC20Min(tokenIn).balanceOf(msg.sender));
    IERC20Min(tokenIn).approve(pool, maxAmountIn);

    (tokenAmountIn, spotPriceAfter) = IBPool(pool).swapExactAmountOut(
      tokenIn,
      maxAmountIn,
      tokenOut,
      tokenAmountOut,
      maxPrice
    );

    IERC20Min(tokenIn).transfer(msg.sender, IERC20Min(tokenIn).balanceOf(address(this)));
    IERC20Min(tokenOut).transfer(msg.sender, IERC20Min(tokenOut).balanceOf(address(this)));

    emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountIn, tokenAmountOut);
  }

  function joinswapExternAmountIn(
      address pool,
      address tokenIn,
      uint256 tokenAmountIn,
      uint256 minPoolAmountOut
  ) external returns (uint256 poolAmountOut) {
    IERC20Min(tokenIn).transferFrom(msg.sender, address(this), IERC20Min(tokenIn).balanceOf(msg.sender));
    IERC20Min(tokenIn).approve(pool, tokenAmountIn);

    poolAmountOut = IBPool(pool).joinswapExternAmountIn(
      tokenIn,
      tokenAmountIn,
      minPoolAmountOut
    );

    IERC20Min(tokenIn).transfer(msg.sender, IERC20Min(tokenIn).balanceOf(address(this)));
    IERC20Min(pool).transfer(msg.sender, IERC20Min(pool).balanceOf(address(this)));
  }

  function joinswapPoolAmountOut(
      address pool,
      address tokenIn,
      uint256 poolAmountOut,
      uint256 maxAmountIn
  ) external returns (uint256 tokenAmountIn) {
    IERC20Min(tokenIn).transferFrom(msg.sender, address(this), IERC20Min(tokenIn).balanceOf(msg.sender));
    IERC20Min(tokenIn).approve(pool, maxAmountIn);

    tokenAmountIn = IBPool(pool).joinswapPoolAmountOut(
      tokenIn,
      poolAmountOut,
      maxAmountIn
    );

    IERC20Min(tokenIn).transfer(msg.sender, IERC20Min(tokenIn).balanceOf(address(this)));
    IERC20Min(pool).transfer(msg.sender, IERC20Min(pool).balanceOf(address(this)));
  }

  function exitswapPoolAmountIn(
      address pool,
      address tokenOut,
      uint256 poolAmountIn,
      uint256 minAmountOut
  ) external returns (uint256 tokenAmountOut) {
    IERC20Min(pool).transferFrom(msg.sender, address(this), IERC20Min(pool).balanceOf(msg.sender));

    tokenAmountOut = IBPool(pool).exitswapPoolAmountIn(
      tokenOut,
      poolAmountIn,
      minAmountOut
    );

    IERC20Min(tokenOut).transfer(msg.sender, IERC20Min(tokenOut).balanceOf(address(this)));
    IERC20Min(pool).transfer(msg.sender, IERC20Min(pool).balanceOf(address(this)));
  }

  function exitswapExternAmountOut(
      address pool,
      address tokenOut,
      uint256 tokenAmountOut,
      uint256 maxPoolAmountIn
  ) external returns (uint256 poolAmountIn) {
    IERC20Min(pool).transferFrom(msg.sender, address(this), IERC20Min(pool).balanceOf(msg.sender));

    poolAmountIn = IBPool(pool).exitswapExternAmountOut(
      tokenOut,
      tokenAmountOut,
      maxPoolAmountIn
    );

    IERC20Min(tokenOut).transfer(msg.sender, IERC20Min(tokenOut).balanceOf(address(this)));
    IERC20Min(pool).transfer(msg.sender, IERC20Min(pool).balanceOf(address(this)));
  }
}
