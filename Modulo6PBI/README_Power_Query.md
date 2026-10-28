# Limpieza y normalización de datos en Power BI

## Evidencia: pasos aplicados

![Panel «Pasos aplicados» de Power Query](capturas/pasos_aplicados.png)

La captura documenta el orden de las transformaciones de la consulta de origen. Los nombres automáticos de algunos pasos no permiten conocer por sí solos sus parámetros exactos; cuando corresponde, se indica esa limitación.

## 1. Transformaciones realizadas, en orden

| Orden | Paso en Power Query | Acción y justificación técnica |
|---:|---|---|
| 1 | **Origen** | Se conectó el archivo de datos. Mantener la conexión en una consulta permite repetir las transformaciones cuando se actualiza la fuente. |
| 2 | **Navegación** | Se seleccionó el objeto de origen que contiene los registros de ventas. |
| 3 | **Filas en blanco eliminadas** | Se descartaron filas totalmente vacías, que no aportan observaciones ni pueden identificarse como transacciones. No equivale a eliminar cualquier fila con algún campo nulo. |
| 5 | **Tipo cambiado** | Se revisaron los tipos detectados por Power Query. Los campos ya tenían tipos adecuados, por lo que no fue necesario corregirlos en esta revisión. |
| 6 | **Columnas con nombre cambiado** | Se sustituyeron abreviaturas por nombres descriptivos y consistentes, facilitando la lectura y la construcción de fórmulas. |
| 7 | **Tipo cambiado1** | Se revisó nuevamente la asignación de tipos de datos para comprobar su coherencia con el contenido de las columnas. |
| 8 | **Duplicados quitados** | Se eliminaron filas idénticas tras revisar operaciones con identificadores repetidos. Se comparó el contenido completo, porque un mismo `id_operacion` podría corresponder a varias líneas legítimas de una compra. |
| 9 | **Personalizada agregada** | Se añadió una columna auxiliar para detectar registros con al menos un valor `null`, sin modificar sus valores originales. |
| 10–14 | **Valor reemplazado**, **Valor reemplazado1** a **Valor reemplazado4** | Se aplicaron cinco operaciones de reemplazo para tratar valores identificados durante la revisión. Cada sustitución debe respetar el significado del campo: un dato desconocido no debe convertirse automáticamente en cero. La captura no permite verificar qué valor se reemplazó en cada paso. |
| 15 | **Personalizada agregada1** | Se generó una columna con el total de venta corregido, reconstruyendo importes faltantes a partir de las variables disponibles y conservando los totales existentes. |
| 16 | **Columnas quitadas** | Se eliminaron columnas auxiliares utilizadas durante la revisión de nulos y columnas sustituidas tras completar las correcciones, porque ya no eran necesarias en el resultado final. Esto evita campos redundantes y facilita la lectura del conjunto de datos. |
| 17 | **Columnas reordenadas** | Se ordenaron los campos para facilitar la inspección y comprensión de la tabla; esta operación no cambia los valores. |
| 18 | **Columnas con nombre cambiado1** | Se ajustaron los nombres finales, entre ellos el de la columna de total corregido para conservar la denominación de negocio. |
| 19 | **Tipo cambiado2** | Se comprobó la tipificación final de los campos calculados. La única modificación de formato realizada por preferencia fue presentar `descuento_porcentual` como porcentaje en lugar de decimal; ambos formatos pueden representar la misma proporción. |

## 2. Justificación de los tipos de datos

Los tipos de datos de origen ya eran adecuados y se revisaron para comprobarlo. No se corrigieron errores de tipificación: únicamente se optó por mostrar `descuento_porcentual` como porcentaje en lugar de decimal, por claridad de lectura. Este cambio de presentación no altera por sí mismo el significado numérico de la proporción.

| Campos | Tipo adecuado | Justificación |
|---|---|---|
| `nombre_cliente`, `mail_cliente`, `telefono_cliente`, `ciudad_cliente`, `provincia_cliente`, `segmento`, `canal`, `moneda` | Texto | Son etiquetas, categorías o datos de contacto; no se utilizan para operaciones aritméticas. El teléfono debe tratarse como texto para preservar ceros iniciales y símbolos. |
| `cantidad` | Número entero | Expresa unidades vendidas y permite sumas y controles de cantidades. |
| `precio_unitario`, `total_venta` | Número decimal o decimal fijo | Son importes monetarios; el decimal fijo es útil cuando se requiere precisión a escala de moneda. |
| `descuento_porcentual` | Porcentaje | Representa una proporción; un 10 % se utiliza como `0,10` en la fórmula de cálculo. |
| `fecha_registro`, `fecha_venta` | Fecha | Permite ordenar, agrupar y filtrar por períodos sin interpretar las fechas como cadenas de texto. |
| `id_cliente`, `id_operacion` | Identificador: texto o entero según la fuente | Su función es identificar y relacionar registros, no medir cantidades. El tipo de `id_cliente` debe coincidir en ambas tablas. Si los códigos contienen ceros iniciales o letras, corresponde texto. |

