CREATE TABLE public.dim_customer
(
    "CustomerId" character varying NOT NULL,
    "CompanyName" character varying(100) NOT NULL,
    "ContactName" character varying(100) NOT NULL,
    "ContactTitle" character varying(100) NOT NULL,
    "LocationId" character varying(100) NOT NULL,
    "Address" character varying(100) NOT NULL,
    "City" character varying(100) NOT NULL,
    "Region" character varying(100) NOT NULL,
    "PostalCode" character varying(100) NOT NULL,
    "Country" character varying(100) NOT NULL,
    "Phone" character varying(100) NOT NULL,
    "Fax" character varying(100) NOT NULL,
    PRIMARY KEY ("CustomerId")
);
CREATE TABLE public.dim_location
(
    "LocationId" character varying NOT NULL,
    "Address" character varying(100) NOT NULL,
    "City" character varying(100) NOT NULL,
    "Region" character varying(100) NOT NULL,
    "PostalCode" character varying(100) NOT NULL,
    "Country" character varying(100) NOT NULL,
    PRIMARY KEY ("LocationId")
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
CREATE TABLE public.dim_product
(
    "ProductId" integer NOT NULL,
    "ProductName" character varying(100) NOT NULL,
    "SupplierId" integer NOT NULL,
    "CategoryId" integer NOT NULL,
    "QuantityPerUnit" character varying(100) NOT NULL,
    "UnitPrice" numeric NOT NULL,
    "UnitsInStock" integer NOT NULL,
    "UnitsOnOrder" integer NOT NULL,
    "ReorderLevel" integer NOT NULL,
    "Discontinued" integer NOT NULL,
    PRIMARY KEY ("ProductId")
);
CREATE TABLE public.dim_category
(
    "CategoryId" integer NOT NULL,
    "CategoryName" character varying(100) NOT NULL,
    "Description" character varying(100) NOT NULL,
    PRIMARY KEY ("CategoryId")
);

CREATE TABLE public."Fact_sales_liquor"
(
    "FactId" character varying NOT NULL,
    "CustomerId" character varying(100) NOT NULL,
    "EmployeeId" integer NOT NULL,
    "TimeId" integer NOT NULL,
    "RequiredDate" character varying(100) NOT NULL,
    "ShippedDate" character varying(100) NOT NULL,
    "ShipVia" integer NOT NULL,
    "Freight" numeric NOT NULL,
    "ProductId" integer NOT NULL,
    "UnitPrice" numeric NOT NULL,
    "Quantity" integer NOT NULL,
    "Discount" double precision NOT NULL,
    PRIMARY KEY ("FactId")
);

CREATE TABLE public.dim_shipper
(
    "ShipperId" integer NOT NULL,
    "CompanyName" character varying(100) NOT NULL,
    "Phone" character varying(20) NOT NULL,
    PRIMARY KEY ("ShipperId")
);
CREATE TABLE public.dim_supplier
(
    "SupplierId" integer NOT NULL,
    "CompanyName" character varying(100) NOT NULL,
    "ContactName" character varying(100) NOT NULL,
    "ContactTitle" character varying(100) NOT NULL,
    "Address" character varying(100) NOT NULL,
    "City" character varying(100) NOT NULL,
    "Region" character varying(100) NOT NULL,
    "PostalCode" character varying(100) NOT NULL,
    "Country" character varying(100) NOT NULL,
    "Phone" character varying(100) NOT NULL,
    "Fax" character varying(100) NOT NULL,
    "HomePage" character varying(100) NOT NULL,
    PRIMARY KEY ("SupplierId")
);
--////////////////////////////////////////////////////
-- relaciones de la tabla fact_sales_liquor
--////////////////////////////////////////////////////
-- relación entre la tabla fact y dim_customer
ALTER TABLE IF EXISTS public."Fact_sales_liquor"
    ADD CONSTRAINT "fk_customerId" FOREIGN KEY ("CustomerId")
    REFERENCES public.dim_customer ("CustomerId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
-- relación entre la tabla fact y dim_employee	
ALTER TABLE IF EXISTS public."Fact_sales_liquor"
    ADD CONSTRAINT fk_employee FOREIGN KEY ("EmployeeId")
    REFERENCES public.dim_employee ("EmployeeId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
	
-- relación entre la tabla fact y dim_shipper		
ALTER TABLE IF EXISTS public."Fact_sales_liquor"
    ADD CONSTRAINT fk_shipper FOREIGN KEY ("ShipVia")
    REFERENCES public.dim_shipper ("ShipperId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
-- relación entre la tabla fact y dim_time
ALTER TABLE IF EXISTS public."Fact_sales_liquor"
    ADD CONSTRAINT fk_time FOREIGN KEY ("TimeId")
    REFERENCES public.dim_time (date_dim_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
-- relación entre la tabla fact y dim_product
ALTER TABLE IF EXISTS public."Fact_sales_liquor"
    ADD CONSTRAINT fk_producto FOREIGN KEY ("ProductId")
    REFERENCES public.dim_product ("ProductId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
	
--////////////////////////////////////////////////////
-- relaciones de la tabla dim_product
--////////////////////////////////////////////////////

-- relacion entre la tabla dim_product y dim_category
ALTER TABLE IF EXISTS public.dim_product
    ADD CONSTRAINT fk_category FOREIGN KEY ("CategoryId")
    REFERENCES public.dim_category ("CategoryId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

-- relacion entre la tabla dim_product y dim_supplier
	
ALTER TABLE IF EXISTS public.dim_product
    ADD CONSTRAINT fk_supplier FOREIGN KEY ("SupplierId")
    REFERENCES public.dim_supplier ("SupplierId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
-- relacion entre la tabla dim_product y dim_supplier

ALTER TABLE IF EXISTS public.dim_product
    ADD CONSTRAINT fk_supplier FOREIGN KEY ("SupplierId")
    REFERENCES public.dim_supplier ("SupplierId") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
--////////////////////////////////////////////////////
-- relaciones de la tabla dim_customer
--////////////////////////////////////////////////////

-- relacion de la tabla dim customer y dim_location
ALTER TABLE IF EXISTS public.dim_customer
    ADD CONSTRAINT fk_location FOREIGN KEY ("LocationId")
    REFERENCES public.dim_location ("LocationId") MATCH SIMPLE
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
	
	
	
	
	
	
	
	
	