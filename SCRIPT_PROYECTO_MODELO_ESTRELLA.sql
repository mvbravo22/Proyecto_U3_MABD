CREATE TABLE dim_time
(
  date_dim_id              INT NOT NULL,
  date_actual              DATE NOT NULL,
  epoch                    BIGINT NOT NULL,
  day_suffix               VARCHAR(4) NOT NULL,
  day_name                 VARCHAR(20) NOT NULL,
  day_of_week              INT NOT NULL,
  day_of_month             INT NOT NULL,
  day_of_quarter           INT NOT NULL,
  day_of_year              INT NOT NULL,
  week_of_month            INT NOT NULL,
  week_of_year             INT NOT NULL,
  week_of_year_iso         CHAR(10) NOT NULL,
  month_actual             INT NOT NULL,
  month_name               VARCHAR(20) NOT NULL,
  month_name_abbreviated   CHAR(3) NOT NULL,
  quarter_actual           INT NOT NULL,
  quarter_name             VARCHAR(20) NOT NULL,
  year_actual              INT NOT NULL,
  first_day_of_week        DATE NOT NULL,
  last_day_of_week         DATE NOT NULL,
  first_day_of_month       DATE NOT NULL,
  last_day_of_month        DATE NOT NULL,
  first_day_of_quarter     DATE NOT NULL,
  last_day_of_quarter      DATE NOT NULL,
  first_day_of_year        DATE NOT NULL,
  last_day_of_year         DATE NOT NULL,
  mmyyyy                   CHAR(6) NOT NULL,
  mmddyyyy                 CHAR(10) NOT NULL,
  weekend_indr             BOOLEAN NOT NULL
);

--Generacion de datos de la dimension tiempo: fechas desde el 2009/01/01 hasta 10 anios despues de la ultima factura.
ALTER TABLE public.dim_time ADD CONSTRAINT d_date_date_dim_id_pk PRIMARY KEY (date_dim_id);

CREATE INDEX d_date_date_actual_idx
  ON dim_time(date_actual);

COMMIT;

