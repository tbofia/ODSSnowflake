IF OBJECT_ID('adm.FK_Process_Product', 'F') IS NULL
ALTER TABLE adm.Process ADD CONSTRAINT FK_Process_Product
    FOREIGN KEY (ProductKey)
    REFERENCES adm.Product(ProductKey)
GO
