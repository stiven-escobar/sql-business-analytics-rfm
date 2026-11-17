-- ========================================================
-- PROYECTO: Modelado Relacional y Segmentación RFM (SQL)
-- AUTOR: Stiven Escobar Carabalí
-- ========================================================

CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    tipo_cliente VARCHAR(20) CHECK (tipo_cliente IN ('B2B', 'B2C')),
    ciudad VARCHAR(50),
    fecha_registro DATE
);

CREATE TABLE Productos (
    producto_id INT PRIMARY KEY IDENTITY(1,1),
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    precio_unitario DECIMAL(12,2)
);

CREATE TABLE Ventas (
    venta_id INT PRIMARY KEY IDENTITY(1,1),
    cliente_id INT FOREIGN KEY REFERENCES Clientes(cliente_id),
    producto_id INT FOREIGN KEY REFERENCES Productos(producto_id),
    cantidad INT NOT NULL,
    monto_total DECIMAL(12,2) NOT NULL,
    fecha_venta DATE NOT NULL
);
