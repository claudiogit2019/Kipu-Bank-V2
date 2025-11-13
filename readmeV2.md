
## KipuBankV2

**Versión evolucionada del contrato inteligente KipuBank**
Trabajo Final Módulo 3 – 2025-S2-EDP-HENRY-M3


### Introducción

KipuBankV2 es la versión mejorada del contrato **KipuBank**, desarrollado inicialmente en el Módulo 2 como ejercicio de fundamentos en Solidity.
Mientras la primera versión se limitaba a recibir Ether y registrar balances, esta segunda versión da un salto hacia un diseño **más cercano a un entorno de producción**, aplicando prácticas avanzadas de arquitectura, seguridad y documentación.

Este proyecto representa el proceso natural de **evolucionar un contrato inteligente**: analizar limitaciones, tomar decisiones de diseño y extender funcionalidades con criterio técnico.


### Reseña del prototipo original

El primer KipuBank fue un contrato simple de depósito en Ether.
Permitía a cada usuario guardar su saldo, visualizar su balance personal y probar el comportamiento de las funciones `receive` y `fallback`.
Este prototipo cumplió el propósito formativo del módulo anterior: comprender los conceptos base de **mappings**, **eventos** y **funciones `payable`**.

No obstante, presentaba varias limitaciones:

* No existía un mecanismo de control administrativo.
* Solo funcionaba con Ether, sin soporte para tokens ERC20.
* No utilizaba oráculos ni manejo de decimales.
* No aplicaba optimizaciones de gas, ni variables inmutables o constantes.

Estas restricciones son el punto de partida para el desarrollo de **KipuBankV2**.


### Mejoras introducidas en KipuBankV2

La nueva versión del contrato implementa una arquitectura más sólida, con las siguientes ampliaciones y refactorizaciones:

**1. Control de acceso mediante Ownable**
Se incorpora el módulo `Ownable` de OpenZeppelin para definir un propietario del contrato.
Esto permite restringir funciones administrativas y preparar la base para futuras ampliaciones de gobernanza.

**2. Soporte multi-token**
Además de Ether, ahora es posible depositar y retirar tokens ERC20.
Cada usuario puede mantener saldos independientes por tipo de activo, identificados por su dirección de contrato.
El Ether se representa por convención con la dirección `address(0)`.

**3. Contabilidad interna avanzada**
Se implementa un `mapping` doble que asocia a cada usuario una lista de balances por token.
Esto simula la estructura de una bóveda multiactivo, común en protocolos DeFi.

**4. Integración con Chainlink**
El contrato incluye un oráculo ETH/USD de Chainlink, utilizado para obtener el precio actualizado del Ether.
Esto permite simular la conversión de valores a dólares y definir un **límite global del banco (bank cap)** expresado en USD.

**5. Manejo de decimales y conversiones**
Se agrega una función que normaliza los montos entre tokens con distintos decimales, ajustando las unidades a una escala común (por ejemplo, la de USDC con 6 decimales).

**6. Uso de variables constant e immutable**
El contrato define una constante `MAX_BANK_CAP_USD` y una variable inmutable `chainlinkFeed`.
Ambas prácticas reducen el consumo de gas y aumentan la transparencia de las reglas del sistema.

**7. Eventos de depósito y retiro**
Se amplía la trazabilidad incorporando eventos específicos para cada operación, lo que facilita la verificación de transacciones en testnets y el seguimiento desde interfaces externas.

**8. Constructor parametrizable**
A diferencia del prototipo inicial, esta versión incluye un constructor que recibe la dirección del oráculo Chainlink durante el despliegue, lo que la hace adaptable a diferentes testnets.


### Elementos no implementados

En esta versión base no se incluyeron modificadores personalizados ni errores definidos con `error NombreError()`.
Estas características serán incorporadas en futuras versiones (por ejemplo, `KipuBankV2.1`) para reforzar las validaciones internas.
La decisión de omitirlas responde al objetivo pedagógico de mantener el código claro y funcional, sin agregar complejidad innecesaria en esta etapa del módulo.


### Decisiones de diseño

El diseño de **KipuBankV2** priorizó la claridad, la seguridad y la extensibilidad.
Se optó por una arquitectura simple y modular, evitando dependencias externas innecesarias.
El patrón *checks-effects-interactions* se respeta en las operaciones críticas de transferencia, y el contrato mantiene una estructura limpia, fácil de ampliar en etapas posteriores.


### Instrucciones de despliegue en Remix

1. Ingresar a [Remix IDE](https://remix.ethereum.org).
2. Crear el archivo `KipuBankV2.sol`.
3. Versión del compilador **0.8.20** seleccionada.
4. En la pestaña **Deploy & Run Transactions**:

   * Elegir el entorno **Injected Provider - MetaMask**.
   * En el campo del constructor, ingresar la dirección del oráculo Chainlink ETH/USD de la testnet elegida.

     * Ejemplo en Sepolia:
       `0x694AA1769357215DE4FAC081bf1f309aDC325306`
   * Hacer clic en **Deploy**.
5. Copiar la dirección del contrato desplegado.
6. Verificar el código fuente en el explorador de bloques de la testnet.



### Pruebas sugeridas en Remix

**Depósito en Ether:**
Seleccionar `depositar` con la dirección `0x0000000000000000000000000000000000000000` (address(0)) y enviar un valor en Ether desde la interfaz de Remix.
Verificar que se emite el evento `Deposito`.

**Depósito en token ERC20:**

1. Desde el contrato del token, ejecutar `approve(KipuBankV2, monto)`.
2. Luego, llamar a `depositar(direccionDelToken, monto)` en el contrato de KipuBankV2.

**Retiro:**
Ejecutar `retirar(token, monto)` y confirmar que el evento `Retiro` se emite correctamente.

**Consulta de balance:**
Utilizar `verBalance(usuario, token)` para revisar los saldos de un usuario específico.

**Precio ETH/USD:**
Invocar `getEthUsdPrice()` para obtener la cotización actual del Ether.

**Conversión de decimales:**
Probar `convertirDecimales(valor, decimalesToken)` para verificar la normalización de unidades.


### Conclusión

**KipuBankV2** marca una transición desde un contrato de prueba hacia una base sólida de producción.
Incorpora control de acceso, soporte multi-token, oráculo de precios y contabilidad avanzada, cumpliendo con los objetivos centrales del Módulo 3.


