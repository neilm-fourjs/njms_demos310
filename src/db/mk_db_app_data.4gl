#+ Insert the demo application data.

IMPORT util
IMPORT os
IMPORT FGL g2_db
&include "schema.inc"

DEFINE m_ordHead RECORD LIKE ord_head.*
DEFINE m_ordDet RECORD LIKE ord_detail.*
DEFINE m_cust RECORD LIKE customer.*

CONSTANT MAX_ORDERS = 50
CONSTANT MAX_QUOTES = 50
CONSTANT MAX_LINES = 20
CONSTANT MAX_QTY = 25

DEFINE m_bc_cnt, m_prod_key INTEGER

---------------------------------------------------
FUNCTION insert_app_data()
	DEFINE l_jcust DYNAMIC ARRAY OF RECORD
		name STRING,
		email STRING,
		addr STRING,
		city STRING,
		county STRING,
		postcode STRING,
		phone STRING,
		contact STRING
	END RECORD
	DEFINE l_cust RECORD LIKE customer.*
	DEFINE l_add RECORD LIKE addresses.*
	DEFINE l_jsonData TEXT
	DEFINE x SMALLINT

  CALL mkdb_progress("Inserting test customer data...")
	LOCATE l_jsonData IN MEMORY
	CALL l_jsonData.readFile("../etc/customers.json")
  CALL util.JSON.parse( l_jsonData, l_jcust )

	LET l_add.country_code = "GBR"
	FOR x = 1 TO l_jcust.getLength()
		LET l_add.rec_key = 0
		LET l_add.line1 = l_jcust[x].addr
		LET l_add.line2 = l_jcust[x].city
		--LET l_add.line3 =
		LET l_add.postal_code = l_jcust[x].postcode
		INSERT INTO addresses VALUES l_add.*
		LET l_add.rec_key = SQLCA.sqlerrd[2]
		LET l_cust.contact_name = l_jcust[x].contact
		LET l_cust.credit_limit = 1000
		LET l_cust.customer_code = "C"||(x USING "&&&&")
		LET l_cust.customer_name = l_jcust[x].name
		LET l_cust.del_addr = l_add.rec_key
		LET l_cust.inv_addr = l_add.rec_key
		LET l_cust.disc_code = "AA"
		LET l_cust.email = l_jcust[x].email
		LET l_cust.outstanding_amount = 0
		LET l_cust.total_invoices = util.Math.rand(10000)
		INSERT INTO customer VALUES l_cust.*
	END FOR


  CALL mkdb_progress("Inserting test stock data...")

  LET m_bc_cnt = 124212
  LET m_prod_key = 1
  CALL insStock("FR01", NULL, "An Apple", NULL, 0.20, "AA", NULL)
  CALL insStock("FR01-10", NULL, "An Apple x 10", NULL, 1.90, "AA", NULL)
  CALL insStock("FR02", NULL, "A Bannana", NULL, 0.30, "AA", NULL)
  CALL insStock("FR02-5", NULL, "A Bunch of Bannanas(5)", NULL, 1.0, "AA", NULL)
  CALL insStock("FR03", NULL, "A Peach", NULL, 0.30, "AA", NULL)
  CALL insStock("FR03-10", NULL, "A Peach x 10", NULL, 1.95, "AA", NULL)

  CALL insStock("GM01", NULL, "Poker Chips", NULL, 19.99, "AA", NULL)
  CALL insStock("GM02", NULL, "Playing Cards - Cheap", NULL, .99, "AA", NULL)
  CALL insStock("GM03-R", NULL, "Playing Cards - Bicycle Red", NULL, 1.99, "AA", NULL)
  CALL insStock("GM03-B", NULL, "Playing Cards - Bicycle Blue", NULL, 1.99, "AA", NULL)
  CALL insStock("GM05", NULL, "Poker Dice", NULL, 2.49, "AA", NULL)
  CALL insStock("GM06", NULL, "Card Mat - Green", NULL, 1.49, "AA", NULL)

  CALL insPackItem("GM04", "GM01", 1)
  CALL insPackItem("GM04", "GM03-R", 1)
  CALL insPackItem("GM04", "GM03-B", 1)
  CALL insPackItem("GM04", "GM05", 1)
  CALL insPackItem("GM04", "GM06", 1)
  CALL insStock("GM04", "E", "Poker Set", NULL, 25.99, "AA", NULL)

  CALL insStock("ST15", NULL, "Artist Sketch Pad", NULL, 2.49, "AA", NULL)
  CALL insStock("ST16", NULL, "5 Pencils HB-B4", NULL, 3.49, "AA", NULL)
  CALL insStock("ST17", NULL, "5 Pencils H4-HB", NULL, 3.49, "AA", NULL)
  CALL insStock("ST18", NULL, "Artists Eraser", NULL, 1.49, "AA", NULL)

  CALL insPackItem("ST19", "ST15", 2)
  CALL insPackItem("ST19", "ST16", 1)
  CALL insPackItem("ST19", "ST17", 1)
  CALL insPackItem("ST19", "ST18", 2)
  CALL insStock("ST19", "P", "Artists Starter Pack", NULL, 12.99, "AA", NULL)

  CALL insStock("ST13", NULL, "Calculator", NULL, 9.99, "CC", NULL)
  CALL insStock("ST02-10", NULL, "Envelope x 10", NULL, 2.25, "CC", NULL)
  CALL insStock("ST01", NULL, "A4 Paper x 500", NULL, 9.99, "CC", NULL)
  CALL insStock("ST03-BK", NULL, "Bic Ball Point - Black", NULL, .49, "CC", NULL)
  CALL insStock("ST03-BL", NULL, "Bic Ball Point - Blue", NULL, .49, "CC", NULL)
  CALL insStock("ST03-RD", NULL, "Bic Ball Point - Red", NULL, .49, "CC", NULL)
  CALL insStock("ST14", NULL, "Tissues", NULL, 1.49, "BB", NULL)

  CALL insStock("WW47", NULL, "AK47", NULL, 789.99, "DD", NULL)
  CALL insStock("WW10", NULL, "Flame Thrower", NULL, 1229.99, "DD", NULL)
  CALL insStock("WW01-DES", NULL, "Combat Jacket - Desert", NULL, 59.99, "DD", NULL)
  CALL insStock("WW01-JUN", NULL, "Combat Jacket - Jungle", NULL, 59.99, "DD", NULL)

  CALL genStock("../pics/products", "??", FALSE)

  INSERT INTO stock_cat VALUES('ART', 'Office Decor')
  INSERT INTO stock_cat VALUES('ENTERTAIN', 'Entertainment')
  INSERT INTO stock_cat VALUES('FURNITURE', 'Furniture')
  INSERT INTO stock_cat VALUES('TRAVELLING', 'Travelling')
