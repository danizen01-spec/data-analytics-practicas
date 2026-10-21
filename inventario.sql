CREATE TABLE inventario (
id_producto INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
nombre_producto VARCHAR(100) NOT NULL,
categoria VARCHAR(50) NOT NULL,
precio_unitario DECIMAL(10,2) NOT NULL,
stock_actual INT NOT NULL,
stock_minimo INT NOT NULL,
fecha_ingreso DATE NOT NULL,
activo BIT NOT NULL DEFAULT(0)
);
-- Se eligió INT para datos numéricos fijos, Identity para ejecutar una secuencia de (1,1) fija, y date para que el conjunto de números se interprete como fecha.
SELECT * FROM inventario;

INSERT INTO inventario
(nombre_producto, categoria, precio_unitario, stock_actual, stock_minimo, fecha_ingreso, activo)
VALUES
('Mouse Inalámbrico', 'Accesorios', 28.00, 80, 10,'2024-01-10',1),
('Monitor 4K 27"',	'Computación',	1200.00,	15,	3,	'2024-01-10',	1),
('Teclado Mecánico','Accesorios',95.00, 40, 5, '2024-01-15', 1),
('Laptop Basic 14',	'Computación',	650.00,	20, 3, '2024-02-01',1),
('Auriculares BT Pro',	'Audio',	120.00,	35,	5,	'2024-02-01',	1),
('Hub USB-C 7 puertos',	'Accesorios', 45.00,	60,	10,	'2024-02-10',	1),
('Webcam HD 1080p',	'Accesorios',	85.00,	25,	5,	'2024-02-10',	1),
('SSD Externo 1TB',	'Almacenamiento',	130.00,	18,	3,	'2024-03-01',	1),
('Parlante Bluetooth',	'Audio',	60.00,	45,	8, '2024-03-01',	1);

UPDATE inventario
SET stock_actual = stock_actual - 3
WHERE id_producto = 1;
UPDATE inventario
SET stock_actual = stock_actual - 12
WHERE id_producto = 2;
UPDATE inventario
SET stock_actual = stock_actual - 5
WHERE id_producto = 6;

UPDATE inventario
SET activo = 0
WHERE  id_producto = 8;