// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

contract KipuBankV3 is Ownable {
    address public immutable USDC_ADDRESS; 
    address public immutable UNISWAP_ROUTER_ADDRESS;
    address public immutable WETH_ADDRESS;
    
    uint256 public constant BANK_CAP_USDC = 100_000 * 1e6; 
    uint256 public totalUSDCDeposited; 
    mapping(address => uint256) private userUSDCBalances; 

    event Deposito(address indexed usuario, address indexed tokenIn, uint256 montoIn, uint256 montoUSDC);
    event Retiro(address indexed usuario, uint256 montoUSDC);

    constructor(address _usdc, address _router, address _weth) Ownable(msg.sender) {
        require(_usdc != address(0) && _router != address(0) && _weth != address(0), "Direccion invalida");
        USDC_ADDRESS = _usdc;
        UNISWAP_ROUTER_ADDRESS = _router;
        WETH_ADDRESS = _weth;
    }

    receive() external payable {
        if (msg.value > 0) {
            _depositAndSwapToUSDC(address(0), msg.value);
        }
    }

    function depositar(address tokenIn, uint256 amountIn) external payable {
        if (tokenIn == address(0)) {
            require(msg.value > 0, "Monto ETH invalido");
            _depositAndSwapToUSDC(address(0), msg.value);
        } else if (tokenIn == USDC_ADDRESS) {
            require(amountIn > 0, "Monto USDC invalido");
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
            uint256 newTotal = totalUSDCDeposited + amountIn;
            require(newTotal <= BANK_CAP_USDC, "Limite bancario excedido");
            userUSDCBalances[msg.sender] += amountIn;
            totalUSDCDeposited = newTotal;
            emit Deposito(msg.sender, tokenIn, amountIn, amountIn);
        } else {
            require(amountIn > 0, "Monto ERC20 invalido");
            _depositAndSwapToUSDC(tokenIn, amountIn);
        }
    }

    function _depositAndSwapToUSDC(address tokenIn, uint256 amountIn) internal {
        address[] memory path;
        uint256 usdcReceived;

        if (tokenIn == address(0)) {
            path = new address ;
            path[0] = WETH_ADDRESS;
            path[1] = USDC_ADDRESS;
            uint256[] memory amounts = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS)
                .swapExactETHForTokens{value: amountIn}(0, path, address(this), block.timestamp);
            usdcReceived = amounts[1];
        } else {
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
            IERC20(tokenIn).approve(UNISWAP_ROUTER_ADDRESS, amountIn);
            path = new address ;
            path[0] = tokenIn;
            path[1] = USDC_ADDRESS;
            uint256[] memory amounts = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS)
                .swapExactTokensForTokens(amountIn, 0, path, address(this), block.timestamp);
            usdcReceived = amounts[1];
            IERC20(tokenIn).approve(UNISWAP_ROUTER_ADDRESS, 0);
        }

        require(usdcReceived > 0, "Swap fallido o 0 USDC");
        uint256 newTotal = totalUSDCDeposited + usdcReceived;
        require(newTotal <= BANK_CAP_USDC, "Limite bancario excedido post-swap");
        userUSDCBalances[msg.sender] += usdcReceived;
        totalUSDCDeposited = newTotal;
        emit Deposito(msg.sender, tokenIn, amountIn, usdcReceived);
    }

    function retirar(uint256 amount) external {
        require(amount > 0, "Monto invalido");
        uint256 currentBalance = userUSDCBalances[msg.sender];
        require(currentBalance >= amount, "Fondos insuficientes");
        userUSDCBalances[msg.sender] -= amount;
        totalUSDCDeposited -= amount;
        IERC20(USDC_ADDRESS).transfer(msg.sender, amount);
        emit Retiro(msg.sender, amount);
    }

    function verBalanceUSDC(address usuario) external view returns (uint256) {
        return userUSDCBalances[usuario];
    }
    
    function verTotalDepositado() external view returns (uint256) {
        return totalUSDCDeposited;
    }
}
