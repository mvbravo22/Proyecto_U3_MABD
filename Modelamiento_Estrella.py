
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import MetaData
from datetime import datetime
import psycopg2

def log(logfile, message):
    timestamp_format = '%H:%M:%S-%h-%d-%Y'
    #Hour-Minute-Second-MonthName-Day-Year
    now = datetime.now() # get current timestamp
    timestamp = now.strftime(timestamp_format)
    with open(logfile,"a") as f: 
        f.write('[' + timestamp + ']: ' + message + '\n')
        print(message)

def transform():

    log(logfile, "-------------------------------------------------------------")
    log(logfile, "Inicia Fase De Transformacion")
    df_fact_sales = pd.read_sql_query("""
      SELECT OrderDetail.Id AS FactId,
       Customer.Id AS CustomerId,
       Employee.Id AS EmployeeId,
       Customer.Id AS LocationId,
       strftime('%Y%m%d', datetime([Order].OrderDate)) as TimeId, 
       [Order].RequiredDate,
        CASE
           WHEN [Order].ShippedDate is NOT NULL then [Order].ShippedDate
        ELSE 'NA'
        END
        ShippedDate,
       Shipper.Id AS ShipVia,
       [Order].Freight,
       Product.Id AS ProductId,
       OrderDetail.UnitPrice,
       OrderDetail.Quantity,
       OrderDetail.Discount
         FROM OrderDetail
        INNER JOIN [Order]  ON [Order].Id = OrderDetail.OrderId 
        INNER JOIN Customer  ON Customer.Id = [Order].CustomerId
        INNER JOIN Employee  ON Employee.Id = [Order].EmployeeId 
        INNER JOIN Shipper  ON Shipper.Id = [Order].ShipVia 
        INNER JOIN Product  ON Product.Id = OrderDetail.ProductId;
        """, con=engine.connect())

    df_customers = pd.read_sql_query("""SELECT Id AS CustomerId, 
        CompanyName, 
        ContactName, 
        ContactTitle, 
        Phone,
        CASE
           WHEN Fax is NOT NULL then Fax
        ELSE 'NA'
        END
        Fax
        FROM Customer;
        """, con=engine.connect())
    df_employees = pd.read_sql_query("""
       SELECT Id AS EmployeeId,
       LastName,
       FirstName,
       Title,
       TitleOfCourtesy,
       BirthDate,
       HireDate,
       Address,
       City,
       Region,
       PostalCode,
       Country,
       HomePhone,
       Extension,
       CASE
           WHEN Photo is NOT NULL then Photo
        ELSE 'foto no registrada'
        END
        Photo,
       Notes,
        CASE
           WHEN ReportsTo is NOT NULL then ReportsTo
        ELSE 'NA'
        END
        ReportsTo,
       PhotoPath
        FROM Employee;
        """, con=engine.connect())
    df_location = pd.read_sql_query("""
       SELECT Id AS LocationId,
       Address,
       City,
       Region,
       CASE
           WHEN PostalCode is NOT NULL then PostalCode
        ELSE 'NA'
        END
        PostalCode,
       Country
       FROM Customer;
        """, con=engine.connect())
    df_product = pd.read_sql_query("""
        SELECT p.Id AS ProducId,
       p.ProductName AS Nombre_Producto ,
       p.QuantityPerUnit,
       p.UnitPrice,
       p.UnitsInStock,
       p.UnitsOnOrder,
       p.ReorderLevel,
       p.Discontinued,
       c.CategoryName AS Categoria,
       s.CompanyName AS Proveedor,
       s.ContactName AS Nombre_Contacto,
       s.City AS City_Proveedor
        FROM Product p
        INNER JOIN Category c ON c.Id = p.CategoryId
        INNER JOIN Supplier s ON s.Id = p.SupplierId;
        """, con=engine.connect())
    df_shipper = pd.read_sql_query("""
    SELECT Id AS ShipperId,
       CompanyName,
       Phone
     FROM Shipper;""", con=engine.connect())

    log(logfile, "Finaliza Fase De Transformacion")
    log(logfile, "-------------------------------------------------------------")
    return df_fact_sales,df_customers,df_employees,df_location,df_product,df_shipper
   
def load():
    """ Connect to the PostgreSQL database server """
    conn_string = 'postgresql://postgres:172164@localhost/DW_ liquor_sale_Estrella'
    db = create_engine(conn_string)
    conn = db.connect()
    try:
        log(logfile, "-------------------------------------------------------------")
        log(logfile, "Inicia  Carga")
        df_customers.to_sql('dim_customer', conn, if_exists='append',index=False)
        df_employees.to_sql('dim_employee', conn, if_exists='append',index=False)
        df_location.to_sql('dim_location', conn, if_exists='append',index=False)
        df_product.to_sql('dim_product', conn, if_exists='append',index=False)
        df_shipper.to_sql('dim_shipper', conn, if_exists='append',index=False)
        df_fact_sales.to_sql('liquor_sales', conn, if_exists='append',index=False)
        conn = psycopg2.connect(conn_string)
        conn.autocommit = True
        cursor = conn.cursor()
        log(logfile, "Finaliza Carga")
        log(logfile, "-------------------------------------------------------------")
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally: 
        if conn is not None:
            conn.close()
            print('Conexion de la base de datos cerrada.')

def extract():
    log(logfile, "--------------------------------------------------------")
    log(logfile, "Inicia Extraccion")
    metadata = MetaData()
    metadata.create_all(engine)
    log(logfile, "Finaliza Extraccion")
    log(logfile, "--------------------------------------------------------")


if __name__ == '__main__':
    
    logfile = "ProyectoETL_logfile.txt"
    log(logfile, "ETL iniciado.")
    engine = create_engine('sqlite:///Northwind.sqlite')
    extract()
    (df_fact_sales,df_customers,df_employees,df_location,df_product,df_shipper) = transform()
    load()
    log(logfile, "ETL  finalizado.")