## 3. Tratamiento de duplicados y valores nulos

### Duplicados

Se agrupó temporalmente la información por `id_operacion` y se contó la cantidad de filas por identificador. Algunos identificadores aparecían dos veces. Antes de eliminarlos se compararon los registros: la repetición de un identificador no basta para demostrar un error, ya que una operación puede incluir varios artículos. Al comprobar filas completamente idénticas, se aplicó **Quitar duplicados** sobre el conjunto de columnas. Así se evitó borrar ventas válidas solo por compartir identificador.

### Nulos

Se usó **Vista → Calidad de columna** para observar valores válidos, errores y vacíos. Además, se creó una columna auxiliar con esta expresión M:

```powerquery
List.Contains(Record.FieldValues(_), null)
```

La expresión devuelve `true` si una fila contiene al menos un `null`, lo que facilita localizar registros incompletos en distintas columnas. Una vez terminada la inspección, se eliminaron las columnas auxiliares que ya no se necesitaban, para no conservar indicadores temporales en el modelo. Se eliminó una fila completamente vacía. En campos de contacto como el correo electrónico, un nulo no invalida necesariamente una venta y puede mantenerse sin inventar información.

En `total_venta`, reemplazar un importe desconocido por cero distorsionaría la facturación. Por ello, después de revisar `cantidad`, `precio_unitario` y `descuento_porcentual`, se calculó el total faltante con la siguiente expresión:

```powerquery
if [total_venta] = null then
    [cantidad] * [precio_unitario] * (1 - [descuento_porcentual])
else
    [total_venta]
```

Este cálculo supone que el descuento está almacenado como proporción (por ejemplo, `0,10` para 10 %) y que el total de venta corresponde al importe posterior al descuento. La condición conserva los importes originales cuando ya están informados. Tras la corrección, se comprobó la calidad de la columna `total_venta`, sin vacíos ni errores detectados.

## 4. Separación entre clientes y transacciones

La división se basó en la **entidad descrita por cada atributo** y en la granularidad de los registros:

- **`D_clientes`**: `id_cliente`, `nombre_cliente`, `mail_cliente`, `telefono_cliente`, `ciudad_cliente`, `provincia_cliente`, `segmento`, `fecha_registro`. Son atributos del cliente, independientes de cada compra. Se verificó que `id_cliente` no estuviera duplicado, para que funcione como clave única lógica.
- **`F_Transacciones`**: `id_operacion`, `id_cliente`, `fecha_venta`, `cantidad`, `precio_unitario`, `descuento_porcentual`, `total_venta`, `canal`, `moneda`. Describen cuándo y en qué condiciones se realizó una venta. `id_cliente` se mantiene como referencia al comprador.

Las dos consultas se derivaron de la fuente limpiada y se conservaron solo las columnas correspondientes a cada entidad. La consulta original `F_Datos` se mantuvo como base de transformación, con la carga al modelo deshabilitada, para evitar una tercera tabla redundante.

En la **Vista de modelo** se estableció o verificó una relación activa **uno a varios (1:*)** desde `D_clientes[id_cliente]` hacia `F_Transacciones[id_cliente]`, con filtrado en una sola dirección. Esto refleja que un cliente puede registrar varias transacciones y evita repetir sus atributos personales en cada fila de venta. En Power BI estas claves son lógicas: la unicidad y la cardinalidad se verifican en el modelo, no mediante restricciones SQL `PRIMARY KEY` o `FOREIGN KEY`.

## 5. Resultado

El resultado es un modelo de dos tablas relacionadas, adecuado para analizar importes, cantidades y descuentos por cliente, segmento, ubicación, fecha y canal. El proceso conserva una secuencia reproducible de limpieza en Power Query y separa los datos descriptivos de las operaciones comerciales.

> **Verificación pendiente para una documentación exhaustiva:** los cinco pasos llamados `Valor reemplazado...` no muestran sus valores de búsqueda y sustitución en la captura. Para detallar cada uno con exactitud, se debe seleccionar el paso en Power Query y consultar la barra de fórmulas o el Editor avanzado.