INSERT INTO dim_time
SELECT TO_CHAR(datum, 'yyyymmdd')::INT AS date_dim_id,
       datum AS date_actual,
       EXTRACT(EPOCH FROM datum) AS epoch,
       TO_CHAR(datum, 'fmDDth') AS day_suffix,
       TO_CHAR(datum, 'TMDay') AS day_name,
       EXTRACT(ISODOW FROM datum) AS day_of_week,
       EXTRACT(DAY FROM datum) AS day_of_month,
       datum - DATE_TRUNC('quarter', datum)::DATE + 1 AS day_of_quarter,
       EXTRACT(DOY FROM datum) AS day_of_year,
       TO_CHAR(datum, 'W')::INT AS week_of_month,
       EXTRACT(WEEK FROM datum) AS week_of_year,
       EXTRACT(ISOYEAR FROM datum) || TO_CHAR(datum, '"-W"IW-') || EXTRACT(ISODOW FROM datum) AS week_of_year_iso,
       EXTRACT(MONTH FROM datum) AS month_actual,
       TO_CHAR(datum, 'TMMonth') AS month_name,
       TO_CHAR(datum, 'Mon') AS month_name_abbreviated,
       EXTRACT(QUARTER FROM datum) AS quarter_actual,
       CASE
           WHEN EXTRACT(QUARTER FROM datum) = 1 THEN 'First'
           WHEN EXTRACT(QUARTER FROM datum) = 2 THEN 'Second'
           WHEN EXTRACT(QUARTER FROM datum) = 3 THEN 'Third'
           WHEN EXTRACT(QUARTER FROM datum) = 4 THEN 'Fourth'
           END AS quarter_name,
       EXTRACT(YEAR FROM datum) AS year_actual,
       datum + (1 - EXTRACT(ISODOW FROM datum))::INT AS first_day_of_week,
       datum + (7 - EXTRACT(ISODOW FROM datum))::INT AS last_day_of_week,
       datum + (1 - EXTRACT(DAY FROM datum))::INT AS first_day_of_month,
       (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month,
       DATE_TRUNC('quarter', datum)::DATE AS first_day_of_quarter,
       (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') AS first_day_of_year,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year,
       TO_CHAR(datum, 'mmyyyy') AS mmyyyy,
       TO_CHAR(datum, 'mmddyyyy') AS mmddyyyy,
       CASE
           WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE
           ELSE FALSE
           END AS weekend_indr
FROM (SELECT '2012-07-04'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 4928) AS SEQUENCE (DAY)
      GROUP BY SEQUENCE.DAY) DQ
ORDER BY 1;

COMMIT;



CREATE TABLE public.dim_location
(
    "LocationId" character varying NOT NULL,
    "Address" character varying(200) NOT NULL,
    "City" character varying(200) NOT NULL,
    "Region" character varying(200) NOT NULL,
    "PostalCode" character varying(200) NOT NULL,
    "Country" character varying(200) NOT NULL,
    PRIMARY KEY ("LocationId")
);

CREATE TABLE public.dim_customer
(
    "CustomerId" character varying NOT NULL,
	"CompanyName" character varying(200) NOT NULL,
    "ContactName" character varying(200) NOT NULL,
    "ContactTitle" character varying(200) NOT NULL,
    "Phone" character varying(200) NOT NULL,
    "Fax" character varying(200) NOT NULL,
    PRIMARY KEY ("CustomerId")
);

CREATE TABLE public.dim_employee
(
    "EmployeeId" integer NOT NULL,
    "LastName" character varying(100) NOT NULL,
    "FirstName" character varying(100) NOT NULL,
    "Title" character varying(100) NOT NULL,
    "TitleOfCourtesy" character varying(100) NOT NULL,
	"BirthDate" character varying(100) NOT NULL,
    "HireDate" character varying(100) NOT NULL,
    "Address" character varying(100) NOT NULL,
    "City" character varying(100) NOT NULL,
    "Region" character varying(100) NOT NULL,
    "PostalCode" character varying(100) NOT NULL,
    "Country" character varying(100) NOT NULL,
    "HomePhone" character varying(50) NOT NULL,
    "Extension" character varying(50) NOT NULL,
    "Photo" character varying(40) NOT NULL,
    "Notes" character varying(5000) NOT NULL,
    "ReportsTo" character varying(200) NOT NULL,
    "PhotoPath" character varying(200) NOT NULL,
    PRIMARY KEY ("EmployeeId")
);
CREATE TABLE public.liquor_sales
(
    "FactId" character varying NOT NULL,
    "CustomerId" character varying NOT NULL,
    "EmployeeId" integer NOT NULL,
    "LocationId" character varying NOT NULL,
    "TimeId" integer NOT NULL,
    "RequiredDate" character varying(200) NOT NULL,
    "ShippedDate" character varying(200) NOT NULL,
    "ShipVia" integer NOT NULL,
    "Freight" character varying NOT NULL,
    "ProductId" integer NOT NULL,
    "UnitPrice" numeric NOT NULL,
    "Quantity" integer NOT NULL,
    "Discount" double precision NOT NULL,
    PRIMARY KEY ("FactId")
);

CREATE TABLE public.dim_product
(
    "ProducId" integer NOT NULL,
    "Nombre_Producto" character varying(100) NOT NULL,
    "QuantityPerUnit" character varying(200) NOT NULL,
    "UnitPrice" numeric NOT NULL,
    "UnitsInStock" integer NOT NULL,
    "UnitsOnOrder" integer NOT NULL,
    "ReorderLevel" integer NOT NULL,
    "Discontinued" integer NOT NULL,
    "Categoria" character varying(200) NOT NULL,
    "Proveedor" character varying(200) NOT NULL,
    "Nombre_Contacto" character varying(200) NOT NULL,
    "City_Proveedor" character varying(200) NOT NULL,
    PRIMARY KEY ("ProducId")
);
CREATE TABLE public.dim_shipper
(
    "ShipperId" integer NOT NULL,
    "CompanyName" character varying(200) NOT NULL,
    "Phone" character varying(200) NOT NULL,
    PRIMARY KEY ("ShipperId")
);

ALTER TABLE IF EXISTS public.liquor_sales
    ADD CONSTRAINT "fk_customerId" FOREIGN KEY ("CustomerId")
    REFERENCES public.dim_customer ("CustomerId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
ALTER TABLE IF EXISTS public.liquor_sales
    ADD CONSTRAINT "fk_employeeId" FOREIGN KEY ("EmployeeId")
    REFERENCES public.dim_employee ("EmployeeId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
ALTER TABLE IF EXISTS public.liquor_sales
    ADD CONSTRAINT fk_location FOREIGN KEY ("LocationId")
    REFERENCES public.dim_location ("LocationId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
ALTER TABLE IF EXISTS public.liquor_sales
    ADD CONSTRAINT "fk_timeId" FOREIGN KEY ("TimeId")
    REFERENCES public.dim_time (date_dim_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
ALTER TABLE IF EXISTS public.liquor_sales
    ADD CONSTRAINT "fk_shipviaId" FOREIGN KEY ("ShipVia")
    REFERENCES public.dim_shipper ("ShipperId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
ALTER TABLE IF EXISTS public.liquor_sales
    ADD CONSTRAINT "fk_productId" FOREIGN KEY ("ProductId")
    REFERENCES public.dim_product ("ProducId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;