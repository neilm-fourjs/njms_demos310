# ================================================================================================================
# GENERATED MAIN TEST
# Using Genero Ghost Client 1.10.08-201802011654
# ================================================================================================================

&include "GGCTestUtilsMacro.4gl"

IMPORT FGL GGCTestUtils

DEFINE ggcStartTimeStamp     DATETIME YEAR TO SECOND

MAIN
    DEFINE args DYNAMIC ARRAY OF STRING
    DEFINE i INTEGER

    FOR i = 1 TO  NUM_ARGS()
        LET args[i] = ARG_VAL(i)
    END FOR

    LET ggcStartTimeStamp = CURRENT
    CALL GGCTestUtils.createSession("menu", args)
    CALL menu_test()

    CALL GGCTestUtils.finishSession()
    CALL GGCTestUtils.printSummary()
    IF GGCTestUtils.getErrorCount() > 0 THEN
        EXIT PROGRAM 1
    END IF
END MAIN


FUNCTION menu_test()
    --Initialize your test session here

    -- Frontend Call:
    -- FunctionCall 101 (name = "feinfo", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 102 (dataType = "STRING", value = "ostype", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="LINUX" ></FunctionCallReturn></FunctionCallEvent>
    -- Frontend Call:
    -- FunctionCall 106 (name = "feinfo", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 107 (dataType = "STRING", value = "osversion", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="Linux #36-Ubuntu SMP Wed Aug 15 16:00:05 UTC 2018" ></FunctionCallReturn></FunctionCallEvent>
    -- Frontend Call:
    -- FunctionCall 102 (name = "feinfo", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 101 (dataType = "STRING", value = "screenresolution", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="1920x1080" ></FunctionCallReturn></FunctionCallEvent>
    -- Frontend Call:
    -- FunctionCall 107 (name = "feinfo", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 106 (dataType = "STRING", value = "fepath", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="/opt/fourjs/gdc-3.10.18/bin" ></FunctionCallReturn></FunctionCallEvent>
    -- Frontend Call:
    -- FunctionCall 279 (name = "getenv", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 280 (dataType = "STRING", value = "USERNAME", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="" ></FunctionCallReturn></FunctionCallEvent>
    -- Frontend Call:
    -- FunctionCall 100 (name = "getenv", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 99 (dataType = "STRING", value = "LOGNAME", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="neilm" ></FunctionCallReturn></FunctionCallEvent>
    -- Frontend Call:
    -- FunctionCall 99 (name = "getItem", returnCount = "1", isSystem = "0", moduleName = "localStorage", paramCount = "1") {
    --   FunctionCallParameter 100 (dataType = "STRING", value = "NJMDEMOSESSION", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="1" dataType="STRING" isNull="1" value="" ></FunctionCallReturn></FunctionCallEvent>



    WAIT_FOR_APPLICATION("app_13005", 3901)
    ASSERT_EQUALS(getWindowName(), "NJM's Demos_3.1c")
    ASSERT_EQUALS(getWindowTitle(), "NJM's Demos-3.1c Login")
    ASSERT_EQUALS(getFormName(), "login")
    ASSERT_EQUALS(getFormTitle(), "NJM's Demos-3.1c Login")
    ASSERT_EQUALS(getFocused(), "formonly.l_login")
    -- DialogType:Input
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("acct_new"))
    ASSERT(getActionActive("forgotten"))
    ASSERT(getActionActive("testlogin")) --Test Login
    ASSERT(getActionActive("about")) --About
    ASSERT_EQUALS(getFieldValue("formonly.m_logo_image"), "logo_dark") --STRING
    ASSERT_EQUALS(getFieldValue("formonly.l_login"), "") --STRING
    ASSERT_EQUALS(getFieldValue("formonly.l_pass"), "") --STRING
    ASSERT_NULL(getFieldValue("formonly.l_pass1")) --null
    ASSERT_NULL(getFieldValue("formonly.l_pass2")) --null
    ASSERT_NULL(getFieldValue("formonly.l_rules")) --null

    SEND_ACTION("app_13005", "testlogin")

    -- Frontend Call:
    -- FunctionCall 103 (name = "setItem", returnCount = "0", isSystem = "0", moduleName = "localStorage", paramCount = "2") {
    --   FunctionCallParameter 100 (dataType = "STRING", value = "NJMDEMOSESSION", isNull = "0") { }
    --   FunctionCallParameter 99 (dataType = "STRING", value = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PHhlbmM6RW5jcnlwdGVkRGF0YSB4bWxuczp4ZW5jPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGVuYyMiIFR5cGU9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvMDQveG1sZW5jI0VsZW1lbnQiPjx4ZW5jOkVuY3J5cHRpb25NZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGVuYyNhZXMyNTYtY2JjIi8+PGRzaWc6S2V5SW5mbyB4bWxuczpkc2lnPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjIj48eGVuYzpFbmNyeXB0ZWRLZXk+PHhlbmM6RW5jcnlwdGlvbk1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvMDQveG1sZW5jI3JzYS0xXzUiLz48eGVuYzpDaXBoZXJEYXRhPjx4ZW5jOkNpcGhlclZhbHVlPkR1QXpHNjFhbVVVQVluckkwWEtMdXJNRE1zM1RFbjVkYWgvV09KdVFUbHZDcFp1cUVCL0xkVFhWbHp6WHZWS1UzZDh5UmZTTnA5YXVLc0t4OW5nVE43QlFDWDJTdk0yQnk3SFR2cUoxK29iZ2duMjE0Y1pqbEM1N2dwR0hIcHFpQW96Yld5TG9aKzR1ZjlYV0hJL2dLR3ZKOFF2WVZvOHpaRXpaUjg2NjBxcz08L3hlbmM6Q2lwaGVyVmFsdWU+PC94ZW5jOkNpcGhlckRhdGE+PC94ZW5jOkVuY3J5cHRlZEtleT48L2RzaWc6S2V5SW5mbz48eGVuYzpDaXBoZXJEYXRhPjx4ZW5jOkNpcGhlclZhbHVlPnhzUnpJWUl5VmpqcmRieE53QnBZem14aTk3dUI1QkUxaVpBcEVnOHViZG8xUjBUSlZKZVVlN2JPTmhhY091cjJDc0xmeFo0QjZZWmtnckdFTURaT0dPNnZwTHZVaTdVM0YwaUdXUmY4OXlUQTFiNHdDVU9mZ0RVc1o5TnpWanVHPC94ZW5jOkNpcGhlclZhbHVlPjwveGVuYzpDaXBoZXJEYXRhPjwveGVuYzpFbmNyeXB0ZWREYXRhPg==", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="1" dataType="INTEGER" isNull="0" value="0" ></FunctionCallReturn></FunctionCallEvent>



    -- Frontend Call:
    -- FunctionCall 46 (name = "feinfo", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 47 (dataType = "STRING", value = "target", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="l64xl212" ></FunctionCallReturn></FunctionCallEvent>



    WAIT_FOR_APPLICATION("app_13005", 4268)
    ASSERT_EQUALS(getWindowName(), "menu")
    ASSERT_EQUALS(getFormName(), "menu")
    ASSERT_EQUALS(getFocused(), "formonly.l_dummy")
    -- DialogType:Input
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("logout"))
    ASSERT(getActionActive("exit"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("menu.+tab_out_prev"))
    ASSERT(getActionActive("menu.+tab_out_next"))
    ASSERT(getActionActive("menu.nextrow"))
    ASSERT(getActionActive("menu.lastrow"))
    ASSERT(getActionActive("menu.editcopy"))
    ASSERT(getActionActive("menu.accept"))
    ASSERT(getActionActive("menu.find"))
    ASSERT(getActionActive("menu.findnext"))
    ASSERT(NOT getActionActive("back"))
    ASSERT(NOT getActionActive("+tab_out_prev"))
    ASSERT(NOT getActionActive("+tab_out_next"))
    ASSERT(NOT getActionActive("menu.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("menu.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT(NOT getActionActive("nextrow")) --Next
    ASSERT(NOT getActionActive("lastrow")) --Last
    ASSERT(NOT getActionActive("editcopy")) --Copy
    ASSERT(NOT getActionActive("accept")) --OK
    ASSERT(NOT getActionActive("find")) --Find
    ASSERT(NOT getActionActive("findnext")) --Find Next
    ASSERT_EQUALS(getFieldValue("formonly.l_titl"), "Four J's Demos Menu") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("formonly.m_user"), "test@test.com") --STRING
    ASSERT_EQUALS(getFieldValue("formonly.l_dummy"), "") --CHAR(1)
    ASSERT_EQUALS(getFieldValue("formonly.logo"), "logo_dark") --STRING
    ASSERT_EQUALS(getCurrentRow("menu"), "0")
    ASSERT_EQUALS(getCurrentColumn("menu"), "-1")
    ASSERT_EQUALS(getTableSize("menu"), "7")
    ASSERT_EQUALS(getTablePageSize("menu"), "12")
    ASSERT_EQUALS(getScrollingOffset("menu"), "0")

    RESIZE_TABLE("app_13005", "menu", 9)

    WAIT_FOR_APPLICATION("app_13005", 5275)
    ASSERT_EQUALS(getWindowName(), "menu")
    ASSERT_EQUALS(getFormName(), "menu")
    ASSERT_EQUALS(getFocused(), "formonly.l_dummy")
    -- DialogType:Input
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("logout"))
    ASSERT(getActionActive("exit"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("menu.+tab_out_prev"))
    ASSERT(getActionActive("menu.+tab_out_next"))
    ASSERT(getActionActive("menu.nextrow"))
    ASSERT(getActionActive("menu.lastrow"))
    ASSERT(getActionActive("menu.editcopy"))
    ASSERT(getActionActive("menu.accept"))
    ASSERT(getActionActive("menu.find"))
    ASSERT(getActionActive("menu.findnext"))
    ASSERT(NOT getActionActive("back"))
    ASSERT(NOT getActionActive("+tab_out_prev"))
    ASSERT(NOT getActionActive("+tab_out_next"))
    ASSERT(NOT getActionActive("menu.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("menu.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT(NOT getActionActive("nextrow")) --Next
    ASSERT(NOT getActionActive("lastrow")) --Last
    ASSERT(NOT getActionActive("editcopy")) --Copy
    ASSERT(NOT getActionActive("accept")) --OK
    ASSERT(NOT getActionActive("find")) --Find
    ASSERT(NOT getActionActive("findnext")) --Find Next
    ASSERT_EQUALS(getFieldValue("formonly.l_titl"), "Four J's Demos Menu") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("formonly.m_user"), "test@test.com") --STRING
    ASSERT_EQUALS(getFieldValue("formonly.l_dummy"), "") --CHAR(1)
    ASSERT_EQUALS(getFieldValue("formonly.logo"), "logo_dark") --STRING
    ASSERT_EQUALS(getCurrentRow("menu"), "0")
    ASSERT_EQUALS(getCurrentColumn("menu"), "-1")
    ASSERT_EQUALS(getTableSize("menu"), "7")
    ASSERT_EQUALS(getTablePageSize("menu"), "9")
    ASSERT_EQUALS(getScrollingOffset("menu"), "0")

    FOCUS_TABLE_CELL("app_13005", "menu", "m_text", 3)

    WAIT_FOR_APPLICATION("app_13005", 6242)
    ASSERT_EQUALS(getWindowName(), "menu")
    ASSERT_EQUALS(getFormName(), "menu")
    ASSERT_EQUALS(getFocused(), "formonly.l_dummy")
    -- DialogType:Input
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("logout"))
    ASSERT(getActionActive("exit"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("back"))
    ASSERT(getActionActive("menu.+tab_out_prev"))
    ASSERT(getActionActive("menu.+tab_out_next"))
    ASSERT(getActionActive("menu.nextrow"))
    ASSERT(getActionActive("menu.lastrow"))
    ASSERT(getActionActive("menu.editcopy"))
    ASSERT(getActionActive("menu.accept"))
    ASSERT(getActionActive("menu.find"))
    ASSERT(getActionActive("menu.findnext"))
    ASSERT(NOT getActionActive("+tab_out_prev"))
    ASSERT(NOT getActionActive("+tab_out_next"))
    ASSERT(NOT getActionActive("menu.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("menu.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT(NOT getActionActive("nextrow")) --Next
    ASSERT(NOT getActionActive("lastrow")) --Last
    ASSERT(NOT getActionActive("editcopy")) --Copy
    ASSERT(NOT getActionActive("accept")) --OK
    ASSERT(NOT getActionActive("find")) --Find
    ASSERT(NOT getActionActive("findnext")) --Find Next
    ASSERT_EQUALS(getFieldValue("formonly.l_titl"), "Order Entry") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("formonly.m_user"), "test@test.com") --STRING
    ASSERT_EQUALS(getFieldValue("formonly.l_dummy"), "") --CHAR(1)
    ASSERT_EQUALS(getFieldValue("formonly.logo"), "logo_dark") --STRING
    ASSERT_EQUALS(getCurrentRow("menu"), "0")
    ASSERT_EQUALS(getCurrentColumn("menu"), "-1")
    ASSERT_EQUALS(getTableSize("menu"), "5")
    ASSERT_EQUALS(getTablePageSize("menu"), "9")
    ASSERT_EQUALS(getScrollingOffset("menu"), "0")

    FOCUS_TABLE_CELL("app_13005", "menu", "m_text", 0)
    WAIT_FOR_APPLICATION("app_13022", 0)

    -- Frontend Call:
    -- FunctionCall 101 (name = "feinfo", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 102 (dataType = "STRING", value = "ostype", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="LINUX" ></FunctionCallReturn></FunctionCallEvent>



    -- Frontend Call:
    -- FunctionCall 106 (name = "feinfo", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 107 (dataType = "STRING", value = "osversion", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="Linux #36-Ubuntu SMP Wed Aug 15 16:00:05 UTC 2018" ></FunctionCallReturn></FunctionCallEvent>



    -- Frontend Call:
    -- FunctionCall 102 (name = "feinfo", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 101 (dataType = "STRING", value = "screenresolution", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="1920x1080" ></FunctionCallReturn></FunctionCallEvent>



    -- Frontend Call:
    -- FunctionCall 107 (name = "feinfo", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 106 (dataType = "STRING", value = "fepath", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="/opt/fourjs/gdc-3.10.18/bin" ></FunctionCallReturn></FunctionCallEvent>



    -- Frontend Call:
    -- FunctionCall 279 (name = "getenv", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 280 (dataType = "STRING", value = "USERNAME", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="" ></FunctionCallReturn></FunctionCallEvent>



    -- Frontend Call:
    -- FunctionCall 100 (name = "getenv", returnCount = "1", isSystem = "0", moduleName = "standard", paramCount = "1") {
    --   FunctionCallParameter 99 (dataType = "STRING", value = "LOGNAME", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="0" dataType="STRING" isNull="0" value="neilm" ></FunctionCallReturn></FunctionCallEvent>



    WAIT_FOR_APPLICATION("app_13022", 6463)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFocused(), "new")
    -- DialogType:Menu (style=null, text=)
    ASSERT(getActionActive("new")) --Insert
    ASSERT(getActionActive("update")) --Update
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("getcust"))
    ASSERT(getActionActive("getstock"))
    ASSERT(getActionActive("help")) --Help
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("quit")) --Quit
    ASSERT_EQUALS(getFieldValue("formonly.welcome"), "Welcome Mr Test Testing") --STRING
    ASSERT_NULL(getFieldValue("customer.customer_code")) --null
    ASSERT_NULL(getFieldValue("customer.customer_name")) --null
    ASSERT_NULL(getFieldValue("formonly.order_number")) --null
    ASSERT_NULL(getFieldValue("ord_head.order_datetime")) --null
    ASSERT_NULL(getFieldValue("ord_head.req_del_date")) --null
    ASSERT_NULL(getFieldValue("ord_head.username")) --null
    ASSERT_NULL(getFieldValue("ord_head.order_ref")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address1")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address2")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address3")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address4")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address5")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_postcode")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address1")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address2")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address3")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address4")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address5")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_postcode")) --null
    ASSERT_NULL(getFieldValue("ord_head.items")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_qty")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_disc")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_tax")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_gross")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_nett")) --null
    ASSERT_EQUALS(getCurrentRow("details"), "-1")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "-1")
    ASSERT_EQUALS(getTablePageSize("details"), "10")
    ASSERT_EQUALS(getScrollingOffset("details"), "-1")

    RESIZE_TABLE("app_13022", "details", 7)

    WAIT_FOR_APPLICATION("app_13022", 7986)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFocused(), "new")
    -- DialogType:Menu (style=null, text=)
    ASSERT(getActionActive("new")) --Insert
    ASSERT(getActionActive("update")) --Update
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("getcust"))
    ASSERT(getActionActive("getstock"))
    ASSERT(getActionActive("help")) --Help
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("quit")) --Quit
    ASSERT_EQUALS(getFieldValue("formonly.welcome"), "Welcome Mr Test Testing") --STRING
    ASSERT_NULL(getFieldValue("customer.customer_code")) --null
    ASSERT_NULL(getFieldValue("customer.customer_name")) --null
    ASSERT_NULL(getFieldValue("formonly.order_number")) --null
    ASSERT_NULL(getFieldValue("ord_head.order_datetime")) --null
    ASSERT_NULL(getFieldValue("ord_head.req_del_date")) --null
    ASSERT_NULL(getFieldValue("ord_head.username")) --null
    ASSERT_NULL(getFieldValue("ord_head.order_ref")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address1")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address2")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address3")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address4")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address5")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_postcode")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address1")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address2")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address3")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address4")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address5")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_postcode")) --null
    ASSERT_NULL(getFieldValue("ord_head.items")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_qty")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_disc")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_tax")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_gross")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_nett")) --null
    ASSERT_EQUALS(getCurrentRow("details"), "-1")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "-1")
    ASSERT_EQUALS(getTablePageSize("details"), "7")
    ASSERT_EQUALS(getScrollingOffset("details"), "-1")

    SEND_ACTION("app_13022", "find")

    WAIT_FOR_APPLICATION("app_13022", 8084)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFocused(), "formonly.order_number")
    -- DialogType:Input
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("getorder"))
    ASSERT(getActionActive("about")) --About
    ASSERT_NULL(getFieldValue("formonly.welcome")) --null
    ASSERT_NULL(getFieldValue("customer.customer_code")) --null
    ASSERT_NULL(getFieldValue("customer.customer_name")) --null
    ASSERT_EQUALS(getFieldValue("formonly.order_number"), "") --INTEGER
    ASSERT_NULL(getFieldValue("ord_head.order_datetime")) --null
    ASSERT_NULL(getFieldValue("ord_head.req_del_date")) --null
    ASSERT_NULL(getFieldValue("ord_head.username")) --null
    ASSERT_NULL(getFieldValue("ord_head.order_ref")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address1")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address2")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address3")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address4")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address5")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_postcode")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address1")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address2")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address3")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address4")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address5")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_postcode")) --null
    ASSERT_NULL(getFieldValue("ord_head.items")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_qty")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_disc")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_tax")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_gross")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_nett")) --null
    ASSERT_EQUALS(getCurrentRow("details"), "-1")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "0")
    ASSERT_EQUALS(getTablePageSize("details"), "10")
    ASSERT_EQUALS(getScrollingOffset("details"), "0")

    RESIZE_TABLE("app_13022", "details", 7)

    WAIT_FOR_APPLICATION("app_13022", 8699)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFocused(), "formonly.order_number")
    -- DialogType:Input
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("getorder"))
    ASSERT(getActionActive("about")) --About
    ASSERT_NULL(getFieldValue("formonly.welcome")) --null
    ASSERT_NULL(getFieldValue("customer.customer_code")) --null
    ASSERT_NULL(getFieldValue("customer.customer_name")) --null
    ASSERT_EQUALS(getFieldValue("formonly.order_number"), "") --INTEGER
    ASSERT_NULL(getFieldValue("ord_head.order_datetime")) --null
    ASSERT_NULL(getFieldValue("ord_head.req_del_date")) --null
    ASSERT_NULL(getFieldValue("ord_head.username")) --null
    ASSERT_NULL(getFieldValue("ord_head.order_ref")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address1")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address2")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address3")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address4")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_address5")) --null
    ASSERT_NULL(getFieldValue("ord_head.del_postcode")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address1")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address2")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address3")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address4")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_address5")) --null
    ASSERT_NULL(getFieldValue("ord_head.inv_postcode")) --null
    ASSERT_NULL(getFieldValue("ord_head.items")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_qty")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_disc")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_tax")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_gross")) --null
    ASSERT_NULL(getFieldValue("ord_head.total_nett")) --null
    ASSERT_EQUALS(getCurrentRow("details"), "-1")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "0")
    ASSERT_EQUALS(getTablePageSize("details"), "7")
    ASSERT_EQUALS(getScrollingOffset("details"), "0")

    SEND_ACTION("app_13022", "getorder")

    WAIT_FOR_APPLICATION("app_13022", 8803)
    ASSERT_EQUALS(getWindowName(), "getorder")
    ASSERT_EQUALS(getFormName(), "getorder")
    ASSERT_EQUALS(getFocused(), "arr")
    -- DialogType:DisplayArray
    ASSERT(getActionActive("arr.accept"))
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("arr.cancel"))
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("arr.close"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("arr.nextrow"))
    ASSERT(getActionActive("nextrow")) --Next
    ASSERT(getActionActive("arr.lastrow"))
    ASSERT(getActionActive("lastrow")) --Last
    ASSERT(getActionActive("arr.editcopy"))
    ASSERT(getActionActive("editcopy")) --Copy
    ASSERT(getActionActive("arr.about"))
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("arr.find"))
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("arr.findnext"))
    ASSERT(getActionActive("findnext")) --Find Next
    ASSERT(NOT getActionActive("arr.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("arr.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT_EQUALS(getCurrentRow("arr"), "0")
    ASSERT_EQUALS(getCurrentColumn("arr"), "-1")
    ASSERT_EQUALS(getTableSize("arr"), "50")
    ASSERT_EQUALS(getTablePageSize("arr"), "12")
    ASSERT_EQUALS(getScrollingOffset("arr"), "0")

    RESIZE_TABLE("app_13022", "arr", 16)

    WAIT_FOR_APPLICATION("app_13022", 10315)
    ASSERT_EQUALS(getWindowName(), "getorder")
    ASSERT_EQUALS(getFormName(), "getorder")
    ASSERT_EQUALS(getFocused(), "arr")
    -- DialogType:DisplayArray
    ASSERT(getActionActive("arr.accept"))
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("arr.cancel"))
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("arr.close"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("arr.nextrow"))
    ASSERT(getActionActive("nextrow")) --Next
    ASSERT(getActionActive("arr.lastrow"))
    ASSERT(getActionActive("lastrow")) --Last
    ASSERT(getActionActive("arr.editcopy"))
    ASSERT(getActionActive("editcopy")) --Copy
    ASSERT(getActionActive("arr.about"))
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("arr.find"))
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("arr.findnext"))
    ASSERT(getActionActive("findnext")) --Find Next
    ASSERT(NOT getActionActive("arr.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("arr.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT_EQUALS(getCurrentRow("arr"), "0")
    ASSERT_EQUALS(getCurrentColumn("arr"), "-1")
    ASSERT_EQUALS(getTableSize("arr"), "50")
    ASSERT_EQUALS(getTablePageSize("arr"), "16")
    ASSERT_EQUALS(getScrollingOffset("arr"), "0")

    FOCUS_TABLE_CELL("app_13022", "arr", "customer_name", 10)

    WAIT_FOR_APPLICATION("app_13022", 10466)
    ASSERT_EQUALS(getWindowName(), "getorder")
    ASSERT_EQUALS(getFormName(), "getorder")
    ASSERT_EQUALS(getFocused(), "arr")
    -- DialogType:DisplayArray
    ASSERT(getActionActive("arr.accept"))
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("arr.cancel"))
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("arr.close"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("arr.firstrow"))
    ASSERT(getActionActive("firstrow")) --First
    ASSERT(getActionActive("arr.prevrow"))
    ASSERT(getActionActive("prevrow")) --Previous
    ASSERT(getActionActive("arr.nextrow"))
    ASSERT(getActionActive("nextrow")) --Next
    ASSERT(getActionActive("arr.lastrow"))
    ASSERT(getActionActive("lastrow")) --Last
    ASSERT(getActionActive("arr.editcopy"))
    ASSERT(getActionActive("editcopy")) --Copy
    ASSERT(getActionActive("arr.about"))
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("arr.find"))
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("arr.findnext"))
    ASSERT(getActionActive("findnext")) --Find Next
    ASSERT_EQUALS(getCurrentRow("arr"), "10")
    ASSERT_EQUALS(getCurrentColumn("arr"), "-1")
    ASSERT_EQUALS(getTableSize("arr"), "50")
    ASSERT_EQUALS(getTablePageSize("arr"), "16")
    ASSERT_EQUALS(getScrollingOffset("arr"), "0")

    SEND_ACTION("app_13022", "arr.accept")

    WAIT_FOR_APPLICATION("app_13022", 11139)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFocused(), "details")
    -- DialogType:DisplayArray
    ASSERT(getActionActive("details.accept"))
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("details.cancel"))
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("details.close"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("details.nextrow"))
    ASSERT(getActionActive("nextrow")) --Next
    ASSERT(getActionActive("details.lastrow"))
    ASSERT(getActionActive("lastrow")) --Last
    ASSERT(getActionActive("details.editcopy"))
    ASSERT(getActionActive("editcopy")) --Copy
    ASSERT(getActionActive("details.expandall"))
    ASSERT(getActionActive("expandall"))
    ASSERT(getActionActive("details.collapseall"))
    ASSERT(getActionActive("collapseall"))
    ASSERT(getActionActive("details.enquire"))
    ASSERT(getActionActive("enquire"))
    ASSERT(getActionActive("details.update"))
    ASSERT(getActionActive("update")) --Update
    ASSERT(getActionActive("details.print"))
    ASSERT(getActionActive("print")) --Print
    ASSERT(getActionActive("details.picklist"))
    ASSERT(getActionActive("picklist"))
    ASSERT(getActionActive("details.hideaddr"))
    ASSERT(getActionActive("hideaddr"))
    ASSERT(getActionActive("details.showaddr"))
    ASSERT(getActionActive("showaddr"))
    ASSERT(getActionActive("details.find"))
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("details.findnext"))
    ASSERT(getActionActive("findnext")) --Find Next
    ASSERT(NOT getActionActive("details.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("details.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT_NULL(getFieldValue("formonly.welcome")) --null
    ASSERT_EQUALS(getFieldValue("customer.customer_code"), "2") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("customer.customer_name"), "O'Meara Operations Ltd") --VARCHAR(30)
    ASSERT_EQUALS(getFieldValue("formonly.order_number"), "11") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.order_datetime"), "2015-02-04 00:00:00") --DATETIME YEAR TO SECOND
    ASSERT_EQUALS(getFieldValue("ord_head.req_del_date"), "02/14/2015") --DATE
    ASSERT_EQUALS(getFieldValue("ord_head.username"), "auto") --CHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.order_ref"), "Auto Generated 10 07/09/2018") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.items"), "18") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_qty"), "208") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_disc"), "227.17") --DECIMAL(12,3)
    ASSERT_EQUALS(getFieldValue("ord_head.total_tax"), "1255.8") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_gross"), "7635.64") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_nett"), "8664.22") --DECIMAL(12,2)
    ASSERT_EQUALS(getCurrentRow("details"), "0")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "18")
    ASSERT_EQUALS(getTablePageSize("details"), "7")
    ASSERT_EQUALS(getScrollingOffset("details"), "0")

    SCROLL_TABLE("app_13022", "details", 3)

    WAIT_FOR_APPLICATION("app_13022", 11164)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFocused(), "details")
    -- DialogType:DisplayArray
    ASSERT(getActionActive("details.accept"))
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("details.cancel"))
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("details.close"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("details.nextrow"))
    ASSERT(getActionActive("nextrow")) --Next
    ASSERT(getActionActive("details.lastrow"))
    ASSERT(getActionActive("lastrow")) --Last
    ASSERT(getActionActive("details.editcopy"))
    ASSERT(getActionActive("editcopy")) --Copy
    ASSERT(getActionActive("details.expandall"))
    ASSERT(getActionActive("expandall"))
    ASSERT(getActionActive("details.collapseall"))
    ASSERT(getActionActive("collapseall"))
    ASSERT(getActionActive("details.enquire"))
    ASSERT(getActionActive("enquire"))
    ASSERT(getActionActive("details.update"))
    ASSERT(getActionActive("update")) --Update
    ASSERT(getActionActive("details.print"))
    ASSERT(getActionActive("print")) --Print
    ASSERT(getActionActive("details.picklist"))
    ASSERT(getActionActive("picklist"))
    ASSERT(getActionActive("details.hideaddr"))
    ASSERT(getActionActive("hideaddr"))
    ASSERT(getActionActive("details.showaddr"))
    ASSERT(getActionActive("showaddr"))
    ASSERT(getActionActive("details.find"))
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("details.findnext"))
    ASSERT(getActionActive("findnext")) --Find Next
    ASSERT(NOT getActionActive("details.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("details.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT_NULL(getFieldValue("formonly.welcome")) --null
    ASSERT_EQUALS(getFieldValue("customer.customer_code"), "2") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("customer.customer_name"), "O'Meara Operations Ltd") --VARCHAR(30)
    ASSERT_EQUALS(getFieldValue("formonly.order_number"), "11") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.order_datetime"), "2015-02-04 00:00:00") --DATETIME YEAR TO SECOND
    ASSERT_EQUALS(getFieldValue("ord_head.req_del_date"), "02/14/2015") --DATE
    ASSERT_EQUALS(getFieldValue("ord_head.username"), "auto") --CHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.order_ref"), "Auto Generated 10 07/09/2018") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.items"), "18") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_qty"), "208") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_disc"), "227.17") --DECIMAL(12,3)
    ASSERT_EQUALS(getFieldValue("ord_head.total_tax"), "1255.8") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_gross"), "7635.64") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_nett"), "8664.22") --DECIMAL(12,2)
    ASSERT_EQUALS(getCurrentRow("details"), "0")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "18")
    ASSERT_EQUALS(getTablePageSize("details"), "7")
    ASSERT_EQUALS(getScrollingOffset("details"), "3")

    SCROLL_TABLE("app_13022", "details", 6)

    WAIT_FOR_APPLICATION("app_13022", 11186)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFocused(), "details")
    -- DialogType:DisplayArray
    ASSERT(getActionActive("details.accept"))
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("details.cancel"))
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("details.close"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("details.nextrow"))
    ASSERT(getActionActive("nextrow")) --Next
    ASSERT(getActionActive("details.lastrow"))
    ASSERT(getActionActive("lastrow")) --Last
    ASSERT(getActionActive("details.editcopy"))
    ASSERT(getActionActive("editcopy")) --Copy
    ASSERT(getActionActive("details.expandall"))
    ASSERT(getActionActive("expandall"))
    ASSERT(getActionActive("details.collapseall"))
    ASSERT(getActionActive("collapseall"))
    ASSERT(getActionActive("details.enquire"))
    ASSERT(getActionActive("enquire"))
    ASSERT(getActionActive("details.update"))
    ASSERT(getActionActive("update")) --Update
    ASSERT(getActionActive("details.print"))
    ASSERT(getActionActive("print")) --Print
    ASSERT(getActionActive("details.picklist"))
    ASSERT(getActionActive("picklist"))
    ASSERT(getActionActive("details.hideaddr"))
    ASSERT(getActionActive("hideaddr"))
    ASSERT(getActionActive("details.showaddr"))
    ASSERT(getActionActive("showaddr"))
    ASSERT(getActionActive("details.find"))
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("details.findnext"))
    ASSERT(getActionActive("findnext")) --Find Next
    ASSERT(NOT getActionActive("details.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("details.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT_NULL(getFieldValue("formonly.welcome")) --null
    ASSERT_EQUALS(getFieldValue("customer.customer_code"), "2") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("customer.customer_name"), "O'Meara Operations Ltd") --VARCHAR(30)
    ASSERT_EQUALS(getFieldValue("formonly.order_number"), "11") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.order_datetime"), "2015-02-04 00:00:00") --DATETIME YEAR TO SECOND
    ASSERT_EQUALS(getFieldValue("ord_head.req_del_date"), "02/14/2015") --DATE
    ASSERT_EQUALS(getFieldValue("ord_head.username"), "auto") --CHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.order_ref"), "Auto Generated 10 07/09/2018") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.items"), "18") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_qty"), "208") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_disc"), "227.17") --DECIMAL(12,3)
    ASSERT_EQUALS(getFieldValue("ord_head.total_tax"), "1255.8") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_gross"), "7635.64") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_nett"), "8664.22") --DECIMAL(12,2)
    ASSERT_EQUALS(getCurrentRow("details"), "0")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "18")
    ASSERT_EQUALS(getTablePageSize("details"), "7")
    ASSERT_EQUALS(getScrollingOffset("details"), "6")

    SCROLL_TABLE("app_13022", "details", 9)

    WAIT_FOR_APPLICATION("app_13022", 11218)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getWindowTitle(), "09/11/2018: orderEntry 3.1c - Order Entry")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFormTitle(), "09/11/2018: orderEntry 3.1c - Order Entry")
    ASSERT_EQUALS(getFocused(), "details")
    -- DialogType:DisplayArray
    ASSERT(getActionActive("details.accept"))
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("details.cancel"))
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("details.close"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("details.nextrow"))
    ASSERT(getActionActive("nextrow")) --Next
    ASSERT(getActionActive("details.lastrow"))
    ASSERT(getActionActive("lastrow")) --Last
    ASSERT(getActionActive("details.editcopy"))
    ASSERT(getActionActive("editcopy")) --Copy
    ASSERT(getActionActive("details.expandall"))
    ASSERT(getActionActive("expandall"))
    ASSERT(getActionActive("details.collapseall"))
    ASSERT(getActionActive("collapseall"))
    ASSERT(getActionActive("details.enquire"))
    ASSERT(getActionActive("enquire"))
    ASSERT(getActionActive("details.update"))
    ASSERT(getActionActive("update")) --Update
    ASSERT(getActionActive("details.print"))
    ASSERT(getActionActive("print")) --Print
    ASSERT(getActionActive("details.picklist"))
    ASSERT(getActionActive("picklist"))
    ASSERT(getActionActive("details.hideaddr"))
    ASSERT(getActionActive("hideaddr"))
    ASSERT(getActionActive("details.showaddr"))
    ASSERT(getActionActive("showaddr"))
    ASSERT(getActionActive("details.find"))
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("details.findnext"))
    ASSERT(getActionActive("findnext")) --Find Next
    ASSERT(NOT getActionActive("details.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("details.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT_NULL(getFieldValue("formonly.welcome")) --null
    ASSERT_EQUALS(getFieldValue("customer.customer_code"), "2") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("customer.customer_name"), "O'Meara Operations Ltd") --VARCHAR(30)
    ASSERT_EQUALS(getFieldValue("formonly.order_number"), "11") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.order_datetime"), "2015-02-04 00:00:00") --DATETIME YEAR TO SECOND
    ASSERT_EQUALS(getFieldValue("ord_head.req_del_date"), "02/14/2015") --DATE
    ASSERT_EQUALS(getFieldValue("ord_head.username"), "auto") --CHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.order_ref"), "Auto Generated 10 07/09/2018") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.items"), "18") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_qty"), "208") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_disc"), "227.17") --DECIMAL(12,3)
    ASSERT_EQUALS(getFieldValue("ord_head.total_tax"), "1255.8") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_gross"), "7635.64") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_nett"), "8664.22") --DECIMAL(12,2)
    ASSERT_EQUALS(getCurrentRow("details"), "0")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "18")
    ASSERT_EQUALS(getTablePageSize("details"), "7")
    ASSERT_EQUALS(getScrollingOffset("details"), "9")

    SCROLL_TABLE("app_13022", "details", 11)

    WAIT_FOR_APPLICATION("app_13022", 12554)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getWindowTitle(), "09/11/2018: orderEntry 3.1c - Order Entry")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFormTitle(), "09/11/2018: orderEntry 3.1c - Order Entry")
    ASSERT_EQUALS(getFocused(), "details")
    -- DialogType:DisplayArray
    ASSERT(getActionActive("details.accept"))
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("details.cancel"))
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("details.close"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("details.nextrow"))
    ASSERT(getActionActive("nextrow")) --Next
    ASSERT(getActionActive("details.lastrow"))
    ASSERT(getActionActive("lastrow")) --Last
    ASSERT(getActionActive("details.editcopy"))
    ASSERT(getActionActive("editcopy")) --Copy
    ASSERT(getActionActive("details.expandall"))
    ASSERT(getActionActive("expandall"))
    ASSERT(getActionActive("details.collapseall"))
    ASSERT(getActionActive("collapseall"))
    ASSERT(getActionActive("details.enquire"))
    ASSERT(getActionActive("enquire"))
    ASSERT(getActionActive("details.update"))
    ASSERT(getActionActive("update")) --Update
    ASSERT(getActionActive("details.print"))
    ASSERT(getActionActive("print")) --Print
    ASSERT(getActionActive("details.picklist"))
    ASSERT(getActionActive("picklist"))
    ASSERT(getActionActive("details.hideaddr"))
    ASSERT(getActionActive("hideaddr"))
    ASSERT(getActionActive("details.showaddr"))
    ASSERT(getActionActive("showaddr"))
    ASSERT(getActionActive("details.find"))
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("details.findnext"))
    ASSERT(getActionActive("findnext")) --Find Next
    ASSERT(NOT getActionActive("details.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("details.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT_NULL(getFieldValue("formonly.welcome")) --null
    ASSERT_EQUALS(getFieldValue("customer.customer_code"), "2") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("customer.customer_name"), "O'Meara Operations Ltd") --VARCHAR(30)
    ASSERT_EQUALS(getFieldValue("formonly.order_number"), "11") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.order_datetime"), "2015-02-04 00:00:00") --DATETIME YEAR TO SECOND
    ASSERT_EQUALS(getFieldValue("ord_head.req_del_date"), "02/14/2015") --DATE
    ASSERT_EQUALS(getFieldValue("ord_head.username"), "auto") --CHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.order_ref"), "Auto Generated 10 07/09/2018") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.items"), "18") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_qty"), "208") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_disc"), "227.17") --DECIMAL(12,3)
    ASSERT_EQUALS(getFieldValue("ord_head.total_tax"), "1255.8") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_gross"), "7635.64") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_nett"), "8664.22") --DECIMAL(12,2)
    ASSERT_EQUALS(getCurrentRow("details"), "0")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "18")
    ASSERT_EQUALS(getTablePageSize("details"), "7")
    ASSERT_EQUALS(getScrollingOffset("details"), "11")

    EXPAND_TREE_ROW("app_13022", "details", 12)

    WAIT_FOR_APPLICATION("app_13022", 14571)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getWindowTitle(), "09/11/2018: orderEntry 3.1c - Order Entry")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFormTitle(), "09/11/2018: orderEntry 3.1c - Order Entry")
    ASSERT_EQUALS(getFocused(), "details")
    -- DialogType:DisplayArray
    ASSERT(getActionActive("details.accept"))
    ASSERT(getActionActive("accept")) --OK
    ASSERT(getActionActive("details.cancel"))
    ASSERT(getActionActive("cancel")) --Cancel
    ASSERT(getActionActive("details.close"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("details.nextrow"))
    ASSERT(getActionActive("nextrow")) --Next
    ASSERT(getActionActive("details.lastrow"))
    ASSERT(getActionActive("lastrow")) --Last
    ASSERT(getActionActive("details.editcopy"))
    ASSERT(getActionActive("editcopy")) --Copy
    ASSERT(getActionActive("details.expandall"))
    ASSERT(getActionActive("expandall"))
    ASSERT(getActionActive("details.collapseall"))
    ASSERT(getActionActive("collapseall"))
    ASSERT(getActionActive("details.enquire"))
    ASSERT(getActionActive("enquire"))
    ASSERT(getActionActive("details.update"))
    ASSERT(getActionActive("update")) --Update
    ASSERT(getActionActive("details.print"))
    ASSERT(getActionActive("print")) --Print
    ASSERT(getActionActive("details.picklist"))
    ASSERT(getActionActive("picklist"))
    ASSERT(getActionActive("details.hideaddr"))
    ASSERT(getActionActive("hideaddr"))
    ASSERT(getActionActive("details.showaddr"))
    ASSERT(getActionActive("showaddr"))
    ASSERT(getActionActive("details.find"))
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("details.findnext"))
    ASSERT(getActionActive("findnext")) --Find Next
    ASSERT(NOT getActionActive("details.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("details.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT_NULL(getFieldValue("formonly.welcome")) --null
    ASSERT_EQUALS(getFieldValue("customer.customer_code"), "2") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("customer.customer_name"), "O'Meara Operations Ltd") --VARCHAR(30)
    ASSERT_EQUALS(getFieldValue("formonly.order_number"), "11") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.order_datetime"), "2015-02-04 00:00:00") --DATETIME YEAR TO SECOND
    ASSERT_EQUALS(getFieldValue("ord_head.req_del_date"), "02/14/2015") --DATE
    ASSERT_EQUALS(getFieldValue("ord_head.username"), "auto") --CHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.order_ref"), "Auto Generated 10 07/09/2018") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.items"), "18") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_qty"), "208") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_disc"), "227.17") --DECIMAL(12,3)
    ASSERT_EQUALS(getFieldValue("ord_head.total_tax"), "1255.8") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_gross"), "7635.64") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_nett"), "8664.22") --DECIMAL(12,2)
    ASSERT_EQUALS(getCurrentRow("details"), "0")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "23")
    ASSERT_EQUALS(getTablePageSize("details"), "7")
    ASSERT_EQUALS(getScrollingOffset("details"), "11")

    SEND_ACTION("app_13022", "cancel")

    WAIT_FOR_APPLICATION("app_13022", 15699)
    ASSERT_EQUALS(getWindowName(), "screen")
    ASSERT_EQUALS(getWindowTitle(), "09/11/2018: orderEntry 3.1c - Order Entry")
    ASSERT_EQUALS(getFormName(), "ordent2")
    ASSERT_EQUALS(getFormTitle(), "09/11/2018: orderEntry 3.1c - Order Entry")
    ASSERT_EQUALS(getFocused(), "new")
    -- DialogType:Menu (style=null, text=)
    ASSERT(getActionActive("new")) --Insert
    ASSERT(getActionActive("update")) --Update
    ASSERT(getActionActive("find")) --Find
    ASSERT(getActionActive("getcust"))
    ASSERT(getActionActive("getstock"))
    ASSERT(getActionActive("help")) --Help
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("quit")) --Quit
    ASSERT_NULL(getFieldValue("formonly.welcome")) --null
    ASSERT_EQUALS(getFieldValue("customer.customer_code"), "2") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("customer.customer_name"), "O'Meara Operations Ltd") --VARCHAR(30)
    ASSERT_EQUALS(getFieldValue("formonly.order_number"), "11") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.order_datetime"), "2015-02-04 00:00:00") --DATETIME YEAR TO SECOND
    ASSERT_EQUALS(getFieldValue("ord_head.req_del_date"), "02/14/2015") --DATE
    ASSERT_EQUALS(getFieldValue("ord_head.username"), "auto") --CHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.order_ref"), "Auto Generated 10 07/09/2018") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.del_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address1"), "Some Road") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address2"), "The Large Town") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address3"), "London") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address4"), "U.K.") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_address5"), "") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("ord_head.inv_postcode"), "SW12") --VARCHAR(8)
    ASSERT_EQUALS(getFieldValue("ord_head.items"), "18") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_qty"), "208") --INTEGER
    ASSERT_EQUALS(getFieldValue("ord_head.total_disc"), "227.17") --DECIMAL(12,3)
    ASSERT_EQUALS(getFieldValue("ord_head.total_tax"), "1255.8") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_gross"), "7635.64") --DECIMAL(12,2)
    ASSERT_EQUALS(getFieldValue("ord_head.total_nett"), "8664.22") --DECIMAL(12,2)
    ASSERT_EQUALS(getCurrentRow("details"), "-1")
    ASSERT_EQUALS(getCurrentColumn("details"), "-1")
    ASSERT_EQUALS(getTableSize("details"), "23")
    ASSERT_EQUALS(getTablePageSize("details"), "7")
    ASSERT_EQUALS(getScrollingOffset("details"), "11")

    SEND_ACTION("app_13022", "quit")

    WAIT_FOR_APPLICATION("app_13005", 18411)
    ASSERT_EQUALS(getWindowName(), "menu")
    ASSERT_EQUALS(getWindowTitle(), "09/11/2018: menu 3.1c - test@test.com")
    ASSERT_EQUALS(getFormName(), "menu")
    ASSERT_EQUALS(getFormTitle(), "09/11/2018: menu 3.1c - test@test.com")
    ASSERT_EQUALS(getFocused(), "formonly.l_dummy")
    -- DialogType:Input
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("logout"))
    ASSERT(getActionActive("exit"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("back"))
    ASSERT(getActionActive("menu.+tab_out_prev"))
    ASSERT(getActionActive("menu.+tab_out_next"))
    ASSERT(getActionActive("menu.nextrow"))
    ASSERT(getActionActive("menu.lastrow"))
    ASSERT(getActionActive("menu.editcopy"))
    ASSERT(getActionActive("menu.accept"))
    ASSERT(getActionActive("menu.find"))
    ASSERT(getActionActive("menu.findnext"))
    ASSERT(NOT getActionActive("+tab_out_prev"))
    ASSERT(NOT getActionActive("+tab_out_next"))
    ASSERT(NOT getActionActive("menu.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("menu.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT(NOT getActionActive("nextrow")) --Next
    ASSERT(NOT getActionActive("lastrow")) --Last
    ASSERT(NOT getActionActive("editcopy")) --Copy
    ASSERT(NOT getActionActive("accept")) --OK
    ASSERT(NOT getActionActive("find")) --Find
    ASSERT(NOT getActionActive("findnext")) --Find Next
    ASSERT_EQUALS(getFieldValue("formonly.l_titl"), "Order Entry") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("formonly.m_user"), "test@test.com") --STRING
    ASSERT_EQUALS(getFieldValue("formonly.l_dummy"), "") --CHAR(1)
    ASSERT_EQUALS(getFieldValue("formonly.logo"), "logo_dark") --STRING
    ASSERT_EQUALS(getCurrentRow("menu"), "0")
    ASSERT_EQUALS(getCurrentColumn("menu"), "-1")
    ASSERT_EQUALS(getTableSize("menu"), "5")
    ASSERT_EQUALS(getTablePageSize("menu"), "9")
    ASSERT_EQUALS(getScrollingOffset("menu"), "0")

    FOCUS_TABLE_CELL("app_13005", "menu", "m_text", 4)

    WAIT_FOR_APPLICATION("app_13005", 22537)
    ASSERT_EQUALS(getWindowName(), "menu")
    ASSERT_EQUALS(getWindowTitle(), "09/11/2018: menu 3.1c - test@test.com")
    ASSERT_EQUALS(getFormName(), "menu")
    ASSERT_EQUALS(getFormTitle(), "09/11/2018: menu 3.1c - test@test.com")
    ASSERT_EQUALS(getFocused(), "formonly.l_dummy")
    -- DialogType:Input
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("logout"))
    ASSERT(getActionActive("exit"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("menu.+tab_out_prev"))
    ASSERT(getActionActive("menu.+tab_out_next"))
    ASSERT(getActionActive("menu.nextrow"))
    ASSERT(getActionActive("menu.lastrow"))
    ASSERT(getActionActive("menu.editcopy"))
    ASSERT(getActionActive("menu.accept"))
    ASSERT(getActionActive("menu.find"))
    ASSERT(getActionActive("menu.findnext"))
    ASSERT(NOT getActionActive("back"))
    ASSERT(NOT getActionActive("+tab_out_prev"))
    ASSERT(NOT getActionActive("+tab_out_next"))
    ASSERT(NOT getActionActive("menu.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("menu.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT(NOT getActionActive("nextrow")) --Next
    ASSERT(NOT getActionActive("lastrow")) --Last
    ASSERT(NOT getActionActive("editcopy")) --Copy
    ASSERT(NOT getActionActive("accept")) --OK
    ASSERT(NOT getActionActive("find")) --Find
    ASSERT(NOT getActionActive("findnext")) --Find Next
    ASSERT_EQUALS(getFieldValue("formonly.l_titl"), "Four J's Demos Menu") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("formonly.m_user"), "test@test.com") --STRING
    ASSERT_EQUALS(getFieldValue("formonly.l_dummy"), "") --CHAR(1)
    ASSERT_EQUALS(getFieldValue("formonly.logo"), "logo_dark") --STRING
    ASSERT_EQUALS(getCurrentRow("menu"), "0")
    ASSERT_EQUALS(getCurrentColumn("menu"), "-1")
    ASSERT_EQUALS(getTableSize("menu"), "7")
    ASSERT_EQUALS(getTablePageSize("menu"), "9")
    ASSERT_EQUALS(getScrollingOffset("menu"), "0")

    FOCUS_TABLE_CELL("app_13005", "menu", "m_text", 0)

    WAIT_FOR_APPLICATION("app_13005", 27915)
    ASSERT_EQUALS(getWindowName(), "menu")
    ASSERT_EQUALS(getWindowTitle(), "09/11/2018: menu 3.1c - test@test.com")
    ASSERT_EQUALS(getFormName(), "menu")
    ASSERT_EQUALS(getFormTitle(), "09/11/2018: menu 3.1c - test@test.com")
    ASSERT_EQUALS(getFocused(), "formonly.l_dummy")
    -- DialogType:Input
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("logout"))
    ASSERT(getActionActive("exit"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("back"))
    ASSERT(getActionActive("menu.+tab_out_prev"))
    ASSERT(getActionActive("menu.+tab_out_next"))
    ASSERT(getActionActive("menu.nextrow"))
    ASSERT(getActionActive("menu.lastrow"))
    ASSERT(getActionActive("menu.editcopy"))
    ASSERT(getActionActive("menu.accept"))
    ASSERT(getActionActive("menu.find"))
    ASSERT(getActionActive("menu.findnext"))
    ASSERT(NOT getActionActive("+tab_out_prev"))
    ASSERT(NOT getActionActive("+tab_out_next"))
    ASSERT(NOT getActionActive("menu.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("menu.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT(NOT getActionActive("nextrow")) --Next
    ASSERT(NOT getActionActive("lastrow")) --Last
    ASSERT(NOT getActionActive("editcopy")) --Copy
    ASSERT(NOT getActionActive("accept")) --OK
    ASSERT(NOT getActionActive("find")) --Find
    ASSERT(NOT getActionActive("findnext")) --Find Next
    ASSERT_EQUALS(getFieldValue("formonly.l_titl"), "UI Demo Programs") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("formonly.m_user"), "test@test.com") --STRING
    ASSERT_EQUALS(getFieldValue("formonly.l_dummy"), "") --CHAR(1)
    ASSERT_EQUALS(getFieldValue("formonly.logo"), "logo_dark") --STRING
    ASSERT_EQUALS(getCurrentRow("menu"), "0")
    ASSERT_EQUALS(getCurrentColumn("menu"), "-1")
    ASSERT_EQUALS(getTableSize("menu"), "8")
    ASSERT_EQUALS(getTablePageSize("menu"), "9")
    ASSERT_EQUALS(getScrollingOffset("menu"), "0")

    FOCUS_TABLE_CELL("app_13005", "menu", "m_text", 7)

    WAIT_FOR_APPLICATION("app_13005", 29539)
    ASSERT_EQUALS(getWindowName(), "menu")
    ASSERT_EQUALS(getWindowTitle(), "09/11/2018: menu 3.1c - test@test.com")
    ASSERT_EQUALS(getFormName(), "menu")
    ASSERT_EQUALS(getFormTitle(), "09/11/2018: menu 3.1c - test@test.com")
    ASSERT_EQUALS(getFocused(), "formonly.l_dummy")
    -- DialogType:Input
    ASSERT(getActionActive("about")) --About
    ASSERT(getActionActive("logout"))
    ASSERT(getActionActive("exit"))
    ASSERT(getActionActive("close")) --Close
    ASSERT(getActionActive("menu.+tab_out_prev"))
    ASSERT(getActionActive("menu.+tab_out_next"))
    ASSERT(getActionActive("menu.nextrow"))
    ASSERT(getActionActive("menu.lastrow"))
    ASSERT(getActionActive("menu.editcopy"))
    ASSERT(getActionActive("menu.accept"))
    ASSERT(getActionActive("menu.find"))
    ASSERT(getActionActive("menu.findnext"))
    ASSERT(NOT getActionActive("back"))
    ASSERT(NOT getActionActive("+tab_out_prev"))
    ASSERT(NOT getActionActive("+tab_out_next"))
    ASSERT(NOT getActionActive("menu.firstrow"))
    ASSERT(NOT getActionActive("firstrow")) --First
    ASSERT(NOT getActionActive("menu.prevrow"))
    ASSERT(NOT getActionActive("prevrow")) --Previous
    ASSERT(NOT getActionActive("nextrow")) --Next
    ASSERT(NOT getActionActive("lastrow")) --Last
    ASSERT(NOT getActionActive("editcopy")) --Copy
    ASSERT(NOT getActionActive("accept")) --OK
    ASSERT(NOT getActionActive("find")) --Find
    ASSERT(NOT getActionActive("findnext")) --Find Next
    ASSERT_EQUALS(getFieldValue("formonly.l_titl"), "Four J's Demos Menu") --VARCHAR(40)
    ASSERT_EQUALS(getFieldValue("formonly.m_user"), "test@test.com") --STRING
    ASSERT_EQUALS(getFieldValue("formonly.l_dummy"), "") --CHAR(1)
    ASSERT_EQUALS(getFieldValue("formonly.logo"), "logo_dark") --STRING
    ASSERT_EQUALS(getCurrentRow("menu"), "0")
    ASSERT_EQUALS(getCurrentColumn("menu"), "-1")
    ASSERT_EQUALS(getTableSize("menu"), "7")
    ASSERT_EQUALS(getTablePageSize("menu"), "9")
    ASSERT_EQUALS(getScrollingOffset("menu"), "0")

    SEND_ACTION("app_13005", "logout")

    -- Frontend Call:
    -- FunctionCall 395 (name = "removeItem", returnCount = "0", isSystem = "0", moduleName = "localStorage", paramCount = "1") {
    --   FunctionCallParameter 394 (dataType = "STRING", value = "NJMDEMOSESSION", isNull = "0") { } }
    -- Frontend result:
    -- <FunctionCallEvent id="0" result="0" ><FunctionCallReturn id="1" dataType="INTEGER" isNull="0" value="0" ></FunctionCallReturn></FunctionCallEvent>



    APPLICATION_ENDED("app_13022", 0)

    APPLICATION_ENDED("app_13005", 0)
END FUNCTION -- menu_test
