--
-- https://d3js.org/
--
-- API:
-- Let wc_d3charts.m_d3_clicked = FUNCTION <your click function>    This is optional
-- Call wc_d3_init
-- Call wc_d3_setData passing an array of type t_d3_rec to supply the data
--
-- NOTE: Your 'click' function must take one arg of type SMALLINT, this is the item number clicked on.

IMPORT util

PUBLIC DEFINE m_d3_wc STRING
PUBLIC TYPE t_d3_rec RECORD
  labs STRING,
  vals STRING,
  action_name STRING
END RECORD
PUBLIC TYPE t_d3_clicked FUNCTION(x SMALLINT)

PUBLIC DEFINE m_d3_clicked t_d3_clicked
PUBLIC DEFINE m_title, m_x_label, m_y_label STRING

DEFINE m_d3_arr DYNAMIC ARRAY OF t_d3_rec
DEFINE m_height, m_width SMALLINT

--------------------------------------------------------------------------------
-- Set up the click handler function
FUNCTION wc_d3_init(l_w SMALLINT, l_h SMALLINT, l_titl STRING)
  LET m_height = l_h
  LET m_width = l_w
  LET m_title = l_titl
  IF m_d3_clicked IS NULL THEN
    LET m_d3_clicked = FUNCTION dummyClick
  END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION wc_d3_setData(l_d3_arr DYNAMIC ARRAY OF t_d3_rec)
  LET m_d3_arr = l_d3_arr
  LET m_d3_wc = arrToJsonStr()
END FUNCTION
--------------------------------------------------------------------------------
DIALOG d3_wc() INPUT BY NAME m_d3_wc ATTRIBUTE(WITHOUT DEFAULTS)
-- Handle clicking on the month / first 12 bars!
  ON ACTION item1
    CALL m_d3_clicked(1)
  ON ACTION item2
    CALL m_d3_clicked(2)
  ON ACTION item3
    CALL m_d3_clicked(3)
  ON ACTION item4
    CALL m_d3_clicked(4)
  ON ACTION item5
    CALL m_d3_clicked(5)
  ON ACTION item6
    CALL m_d3_clicked(6)
  ON ACTION item7
    CALL m_d3_clicked(7)
  ON ACTION item8
    CALL m_d3_clicked(8)
  ON ACTION item9
    CALL m_d3_clicked(9)
  ON ACTION item10
    CALL m_d3_clicked(10)
  ON ACTION item11
    CALL m_d3_clicked(11)
  ON ACTION item12
    CALL m_d3_clicked(12)
  ON ACTION back
    CALL m_d3_clicked(0)
END INPUT
END DIALOG
--------------------------------------------------------------------------------
-- Convert the data arr to a json string
PRIVATE FUNCTION arrToJsonStr()
  DEFINE l_data, l_jo util.JSONObject
  DEFINE l_ja util.JSONArray
  DEFINE x SMALLINT
  DEFINE l_max SMALLINT

  LET l_ja = util.JSONArray.create()
  FOR x = 1 TO m_d3_arr.getLength()
    LET l_jo = util.JSONObject.create()

    CALL l_jo.put("name", NVL(m_d3_arr[x].labs.subString(1, 3), x))
    CALL l_jo.put("value", m_d3_arr[x].vals)
    CALL l_jo.put("action", m_d3_arr[x].action_name)
    CALL l_jo.put("fill", IIF(x MOD 2, "steelblue", "royalblue"))
    CALL l_ja.put(x, l_jo)
    IF m_d3_arr[x].vals > l_max THEN
      LET l_max = m_d3_arr[x].vals
    END IF
  END FOR

  LET l_data = util.JSONObject.create() -- Root
  CALL l_data.put("width", m_width)
  CALL l_data.put("heigth", m_height)
  CALL l_data.put("title", m_title)
  CALL l_data.put("x_label", m_x_label)
  CALL l_data.put("y_label", m_y_label)
  CALL l_data.put("max_value", l_max)
  CALL l_data.put("data", l_ja)

  DISPLAY "JSONData:", l_data.toString()
  RETURN l_data.toString()
END FUNCTION
--------------------------------------------------------------------------------
-- dummy click handler, used if one is not defined by calling program
PRIVATE FUNCTION dummyClick(x SMALLINT)
  MESSAGE "Clicked: ", x
END FUNCTION
