CREATE TABLE Clientes (
id_cliente INT NOT NULL IDENTITY (1,1) PRIMARY KEY,
nombre_cliente varchar(100) NOT NULL, 
perfil_bio varchar(150) NOT NULL,
fecha_registro date 
);

CREATE TABLE Productos (
id_producto INT NOT NULL IDENTITY (1,1) PRIMARY KEY,
descripcion varchar(255) NOT NULL,
precio DECIMAL (10,2),
esta_activo BIT NOT NULL DEFAULT (0) 
)
--Los datos que tienen INT son numeros enteros fijos, identificadores, marqué NOT NULL para que no permita vacios. IDENTITY marca que comienza desde el ID 1 y que sube de uno en uno.
--Primary Key es el dato que sire para identificar de manera unica al registro de cada tabla.
--varchar permite entradas de texto (incluyendo numeros). Decimal se usó para permitir un precio que ocupe diez nmuméricos y dos decimales.
-- Bit lo tuve que buscar online, mi idea es que cada bit identifique si está activo o no, siendo 1 SI y 0 NO. Como era posible, lo implementé con el 0 como default.