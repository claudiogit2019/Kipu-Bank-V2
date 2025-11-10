// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract KipuBankV2 is Ownable {

    // --- Tipos y estructuras ---
    struct Balance {
        uint256 amount;
        uint8 decimals;
    }

    // --- Variables constantes e inmutables ---
    uint256 public constant MAX_BANK_CAP_USD = 100_000 * 1e8; // límite global del banco en USD (8 decimales Chainlink)
    address public immutable chainlinkFeed; // oráculo ETH/USD

    // --- Mappings anidados ---
    mapping(address => mapping(address => Balance)) private userBalances; // usuario -> token -> balance

    // --- Eventos ---
    event Deposito(address indexed usuario, address indexed token, uint256 monto);
    event Retiro(address indexed usuario, address indexed token, uint256 monto);

    // --- Constructor ---
    constructor(address _feed) Ownable(msg.sender) {
        chainlinkFeed = _feed;
    }

    // --- Función de depósito multi-token ---
    function depositar(address token, uint256 amount) external payable {
        if (token == address(0)) {
            require(msg.value > 0, "Monto invalido");
            userBalances[msg.sender][address(0)].amount += msg.value;
            emit Deposito(msg.sender, address(0), msg.value);
        } else {
            require(amount > 0, "Monto invalido");
            IERC20(token).transferFrom(msg.sender, address(this), amount);
            userBalances[msg.sender][token].amount += amount;
            emit Deposito(msg.sender, token, amount);
        }
    }

    // --- Función de retiro multi-token ---
    function retirar(address token, uint256 amount) external {
        Balance storage bal = userBalances[msg.sender][token];
        require(bal.amount >= amount, "Fondos insuficientes");

        bal.amount -= amount;

        if (token == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            IERC20(token).transfer(msg.sender, amount);
        }

        emit Retiro(msg.sender, token, amount);
    }

    // --- Conversión ETH/USD usando Chainlink ---
    function getEthUsdPrice() public view returns (int256) {
        (, int256 price,,,) = AggregatorV3Interface(chainlinkFeed).latestRoundData();
        return price;
    }

    // --- Ver balances individuales ---
    function verBalance(address usuario, address token) external view returns (uint256) {
        return userBalances[usuario][token].amount;
    }

    // --- Conversión genérica de decimales (tokens a USDC estándar 6 decimales) ---
    function convertirDecimales(uint256 valor, uint8 decimalesToken) public pure returns (uint256) {
        if (decimalesToken == 6) return valor;
        if (decimalesToken > 6) return valor / (10 ** (decimalesToken - 6));
        return valor * (10 ** (6 - decimalesToken));
    }
}

