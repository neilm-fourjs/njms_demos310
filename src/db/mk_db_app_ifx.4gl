
IMPORT FGL g2_db

#+ Create the application database tables: Informix
--------------------------------------------------------------------------------
FUNCTION ifx_create_app_tables(l_db g2_db.dbInfo INOUT)
	CALL mkdb_progress("Creating application tables...")

	CREATE TABLE customer (
		customer_code CHAR(8),
		customer_name VARCHAR(30),
		contact_name VARCHAR(30),
		email VARCHAR(100),
		web_passwd CHAR(10),
		del_addr INTEGER,
		inv_addr INTEGER,
		disc_code CHAR(2),
		credit_limit INTEGER DEFAULT 0,
		total_invoices DECIMAL(12, 2) DEFAULT 0,
		outstanding_amount DECIMAL(12, 2) DEFAULT 0
	);
	CALL l_db.g2_addPrimaryKey( "customer", "customer_code" )
	CREATE TABLE countries(country_code CHAR(3) PRIMARY KEY, country_name CHAR(40));

	CREATE TABLE addresses(
		rec_key SERIAL,
		line1 VARCHAR(40),
		line2 VARCHAR(40),
		line3 VARCHAR(40),
		line4 VARCHAR(40),
		line5 VARCHAR(40),
		postal_code VARCHAR(8),
		country_code CHAR(3)
	);
	CALL l_db.g2_addPrimaryKey( "addresses", "rec_key" )
	CREATE INDEX addr_idx ON addresses(line2, line3);

	--EXECUTE IMMEDIATE "
	CREATE TABLE stock(
		stock_code CHAR(8),
		stock_cat CHAR(10),
		pack_flag CHAR(1),
		supp_code CHAR(10),
		barcode CHAR(13),
		description CHAR(30),
		price DECIMAL(12, 2),
		cost DECIMAL(12, 2),
		tax_code CHAR(1),
		disc_code CHAR(2),
		physical_stock INTEGER,
		allocated_stock INTEGER,
		free_stock INTEGER, -- CONSTRAINT ch_free CHECK (free_stock  >= 0)
		long_desc VARCHAR(100),
		img_url VARCHAR(100),
		UNIQUE(barcode)
	);
	CALL l_db.g2_addPrimaryKey( "stock", "stock_code" )
	IF l_db.type = "ifx" THEN
		EXECUTE IMMEDIATE "ALTER TABLE stock ADD CONSTRAINT CHECK (free_stock >= 0)"
	END IF
	CREATE INDEX stk_idx ON stock(description);

	CREATE TABLE pack_items(
		pack_code CHAR(8),
		stock_code CHAR(8),
		qty INTEGER,
		price DECIMAL(12, 2),
		cost DECIMAL(12, 2),
		tax_code CHAR(1),
		disc_code CHAR(2)
	);

	CREATE TABLE stock_cat(catid CHAR(10), cat_name CHAR(80));

	CREATE TABLE supplier(
		supp_code CHAR(10),
		supp_name CHAR(80),
		disc_code CHAR(2),
		addr_line1 VARCHAR(40),
		addr_line2 VARCHAR(40),
		addr_line3 VARCHAR(40),
		addr_line4 VARCHAR(40),
		addr_line5 VARCHAR(40),
		postal_code VARCHAR(8),
		tel CHAR(20),
		email VARCHAR(60)
	);

	CREATE TABLE disc(
		stock_disc CHAR(2),
		customer_disc CHAR(2),
		disc_percent DECIMAL(5, 2),
		PRIMARY KEY(stock_disc, customer_disc)
	);

	CREATE TABLE ord_payment(
		order_number INTEGER,
		payment_type CHAR(1),
		del_type CHAR(1),
		card_type CHAR(1),
		card_no CHAR(20),
		expires_m SMALLINT,
		expires_y SMALLINT,
		issue_no SMALLINT,
		payment_amount DECIMAL(12, 2),
		del_amount DECIMAL(6, 2)
	);

	DISPLAY "Create ord_head ..."
	CREATE TABLE ord_head (
		order_number SERIAL,
		order_datetime DATETIME YEAR TO SECOND,
		order_date DATE,
		order_ref VARCHAR(40),
		req_del_date DATE,
		customer_code VARCHAR(8),
		customer_name VARCHAR(30),
		del_address1 VARCHAR(40),
		del_address2 VARCHAR(40),
		del_address3 VARCHAR(40),
		del_address4 VARCHAR(40),
		del_address5 VARCHAR(40),
		del_postcode VARCHAR(8),
		inv_address1 VARCHAR(40),
		inv_address2 VARCHAR(40),
		inv_address3 VARCHAR(40),
		inv_address4 VARCHAR(40),
		inv_address5 VARCHAR(40),
		inv_postcode VARCHAR(8),
		username CHAR(8),
		items INTEGER,
		total_qty INTEGER,
		total_nett DECIMAL(12, 2),
		total_tax DECIMAL(12, 2),
		total_gross DECIMAL(12, 2),
		total_disc DECIMAL(12, 3)
		 );
	CALL l_db.g2_addPrimaryKey( "ord_head", "order_number" )

	DISPLAY "Create ord_detail ..."
	CREATE TABLE ord_detail (
		order_number INTEGER,
		line_number SMALLINT,
		stock_code VARCHAR(8),
		pack_flag CHAR(1),
		price DECIMAL(12, 2),
		quantity INTEGER,
		disc_percent DECIMAL(5, 2),
		disc_value DECIMAL(10, 3),
		tax_code CHAR(1),
		tax_rate DECIMAL(5, 2),
		tax_value DECIMAL(10, 2),
		nett_value DECIMAL(10, 2),
		gross_value DECIMAL(10, 2),
		PRIMARY KEY(order_number, line_number),
		FOREIGN KEY(order_number) REFERENCES ord_head(order_number)
	);

	DISPLAY "Create colours ..."
	CREATE TABLE colours (
		colour_key SERIAL,
		colour_name VARCHAR(30),
		colour_hex CHAR(7)
	)
	CALL l_db.g2_addPrimaryKey( "colours", "colour_key" )

	DISPLAY "Create quotes ..."
	CREATE TABLE quotes (
		quote_number SERIAL,
		quote_ref CHAR(10),
		revision SMALLINT,
		status CHAR(1),
		account_manager	INTEGER,
		raised_by INTEGER,
		customer_code CHAR(8),
		division INTEGER,
		quote_date DATE,
		expiration_date DATE,
		projected_date DATE,
		ordered_date DATE,
		description VARCHAR(250),
		end_user VARCHAR(50),
		project	VARCHAR(50),
		registered_project INTEGER,
		quote_total DECIMAL(10, 2)
		,FOREIGN KEY(customer_code) REFERENCES customer(customer_code)
	);
	CALL l_db.g2_addPrimaryKey( "quotes", "quote_number" )

	DISPLAY "Create quote_detail ..."
	CREATE TABLE quote_detail (
		quote_number INTEGER,
		item_num SMALLINT,
		item_group SMALLINT,
		stock_code CHAR(8),
		colour_key INTEGER,
		colour_surcharge DECIMAL(10, 2),
		quantity INTEGER,
		unit_rrp  DECIMAL(10, 2),
		unit_surcharge DECIMAL(10, 2),
		discount DECIMAL(5, 2),
		unit_net DECIMAL(10, 2),
		item_detail_net DECIMAL(10, 2)
		,PRIMARY KEY(quote_number, item_num)
		,FOREIGN KEY(quote_number) REFERENCES quotes(quote_number)
		,FOREIGN KEY(stock_code) REFERENCES stock(stock_code)
		,FOREIGN KEY(colour_key) REFERENCES colours(colour_key)
	)
	CALL mkdb_progress("Done.")
END FUNCTION
