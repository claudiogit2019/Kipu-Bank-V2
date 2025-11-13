# Proyecto: KipuBankV3

Versión final del examen del Módulo 4– Integración DeFi con Uniswap V2

## Objetivo

KipuBankV3 extiende la funcionalidad del contrato KipuBankV2 para convertirse en una aplicación DeFi completa, que:

Acepta cualquier token ERC20 o ETH con par en Uniswap V2.

Convierte automáticamente todo a USDC mediante un swap.

Acredita el saldo convertido al usuario.

Respeta un límite global (Bank Cap) y mantiene las funciones de depósito y retiro seguras.

## Requisitos previos

Remix IDE abierto en tu navegador:

https://remix.ethereum.org

MetaMask conectado (por ejemplo, a la red Sepolia testnet).

Algo de ETH de prueba (para swaps y gas).

Importar las dependencias de OpenZeppelin y Uniswap:

@openzeppelin/contracts

@uniswap/v2-periphery

Si Remix no detecta los imports automáticamente, crea una carpeta node_modules/@openzeppelin/contracts y pegá los contratos necesarios.

## Configuración de despliegue

En Remix:

Compilá con Solidity 0.8.20

Pestaña Deploy & Run Transactions

En Environment, seleccioná Injected Provider - MetaMask

Usá los siguientes parámetros de ejemplo para Sepolia:

Parámetro	Descripción	Dirección de ejemplo (Sepolia)

_usdc	Token USDC (6 decimales)	0x07865c6E87B9F70255377e024ace6630C1Eaa37F

_router	Uniswap V2 Router	0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45

_weth	WETH	0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6

Estos valores funcionan correctamente en la testnet Sepolia con MetaMask configurado.

## Pruebas básicas paso a paso

Desplegar contrato

Verificá que el deploy se complete sin errores.

Depósito de ETH

En Remix, seleccioná la función depositar

Dejá tokenIn = 0x0000000000000000000000000000000000000000

En el campo “value”, ingresá por ejemplo 0.01 ETH

Ejecutá y confirmá la transacción en MetaMask

Esperá a que el swap se ejecute (verás un evento Deposito)

Consultar balance del usuario

Llamá a verBalanceUSDC(tu_direccion)

Verás el monto en USDC recibido tras el swap.

Depósito de tokens ERC20

Usá approve desde el token que desees depositar

Luego llamá a depositar(tokenIn, amountIn)

Retiro de USDC

Ejecutá retirar(cantidad)

Confirmá la transacción y verificá que el USDC llegue a tu cuenta.

## Detalles técnicos

Los swaps se realizan directamente en Uniswap V2 Router 02

Se respeta el BANK_CAP_USDC = 100.000 USDC

Toda la conversión se acredita automáticamente al usuario

El contrato solo almacena USDC

Implementa control de propietario (Ownable) para administración futura



https://sepolia.etherscan.io/tx/0xf644e6f7d2238ddc0d51245fe1a26116652882fdd22f65983187b63c71246876