--	INSERT INTO stock_cat VALUES ('HOUSEHOLD', 'House Hold')
  INSERT INTO stock_cat VALUES('SUPPLIES', 'Supplies')
  INSERT INTO stock_cat VALUES('FRUIT', 'Fruit')
  INSERT INTO stock_cat VALUES('ARMY', 'WWIII Supplies')
  INSERT INTO stock_cat VALUES('GAMES', 'Games/Toys')
  INSERT INTO stock_cat VALUES('SPORTS', 'Sporting Goods')

  INSERT INTO disc VALUES("AA", "AA", 2.5)
  INSERT INTO disc VALUES("AA", "BB", 5)
  INSERT INTO disc VALUES("AA", "CC", 10)
  INSERT INTO disc VALUES("AA", "DD", 10.25)
  INSERT INTO disc VALUES("BB", "AA", 2)
  INSERT INTO disc VALUES("BB", "BB", 2.5)
  INSERT INTO disc VALUES("BB", "CC", 4)
  INSERT INTO disc VALUES("BB", "DD", 4.25)
  INSERT INTO disc VALUES("CC", "AA", 1.5)
  INSERT INTO disc VALUES("CC", "BB", 3)
  INSERT INTO disc VALUES("CC", "CC", 15)
  INSERT INTO disc VALUES("CC", "DD", 15.25)
  INSERT INTO disc VALUES("DD", "AA", 1.25)
  INSERT INTO disc VALUES("DD", "BB", 1.35)
  INSERT INTO disc VALUES("DD", "CC", 1.45)
  INSERT INTO disc VALUES("DD", "DD", 1.55)

	CALL insColours()
  CALL insSupp()

  CALL genQuotes()

  CALL genOrders()

  CALL mkdb_progress("Done.")
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION insStock(
    l_sc CHAR(8),
    l_pack CHAR(1),
    l_ds CHAR(30),
    l_cat CHAR(10),
    l_pr DECIMAL(12, 2),
    l_dc CHAR(2),
    l_img VARCHAR(100))

  DEFINE
    l_bc CHAR(13),
    l_cst DECIMAL(12, 2),
    l_sup CHAR(10),
    l_tc CHAR(1)

  DEFINE l_ps, l_al, l_fr INTEGER --physical/allocated/free

  LET l_tc = "1"
  IF l_cat IS NULL THEN
    IF l_sc[1, 2] = "FR" THEN
      LET l_cat = "FRUIT"
      LET l_sup = getSupp(l_cat)
      LET l_tc = "0"
      LET l_dc = "AA"
    END IF
    IF l_sc[1, 2] = "ST" THEN
      LET l_cat = "SUPPLIES"
      LET l_sup = getSupp(l_cat)
    END IF
    IF l_sc[1, 2] = "WW" THEN
      LET l_cat = "ARMY"
      LET l_sup = getSupp(l_cat)
      LET l_tc = "3"
      LET l_dc = "CC"
    END IF
    IF l_sc[1, 2] = "HH" THEN
      LET l_cat = "HOUSEHOLD"
      LET l_sup = getSupp(l_cat)
    END IF
    IF l_sc[1, 2] = "GM" THEN
      LET l_cat = "GAMES"
      LET l_sup = getSupp(l_cat)
      LET l_dc = "BB"
    END IF
  END IF

  IF l_sc IS NULL THEN
    LET l_sc = l_cat[1, 2] || (m_prod_key USING "&&&&&&")
    LET m_prod_key = m_prod_key + 1
  END IF

  LET l_bc = genBarCode(l_cat)

  IF l_pack = "P" THEN
    SELECT MIN(physical_stock)
        INTO l_ps
        FROM pack_items p, stock s
        WHERE pack_code = l_sc AND p.stock_code = s.stock_code
    SELECT MAX(allocated_stock)
        INTO l_al
        FROM pack_items p, stock s
        WHERE pack_code = l_sc AND p.stock_code = s.stock_code
  ELSE
    LET l_ps = util.math.rand(200)
    LET l_al = util.math.rand(50)
  END IF
  IF l_pr = 0 THEN
    LET l_pr = util.math.rand(10) + (100 / util.math.rand(10))
  END IF
  LET l_ps = l_ps + 50
  LET l_fr = l_ps - l_al
  LET l_cst = (l_pr * 0.75)
  DISPLAY l_sc, "-", l_bc, "-", l_ds, " ps:", l_ps, " al:", l_al, " fr:", l_fr
  IF l_img IS NULL THEN
    LET l_img = downshift(l_sc CLIPPED)
  END IF
  INSERT INTO stock
      VALUES(l_sc,
          l_cat,
          l_pack,
          l_sup,
          l_bc,
          l_ds,
          l_pr,
          l_cst,
          l_tc,
          l_dc,
          l_ps,
          l_al,
          l_fr,
          "",
          l_img)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION insPackItem(l_pc, l_sc, l_qty)
  DEFINE
    l_pc, l_sc CHAR(8),
    l_qty SMALLINT,
    l_pr, l_cst DECIMAL(12, 2),
    l_tc CHAR(1),
    l_dc CHAR(2)
  SELECT price, cost, tax_code, disc_code
      INTO l_pr, l_cst, l_tc, l_dc
      FROM stock
      WHERE stock_code = l_sc
  INSERT INTO pack_items VALUES(l_pc, l_sc, l_qty, l_pr, l_cst, l_tc, l_dc)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION insSupp()
  DEFINE sup CHAR(10)
  DEFINE supname CHAR(20)

  DECLARE sup_cur CURSOR FOR SELECT UNIQUE supp_code FROM stock ORDER BY supp_code
  FOREACH sup_cur INTO sup
    LET supname = "Supplier " || sup
    INSERT INTO supplier
        VALUES(sup, supname, "DC", "al1", "al2", "al3", "al4", "al5", "pc", "tel", "email")
  END FOREACH

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getSupp(l_cat)
  DEFINE l_cat CHAR(10)

  CASE l_cat
    WHEN "FRUIT"
      RETURN "GRO"
    WHEN "SUPPLIES"
      RETURN "SS"
    WHEN "ARMY"
      RETURN "USGOV"
    WHEN "HOUSEHOLD"
      RETURN "HHINC"
    WHEN "GAMES"
      RETURN "GRO"
    WHEN "ART"
      RETURN "GRO"
    WHEN "ENTERTAIN"
      RETURN "GRO"
    WHEN "FURNITURE"
      RETURN "FCB"
    WHEN "TRAVELLING"
      RETURN "TC"
    OTHERWISE
      RETURN "UNK"
  END CASE

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION discCode()
  DEFINE l_dc CHAR(2)
  CASE util.math.rand(5)
    WHEN 1
      LET l_dc = "AA"
    WHEN 2
      LET l_dc = "BB"
    WHEN 3
      LET l_dc = "CC"
    WHEN 4
      LET l_dc = "DD"
    OTHERWISE
      LET l_dc = "??"
  END CASE
  RETURN l_dc
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION genBarCode(l_cat CHAR(10)) RETURNS CHAR(13)
  DEFINE l_bc CHAR(13)
  DEFINE x SMALLINT

  CASE l_cat
    WHEN "SPORT"
      LET l_bc = "060"
    WHEN "FRUIT"
      LET l_bc = "061"
    WHEN "SUPPLIES"
      LET l_bc = "062"
    WHEN "ARMY"
      LET l_bc = "063"
    WHEN "HOUSEHOLD"
      LET l_bc = "063"
    WHEN "GAMES"
      LET l_bc = "064"
    WHEN "ART"
      LET l_bc = "065"
    WHEN "ENTERTAIN"
      LET l_bc = "066"
    WHEN "FURNITURE"
      LET l_bc = "067"
    WHEN "TRAVELLING"
      LET l_bc = "068"
    OTHERWISE
      LET l_bc = "069"
  END CASE
  LET l_bc[4, 11] = m_bc_cnt USING "&&&&&&&&"
  LET m_bc_cnt = m_bc_cnt + 1

  LET x = l_bc[1] + l_bc[3] + l_bc[5] + l_bc[7] + l_bc[9] + l_bc[11]
  LET x = x * 3
  LET x = x + l_bc[2] + l_bc[4] + l_bc[6] + l_bc[8] + l_bc[10]
  LET x = (x MOD 10)
  IF x != 0 THEN
    LET x = 10 - x
  END IF
  LET l_bc[12] = x

  RETURN l_bc
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION genOrders()
  DEFINE cst DYNAMIC ARRAY OF VARCHAR(8)
  DEFINE stk DYNAMIC ARRAY OF VARCHAR(8)
  DEFINE dets DYNAMIC ARRAY OF RECORD
    sc CHAR(8),
    qt SMALLINT
  END RECORD
  DEFINE z, x, y, q, c, s, l SMALLINT
  DEFINE dte DATE

  DECLARE cstcur CURSOR FOR SELECT customer_code FROM customer
  DECLARE stkcur CURSOR FOR SELECT stock_code FROM stock
  FOREACH cstcur INTO cst[cst.getLength() + 1]
  END FOREACH
  FOREACH stkcur INTO stk[stk.getLength() + 1]
  END FOREACH
  CALL cst.deleteElement(cst.getLength())
  CALL stk.deleteElement(stk.getLength())

  CALL mkdb_progress("Generating " || MAX_ORDERS || " Orders")
  FOR x = 1 TO MAX_ORDERS
    LET c = util.math.rand(cst.getLength())
    IF c = 0 OR c > cst.getLength() THEN
      LET c = cst.getLength()
    END IF
    LET dte = TODAY - 1825
    LET dte = dte + util.math.rand(1825)
    CALL orderHead(cst[c] CLIPPED, dte)
    LET l = util.math.rand(MAX_LINES + 1)
    CALL dets.clear()
    IF l >= stk.getLength() THEN
      LET l = stk.getLength() - 5
    END IF
    IF l < 2 THEN
      LET l = 2
    END IF
    FOR y = 1 TO l
      LET q = util.math.rand(MAX_QTY)
      IF q = 0 OR q > MAX_QTY THEN
        LET q = 5
      END IF
      --DISPLAY "Details Line:",y," of",l," qty:",q," stklen:",stk.getLength()
      WHILE TRUE -- loop till we find a stock item that hasn't already be used.
        LET s = util.math.rand(stk.getLength())
        IF s = 0 OR s > stk.getLength() THEN
          CONTINUE WHILE
        END IF
        FOR z = 1 TO dets.getLength()
          IF dets[z].sc = stk[s] THEN
            CONTINUE WHILE
          END IF
        END FOR
        EXIT WHILE
      END WHILE
      --DISPLAY "stk:",stk[s]
      LET dets[y].qt = q
      LET dets[y].sc = stk[s]
    END FOR
    FOR y = 1 TO dets.getLength()
      CALL orderDetail(dets[y].sc CLIPPED, dets[y].qt)
    END FOR
    UPDATE ord_head SET ord_head.* = m_ordHead.* WHERE order_number = m_ordHead.order_number
  END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION orderHead(cst, dte)
  DEFINE cst VARCHAR(8)
  DEFINE dte DATE
  DEFINE dt CHAR(20)
  DEFINE inv_ad, del_ad RECORD LIKE addresses.*

  SELECT * INTO m_cust.* FROM customer WHERE customer_code = cst
  SELECT * INTO del_ad.* FROM addresses WHERE rec_key = m_cust.del_addr
  SELECT * INTO inv_ad.* FROM addresses WHERE rec_key = m_cust.inv_addr
  LET m_ordHead.customer_code = cst
  LET m_ordHead.customer_name = m_cust.customer_name
  LET m_ordHead.del_address1 = del_ad.line1
  LET m_ordHead.del_address2 = del_ad.line2
  LET m_ordHead.del_address3 = del_ad.line3
  LET m_ordHead.del_address4 = del_ad.line4
  LET m_ordHead.del_address5 = del_ad.line5
  LET m_ordHead.del_postcode = del_ad.postal_code
  LET m_ordHead.inv_address1 = inv_ad.line1
  LET m_ordHead.inv_address2 = inv_ad.line2
  LET m_ordHead.inv_address3 = inv_ad.line3
  LET m_ordHead.inv_address4 = inv_ad.line4
  LET m_ordHead.inv_address5 = inv_ad.line5
  LET m_ordHead.inv_postcode = inv_ad.postal_code
  LET m_ordHead.items = 0
  LET m_ordHead.total_qty = 0
  LET m_ordHead.total_disc = 0
  LET m_ordHead.total_gross = 0
  LET m_ordHead.total_nett = 0
  LET m_ordHead.total_tax = 0

  LET dt = dte USING "YYYY-MM-DD"
  LET m_ordHead.order_date = dte
  LET m_ordHead.order_datetime = dte
  LET m_ordHead.req_del_date = (dte + 10)
  LET m_ordHead.username = "auto"
  LET m_ordHead.order_ref = "Auto Generated " || m_ordHead.order_number || " " || TODAY
  INSERT INTO ord_head VALUES m_ordHead.*
  LET m_ordHead.order_number = SQLCA.SQLERRD[2] -- Fetch SERIAL order num
  DISPLAY "Order Head:", m_ordHead.order_number, ":", cst, " ", dte
  LET m_ordDet.line_number = 0
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION orderDetail(stk, q)
  DEFINE stk CHAR(8)
  DEFINE q SMALLINT
  DEFINE stkrec RECORD LIKE stock.*
  DEFINE tax_rate DECIMAL(5, 2)
  DEFINE pflag CHAR(1)

  LET tax_rate = 17.5
  SELECT price, tax_code, disc_code, pack_flag
      INTO stkrec.price, stkrec.tax_code, stkrec.disc_code, pflag
      FROM stock
      WHERE stock_code = stk
  IF STATUS = NOTFOUND THEN
    DISPLAY "NOT FOUND STOCK ITEM '", stk, "'"
    RETURN
  END IF
  SELECT disc_percent
      INTO m_ordDet.disc_percent
      FROM disc
      WHERE stock_disc = stkrec.disc_code AND customer_disc = m_cust.disc_code
  IF STATUS = NOTFOUND THEN
    LET m_ordDet.disc_percent = 0
  END IF
  --DISPLAY "DETAIL LINE:",stk," QTY:",q
  LET m_ordDet.order_number = m_ordHead.order_number
  LET m_ordDet.line_number = m_ordDet.line_number + 1
  LET m_ordDet.price = stkrec.price
  LET m_ordDet.tax_code = stkrec.tax_code
  IF m_ordDet.tax_code = "1" THEN
    LET m_ordDet.tax_rate = tax_rate
  ELSE
    LET m_ordDet.tax_rate = 0
  END IF
  LET m_ordDet.quantity = q
  LET m_ordDet.stock_code = stk
  IF pflag = "E" THEN
    LET pflag = "P"
  END IF
  LET m_ordDet.pack_flag = pflag

  CALL oe_calcLineTot()

  INSERT INTO ord_detail VALUES(m_ordDet.*)

  LET m_ordHead.items = m_ordHead.items + 1
  LET m_ordHead.total_gross = m_ordHead.total_gross + m_ordDet.gross_value
  LET m_ordHead.total_nett = m_ordHead.total_nett + m_ordDet.nett_value
  LET m_ordHead.total_qty = m_ordHead.total_qty + m_ordDet.quantity
  LET m_ordHead.total_disc = m_ordHead.total_disc + m_ordDet.disc_value
  LET m_ordHead.total_tax = m_ordHead.total_tax + m_ordDet.tax_value

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION oe_calcLineTot()

  IF m_ordDet.price IS NULL THEN
    LET m_ordDet.price = 0
  END IF
  IF m_ordDet.quantity IS NULL THEN
    LET m_ordDet.quantity = 0
  END IF
  IF m_ordDet.disc_percent IS NULL THEN
    LET m_ordDet.disc_percent = 0
  END IF
  IF m_ordDet.tax_rate IS NULL THEN
    LET m_ordDet.tax_rate = 0
  END IF

  LET m_ordDet.gross_value = m_ordDet.price * m_ordDet.quantity
  LET m_ordDet.disc_value = m_ordDet.gross_value * (m_ordDet.disc_percent / 100)
  LET m_ordDet.nett_value = m_ordDet.gross_value - m_ordDet.disc_value
  LET m_ordDet.tax_value = m_ordDet.nett_value * (m_ordDet.tax_rate / 100)
  LET m_ordDet.nett_value = m_ordDet.nett_value + m_ordDet.tax_value

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION genStock(l_base STRING, l_cat STRING, l_process BOOLEAN)
  DEFINE l_ext, l_path, l_dir, l_desc STRING
  DEFINE l_d INT
  DEFINE l_nam STRING

  DISPLAY "---------------Generating Stock from ", l_base, " Cat:", l_cat

  CALL os.Path.dirSort("name", 1)
  LET l_d = os.Path.dirOpen(l_base)
  IF l_d > 0 THEN
    WHILE TRUE
      LET l_path = os.Path.dirNext(l_d)
      IF l_path IS NULL THEN
        EXIT WHILE
      END IF
      LET l_dir = os.path.baseName(l_base)
      --DISPLAY "Path:",l_path," Dir:", os.path.isDirectory(os.path.join(l_base,l_path))
      IF os.path.isDirectory(os.path.join(l_base, l_path)) THEN
        IF l_path != "." AND l_path != ".." THEN
          CASE l_path
            WHEN "supplies"
              LET l_cat = "SUPPLIES"
            WHEN "art"
              LET l_cat = "ART"
            WHEN "entertainment"
              LET l_cat = "ENTERTAIN"
            WHEN "furniture"
              LET l_cat = "FURNITURE"
            WHEN "travelling"
              LET l_cat = "TRAVELLING"
            OTHERWISE
              LET l_cat = "??"
          END CASE
          DISPLAY "DIR --    Path:", l_path, " Cat:", l_cat
          CALL genStock(os.path.join(l_base, l_path), l_cat, TRUE)
        END IF
        CONTINUE WHILE
      ELSE
        IF l_process THEN
          LET l_ext = os.path.extension(l_path)
          IF l_ext IS NULL OR (l_ext != "jpg" AND l_ext != "png") THEN
            CONTINUE WHILE
          END IF
          LET l_nam = os.path.rootName(l_path)
          LET l_desc = tidy_name(l_nam)
          DISPLAY "Path:", l_path, " Cat:", l_cat, " Name:", l_nam, " Ext:", l_ext
          CALL insStock(NULL, NULL, l_desc, l_cat, 0, "CC", os.path.join(l_dir, l_nam))
        END IF
      END IF
    END WHILE
  END IF
  DISPLAY "---------------END"
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION tidy_name(l_nam STRING) RETURNS STRING
  DEFINE l_st base.StringTokenizer
  DEFINE l_word CHAR(100)
  LET l_st = base.StringTokenizer.create(l_nam, "-")
  LET l_nam = ""
  WHILE l_st.hasMoreTokens()
    LET l_word = l_st.nextToken()
    LET l_word[1] = upshift(l_word[1])
    LET l_nam = l_nam.append(l_word CLIPPED || " ")
  END WHILE
  RETURN l_nam.trim()
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION insColours()
	DEFINE c base.Channel
	DEFINE l_col RECORD LIKE colours.*
	DEFINE l_cnt SMALLINT
	DELETE FROM colours
  CALL mkdb_progress("Loading Colours ...")
	LET c = base.Channel.create()
	CALL c.openFile("../etc/colour_names.txt","r")
	WHILE NOT c.isEof()
		IF c.read( [ l_col.* ] ) THEN
			INSERT INTO colours VALUES l_col.*
		END IF
	END WHILE
	CALL C.close()
	SELECT COUNT(*) INTO l_cnt FROM colours
  CALL mkdb_progress(SFMT("Loaded %1 Colours.", l_cnt ) )
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION genQuotes()
  DEFINE l_cst DYNAMIC ARRAY OF VARCHAR(8)
  DEFINE l_stk DYNAMIC ARRAY OF VARCHAR(8)
  DEFINE l_dets DYNAMIC ARRAY OF RECORD
    sc CHAR(8),
    qt SMALLINT
  END RECORD
	DEFINE l_quote RECORD LIKE quotes.*
	DEFINE l_quote_det RECORD LIKE quote_detail.*
  DEFINE z, x, y, q, c, s, l, l_colrs, l_users SMALLINT
  DEFINE l_dte DATE

	SELECT COUNT(*) INTO l_colrs FROM colours
	SELECT COUNT(*) INTO l_users FROM sys_users

  DECLARE qcstcur CURSOR FOR SELECT customer_code FROM customer
  DECLARE qstkcur CURSOR FOR SELECT stock_code FROM stock
  FOREACH qcstcur INTO l_cst[l_cst.getLength() + 1]
  END FOREACH
  FOREACH qstkcur INTO l_stk[l_stk.getLength() + 1]
  END FOREACH
  CALL l_cst.deleteElement(l_cst.getLength())
  CALL l_stk.deleteElement(l_stk.getLength())

  CALL mkdb_progress("Generating " || MAX_QUOTES || " Quotes")
  FOR x = 1 TO MAX_ORDERS
		INITIALIZE l_quote.* TO NULL
		LET l_quote.revision = 1
    LET c = util.math.rand(l_cst.getLength())
    IF c = 0 OR c > l_cst.getLength() THEN
      LET c = l_cst.getLength()
    END IF
    LET l_dte = TODAY - 182
    LET l_dte = l_dte + util.math.rand(182)
		CASE  util.math.rand(5)
			WHEN 1 LET l_quote.status = "W"
			WHEN 2 LET l_quote.status = "R" LET l_quote.revision = 2
			OTHERWISE LET l_quote.status = "Q"
		END CASE
		LET l_quote.quote_number = 0
		LET l_quote.quote_ref = "GenQ"||(x USING "&&&")
		LET l_quote.raised_by =  util.math.rand(l_users-1)+1
		LET l_quote.customer_code = l_cst[c]
		LET l_quote.expiration_date = l_dte+60
		LET l_quote.account_manager =  util.math.rand(l_users-1)+1
		IF l_quote.status = "W" THEN
			LET l_quote.ordered_date = l_dte+util.math.rand(30)
		END IF
		LET l_quote.quote_date = l_dte
		LET l_quote.description = "Generate "||x
		LET l_quote.project = "Test"
		LET l_quote.quote_total = 0

    LET l = util.math.rand(MAX_LINES + 1)
    CALL l_dets.clear()
    IF l >= l_stk.getLength() THEN
      LET l = l_stk.getLength() - 1
    END IF
    IF l < 2 THEN LET l = 2 END IF -- Min lines
    FOR y = 1 TO l
      LET q = util.math.rand(MAX_QTY)
      IF q = 0 OR q > MAX_QTY THEN
        LET q = 5
      END IF
      --DISPLAY "Details Line:",y," of",l," qty:",q," stklen:",stk.getLength()
      WHILE TRUE -- loop till we find a stock item that hasn't already be used.
        LET s = util.math.rand(l_stk.getLength())
        IF s = 0 OR s > l_stk.getLength() THEN
          CONTINUE WHILE
        END IF
        FOR z = 1 TO l_dets.getLength()
          IF l_dets[z].sc = l_stk[s] THEN
            CONTINUE WHILE
          END IF
        END FOR
        EXIT WHILE
      END WHILE
      --DISPLAY "stk:",stk[s]
      LET l_dets[y].qt = q
      LET l_dets[y].sc = l_stk[s]
    END FOR
    INSERT INTO quotes VALUES l_quote.*
		LET l_quote.quote_number = SQLCA.SQLERRD[2] -- Fetch SERIAL num
    FOR y = 1 TO l_dets.getLength()
			LET l_quote_det.quote_number =  l_quote.quote_number
			LET l_quote_det.item_num = y
			LET l_quote_det.discount = 0
			LET l_quote_det.quantity = l_dets[y].qt
			LET l_quote_det.stock_code = l_dets[y].sc
			LET l_quote_det.colour_key = util.math.rand(l_colrs-1)+1
			SELECT price INTO l_quote_det.unit_rrp
				FROM stock
				WHERE stock_code = l_quote_det.stock_code
			LET l_quote_det.unit_net = l_quote_det.unit_rrp
{
			SELECT * FROM quotes WHERE quote_number = l_quote_det.quote_number
			DISPLAY "Quote:",STATUS, ":", l_quote_det.quote_number, ":",l_quote_det.item_num
			SELECT * FROM stock WHERE stock_code = l_quote_det.stock_code
			DISPLAY "Stock:",STATUS, ":", l_quote_det.stock_code
			SELECT * FROM colours WHERE colour_key = l_quote_det.colour_key
			DISPLAY "Colour:",STATUS, ":", l_quote_det.colour_key
}
      INSERT INTO quote_detail VALUES l_quote_det.*
			LET l_quote.quote_total = l_quote.quote_total + ( l_quote_det.quantity * l_quote_det.unit_rrp )
			DISPLAY  l_quote_det.quote_number, ":", l_quote.quote_total
    END FOR
 		UPDATE quotes SET quote_total = l_quote.quote_total WHERE quote_number = l_quote.quote_number
  END FOR
END FUNCTION
